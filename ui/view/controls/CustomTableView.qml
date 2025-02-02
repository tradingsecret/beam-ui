import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls.impl 2.4
import QtQuick.Layouts 1.12
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
import "."

TableView {
    id: tableView

    FontLoader { id: tomorrow_regular;  source: "qrc:/assets/fonts/SF-Pro-Display-TomorrowRegular.ttf" }

    property int headerHeight: 46
    property int headerTextFontSize: 14
    property int headerTextLeftMargin: 20
    property var mainBackgroundRect: null
    property var backgroundRect: 'transparent' // mainBackgroundRect != null ? mainBackgroundRect : main.backgroundRect
    property color headerColor: '#00000a' //'#00000d' //Style.table_header
    // property var headerOpacity: 1
    property bool headerShaderVisible: false

    // Scrollbar fine-tuning
    __scrollBarTopMargin: tableView.headerHeight
    verticalScrollBarPolicy: Qt.ScrollBarAsNeeded

    style: TableViewStyle {
        minimumHandleLength: 30

        handle: Rectangle {
            color: "white"
            radius: 3
            opacity: __verticalScrollBar.handlePressed ? 0.5 : 0.12
            implicitWidth: 6
        }

        scrollBarBackground: Rectangle {
            color: "transparent"
            implicitWidth: 6
            anchors.topMargin: 46
        }

        decrementControl: Rectangle {
            color: "transparent"
        }

        incrementControl: Rectangle {
            color: "transparent"
        }
    }

    function getAdjustedColumnWidth (column) {
        var acc = 0
        for (var i = 0; i < columnCount; ++i)
        {
            var c = getColumn(i)
            if (c != column && c.visible) {
                acc += c.width
            }
        }
        return width - acc
    }

    frameVisible: false
    backgroundVisible: false
    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff

    Rectangle {
        anchors.bottom: parent.top
        width: tableView.width
        height: 1
        color: '#112a26'
    }

    headerDelegate: Rectangle {
        id: rect
        height: headerHeight
        color:"transparent"// Style.background_main

        function getX() {
            return rect.mapToItem(backgroundRect, rect.x, rect.y).y;
        }
        function getY() {
            return rect.mapToItem(backgroundRect, rect.x, rect.y).y;
        }

        function updateShader() {
            if (headerShaderVisible) {
                shaderSrc.sourceRect.x = getX()
                shaderSrc.sourceRect.y = getY()
            }
        }

        Connections {
            target: tableView
            function onWidthChanged() {
                updateShader()
            }
            function onHeightChanged() {
                updateShader()
            }
            function onXChanged() {
                updateShader()
            }
            function onYChanged() {
                updateShader()
            }
            function onVisibleChanged() {
                updateShader()
            }
        }

        ShaderEffectSource {
            id: shaderSrc
            objectName: "renderRect"

            sourceRect.x: getX()
            sourceRect.y: getY()
            sourceRect.width: rect.width
            sourceRect.height: rect.height
            width: rect.width
            height: rect.height
            sourceItem: backgroundRect
            visible: headerShaderVisible
        }

        property bool lastColumn: styleData.column == tableView.columnCount-1
        property bool firstOrLastColumn : styleData.column == 0 || lastColumn
        
        clip: firstOrLastColumn

        Rectangle {
            x: lastColumn ? -12 : 0
            width: parent.width + (firstOrLastColumn ? 12 : 0)
            height: parent.height + (firstOrLastColumn ? 12 : 0)
            color: headerColor
            // opacity: tableView.headerOpacity
            radius: firstOrLastColumn ? 10 : 0
        }

        IconLabel {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: headerTextLeftMargin
            font.pixelSize: headerTextFontSize
            color: '#585858' //tableView.sortIndicatorColumn == styleData.column ? Style.content_main : Style.content_secondary
            //font.weight: tableView.sortIndicatorColumn == styleData.column ? Font.Bold : Font.Normal
            font.family: tomorrow_regular.name
            font.capitalization: Font.AllUppercase

            //icon.source: styleData.value == "" ? "" : tableView.sortIndicatorColumn == styleData.column ? "qrc:/assets/icon-sort-active.svg" : "qrc:/assets/icon-sort.svg"
            //icon.width: 5
            //icon.height: 8
            spacing: 6
            mirrored: true

            text: styleData.value
        }

        Rectangle {
            visible: false
            anchors.fill: parent
            color: 'transparent'
            border.width: 1
            border.color: 'pink'
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: tableView.width
            height: 1
            color: '#112a26'
        }
    }

    Component.onCompleted: {
        var numchilds = __scroller.children.length;
        __scroller.children[numchilds -1].anchors.rightMargin = 0;
    }
}
