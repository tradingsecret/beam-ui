import QtQuick.Layouts 1.11
import QtQuick 2.11
import QtQuick.Controls 2.4
import Beam.Wallet 1.0
import "../utils.js" as Utils
import Beam.Wallet 1.0

Control {
    id: control

    function getFeeTitle() {
        if (control.feeTitle.length) {
            return control.feeTitle;
        }
        if (control.currency == Currency.CurrBeam) {
            return control.currFeeTitle ?
                //% "BEAM Transaction fee"
                qsTrId("beam-transaction-fee") :
                //% "Transaction fee"
                qsTrId("general-fee")
        }
        //% "%1 Transaction fee rate"
        return qsTrId("general-fee-rate").arg(control.currencyLabel)
    }

    function getTotalFeeTitle() {
        //% "%1 Transaction fee (est)"
        return qsTrId("general-fee-total").arg(control.currencyLabel)
    }

    function getTotalFeeAmount() {
        return BeamGlobals.calcTotalFee(control.currency, control.fee);
    }

    function getFeeInSecondCurrency(feeValue) {
        return BeamGlobals.calcFeeInSecondCurrency(
            feeValue,
            control.currency,
            control.secondCurrencyRateValue,
            control.secondCurrencyLabel);
    }

    function getAmountInSecondCurrency() {
        return BeamGlobals.calcAmountInSecondCurrency(
            control.amountIn,
            control.secondCurrencyRateValue,
            control.secondCurrencyLabel) + " " + control.secondCurrencyLabel;
    }

    function getSendAllIcon()
    {
        if (control.color == Style.accent_outgoing)
            return "qrc:/assets/icon-send-purple.svg";
        else if (control.color == Style.active)
            return "qrc:/assets/icon-send-bright-teal.svg";
        else
            return "qrc:/assets/icon-send-blue.svg";
    }

    readonly property bool     isValidFee:     hasFee ? feeInput.isValid : true
    readonly property bool     isValid:        error.length == 0 && isValidFee
    readonly property string   currencyLabel:  BeamGlobals.getCurrencyLabel(control.currency)

    property string   title
    property string   color:        Style.accent_incoming
    property string   currColor:    Style.content_main
    property bool     hasFee:       false
    property bool     currFeeTitle: false
    property bool     multi:        false // changing this property in runtime would reset bindings
    property int      currency:     Currency.CurrBeam
    property string   amount:       "0"
    property string   amountIn:     "0"  // public property for binding. Use it to avoid binding overriding
    property int      fee:          BeamGlobals.getDefaultFee(control.currency)
    property alias    error:        errmsg.text
    property bool     readOnlyA:    false
    property bool     readOnlyF:    false
    property bool     resetAmount:  true
    property var      amountInput:  ainput
    property bool     showTotalFee: false
    property bool     showAddAll:   false
    property string   secondCurrencyRateValue:  "0"
    property string   secondCurrencyLabel:      ""
    property var      setMaxAvailableAmount:    {} // callback function to set amount from viewmodel
    property bool     showSecondCurrency:       control.secondCurrencyLabel != "" && control.secondCurrencyLabel != control.currencyLabel
    readonly property bool  isExchangeRateAvailable:    control.secondCurrencyRateValue != "0"
    property bool     enableDoubleFrame: false
    property bool     feeFieldFillWidth: false
    property string   feeTitle: ""
    property int      minimalFee: 0

    contentItem: ColumnLayout {
        Layout.fillWidth: true
        ColumnLayout {
            Layout.fillWidth: true
            Rectangle {
                x:      0
                y:      0
                width:  parent.width
                height: parent.height
                radius: 10
                color:  Style.background_second
                visible: enableDoubleFrame
            }

            ColumnLayout {
                Layout.topMargin: enableDoubleFrame ? 20 : 0
                Layout.bottomMargin: enableDoubleFrame ? 40 : 0
                Layout.leftMargin: enableDoubleFrame ? 20 : 0
                Layout.rightMargin: enableDoubleFrame ? 20 : 0

                SFText {
                    font.pixelSize:   14
                    font.styleName:   "Bold"
                    font.weight:      Font.Bold
                    font.letterSpacing: enableDoubleFrame? 3.11 : 1
                    color:            enableDoubleFrame ? Style.content_secondary : Style.content_main
                    text:             control.title
                }

                RowLayout {
                    id: ainputRow
                    Layout.fillWidth: true
                    Layout.preferredWidth: 410

                    SFTextInput {
                        id:               ainput
                        Layout.fillWidth: true
                        Layout.preferredWidth: 248
                        font.pixelSize:   36
                        font.styleName:   "Light"
                        font.weight:      Font.Light
                        color:            error.length ? Style.validator_error : control.color
                        backgroundColor:  error.length ? Style.validator_error : Style.content_main
                        validator:        RegExpValidator {regExp: /^(([1-9][0-9]{0,7})|(1[0-9]{8})|(2[0-4][0-9]{7})|(25[0-3][0-9]{6})|(0))(\.[0-9]{0,7}[1-9])?$/}
                        selectByMouse:    true
                        text:             formatDisplayedAmount()
                        readOnly:         control.readOnlyA

                        onTextChanged: {
                            // if nothing then "0", remove insignificant zeroes and "." in floats
                            errmsg.text = "";
                            if (ainput.focus) {
                                control.amount = text ? text.replace(/\.0*$|(\.\d*[1-9])0+$/,'$1') : "0"
                            }
                        }

                        onFocusChanged: {
                            text = formatDisplayedAmount()
                            if (focus) cursorPosition = positionAt(ainput.getMousePos().x, ainput.getMousePos().y)
                        }

                        function formatDisplayedAmount() {
                            return control.amountIn == "0" ? "" : (ainput.focus ? control.amountIn : Utils.uiStringToLocale(control.amountIn))
                        }

                        Connections {
                            target: control
                            onAmountInChanged: {
                                if (!ainput.focus) {
                                    ainput.text = ainput.formatDisplayedAmount()
                                }
                            }
                        }
                    }

                    SFText {
                        Layout.topMargin:   22
                        font.pixelSize:     24
                        font.letterSpacing: 0.6
                        color:              control.currColor
                        text:               control.currencyLabel
                        visible:            !multi
                    }

                    CustomComboBox {
                        id:                  currCombo
                        Layout.topMargin:    22
                        Layout.minimumWidth: 95
                        spacing:             0
                        fontPixelSize:       24
                        fontLetterSpacing:   0.6
                        currentIndex:        control.currency
                        color:               control.currColor
                        visible:             multi
                        model:               Utils.currenciesList()

                        onActivated: {
                            if (multi) control.currency = index
                            if (resetAmount) control.amount = 0
                        }
                    }

                    function addAll(){
                        ainput.focus = false;                
                        if (control.setMaxAvailableAmount) {
                            control.setMaxAvailableAmount();
                        }
                    }

                    SvgImage {
                        Layout.alignment:    Qt.AlignBottom | Qt.AlignRight
                        Layout.bottomMargin: 7
                        Layout.leftMargin:   25
                        Layout.maximumHeight: 16
                        Layout.maximumWidth:  16
                        source: control.getSendAllIcon()
                        visible:             control.showAddAll
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ainputRow.addAll();
                            }
                        }
                    }

                    SFText {
                        Layout.alignment:    Qt.AlignBottom | Qt.AlignRight
                        Layout.bottomMargin: 7
                        font.pixelSize:   14
                        font.styleName:   "Bold";
                        font.weight:      Font.Bold
                        color:            control.color
                        //% "add all"
                        text:             qsTrId("amount-input-add-all")
                        visible:             control.showAddAll
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                ainputRow.addAll();
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    SFText {
                        id:              errmsg
                        color:           Style.validator_error
                        font.pixelSize:  12
                        font.styleName:  "Italic"
                        width:           parent.width
                        visible:         error.length
                    }
                    SFText {
                        id:             amountSecondCurrencyText
                        visible:        control.showSecondCurrency && !errmsg.visible && !showTotalFee  // show only on send side
                        font.pixelSize: 14
                        opacity:        isExchangeRateAvailable ? 0.5 : 0.7
                        color:          isExchangeRateAvailable ? Style.content_secondary : Style.accent_fail
                        text:           isExchangeRateAvailable
                                        ? getAmountInSecondCurrency()
                                        //% "Exchange rate to %1 is not available"
                                        : qsTrId("general-exchange-rate-not-available").arg(control.secondCurrencyLabel)
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: enableDoubleFrame ? 10 : 0
            Rectangle {
                x:      0
                y:      0
                width:  parent.width
                height: parent.height
                radius: 10
                color:  Style.background_second
                visible: enableDoubleFrame
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: enableDoubleFrame ? 20 : 50
                Layout.bottomMargin: enableDoubleFrame ? 40 : 0
                Layout.leftMargin: enableDoubleFrame ? 20 : 0
                Layout.rightMargin: enableDoubleFrame ? 20 : 0
                Layout.alignment:     Qt.AlignTop

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth:  !showTotalFee && feeFieldFillWidth ? parent.width : 198
                    Layout.alignment:    Qt.AlignTop
                    visible:              control.hasFee

                    SFText {
                        font.pixelSize:   14
                        font.styleName:   "Bold"
                        font.weight:      Font.Bold
                        font.letterSpacing: enableDoubleFrame? 3.11 : 1
                        color:            enableDoubleFrame ? Style.content_secondary : Style.content_main
                        text:             getFeeTitle()
                    }
                    FeeInput {
                        id:               feeInput
                        Layout.fillWidth: true
                        fillWidth: !showTotalFee && feeFieldFillWidth
                        inputPreferredWidth: !showTotalFee && feeFieldFillWidth ? -1 : feeInput.inputPreferredWidth//parent.width
                        fee:              control.fee
                        minFee:           control.minimalFee ? control.minimalFee : BeamGlobals.getMinimalFee(control.currency)
                        feeLabel:         BeamGlobals.getFeeRateLabel(control.currency)
                        feeLabelColor:    enableDoubleFrame ? Style.content_secondary : Style.content_main
                        color:            control.color
                        readOnly:         control.readOnlyF
                        showSecondCurrency:         control.showSecondCurrency
                        isExchangeRateAvailable:    control.isExchangeRateAvailable
                        secondCurrencyAmount:       getFeeInSecondCurrency(control.fee)
                        secondCurrencyLabel:        control.secondCurrencyLabel
                        Connections {
                            target: control
                            onFeeChanged: feeInput.fee = control.fee
                            onCurrencyChanged: feeInput.fee = BeamGlobals.getDefaultFee(control.currency)
                        }
                    }
                }
            
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: !showTotalFee && feeFieldFillWidth ? 0 : parent.width / 2
                    Layout.alignment:    Qt.AlignTop
                    visible:              showTotalFee && !feeFieldFillWidth && control.hasFee && control.currency != Currency.CurrBeam
                    SFText {
                        font.pixelSize:   14
                        font.styleName:   "Bold"
                        font.weight:      Font.Bold
                        color:            Style.content_main
                        text:             getTotalFeeTitle()
                    }
                    SFText {
                        id:               totalFeeLabel
                        Layout.topMargin: 6
                        font.pixelSize:   14
                        color:            Style.content_main
                        text:             getTotalFeeAmount()
                    }
                    SFText {
                        id:               feeTotalInSecondCurrency
                        visible:          control.showSecondCurrency && control.isExchangeRateAvailable
                        Layout.topMargin: 6
                        font.pixelSize:   14
                        opacity:          0.5
                        color:            Style.content_secondary
                        text:             getFeeInSecondCurrency(parseInt(totalFeeLabel.text, 10))
                    }
                }
            }

            SFText {
                visible:               control.hasFee && control.currency != Currency.CurrBeam
                Layout.topMargin:      20
                Layout.bottomMargin: enableDoubleFrame ? 40 : 0
                Layout.leftMargin: enableDoubleFrame ? 20 : 0
                Layout.rightMargin: enableDoubleFrame ? 20 : 0
                Layout.preferredWidth: 370
                font.pixelSize:        14
                font.italic:           true
                wrapMode:              Text.WordWrap
                color:                 Style.content_secondary
                lineHeight:            1.1
                //% "Remember to validate the expected fee rate for the blockchain (as it varies with time)."
                text:                  qsTrId("settings-fee-rate-note")
            }

            Binding {
                target:   control
                property: "fee"
                value:    feeInput.fee
            }
        }
    }
}
