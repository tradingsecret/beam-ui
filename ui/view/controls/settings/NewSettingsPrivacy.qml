import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import ".."
import "../../utils.js" as Utils

ColumnLayout {
    spacing: 30
    id: privacyBlock
    property var viewModel

    ConfirmPasswordDialog {
        id: confirmPasswordDialog
        settingsViewModel: viewModel
    }

    ChangePasswordDialog {
        id: changePasswordDialog
        settingsViewModel: viewModel
        parent: main
    }

    OwnerKeyDialog {
        id: showOwnerKeyDialog
        settingsViewModel: viewModel
        parent: main
    }

    RowLayout {
        ColumnLayout {
            SFText {
                Layout.fillWidth: true
                text: "Wallet password"
                color: '#5fe795'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
                font.underline: true
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        changePasswordDialog.open();
                    }
                }
            }
        }

        ColumnLayout {
            Layout.leftMargin: 110
            SFText {
                Layout.fillWidth: true
                text: "Show wallet private key"
                color: '#5fe795'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
                font.underline: true
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        //: settings tab, general section, Show owner key button and dialog title
                        //% "Show owner key"
                        confirmPasswordDialog.dialogTitle = qsTrId("settings-general-require-pwd-to-show-owner-key")
                        //: settings tab, general section, ask password to Show owner key, message
                        //% "Password verification is required to see the owner key"
                        confirmPasswordDialog.dialogMessage = qsTrId("settings-general-require-pwd-to-show-owner-key-message")
                        //: settings tab, general section, Show owner key button and dialog title
                        //% "Show owner key"
                        confirmPasswordDialog.okButtonText = qsTrId("settings-general-require-pwd-to-show-owner-key")
                        confirmPasswordDialog.okButtonIcon = "qrc:/assets/icon-show-key.svg"
                        confirmPasswordDialog.onDialogAccepted = function () {
                            showOwnerKeyDialog.pwd = confirmPasswordDialog.pwd
                            showOwnerKeyDialog.open()
                        }
                        confirmPasswordDialog.onDialogRejected = function() {}
                        confirmPasswordDialog.open();
                    }
                }
            }
        }
    }

    ColumnLayout {
        Layout.topMargin: 40

        SFText {
            Layout.fillWidth: true
            text: "ANONYMOUS MAX. TRANSACTION TIME (24H, 36H, 48H, 60H, 72H)"
            color: '#fff'
            font.pixelSize: 18
            font.capitalization: Font.AllUppercase
        }

        CustomComboBox {
            id: mpLockTimeLimit
            fontPixelSize: 14
            Layout.preferredWidth: 100
            currentIndex: viewModel.maxPrivacyLockTimeLimit
            model: [
                //% "No limit"
                qsTrId("settings-privacy-mp-time-no-limit"),
                //% "72h"
                qsTrId("settings-privacy-mp-time-limit-72"),
                //% "60h"
                qsTrId("settings-privacy-mp-time-limit-60"),
                //% "48h"
                qsTrId("settings-privacy-mp-time-limit-48"),
                //% "36h"
                qsTrId("settings-privacy-mp-time-limit-36"),
                //% "24h"
                qsTrId("settings-privacy-mp-time-limit-24"),
            ]
            onActivated: {
                viewModel.maxPrivacyLockTimeLimit = mpLockTimeLimit.currentIndex
            }
        }
    }

    ColumnLayout {
        Layout.topMargin: 40

        SFText {
            Layout.fillWidth: true
            text: "ENTER PASSWORD TO SEND TRANSACTION "
            color: '#fff'
            font.pixelSize: 18
            font.capitalization: Font.AllUppercase
        }


        CustomSwitch {
            id: isPasswordReqiredToSpendMoney
            //: settings tab, general section, ask password to send label
            //% "Ask password on every Send"
            text: qsTrId("settings-general-require-pwd-to-spend")
            checked: viewModel.isPasswordReqiredToSpendMoney
            Layout.fillWidth: true
            font.styleName:   "Regular"
            font.weight:      Font.Normal
            function onDialogAccepted() {
                viewModel.isPasswordReqiredToSpendMoney = checked;
            }

            function onDialogRejected() {
                checked = !checked;
            }

            onClicked: {
                confirmPasswordDialog.dialogTitle = viewModel.isPasswordReqiredToSpendMoney
                    //: settings tab, general section, ask password to send, confirm password dialog, title if checked
                    //% "Don't ask password on every Send"
                    ? qsTrId("settings-general-require-pwd-to-spend-confirm-pwd-title")
                    //: settings tab, general section, ask password to send, confirm password dialog, title if unchecked
                    //% "Ask password on every Send"
                    : qsTrId("settings-general-no-require-pwd-to-spend-confirm-pwd-title")
                //: settings tab, general section, ask password to send, confirm password dialog, message
                //% "Password verification is required to change that setting"
                confirmPasswordDialog.dialogMessage = qsTrId("settings-general-require-pwd-to-spend-confirm-pwd-message")
                confirmPasswordDialog.okButtonIcon = "qrc:/assets/icon-done.svg"
                //% "Proceed"
                confirmPasswordDialog.okButtonText = qsTrId("general-proceed")
                confirmPasswordDialog.onDialogAccepted = onDialogAccepted
                confirmPasswordDialog.onDialogRejected = onDialogRejected
                confirmPasswordDialog.open()
            }
        }

    }



/*
    RowLayout {
        Layout.fillWidth:       true
        ColumnLayout {
            SFText {
                Layout.fillWidth: true
                //% "Max privacy longest transaction time"
                text: qsTrId("settings-privacy-mp-time-limit")
                wrapMode:   Text.WordWrap
                color: Style.content_main
                font.pixelSize: 14
            }
        }

        ColumnLayout {
            CustomComboBox {
                id: mpLockTimeLimit
                fontPixelSize: 14
                Layout.preferredWidth: 100
                currentIndex: viewModel.maxPrivacyLockTimeLimit
                model: [
                    //% "No limit"
                    qsTrId("settings-privacy-mp-time-no-limit"),
                    //% "72h"
                    qsTrId("settings-privacy-mp-time-limit-72"),
                    //% "60h"
                    qsTrId("settings-privacy-mp-time-limit-60"),
                    //% "48h"
                    qsTrId("settings-privacy-mp-time-limit-48"),
                    //% "36h"
                    qsTrId("settings-privacy-mp-time-limit-36"),
                    //% "24h"
                    qsTrId("settings-privacy-mp-time-limit-24"),
                ]
                onActivated: {
                    viewModel.maxPrivacyLockTimeLimit = mpLockTimeLimit.currentIndex
                }
            }
        }
    }*/
}
