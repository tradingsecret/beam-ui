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
    id: dappsBlock
    property var viewModel

    ColumnLayout {
        SFText {
            Layout.fillWidth: true
            text: "Allow to launch dapps "
            color: '#fff'
            font.pixelSize: 16
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
                        else if (viewModel.dappsAllowed) {
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
                        onClicked: {
                            viewModel.dappsAllowed = false
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
                             else if (viewModel.dappsAllowed) {
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
                        else if (!viewModel.dappsAllowed) {
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
                        onClicked: {
                            viewModel.dappsAllowed = true
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
                             else if (!viewModel.dappsAllowed) {
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

    RowLayout {
        Layout.fillWidth: true
        spacing: 20

        SFText {
            text: qsTrId("settings-dapps-port")
            color: '#fff'
            font.pixelSize: 16
            font.capitalization: Font.AllUppercase
            wrapMode: Text.NoWrap
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            spacing: 0

            SFTextInput {
                id: appsServerPort
                Layout.preferredWidth: 210
                width: 210
                topPadding: 0
                activeFocusOnTab: true
                enabled: false
                font.pixelSize: 14
                color: !appsServerPort.acceptableInput ? Style.validator_error : Style.content_main
                text:  ""
                validator: RegExpValidator {regExp: /^([1-9][0-9]{0,3}|[1-5][0-9]{2,4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$/g}
                backgroundColor: !appsServerPort.acceptableInput ? Style.validator_error : Style.content_main

                background: Rectangle {
                    id: backgroundRect
                    y: appsServerPort.height - height - appsServerPort.bottomPadding + 4
                    width: appsServerPort.width - (appsServerPort.leftPadding + appsServerPort.rightPadding)
                    height: 0

                    Shape {
                        anchors.fill: parent

                        ShapePath {
                            strokeColor: '#fff'
                            strokeWidth: 1
                            strokeStyle: ShapePath.DashLine
                            startX: 0
                            startY: 0
                            PathLine { x: backgroundRect.width; y: 0 }
                        }
                        visible: true
                    }
                }
            }

            Item {
                Layout.preferredWidth: 210
                width: 210
                Layout.alignment: Qt.AlignRight
                SFText {
                    color:          '#992727'
                    font.pixelSize: 12
                    font.italic:    true
                    text:           'NOT AVAILABLE ON TESTNET WALLET'
                    visible:        !appsServerPort.acceptableInput
                }
            }
        }
    }
}
