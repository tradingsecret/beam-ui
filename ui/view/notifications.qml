import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.12
import "controls"
import "wallet"
import "utils.js" as Utils
import Beam.Wallet 1.0

ColumnLayout {
    id: control
    anchors.fill: parent
    spacing: 0


    NotificationsViewModel {
        id: viewModel
    }

    TransactionDetailsPopupNotifications {
        id: txDetailsNotifications
        onTextCopied: function(text) {
            BeamGlobals.copyToClipboard(text);
        }
        onOpenExternal: function(kernelID) {
            var url = BeamGlobals.getExplorerUrl() + "block?kernel_id=" + kernelID;
            Utils.openExternalWithConfirmation(url, undefined, true);
        };
    }

    property var notificationsList: SortFilterProxyModel {
        source: viewModel.notifications
        sortOrder: Qt.DescendingOrder
        sortCaseSensitivity: Qt.CaseInsensitive
        sortRole: "timeCreatedSort"
    }


    property var notificationsArray: [];
    
    /*CustomButton {
        Layout.alignment: Qt.AlignRight | Qt.AlignTop
        Layout.preferredHeight: 38
        Layout.bottomMargin: 10
        palette.button: Style.background_second
        palette.buttonText : Style.content_main
        icon.source: "qrc:/assets/icon-cancel-white.svg"
        //% "clear all"
        text: qsTrId('notifications-clear-all')
        visible: notificationList.model.count > 0
        onClicked: {
            viewModel.clearAll();
        }
    }*/

    Repeater {
        model: notificationsList

        ColumnLayout {
            Layout.maximumHeight: 0
            Component.onCompleted: {
                notificationsArray.push(model);
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: notificationList.model.count == 0

        SFText {
            Layout.topMargin:     48
            Layout.bottomMargin:  20
            Layout.alignment:     Qt.AlignHCenter
            horizontalAlignment:  Text.AlignHCenter
            font.capitalization:  Font.AllUppercase
            font.pixelSize:       18
            color:                'white'
            //lineHeight:           1.43
            /*% "There are no notifications yet."*/
            text:                 "All notifies"
        }

        ColumnLayout {
            Layout.fillWidth: true

            Item {
                Layout.fillWidth: true
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

    ColumnLayout {
        visible: notificationList.model.count > 0

        SFText {
            Layout.topMargin:     48
            Layout.bottomMargin:  20
            Layout.alignment:     Qt.AlignHCenter
            horizontalAlignment:  Text.AlignHCenter
            font.capitalization:  Font.AllUppercase
            font.pixelSize:       18
            color:                'white'
            //lineHeight:           1.43
            /*% "There are no notifications yet."*/
            text:                 "All notifies"
        }

        ColumnLayout {
            ColumnLayout {
                //Layout.topMargin: 2
                Layout.margins: 15
                Layout.rightMargin: 5
                Layout.bottomMargin: 0

                ListView {
                    id: notificationList
                    Layout.fillWidth: true
                    Layout.fillHeight: true //notificationList.model.count <= notificationList.loadedCnt
                    height: 525
                    boundsMovement: Flickable.StopAtBounds
                    boundsBehavior: Flickable.StopAtBounds

                    //property var loadedCnt: 4

                    model: notificationsList
                    spacing: 0 // we emulate spacings with margins to avoid Flickable drag effect
                    clip: true

                    //! [transitions]
                    add: Transition {
                        NumberAnimation { property: "opacity"; from: 0; to: 1.0; easing.type: Easing.InOutQuad }
                    }
                    remove: Transition {
                        NumberAnimation { property: "opacity"; to: 0; easing.type: Easing.InOutQuad }
                    }

                    displaced: Transition {
                        SequentialAnimation {
                            PauseAnimation { duration: 125 }
                            NumberAnimation { property: "y"; easing.type: Easing.InOutQuad }
                        }
                    }
                    //! [transitions]

                    ScrollBar.vertical: ScrollBar {
                        id: notificationScrollBar
                        hoverEnabled: true
                        policy: ScrollBar.AsNeeded

                        contentItem: Rectangle {
                                radius: implicitHeight/2
                                color: notificationScrollBar.hovered || notificationScrollBar.pressed ? "#aff3ca"  : "#307451"
                                width: 15 // This will be overridden by the width of the scrollbar
                                height: 10 // This will be overridden based on the size of the scrollbar
                            }

                            //size: (songGrid.height) / (songGrid.flickableItem.contentItem.height)
                            width: 15
                    }

                    section.property: "state"
                    /*section.delegate: Item {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        property bool isRead: section == "read"
                        height: isRead ? 24 : 0

                        SFText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            //% "read"
                            text: qsTrId("notifications-read")
                            font.pixelSize: 12
                            color: Style.section
                            font.capitalization: Font.AllUppercase
                            visible: parent.isRead
                        }
                    }*/

                    delegate: Item {
                        id: notification_item
                        //visible: index+1 <= notificationList.loadedCnt
                        visible: true
                        anchors.left: parent ? parent.left : 0
                        anchors.right: parent ? parent.right : 500
                        //height: index+1 <= notificationList.loadedCnt ? 121+10 : 0
                        height: 121+10

                        property bool isUnread: model.state == "unread"

                        Rectangle {
                            id: itemRect
                            anchors.topMargin: index == 0 ? 2 : 0
                            anchors.bottomMargin: 10
                            anchors.rightMargin: 18
                            radius: 0
                            anchors.fill: parent
                            //color: parent.isUnread ? '#effdf4' : 'transparent'
                            color: 'transparent'
                            //border.color: '#b6f4ce'
                            //border.width: 0.5
                            //opacity: (parent.isUnread) ? 0.5 : 1

                            Image {
                                anchors.fill: parent
                                fillMode: Image.Stretch
                                source: notification_item.isUnread ? "qrc:/assets/notify-bg-unread.png" : "qrc:/assets/notify-bg-read.png"
                            }
                        }

                        MouseArea { // avoid Flickable drag effect
                            anchors.fill: parent
                            onPressed : {
                                notificationList.interactive = false;
                            }
                            onReleased : {
                                notificationList.interactive = true;
                            }
                        }

                        Timer {
                            id: readTimer
                            running: parent.isUnread
                            interval: 10000
                            onTriggered: {
                                viewModel.markItemAsRead(model.rawID);
                            }
                        }

                        RowLayout {
                            anchors.top: itemRect.top
                            anchors.left: itemRect.left
                            anchors.topMargin: 10
                            anchors.leftMargin: 10
                           // Layout.bottomMargin: 5

                            Image {
                                fillMode: Image.Stretch
                                source: {
                                     "qrc:/assets/completed-icon.png"
                                }
                                sourceSize: Qt.size(40, 40)
                            }

                            Item {
                                width: 3
                            }

                            SFText {
                                text: 'Completed'
                                font.capitalization: Font.AllUppercase
                                font.pixelSize: 18
                                color: '#0b7d3b'
                            }
                        }

                        ColumnLayout {
                            anchors.bottom: itemRect.bottom
                            anchors.left: itemRect.left
                            anchors.bottomMargin: 10
                            anchors.leftMargin: 10
                            spacing: 0

                            SFText {
                                text: model.amount + " " + model.coin
                                font.pixelSize: 18
                                color: '#fff'
                            }

                            SFText {
                                text: type == 'maxpReceived' || type == 'maxpSent' || type == 'maxpFailedToSend' ? 'Anonymous transaction' :  "TXID: " + model.txid
                                font.pixelSize: 18
                                color: '#fff'
                            }
                        }

                        /*
                        CustomToolButton {
                            anchors.top: itemRect.top
                            anchors.right: itemRect.right
                            anchors.topMargin: 12
                            anchors.rightMargin: 12
                            padding: 0

                            icon.source: "qrc:/assets/icon-cancel-white.svg"
                            onClicked: {
                                viewModel.removeItem(model.rawID);
                            }
                            onPressed : { // avoid Flickable drag effect
                                notificationList.interactive = false;
                            }
                            onReleased : {
                                notificationList.interactive = true;
                            }
                        }*/

                        ColumnLayout {
                            anchors.top: itemRect.top
                            anchors.right: itemRect.right
                            anchors.topMargin: 10
                            anchors.rightMargin: 10
                            spacing: 0

                            SFText {
                                Layout.alignment: Qt.AlignRight
                                text: dateCreated
                                font.pixelSize: 16
                                font.letterSpacing: 2
                                color: '#767676'
                                //opacity: 0.5
                            }

                            SFText {
                                Layout.alignment: Qt.AlignRight
                                text: timeCreated
                                font.pixelSize: 16
                                font.letterSpacing: 2
                                color: '#767676'
                                //opacity: 0.5
                            }
                            Item {
                                Layout.fillWidth: true
                            }
                        }

                        Image {
                            anchors.top: itemRect.top
                            anchors.right: itemRect.right
                            anchors.rightMargin: 190
                            anchors.topMargin: 20
                            fillMode: Image.Stretch
                            source: {
                                 "qrc:/assets/anonymity-icon.png"
                            }
                            //sourceSize: Qt.size(25, 25)
                            visible: type == 'maxpReceived' || type == 'maxpSent' || type == 'maxpFailedToSend'
                        }

                        CustomButton {
                            id:             actionButton
                            anchors.bottom: itemRect.bottom
                            anchors.right: itemRect.right
                            anchors.bottomMargin: 10
                            anchors.rightMargin: 15
                            width: 170

                            height: 36
                            palette.button: Style.background_second
                            palette.buttonText : Style.content_main
                            text: 'Show info'//getActionButtonLabel(type)
                            font.pixelSize: 13
                            //font.weight: Font.Bold
                            font.letterSpacing: 1
                            customColor: '#b4b4b4'

                            border.color: '#b6f4ce'
                            border.width: 1

                            hasShadow: false
                            disableRadius: true
                            radius: 0

                            background: Rectangle {
                                id:         rect
                                color:      "transparent"

                                Image {
                                    anchors.fill: parent
                                    fillMode: Image.Stretch
                                    source: {
                                         actionButton.hovered ? "qrc:/assets/show-info-hover.png" :  "qrc:/assets/show-info-default.png"
                                    }
                                }
                            }

                            visible: getActionButtonLabel(type) != undefined
                            enabled: control.notifications[type].action != null

                            onClicked: {
                                if (enabled) {
                                    viewModel.markItemAsRead(model.rawID);
                                    //control.notifications[type].action(model.rawID);

                                    txDetailsNotifications.txID = model.txid;
                                    txDetailsNotifications.sendAddress = model.sender || "";
                                    txDetailsNotifications.receiveAddress = model.receiver || "";
                                    txDetailsNotifications.token = model.token;
                                    txDetailsNotifications.assetAmounts = [model.amount];
                                    txDetailsNotifications.fee = model.fee;
                                    txDetailsNotifications.assetIncome = [isReceivedType(type) ? 1 : 0];
                                    txDetailsNotifications.isIncome = isReceivedType(type);
                                    txDetailsNotifications.assetNames = ['ARC'];
                                    txDetailsNotifications.assetIDs = ['0'];
                                    txDetailsNotifications.feeUnit = 'ARC';
                                    //txDetails.comment = model.comment || "";
                                    txDetailsNotifications.kernelID = model.kernelID;
                                    txDetailsNotifications.open();
                                }
                            }
                            onPressed : { // avoid Flickable drag effect
                                notificationList.interactive = false;
                            }
                            onReleased : {
                                notificationList.interactive = true;
                            }
                        }
                    }
                }
             }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            CustomButton {
                visible: false
                id:             loadMoreButton
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: -18
                //visible: notificationList.model.count > notificationList.loadedCnt
                //visible: notificationsArray.length > notificationList.loadedCnt

                height: 36
                palette.button: Style.background_second
                palette.buttonText : Style.content_main
                text: 'Load more'//getActionButtonLabel(type)
                font.pixelSize: 18
                customColor: '#b4b4b4'

                border.color: '#b6f4ce'
                border.width: 1

                hasShadow: false
                disableRadius: true
                radius: 0

                background: Rectangle {
                    color:      "transparent"

                    Image {
                        anchors.fill: parent
                        fillMode: Image.Stretch
                        source: {
                             loadMoreButton.hovered ? "qrc:/assets/load-more-hover.png" :  "qrc:/assets/load-more-default.png"
                        }
                    }
                }

                //visible: getActionButtonLabel(type) != undefined
                //enabled: control.notifications[type].action != null

                onClicked: {
                    if (notificationList.model.count - notificationList.loadedCnt >= 5) {
                        notificationList.loadedCnt = notificationList.loadedCnt + 5;
                    }
                    else {
                        notificationList.loadedCnt = notificationList.loadedCnt + (notificationList.model.count - notificationList.loadedCnt);
                    }
                }
            }

            Item {
                Layout.fillWidth: true
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

    function getIconSource(notificationType) {
        return control.notifications[notificationType].icon || ''
    }

    property var icons: ({
        updateIcon: { source: 'qrc:/assets/icon-repeat-white.svg', height: 16},
        detailsIcon: { source: 'qrc:/assets/icon-details.svg', height: 12},
        activateIcon: { source: 'qrc:/assets/icon-activate.svg', height: 16},
        goToAppIcon: { source: 'qrc:/assets/icon-go-to-app.svg', height: 16}
    })

    property var labels: ({
        //% "update now"
        updateLabel:    qsTrId("notifications-update-now"),
        //% "activate"
        activateLabel:  qsTrId("notifications-activate"),
        //% "activated"
        activatedLabel: qsTrId("notifications-activated"),
        //% "details"
        detailsLabel:   qsTrId("notifications-details"),
        //% "open the dapp"
        openDappLabel:  qsTrId("notifications-open-dapp")
    })

    property var notifications: ({
        update: {
            label:      labels.updateLabel,
            actionIcon: icons.updateIcon,
            action:     updateClient,
            icon:       "qrc:/assets/icon-notifications-update.svg"
        },
        expired: {
            label:      labels.activateLabel,
            actionIcon: icons.activateIcon,
            action:     activateAddress,
            icon:       "qrc:/assets/icon-notifications-expired.svg"
        },
        extended: {
            label:      labels.activatedLabel,
            actionIcon: icons.activateIcon,
            action:     null,
            icon:       "qrc:/assets/icon-notifications-expired.svg"
        },
        received: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-received.svg"
        },
        sent: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-sent.svg"
        },
        offlineReceived: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-received-offline.svg"
        },
        offlineSent: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-sent-offline.svg"
        },
        offlineFailedToSend: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-failed-sent-offline.svg"
        },
        pubOfflineReceived: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-received-offline.svg"
        },
        pubOfflineSent: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-sent-offline.svg"
        },
        pubOfflineFailedToSend: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-failed-sent-offline.svg"
        },
        maxpReceived: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-received-privacy.svg"
        },
        maxpSent: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-sent-privacy.svg"
        },
        maxpFailedToSend: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-failed-sent-privacy.svg"
        },
        failedToSend: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-sending-failed.svg"
        },
        failedToReceive: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToTransaction,
            icon:       "qrc:/assets/icon-notifications-receiving-failed.svg"
        },
        swapFailed: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToSwapTransaction,
            icon:       "qrc:/assets/icon-notifications-swap-failed.svg"
        },
        swapExpired: {
            label:      labels.detailsLabel,
            actionIcon: icons.detailsIcon,
            action:     navigateToSwapTransaction,
            icon:       "qrc:/assets/icon-notifications-expired.svg"
        },
        swapCompleted: {
            label:      labels.detailsLabel,
            actionIcon: icons.goToAppIcon,
            action:     navigateToSwapTransaction,
            icon:       "qrc:/assets/icon-notifications-swap-completed.svg"
        },
        contractCompleted: {
            label:      labels.openDappLabel,
            actionIcon: icons.goToAppIcon,
            action:     navigateToDAppTransaction,
            icon:       "qrc:/assets/icon-contract-completed.svg"
        },
        contractExpired: {
            label:      labels.openDappLabel,
            actionIcon: icons.goToAppIcon,
            action:     navigateToDAppTransaction,
            icon:       "qrc:/assets/icon-contract-expired.svg"
        },
        contractFailed: {
            label:      labels.openDappLabel,
            actionIcon: icons.goToAppIcon,
            action:     navigateToDAppTransaction,
            icon:       "qrc:/assets/icon-contract-failed.svg"
        }
    })

    function isReceivedType(type) {
        return type == 'received' ||
                type == 'offlineReceived' ||
                type == 'pubOfflineReceived' ||
                type == 'maxpReceived' ||
                type == 'failedToReceive'
    }

    function updateClient(id) {
        Utils.navigateToDownloads();
    }

    function activateAddress(id) {
        viewModel.activateAddress(id);
    }

    function navigateToTransaction(id) {
        var txID = viewModel.getItemTxID(id);
        if (txID.length > 0) {
            main.openTransactionDetails(txID);
        }
    }

    function navigateToSwapTransaction(id) {
        var txID = viewModel.getItemTxID(id);
        if (txID.length > 0) {
            main.openSwapTransactionDetails(txID);
        }
    }

    function getActionButtonLabel(notificationType) {
        return control.notifications[notificationType].label
    }

    function getActionButtonIcon(notificationType) {
        return control.notifications[notificationType].actionIcon || ''
    }

    function navigateToDAppTransaction(id) {
        var txID = viewModel.getItemTxID(id)
        if (txID) main.openDAppTransactionDetails(txID)
    }
} // Item
