import sys
import os
import numpy as np
from pathlib import Path
from PySide6.QtWidgets import QApplication, QFileDialog
from PySide6.QtQuick import QQuickView
from PySide6.QtCore import QObject, Slot, Signal, QUrl
from PIL import Image
import tensorflow as tf
import pydicom
from pydicom.pixel_data_handlers.util import apply_modality_lut, apply_voi_lut


def resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)


def load_dicom_image(dicom_path):
    """Load DICOM file and convert to PIL Image"""
    dicom = pydicom.dcmread(dicom_path)
    pixel_array = dicom.pixel_array
    
    pixel_array = apply_modality_lut(pixel_array, dicom)
    
    if hasattr(dicom, 'WindowCenter') and hasattr(dicom, 'WindowWidth'):
        pixel_array = apply_voi_lut(pixel_array, dicom)
    
    # Normalize to 0-255
    pixel_array = pixel_array.astype(np.float64)
    pixel_min = pixel_array.min()
    pixel_max = pixel_array.max()
    
    if pixel_max > pixel_min:
        pixel_array = ((pixel_array - pixel_min) / (pixel_max - pixel_min) * 255.0)
    
    pixel_array = pixel_array.astype(np.uint8)
    
    # Convert to RGB
    if len(pixel_array.shape) == 2:
        pixel_array = np.stack([pixel_array] * 3, axis=-1)
    
    img = Image.fromarray(pixel_array, mode='RGB')
    return img


def load_dicom_folder(folder_path):
    """
    Load all DICOM slices from a folder
    Returns: list of DICOM file paths (sorted)
    """
    print(f"Loading DICOM folder: {folder_path}")
    
    # Get all DICOM files
    dicom_files = []
    for file in os.listdir(folder_path):
        if file.lower().endswith(('.dcm', '.dicom')):
            dicom_files.append(os.path.join(folder_path, file))
    
    if not dicom_files:
        raise ValueError("No DICOM files found in folder")
    
    print(f"Found {len(dicom_files)} DICOM files")
    
    # Load and sort by InstanceNumber
    slices = []
    for dcm_file in dicom_files:
        try:
            dcm = pydicom.dcmread(dcm_file)
            slices.append((dcm, dcm_file))
        except Exception as e:
            print(f"Warning: Could not read {dcm_file}: {e}")
    
    # Sort by InstanceNumber or SliceLocation
    slices.sort(key=lambda x: float(getattr(x[0], 'InstanceNumber', 0)))
    
    slice_paths = [s[1] for s in slices]
    print(f"Sorted {len(slice_paths)} slices")
    
    return slice_paths


