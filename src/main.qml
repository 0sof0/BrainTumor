import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1366
    height: 768
    color: "#1a1a2e"


    
    property bool hasImage: false
    property string resultLabel: ""
    property real resultConfidence: 0.0
    property bool isAnalyzing: false
    property bool isTumor: false
    property bool volumeLoaded: false
    property int numSlices: 0
    property int currentSlice: 0

    // Language Switcher (Top Right)
    Rectangle {
        id: languageSwitcher
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 15
        width: 120
        height: 40
        color: "#16213e"
        radius: 8
        border.color: "#3498db"
        border.width: 1
        z: 100

        RowLayout {
            anchors.fill: parent
            anchors.margins: 5
            spacing: 5

            Button {
                id: englishBtn
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "EN"
                background: Rectangle {
                    color: Translator.currentLanguage === "en" ? "#3498db" : "transparent"
                    radius: 6
                }
                contentItem: Text {
                    text: englishBtn.text
                    font.pixelSize: 14
                    font.bold: Translator.currentLanguage === "en"
                    color: Translator.currentLanguage === "en" ? "#ffffff" : "#95a5a6"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: Translator.setLanguage("en")
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: "#7f8c8d"
            }

            Button {
                id: frenchBtn
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "FR"
                background: Rectangle {
                    color: Translator.currentLanguage === "fr" ? "#3498db" : "transparent"
                    radius: 6
                }
                contentItem: Text {
                    text: frenchBtn.text
                    font.pixelSize: 14
                    font.bold: Translator.currentLanguage === "fr"
                    color: Translator.currentLanguage === "fr" ? "#ffffff" : "#95a5a6"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: Translator.setLanguage("fr")
            }
        }
    }

    // Left Panel
    Rectangle {
        id: leftPanel
        width: 280
        height: parent.height
        color: "#16213e"
        anchors.left: parent.left

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Upload Single Image Button
            Button {
                id: uploadButton
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: Translator.tr("uploadImage")
                enabled: !root.isAnalyzing

                background: Rectangle {
                    color: !uploadButton.enabled ? "#1a3a5c" :
                           uploadButton.pressed ? "#1e5a8e" :
                           uploadButton.hovered ? "#2980b9" : "#3498db"
                    radius: 8
                }

                contentItem: Text {
                    text: uploadButton.text
                    font.pixelSize: 16
                    font.bold: true
                    color: uploadButton.enabled ? "#ffffff" : "#7f8c8d"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: backend.open_image()
            }

            // NEW: Upload DICOM Folder Button
            Button {
                id: uploadFolderButton
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: Translator.tr("uploadFolder")
                enabled: !root.isAnalyzing

                background: Rectangle {
                    color: !uploadFolderButton.enabled ? "#1a3a5c" :
                           uploadFolderButton.pressed ? "#1e5a8e" :
                           uploadFolderButton.hovered ? "#27ae60" : "#2ecc71"
                    radius: 8
                }

                contentItem: Text {
                    text: "📁 " + uploadFolderButton.text
                    font.pixelSize: 15
                    font.bold: true
                    color: uploadFolderButton.enabled ? "#ffffff" : "#7f8c8d"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: backend.open_dicom_folder()
            }

            // Stage Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#0f1419"
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 8

                    Text {
                        text: Translator.tr("stage")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#ecf0f1"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 8
                        color: "#2c3e50"
                        radius: 4

                        Rectangle {
                            width: root.hasImage ? parent.width : parent.width * 0.33
                            height: parent.height
                            color: root.hasImage ? "#2ecc71" : "#3498db"
                            radius: 4
                            Behavior on width {
                                NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                }
            }

            // Volume Info (shows when folder loaded)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                color: "#0f1419"
                radius: 8
                visible: root.volumeLoaded

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 8

                    Text {
                        text: Translator.tr("volumeInfo")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#ecf0f1"
                    }

                    Text {
                        text: root.numSlices + " slices loaded"
                        font.pixelSize: 12
                        color: "#2ecc71"
                    }

                    // Slice slider
                    Slider {
                        id: sliceSlider
                        Layout.fillWidth: true
                        from: 0
                        to: root.numSlices - 1
                        stepSize: 1
                        value: root.currentSlice

                        onValueChanged: {
                            if (value !== root.currentSlice) {
                                root.currentSlice = value
                                backend.select_slice(value)
                            }
                        }
                    }

                    Text {
                        text: "Slice: " + (root.currentSlice + 1) + " / " + root.numSlices
                        font.pixelSize: 11
                        color: "#95a5a6"
                    }
                }
            }

            // Status Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: root.hasImage ? (root.isTumor ? "#c0392b" : "#27ae60") : "#34495e"
                radius: 8
                Behavior on color { ColorAnimation { duration: 400 } }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5

                    Text {
                        id: statusTitle
                        text: root.isAnalyzing ? Translator.tr("analyzing") :
                              root.hasImage ? (root.isTumor ? Translator.tr("abnormalDetected") : Translator.tr("normalDetected")) :
                              Translator.tr("waitingForImage")
                        font.pixelSize: 16
                        font.bold: true
                        color: "#ffffff"
                    }

                    Text {
                        id: statusText
                        text: root.isAnalyzing ? Translator.tr("pleaseWait") :
                              root.hasImage ? Translator.tr("analysisComplete") :
                              Translator.tr("uploadToStart")
                        font.pixelSize: 12
                        color: "#ecf0f1"
                    }
                }
            }

            // Diagnosis Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                color: "#0f1419"
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 8

                    Text {
                        text: Translator.tr("diagnosis")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#ecf0f1"
                    }

                    Text {
                        id: diagnosisType
                        text: root.hasImage ? root.resultLabel : Translator.tr("pending")
                        font.pixelSize: 18
                        font.bold: true
                        color: root.hasImage ? (root.isTumor ? "#e74c3c" : "#2ecc71") : "#7f8c8d"
                    }

                    Text {
                        id: diagnosisDetail
                        text: root.hasImage ?
                              (root.isTumor ? Translator.tr("tumorDetected") : Translator.tr("noTumorDetected")) :
                              Translator.tr("uploadImage2")
                        font.pixelSize: 11
                        color: "#95a5a6"
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // Confidence Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 75
                color: "#0f1419"
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 6

                    Text {
                        text: Translator.tr("confidence") + ": " +
                              (root.hasImage ? (root.resultConfidence * 100).toFixed(1) + "%" : "—")
                        font.pixelSize: 13
                        font.bold: true
                        color: root.hasImage ?
                               (root.resultConfidence >= 0.9 ? "#2ecc71" :
                                root.resultConfidence >= 0.7 ? "#f39c12" : "#e74c3c") :
                               "#7f8c8d"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 10
                        color: "#2c3e50"
                        radius: 5

                        Rectangle {
                            id: confidenceBar
                            width: root.hasImage ? parent.width * root.resultConfidence : 0
                            height: parent.height
                            color: root.resultConfidence >= 0.9 ? "#2ecc71" :
                                   root.resultConfidence >= 0.7 ? "#f39c12" : "#e74c3c"
                            radius: 5
                            Behavior on width {
                                NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                            }
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Warning Note
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "#34495e"
                radius: 8

                Text {
                    anchors.fill: parent
                    anchors.margins: 12
                    text: Translator.tr("warningNote")
                    font.pixelSize: 11
                    color: "#bdc3c7"
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            // Close Button
            Button {
                id: closeButton
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                text: Translator.tr("close")

                background: Rectangle {
                    color: closeButton.pressed ? "#7f8c8d" : (closeButton.hovered ? "#95a5a6" : "#bdc3c7")
                    radius: 8
                }

                contentItem: Text {
                    text: closeButton.text
                    font.pixelSize: 14
                    font.bold: true
                    color: "#2c3e50"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: Qt.quit()
            }
        }
    }

    // Right Panel - Main Content
    Rectangle {
        id: rightPanel
        anchors.left: leftPanel.right
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#0f1419"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Translator.tr("mainTitle")
                font.pixelSize: 32
                font.bold: true
                color: "#ecf0f1"
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#000000"
                radius: 10
                border.color: root.hasImage ? (root.isTumor ? "#e74c3c" : "#2ecc71") : "#3498db"
                border.width: 2
                Behavior on border.color { ColorAnimation { duration: 400 } }

                Image {
                    id: mriImage
                    anchors.fill: parent
                    anchors.margins: 10
                    fillMode: Image.PreserveAspectFit
                    source: ""
                }

                Text {
                    id: placeholderText
                    anchors.centerIn: parent
                    text: Translator.tr("noImageLoaded")
                    font.pixelSize: 20
                    color: "#7f8c8d"
                    horizontalAlignment: Text.AlignHCenter
                    visible: !root.hasImage
                }

                Text {
                    anchors.centerIn: parent
                    text: Translator.tr("analyzing") + "..."
                    font.pixelSize: 22
                    font.bold: true
                    color: "#3498db"
                    visible: root.isAnalyzing

                    SequentialAnimation on opacity {
                        running: root.isAnalyzing
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 600 }
                        NumberAnimation { to: 1.0; duration: 600 }
                    }
                }

                // Result Overlay
                Rectangle {
                    id: resultOverlay
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    width: 260
                    height: overlayColumn.height + 30
                    color: "#dd16213e"
                    radius: 10
                    border.color: root.isTumor ? "#e74c3c" : "#2ecc71"
                    border.width: 2
                    visible: root.hasImage && !root.isAnalyzing

                    ColumnLayout {
                        id: overlayColumn
                        anchors.centerIn: parent
                        width: parent.width - 30
                        spacing: 10

                        Text {
                            Layout.fillWidth: true
                            text: root.isTumor ? Translator.tr("abnormalDetected") : Translator.tr("normalDetected")
                            font.pixelSize: 18
                            font.bold: true
                            color: root.isTumor ? "#e74c3c" : "#2ecc71"
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Rectangle { Layout.fillWidth: true; height: 1; color: "#7f8c8d" }

                        Text {
                            Layout.fillWidth: true
                            text: Translator.tr("diagnosis")
                            font.pixelSize: 12
                            color: "#95a5a6"
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.resultLabel
                            font.pixelSize: 16
                            font.bold: true
                            color: root.isTumor ? "#e74c3c" : "#2ecc71"
                        }

                        Rectangle { Layout.fillWidth: true; height: 1; color: "#7f8c8d" }

                        Text {
                            Layout.fillWidth: true
                            text: Translator.tr("confidence") + ": " + (root.resultConfidence * 100).toFixed(1) + "%"
                            font.pixelSize: 14
                            font.bold: true
                            color: root.resultConfidence >= 0.9 ? "#2ecc71" :
                                   root.resultConfidence >= 0.7 ? "#f39c12" : "#e74c3c"
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            color: "#2c3e50"
                            radius: 3

                            Rectangle {
                                width: parent.width * root.resultConfidence
                                height: parent.height
                                color: root.resultConfidence >= 0.9 ? "#2ecc71" :
                                       root.resultConfidence >= 0.7 ? "#f39c12" : "#e74c3c"
                                radius: 3
                                Behavior on width {
                                    NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.isTumor ? Translator.tr("tumorDescription") : Translator.tr("noTumorDescription")
                            font.pixelSize: 11
                            color: "#bdc3c7"
                            wrapMode: Text.WordWrap
                            topPadding: 5
                        }
                    }
                }
            }
        }
    }

    // Backend Connections
    Connections {
        target: backend

        function onImagePathChanged(path) {
            mriImage.source = path
            root.hasImage = true
            root.isAnalyzing = true
            root.resultLabel = ""
            root.resultConfidence = 0.0
        }

        function onPredictionResult(label, confidence) {
            root.isAnalyzing = false
            root.resultLabel = label
            root.resultConfidence = confidence
            root.isTumor = (label === "Tumor")
        }

        function onPredictionError(error) {
            root.isAnalyzing = false
            statusText.text = "Error: " + error
        }

        function onVolumeLoaded(numSlices, firstSlicePath) {
            root.volumeLoaded = true
            root.numSlices = numSlices
            root.currentSlice = 0
        }

        function onVisualization3DReady(htmlPath) {
            console.log("3D visualization ready:", htmlPath)
            // Open in default browser
            Qt.openUrlExternally("file:///" + htmlPath)
        }
    }

    Connections {
        target: Translator
        function onLanguageChanged() {
            // Auto-refresh
        }
    }
}
