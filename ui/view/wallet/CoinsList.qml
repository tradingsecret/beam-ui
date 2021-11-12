import QtQuick 2.15
import QtQuick.Layouts 1.12
import "../controls"

RowLayout {
    id: control

    FontLoader { id: tomorrow_extralight;  source: "qrc:/assets/fonts/Tomorrow-ExtraLight.ttf" }

    property var icons
    property var names
    property var verified
    readonly property int count: icons ? icons.length : 0

    spacing: 0
    clip: true

    Repeater {
        model: Math.min(3, control.count)

        SvgImage {
            Layout.leftMargin: 13
            sourceSize: Qt.size(0, 0)
            z: -index
        }
    }

    SFText {
        id: extraCount
        Layout.fillWidth: true
        Layout.leftMargin: 7
        visible: count > 3

        text:            ["+", count - 3].join("")
        font.pixelSize: 15
        font.family:  tomorrow_extralight.name
        color:             '#ffffff'
        font.weight: Font.Bold
    }

    SFText {
        id: coinName
        Layout.fillWidth: true
        //Layout.leftMargin: 10
        visible: count == 1

        text:            control.names ? control.names[0] : ""
        font.pixelSize: 15
        font.family:  tomorrow_extralight.name
        color:             '#ffffff'
        elide:           Text.ElideRight
        font.weight: Font.Bold
    }

    Item {
        Layout.fillWidth: true
        visible: !extraCount.visible && ! coinName.visible
    }
}
