import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "."

CustomButton {
    palette.button: Style.active
    palette.buttonText: Style.content_opposite

    SFText {
        id: text
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        font.pixelSize: 12
        font.styleName: "Bold";
        font.weight: Font.Bold
        font.capitalization: Font.AllUppercase

        color: '#d5ff9f'

        text: parent.text
        visible: false
    }

    background: Rectangle {
        id:         rect
        //opacity:    0
        color:      "transparent"
        radius:  control.radius
        //color:   control.palette.button
        Image {
            id: backgroundImage
            anchors.fill: parent
            source: "qrc:/assets/primary-button-hover.png"
        }
    }
}
