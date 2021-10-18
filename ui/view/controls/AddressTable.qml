import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.3
import QtQuick.Controls.Styles 1.2
import Beam.Wallet 1.0
import "."
import "../utils.js" as Utils

CustomTableView {
    id: rootControl

    property bool isShieldedSupported: true

    property int rowHeight: 46
    property int resizableWidth: parent.width - actions.width
    property double columnResizeRatio: resizableWidth / 914

    property var parentModel
    property bool isExpired: false
    property var showQRDialog
    anchors.fill: parent
    frameVisible: false
    selectionMode: SelectionMode.NoSelection
    backgroundVisible: false
    sortIndicatorVisible: true
    sortIndicatorColumn: 0
    sortIndicatorOrder: Qt.DescendingOrder

    __scrollBarTopMargin: 0
    __verticalScrollbarOffset: 200
    verticalScrollBarPolicy: Qt.ScrollBarAsNeeded

    //onSortIndicatorColumnChanged: {
    //    if (sortIndicatorColumn != 3 &&
    //        sortIndicatorColumn != 4) {
    //        sortIndicatorOrder = Qt.AscendingOrder;
    //    } else {
    //        sortIndicatorOrder = Qt.DescendingOrder;
    //    }
    //}


    headerDelegate: Rectangle {
        id: rect
        height: 0
        visible: none
    }


    /*style: TableViewStyle {
        minimumHandleLength: 30

        handle: Rectangle {
            color: "white"
            radius: 3
            opacity: __verticalScrollBar.handlePressed ? 0.12 : 0.5
            implicitWidth: 6
        }

        scrollBarBackground: Rectangle {
            color: "transparent"
            implicitWidth: 6
            anchors.topMargin: 46
        }

        decrementControl: Rectangle {
            color: "transparent"
        }

        incrementControl: Rectangle {
            color: "transparent"
        }
    }*/

    style: TableViewStyle {
        handle: Rectangle {
            //anchors.leftMargin: 100
            //implicitHeight: 17
            //implicitWidth: 10
            implicitWidth: 10
            width: 5
            //implicitHeight: 50

            //height: 10
            //radius: implicitHeight/2
            color: "#307451"
           // width: 10 // This will be overridden by the width of the scrollbar
            //height: 10

            /*Rectangle {
                color: "purple"
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.leftMargin: 30
                //anchors.topMargin: 6
               // anchors.leftMargin: 200
                //anchors.rightMargin: 4
               // anchors.bottomMargin: 6
            }*/
        }

        scrollBarBackground: Rectangle {
            color: "transparent"
            implicitWidth: 10
            //anchors.topMargin: 46
            //anchors.leftMargin: 100
        }

        decrementControl: Rectangle {
            color: "transparent"
        }

        incrementControl: Rectangle {
            color: "transparent"
        }
    }


    TableViewColumn {
        role: rootControl.isShieldedSupported ? parentModel.tokenRole : parentModel.walletIDRole
        //% "Address"
        title: qsTrId("general-address")
        width: 360//280 *  rootControl.columnResizeRatio
        horizontalAlignment: Text.AlignRight
        movable: false
        resizable: false
        delegate: Item {
            width: parent.width
            height: rootControl.rowHeight
            //clip:true

            SFLabel {
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                elide: Text.ElideLeft
                anchors.verticalCenter: parent.verticalCenter
                text: styleData.value
                color: Style.content_main
                copyMenuEnabled: true
                onCopyText: BeamGlobals.copyToClipboard(text)
            }
        }
    }

    TableViewColumn {
        id:   identityColumn
        role: viewModel.identityRole
        //% "Wallet's signature"
        title: qsTrId("general-wallet-signature")
        width: 360//rootControl.getAdjustedColumnWidth(identityColumn)//150 *  rootControl.columnResizeRatio
        resizable: false
        movable: false
        horizontalAlignment: Text.AlignRight
        delegate:
        Item {
            width: parent.width
            height: rootControl.rowHeight
            clip:true

            SFLabel {
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                elide: Text.ElideLeft
                anchors.verticalCenter: parent.verticalCenter
                text: styleData.value
                color: Style.content_main
                copyMenuEnabled: true
                onCopyText: BeamGlobals.copyToClipboard(text)

            }
        }
    }

    TableViewColumn {
        role: parentModel.nameRole
        //% "Comment"
        title: qsTrId("general-comment")
        width: 360//300 * rootControl.columnResizeRatio
        resizable: false
        movable: false
        horizontalAlignment: Text.AlignRight
        //delegate: TableItem {
        //    text:           styleData.value
        //    elide:          styleData.elideMode
        //    fontWeight:     Font.Bold
        //    fontStyleName: "Bold"
        //}

        delegate: Item {
            width: parent.width
            height: rootControl.rowHeight
            clip:true

            SFLabel {
                font.pixelSize: 14
                horizontalAlignment: Text.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 20
                anchors.rightMargin: 70
                elide: Text.ElideLeft
                anchors.verticalCenter: parent.verticalCenter
                text: styleData.value
                color: Style.content_main
                copyMenuEnabled: true
                onCopyText: BeamGlobals.copyToClipboard(text)
            }

            CustomButton {
                id:             actionButton
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 25
                anchors.topMargin: 10

                height: 28
                width: 28
                palette.button: Style.background_second
                palette.buttonText : Style.content_main
                text: ''
                font.pixelSize: 13
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
                             actionButton.hovered ? "qrc:/assets/gear-hover.png" :  "qrc:/assets/gear-default.png"
                        }
                    }
                }

                onClicked: {
                    contextMenu.addressItem = rootControl.model[styleData.row]
                    contextMenu.popup()
                }
            }
        }
    }

    //TableViewColumn {
    //    role: parentModel.expirationRole
    //    //% "Expiration date"
    //    title: qsTrId("general-exp-date")
    //    width: 150 *  rootControl.columnResizeRatio
    //    resizable: false
    //    movable: false
    //    visible: false
    //    delegate: Item {
    //        Item {
    //            width: parent.width
    //            height: rootControl.rowHeight
    //
    //            SFText {
    //                font.pixelSize: 14
    //                anchors.left: parent.left
    //                anchors.right: parent.right
    //                anchors.leftMargin: 20
    //                elide: Text.ElideRight
    //                anchors.verticalCenter: parent.verticalCenter
    //                text: Utils.formatDateTime(styleData.value, BeamGlobals.getLocaleName())
    //                color: Style.content_main
    //            }
    //        }
    //    }
    //}
    //
    //TableViewColumn {
    //    id: createdColumn
    //    role:parentModel.createdRole
    //    //% "Created"
    //    title: qsTrId("general-created")
    //    width: rootControl.getAdjustedColumnWidth(createdColumn)
    //    resizable: false
    //    movable: false
    //    visible: false
    //    delegate: Item {
    //        Item {
    //            width: parent.width
    //            height: rootControl.rowHeight
    //
    //            SFText {
    //                font.pixelSize: 14
    //                anchors.left: parent.left
    //                anchors.right: parent.right
    //                anchors.leftMargin: 20
    //                elide: Text.ElideRight
    //                anchors.verticalCenter: parent.verticalCenter
    //                text: Utils.formatDateTime(styleData.value, BeamGlobals.getLocaleName())
    //                color: Style.content_main
    //            }
    //        }
    //    }
    //}

    TableViewColumn {
        visible: false
        id: actions
        title: ""
        width: 40
        movable: false
        resizable: false
        delegate: txActions
    }

    rowDelegate: Item {

        height: rootControl.rowHeight

        anchors.left: parent.left
        //anchors.right: parent.right
        //anchors.rightMargin: 200

        Rectangle {
            anchors.fill: parent

            color: styleData.selected ? Style.row_selected :
                    (styleData.alternate ? 'transparent' : '#14141e')
        }
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                if (mouse.button == Qt.RightButton && styleData.row != undefined)
                {
                    contextMenu.addressItem = rootControl.model[styleData.row]
                    contextMenu.popup()
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
                height: rootControl.rowHeight

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
                            contextMenu.addressItem = rootControl.model[styleData.row]
                            contextMenu.popup()
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
        property var addressItem
        Action {
            id:          receiveAction
            //: Entry in address table context menu to get receive token
            //% "receive"
            text:        qsTrId("address-table-cm-receive")
            icon.source: "qrc:/assets/icon-receive-blue.svg"
            enabled:     contextMenu.addressItem && !contextMenu.addressItem.isExpired
            onTriggered: {
                main.openReceiveDialog(contextMenu.addressItem.token)
            }
        }

        Action {
            //: Entry in address table context menu to edit
            //% "Edit address"
            text: qsTrId("address-table-cm-edit")
            icon.source: "qrc:/assets/icon-edit.svg"
            onTriggered: {
                var dialog = Qt.createComponent("EditAddress.qml").createObject(main, {
                    viewModel:           rootControl.parentModel,
                    addressItem:         contextMenu.addressItem,
                    isShieldedSupported: rootControl.isShieldedSupported
                })
                dialog.open();
            }
        }

        Action {
            //: Entry in address table context menu to delete
            //% "Delete address"
            text: qsTrId("address-table-cm-delete")
            icon.source: "qrc:/assets/icon-delete.svg"
            onTriggered: {
                if (viewModel.isWIDBusy(contextMenu.addressItem.walletID)) {
                    return deleteAddressDialog.open()
                }
                viewModel.deleteAddress(contextMenu.addressItem.token)
            }
        }
    
        Component.onCompleted: {
            if (isExpired) {
                contextMenu.removeAction(showQRAction);
            }
        }
    }
    
    ConfirmationDialog {
        id:                 deleteAddressDialog
        width:              460
        //% "Delete address"
        title:              qsTrId("addresses-delete-warning-title")
        //% "There is active transaction that uses this address, therefore the address cannot be deleted."
        text:               qsTrId("addresses-delete-warning-text")
        //% "Ok"
        okButtonText:       qsTrId("general-ok")
        okButtonIconSource: "qrc:/assets/icon-done.svg"
        cancelButtonVisible: false
    }
}
