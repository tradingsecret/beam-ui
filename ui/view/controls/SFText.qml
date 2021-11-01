import QtQuick 2.15
import QtQuick.Window 2.2

Text {
    FontLoader { id: tomorrow_regular;  source: "qrc:/assets/fonts/SF-Pro-Display-TomorrowRegular.ttf" }

	font { 
        family:    tomorrow_regular.name
		weight:    Font.Normal
	}
    property alias linkEnabled: linkMouseArea.enabled
    MouseArea {
        visible: false
        id: linkMouseArea
        enabled: false
        anchors.fill: parent
        acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
        cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
    }
}
