import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.15
import "."

Dialog { 
    property var backgroundImage: "qrc:/assets/popup-window.png"

    //topPadding: 20
    leftPadding: 40
    rightPadding: 40
    bottomPadding: 20
    //width: 584
    //height: 340
    background: Rectangle {
        //radius: 10
        //color: Style.background_popup
        anchors.fill: parent
        color: 'transparent'

        Image {
            //fillMode: Image.PreserveAspectCrop
            width: parent.width
            height: parent.height
            fillMode: Image.Stretch
            anchors.fill: parent

            source: backgroundImage
        }
    }

    Overlay.modal: GaussianBlur {
        source: ShaderEffectSource {
            sourceItem: appWindow.contentItem
            live: false
        }
        radius: 8
        samples: 8//16
    }
}
