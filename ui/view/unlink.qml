import QtQuick 2.11
import QtQuick.Layouts 1.3
import Beam.Wallet 1.0
import "controls"

ColumnLayout {
    id: unlinkView

    // callbacks set by parent
    property var onClosed: undefined

    UnlinkViewModel {
        id: viewModel
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 105
        Layout.preferredHeight: 16
        Layout.maximumHeight: 16

        Item {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            RowLayout {
                spacing: 0
                Image {
                    source:  "qrc:/assets/icon-back.svg"
                    width:   16
                    height:  16
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (unlinkView.onClosed && typeof unlinkView.onClosed == "function") unlinkView.onClosed();
                        }
                    }
                }

                SFText {
                    Layout.leftMargin: 14
                    font.pixelSize:  14
                    font.styleName:  "Bold"; font.weight: Font.Bold
                    color:           Style.content_main
                    //% "back"
                    text:            qsTrId("unlink-back")
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (unlinkView.onClosed && typeof unlinkView.onClosed == "function") unlinkView.onClosed();
                        }
                    }
                }
            }

            SFText {
                anchors.horizontalCenter : parent.horizontalCenter
                font.pixelSize:  14
                font.styleName:  "Bold"
                font.weight: Font.Bold
                font.letterSpacing: 4
                color:           Style.content_main
                //% "UNLINK"
                text:            qsTrId("unlink-title")
            }
        }
    }

    RowLayout {
        Layout.topMargin: 30
        spacing:    10
        Layout.fillWidth: true
        Layout.preferredWidth: unlinkView.width

        //
        // Left column
        //
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignTop

            AmountInput {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width
                //% "AMOUNT"
                title:            qsTrId("unlink-amount-title")
                id:               unlinkAmountInput
                amountIn:         viewModel.unlinkAmount
                secondCurrencyRateValue:    viewModel.secondCurrencyRateValue
                secondCurrencyLabel:        viewModel.secondCurrencyLabel
                setMaxAvailableAmount:      function() { viewModel.setMaxAvailableAmount(); }
                hasFee:           true
                showAddAll:       true
                color:            Style.accent_outgoing
                enableDoubleFrame:  true
                feeFieldFillWidth: true
                // error:            showInsufficientBalanceWarning
                //                   //% "Insufficient funds: you would need %1 to complete the transaction"
                //                   ? qsTrId("send-founds-fail").arg(Utils.uiStringToLocale(viewModel.missing))
                //                   : ""
            }
            Binding {
                target:   viewModel
                property: "unlinkAmount"
                value:    unlinkAmountInput.amount
            }
            Binding {
                target:   viewModel
                property: "feeGrothes"
                value:    unlinkAmountInput.fee
            }
        }
        //
        // Right column
        //
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width / 2
            Layout.alignment: Qt.AlignTop
            GridLayout {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width
                Layout.alignment: Qt.AlignTop
                rowSpacing:          10
                columns:             2

                Rectangle {
                    x:      0
                    y:      0
                    width:  parent.width
                    height: parent.height
                    radius: 10
                    color:  Style.background_second
                }

                SFText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin:       20
                    Layout.leftMargin:      30
                    font.pixelSize:         14
                    color:                  Style.content_secondary
                    //% "Available to unlink:"
                    text:                   qsTrId("unlink-available")
                }

                BeamAmount
                {
                    Layout.fillWidth: true
                    Layout.topMargin:       20
                    // error:                  showInsufficientBalanceWarning
                    amount:                 viewModel.totalToUnlink
                    currencySymbol:         BeamGlobals.getCurrencyLabel(Currency.CurrBeam)
                    secondCurrencyLabel:    viewModel.secondCurrencyLabel
                    secondCurrencyRateValue: viewModel.secondCurrencyRateValue
                }

                SFText {
                    Layout.alignment: Qt.AlignTop
                    Layout.leftMargin:      30
                    font.pixelSize:         14
                    color:                  Style.content_secondary
                    //% "Amount to unlink:"
                    text:                   qsTrId("unlink-amount")
                }

                BeamAmount
                {
                    // error:                  showInsufficientBalanceWarning
                    amount:                 viewModel.unlinkAmount
                    currencySymbol:         BeamGlobals.getCurrencyLabel(Currency.CurrBeam)
                    secondCurrencyLabel:    viewModel.secondCurrencyLabel
                    secondCurrencyRateValue: viewModel.secondCurrencyRateValue
                }

                SFText {
                    Layout.alignment: Qt.AlignTop
                    Layout.leftMargin:      30
                    font.pixelSize:         14
                    color:                  Style.content_secondary
                    text:                   qsTrId("general-change") + ":"
                }

                BeamAmount
                {
                    // error:                  showInsufficientBalanceWarning
                    amount:                 viewModel.change
                    currencySymbol:         BeamGlobals.getCurrencyLabel(Currency.CurrBeam)
                    secondCurrencyLabel:    viewModel.secondCurrencyLabel
                    secondCurrencyRateValue: viewModel.secondCurrencyRateValue
                }

                SFText {
                    Layout.alignment: Qt.AlignTop
                    Layout.leftMargin:      30
                    font.pixelSize:         14
                    color:                  Style.content_secondary
                    //% "Fee:"
                    text:                   qsTrId("unlink-fee")
                }

                BeamAmount
                {
                    // error:                  showInsufficientBalanceWarning
                    amount:                 viewModel.feeGrothes
                    currencySymbol:         qsTrId("general-groth")
                    secondCurrencyLabel:    viewModel.secondCurrencyLabel
                    secondCurrencyRateValue: viewModel.secondCurrencyRateValue / 100000000
                }

                SFText {
                    Layout.alignment: Qt.AlignTop
                    Layout.leftMargin:      30
                    Layout.bottomMargin:    20
                    font.pixelSize:         14
                    color:                  Style.content_secondary
                    text:                   qsTrId("general-remaining-label") + ":"
                }

                BeamAmount
                {
                    Layout.bottomMargin:    20
                    // error:                  showInsufficientBalanceWarning
                    amount:                 viewModel.remaining
                    currencySymbol:         BeamGlobals.getCurrencyLabel(Currency.CurrBeam)
                    secondCurrencyLabel:    viewModel.secondCurrencyLabel
                    secondCurrencyRateValue: viewModel.secondCurrencyRateValue
                }
            }
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 30
        SFText {
            font.pixelSize:  14
            color:           Style.content_secondary
            font.italic: true
            //% "Please notice that unlinking funds may take up to few days to proceed."
            text: qsTrId("unlink-notice")
        }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 10
        SFText {
            font.pixelSize:  14
            color:           Style.content_main
            text:            "Estimated time: 2 days 5 hours"
        }
    }

    PrimaryButton {
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 20
        Layout.preferredHeight: 38
        //% "unlink"
        text: qsTrId("unlink-confirm-button")
        icon.source: "qrc:/assets/icon-unlink-black.svg"
        onClicked: {
            console.log("unlink accepted");
        }
    }

    Item {
        Layout.fillHeight: true
    }
}
