import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtQuick.Shapes 1.0
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import '../'

ColumnLayout {
    id: generalBlock
    property var viewModel
    property bool languagePanelVisible: false
    property bool autoLockPanelVisible: false
    property var confirmationsValue: viewModel.minConfirmations
    Layout.fillWidth: true
    Layout.fillHeight: false
    spacing: 0

    property var lockItems: [
        'NEVER',
        '1MIN',
        '2MIN',
        '3MIN',
        '5MIN',
        '15MIN',
        '30MIN',
        '45MIN',
        '1H',
        '2H',
        '3H',
        '6H',
    ]

    property var confirmationsItems: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    RowLayout {
        id: settings1
        Layout.fillWidth: true
        width: parent.width
        Layout.topMargin: 0

        ColumnLayout {
            Layout.preferredWidth: 100

            SFText {
                text: "Wallet Language"
                color: '#fff'
                font.pixelSize: 18
                font.capitalization: Font.AllUppercase
            }


            SFText {
               // width: 125
               // Layout.fillWidth: true
                id: languageSelect
                Layout.topMargin: 15
                bottomPadding: 5
                leftPadding: 50
                rightPadding: 50
                horizontalAlignment: Text.AlignHCenter
                text: viewModel.supportedLanguages[viewModel.currentLanguageIndex]
                color: '#5fe795'
                font.pixelSize: 18
                font.capitalization: Font.AllUppercase
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        autoLockPanelVisible = false
                        languagePanelVisible = !languagePanelVisible
                    }
                }
            }

            Shape {
                anchors.bottom: languageSelect.bottom

                ShapePath {
                    strokeColor: 'white'
                    strokeWidth: 1
                    strokeStyle: ShapePath.DashLine
                    startX: 0
                    startY: 0
                    PathLine { x: languageSelect.width; y: 0 }
                }
            }

            CustomComboBox {
                id: language
                visible: false
                Layout.preferredWidth: secondCurrencySwitch.width
                fontPixelSize: 14
                enableScroll: true

                model: viewModel.supportedLanguages
                currentIndex: viewModel.currentLanguageIndex
                onActivated: {
                    viewModel.currentLanguage = currentText;
                }
            }
        }

        ColumnLayout {
            Layout.leftMargin: 140
            Layout.preferredWidth: 170
            SFText {
                text: "Auto-lock if away for..."
                color: '#fff'
                font.pixelSize: 18
                font.capitalization: Font.AllUppercase
            }


            SFText {
                id: lockSelect
                //Layout.preferredWidth: 100
                leftPadding: 50
                rightPadding: 50
                Layout.topMargin: 20
                bottomPadding: 5
                horizontalAlignment: Text.AlignHCenter
                text: lockItems[viewModel.lockTimeout]
                color: '#5fe795'
                font.pixelSize: 18
                font.capitalization: Font.AllUppercase
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        languagePanelVisible = false
                        autoLockPanelVisible = !autoLockPanelVisible
                    }
                }
            }

            Shape {
                anchors.bottom: lockSelect.bottom

                ShapePath {
                    strokeColor: 'white'
                    strokeWidth: 1
                    strokeStyle: ShapePath.DashLine
                    startX: 0
                    startY: 0
                    PathLine { x: lockSelect.width; y: 0 }
                }
            }

            CustomComboBox {
                id: lockTimeoutControl
                visible: false
                fontPixelSize: 14
                Layout.preferredWidth: secondCurrencySwitch.width
                currentIndex: viewModel.lockTimeout
                model: lockItems
                onActivated: {
                    viewModel.lockTimeout = lockTimeoutControl.currentIndex
                }
            }
        }
    }

    RowLayout {
        anchors.top: settings1.bottom
        anchors.left: settings1.left
        Layout.topMargin: 5

        Rectangle {
            anchors.fill: parent
            color: 'transparent'

            Image {
                visible: languagePanelVisible || autoLockPanelVisible
                anchors.fill: parent
                source: {
                     "qrc:/assets/settings/language-popup.png"
                }
            }
        }

        SFText {
            visible: !languagePanelVisible || !autoLockPanelVisible
            Layout.fillWidth: true
            padding: 10
            text: ""
            color: mouseAreaLangugage.containsMouse ? 'white' : '#93959a'
            font.pixelSize: 16
            font.capitalization: Font.AllUppercase
        }

        Repeater {
            model: viewModel.supportedLanguages
            //Layout.margins: 10

            SFText {
                visible: languagePanelVisible
                Layout.fillWidth: true
                padding: 10
                text: viewModel.supportedLanguages[index]
                color: mouseAreaLangugage.containsMouse ? 'white' : '#93959a'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
                MouseArea {
                    id: mouseAreaLangugage
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        //viewModel.currentLanguage = viewModel.supportedLanguages[index]
                        languagePanelVisible = !languagePanelVisible
                    }
                }
            }
        }

        Repeater {
            model: lockItems
            //Layout.margins: 10

            SFText {
                visible: autoLockPanelVisible
                Layout.fillWidth: true
                padding: 10
                text: lockItems[index]
                color: mouseAreaLockTime.containsMouse ? 'white' : '#93959a'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
                MouseArea {
                    id: mouseAreaLockTime
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        viewModel.lockTimeout = index
                        autoLockPanelVisible = !autoLockPanelVisible
                    }
                }
            }
        }
    }

    ColumnLayout {
        Layout.topMargin: 30

        SFText {
            Layout.fillWidth: true
            text: "Confirmations"
            color: '#fff'
            font.pixelSize: 16
            font.capitalization: Font.AllUppercase
        }

        RowLayout {
            spacing: 10
            Layout.topMargin: 15

            Repeater {
                model: confirmationsItems


                ColumnLayout {
                    SFText {
                       // width: 125
                       // Layout.fillWidth: true
                        id: confirmationsSelect
                        bottomPadding: 5
                        leftPadding: 10
                        rightPadding: 10
                        horizontalAlignment: Text.AlignHCenter
                        text: confirmationsItems[index]
                        color: {
                            if (mouseAreaConfirmations.containsMouse) {
                                return '#5d8af0';
                            }
                            else if (confirmationsValue != index) {
                                return '#817272'
                            }
                            else {
                                return '#5fe795';
                            }
                        }
                        font.pixelSize: 24
                        font.capitalization: Font.AllUppercase
                        MouseArea {
                            id: mouseAreaConfirmations
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                viewModel.minConfirmations = index
                                confirmationsValue = index
                            }
                        }
                    }

                    Shape {
                        anchors.bottom: confirmationsSelect.bottom

                        ShapePath {
                            strokeColor: {
                                 if (mouseAreaConfirmations.containsMouse) {
                                     return '#5d8af0';
                                 }
                                 else if (confirmationsValue != index) {
                                     return '#817272'
                                 }
                                 else {
                                     return '#fff';
                                 }
                             }
                            strokeWidth: 1
                            strokeStyle: ShapePath.DashLine
                            startX: 0
                            startY: 0
                            PathLine { x: confirmationsSelect.width; y: 0 }
                        }
                    }
                }
            }
        }

        CustomComboBox {
            visible: false
            id: minConfirmationsControl
            fontPixelSize: 14
            Layout.preferredWidth: secondCurrencySwitch.width
            currentIndex: viewModel.minConfirmations
            model: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            onActivated: {
                viewModel.minConfirmations = minConfirmationsControl.currentIndex
            }
        }
    }

    ColumnLayout {
        Layout.topMargin: 67

        SFText {
            Layout.fillWidth: true
            text: "Wallet location"
            color: '#fff'
            font.pixelSize: 18
            font.capitalization: Font.AllUppercase
        }

        ColumnLayout {
            Layout.preferredWidth: 600
            Layout.maximumWidth: 600
            spacing: 10
            Layout.preferredHeight: spacing + folderText.height + folderButton.height

            SFText {
                Layout.preferredWidth: 600
                Layout.maximumWidth: 600
                Layout.topMargin: 15
                id: folderText
                font.pixelSize: 18
                font.capitalization: Font.AllUppercase
                bottomPadding: 5
                color: '#5fe795'
                text: viewModel.walletLocation
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 1
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        viewModel.openFolder(viewModel.walletLocation);
                    }
                }
            }

            Shape {
                anchors.bottom: folderText.bottom

                ShapePath {
                    strokeColor: '#fff'
                    strokeWidth: 1
                    strokeStyle: ShapePath.DashLine
                    startX: 0
                    startY: 0
                    PathLine { x: folderText.width; y: 0 }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: 'transparent'
        border.width: 1
        border.color: 'purple'
    }
}
