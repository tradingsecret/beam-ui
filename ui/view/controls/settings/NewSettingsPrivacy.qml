import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtQuick.Shapes 1.0
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import ".."
import "../../utils.js" as Utils

ColumnLayout {
    spacing: 30
    id: privacyBlock
    property var viewModel
    property var lockTime: [
        //% "No limit"
        '72H',
        '48H',
        '24H',
        '16H',
        '8H',
        '4H',
        '2H',
    ]

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
            text: "ANONYMOUS MAX. TRANSACTION TIME (72H, 48H, 24H, 16H, 8H, 4H, 2H)"
            color: '#fff'
            font.pixelSize: 18
            font.capitalization: Font.AllUppercase
        }

        RowLayout {
            spacing: 10
            Layout.topMargin: 15

            Repeater {
                model: lockTime

                ColumnLayout {
                    SFText {
                       // width: 125
                       // Layout.fillWidth: true
                        id: confirmationsSelect
                        bottomPadding: 5
                        leftPadding: 10
                        rightPadding: 10
                        horizontalAlignment: Text.AlignHCenter
                        text: lockTime[index]
                        color: {
                            if (mouseAreaConfirmations.containsMouse) {
                                return '#5d8af0';
                            }
                            else if (viewModel.maxPrivacyLockTimeLimit != index) {
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
                                viewModel.maxPrivacyLockTimeLimit = index
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
                                 else if (viewModel.maxPrivacyLockTimeLimit != index) {
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

        RowLayout {
            spacing: 10
            Layout.topMargin: 15

            ColumnLayout {
                SFText {
                   // width: 125
                   // Layout.fillWidth: true
                    id: noSelect
                    bottomPadding: 5
                    leftPadding: 10
                    rightPadding: 10
                    horizontalAlignment: Text.AlignHCenter
                    text: 'NO'
                    color: {
                        if (mouseAreaNo.containsMouse) {
                            return '#5d8af0';
                        }
                        else if (viewModel.isPasswordReqiredToSpendMoney) {
                            return '#817272'
                        }
                        else {
                            return '#5fe795';
                        }
                    }
                    font.pixelSize: 24
                    font.capitalization: Font.AllUppercase
                    MouseArea {
                        id: mouseAreaNo
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        function onDialogAcceptedFalse() {
                            viewModel.isPasswordReqiredToSpendMoney = false;
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
                            confirmPasswordDialog.onDialogAccepted = onDialogAcceptedFalse
                            confirmPasswordDialog.open()
                        }
                    }
                }

                Shape {
                    anchors.bottom: noSelect.bottom

                    ShapePath {
                        strokeColor: {
                             if (mouseAreaNo.containsMouse) {
                                 return '#5d8af0';
                             }
                             else if (viewModel.isPasswordReqiredToSpendMoney) {
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
                        PathLine { x: noSelect.width; y: 0 }
                    }
                }
            }

            ColumnLayout {
                SFText {
                   // width: 125
                   // Layout.fillWidth: true
                    id: yesSelect
                    bottomPadding: 5
                    leftPadding: 10
                    rightPadding: 10
                    horizontalAlignment: Text.AlignHCenter
                    text: 'YES'
                    color: {
                        if (mouseAreaYes.containsMouse) {
                            return '#5d8af0';
                        }
                        else if (!viewModel.isPasswordReqiredToSpendMoney) {
                            return '#817272'
                        }
                        else {
                            return '#5fe795';
                        }
                    }
                    font.pixelSize: 24
                    font.capitalization: Font.AllUppercase
                    MouseArea {
                        id: mouseAreaYes
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        function onDialogAcceptedTrue() {
                            viewModel.isPasswordReqiredToSpendMoney = true;
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
                            confirmPasswordDialog.onDialogAccepted = onDialogAcceptedTrue
                            confirmPasswordDialog.open()
                        }
                    }
                }

                Shape {
                    anchors.bottom: yesSelect.bottom

                    ShapePath {
                        strokeColor: {
                             if (mouseAreaYes.containsMouse) {
                                 return '#5d8af0';
                             }
                             else if (!viewModel.isPasswordReqiredToSpendMoney) {
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
                        PathLine { x: yesSelect.width; y: 0 }
                    }
                }
            }
        }
    }
}
