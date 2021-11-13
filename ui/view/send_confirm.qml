import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import "controls"
import "./utils.js" as Utils

ConfirmationDialog {

    FontLoader { id: agency_b;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyB.ttf" }
    FontLoader { id: agency_r;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyR.otf" }

    onVisibleChanged: {
        if (!this.visible) {
            this.destroy();
        }
    }

    id: control
    parent: Overlay.overlay

    property alias  addressText: addressLabel.text
    property alias  typeText:    typeLabel.text
    property bool   isOnline:    true
    property bool   appMode:     false
    property string appName:     ""
    property bool   showPrefix:  false
    property alias  comment:     commentCtrl.text
    property var    amounts
    property var    assetsProvider
    property bool   hasAmounts:  amounts && amounts.length > 0

    property string rateUnit: ""
    property string fee:      "0"
    property string feeRate:  "0"
    property string feeUnit:  BeamGlobals.beamUnit
    property bool   isEnough: true

    readonly property bool isSpend:  {
        for (var idx = 0; idx < amounts.length; ++idx) {
            if (amounts[idx].spend) {
                return true
            }
        }
        return false
    }

    readonly property bool isReceive: {
        for (var idx = 0; idx < amounts.length; ++idx) {
            if (!amounts[idx].spend) {
                return true
            }
        }
        return false
    }

    defaultFocusItem: BeamGlobals.needPasswordToSpend() ? requirePasswordInput : cancelButton
    title: {
        if (control.appMode) {
            if (isReceive && isSpend) {
                //% "Confirm withdraw & deposit"
                return qsTrId("send-app-twoway-confirmation-title")
            }
            if (isSpend) {
                //% "Confirm deposit from the wallet"
                return qsTrId("send-app-spend-confirmation-title")
            }
            if (isReceive) {
                //% "Confirm withdraw to the wallet"
                return qsTrId("send-app-receive-confirmation-title")
            }
            //% "Confirm application transaction"
            return qsTrId("send-app-confirmation-title")
        }
        //% "Confirm transaction details"
        return qsTrId("send-confirmation-title")
    }

    okButtonText: control.appMode ?
        //% "Confirm"
        qsTrId("general-confirm"):
        //% "Send"
        qsTrId("general-send")

    okButtonColor: control.isSpend ? Style.accent_outgoing : Style.accent_incoming
    okButtonIconSource: {
        if (control.appMode) {
            if (control.isSpend && control.isReceive) {
                return "qrc:/assets/icon-send-receive-blue.svg"
            }
            if (control.isSpend) {
                return "qrc:/assets/icon-send-blue.svg"
            }
            return "qrc:/assets/icon-receive-blue.svg"
        }
        return "qrc:/assets/icon-send-blue.svg"
    }

    okButtonEnable: isEnough && (BeamGlobals.needPasswordToSpend() ? !!requirePasswordInput.text : true)
    cancelButtonIconSource: "qrc:/assets/icon-cancel-white.svg"

    beforeAccept: function () {
        if (BeamGlobals.needPasswordToSpend()) {
            if (!requirePasswordInput.text) {
                requirePasswordInput.forceActiveFocus(Qt.TabFocusReason);
                return false
            }

            if (!BeamGlobals.isPasswordValid(requirePasswordInput.text)) {
                requirePasswordInput.forceActiveFocus(Qt.TabFocusReason);
                requirePasswordInput.selectAll();
                requirePasswordError.text = qsTrId("general-pwd-invalid");
                return false
            }
        }
        return true
    }

    topPadding: 50
    backgroundImage: (isEnough && BeamGlobals.needPasswordToSpend()) ? "qrc:/assets/popups/popup-14.png" : "qrc:/assets/popups/popup-6.png"
    width: (isEnough && BeamGlobals.needPasswordToSpend()) ? 704 : 710
    height: (isEnough && BeamGlobals.needPasswordToSpend()) ? 564 : 490
    footerBottomPadding: 95
    cancelButtonWidth: 140
    okButtonWidth: 140

    contentItem: Item { ColumnLayout {
        spacing: 22
        //margins: 20
        Layout.margins: 40
        Layout.fillWidth: true

        ColumnLayout {

            width: 500
            Layout.maximumWidth: 500
            Layout.preferredWidth: 500

            Layout.alignment: Qt.AlignCenter
            anchors.horizontalCenter: parent.horizontalCenter
            Layout.leftMargin: 220

            GridLayout {
                width: 500
                Layout.maximumWidth: 500
                Layout.preferredWidth: 500
                Layout.alignment:  Qt.AlignHCenter
                Layout.fillWidth:  false
                Layout.fillHeight: false
                columnSpacing:     typeLabel.visible ? 14 : 30
                rowSpacing:        14
                columns:           1

                RowLayout {
                    spacing:        14
                    //
                    // Recipient/Address
                    //
                    SFText {
                        font.pixelSize:         18
                        font.family:            agency_r.name
                        color:                  'white'
                        font.capitalization: Font.AllUppercase
                        //% "Recipient"
                        text:                   qsTrId("send-confirmation-recipient-label") + ":"
                        verticalAlignment:      Text.AlignTop
                        visible:                addressLabel.visible
                        font.letterSpacing: 2
                    }

                    SFLabel {
                        Layout.topMargin: -1
                        id:                     addressLabel
                        Layout.maximumWidth:    290
                        wrapMode:               Text.NoWrap
                        elide:                  Text.ElideMiddle
                        font.pixelSize:         18
                        font.family:            agency_b.name
                        color:                  'white'
                        font.capitalization: Font.AllUppercase
                        copyMenuEnabled:        true
                        onCopyText:             BeamGlobals.copyToClipboard(text)
                        visible:                !!text
                        font.letterSpacing: 2
                        font.weight: Font.Bold
                    }
                }


                RowLayout {
                    spacing:        14
                    visible: false
                    //
                    // Comment
                    //
                    SFText {
                        font.pixelSize:         18
                        font.family:            agency_r.name
                        color:                  'white'
                        font.capitalization: Font.AllUppercase
                        //% "Comment"
                        text:              qsTrId("general-comment") + ":"
                        visible:           commentCtrl.visible
                        font.letterSpacing: 2
                    }

                    SFLabel {
                        Layout.topMargin: -1
                        id:                   commentCtrl
                        Layout.maximumWidth:  290
                        wrapMode:             Text.Wrap
                        elide:                Text.ElideRight
                        font.pixelSize:         18
                        font.family:            agency_b.name
                        color:                  'white'
                        font.capitalization: Font.AllUppercase
                        copyMenuEnabled:      true
                        onCopyText:           BeamGlobals.copyToClipboard(text)
                        maximumLineCount:     4
                        visible:              !!text
                        font.letterSpacing: 2
                        font.weight: Font.Bold
                    }
                }


                RowLayout {
                    spacing:        14
                    //
                    // Address type
                    //
                    SFText {
                        font.pixelSize:         18
                        font.family:            agency_r.name
                        color:                  'white'
                        font.capitalization: Font.AllUppercase
                        //% "Transaction type"
                        text:                   qsTrId("send-type-label") + ":"
                        verticalAlignment:      Text.AlignTop
                        visible:                typeLabel.visible
                        font.letterSpacing: 2
                    }

                    SFText {
                        Layout.topMargin: -1
                        id:                     typeLabel
                        Layout.maximumWidth:    290
                        wrapMode:               Text.Wrap
                        maximumLineCount:       2
                        font.pixelSize:         18
                        font.family:            agency_b.name
                        color:                  typeLabel.text.toUpperCase() == 'ANONYMOUS' ? '#17d266' : 'white'
                        font.capitalization: Font.AllUppercase
                        visible:                text.length > 0
                        font.letterSpacing: 2
                        font.weight: Font.Bold
                    }
                }


                RowLayout {
                    spacing:        14
                    //
                    // Amounts
                    //
                    SFText {
                        Layout.alignment: Qt.AlignTop
                        font.pixelSize:         18
                        font.family:            agency_r.name
                        color:                  'white'
                        font.capitalization: Font.AllUppercase
                        //% "Amount"
                        text: qsTrId("general-amount") + ":"
                        font.letterSpacing: 2
                    }

                    SFText {
                        Layout.topMargin: -1
                        Layout.alignment:  Qt.AlignTop
                        Layout.leftMargin: 27
                        font.pixelSize:         18
                        font.family:            agency_b.name
                        color:                  'white'
                        font.capitalization: Font.AllUppercase
                        visible: !control.hasAmounts
                        font.letterSpacing: 2
                        font.weight: Font.Bold

                        text: "-"
                    }

                    ColumnLayout {
                        Layout.topMargin: -1
                        Layout.maximumWidth: 290
                        visible:  control.hasAmounts
                        spacing:  8

                        Repeater {
                            model: control.amounts

                            BeamAmount  {
                                amount:           modelData.amount
                                unitName:         (assetsProvider ? assetsProvider.assets[modelData.assetID] : modelData).unitName
                                rate:             (assetsProvider ? assetsProvider.assets[modelData.assetID] : modelData).rate
                                prefix:           control.showPrefix ? (modelData.spend ? "- " : "+ ") : ""
                                rateUnit:         control.rateUnit
                                maxPaintedWidth:  false
                                maxUnitChars:     7
                                font.pixelSize:   18
                                font.family:      agency_b.name
                                color: 'white'
                                iconSize:         Qt.size(20, 20)
                                iconSource:       (assetsProvider ? assetsProvider.assets[modelData.assetID] : modelData).icon || ""
                                iconAnchorCenter: false
                                verified:         !!(assetsProvider ? assetsProvider.assets[modelData.assetID] : modelData).verified

                                rateFontSize:     12
                                copyMenuEnabled:  true
                                font.letterSpacing: 2
                                font.weight: Font.Bold
                            }
                        }
                    }
                }


                RowLayout {
                    spacing:        14
                    //
                    // Fee
                    //
                    SFText {
                        Layout.alignment: Qt.AlignTop
                        font.pixelSize:         18
                        font.family:            agency_r.name
                        color:                  'white'
                        font.capitalization: Font.AllUppercase
                        //% "Fee"
                        text:             [qsTrId("send-regular-fee"), ":"].join("")
                        font.letterSpacing: 2
                    }

                    ColumnLayout {
                        Layout.topMargin: -1
                        Layout.maximumWidth: 290
                        spacing:  8

                        BeamAmount  {
                            amount:           control.fee
                            unitName:         control.feeUnit
                            rate:             control.feeRate
                            prefix:           control.showPrefix ? (modelData.spend ? "- " : "+ ") : ""
                            rateUnit:         control.rateUnit
                            maxPaintedWidth:  false
                            maxUnitChars:     7
                            font.pixelSize:   18
                            iconSize:         Qt.size(20, 20)
                            iconSource:       assetsProvider ? assetsProvider.assets[0].icon : ""
                            iconAnchorCenter: false
                            color:            'white'
                            font.capitalization: Font.AllUppercase
                            font.family:            agency_b.name
                            rateFontSize:     12
                            copyMenuEnabled:  true
                            font.letterSpacing: 2
                            font.weight: Font.Bold
                        }
                    }
                }
            }

            Rectangle {
                anchors.fill: parent
                //border.width: 3
                //border.color: 'yellow'
                color: 'transparent'
            }
        }

        SFText {
            Layout.topMargin: 8
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter

            visible:  !!text
            color:    !isEnough ? Style.validator_error : Style.content_disabled
            wrapMode: Text.Wrap

            font {
                italic: true
                pixelSize: 14
            }
            font.letterSpacing: 2

            text: {
                //% "There is not enough funds to complete the transaction"
                if (!isEnough) return qsTrId("send-not-enough")

                if (control.appMode) {
                    if (isSpend && isReceive) {
                        //% "%1 will change the balances of your wallet"
                        return qsTrId("send-twoway-warning").arg(control.appName)
                    }

                    if (isSpend) {
                        //% "%1 will take the funds from your wallet"
                        return qsTrId("send-dapp-spend-warning").arg(control.appName)
                    }

                    if (isReceive) {
                        //% "%1 will send the funds to your wallet"
                        return qsTrId("send-dapp-receive-warning").arg(control.appName)
                    }

                    //% "The transaction fee would be deducted from your balance"
                    return qsTrId("send-contract-only-fee")
                }

                return ""
            }
        }

        ColumnLayout {
            SFText {
                id:                   requirePasswordLabel
                visible:              isEnough && BeamGlobals.needPasswordToSpend()
                horizontalAlignment:  Text.AlignHCenter
                Layout.fillWidth:     true
                font.pixelSize:       18
                font.capitalization: Font.AllUppercase
                font.family:      agency_r.name
                font.letterSpacing: 2
                color:                'white'
                //% "To approve the transaction please enter your password"
                text:                 "enter your password to complete the transaction:"
            }

            Column {
                Layout.alignment: Qt.AlignCenter
                width: 400
                Layout.maximumWidth: 400
                Layout.preferredWidth: 400
                spacing: 0
                visible: isEnough && BeamGlobals.needPasswordToSpend()

                SFTextInput {
                    Layout.fillWidth: true
                    id:               requirePasswordInput
                    width:            parent.width
                    font.pixelSize:   14
                    color:            requirePasswordError.text ? Style.validator_error : Style.content_main
                    echoMode:         TextInput.Password
                    dottedBorderColor: 'white'
                    font.family:      agency_r.name
                    font.letterSpacing: 2

                    onAccepted: function () {
                        control.okButton.clicked()
                    }

                    onTextChanged: function () {
                        requirePasswordError.text = ""
                    }
                }

                SFText {
                    id:              requirePasswordError
                    color:           Style.validator_error
                    font.pixelSize:  12
                    font.family:            agency_r.name
                    font.italic:     true
                    font.letterSpacing: 2
                }
            }
        }

        SFText {
            visible: false
            id:                     onlineMessageText
            horizontalAlignment:    Text.AlignHCenter
            Layout.maximumWidth:    420
            font.pixelSize:         14
            color:                  Style.content_disabled
            wrapMode:               Text.WordWrap
            //visible:                isEnough && isOnline
            //% "For the transaction to complete, the recipient must get online within the next 12 hours and you should get online within 2 hours afterwards."
            text:                   qsTrId("send-confirmation-pwd-text-online-time")
            font.letterSpacing: 2
        }
    }

        Rectangle {
            anchors.fill: parent
            //border.width: 1
            //border.color: 'purple'
            color: 'transparent'
        }
    }
}
