import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import "."
import "../utils.js" as Utils

ConfirmationDialog {
    property string externalUrl
    property var onOkClicked: function () {}
    property var onCancelClicked: function () {}
    //% "open"
    okButtonText: qsTrId("open-external-open")
    okButtonIconSource: "qrc:/assets/icon-done.svg"
    cancelButtonVisible: true
    cancelButtonIconSource: "qrc:/assets/icon-cancel-white.svg"
    //width: 460
    leftPadding: 50
    rightPadding: 50

    backgroundImage: "qrc:/assets/popups/popup-11.png"
    width: 710
    height: 490
    footerBottomPadding: 95

    FontLoader { id: agency_b;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyB.ttf" }
    FontLoader { id: agency_r;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyR.otf" }

    //% "External link"
    //title: qsTrId("open-external-title")

    /*% "Beam Wallet app requires permission to open external link in the browser. This action will expose your IP to the web server. To avoid it, choose \"Cancel\". You can change your choice in app setting anytime."*/
    //text: qsTrId("open-external-message")

    contentItem: Item {
        ColumnLayout {
            anchors.fill: parent
            Layout.fillWidth: true
            //spacing: 10

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter

                SFText {
                    id: title
                    Layout.alignment: Qt.AlignHCenter
                    //Layout.minimumHeight: 21
                    //Layout.leftMargin: 68
                    //Layout.rightMargin: 68
                    Layout.topMargin: 70
                    font.pixelSize: 30
                    font.bold: true
                    font.letterSpacing: 4
                    font.family: agency_b.name
                    font.weight: Font.Bold
                    font.capitalization: Font.AllUppercase
                    color: Style.content_main
                    text: qsTrId("open-external-title")
                    wrapMode: Text.WrapAnywhere
                }

                SFText {
                    Layout.alignment: Qt.AlignHCenter
                    //Layout.minimumHeight: 18
                    Layout.topMargin: 40
                    //Layout.leftMargin: 60
                    //Layout.rightMargin: 60
                    //Layout.bottomMargin: 50
                    font.capitalization: Font.AllUppercase
                    font.pixelSize: 18
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.content_main
                    font.family: agency_r.name
                    text: "Imperium Protocol Wallet app requests to open"
                }

                SFText {
                    Layout.alignment: Qt.AlignHCenter
                    //Layout.minimumHeight: 18
                    //Layout.leftMargin: 60
                    //Layout.rightMargin: 60
                    //Layout.bottomMargin: 50
                    font.capitalization: Font.AllUppercase
                    font.pixelSize: 18
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.content_main
                    font.family: agency_r.name
                    text: "the external link via browser."
                }

                SFText {
                    Layout.alignment: Qt.AlignHCenter
                    //Layout.minimumHeight: 18
                    Layout.topMargin: 20
                    //Layout.leftMargin: 60
                    //Layout.rightMargin: 60
                    //Layout.bottomMargin: 50
                    font.capitalization: Font.AllUppercase
                    font.pixelSize: 18
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.content_main
                    font.family: agency_r.name
                    text: "Note: External links will expose your IP address"
                }

                SFText {
                    Layout.alignment: Qt.AlignHCenter
                    //Layout.minimumHeight: 18
                   // Layout.leftMargin: 60
                    //Layout.rightMargin: 60
                    //Layout.bottomMargin: 50
                    font.capitalization: Font.AllUppercase
                    font.pixelSize: 18
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.content_main
                    font.family: agency_r.name
                    text: "to the opening websites. If you don't want to reveal "
                }

                SFText {
                    Layout.alignment: Qt.AlignHCenter
                    //Layout.minimumHeight: 18
                    //Layout.leftMargin: 60
                    //Layout.rightMargin: 60
                    //Layout.bottomMargin: 50
                    font.capitalization: Font.AllUppercase
                    font.pixelSize: 18
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.content_main
                    font.family: agency_r.name
                    text: "your IP address press CANCEL."
                }
            }

            Rectangle {
                anchors.fill: parent
                color: 'transparent'
            }
        }
    }

    onAccepted: {
        onOkClicked();
        Utils.openUrl(externalUrl);
    }

    onRejected: {
        onCancelClicked();
    }
}
