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

            Row {
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 30
                spacing: 20
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
                Layout.topMargin: 10
                spacing: 20
                visible: true

                SFText {
                    text: viewModelSwap.beamAvailable + ' ARC'
                    color: '#5fe795'
                    font.pixelSize: 30
                    font.capitalization: Font.AllUppercase
                }
            }

            Row {
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 30
                spacing: 20

                CustomButton {
                    height: 38
                    id: sendButton
                    palette.button: Style.accent_outgoing
                    palette.buttonText: Style.content_opposite
                    //% "Send"
                    text: qsTrId("general-send")
                    onClicked: {
                        navigateSend(assets.selectedId);
                    }
                    width: 200
                }

                CustomButton {
                    height: 38
                    palette.button: Style.accent_incoming
                    palette.buttonText: Style.content_opposite
                    //% "Receive"
                    text: qsTrId("wallet-receive-button")
                    onClicked: {
                        navigateReceive(assets.selectedId);
                    }
                    width: 200
                }
            }

            Row {
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 15

                CustomButton {
                    height: 38
                    palette.button: Style.accent_incoming
                    palette.buttonText: Style.content_opposite
                    //% "Receive"
                    text: "Get testnet arcs"
                    onClicked: {
                        Utils.getFaucet();
                    }
                    width: 420
                }
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

                    opacity: 0.5
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

            RowLayout {
                Layout.fillHeight: true
                Layout.topMargin: 12

                ColumnLayout {
                    Image {
                        fillMode: Image.PreserveAspectCrop
                        source: {
                             "qrc:/assets/ins-logo-2.png"
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    Item {
                        Layout.fillWidth: true
                    }
                }

                ColumnLayout {
                    Layout.bottomMargin: 10
                    Image {
                        Layout.alignment: Qt.AlignVCenter

                        source: {
                             "qrc:/assets/status-offline.png"
                        }
                    }
                }

                ColumnLayout {
                    Layout.bottomMargin: 10
                    SFText {
                        Layout.alignment: Qt.AlignVCenter

                        Layout.rightMargin: 15
                        color: '#7d7d7d'
                        text: 'Mainnet offline'
                        font.capitalization: Font.AllUppercase
                        font.pixelSize: 12
                        font.letterSpacing: 1
                    }
                }

                ColumnLayout {
                    Layout.bottomMargin: 10
                    Image {
                        Layout.alignment: Qt.AlignVCenter

                        source: {
                             "qrc:/assets/status-online.png"
                        }
                    }
                }

                ColumnLayout {
                    Layout.bottomMargin: 10
                    SFText {
                        Layout.alignment: Qt.AlignVCenter

                        color: '#ffffff'
                        text: 'Testnet online'
                        font.capitalization: Font.AllUppercase
                        font.pixelSize: 12
                        font.letterSpacing: 1
                    }
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
