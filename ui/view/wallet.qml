import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import "controls"
import "wallet"
import "utils.js" as Utils

Item {
    id: root
    anchors.fill: parent

    SwapOffersViewModel {
        id: viewModelSwap
    }

    AssetsViewModel {
        id: viewModelAssets
    }

    property string openedTxID: ""
    
    function onAccepted() { walletStackView.pop(); }
    function onClosed() {
        walletStackView.pop();
       // wallet_title.text = qsTrId("wallet-title");
    }
    function onSwapToken(token) {
        tokenDuplicateChecker.checkTokenForDuplicate(token);
    }

    WalletViewModel {
        id: viewModel
    }

    property bool openSend:     false
    property bool openReceive:  false
    property string token:      ""

    TokenDuplicateChecker {
        id: tokenDuplicateChecker
        onAccepted: {
            walletStackView.pop();
            main.openSwapActiveTransactionsList()
        }
        Connections {
            target: tokenDuplicateChecker.model

            function onTokenPreviousAccepted (token) {
                tokenDuplicateChecker.isOwn = false
                tokenDuplicateChecker.open()
            }

            function onTokenFirstTimeAccepted (token) {
                walletStackView.pop()
                walletStackView.push(Qt.createComponent("send_swap.qml"),
                                     {
                                         "onAccepted": tokenDuplicateChecker.onAccepted,
                                         "onClosed":   onClosed,
                                         "swapToken":  token
                                     })
                walletStackView.currentItem.validateCoin()
            }

            function onTokenOwnGenerated (token) {
                tokenDuplicateChecker.isOwn = true
                tokenDuplicateChecker.open()
            }
        }
    }
    
    Component {
        id: walletLayout

        ColumnLayout {
            id: transactionsLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            function navigateSend(assetId) {
               // wallet_title.text = qsTrId("wallet-send-title")

                var params = {
                    "onAccepted":    onAccepted,
                    "onClosed":      onClosed,
                    "onSwapToken":   onSwapToken,
                    "receiverToken": root.token,
                    "assetId":       assetId
                }

                if (assetId != undefined)
                {
                    params["assetId"] = assetId >= 0 ? assetId : 0
                }

                walletStackView.push(Qt.createComponent("send_regular.qml"), params)
                root.token = ""
            }

            function navigateReceive(assetId) {
               // wallet_title.text = qsTrId("wallet-receive-main-title")

                walletStackView.push(Qt.createComponent("receive_regular.qml"),
                                        {"onClosed": onClosed,
                                         "token":    root.token,
                                         "assetId":  assetId})
                token = ""
            }

            AssetsPanel {
                id: assets
                Layout.topMargin: 25
                Layout.fillWidth: true
                showFaucetPromo: false
                hideSeedValidationPromo: true

                Binding {
                    target:    txTable
                    property:  "selectedAsset"
                    value:     assets.selectedId
                }

                visible: false
            }

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
                        enabled: true
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

                CustomButton {
                    height: 43
                    width: 440
                    Layout.fillWidth: true
                    Layout.topMargin: 10
                    palette.button: Style.accent_incoming
                    palette.buttonText: Style.content_opposite
                    hoveredBorderColor: '#1aa853'
                    //% "Receive"
                    text: "Get testnet arcs"
                    onClicked: {
                        Utils.getFaucet();
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

            ColumnLayout {
                Layout.topMargin: assets.folded ? 25 : 35

                SFText {
                    Layout.topMargin: 10
                    //Layout.fillWidth: true
                    Layout.alignment: Qt.AlignTop | Qt.AlignCenter

                    font {
                        pixelSize: 18
                    }

                    color: '#585858'
                    //% "Transactions"
                    text: qsTrId("wallet-transactions-title")
                }

                TxTable {
                    Layout.leftMargin: 10
                    Layout.rightMargin: 10
                    Layout.bottomMargin: 10
                    id:    txTable
                    owner: root

                    //Layout.topMargin:  12
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                }

                Rectangle {
                    anchors.fill: parent
                    border.color: '#112a26'
                    border.width: 1
                    color: 'transparent'
                }
            }
        }
    }

    StackView {
        id: walletStackView
        anchors.fill: parent
        initialItem: walletLayout
        pushEnter: Transition {
            enabled: false
        }
        pushExit: Transition {
            enabled: false
        }
        popEnter: Transition {
            enabled: false
        }
        popExit: Transition {
            enabled: false
        }
        onCurrentItemChanged: {
            if (currentItem && currentItem.defaultFocusItem) {
                walletStackView.currentItem.defaultFocusItem.forceActiveFocus();
            }
        }
    }

    Component.onCompleted: {
        if (root.openSend) {
            var item = walletStackView.currentItem;
            if (item && item.navigateSend && typeof item.navigateSend == "function" ) {
                item.navigateSend();
                root.openSend = false;
            }
        }
        else if (root.openReceive) {
            var item = walletStackView.currentItem;
            if (item && item.navigateReceive && typeof item.navigateReceive == "function" ) {
                item.navigateReceive();
                root.openReceive = false;
            }
        }
    }

    Component.onDestruction: {
        var item = walletStackView.currentItem;
        if (item && item.saveAddress && typeof item.saveAddress == "function") {
            item.saveAddress();
        }
    }
}
