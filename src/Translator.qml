pragma Singleton
import QtQuick

QtObject {
    id: translator

    property string currentLanguage: "en"

    signal languageChanged()

    function setLanguage(lang) {
        if (lang === "en" || lang === "fr") {
            currentLanguage = lang
            languageChanged()
        }
    }

    property var translations: ({
        // ─── Buttons ────────────────────────────────
        "uploadImage": {
            "en": "Upload Image",
            "fr": "Télécharger l'image"
        },
        "close": {
            "en": "Close",
            "fr": "Fermer"
        },

        // ─── Title ──────────────────────────────────
        "mainTitle": {
            "en": "Brain MRI Diagnostic System",
            "fr": "Système de Diagnostic IRM Cérébral"
        },

        // ─── Stage ──────────────────────────────────
        "stage": {
            "en": "Stage 1: Initial Assessment",
            "fr": "Étape 1 : Évaluation Initiale"
        },

        // ─── Status (Dynamic) ───────────────────────
        "waitingForImage": {
            "en": "Waiting for Image",
            "fr": "En attente d'une image"
        },
        "uploadToStart": {
            "en": "Upload an image to start",
            "fr": "Téléchargez une image pour commencer"
        },
        "analyzing": {
            "en": "Analyzing",
            "fr": "Analyse en cours"
        },
        "pleaseWait": {
            "en": "Please wait...",
            "fr": "Veuillez patienter..."
        },
        "analysisComplete": {
            "en": "Analysis complete",
            "fr": "Analyse terminée"
        },
        "abnormalDetected": {
            "en": "Abnormal Detected",
            "fr": "Anomalie Détectée"
        },
        "normalDetected": {
            "en": "Normal",
            "fr": "Normal"
        },

        // ─── Diagnosis ──────────────────────────────
        "diagnosis": {
            "en": "Diagnosis:",
            "fr": "Diagnostic :"
        },
        "pending": {
            "en": "Pending...",
            "fr": "En attente..."
        },
        "tumorDetected": {
            "en": "Tumor detected in the uploaded MRI scan",
            "fr": "Tumeur détectée dans le scan IRM téléchargé"
        },
        "noTumorDetected": {
            "en": "No tumor detected in the uploaded MRI scan",
            "fr": "Aucune tumeur détectée dans le scan IRM téléchargé"
        },
        "uploadImage2": {
            "en": "Upload an MRI image to begin",
            "fr": "Téléchargez une image IRM pour commencer"
        },

        // ─── Confidence ─────────────────────────────
        "confidence": {
            "en": "Confidence",
            "fr": "Confiance"
        },

        // ─── Overlay Descriptions ───────────────────
        "tumorDescription": {
            "en": "The model detected abnormal tissue patterns consistent with a brain tumor. Please consult a specialist.",
            "fr": "Le modèle a détecté des motifs tissulaires anormaux cohérents avec une tumeur cérébrale. Veuillez consulter un spécialiste."
        },
        "noTumorDescription": {
            "en": "No abnormal tissue patterns detected. This does not rule out other conditions.",
            "fr": "Aucun motif tissulaire anormal détecté. Cela n'exclut pas d'autres conditions."
        },

        // ─── Warning ────────────────────────────────
        "warningNote": {
            "en": "Note: This tool provides diagnostic assistance and does not replace a medical professional.",
            "fr": "Note : Cet outil fournit une assistance diagnostique et ne remplace pas un professionnel de la santé."
        },

        // ─── Placeholder ────────────────────────────
        "noImageLoaded": {
            "en": "No Image Loaded\n\nClick 'Upload Image' to begin analysis",
            "fr": "Aucune Image Chargée\n\nCliquez sur 'Télécharger l'image' pour commencer"
        },
        "uploadFolder": {
            "en": "Upload DICOM Folder",
            "fr": "Télécharger Dossier DICOM"
        },
        "volumeInfo": {
            "en": "3D Volume",
            "fr": "Volume 3D"
        },
        "view3D": {
            "en": "View in 3D",
            "fr": "Voir en 3D"
        }


    })

    function tr(key) {
        if (translations[key] && translations[key][currentLanguage]) {
            return translations[key][currentLanguage]
        }
        return key
    }
}
