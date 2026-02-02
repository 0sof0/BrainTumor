import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1366
    height: 768
    color: "#1a1a2e"

    // Language Switcher (Top Right Corner)
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

                onClicked: {
                    Translator.setLanguage("en")
                }
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

                onClicked: {
                    Translator.setLanguage("fr")
                }
            }
        }
    }

    // Left Panel - Controls
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

            // Upload Button
            Button {
                id: uploadButton
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                text: Translator.tr("uploadImage")

                background: Rectangle {
                    color: uploadButton.pressed ? "#1e5a8e" : (uploadButton.hovered ? "#2980b9" : "#3498db")
                    radius: 8
                }

                contentItem: Text {
                    text: uploadButton.text
                    font.pixelSize: 16
                    font.bold: true
                    color: "#ffffff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: {
                    console.log("Upload button clicked!")
                    backend.open_image()
                }
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
                            width: parent.width * 0.33
                            height: parent.height
                            color: "#3498db"
                            radius: 4
                        }
                    }
                }
            }

            // Status Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 70
                color: "#c0392b"
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5

                    Text {
                        text: Translator.tr("abnormalDetected")
                        font.pixelSize: 16
                        font.bold: true
                        color: "#ffffff"
                    }

                    Text {
                        id: statusText
                        text: Translator.tr("noAnalysis")
                        font.pixelSize: 12
                        color: "#ecf0f1"
                    }
                }
            }

            // Diagnosis Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: "#0f1419"
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 10

                    Text {
                        text: Translator.tr("diagnosis")
                        font.pixelSize: 14
                        font.bold: true
                        color: "#ecf0f1"
                    }

                    Text {
                        id: diagnosisType
                        text: Translator.tr("tumor")
                        font.pixelSize: 13
                        color: "#e74c3c"
                        font.italic: true
                    }

                    Text {
                        id: diagnosisDetail
                        text: Translator.tr("tumorDetail")
                        font.pixelSize: 11
                        color: "#95a5a6"
                    }
                }
            }

            // Confidence Section
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#0f1419"
                radius: 8

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5

                    Text {
                        text: Translator.tr("confidence")
                        font.pixelSize: 13
                        font.bold: true
                        color: "#2ecc71"
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 10
                        color: "#2c3e50"
                        radius: 5

                        Rectangle {
                            width: parent.width * 0.936
                            height: parent.height
                            color: "#2ecc71"
                            radius: 5
                        }
                    }
                }
            }

            // Spacer
            Item {
                Layout.fillHeight: true
            }

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
        anchors.leftMargin: 6
        anchors.rightMargin: -6
        anchors.topMargin: 0
        anchors.bottomMargin: 0
        color: "#0f1419"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20

            // Title
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Translator.tr("mainTitle")
                font.pixelSize: 32
                font.bold: true
                color: "#ecf0f1"
            }

            // Main Image Display Area
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#000000"
                radius: 10
                border.color: "#3498db"
                border.width: 2

                Image {
                    id: mriImage
                    anchors.fill: parent
                    anchors.margins: 10
                    fillMode: Image.PreserveAspectFit
                    source: ""
                }

                // Placeholder when no image
                Text {
                    id: placeholderText
                    anchors.centerIn: parent
                    text: Translator.tr("noImageLoaded")
                    font.pixelSize: 20
                    color: "#7f8c8d"
                    horizontalAlignment: Text.AlignHCenter
                    visible: mriImage.source == ""
                }

                // Analysis info overlay
                Rectangle {
                    id: infoOverlay
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 20
                    width: 280
                    height: infoColumn.height + 20
                    color: "#cc16213e"
                    radius: 8
                    border.color: "#e74c3c"
                    border.width: 1
                    visible: mriImage.source != ""

                    ColumnLayout {
                        id: infoColumn
                        anchors.centerIn: parent
                        width: parent.width - 20
                        spacing: 10

                        Text {
                            Layout.fillWidth: true
                            text: Translator.tr("abnormalDetected")
                            font.pixelSize: 16
                            font.bold: true
                            color: "#e74c3c"
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: "#7f8c8d"
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Translator.tr("tumor")
                            font.pixelSize: 14
                            color: "#ecf0f1"
                            font.bold: true
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Translator.tr("tumorDetail")
                            font.pixelSize: 12
                            color: "#95a5a6"
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Translator.tr("highlightedArea")
                            font.pixelSize: 11
                            color: "#bdc3c7"
                            topPadding: 5
                        }

                        Text {
                            Layout.fillWidth: true
                            text: Translator.tr("abnormalDensity")
                            font.pixelSize: 10
                            color: "#95a5a6"
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }

    // Connect to backend signals
    Connections {
        target: backend

        function onImagePathChanged(path) {
            console.log("Image path changed:", path)
            mriImage.source = path
            placeholderText.visible = false
            statusText.text = Translator.tr("analysisComplete")
        }

        function onTextChanged(text) {
            console.log("Text changed:", text)
            // Use translated message
            statusText.text = Translator.tr("imageLoaded")
        }
    }

    // Update all text when language changes
    Connections {
        target: Translator

        function onLanguageChanged() {
            console.log("Language changed to:", Translator.currentLanguage)
            // Force update of status text if we have an image loaded
            if (mriImage.source != "") {
                statusText.text = Translator.tr("analysisComplete")
            }
        }
    }
}
