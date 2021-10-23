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

            SFText {
                text: "SUPPORT@IMPERIUMPROTOCOL.COM"
                color: '#5e5cb3'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
            }
        }
    }
}
