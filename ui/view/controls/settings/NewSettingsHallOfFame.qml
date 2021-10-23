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
    id: hallOfFameBlock
    property var viewModel
    Layout.fillWidth: true

    ColumnLayout {
        Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter

        RowLayout {
            Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter

            SFText {
                Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
                horizontalAlignment: Text.horizontalCenter
                text: "PEOPLE`S COMMUNITY OF THE IMPERIUM PROTOCOL THANK TO:"
                color: '#fff'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
            Layout.topMargin: 60

            SFText {
                Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
                horizontalAlignment: Text.horizontalCenter
                text: "NICKNAME 1, NICKNAME 2, NICKNAME 3, NICKNAME 4, NICKNAME 5"
                color: '#abb020'
                font.pixelSize: 18
                font.capitalization: Font.AllUppercase
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter

            SFText {
                Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
                horizontalAlignment: Text.horizontalCenter
                text: "NICKNAME 6, NICKNAME 7, NICKNAME 8, NICKNAME 9, NICKNAME 10 "
                color: '#abb020'
                font.pixelSize: 18
                font.capitalization: Font.AllUppercase
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
            Layout.bottomMargin: 60

            SFText {
                Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
                horizontalAlignment: Text.horizontalCenter
                text: "NICKNAME 11, NICKNAME 12, NICKNAME 13, NICKNAME 14, NICKNAME 15"
                color: '#abb020'
                font.pixelSize: 18
                font.capitalization: Font.AllUppercase
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter

            SFText {
                Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
                horizontalAlignment: Text.horizontalCenter
                text: "MAY THE FORCE BE WITH YOU!"
                color: '#fff'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
            Layout.topMargin: 10

            SFText {
                Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
                horizontalAlignment: Text.horizontalCenter
                text: "THE CRYPTO STORM IS COMING..."
                color: '#fff'
                font.pixelSize: 16
                font.capitalization: Font.AllUppercase
            }
        }
    }
}
