import QtQuick 2.12
import QtQuick.Controls 2.4
import Beam.Wallet 1.0
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import "../utils.js" as Utils
import "."

Rectangle
{
    id: root

    readonly property bool isSqueezedHeight : Utils.isSqueezedHeight(root.height)

    color: Style.background_main
    default property alias content: contentLayout.children
    property bool showNetworkLabel

    Image {
        id: backgroundImage
        fillMode: Image.PreserveAspectCrop
        anchors.fill: parent

        source: {
             "qrc:/assets/bg-1.png"
        }
    }

    BgLogo {}

    ColumnLayout {
        id: rootColumn
        anchors.fill: parent
        spacing: 0

        LogoComponent {
            id: logoComponentId
            Layout.topMargin:  root.isSqueezedHeight ? 13 : 83
            Layout.alignment:  Qt.AlignHCenter
            isSqueezedHeight:  root.isSqueezedHeight
            hideNetworkLabel:  !showNetworkLabel
        }

        ColumnLayout {
            id:                 contentLayout
            Layout.fillWidth:   true
            Layout.fillHeight:  true
            Layout.alignment:   Qt.AlignHCenter
        }

        Image {
            //Layout.topMargin: -100
            source:  "qrc:/assets/copyright.png"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 30
        }
    }
}
