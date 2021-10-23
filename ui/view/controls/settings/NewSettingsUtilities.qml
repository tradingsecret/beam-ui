import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import "../../utils.js" as Utils
import ".."

ColumnLayout {
    property var viewModel
    property bool showAddress: false
    Layout.fillWidth: true
    Layout.fillHeight: false
    spacing: 0

    ConfirmRefreshDialog {
        id: confirmRefreshDialog
        parent: main
        settingsViewModel: viewModel
    }

    PublicOfflineAddressDialog {
        id: publicOfflineAddressDialog;
    }

    UtxoDialog {
        id: utxoDialog
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredWidth: parent.width


        RowLayout {
            Layout.alignment: Qt.AlignCenter

            SFText {
                //rightPadding: 100
                text: "Import wallet"
                color: '#5fe795'
                rightPadding: 75
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
                font.underline: true
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                         viewModel.importData()
                    }
                }
            }

            SFText {
                text: "Export wallet"
                color: '#5fe795'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
                font.underline: true
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        viewModel.exportData()
                    }
                }
            }
        }
    }

    ColumnLayout {
        Layout.topMargin:38
        //Layout.bottomMargin: 38
        Layout.fillWidth: true
        //Layout.fillHeight: true
        width: 732
        height: 380
        Layout.preferredHeight: 380
        Layout.maximumHeight: 380

        Rectangle {
            id: itemRect
            anchors.fill: parent
            //border.width: 1
            //border.color: 'purple'
            color: 'transparent'

            Image {
                anchors.fill: parent
                fillMode: Image.Stretch

                source: {
                     "qrc:/assets/settings/secret-bg-1.png"
                }
            }
        }

        ColumnLayout {
            visible: true
            anchors.top: itemRect.top
            height: parent.height
            Layout.preferredHeight: parent.height
            Layout.preferredWidth: parent.width

            RowLayout {
                anchors.verticalCenter: parent.verticalCenter
                //Layout.fillWidth: true
               // Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignCenter

                ColumnLayout {
                    Layout.fillWidth:       true
                    Layout.maximumWidth:    650

                    SFText {
                        visible: !showAddress
                        horizontalAlignment: Text.horizontalCenter
                        Layout.alignment: Qt.AlignCenter
                        text: "Show me offline address (public)"
                        //Layout.alignment: Qt.AlignCenter
                        color: '#5f5f5f'
                        font.pixelSize: 18
                        font.capitalization: Font.AllUppercase
                        font.underline: true
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                showAddress = true
                            }
                        }
                    }

                    SFText {
                        visible: showAddress
                        horizontalAlignment: Text.horizontalCenter
                        //anchors.top: parent.top
                        //visible: false
                        text: viewModel.publicAddress
                        //Layout.fillWidth: true
                        //Layout.preferredWidth: parent.width
                        //Layout.alignment: Qt.AlignCenter
                        //horizontalAlignment: Text.AlignHCenter
                        //padding: 50
                        color: '#bb69dd'
                        font.pixelSize: 18
                        topPadding: 30
                        wrapMode:               Text.Wrap
                        Layout.maximumWidth: 650
                    }

                    RowLayout {
                        visible: showAddress
                        Layout.topMargin:       85
                        Layout.alignment:       Qt.AlignCenter | Qt.AlignHCenter

                        CustomButton {
                            id: copyButton
                            customColor:            copyButton.hovered ? '#5fe795' : '#696969'
                            Layout.alignment:       Qt.AlignCenter | Qt.AlignHCenter
                            Layout.rightMargin:     30
                            text:                   "Copy and go back"
                            font.capitalization:    Font.AllUppercase
                            Layout.preferredHeight: 42
                            palette.button:         Style.accent_incoming
                            enabled:                control.isValid()

                            onClicked: function () {
                                BeamGlobals.copyToClipboard(viewModel.publicAddress);
                                showAddress = false
                            }

                            background: Rectangle {
                                id: rect1
                                color:      "transparent"

                                Image {
                                    anchors.fill: parent
                                    fillMode: Image.Stretch
                                    source: {
                                         copyButton.hovered ? "qrc:/assets/settings/buttons-frame-hover.png" :  "qrc:/assets/settings/buttons-frame-default.png"
                                    }
                                }
                            }
                        }

                        CustomButton {
                            id: closeButton
                            customColor:            closeButton.hovered ? '#5fe795' : '#696969'
                            Layout.alignment:       Qt.AlignCenter | Qt.AlignHCenter
                            text:                   "Hide all info"
                            font.capitalization:    Font.AllUppercase
                            Layout.preferredHeight: 42
                            palette.button:         Style.accent_incoming
                            enabled:                control.isValid()

                            onClicked: function () {
                                showAddress = false
                            }

                            background: Rectangle {
                                id: rect
                                color:      "transparent"

                                Image {
                                    anchors.fill: parent
                                    fillMode: Image.Stretch
                                    source: {
                                         closeButton.hovered ? "qrc:/assets/settings/buttons-frame-hover.png" :  "qrc:/assets/settings/buttons-frame-default.png"
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: true
                        anchors.fill: parent
                        //border.width: 1
                        //border.color: 'yellow'
                        color: 'transparent'
                    }
                }

                /*Rectangle {
                    visible: true
                    anchors.fill: parent
                    border.width: 3
                    border.color: 'pink'
                    color: 'transparent'
                }*/
            }

            Rectangle {
                visible: true
                anchors.fill: parent
                //border.width: 1
                //border.color: 'purple'
                color: 'transparent'
            }
        }

        /*Rectangle {
            visible: true
            anchors.fill: parent
            border.width: 6
            border.color: '#979797'
            color: 'transparent'
        }*/
    }
}
