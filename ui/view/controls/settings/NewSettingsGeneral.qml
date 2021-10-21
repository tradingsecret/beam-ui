import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import '../'

ColumnLayout {
    spacing: 30
    id: generalBlock
    property var viewModel

    RowLayout {
        ColumnLayout {
            SFText {
                Layout.fillWidth: true
                text: "Wallet Language"
                color: '#fff'
                font.pixelSize: 18
                font.capitalization: Font.AllUppercase
            }

            CustomComboBox {
                id: language
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
            Layout.leftMargin: 110
            SFText {
                Layout.fillWidth: true
                text: "Auto-lock if away for..."
                color: '#fff'
                font.pixelSize: 18
                font.capitalization: Font.AllUppercase
            }

            CustomComboBox {
                id: lockTimeoutControl
                fontPixelSize: 14
                Layout.preferredWidth: secondCurrencySwitch.width
                currentIndex: viewModel.lockTimeout
                model: [
                    //% "Never"
                    qsTrId("settings-general-lock-screen-never"),
                    //% "1 minute"
                    qsTrId("settings-general-lock-screen-1m"),
                    //% "5 minutes"
                    qsTrId("settings-general-lock-screen-5m"),
                    //% "15 minutes"
                    qsTrId("settings-general-lock-screen-15m"),
                    //% "30 minutes"
                    qsTrId("settings-general-lock-screen-30m"),
                    //% "1 hour"
                    qsTrId("settings-general-lock-screen-1h"),
                ]
                onActivated: {
                    viewModel.lockTimeout = lockTimeoutControl.currentIndex
                }
            }
        }
    }

    /*RowLayout {
        Layout.preferredHeight: 16
        ColumnLayout {
            SFText {
                Layout.fillWidth: true
                //: settings tab, general section, language label
                //% "Language"
                text: qsTrId("settings-general-language")
                color: Style.content_secondary
                font.pixelSize: 14
            }
        }

        Item {
        }

        ColumnLayout {
            CustomComboBox {
                id: language
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
        //visible: false  // Remove to enable language dropdown
    }

    RowLayout {
        SFText {
            Layout.fillWidth: true
            //: settings tab, general section, lock screen label
            //% "Lock screen"
            text: qsTrId("settings-general-lock-screen")
            color: Style.content_secondary
            font.pixelSize: 14
        }
        Item {}
        CustomComboBox {
            id: lockTimeoutControl
            fontPixelSize: 14
            Layout.preferredWidth: secondCurrencySwitch.width
            currentIndex: viewModel.lockTimeout
            model: [
                //% "Never"
                qsTrId("settings-general-lock-screen-never"),
                //% "1 minute"
                qsTrId("settings-general-lock-screen-1m"),
                //% "5 minutes"
                qsTrId("settings-general-lock-screen-5m"),
                //% "15 minutes"
                qsTrId("settings-general-lock-screen-15m"),
                //% "30 minutes"
                qsTrId("settings-general-lock-screen-30m"),
                //% "1 hour"
                qsTrId("settings-general-lock-screen-1h"),
            ]
            onActivated: {
                viewModel.lockTimeout = lockTimeoutControl.currentIndex
            }
        }
    }*/

    ColumnLayout {
        Layout.topMargin: 67

        SFText {
            Layout.fillWidth: true
            text: "Confirmations"
            color: '#fff'
            font.pixelSize: 18
            font.capitalization: Font.AllUppercase
        }

        CustomComboBox {
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
            spacing: 10
            Layout.preferredHeight: spacing + folderText.height + folderButton.height

            SFText {
                id: folderText
                Layout.fillWidth: true
                font.pixelSize: 14
                color: Style.content_main
                text: viewModel.walletLocation
                wrapMode: Text.Wrap
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        viewModel.openFolder(viewModel.walletLocation);
                    }
                }
            }
        }
    }

    /*RowLayout {
        SFText {
            Layout.fillWidth: true
            //: settings tab, general section, minimum confirmations
            //% "Minimum confirmations"
            text: qsTrId("settings-general-confirmations")
            color: Style.content_secondary
            font.pixelSize: 14
        }
        Item {}
        CustomComboBox {
            id: minConfirmationsControl
            fontPixelSize: 14
            Layout.preferredWidth: secondCurrencySwitch.width
            currentIndex: viewModel.minConfirmations
            model: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            onActivated: {
                viewModel.minConfirmations = minConfirmationsControl.currentIndex
            }
        }
    }*/

    /*RowLayout {
        SFText {
            Layout.fillWidth: true
            //: settings tab, general section, amounts unit label
            //% "Show amounts in"
            text: qsTrId("settings-general-amounts-unit")
            color: Style.content_secondary
            font.pixelSize: 14
        }
        Item {}
        CustomSecondCurrencySwitch {
            id: secondCurrencySwitch
            width: 210 // generalBlock.width * 0.33
            height: 20
            state: viewModel.secondCurrency
            onStateChanged: {
                viewModel.secondCurrency = secondCurrencySwitch.state;
            }
        }
    }*/

    /*
    LinkButton {
        //% "Remove current wallet"
        text: qsTrId("settings-remove-wallet")
        linkColor: "#ff625c"
        bold: true
        onClicked: {
            // TODO:SETTINGS
        }
    }
    */
}
