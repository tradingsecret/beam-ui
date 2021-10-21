import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
import QtQuick.Window 2.2
import "controls"
import Beam.Wallet 1.0
import "utils.js" as Utils

Rectangle {
    id: main

    property var    openedNotifications: 0
    property var    notificationOffset: 0
    property alias  hasNewerVersion : updateInfoProvider.hasNewerVersion
    readonly property bool devMode: viewModel.isDevMode
    anchors.fill:   parent

    function increaseNotificationOffset(popup) {
        popup.verticalOffset = main.notificationOffset
        main.notificationOffset += popup.height + 10
        popup.nextVerticalOffset = main.notificationOffset
    }

    function decreaseNotificationOffset(popup) {
        main.notificationOffset -= (popup.nextVerticalOffset - popup.verticalOffset)
        if (main.notificationOffset < 0) main.notificationOffset = 0
    }

    function showPopup(popup) {
        increaseNotificationOffset(popup)
        popup.closed.connect(function () {
            if (main) {
                main.decreaseNotificationOffset(popup)
            }
        })
        popup.open();
    }

    function showSimplePopup(message) {
        var popup = Qt.createComponent("controls/SimpleNotification.qml").createObject(main, {
            message
        })
        showPopup(popup)
    }

    function showAppTxPopup (comment, appname, appicon, txid) {
        var popup = Qt.createComponent("controls/AppTxNotification.qml").createObject(main, {
            comment, appname, appicon, txid
        })
        showPopup(popup)
    }

    function showUpdatePopup (newVersion, currentVersion, id) {
         var popup = Qt.createComponent("controls/UpdateNotification.qml").createObject(main, {
            title: ["New version v", newVersion, "is avalable"].join(" "),
            message: ["Your current version is v", currentVersion, ".Please update to get the most of your Beam wallet."].join(" "),
            acceptButtonText: "update now",
            onCancel: function () {
                updateInfoProvider.onCancelPopup(id);
                popup.close();
            },
            onAccept: function () {
                Utils.navigateToDownloads();
            }
         });
         showPopup(popup)
    }

    PushNotificationManager {
        id: updateInfoProvider
        onShowUpdateNotification: function (newVersion, currentVersion, id) {
            showUpdatePopup (newVersion, currentVersion, id)
        }
    }

    ConfirmationDialog {
        id:                     closeDialog
        //% "Beam wallet close"
        title:                  qsTrId("app-close-title")
        //% "There are %1 active transactions that might fail if the wallet will go offline. Are you sure to close the wallet now?"
        text:                   qsTrId("app-close-text").arg(viewModel.unsafeTxCount)
        //% "yes"
        okButtonText:           qsTrId("atomic-swap-tx-yes-button")
        okButtonIconSource:     "qrc:/assets/icon-done.svg"
        okButtonColor:          Style.swapStateIndicator
        //% "no"
        cancelButtonText:       qsTrId("atomic-swap-no-button")
        cancelButtonIconSource: "qrc:/assets/icon-cancel-16.svg"
        
        onOpened: {
            closeDialog.visible = Qt.binding(function(){return viewModel.unsafeTxCount > 0;});
        }

        onClosed: {
            closeDialog.visible = false;
        }

        onAccepted: {
            Qt.quit();
        }
        modal: true
    }

    SeedValidationHelper { id: seedValidationHelper }

    function onClosing (close) {
        if (viewModel.unsafeTxCount > 0) {
            close.accepted = false;
            closeDialog.open();
        }
    }

    property color topColor: Style.background_main_top
    property color topGradientColor: Qt.rgba(Style.background_main_top.r, Style.background_main_top.g, Style.background_main_top.b, 0)


    StatusbarViewModel {
        id: statusbarModel
    }

    property var backgroundRect: mainBackground
    property var backgroundLogo: mainBackgroundLogo

    Rectangle {
        id: mainBackground
        anchors.fill: parent
        color: '#00000d'

        //Rectangle {
        //    anchors.left: parent.left
        //    anchors.right: parent.right
            //height: 230
            // gradient: Gradient {
            //     GradientStop { position: 0.0; color: main.topColor }
            //    GradientStop { position: 1.0; color: main.topGradientColor }
            //}
        //    color: '#00000d'
        //}

        //BgLogo {
        //    id: mainBackgroundLogo
        //    anchors.leftMargin: sidebar.width
        //}
    }

    MouseArea {
        id: mainMouseArea
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        hoverEnabled: true
        propagateComposedEvents: true
        onMouseXChanged: resetLockTimer()
        onPressedChanged: resetLockTimer()
    }

    Keys.onReleased: {
        resetLockTimer()
    }

    function appsQml () {
        return BeamGlobals.isFork3() ? "applications" : "applications_nofork"
    }

    function appArgs (name, appid, showBack) {
        return {
            "appToOpen": { name, appid},
            showBack
        }
    }

    property var contentItems : [
        {name: "wallet", title: "Wallet", active: true},
        {name: "atomic_swap", title: "Atomic Swaps", active: false},
        {name: "atlasdex", title: "Atlas dex", active: true},
        {name: "daocore", qml: appsQml, title: "Dao", active: false},
        //{name: "applications", qml: appsQml, title: "Atomic Swaps"},
        //{name: "dex"},
        {name: "addresses", title: "Address book", active: true},
        {name: "notifications", title: "Notifications", active: true},
        {name: "settings", title: "Settings", active: true},
        {name: "settings_old", title: "Settings Old", active: true},
        {name: "connect", title: "Assets", active: false}
    ]

    property int selectedItem: -1

    ColumnLayout {
        Item {
           // Layout.fillWidth: true
            Layout.leftMargin: 40
            Layout.rightMargin: 40
            width: parent.parent.width - 80

            RowLayout {
                Layout.fillWidth: true
                spacing: 0
                width: parent.width

                Repeater {
                    id: controls
                    model: contentItems

                    ColumnLayout {
                        id: control

                        SFText {
                            id: menu_item
                            leftPadding: 15
                            rightPadding: 15
                            topPadding: 15
                            bottomPadding: 20
                            text:             modelData.title
                            font.pixelSize: 14
                            color: modelData.active ? ((selectedItem == index || mouseArea.containsMouse) ? '#5fe795' : '#fff') : '#817272'
                            font.capitalization: Font.AllUppercase
                            font.letterSpacing: 1

                            Keys.onPressed: {
                                if (modelData.name == 'atlasdex') {
                                    Utils.navigateToAtlasDex();
                                }
                                else if (modelData.name != 'daocore' && modelData.name != 'connect' && modelData.name != 'atomic_swap') {
                                    if ((event.key == Qt.Key_Return || event.key == Qt.Key_Enter || event.key == Qt.Key_Space))
                                    if (selectedItem != index) {
                                        updateItem(index);
                                    }
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                enabled: true
                                onClicked: {
                                    if (modelData.name == 'atlasdex') {
                                        Utils.navigateToAtlasDex();
                                    }
                                    else if (modelData.name != 'daocore' && modelData.name != 'connect' && modelData.name != 'atomic_swap') {
                                        //control.focus = true
                                        if (selectedItem != index) {
                                            updateItem(index);
                                        }
                                    }
                                }
                                hoverEnabled: true
                                cursorShape: Qt.ArrowCursor
                            }
                        }

                        Item {
                            Rectangle {
                                id: indicator
                                anchors.fill: menu_item
                                y: 43
                                height: 3
                                width: menu_item.width
                                color: selectedItem == index ? '#5fe795' : Style.passive
                            }

                            //DropShadow {
                            //    anchors.fill: indicator
                            //    radius: 5
                            //    samples: 9
                            //    color: Style.active
                            //    source: indicator
                            //}

                            visible: selectedItem == index
                        }
                    }
                }
            }
        }

        //BorderImage {
            //anchors.topMargin: 50
        //    Layout.topMargin: 38
        //    width: parent.width
       //     source:  "qrc:/assets/menu-line.png"
       //     border.top: 1
       //     horizontalTileMode: BorderImage.Stretch
       //     verticalTileMode: BorderImage.Stretch
        //}

        Rectangle {
            Layout.topMargin: 41
            width: parent.parent.width
            Layout.fillWidth: true
            height: 1
            color: '#307451'
        } 
   }

    Loader {
        id: content
        anchors.topMargin: 45
        anchors.bottomMargin: 49
        anchors.rightMargin: 40
        anchors.leftMargin: 40
        focus: true
        anchors.fill: parent
        Layout.fillHeight: true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.rightMargin: 40
        anchors.leftMargin: 40

        Item {
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.bottomMargin: 5

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
                Layout.bottomMargin: 3
                Image {
                    Layout.alignment: Qt.AlignVCenter

                    source: {
                         "qrc:/assets/status-offline.png"
                    }
                }
            }

            ColumnLayout {
                Layout.bottomMargin: 3
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
                Layout.bottomMargin: 3
                Image {
                    Layout.alignment: Qt.AlignVCenter

                    source: {
                         "qrc:/assets/status-online.png"
                    }
                }
            }

            ColumnLayout {
                Layout.bottomMargin: 3
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

    function updateItem(indexOrID, props)
    {
        var update = function(index) {
            var sameTab = selectedItem == index;

            selectedItem = index
            controls.itemAt(index).focus = true;

            var item   = contentItems[index]
            var source = ["qrc:/", item.qml ? item.qml() : item.name, ".qml"].join('')
            var args   = item.args ? item.args() : {}

            content.setSource(source, Object.assign(args, props))
            viewModel.update(index)
        }

        if (typeof(indexOrID) == "string") {
            for (var index = 0; index < contentItems.length; index++) {
                if (contentItems[index].name == indexOrID) {
                    indexOrID = index
                }
            }
        }

        // here we always have a number
        update(indexOrID)
    }

    function openMaxPrivacyCoins (assetId, unitName, lockedAmount) {
        var details = Qt.createComponent("controls/MaxPrivacyCoinsDialog.qml").createObject(main, {
            "unitName":     unitName,
            "lockedAmount": lockedAmount,
            "assetId":      assetId,
       });
       details.open()
    }

    function openWallet () {
        updateItem("wallet")
    }
    function openSendDialog(receiver) {
        updateItem("wallet", {"openSend": true, "token" : receiver})
    }

    function openReceiveDialog(token) {
        updateItem("wallet", {"openReceive": true, "token" : token})
    }

    function openSwapSettings(coinID) {
        updateItem("settings", {swapMode: typeof(coinID) == "string" ? coinID : "ALL"})
    }

    function openSwapActiveTransactionsList() {
        updateItem("atomic_swap", {"shouldShowActiveTransactions": true})
    }

    function openTransactionDetails(id) {
        updateItem("wallet", {"openedTxID": id})
    }

    function openDAppTransactionDetails(txid) {
        if (content.item.openAppTx) {
            return content.item.openAppTx(txid)
        }
        updateItem("applications", {"openedTxID": txid})
    }

    function openSwapTransactionDetails(id) {
        updateItem("atomic_swap", {"openedTxID": id})
    }

    function openApplications () {
        updateItem("applications")
    }

    function resetLockTimer() {
        viewModel.resetLockTimer();
    }

    function openFaucet () {
        var args = appArgs("BEAM Faucet", viewModel.faucetAppID, false);
        updateItem("applications", args);
    }

    function validationSeedBackToSettings() {
        updateItem("settings", { "settingsPrivacyFolded": false});
    }

    property var trezor_popups : []

    Connections {
        target: viewModel
        function onGotoStartScreen () {
            main.parent.setSource("qrc:/start.qml", {"isLockedMode": true});
        }

        function onShowTrezorMessage () {
            var popup = Qt.createComponent("popup_message.qml").createObject(main)
            //% "Please, look at your Trezor device to complete actions..."
            popup.message = qsTrId("trezor-message")
            popup.open()
            trezor_popups.push(popup)
        }

        function onHideTrezorMessage () {
            console.log("onHideTrezorMessage")
            if (trezor_popups.length > 0) {
                var popup = trezor_popups.pop()
                popup.close()
            }
        }

        function onShowTrezorError (error) {
            console.log(error)
            var popup = Qt.createComponent("popup_message.qml").createObject(main)
            popup.message = error
            popup.open()
            trezor_popup.push(popup)
        }
    }

    Component.onCompleted: {
        if (seedValidationHelper.isTriggeredFromSettings)
            validationSeedBackToSettings();
        else
            openWallet();
        main.Window.window.closing.connect(onClosing);
    }

    Component.onDestruction: {
        main.Window.window.closing.disconnect(onClosing)
    }
}
