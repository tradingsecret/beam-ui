import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12
import QtQuick.Controls.impl 2.4
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
import "."

Button {
    id: control
    FontLoader { id: tomorrow_regular;  source: "qrc:/assets/fonts/SF-Pro-Display-TomorrowRegular.ttf" }
    
    palette.button:      "transparent" //checkable ? (checked ? Style.active : "transparent") : Style.background_button
    palette.buttonText:  checkable ? (checked ? Style.content_opposite : Style.content_secondary) : Style.content_main
    opacity:             enabled   ? 1.0 : 0.45

    property int   radius:         checkable ? 10 : 50
    property bool  allLowercase:   !text.startsWith("I ")
    property bool  showHandCursor: false
    property bool  hasShadow:      true
    property bool  hoveredText:    false
    property alias border:         rect.border
    property var   customColor
    property var   customBorderColor
    property bool  disableRadius:  fasle
    property bool  disableBorders: false


    font { 
        family:    tomorrow_regular.name
        pixelSize: 20
        weight: Font.Normal //control.checkable ? Font.Normal : Font.Bold
        capitalization: Font.AllUppercase //allLowercase && !control.checkable ? Font.AllLowercase : Font.MixedCase
    }

    height: 45
    Layout.preferredHeight: 45
    leftPadding: 30
    rightPadding: 30
    activeFocusOnTab: true

    spacing:     15
    icon.width:  16
    icon.height: 16

    contentItem: IconLabel {
        spacing:  control.spacing
        mirrored: control.mirrored
        display:  control.display

        icon:  control.icon
        text:  control.text
        font:  control.font
        //color: hovered || hoveredText ? '#5fe795' : 'white' //control.palette.buttonText
        color: customColor ? customColor : (hovered || hoveredText ? '#5fe795' : '#d2bdff') //control.palette.buttonText

        MouseArea {
            anchors.fill:  parent
            hoverEnabled:  true
            enabled:       false
            cursorShape:   control.showHandCursor ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }
    
    Keys.onPressed: {
        if (event.key == Qt.Key_Return || event.key == Qt.Key_Enter) control.clicked();
    }

    //background: Rectangle {
    ///    id:         rect
        //opacity:    0
    //    color:      "transparent"
    //    radius:  control.radius
        //color:   control.palette.button
    //    Image {
    //        id: backgroundImage
    //        anchors.fill: parent
    //        source: (hovered ? "qrc:/assets/primary-button-hover.png" : "qrc:/assets/primary-button.png")
    //    }
    //}

    background: Rectangle {
        id:         rect
        //opacity:    0
        color:      "transparent"
        //radius:  control.radius
        //color:   control.palette.button
        border.color: customBorderColor ? customBorderColor : (hovered ? '#1aa853' : '#d2bdff')
        border.width: disableBorders ? 0 : 2
        radius: disableRadius ? 0 : 4
        //AnimatedImage {
        //    id: backgroundImage
        //     anchors.fill: parent
        //    source: "qrc:/assets/button.mp4"
        //}
    }

    DropShadow {
        id: drop_shadow
        anchors.fill: rect
        radius:  3
        samples: 10
        color:   '#0ff' //Style.content_main
        source:  rect
        visible: control.hasShadow && (control.visualFocus || control.hovered || control.checked)
    }
}
