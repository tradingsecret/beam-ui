import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Controls.Styles 1.2
import "controls"
import Beam.Wallet 1.0

ColumnLayout {
    id: addressRoot

	AddressBookViewModel {id: viewModel}

    EditAddress {
        id: editActiveAddress
        parentModel: viewModel
    }

    EditAddress {
        id: editExpiredAddress
        parentModel: viewModel
        isExpiredAddress: true
    }

    anchors.fill: parent
    state: "active"
	Title {
        //% "Address Book"
        text: qsTrId("addresses-tittle")
    }

    StatusBar {
        id: status_bar
        model: statusbarModel
    }

    ConfirmationDialog {
		id: confirmationDialog
        property bool isOwn
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.minimumHeight: 40
        Layout.maximumHeight: 40
        Layout.topMargin: 54

        TxFilter{
            id: activeAddressesFilter
            //% "My active addresses"
            label: qsTrId("addresses-tab-active")
            onClicked: addressRoot.state = "active"
        }

        TxFilter{
            id: expiredAddressesFilter
            //% "My expired addresses"
            label: qsTrId("addresses-tab-expired")
            onClicked: addressRoot.state = "expired"
        }

        TxFilter{
            id: contactsFilter
            //% "Contacts"
            label: qsTrId("addresses-tab-contacts")
            onClicked: addressRoot.state = "contacts"
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        AddressTable {
            id: activeAddressesView
            model: viewModel.activeAddresses
            parentModel: viewModel
            visible: false

            editDialog: editActiveAddress

            sortIndicatorVisible: true
            sortIndicatorColumn: 0
            sortIndicatorOrder: Qt.DescendingOrder

            Binding{
                target: viewModel
                property: "activeAddrSortRole"
                value: activeAddressesView.getColumn(activeAddressesView.sortIndicatorColumn).role
            }

            Binding{
                target: viewModel
                property: "activeAddrSortOrder"
                value: activeAddressesView.sortIndicatorOrder
            }
        }

        AddressTable {
            id: expiredAddressesView
            model: viewModel.expiredAddresses
            visible: false
            parentModel: viewModel

            editDialog: editExpiredAddress
            isExpired: true

            sortIndicatorVisible: true
            sortIndicatorColumn: 0
            sortIndicatorOrder: Qt.DescendingOrder

            Binding{
                target: viewModel
                property: "expiredAddrSortRole"
                value: expiredAddressesView.getColumn(expiredAddressesView.sortIndicatorColumn).role
            }

            Binding{
                target: viewModel
                property: "expiredAddrSortOrder"
                value: expiredAddressesView.sortIndicatorOrder
            }
        }
        
        CustomTableView {
            id: contactsView

            property int rowHeight: 56
            property int resizableWidth: parent.width - actions.width
            property double columnResizeRatio: resizableWidth / 914

            anchors.fill: parent
            frameVisible: false
            selectionMode: SelectionMode.NoSelection
            backgroundVisible: false
            model: viewModel.contacts
            sortIndicatorVisible: true
            sortIndicatorColumn: 0
            sortIndicatorOrder: Qt.DescendingOrder
            
            Binding{
                target: viewModel
                property: "contactSortRole"
                value: contactsView.getColumn(contactsView.sortIndicatorColumn).role
            }

            Binding{
                target: viewModel
                property: "contactSortOrder"
                value: contactsView.sortIndicatorOrder
            }

            TableViewColumn {
                role: viewModel.nameRole
                //% "Comment"
                title: qsTrId("general-comment")
                width: 300 * contactsView.columnResizeRatio
                movable: false
            }

            TableViewColumn {
                role: viewModel.addressRole
                title: qsTrId("general-address")
                width: 280 * contactsView.columnResizeRatio
                movable: false
                delegate: 
                Item {
                    width: parent.width
                    height: contactsView.rowHeight
                    clip:true

                    SFLabel {
                        font.pixelSize: 14
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        anchors.rightMargin: 80
                        elide: Text.ElideMiddle
                        anchors.verticalCenter: parent.verticalCenter
                        text: styleData.value
                        color: Style.content_main
                        copyMenuEnabled: true
                        onCopyText: BeamGlobals.copyToClipboard(text)
                    }
                }
            }

            TableViewColumn {
                id: identityColumn
                role: viewModel.identityRole
                //% "Identity"
                title: qsTrId("general-identity")
                width: contactsView.getAdjustedColumnWidth(identityColumn)
                movable: false
                delegate:
                Item {
                    width: parent.width
                    height: contactsView.rowHeight
                    clip:true

                    SFLabel {
                        font.pixelSize: 14
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 20
                        anchors.rightMargin: 100
                        elide: Text.ElideMiddle
                        anchors.verticalCenter: parent.verticalCenter
                        text: styleData.value
                        color: Style.content_main
                        copyMenuEnabled: true
                        onCopyText: BeamGlobals.copyToClipboard(text)
                    }
                }
            }

            TableViewColumn {
                //role: "status"
                id: actions
                title: ""
                width: 40
                movable: false
                resizable: false
                delegate: txActions
            }

            rowDelegate: Item {

                height: contactsView.rowHeight

                anchors.left: parent.left
                anchors.right: parent.right

                Rectangle {
                    anchors.fill: parent
                    color: styleData.selected ? Style.row_selected :
                            (styleData.alternate ? Style.background_row_even : Style.background_row_odd)
                }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: {
                        if (mouse.button == Qt.RightButton && styleData.row != undefined)
                        {
                            contextMenu.address = contactsView.model[styleData.row].address;
                            contextMenu.popup();
                        }
                    }
                }
            }

            itemDelegate: TableItem {
                text: styleData.value
                elide: styleData.elideMode
            }

            Component {
                id: txActions
                Item {
                    Item {
                        width: parent.width
                        height: contactsView.rowHeight

                        Row{
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 10
                            CustomToolButton {
                                icon.source: "qrc:/assets/icon-actions.svg"
                                //% "Actions"
                                ToolTip.text: qsTrId("general-actions")
                                onClicked: {
                                    contextMenu.address = contactsView.model[styleData.row].address;
                                    contextMenu.token = contactsView.model[styleData.row].token;
                                    contextMenu.popup();
                                }
                            }
                        }
                    }
                }
            }

            ContextMenu {
                id: contextMenu
                modal: true
                dim: false
                property string address
                property string token
                Action {
                    //% "Send"
                    text: qsTrId("general-send")
                    icon.source: "qrc:/assets/icon-send-blue.svg"
                    onTriggered: {
                        main.openSendDialog(contextMenu.token);
                    }
                }
                Action {
                    //% "Delete contact"
                    text: qsTrId("address-table-cm-delete-contact")
                    icon.source: "qrc:/assets/icon-delete.svg"
                    onTriggered: {
                        viewModel.deleteAddress(contextMenu.address);
                    }
                }
            }
        }
    }

    states: [
        State {
            name: "active"
            PropertyChanges {target: activeAddressesFilter; state: "active"}
            PropertyChanges {
                target: activeAddressesView
                visible: true
            }
            PropertyChanges {
                target: expiredAddressesView
                visible: false
            }
            PropertyChanges {
                target: contactsView
                visible: false
            }
        },
        State {
            name: "expired"
            PropertyChanges {target: expiredAddressesFilter; state: "active"}
            PropertyChanges {
                target: activeAddressesView
                visible: false
            }
            PropertyChanges {
                target: expiredAddressesView
                visible: true
            }
            PropertyChanges {
                target: contactsView
                visible: false
            }
        },
        State {
            name: "contacts"
            PropertyChanges {target: contactsFilter; state: "active"}
            PropertyChanges {
                target: activeAddressesView
                visible: false
            }
            PropertyChanges {
                target: expiredAddressesView
                visible: false
            }
            PropertyChanges {
                target: contactsView
                visible: true
            }
        }
    ]
}
