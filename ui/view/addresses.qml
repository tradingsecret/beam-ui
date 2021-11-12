import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
import QtQuick.Controls.Styles 1.2
import "controls"
import Beam.Wallet 1.0

ColumnLayout {
    id: control
    anchors.fill: parent

	AddressBookViewModel {
	    id: viewModel
    }

    property bool isShieldedSupported: statusbarModel.isConnectionTrusted && statusbarModel.isOnline

    ConfirmationDialog {
		id: confirmationDialog
        property bool isOwn
    }

    state: "active"
    states: [
        State {
            name: "active";
            PropertyChanges {target: activeAddressesFilter; state: "active"}
        },
        State {
            name: "expired";
            PropertyChanges {target: expiredAddressesFilter; state: "active"}
        },
        State {
            name: "contacts";
            PropertyChanges {target: contactsFilter; state: "active"}
            PropertyChanges { target: emptyMessage;  
                //% "Your contact list is empty"
                text: qsTrId("contacts-empty")
            }
        }
    ]

    /*RowLayout {
        Layout.minimumHeight: 40
        Layout.maximumHeight: 40
        Layout.topMargin:       54
        visible:                viewModel.contacts.length > 0  || viewModel.activeAddresses.length > 0 || viewModel.expiredAddresses.length > 0
        TxFilter{
            id: activeAddressesFilter
            //% "My active addresses"
            label: qsTrId("addresses-tab-active")
            onClicked: control.state = "active"
        }

        TxFilter{
            id: expiredAddressesFilter
            //% "My expired addresses"
            label: qsTrId("addresses-tab-expired")
            onClicked: control.state = "expired"
        }

        TxFilter{
            id: contactsFilter
            //% "Contacts"
            label: qsTrId("addresses-tab-contacts")
            onClicked: control.state = "contacts"
        }
    }*/

    ColumnLayout {
        Layout.topMargin: 90
        Layout.alignment: Qt.AlignHCenter
        Layout.fillHeight: true
        Layout.fillWidth:  true
        visible:          false//activeAddressesViewItem.visible && activeAddressesView.model.length == 0
    
        SvgImage {
            Layout.alignment: Qt.AlignHCenter
            source: "qrc:/assets/icon-addressbook-empty.svg"
            sourceSize: Qt.size(60, 60)
        }
    
        SFText {
            id:                   emptyMessage
            Layout.topMargin:     30
            Layout.alignment:     Qt.AlignHCenter
            horizontalAlignment:  Text.AlignHCenter
            font.pixelSize:       14
            color:                Style.content_main
            opacity:              0.5
            lineHeight:           1.43
            //% "Your address book is empty"
            text: qsTrId("addressbook-empty")
        }
    
        Item {
            Layout.fillHeight: true
        }
    }

    ColumnLayout {
       // visible: notificationList.model.count > 0

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
            text:                 "Latest wallets"
        }

        ColumnLayout {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.margins: 15

                ColumnLayout {
                    id: table_id

                    ColumnLayout {
                        //Layout.topMargin: 2
                        Layout.fillWidth: true
                        Layout.rightMargin: 5
                        Layout.bottomMargin: 0

                        RowLayout {
                            anchors.fill: parent
                            width: parent.width

                            Row {
                                width: 360

                                SFText {
                                    horizontalAlignment: Text.AlignHCenter
                                    width: 360
                                    text: 'Address'
                                    font.pixelSize: 18
                                    color: '#646464'
                                }
                            }

                            Row {
                                width: 360

                                SFText {
                                    horizontalAlignment: Text.AlignHCenter
                                    width: 360
                                    text: 'Signature'
                                    font.pixelSize: 18
                                    color: '#646464'
                                }
                            }

                            Row {
                                width: 360

                                SFText {
                                    horizontalAlignment: Text.AlignHCenter
                                    width: 360
                                    text: 'Transaction note'
                                    font.pixelSize: 18
                                    color: '#646464'
                                }
                            }
                        }

                        Rectangle {
                            Layout.topMargin: 8
                            width: 1080
                            height: 1
                            color: '#112a26'
                        }
                    }

                    Item {
                        Layout.fillWidth:  true
                        Layout.fillHeight: true
                        height: 300
                        Layout.topMargin: 5
                        Layout.rightMargin: 10

                        Item {
                            id: activeAddressesViewItem
                            visible:      control.state == "active"
                            anchors.fill: parent

                            AddressTable {
                                id: activeAddressesView
                                model: viewModel.activeAddresses
                                parentModel: viewModel
                                visible: activeAddressesView.model.length > 0
                                isShieldedSupported: control.isShieldedSupported

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
                        }
                    }
                }

                Item {
                    Rectangle {
                        id: line
                        anchors.fill: table_id
                        anchors.topMargin: 15
                        x: 360
                        height: table_id.height
                        width: 1
                        color: '#112a26'
                    }


                    Rectangle {
                        id: line1
                        anchors.fill: table_id
                        anchors.topMargin: 15
                        x: 720
                        height: table_id.height
                        width: 1
                        color: '#112a26'
                    }
                }

            }
            /*Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 100
                height: 500
                border.color: 'purple'
                border.width: 1
                color: 'purple'
            }*/

            Rectangle {
                anchors.fill: parent
                border.color: '#112a26'
                border.width: 1
                color: 'transparent'
            }
        }
    }
}