def select_key_slices(slice_paths, num_slices=5):
    """
    Select key representative slices from the volume for analysis
    Strategy: Take slices evenly distributed through the volume
    
    Args:
        slice_paths: List of all DICOM slice paths
        num_slices: Number of key slices to analyze (default 5)
    
    Returns:
        List of selected slice paths
    """
    total = len(slice_paths)
    
    if total <= num_slices:
        # If we have fewer slices than requested, use all
        return slice_paths
    
    # Select slices evenly distributed through the volume
    # Skip first and last few slices (often just skull/air)
    skip_start = max(1, total // 10)  # Skip first 10%
    skip_end = max(1, total // 10)    # Skip last 10%
    
    useful_range = slice_paths[skip_start:-skip_end]
    
    # Select evenly spaced slices from useful range
    indices = np.linspace(0, len(useful_range) - 1, num_slices, dtype=int)
    selected = [useful_range[i] for i in indices]
    
    print(f"Selected {len(selected)} key slices from {total} total slices")
    for i, path in enumerate(selected):
        print(f"  Key slice {i+1}: {os.path.basename(path)}")
    
    return selected


def analyze_multiple_slices(model, slice_paths):
    """
    Analyze multiple slices and aggregate the results
    
    Strategy:
    1. Predict on each slice
    2. Use majority voting + max confidence
    3. Return final diagnosis
    
    Args:
        model: Trained TensorFlow model
        slice_paths: List of DICOM slice paths to analyze
    
    Returns:
        (label, confidence, slice_results)
    """
    print(f"\n{'='*50}")
    print(f"Analyzing {len(slice_paths)} slices...")
    print(f"{'='*50}")
    
    predictions = []
    slice_results = []
    
    for i, slice_path in enumerate(slice_paths):
        # Load and preprocess
        img = load_dicom_image(slice_path)
        img = img.resize((224, 224))
        img_array = np.array(img) / 255.0
        img_array = np.expand_dims(img_array, axis=0).astype(np.float32)
        
        # Predict
        pred = model.predict(img_array, verbose=0)[0][0]
        
        # Determine result for this slice
        is_tumor = pred >= 0.5
        confidence = float(pred if is_tumor else 1 - pred)
        label = "Tumor" if is_tumor else "No Tumor"
        
        predictions.append(pred)
        slice_results.append({
            'slice': os.path.basename(slice_path),
            'label': label,
            'confidence': confidence,
            'raw_score': float(pred)
        })
        
        print(f"  Slice {i+1}/{len(slice_paths)}: {label} (conf: {confidence:.2%})")
    
    # ═══════════════════════════════════════════════════
    # AGGREGATION STRATEGY: Multi-criteria decision
    # ═══════════════════════════════════════════════════
    
    predictions = np.array(predictions)
    
    # Method 1: Average prediction across all slices
    avg_prediction = np.mean(predictions)
    
    # Method 2: Maximum prediction (most abnormal slice)
    max_prediction = np.max(predictions)
    
    # Method 3: Majority voting
    tumor_count = np.sum(predictions >= 0.5)
    total_count = len(predictions)
    tumor_ratio = tumor_count / total_count
    
    print(f"\n{'='*50}")
    print(f"AGGREGATION RESULTS:")
    print(f"{'='*50}")
    print(f"  Average prediction: {avg_prediction:.4f}")
    print(f"  Maximum prediction: {max_prediction:.4f}")
    print(f"  Tumor slices: {tumor_count}/{total_count} ({tumor_ratio:.1%})")
    
    # ═══════════════════════════════════════════════════
    # FINAL DECISION LOGIC
    # ═══════════════════════════════════════════════════
    
    # If ANY slice shows strong tumor signal (>0.7), flag as tumor
    if max_prediction >= 0.7:
        final_label = "Tumor"
        final_confidence = float(max_prediction)
        decision_method = "Maximum confidence"
    
    # If majority of slices show tumor
    elif tumor_ratio >= 0.5:
        final_label = "Tumor"
        final_confidence = float(avg_prediction)
        decision_method = "Majority voting"
    
    # Otherwise, use average
    else:
        if avg_prediction >= 0.5:
            final_label = "Tumor"
            final_confidence = float(avg_prediction)
        else:
            final_label = "No Tumor"
            final_confidence = float(1 - avg_prediction)
        decision_method = "Average prediction"
    
    print(f"\n{'='*50}")
    print(f"FINAL DIAGNOSIS:")
    print(f"{'='*50}")
    print(f"  Result: {final_label}")
    print(f"  Confidence: {final_confidence:.2%}")
    print(f"  Method: {decision_method}")
    print(f"{'='*50}\n")
    
    return final_label, final_confidence, slice_results


class Backend(QObject):
    imagePathChanged = Signal(str)
    textChanged = Signal(str)
    predictionResult = Signal(str, float)  # label, confidence
    predictionError = Signal(str)
    volumeLoaded = Signal(int, str)  # num_slices, representative_slice_path
    analysisProgress = Signal(int, int)  # current_slice, total_slices

    def __init__(self):
        super().__init__()
        self.model = None
        self.current_slices = []
        self._load_model()

    def _load_model(self):
        try:
            model_path = resource_path("brain_tumor_model.h5")
            print("Loading model...")
            self.model = tf.keras.models.load_model(model_path)
            print("✅ Model loaded!")

            # Warm-up
            print("Warming up model...")
            dummy = np.zeros((1, 224, 224, 3), dtype=np.float32)
            self.model.predict(dummy, verbose=0)
            print("✅ Model is ready!")

        except Exception as e:
            print(f"❌ Error loading model: {e}")
            self.model = None

    @Slot()
    def open_image(self):
        """Open single image file"""
        file_path, _ = QFileDialog.getOpenFileName(
            None,
            "Select MRI Image",
            "",
            "Images (*.png *.jpg *.jpeg *.bmp *.dcm *.dicom)"
        )

        if file_path:
            print(f"Selected: {file_path}")
            
            if file_path.lower().endswith(('.dcm', '.dicom')):
                try:
                    print("Loading DICOM file...")
                    dicom_img = load_dicom_image(file_path)
                    
                    temp_png_path = os.path.join(os.path.dirname(file_path), "_temp_dicom_display.png")
                    dicom_img.save(temp_png_path)
                    
                    file_url = QUrl.fromLocalFile(temp_png_path).toString()
                    self.imagePathChanged.emit(file_url)
                    self.textChanged.emit("DICOM loaded. Analyzing...")
                    
                    if self.model is None:
                        self.predictionError.emit("Model not loaded!")
                        return
                    self._run_prediction(file_path)
                    
                except Exception as e:
                    print(f"❌ Error loading DICOM: {e}")
                    self.predictionError.emit(f"Failed to load DICOM: {str(e)}")
                    return
            else:
                file_url = QUrl.fromLocalFile(file_path).toString()
                self.imagePathChanged.emit(file_url)
                self.textChanged.emit("Analyzing...")
                
                if self.model is None:
                    self.predictionError.emit("Model not loaded!")
                    return
                self._run_prediction(file_path)

    @Slot()
    def open_dicom_folder(self):
        """Open folder containing DICOM slices and analyze all key slices"""
        folder_path = QFileDialog.getExistingDirectory(
            None,
            "Select DICOM Folder (containing slices)",
            ""
        )
        
        if folder_path:
            print(f"Selected folder: {folder_path}")
            self.textChanged.emit("Loading DICOM volume...")
            
            try:
                # Load all slice paths
                slice_paths = load_dicom_folder(folder_path)
                self.current_slices = slice_paths
                
                # Select key slices for analysis
                key_slices = select_key_slices(slice_paths, num_slices=5)
                
                # Display middle key slice
                middle_idx = len(key_slices) // 2
                representative_slice = key_slices[middle_idx]
                
                # Load and display representative slice
                slice_img = load_dicom_image(representative_slice)
                temp_png = os.path.join(folder_path, "_temp_representative_slice.png")
                slice_img.save(temp_png)
                
                file_url = QUrl.fromLocalFile(temp_png).toString()
                self.imagePathChanged.emit(file_url)
                
                # Emit signal with volume info
                self.volumeLoaded.emit(len(slice_paths), temp_png)
                self.textChanged.emit(f"Analyzing {len(key_slices)} key slices from {len(slice_paths)} total...")
                
                # ANALYZE ALL KEY SLICES AND AGGREGATE
                if self.model is None:
                    self.predictionError.emit("Model not loaded!")
                    return
                
                import time
                start = time.time()
                
                final_label, final_confidence, slice_results = analyze_multiple_slices(
                    self.model, 
                    key_slices
                )
                
                elapsed = time.time() - start
                print(f"Total analysis time: {elapsed:.2f}s")
                
                # Emit final result
                self.predictionResult.emit(final_label, final_confidence)
                self.textChanged.emit(f"Analyzed {len(key_slices)} slices. Final diagnosis ready.")
                
            except Exception as e:
                print(f"❌ Error loading DICOM folder: {e}")
                import traceback
                traceback.print_exc()
                self.predictionError.emit(f"Failed to load DICOM folder: {str(e)}")

    @Slot(int)
    def select_slice(self, slice_index):
        """Select and display a specific slice (just viewing, no re-analysis)"""
        if not self.current_slices or slice_index >= len(self.current_slices):
            return
        
        try:
            slice_path = self.current_slices[slice_index]
            slice_img = load_dicom_image(slice_path)
            
            temp_png = os.path.join(os.path.dirname(slice_path), f"_temp_slice_{slice_index}.png")
            slice_img.save(temp_png)
            
            file_url = QUrl.fromLocalFile(temp_png).toString()
            self.imagePathChanged.emit(file_url)
            # Don't re-analyze, just viewing
            
        except Exception as e:
            print(f"Error loading slice {slice_index}: {e}")

    def _run_prediction(self, image_path):
        """Run prediction on single image"""
        try:
            import time
            start = time.time()

            if image_path.lower().endswith(('.dcm', '.dicom')):
                print("Processing DICOM for prediction...")
                img = load_dicom_image(image_path)
            else:
                img = Image.open(image_path).convert('RGB')
            
            img = img.resize((224, 224))
            img_array = np.array(img) / 255.0
            img_array = np.expand_dims(img_array, axis=0).astype(np.float32)

            prediction = self.model.predict(img_array, verbose=0)[0][0]

            print(f"⏱️  Prediction took: {time.time() - start:.2f}s")

            if prediction >= 0.5:
                label = "Tumor"
                confidence = float(prediction)
            else:
                label = "No Tumor"
                confidence = float(1 - prediction)

            print(f"Result: {label} | Confidence: {confidence:.4f}")
            
            self.predictionResult.emit(label, confidence)

        except Exception as e:
            print(f"❌ Prediction error: {e}")
            import traceback
            traceback.print_exc()
            self.predictionError.emit(str(e))


if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setApplicationName("Brain MRI Diagnostic System")
    app.setApplicationVersion("1.0.0")

    view = QQuickView()

    backend = Backend()
    view.rootContext().setContextProperty("backend", backend)

    current_dir = Path(__file__).parent
    qml_file = current_dir / "main.qml"
    view.setSource(QUrl.fromLocalFile(str(qml_file)))

    view.setTitle("Brain MRI Diagnostic System")
    view.setResizeMode(QQuickView.SizeRootObjectToView)
    view.resize(1366, 768)
    view.show()

    if not view.rootObject():
        print("Error: Failed to load QML file")
        sys.exit(-1)

    print("Application started!")
    sys.exit(app.exec())