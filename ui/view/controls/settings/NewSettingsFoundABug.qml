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
    id: foundABugBlock
    property var viewModel
    Layout.fillWidth: true

    ColumnLayout {
        Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter

        RowLayout {
            Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter

            SFText {
                Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
                horizontalAlignment: Text.horizontalCenter
                text: "IF YOU FOUND BUGS OR FACED ANY OTHER PROBLEMS WITH THE TESTNET WALLET"
                color: '#fff'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
            Layout.topMargin: 10
            SFText {
                text: "PLEASE CONTACT US: "
                color: '#fff'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
            }

            SFTextInput {
                text: "SUPPORT@IMPERIUMPROTOCOL.COM"
                color: '#5e5cb3'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
                disableBorder: true
                readOnly: true
                selectByMouse: true

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    enabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Utils.openUrl("mailto:support@imperiumprotocol.com");
                    }
                    hoverEnabled: true
                }
            }

            Image {
                Layout.alignment: Qt.AlignRight
                //Layout.topMargin: 5

                source: "qrc:/assets/copy-icon.png"
                sourceSize: Qt.size(25, 25)
                //opacity: control.isValid() ? 1.0 : 0.45

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: function () {
                        BeamGlobals.copyToClipboard("support@imperiumprotocol.com");
                    }
                }
            }
        }
    }
}

