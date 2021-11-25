import QtQuick 2.11
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.4
import Beam.Wallet 1.0
import "controls"
import "./utils.js" as Utils

ColumnLayout {
    id: control
    spacing: 0
    property var defaultFocusItem: receiverToken ? sendAmountInput.amountInput : tokenInput

    FontLoader { id: tomorrow_regular;  source: "qrc:/assets/fonts/SF-Pro-Display-TomorrowRegular.ttf" }

    SendViewModel {
        id: viewModel

        onSendMoneyVerified: function () {
            onAccepted()
        }

        onCantSendToExpired: function () {
            Qt.createComponent("send_expired.qml")
                .createObject(control)
                .open();
        }
    }

    SwapOffersViewModel {
        id: viewModelSwap
    }

    property alias assetId:   viewModel.assetId
    property alias assetIdx:  sendAmountInput.currencyIdx
    property var   assetInfo: viewModel.assetsList[assetIdx]

    property var   sendUnit:  assetInfo.unitName
    property var   rate:      assetInfo.rate
    property var   rateUnit:  assetInfo.rateUnit

    // callbacks set by parent
    property var   onAccepted:    undefined
    property var   onClosed:      undefined
    property var   onSwapToken:   undefined
    property alias receiverToken: viewModel.token

    Component.onCompleted: {
        if (receiverToken) {
            tokenInput.cursorPosition = 0
        }
    }

    onAssetIdChanged: function () {
        // C++ provides asset id, combobox exepects index, need to fix this at some point
        for (var idx = 0; idx < viewModel.assetsList.length; ++idx) {
            if (viewModel.assetsList[idx].assetId == assetId) {
                 if (assetIdx != idx) {
                    assetIdx = idx
                 }
            }
        }
    }

    TopGradient {
        mainRoot: main
        topColor: Style.accent_outgoing
    }

    //
    // Title row
    //
    SubtitleRow {
        Layout.fillWidth:    true
        Layout.topMargin:    100
        Layout.bottomMargin: 30

        //% "Send"
        text:   qsTrId("send-title")
        onBack: control.onClosed
        visible: false
    }

    ScrollView {
        id:                  scrollView
        Layout.fillWidth:    true
        Layout.fillHeight:   true
        Layout.bottomMargin: 10
        clip:                true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy:   ScrollBar.AlwaysOff
        ScrollBar.vertical.interactive: false
        wheelEnabled: false

        ColumnLayout {
            width: scrollView.availableWidth

            ColumnLayout {
                Layout.minimumWidth: 440
                Layout.maximumWidth: 440
                width: 440

                ColumnLayout {
                    Layout.minimumHeight: 65
                    Layout.maximumHeight: 65
                    Layout.minimumWidth: parent.width
                    Layout.maximumWidth: parent.width
                    width: parent.width
                    height: 65
                    Layout.topMargin: 30

                    ColumnLayout {
                        Layout.leftMargin: 10

                        Row {
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                            //spacing: 20
                            visible: true

                            SFText {
                                text: "Balance:"
                                color: '#5fe795'
                                font.pixelSize: 16
                                font.capitalization: Font.AllUppercase
                            }
                        }

                        Row {
                            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                            Layout.topMargin: 5
                            //spacing: 20
                            visible: true

                            SFText {
                                text: viewModelSwap.beamAvailable + ' ARC'
                                color: '#5fe795'
                                font.pixelSize: 30
                                font.capitalization: Font.AllUppercase
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.right: parent.right
                        anchors.top: parent.top

                        CustomButton {
                            id: backBtn
                            Layout.alignment: Qt.AlignRight
                            leftPadding: 0
                            rightPadding: 0
                            //Layout.leftMargin: 75

                            //anchors.verticalCenter: parent.verticalCenter
                            //anchors.left:   parent.right

                            palette.button: "transparent"
                            showHandCursor: true

                            //% "Back"
                            text:         "<= " + qsTrId("general-back")
                            //visible:      true

                            //onClicked: control.onClosed
                            onClicked: {
                                updateItem(0);
                                //control.onClosed();
                            }
                            customColor: 'white'
                            disableBorders: true

                            //background.border.width: 0
                            //contentItem.color: 'white'
                        }

                        Rectangle {
                            visible: true
                            anchors.fill: parent
                            color: 'transparent'
                            //border.width: 3
                            //border.color: 'purple'
                        }
                    }

                    Rectangle {
                        visible: true
                        anchors.fill: parent
                        color: 'transparent'
                        //border.width: 2
                        //border.color: 'pink'
                    }
                }

                Row {
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    Layout.topMargin: 25
                    spacing: 40

                    CustomButton {
                        height: 43
                        id: sendButton
                        Layout.alignment: Qt.AlignLeft
                        palette.button: Style.accent_outgoing
                        palette.buttonText: Style.content_opposite
                        hoveredBorderColor: '#1aa853'
                        //% "Send"
                        text: qsTrId("general-send")
                        enabled: false
                        onClicked: {
                            navigateSend(assets.selectedId);
                        }
                        width: 200
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    CustomButton {
                        height: 43
                        Layout.alignment: Qt.AlignRight
                        palette.button: Style.accent_incoming
                        palette.buttonText: Style.content_opposite
                        hoveredBorderColor: '#1aa853'
                        //% "Receive"
                        text: qsTrId("wallet-receive-button")
                        enabled: true
                        onClicked: {
                            navigateReceive(assets.selectedId);
                        }
                        width: 200
                    }
                }


                Rectangle {
                    visible: true
                    anchors.fill: parent
                    color: 'transparent'
                    //border.width: 3
                    //border.color: 'yellow'
                }
            }


            Item {
                Layout.fillHeight: true
            }


            //
            // Content row
            //
            RowLayout {
                Layout.fillWidth:   true
                spacing:  10

                //
                // Left column
                //
                ColumnLayout {
                    Layout.alignment:       Qt.AlignTop
                    Layout.fillWidth:       true
                    Layout.preferredWidth:  400
                    spacing:                10

                    //
                    // Transaction info
                    //
                    Panel {
                        //% "Send to"
                        title:            qsTrId("general-send-to")
                        Layout.fillWidth: true
                        backgroundColor: 'transparent'
                        leftPadding: 0
                        content: ColumnLayout {
                            spacing: 0
                            SFTextInput {
                                property bool tokenError:  viewModel.token && !viewModel.tokenValid

                                Layout.fillWidth:  true
                                id:                tokenInput
                                font.pixelSize:    18
                                font.italic:       false
                                dottedBorder:      true
                                dottedBorderColor: '#616360'
                                color:             '#bb69dd' //tokenError ? Style.validator_error : Style.content_main
                                backgroundColor:   tokenError ? Style.validator_error : Style.content_main
                                //font.italic :      tokenError
                                text:              viewModel.token
                                validator:         RegExpValidator { regExp: /[0-9a-zA-Z]{1,}/ }
                                selectByMouse:     true

                                //% "Paste recipient address here"
                                placeholderText:  qsTrId("send-contact-address-placeholder")
                                onTextChanged: function () {
                                    var isSwap = BeamGlobals.isSwapToken(text)
                                    if (isSwap && typeof onSwapToken == "function") {
                                        onSwapToken(text);
                                    }
                                }
                            }

                            SFText {
                                Layout.alignment: Qt.AlignTop
                                Layout.fillWidth: true
                                id:               receiverTAError
                                color:            tokenInput.tokenError ? Style.validator_error : Style.content_secondary
                                font.italic:      tokenInput.tokenError
                                font.pixelSize:   12
                                wrapMode:         Text.Wrap
                                text:             tokenInput.tokenError ?
                                                  //% "Invalid wallet address"
                                                  qsTrId("wallet-send-invalid-address-or-token") :
                                                  viewModel.newTokenMsg
                                visible:          tokenInput.tokenError || viewModel.newTokenMsg
                            }
                    
                            Binding {
                                target:   viewModel
                                property: "token"
                                value:    tokenInput.text
                            }

                            SFText {
                                Layout.alignment:   Qt.AlignTop
                                Layout.fillWidth:   true
                                id:                 addressNote
                                color:              Style.content_secondary
                                font.italic:        true
                                font.pixelSize:     12
                                wrapMode:           Text.Wrap
                                visible:            viewModel.tokenValid
                                text:               viewModel.tokenTip
                            }
                        }
                    }

                    //
                    // Amount
                    //
                    Panel {
                        //% "Amount"
                        title: qsTrId("general-send-amount")
                        //Layout.fillWidth: true
                        //width: parent.width
                        Layout.fillWidth: true
                        backgroundColor: 'transparent'
                        leftPadding: 0

                        content: ColumnLayout {
                            spacing: 0
                            Layout.fillWidth: true

                            RowLayout {
                                Layout.fillWidth: true

                                Grid{
                                    columns: 2

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        width: 250

                                        AmountInput {
                                            id:                sendAmountInput
                                            amount:            viewModel.sendAmount
                                            color:             '#56d288'
                                            Layout.fillWidth:  true

                                            //width:              parent.width / 2
                                            currencies:        viewModel.assetsList
                                            multi:             viewModel.assetsList.length > 1
                                            showRate:          false

                                            error: {
                                                return ""
                                                /*
                                                if (!viewModel.isEnoughAmount)
                                                {
                                                    var maxAmount = Utils.uiStringToLocale(viewModel.maxSendAmount)
                                                    //% "Insufficient funds to complete the transaction. Maximum amount is %1 %2."
                                                    return qsTrId("send-no-funds").arg(maxAmount).arg(Utils.limitText(control.sendUnit, 10))
                                                }
                                                else if (!viewModel.isEnoughFee)
                                                {
                                                    //% "Insufficient funds to pay transaction fee."
                                                    return qsTrId("send-no-funds-for-fee")
                                                }*/
                                            }

                                            onCurrencyIdxChanged: function () {
                                                var idx = sendAmountInput.currencyIdx
                                                control.assetId = viewModel.assetsList[idx].assetId
                                            }
                                        }

                                        RowLayout {
                                            spacing: 0
                                            //width: 250

                                            /*SFText {
                                                Layout.fillWidth:  true
                                                font.pixelSize:      14
                                                font.styleName:      "Bold"
                                                font.weight:         Font.Bold
                                                font.letterSpacing:  3.11
                                                font.capitalization: Font.AllUppercase
                                                color:               Style.content_main
                                                //% "Available"
                                                text:             qsTrId("send-available")
                                                visible:          text.length > 0
                                            }*/

                                            ColumnLayout {
                                                Layout.leftMargin: 0
                                                Layout.fillHeight: true
                                                Layout.fillWidth: true
                                                spacing:           0
                                                width: parent.width

                                                SFText {
                                                    Layout.fillWidth: true
                                                    font.pixelSize:   12
                                                    font.capitalization: Font.AllUppercase
                                                    color:            '#56d288'
                                                    //% "max"
                                                    text:             "Send half"

                                                    MouseArea {
                                                        anchors.fill:    parent
                                                        acceptedButtons: Qt.LeftButton
                                                        cursorShape:     Qt.PointingHandCursor
                                                        onClicked:       function () {
                                                            sendAmountInput.clearFocus()
                                                            viewModel.setHalfPossibleAmount()
                                                        }
                                                    }
                                                }
                                            }

                                            ColumnLayout {
                                                Layout.rightMargin: 50
                                                Layout.alignment:  Qt.AlignRight

                                                SFText {
                                                    font.pixelSize:   12
                                                    font.capitalization: Font.AllUppercase
                                                    color:            '#56d288'
                                                    //% "max"
                                                    text:             "Send max"

                                                    MouseArea {
                                                        anchors.fill:    parent
                                                        acceptedButtons: Qt.LeftButton
                                                        cursorShape:     Qt.PointingHandCursor
                                                        onClicked:       function () {
                                                            sendAmountInput.clearFocus()
                                                            viewModel.setMaxPossibleAmount()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    SFText {
                                        Layout.fillWidth:  true
                                        topPadding:        25
                                        leftPadding:       25
                                        width: 250
                                        Layout.alignment:       Qt.AlignVCenter
                                        font.pixelSize:         14
                                        font.italic:            true
                                        color:                  Style.validator_error
                                        text:                   "Insufficient funds"
                                        visible:                !viewModel.isEnough
                                    }
                                }
                            }

                            SFText {
                                topPadding:             10
                                Layout.fillWidth:       true
                                Layout.alignment:       Qt.AlignVCenter
                                font.pixelSize:         14
                                font.italic:            true
                                color:                  '#616360'
                                text:                   "The exchange rate to USD is available only on MAINNET"
                            }

                            Connections {
                                target: viewModel
                                function onSendAmountChanged () {
                                    sendAmountInput.amount = viewModel.sendAmount
                                }
                            }

                            Binding {
                                target:   viewModel
                                property: "sendAmount"
                                value:    sendAmountInput.amount
                            }
                        }
                    }

                    Pane {
                        //Layout.fillWidth:        true
                        padding:                 20
                        topPadding:              10
                        Layout.alignment:  Qt.AlignHCenter
                        leftPadding: 0

                        background: Rectangle {
                            radius: 10
                            color:  'transparent' //Style.background_button
                        }

                        Row {
                            Layout.alignment:  Qt.AlignHCenter
                            //anchors.fill:   parent
                            //columnSpacing:  35
                            //rowSpacing:     14
                            //columns:        2

                            SFText {
                                Layout.alignment:       Qt.AlignTop
                                font.pixelSize:         20
                                color:                  viewModel.isEnough ? '#fff' : Style.validator_error
                                text:                   qsTrId("send-regular-fee") + ": "
                            }

                            BeamAmount {
                                Layout.alignment:  Qt.AlignTop
                                Layout.fillWidth:  true
                                error:             !viewModel.isEnough
                                amount:            viewModel.fee
                                unitName:          BeamGlobals.beamUnit
                                rateUnit:          viewModel.feeRateUnit
                                rate:              viewModel.feeRate
                                font.pixelSize:    20
                                font.family:       tomorrow_regular.name
                                font.weight:       Font.Normal
                                maxPaintedWidth:   false
                                maxUnitChars:      20
                            }
                        }
                    }

                    CustomButton {
                        Layout.alignment:  Qt.AlignHCenter
                        Layout.topMargin:  0
                        customColor:       '#5fe795'
                        customBorderColor: '#5fe795'
                        //% "Send"
                        text:                "Confirm"
                        palette.buttonText:  Style.content_opposite
                        palette.button:      Style.accent_outgoing
                        enabled:             viewModel.canSend
                        onClicked: {
                            const dialog = Qt.createComponent("send_confirm.qml")
                            const instance = dialog.createObject(control,
                                {
                                    addressText:   viewModel.token,
                                    typeText:      viewModel.sendType,
                                    isOnline:      viewModel.sendTypeOnline,
                                    amounts: [{
                                        amount:   viewModel.sendAmount,
                                        unitName: control.sendUnit,
                                        rate:     control.rate,
                                        spend:    true
                                    }],
                                    rateUnit:      control.rateUnit,
                                    fee:           viewModel.fee,
                                    feeRate:       viewModel.feeRate,
                                    onAccepted: function () {
                                        viewModel.sendMoney()
                                    },
                                })

                            instance.onAccepted.connect(function () {
                                viewModel.sendMoney()
                            })

                            instance.open()
                        }
                    }
                }

                //
                // Right column
                //
                ColumnLayout {
                    Layout.alignment:      Qt.AlignTop
                    Layout.fillWidth:      true
                    Layout.preferredWidth: 400
                    spacing:               10

                    //
                    // Comment
                    //
                    Panel {
                        //% "Comment"
                        title:                  qsTrId("general-comment")
                       // titleCapitalization:    Font.AllUppercase
                        Layout.fillWidth:       true
                        //folded:                 true
                        backgroundColor: 'transparent'
                        rightPadding: 0

                        content: ColumnLayout {
                            SFTextInput {
                                id:                addressComment
                                font.pixelSize:    18
                                Layout.fillWidth:  true
                                dottedBorder:      true
                                dottedBorderColor: '#616360'
                                color:             Style.content_main
                                text:              viewModel.comment
                                maximumLength:    BeamGlobals.maxCommentLength()
                                //% "Comments are  local and won't be shared"
                                placeholderText:   qsTrId("general-comment-local")
                            }

                            Binding {
                                target:   viewModel
                                property: "comment"
                                value:    addressComment.text
                            }
                        }
                    }

                    Panel {
                        //% "Transaction type"
                        title: qsTrId("general-tx-type")
                        Layout.fillWidth: true
                        visible: false//viewModel.canChoose
                        backgroundColor: 'transparent'
                        rightPadding: 0

                        content: ColumnLayout {
                            spacing: 20
                            id: addressType

                            Pane {
                                padding: 2

                                background: Rectangle {
                                    color:  Qt.rgba(1, 1, 1, 0.1)
                                    radius: 16
                                }

                                ButtonGroup {
                                    id: txTypeGroup
                                }

                                RowLayout {
                                    spacing: 0

                                    CustomButton {
                                        Layout.preferredHeight: 30
                                        Layout.preferredWidth: offlineCheck.width
                                        id: regularCheck
                                        //% "Online"
                                        text:               qsTrId("tx-online")
                                        ButtonGroup.group:  txTypeGroup
                                        checkable:          true
                                        hasShadow:          false
                                        checked:            !viewModel.choiceOffline
                                        radius:             16
                                        border.width:       1
                                        border.color:       checked ? Style.active : "transparent"
                                        palette.button:     checked ? Qt.rgba(0, 252/255, 207/255, 0.1) : "transparent"
                                        palette.buttonText: checked ? Style.active : Style.content_secondary
                                    }

                                    CustomButton {
                                        Layout.preferredHeight: 30
                                        Layout.minimumWidth: 137
                                        id: offlineCheck
                                        //% "Offline"
                                        text:               qsTrId("tx-offline")
                                        ButtonGroup.group:  txTypeGroup
                                        checkable:          true
                                        checked:            viewModel.choiceOffline
                                        hasShadow:          false
                                        radius:             16
                                        border.width:       1
                                        border.color:       checked ? Style.active : "transparent"
                                        palette.button:     checked ? Qt.rgba(0, 252/255, 207/255, 0.1) : "transparent"
                                        palette.buttonText: checked ? Style.active : Style.content_secondary
                                    }

                                    Binding {
                                        target:   viewModel
                                        property: "choiceOffline"
                                        value:    offlineCheck.checked
                                    }
                                }
                            }
                        }
                    }

                    SFText {
                        Layout.alignment:      Qt.AlignHCenter
                        Layout.preferredWidth: 400
                        Layout.topMargin:      15
                        font.pixelSize:        14
                        font.italic:           true
                        color:                 Style.content_disabled
                        wrapMode:              Text.WordWrap
                        horizontalAlignment:   Text.AlignHCenter
                        text:                  viewModel.tokenTip2
                        //visible:               !!text
                        visible: false
                    }
                }
            }

            //
            // Footers
            //


            Item {
                Layout.fillHeight: true
                Layout.bottomMargin: 20
            }
        }  // ColumnLayout
    }  // ScrollView
} // ColumnLayout
