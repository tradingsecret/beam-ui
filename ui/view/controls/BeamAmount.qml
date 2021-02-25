import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
import Beam.Wallet 1.0
import "../utils.js" as Utils

Control {
    id: control
    spacing: 8

    property string  amount:              "0"
    property string  lockedAmount:        "0"
    property string  unitName:            BeamGlobals.beamUnit
    property string  rateUnit:            ""
    property string  rate:                "0"
    property string  color:               Style.content_main
    property bool    error:               false
    property bool    showZero:            true
    property bool    showTip:             true
    property int     rateFontSize:        10
    property string  iconSource:          ""
    property size    iconSize:            Qt.size(22, 22)
    property alias   copyMenuEnabled:     amountText.copyMenuEnabled
    property alias   caption:             captionText.text
    property int     captionFontSize:     12
    property string  prefix:              ""
    property real    maxPaintedWidth:     0
    property int     maxUnitChars:        0
    property real    vSpacing:            5

    property var     dropIcon:            dropIconCtrl
    property bool    showDrop:            false
    property bool    showDropCircular:    false
    property size    dropSize:            Qt.size(5, 3)

    font {
        pixelSize:  14
        styleName:  "Light"
        weight:     Font.Light
        family:     "SF Pro Display"
    }

    property var tipCtrl:   defaultTipCtrl
    property int tipY:      Utils.yUp(amountRow) + amountRow.height + 5

    property int tipX: {
        var amountX = Utils.xUp(control)
        var xpos = amountX + control.width / 2 - control.tipCtrl.width / 2
        if (xpos < 0) return 0
        if (xpos + control.tipCtrl.width <= main.width) return xpos
        return amountX + control.width - control.tipCtrl.width
    }

    function formatRate () {
        var formatted = Utils.formatAmountToSecondCurrency(control.amount, control.rate, control.rateUnit);
        return formatted == "" ?  ["-", control.rateUnit].join(" ") : control.prefix + formatted;
    }

    TextMetrics {
        id:     metrics
        font:   control.font
        elide:  Qt.ElideNone
    }

    TextMetrics {
        id:     lockedMetrics
        font:   lockedAmountCtrl.font
        elide:  Qt.ElideNone
    }

    function formatAmount (amount, uname) {
        if (parseFloat(amount) > 0 || showZero) {
            return (prefix || '') + [Utils.uiStringToLocale(amount), uname].join("\u2000") // 1/2 em space, EN QUAD Unicode char
        }
        return "-"
    }

    function calcMaxTextWidth () {
        var pos = control.mapFromItem(amountText.parent, amountText.x, amountText.y)
        return control.maxPaintedWidth - pos.x - ((showDropCircular || showDrop) ? dropIconCtrl.width + amountText.parent.spacing : 0)
    }

    function fitAmount (amount, uname, prefix, showZero, metrics, maxw) {
        if (maxw <= 0) return formatAmount(amount, uname, prefix, showZero)

        var samount = amount.toString()
        var unamed  = false
        var minUnitChars = 6

        while (true) {
           var result = formatAmount(samount, [uname, unamed ? '\u2026' : ''].join(''))
           if (result == "-") return result;

           metrics.text = result
           if (metrics.tightBoundingRect.width <= maxw) {
               return result
           }

           if (uname && minUnitChars && uname.length > minUnitChars)
           {
                uname  = uname.substring(0, uname.length - 1)
                unamed = true
           }
           else
           {
                if (samount.length == 0) return "ERROR"

                var rup = BeamGlobals.roundUp(samount)
                if (rup == samount) return result
                samount = rup
           }
        }
    }

    function fitText () {
        return fitAmount(control.amount,
                       control.unitName,
                       control.prefix,
                       control.showZero,
                       metrics,
                       calcMaxTextWidth()
        )
    }

    function calcMaxLockedWidth() {
        return calcMaxTextWidth() - lockedAmountLabel.width - lockedAmountRow.spacing
    }

    function fitLocked () {
        return fitAmount(control.lockedAmount,
                         control.unitName,
                         "", false,
                         lockedMetrics,
                         calcMaxLockedWidth()
        )
    }

    onAmountChanged: {
        if (maxPaintedWidth) amountText.text = fitText()
    }

    onUnitNameChanged: {
        if (maxPaintedWidth) amountText.text = fitText()
    }

    onMaxPaintedWidthChanged: {
        if (maxPaintedWidth) amountText.text = fitText()
        else amountText.text = Qt.binding(function () {
                                            return formatAmount(control.amount, Utils.limitText(control.unitName, control.maxUnitChars))
                                          })
    }

    onWidthChanged: {
        if (maxPaintedWidth) amountText.text = fitText()
    }

    property bool hasTip: tipText.text != amountText.text
    readonly property bool inTipArea: amountTextArea.containsMouse || dropIconArea.containsMouse
    readonly property bool tipVisible: showTip && hasTip && inTipArea

    AlphaTip {
        id: defaultTipCtrl

        visible: control.tipCtrl == defaultTipCtrl && control.tipVisible

        defBkColor:   Qt.rgba(55 / 255, 93  / 255, 123 / 255, 0.75)
        defTextColor: Qt.rgba(Style.content_main.r, Style.content_main.g, Style.content_main.b, 0.8)
        parent:       Overlay.overlay

        contentItem: SFText {
            id:             tipText
            text:           formatAmount(control.amount, control.unitName)
            font.pixelSize: 13
            font.styleName: "Light"
            font.weight:    Font.Light
            color:          defaultTipCtrl.defTextColor
        }
    }

    contentItem: Row {
        spacing: control.spacing

        SvgImage {
            id:          assetIcon
            source:      control.iconSource
            width:       control.iconSize.width
            height:      control.iconSize.height
            visible:     !!control.iconSource
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            spacing: control.vSpacing

            SFLabel {
                id:             captionText
                visible:        text.length > 0
                font.pixelSize: captionFontSize
                font.styleName: "Light"
                font.weight:    Font.Light
                color:          Qt.rgba(Style.content_main.r, Style.content_main.g, Style.content_main.b, 0.7)
            }

            Row {
                spacing: 0
                id: amountRow

                SFLabel {
                    id:               amountText
                    font.pixelSize:   control.font.pixelSize
                    color:            control.error ? Style.validator_error : control.color
                    onCopyText:       BeamGlobals.copyToClipboard(amount)
                    copyMenuEnabled:  true
                    text:             control.maxPaintedWidth ? fitText() : formatAmount(control.amount, Utils.limitText(control.unitName, control.maxUnitChars))
                    elide:            Text.ElideRight

                    MouseArea {
                        id:               amountTextArea
                        anchors.fill:     parent
                        hoverEnabled:     true
                        acceptedButtons:  Qt.NoButton
                        preventStealing:  true
                        //propagateComposedEvents: true

                        onWheel: function(data) {
                            data.accepted = tipCtrl.visible
                        }
                    }
                }

                Item {
                    height: amountText.height
                    width:  control.dropSize.width + 5

                    SvgImage {
                        id:         dropIconCtrl
                        visible:    showDrop
                        source:     "qrc:/assets/icon-down.svg"
                        width:      control.dropSize.width
                        height:     control.dropSize.height
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right
                    }

                    MouseArea {
                        id:               dropIconArea
                        anchors.fill:     parent
                        hoverEnabled:     true
                        acceptedButtons:  Qt.NoButton
                        preventStealing:  true

                        onWheel: function(data) {
                            data.accepted = tipCtrl.visible
                        }
                    }
                }
            }

            SFLabel {
                id:              secondCurrencyAmountText
                visible:         rateUnit.length > 0
                font.pixelSize:  control.rateFontSize
                font.styleName:  "Regular"
                font.weight:     Font.Normal
                color:           control.error ? Style.validator_error : Qt.rgba(Style.content_main.r, Style.content_main.g, Style.content_main.b, 0.5)
                text:            formatRate()
                onCopyText:      BeamGlobals.copyToClipboard(secondCurrencyAmountText.text)
                copyMenuEnabled: true
            }

            Row {
                id: lockedAmountRow
                width: parent.width
                spacing: 5

                SFLabel {
                    id:              lockedAmountLabel
                    visible:         lockedAmount != "0"
                    font.pixelSize:  control.rateFontSize
                    font.styleName:  "Regular"
                    font.weight:     Font.Normal
                    color:           control.error ? Style.validator_error : Qt.rgba(Style.content_main.r, Style.content_main.g, Style.content_main.b, 0.5)
                    //% "Locked"
                    text: qsTrId("general-locked")
                }

                SFLabel {
                    id:               lockedAmountCtrl
                    visible:          lockedAmount != "0"
                    font.pixelSize:   control.rateFontSize
                    font.styleName:   "Regular"
                    font.weight:      Font.Normal
                    color:            control.error ? Style.validator_error : Qt.rgba(Style.content_main.r, Style.content_main.g, Style.content_main.b, 0.5)
                    onCopyText:       BeamGlobals.copyToClipboard(amount)
                    copyMenuEnabled:  true
                    text:             fitLocked()
                    elide:            Text.ElideRight
                }
            }
        }
    }
}