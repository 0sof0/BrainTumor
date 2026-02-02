import sys
import os
import numpy as np
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
from PySide6.QtWidgets import QApplication, QFileDialog
from PySide6.QtQuick import QQuickView
from PySide6.QtCore import QObject, Slot, Signal, QUrl, QMetaObject, Qt
from PIL import Image
import tensorflow as tf


def resource_path(relative_path):
    try:
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)


class Backend(QObject):
    imagePathChanged = Signal(str)
    textChanged = Signal(str)
    predictionResult = Signal(str, float)
    predictionError = Signal(str)

    def __init__(self):
        super().__init__()
        self.model = None
        self.executor = ThreadPoolExecutor(max_workers=1)
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

    def _predict(self, image_path):
        """Runs in background thread"""
        try:
            import time
            start = time.time()

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

            # Use invokeMethod to safely call slot on main thread
            QMetaObject.invokeMethod(
                self,
                "_emit_result",
                Qt.QueuedConnection,
                label,
                confidence
            )

        except Exception as e:
            print(f"❌ Prediction error: {e}")
            QMetaObject.invokeMethod(
                self,
                "_emit_error",
                Qt.QueuedConnection,
                str(e)
            )

    @Slot(str, float)
    def _emit_result(self, label, confidence):
        """Called on main thread via invokeMethod"""
        print(f"Emitting result: {label} {confidence}")
        self.predictionResult.emit(label, confidence)

    @Slot(str)
    def _emit_error(self, error):
        """Called on main thread via invokeMethod"""
        self.predictionError.emit(error)

    @Slot()
    def open_image(self):
        file_path, _ = QFileDialog.getOpenFileName(
            None,
            "Select MRI Image",
            "",
            "Images (*.png *.jpg *.jpeg *.bmp)"
        )

        if file_path:
            print(f"Selected: {file_path}")
            file_url = QUrl.fromLocalFile(file_path).toString()
            self.imagePathChanged.emit(file_url)
            self.textChanged.emit("Analyzing...")

            if self.model is None:
                self.predictionError.emit("Model not loaded!")
                return

            # Submit to thread pool
            self.executor.submit(self._predict, file_path)


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