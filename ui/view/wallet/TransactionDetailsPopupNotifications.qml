import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import "../utils.js" as Utils
import "../controls"

CustomDialog {
    id: "dialog"

    property var sendAddress: ""
    property var receiveAddress: ""
    property var senderIdentity: ""
    property var receiverIdentity: ""
    property var comment: ""
    property var txID: ""
    property var kernelID: ""
    property var status: ""
    property var failureReason: ""
    property var isIncome: ""
    property var hasPaymentProof: ""
    property var isSelfTx: ""
    property var rawTxID: ""
    property var stateDetails: ""
    property string token
    property bool hasToken: token.length > 0 

    property bool   feeOnly
    property string fee
    property string feeUnit
    property string feeRate
    property string feeRateUnit

    property string  cidsStr
    property string  searchFilter: ""
    property string  addressType
    property bool    isShieldedTx: false
    property bool    isCompleted:  false
    property bool    isContractTx: false
    property int     minConfirmations: 0
    property string  confirmationsProgress: ""
    property string  dappName: ""

    property var assetNames: []
    property var assetIcons: [""]
    property var assetAmounts: []
    property var assetIncome: []
    property var assetRates: []
    property var assetIDs: []
    property var assetVerified: []
    property string rateUnit
    readonly property int assetCount: assetNames ? assetNames.length : 0
    property int footerBottomPadding: 95

    property alias initialState: stm.state
    property var getPaymentProof: function (rawTxId) { return null; }

    function getHighlitedText(text) {
        return Utils.getHighlitedText(text, dialog.searchFilter, Style.active.toString());
    }

    property PaymentInfoItem paymentInfo
    signal textCopied(string text)
    signal openExternal(string kernelId)

    modal: true
    //width: 760
    //height: 650
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    parent: Overlay.overlay
    padding: 0

    backgroundImage: "qrc:/assets/popups/popup-13.png"
    width: 710
    height: 490

    FontLoader { id: agency_b;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyB.ttf" }
    FontLoader { id: agency_r;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyR.otf" }

    closePolicy: Popup.NoAutoClose | Popup.CloseOnEscape

    header: ColumnLayout {
        SFText {
            Layout.topMargin: 90
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: 30
            font.family: agency_b.name
            font.letterSpacing: 4
            font.weight: Font.Bold
            font.capitalization: Font.AllUppercase
            //% "Transaction info"
            text: qsTrId("tx-details-popup-title")
            color: 'white'
        }
    }

    contentItem: ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true

        id: stm
        state: "tx_info"
        states: [
            State {
                name: "tx_info";
                PropertyChanges {target: txInfo; state: "active"}
            },
            State {
                name: "payment_proof";
                PropertyChanges {target: paymentProof; state: "active"}
            }
        ]

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 30
            visible:          false//dialog.hasPaymentProof && !dialog.isSelfTx

            Row {
                TxFilter {
                    id: txInfo
                    //% "General info"
                    label: qsTrId("tx-details-general-info")
                    inactiveColor: Style.content_disabled
                    onClicked: stm.state = "tx_info"
                }

                TxFilter {
                    id: paymentProof
                    //% "Payment proof"
                    label: qsTrId("general-payment-proof")
                    inactiveColor: Style.content_disabled
                    onClicked: {
                        if (dialog.hasPaymentProof && getPaymentProof && typeof getPaymentProof == "function") {
                            dialog.paymentInfo = getPaymentProof(dialog.rawTxID);
                            stm.state = "payment_proof";
                        }
                    }
                }
            }
        }

        GridLayout {
            id: grid
            Layout.leftMargin: 50
            Layout.rightMargin: 30
            Layout.topMargin: dialog.hasPaymentProof && !dialog.isSelfTx ? 30 : 40
            Layout.alignment: Qt.AlignTop
            columnSpacing: 40
            rowSpacing: 14
            columns: 1

            RowLayout {
                spacing: 14
                visible: !Utils.isZeroed(dialog.txID) && stm.state == "tx_info"

                SFText {
                    font.pixelSize: 18
                    font.family: agency_r.name
                    color: 'white'
                    font.capitalization: Font.AllUppercase
                    //% "Transaction ID"
                    text: qsTrId("tx-details-tx-id-label") + ":"
                    visible: transactionID.parent.visible
                    font.letterSpacing: 2
                }
                RowLayout {
                    Layout.topMargin: -1
                    visible: !Utils.isZeroed(dialog.txID) && stm.state == "tx_info"
                    SFLabel {
                        Layout.fillWidth: true
                        id: transactionID
                        copyMenuEnabled: true
                        font.pixelSize: 18
                        font.family: agency_b.name
                        font.capitalization: Font.AllUppercase
                        font.weight: Font.Bold
                        color: Style.content_main
                        text: getHighlitedText(dialog.txID)
                        elide: Text.ElideMiddle
                        onCopyText: textCopied(dialog.txID)
                        font.letterSpacing: 2
                    }
                    CustomToolButton {
                        visible: false
                        Layout.alignment: Qt.AlignTop | Qt.AlignRight
                        icon.source: "qrc:/assets/copy-icon.png"
                        onClicked: textCopied(transactionID.text)
                        padding: 0
                        background.implicitHeight: 16
                    }

                    Image {
                        Layout.alignment: Qt.AlignRight
                        //Layout.topMargin: 5

                        source: "qrc:/assets/copy-icon.png"
                        sourceSize: Qt.size(25, 25)
                        //opacity: control.isValid() ? 1.0 : 0.45

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function () {
                                BeamGlobals.copyToClipboard(transactionID.text);
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: 14
                visible: stm.state == "tx_info" && dialog.sendAddress.length && !(isIncome && isShieldedTx)

                SFText {
                    font.pixelSize: 18
                    font.family: agency_r.name
                    color: 'white'
                    font.capitalization: Font.AllUppercase
                    //% "Sending address"
                    text: qsTrId("tx-details-sending-addr-label") + ":"
                    visible: sendAddressField.parent.visible
                    font.letterSpacing: 2
                }
                RowLayout {
                    Layout.topMargin: -1
                    visible: stm.state == "tx_info" && dialog.sendAddress.length && !(isIncome && isShieldedTx)
                    SFLabel {
                        id: sendAddressField
                        Layout.fillWidth: true
                        copyMenuEnabled: true
                        font.pixelSize: 18
                        font.family: agency_b.name
                        font.weight: Font.Bold
                        font.capitalization: Font.AllUppercase
                        color: Style.content_main
                        elide: Text.ElideMiddle
                        text: getHighlitedText(dialog.sendAddress)
                        onCopyText: textCopied(dialog.sendAddress)
                        font.letterSpacing: 2
                    }
                    CustomToolButton {
                        Layout.alignment: Qt.AlignRight
                        icon.source: "qrc:/assets/copy-icon.png"
                        onClicked: textCopied(sendAddressField.text)
                        padding: 0
                        background.implicitHeight: 16
                        visible: false
                    }

                    Image {
                        Layout.alignment: Qt.AlignRight
                        //Layout.topMargin: 5

                        source: "qrc:/assets/copy-icon.png"
                        sourceSize: Qt.size(25, 25)
                        //opacity: control.isValid() ? 1.0 : 0.45

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function () {
                                BeamGlobals.copyToClipboard(sendAddressField.text);
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: 14
                visible: stm.state == "payment_proof" && dialog.senderIdentity.length > 0 && (dialog.receiverIdentity.length > 0 || dialog.isShieldedTx )

                SFText {
                    font.pixelSize: 18
                    font.family: agency_r.name
                    color: 'white'
                    font.capitalization: Font.AllUppercase
                    //% "Sender's wallet signature"
                    text: qsTrId("tx-details-sender-identity") + ":"
                    visible: senderIdentityField.parent.visible
                    font.letterSpacing: 2
                }
                RowLayout {
                    Layout.topMargin: -1
                    visible: stm.state == "payment_proof" && dialog.senderIdentity.length > 0 && (dialog.receiverIdentity.length > 0 || dialog.isShieldedTx )
                    SFLabel {
                        id: senderIdentityField
                        Layout.fillWidth: true
                        copyMenuEnabled: true
                        font.pixelSize: 18
                        font.family: agency_b.name
                        font.capitalization: Font.AllUppercase
                        font.weight: Font.Bold
                        color: Style.content_main
                        elide: Text.ElideMiddle
                        text: getHighlitedText(dialog.senderIdentity)
                        onCopyText: textCopied(dialog.senderIdentity)
                        font.letterSpacing: 2
                    }
                    CustomToolButton {
                        Layout.alignment: Qt.AlignRight
                        icon.source: "qrc:/assets/copy-icon.png"
                        onClicked: textCopied(senderIdentityField.text)
                        padding: 0
                        background.implicitHeight: 16
                    }
                }
            }

            RowLayout {
                spacing: 14
                visible: stm.state == "tx_info" && !dialog.isContractTx && receiveAddressField.receiveAddressOrToken.length

                SFText {
                    font.pixelSize: 18
                    font.family: agency_r.name
                    color: 'white'
                    font.capitalization: Font.AllUppercase
                    //% "Receiving address"
                    text: qsTrId("tx-details-receiving-addr-label") + ":"
                    visible: receiveAddressField.parent.visible
                    font.letterSpacing: 2
                }
                RowLayout {
                    Layout.topMargin: -1
                    visible: stm.state == "tx_info" && !dialog.isContractTx && receiveAddressField.receiveAddressOrToken.length
                    SFLabel {
                        property var receiveAddressOrToken : hasToken ? dialog.token : dialog.receiveAddress
                        id: receiveAddressField
                        Layout.fillWidth: true
                        copyMenuEnabled: true
                        font.pixelSize: 18
                        font.family: agency_b.name
                        font.capitalization: Font.AllUppercase
                        font.weight: Font.Bold
                        color: Style.content_main
                        elide: Text.ElideMiddle
                        text: getHighlitedText(receiveAddressOrToken)
                        onCopyText: textCopied(receiveAddressOrToken)
                        font.letterSpacing: 2
                    }
                    CustomToolButton {
                        visible: false
                        Layout.alignment:Qt.AlignRight
                        icon.source: "qrc:/assets/copy-icon.png"
                        onClicked: textCopied(receiveAddressField.text)
                        padding: 0
                        background.implicitHeight: 16
                    }

                    Image {
                        Layout.alignment: Qt.AlignRight
                        //Layout.topMargin: 5

                        source: "qrc:/assets/copy-icon.png"
                        sourceSize: Qt.size(25, 25)
                        //opacity: control.isValid() ? 1.0 : 0.45

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: function () {
                                BeamGlobals.copyToClipboard(receiveAddressField.text);
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: 14
                visible: stm.state == "payment_proof" && dialog.senderIdentity.length > 0 && dialog.receiverIdentity.length > 0

                SFText {
                    font.pixelSize: 18
                    font.family: agency_r.name
                    color: 'white'
                    font.capitalization: Font.AllUppercase
                    //% "Receiver's wallet signature"
                    text: qsTrId("tx-details-receiver-identity") + ":"
                    visible: receiverIdentityField.parent.visible
                    font.letterSpacing: 2
                }
                RowLayout {
                    Layout.topMargin: -1
                    visible: stm.state == "payment_proof" && dialog.senderIdentity.length > 0 && dialog.receiverIdentity.length > 0
                    SFLabel {
                        id: receiverIdentityField
                        Layout.fillWidth: true
                        copyMenuEnabled: true
                        font.pixelSize: 18
                        font.family: agency_b.name
                        color: Style.content_main
                        font.weight: Font.Bold
                        font.capitalization: Font.AllUppercase
                        elide: Text.ElideMiddle
                        text: getHighlitedText(dialog.receiverIdentity)
                        onCopyText: textCopied(dialog.receiverIdentity)
                        font.letterSpacing: 2
                    }
                    CustomToolButton {
                        Layout.alignment: Qt.AlignRight
                        icon.source: "qrc:/assets/copy-icon.png"
                        onClicked: textCopied(receiverIdentityField.text)
                        padding: 0
                        background.implicitHeight: 16
                    }
                }
            }

            RowLayout {
                spacing: 14
                visible: false
                // Address type
                SFText {
                    Layout.alignment:       Qt.AlignTop
                    font.pixelSize: 18
                    font.family: agency_r.name
                    font.capitalization: Font.AllUppercase
                    color: 'white'
                    //% "Address type"
                    text:                   qsTrId("address-info-type") + ":"
                    //visible:                addrTypeText.visible
                    visible: false
                    font.letterSpacing: 2
                }

                SFText {
                    Layout.topMargin: -1
                    id:                     addrTypeText
                    Layout.fillWidth:       true
                    wrapMode:               Text.Wrap
                    font.pixelSize: 18
                    font.family: agency_b.name
                    font.capitalization: Font.AllUppercase
                    font.weight: Font.Bold
                    text:                   dialog.addressType
                    color:                  Style.content_main
                    //visible:                !dialog.isContractTx && stm.state == "tx_info"
                    visible: false
                    font.letterSpacing: 2
                }
            }

            RowLayout {
                spacing: 14
                visible:          minConfirmationsField.visible

                SFText {
                    Layout.alignment: Qt.AlignTop
                    font.pixelSize: 18
                    font.family: agency_r.name
                    font.capitalization: Font.AllUppercase
                    color: 'white'
                    //% "Confirmation status"
                    text: qsTrId("tx-details-confirmation-status-label") + ":"
                    visible:          minConfirmationsField.visible
                    font.letterSpacing: 2
                }

                SFLabel {
                    Layout.topMargin: -1
                    id:               minConfirmationsField
                    font.pixelSize: 18
                    font.family: agency_b.name
                    font.capitalization: Font.AllUppercase
                    color:            Style.content_main
                    font.weight: Font.Bold
                    //% "Confirmed (%1)"
                    text:             qsTrId("tx-details-confirmation-progress-label").arg(dialog.confirmationsProgress)
                    visible:          dialog.minConfirmations && stm.state == "tx_info"
                    font.letterSpacing: 2
                }
            }

            RowLayout {
                spacing: 14
                visible: !dialog.feeOnly

                SFText {
                    Layout.alignment: Qt.AlignTop
                    font.pixelSize: 18
                    font.family: agency_r.name
                    font.capitalization: Font.AllUppercase
                    color: 'white'
                    //% "Amount"
                    text: qsTrId("tx-details-amount-label") + ":"
                    visible: !dialog.feeOnly
                    font.letterSpacing: 2
                }

                ColumnLayout {
                    Layout.topMargin: -1
                    id: amountsList
                    Layout.fillWidth: true
                    spacing: 10
                    visible: !dialog.feeOnly

                    Repeater {
                        model: dialog.assetCount

                        RowLayout {
                            Layout.fillWidth: true
                            Layout.maximumWidth : dialog.width - 60
                            Layout.maximumHeight: 34

                            BeamAmount {
                                id: amountField
                                Layout.fillWidth: true

                                visible:      true
                                amount:       dialog.assetAmounts ? (dialog.assetAmounts[index] || "") : ""
                                unitName:     dialog.assetNames[index] || ""
                                iconSource:   dialog.assetIcons[index] || ""
                                verified:     dialog.assetVerified[index] || false
                                iconSize:     Qt.size(20, 20)
                                color:        'white'
                                prefix:       this.amount == "0" ? "" : (dialog.assetIncome[index] ? "+ " : "- ")
                                rate:         dialog.assetRates ? (dialog.assetRates[index] || "") : ""
                                rateUnit:     this.rate != "0" ? dialog.rateUnit : ""
                                ratePostfix:  "" /*this.rate != "0"
                                    //% "calculated with the exchange rate at the time of the transaction"
                                    ? "(" + qsTrId("tx-details-rate-notice") + ")"
                                    //% "exchange rate was not available at the time of the transaction"
                                    : "(" + qsTrId("tx-details-exchange-rate-not-available") + ")"*/
                                rateFontSize:     12
                                showTip:          false
                                maxUnitChars:     25
                                maxPaintedWidth:  false
                                iconAnchorCenter: false
                                font.pixelSize: 18
                                font.family: agency_b.name
                                font.weight: Font.Bold
                                font.capitalization: Font.AllUppercase
                                font.letterSpacing: 2
                            }

                            SFText {
                                Layout.alignment: Qt.AlignTop
                                font.pixelSize: 18
                                font.family: agency_b.name
                                color: Style.content_secondary
                                font.capitalization: Font.AllUppercase
                                //% "Confidential asset ID"
                                text: qsTrId("general-ca-id") + ":"
                                font.weight: Font.Bold
                                visible: assetIdField.visible
                                font.letterSpacing: 2
                            }
                            SFLabel {
                                id: assetIdField
                                Layout.alignment: Qt.AlignTop
                                copyMenuEnabled: true
                                font.pixelSize: 18
                                font.family: agency_b.name
                                font.capitalization: Font.AllUppercase
                                font.weight: Font.Bold
                                color: Style.content_main
                                text: dialog.assetIDs[index] || ""
                                onCopyText: textCopied(dialog.assetIDs[index])
                                visible: dialog.assetIDs[index] != "0"
                                font.letterSpacing: 2
                            }
                            CustomToolButton {
                                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                                icon.source: "qrc:/assets/copy-icon.png"
                                onClicked: textCopied(dialog.assetIDs[index])
                                visible: dialog.assetIDs[index] != "0"
                                padding: 0
                                background.implicitHeight: 16
                            }
                        }
                    }
                }
            }

            RowLayout {
                spacing: 14
                visible: dialog.fee.length && stm.state == "tx_info"

                SFText {
                    Layout.alignment: Qt.AlignTop
                    font.pixelSize: 18
                    font.family: agency_r.name
                    color: 'white'
                    //% "Transaction fee"
                    text: qsTrId("general-fee") + ": "
                    visible: feeField.parent.visible
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 2
                }

                RowLayout {
                    Layout.topMargin: -3
                    visible: dialog.fee.length && stm.state == "tx_info"
                    Layout.maximumHeight: !dialog.feeRate.length || dialog.feeRate == "0" ? 20 : 34
                    BeamAmount {
                        id: feeField
                        Layout.fillWidth: true

                        amount:           dialog.fee
                        unitName:         dialog.feeUnit
                        rateUnit:         dialog.feeRateUnit
                        rate:             dialog.feeRate
                        rateFontSize:     12
                        showTip:          false
                        maxPaintedWidth:  false
                        iconSource:       "qrc:/assets/icon-beam.svg"
                        iconSize:         Qt.size(20, 20)
                        iconAnchorCenter: false
                        color:            Style.white
                        font.pixelSize: 18
                        font.family: agency_b.name
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 2
                        font.weight: Font.Bold
                    }
                }
            }

            RowLayout {
                spacing: 14
                visible:                dappNameText.visible
                // CID
                SFText {
                    Layout.alignment:       Qt.AlignTop
                    font.pixelSize: 18
                    font.family: agency_r.name
                    font.capitalization: Font.AllUppercase
                    color: 'white'
                    //% "DAPP name"
                    text:                   qsTrId("address-info-dapp") + ":"
                    visible:                dappNameText.visible
                    font.letterSpacing: 2
                }

                SFLabel {
                    Layout.topMargin: -1
                    id:               dappNameText
                    font.pixelSize: 18
                    font.family: agency_b.name
                    color:            Style.content_main
                    font.capitalization: Font.AllUppercase
                    text:             dialog.dappName
                    elide:            Text.ElideRight
                    copyMenuEnabled:  false
                    visible:          dialog.isContractTx && stm.state == "tx_info"
                    font.weight: Font.Bold
                    font.letterSpacing: 2
                }
            }

            RowLayout {
                spacing: 14
                visible:                cidText.parent.visible
                // CID
                SFText {
                    font.pixelSize: 18
                    font.family: agency_r.name
                    color: 'white'
                    font.capitalization: Font.AllUppercase
                    //% "Application shader ID"
                    text:                   qsTrId("address-info-cid") + ":"
                    visible:                cidText.parent.visible
                    font.letterSpacing: 2
                }

                RowLayout {
                    Layout.topMargin: -1
                    visible:          dialog.isContractTx && stm.state == "tx_info"
                    SFLabel {
                        id:               cidText
                        Layout.fillWidth: true
                        font.pixelSize: 18
                        font.family: agency_b.name
                        color:            Style.content_main
                        font.capitalization: Font.AllUppercase
                        text:             dialog.cidsStr
                        elide:            Text.ElideRight
                        copyMenuEnabled:  true
                        onCopyText:       textCopied(text)
                        font.weight: Font.Bold
                        font.letterSpacing: 2
                    }
                    CustomToolButton {
                        Layout.alignment: Qt.AlignRight
                        icon.source: "qrc:/assets/copy-icon.png"
                        onClicked: textCopied(cidText.text)
                        padding: 0
                        background.implicitHeight: 16
                    }
                }
            }

            RowLayout {
                spacing: 14
                visible: stm.state == "tx_info" && dialog.comment.length

                SFText {
                    Layout.alignment: Qt.AlignTop
                    font.pixelSize: 18
                    font.family: agency_r.name
                    color: 'white'
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 2

                    text: isContractTx ?
                        //% "Description"
                        qsTrId("general-description") + ":" :
                        //% "Comment"
                        qsTrId("general-comment") + ":"

                    visible: commentTx.visible
                }

                SFLabel {
                    Layout.topMargin: -1
                    Layout.fillWidth: true
                    id: commentTx
                    copyMenuEnabled: true
                    font.pixelSize: 18
                    font.family: agency_b.name
                    font.weight: Font.Bold
                    color: Style.content_main
                    font.capitalization: Font.AllUppercase
                    wrapMode: Text.WrapAnywhere
                    text: getHighlitedText(dialog.comment)
                    elide: Text.ElideRight
                    onCopyText: textCopied(dialog.comment)
                    visible: stm.state == "tx_info" && dialog.comment.length
                    font.letterSpacing: 2
                }
            }

            RowLayout {
                spacing: 14
                visible: false
                SFText {
                    font.pixelSize: 18
                    font.family: agency_r.name
                    color: 'white'
                    font.capitalization: Font.AllUppercase
                    //% "Kernel ID"
                    text: qsTrId("general-kernel-id") + ":"
                    //visible: kernelID.parent.visible
                    visible: false
                    font.letterSpacing: 2
                }
                RowLayout {
                    Layout.topMargin: -1
                    //visible: !Utils.isZeroed(dialog.kernelID)
                    visible: false
                    SFLabel {
                        Layout.fillWidth: true
                        id: kernelID
                        copyMenuEnabled: true
                        font.pixelSize: 18
                        font.family: agency_b.name
                        font.capitalization: Font.AllUppercase
                        font.weight: Font.Bold
                        color: Style.content_main
                        text: getHighlitedText(dialog.kernelID)
                        elide: Text.ElideMiddle
                        onCopyText: textCopied(dialog.kernelID)
                        font.letterSpacing: 2
                    }
                    CustomToolButton {
                        Layout.alignment: Qt.AlignRight
                        icon.source: "qrc:/assets/copy-icon.png"
                        onClicked: textCopied(kernelID.text)
                        padding: 0
                        background.implicitHeight: 16
                    }
                }
            }

            Item {
                height: 16
                visible: dialog.isCompleted//dialog.isCompleted && kernelID.parent.visible
            }
            OpenInBlockchainExplorer {
                visible: false
                //visible: dialog.isCompleted //dialog.isCompleted && kernelID.parent.visible
                onTriggered: function(kernelID) {
                    openExternal(dialog.kernelID);
                }
            }

            RowLayout {
                spacing: 14
                visible: stm.state == "tx_info" && dialog.stateDetails.length

                RowLayout {
                    Layout.columnSpan: 2
                    Layout.fillWidth: true
                    visible: stm.state == "tx_info" && dialog.stateDetails.length
                    SvgImage {
                        Layout.alignment: Qt.AlignTop
                        sourceSize: Qt.size(16, 16)
                        source:  "qrc:/assets/icon-attention.svg"
                    }
                    SFLabel {
                        Layout.fillWidth: true
                        copyMenuEnabled: true
                        font.pixelSize: 18
                        font.family: agency_r.name
                        font.capitalization: Font.AllUppercase
                        font.weight: Font.Bold
                        color: Style.content_main
                        wrapMode: Text.Wrap
                        elide: Text.ElideMiddle
                        text: dialog.stateDetails
                        onCopyText: textCopied(text)
                        font.letterSpacing: 2
                    }
                }

                SFText {
                    Layout.topMargin: -1
                    Layout.alignment: Qt.AlignTop
                    font.pixelSize: 18
                    font.family: agency_r.name
                    font.capitalization: Font.AllUppercase
                    color: 'white'
                    //% "Error"
                    text: qsTrId("tx-details-error-label") + ":"
                    visible: dialog.failureReason.length
                    font.letterSpacing: 2
                }
            }

            RowLayout {
                spacing: 14
                visible: dialog.failureReason.length > 0 && stm.state == "tx_info"

                SFLabel {
                    id: failureReason
                    Layout.fillWidth: true
                    copyMenuEnabled: true
                    font.pixelSize: 18
                    font.family: agency_b.name
                    font.weight: Font.Bold
                    color: Style.content_main
                    font.capitalization: Font.AllUppercase
                    wrapMode: Text.Wrap
                    visible: dialog.failureReason.length > 0 && stm.state == "tx_info"
                    text: dialog.failureReason.length > 0 ? dialog.failureReason : ""
                    elide: Text.ElideRight
                    onCopyText: textCopied(text)
                    font.letterSpacing: 2
                }

                Rectangle {
                    Layout.topMargin: -1
                    width: parent.width
                    height: 1
                    color: Style.background_button
                    Layout.columnSpan: 2
                    visible: proofField.visible
                }
            }

            RowLayout {
                spacing: 14
                visible: proofField.visible

                SFText {
                    Layout.alignment: Qt.AlignTop
                    font.pixelSize: 18
                    font.family: agency_r.name
                    font.capitalization: Font.AllUppercase
                    color: 'white'
                    //% "Code"
                    text: qsTrId("payment-info-proof-code-label") + ":"
                    visible: proofField.visible
                    font.letterSpacing: 2
                }

                RowLayout {
                    Layout.topMargin: -1
                    id: proofField
                    visible: stm.state == "payment_proof" && dialog.hasPaymentProof
                    ScrollView {
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth:             true
                        Layout.maximumHeight:         120
                        clip:                         true
                        ScrollBar.horizontal.policy:  ScrollBar.AlwaysOff
                        ScrollBar.vertical.policy:    ScrollBar.AsNeeded
                        SFText {
                            width:              450
                            wrapMode:           Text.Wrap
                            font.pixelSize: 18
                            font.family: agency_b.name
                            font.weight: Font.Bold
                            font.capitalization: Font.AllUppercase
                            text:               paymentInfo ? paymentInfo.paymentProof : ""
                            color:              Style.content_main
                            font.letterSpacing: 2
                        }
                    }

                    CustomToolButton {
                        Layout.alignment: Qt.AlignTop | Qt.AlignRight
                        icon.source: "qrc:/assets/copy-icon.png"
                        onClicked: textCopied(paymentInfo ? paymentInfo.paymentProof : "")
                        padding: 0
                        background.implicitHeight: 16
                    }
                }
            }


            Item {
                height: 100
            }
        }
    }

    footer: ColumnLayout {
        Row {
            bottomPadding: footerBottomPadding
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: 60
            spacing: 20

            CustomButton {
                //% "Close"
                text:               qsTrId("general-close")
                onClicked:          dialog.close()
            }

            CustomButton {
                text:               'Explorer'
                onClicked:          {
                    openExternal(dialog.kernelID);
                }
            }
        }
    }

    onOpened: {
        dialog.height = grid.height + (dialog.hasPaymentProof && !dialog.isSelfTx ? 280 : 200);
    }

    onClosed: {
        dialog.height = 650;
    }
}
