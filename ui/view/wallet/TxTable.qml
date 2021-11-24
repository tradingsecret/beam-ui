import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.3
import Beam.Wallet 1.0
import "../controls"
import "../utils.js" as Utils
import "."

Control {
    id: control

    FontLoader { id: tomorrow_semibold;  source: "qrc:/assets/fonts/SF-Pro-Display-TomorrowSemiBold.ttf" }
    FontLoader { id: tomorrow_extralight;  source: "qrc:/assets/fonts/Tomorrow-ExtraLight.ttf" }
    FontLoader { id: tomorrow_light;  source: "qrc:/assets/fonts/Tomorrow-Light.ttf" }

    TxTableViewModel {
        id: tableViewModel

        onTransactionsChanged: function () {
            txNotify.forEach(function (json) {
                var obj = JSON.parse(json)
                control.showAppTxNotifcation(obj.txid, obj.appicon)
            })
        }
    }

    property int       selectedAsset: -1
    property int       emptyMessageMargin: 90
    property int       activeTxCnt: 0
    property alias     headerShaderVisible: transactionsTable.headerShaderVisible
    property var       dappFilter: undefined
    readonly property  bool sourceVisible: dappFilter ? dappFilter == "all" : true
    property var       owner
    property var       txNotify: new Set()

    function showTxDetails (txid) {
        transactionsTable.showDetails (txid)
    }

    function showAppTxNotifcation (txid, appicon) {
        var list  = tableViewModel.transactions
        var index = list.index(0, 0)
        var ilist = list.match(index, TxObjectList.Roles.TxID, txid)
        if (ilist.length)
        {
            txNotify.delete(JSON.stringify({txid, appicon}))
            main.showAppTxPopup(
                list.data(ilist[0], TxObjectList.Roles.Comment),
                list.data(ilist[0], TxObjectList.Roles.DAppName),
                appicon, txid
            )
        }
        else
        {
            // model not yet updated, transaction is still invisble for the list
            // safe for the future
            txNotify.add(JSON.stringify({txid, appicon}))
        }
    }

    state: "all"
    states: [
        State {
            name: "all"
            PropertyChanges { target: allTab; state: "active" }
            PropertyChanges { target: emptyMessage;  
                //% "Your transaction list is empty"
                text: qsTrId("tx-empty")
            }
            
        },
        State {
            name: "inProgress"
            PropertyChanges { target: inProgressTab; state: "active" }
            PropertyChanges { target: txProxyModel; filterRole: "isInProgress" }
            PropertyChanges { target: txProxyModel; filterString: "true" }
            PropertyChanges { target: emptyMessage;  
                //% "There are no in progress transactions yet."
                text: qsTrId("tx-in-progress-empty")
            }
        },
        State {
            name: "sent"
            PropertyChanges { target: sentTab; state: "active" }
            PropertyChanges { target: txProxyModel; filterRole: "isSent" }
            PropertyChanges { target: txProxyModel; filterString: "true" }
            PropertyChanges { target: emptyMessage;  
                //% "There are no sent transactions yet."
                text: qsTrId("tx-sent-empty")
            }
        },
        State {
            name: "received"
            PropertyChanges { target: receivedTab; state: "active" }
            PropertyChanges { target: txProxyModel; filterRole: "isReceived" }
            PropertyChanges { target: txProxyModel; filterString: "true" }
            PropertyChanges { target: emptyMessage;  
                //% "There are no received transactions yet."
                text: qsTrId("tx-received-empty")
            }
        }
    ]

    onStateChanged: {
        transactionsTable.positionViewAtRow(0, ListView.Beginning)
    }

    ConfirmationDialog {
        id: deleteTransactionDialog
        //% "Delete"
        okButtonText: qsTrId("general-delete")

        property var txID
        onAccepted: function () {
            tableViewModel.deleteTx(txID)
       }
    }

    PaymentInfoItem {
        id: verifyInfo
    }

    PaymentInfoDialog {
        id: paymentInfoVerifyDialog
        shouldVerify: true

        model:verifyInfo
        onTextCopied: function(text) {
            BeamGlobals.copyToClipboard(text);
        }
    }

    TransactionDetailsPopupNotifications {
        id: txDetails
        onTextCopied: function(text) {
            BeamGlobals.copyToClipboard(text);
        }
        onOpenExternal: function(kernelID) {
            var url = BeamGlobals.getExplorerUrl() + "block?kernel_id=" + kernelID;
            Utils.openExternalWithConfirmation(url, undefined, true);
        };
    }

    contentItem: ColumnLayout {
        spacing: 0

        ColumnLayout {
            visible:             tableViewModel.transactions.rowCount() == 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            height: parent.parent.height
            Layout.preferredHeight: height
            Layout.alignment:    Qt.AlignCenter | Qt.AlignHCenter | Qt.AlignVCenter
            anchors.horizontalCenter: parent.horizontalCenter

            ColumnLayout {
                 Layout.alignment:    Qt.AlignCenter | Qt.AlignHCenter | Qt.AlignVCenter
                 anchors.horizontalCenter: parent.horizontalCenter

                 SFText {
                     text:              'EMPTY'
                     color:             '#585858'
                     font.pixelSize:    72
                     font.family:       tomorrow_semibold.name
                     opacity: 0.3
                 }

                 Rectangle {
                     anchors.fill: parent
                     //border.width: 1
                     //border.color: 'pink'
                     color: 'transparent'
                 }
            }

            Rectangle {
                anchors.fill: parent
                //border.width: 1
                //border.color: 'purple'
                color: 'transparent'
            }
        }

        RowLayout {
            Layout.fillWidth:    true
            Layout.topMargin: 15
            Layout.bottomMargin: 15
            visible:             tableViewModel.transactions.rowCount() > 0

            Item {
                Layout.fillWidth: true
            }

            TxFilter {
                id: allTab
                Layout.alignment: Qt.AlignVCenter
                //% "All"
                label: qsTrId("wallet-transactions-all-tab")
                onClicked: control.state = "all"
            }

            TxFilter {
                id: inProgressTab
                Layout.alignment: Qt.AlignVCenter
                //% "In progress"
                label: qsTrId("wallet-transactions-in-progress-tab")
                onClicked: control.state = "inProgress"
            }

            TxFilter {
                id: sentTab
                Layout.alignment: Qt.AlignVCenter
                //% "Sent"
                label: qsTrId("wallet-transactions-sent-tab")
                onClicked: control.state = "sent"
                visible: false
            }

            TxFilter {
                id: receivedTab
                Layout.alignment: Qt.AlignVCenter
                //% "Received"
                label: qsTrId("wallet-transactions-received-tab")
                onClicked: control.state = "received"
                visible: false
            }

            Item {
                Layout.fillWidth: true
            }

            SearchBox {
               id: searchBox
               Layout.preferredWidth: 300
               Layout.alignment: Qt.AlignVCenter
               //% "Enter search text..."
               placeholderText: qsTrId("wallet-search-transactions-placeholder")
               visible: false
            }

            CustomToolButton {
                Layout.alignment: Qt.AlignVCenter
                icon.source: "qrc:/assets/icon-export.svg"
                //: transactions history screen, export button tooltip and open file dialog
                //% "Export transactions history"
                ToolTip.text: qsTrId("wallet-export-tx-history")
                onClicked: {
                    tableViewModel.exportTxHistoryToCsv();
                }
                visible: false
            }

            CustomToolButton {
                visible: false
                Layout.alignment: Qt.AlignVCenter
                icon.source: "qrc:/assets/icon-proof.svg"
                //% "Verify payment"
                ToolTip.text: qsTrId("wallet-verify-payment")
                onClicked: {
                    paymentInfoVerifyDialog.model.reset();
                    paymentInfoVerifyDialog.open();
                }
            }
        }

        ColumnLayout {
            Layout.topMargin: emptyMessageMargin
            Layout.alignment: Qt.AlignHCenter
            visible: transactionsTable.model.count == 0
            /*SvgImage {
                Layout.alignment: Qt.AlignHCenter
                source: "qrc:/assets/icon-wallet-empty.svg"
                sourceSize: Qt.size(60, 60)
            }

            SFText {
                id:                   emptyMessage
                Layout.topMargin:     emptyMessageMargin / 3
                Layout.alignment:     Qt.AlignHCenter
                horizontalAlignment:  Text.AlignHCenter
                font.pixelSize:       14
                color:                Style.content_main
                opacity:              0.5
                lineHeight:           1.43
                //% "Your transaction list is empty"
                text: qsTrId("tx-empty")
            }*/

            Item {
                Layout.fillHeight: true
            }
        }

        CustomTableView {
            id: transactionsTable
            headerTextLeftMargin: 0

            //Rectangle { anchors.top: parent.top; height: 1; width: parent.width; color: 'purple'}
            //Rectangle { anchors.bottom: parent.bottom; height: 1; width: parent.width;  color: 'purple'}
            //Rectangle { anchors.left:  parent.left; height: parent.height; width: 1; color: 'purple'; visible: (isSelect()&&column === 0) }
            //Rectangle { anchors.right: parent.right; height: parent.height; width: 1; color: 'purple'; visible: (isSelect()&&column === tableView.columns - 1) }


            property var initTxDetailsFromRow: function (model, row) {
                txDetails.sendAddress      =  model.getRoleValue(row, "addressFrom") || ""
                txDetails.receiveAddress   =  model.getRoleValue(row, "addressTo") || ""
                txDetails.senderIdentity   =  model.getRoleValue(row, "senderIdentity") || ""
                txDetails.receiverIdentity =  model.getRoleValue(row, "receiverIdentity") || ""
                txDetails.comment          =  model.getRoleValue(row, "comment") || ""
                txDetails.txID             =  model.getRoleValue(row, "txID") || ""
                txDetails.kernelID         =  model.getRoleValue(row, "kernelID") || ""
                txDetails.status           =  model.getRoleValue(row, "status") || ""
                txDetails.failureReason    =  model.getRoleValue(row, "failureReason") || ""
                txDetails.isIncome         =  model.getRoleValue(row, "isIncome")
                txDetails.hasPaymentProof  =  model.getRoleValue(row, "hasPaymentProof")
                txDetails.isSelfTx         =  model.getRoleValue(row, "isSelfTransaction")
                txDetails.isContractTx     =  model.getRoleValue(row, "isContractTx")
                txDetails.cidsStr          =  model.getRoleValue(row, "cidsStr") || ""
                txDetails.rawTxID          =  model.getRoleValue(row, "rawTxID") || null
                txDetails.stateDetails     =  model.getRoleValue(row, "stateDetails") || ""
                txDetails.isCompleted      =  model.getRoleValue(row, "isCompleted")
                txDetails.minConfirmations =  model.getRoleValue(row, "minConfirmations") || 0
                txDetails.dappName         =   model.getRoleValue(row, "dappName") || ""
                txDetails.confirmationsProgress = model.getRoleValue(row, "confirmationsProgress") || ""

                var addrModel = {
                    isMaxPrivacy: model.getRoleValue(row, "isMaxPrivacy"),
                    isOfflineToken: model.getRoleValue(row, "isOfflineToken"),
                    isPublicOffline: model.getRoleValue(row, "isPublicOffline")
                }

                txDetails.feeOnly        =  model.getRoleValue(row, "isFeeOnly")
                txDetails.addressType    =  Utils.getAddrTypeFromModel(addrModel)
                txDetails.assetNames     =  model.getRoleValue(row, "assetNames") || []
                txDetails.assetVerified  =  model.getRoleValue(row, "assetVerified") || []
                txDetails.assetIcons     =  model.getRoleValue(row, "assetIcons") || []
                txDetails.assetAmounts   =  model.getRoleValue(row, "assetAmounts") || []
                txDetails.assetIncome    =  model.getRoleValue(row, "assetAmountsIncome") || []
                txDetails.assetRates     =  model.getRoleValue(row, "assetRates") || []
                txDetails.assetIDs       =  model.getRoleValue(row, "assetIDs") || []
                txDetails.rateUnit       =  tableViewModel.rateUnit
                txDetails.fee            =  model.getRoleValue(row, "fee") || "0"
                txDetails.feeRate        =  model.getRoleValue(row, "feeRate") || "0"
                txDetails.feeUnit        =  qsTrId("general-beam");
                txDetails.feeRateUnit    =  tableViewModel.rateUnit
                txDetails.searchFilter   =  searchBox.text;
                txDetails.token          =  model.getRoleValue(row, "token") || ""
                txDetails.isShieldedTx   =  !!model.getRoleValue(row, "isShieldedTx")
                txDetails.initialState   =  "tx_info";

                txDetails.getPaymentProof = function(rawTxID) {
                    return rawTxID ? tableViewModel.getPaymentInfo(rawTxID) : null
                }
            }

            property var showDetails: function (rawTxID) {
                var id = rawTxID;
                if (typeof id != "string") {
                    id = BeamGlobals.rawTxIdToStr(id);
                }

                if (!id.length) return;

                var index = tableViewModel.transactions.index(0, 0);
                var indexList = tableViewModel.transactions.match(index, TxObjectList.Roles.TxID, id);
                if (indexList.length > 0) {
                    index = dappFilterProxy.mapFromSource(indexList[0]);
                    index = assetFilterProxy.mapFromSource(index);
                    index = searchProxyModel.mapFromSource(index);
                    index = txProxyModel.mapFromSource(index);
                    transactionsTable.positionViewAtRow(index.row, ListView.Beginning);

                    initTxDetailsFromRow(transactionsTable.model, index.row);
                    txDetails.open();
                }
            }

            Component.onCompleted: function () {
                txProxyModel.source.countChanged.connect(function() {
                    control.activeTxCnt = 0
                    var source = txProxyModel.source
                    for (var idx = 0; idx < source.count; ++idx) {
                        var qindex = source.index(idx, 0);
                        if (source.data(qindex, TxObjectList.Roles.IsActive)) {
                            ++control.activeTxCnt
                        }
                    }
                })
                transactionsTable.model.modelReset.connect(function() {
                    var activeTxId = "";
                    if (owner && owner != undefined && owner.openedTxID != undefined && owner.openedTxID != "") {
                        // wallet && applications view
                        activeTxId = owner.openedTxID;
                    }
                    showDetails(activeTxId);
                });
            }

            Layout.alignment:     Qt.AlignTop
            Layout.fillWidth:     true
            Layout.fillHeight:    true
            Layout.bottomMargin:  9
            visible:              transactionsTable.model.count > 0

            property real rowHeight: 35 //56
            property real resizableWidth: transactionsTable.width - 140
            property real columnResizeRatio: resizableWidth / (610 - (sourceVisible ? 0 : 140))

            selectionMode: SelectionMode.NoSelection
            sortIndicatorVisible: true
            sortIndicatorColumn: 0
            sortIndicatorOrder: Qt.DescendingOrder

            onSortIndicatorColumnChanged: {
                sortIndicatorOrder = sortIndicatorColumn != 1
                    ? Qt.AscendingOrder
                    : Qt.DescendingOrder;
            }

            model: SortFilterProxyModel {
                id: txProxyModel

                source: SortFilterProxyModel {
                    id: searchProxyModel
                    filterRole: "search"
                    filterString: searchBox.text
                    filterSyntax: SortFilterProxyModel.Wildcard
                    filterCaseSensitivity: Qt.CaseInsensitive

                    source: SortFilterProxyModel {
                        id:           assetFilterProxy
                        filterRole:   "assetFilter"
                        filterString: control.selectedAsset < 0 ? "" : ["\\b", control.selectedAsset, "\\b"].join("")
                        filterSyntax: SortFilterProxyModel.RegExp

                        source: SortFilterProxyModel {
                            id:           dappFilterProxy
                            filterRole:   dappFilter ? (dappFilter == "all" ? "isDappTx" : "dappId") : ""
                            filterString: dappFilter ? (dappFilter == "all" ? "true" : dappFilter) : ""
                            filterSyntax: SortFilterProxyModel.FixedString
                            filterCaseSensitivity: Qt.CaseInsensitive
                            source: tableViewModel.transactions
                        }
                    }
                }

                sortOrder: transactionsTable.sortIndicatorOrder
                sortCaseSensitivity: Qt.CaseInsensitive
                sortRole: transactionsTable.getColumn(transactionsTable.sortIndicatorColumn).role + "Sort"
                filterSyntax: SortFilterProxyModel.Wildcard
            }

            rowDelegate: ExpandableRowDelegate {
                /*Rectangle {
                   anchors{
                       right: parent.right
                       left: parent.left
                       bottom: parent.bottom
                   }
                   height: 1
                   color: "pink"
               }*/

                id:         rowItemDelegate
                collapsed:  true
                rowInModel: styleData.row !== undefined && styleData.row >= 0 && styleData.row < txProxyModel.count
                rowHeight:  transactionsTable.rowHeight
                tableView:  transactionsTable
                //border.width: 1
                //border.color: 'pink'

               // backgroundColor: !rowInModel ? "transparent":
               //                  styleData.selected ?
               //                  Style.row_selected :
               //                  hovered
               //                     ? Qt.rgba(Style.active.r, Style.active.g, Style.active.b, 0.1)
               //                     : (styleData.alternate ? (!collapsed || animating ? Style.background_row_details_even : Style.background_row_even)
               //                                            : (!collapsed || animating ? Style.background_row_details_odd : Style.background_row_odd))
                backgroundColor: 'transparent'
                radius: 0

                property var model: parent.model
                property bool hideFiltered: true
                property string searchBoxText: searchBox.text
                property int rowNumber: styleData.row !== undefined? styleData.row : "-1"
                onSearchBoxTextChanged: function() {
                    if (searchBoxText.length == 0) {
                        collapse(false);
                        return;
                    }
                    if (rowNumber == 0 && collapsed)
                        expand(false);

                    if (rowNumber != 0 && !collapsed)
                        collapse(false);
                }

                onRowNumberChanged: function() {
                    if(searchBoxText.length && rowNumber == 0 && collapsed)
                        expand(false);
                }

                onLeftClick: function() {
                    transactionsTable.initTxDetailsFromRow(transactionsTable.model, rowNumber);
                    txDetails.open();
                    return false;
                }

                delegate: TransactionsSearchHighlighter {
                    id: detailsPanel
                    width: transactionsTable.width
                    sendAddress:            model && model.addressFrom ? model.addressFrom : ""
                    receiveAddress:         model && model.addressTo ? model.addressTo : ""
                    senderIdentity:         model && model.senderIdentity ? model.senderIdentity : ""
                    receiverIdentity:       model && model.receiverIdentity ? model.receiverIdentity : ""
                    txID:                   model && model.txID ? model.txID : ""
                    kernelID:               model && model.kernelID ? model.kernelID : ""
                    comment:                model && model.comment ? model.comment : ""
                    isContractTx:           model && model.isContractTx
                    isShieldedTx:           model && model.isShieldedTx

                    searchFilter:    searchBoxText
                    hideFiltered:    rowItemDelegate.hideFiltered
                    token:           model ? model.token : ""

                    onTextCopied: function (text) {
                        BeamGlobals.copyToClipboard(text);
                    }
                }
            }


            itemDelegate: Item {

                width: parent.width
                Layout.fillWidth: true

                RowLayout {
                    height:   transactionsTable.rowHeight
                    anchors.horizontalCenter: parent.horizontalCenter

                    SFText {
                        text:  styleData.value || ""
                        elide: styleData.elideMode
                        color:             '#ffffff'
                        Layout.fillWidth:  true
                        //Layout.leftMargin: 20
                        font.weight: Font.Bold
                        font {
                            family: tomorrow_extralight.name
                            pixelSize: 15
                        }
                    }
                }
            }

            TableViewColumn {
                role: "timeCreated"
                id: dateColumn

                //% "Created on"
                title:      "Date"
                elideMode:  Text.ElideRight
                //width:      105 * transactionsTable.columnResizeRatio
                width: 80 * transactionsTable.columnResizeRatio
                movable:    false
                resizable:  false
                delegate: Item {

                    width: parent.width
                    Layout.fillWidth: true

                    RowLayout {
                        height:   transactionsTable.rowHeight
                        anchors.horizontalCenter: parent.horizontalCenter

                        SFText {
                            text:  styleData.value.split(" ")[0]
                            elide: styleData.elideMode
                            color:             '#ffffff'
                            Layout.fillWidth:  true
                            //Layout.leftMargin: 20
                            font.weight: Font.Bold
                            font {
                                family: tomorrow_extralight.name
                                pixelSize: 15
                            }
                        }
                    }
                }
            }

            TableViewColumn {
                role: "timeCreated"
                id: timeColumn

                //% "Created on"
                title:      "Time"
                elideMode:  Text.ElideRight
                //width:      105 * transactionsTable.columnResizeRatio
                width: 60 * transactionsTable.columnResizeRatio
                movable:    false
                resizable:  false
                delegate: Item {

                    width: parent.width
                    Layout.fillWidth: true

                    RowLayout {
                        height:   transactionsTable.rowHeight
                        anchors.horizontalCenter: parent.horizontalCenter

                        SFText {
                            text:  styleData.value.split(" ")[1]
                            elide: styleData.elideMode
                            color:             '#ffffff'
                            Layout.fillWidth:  true
                            //Layout.leftMargin: 20
                            font.weight: Font.Bold
                            font {
                                family: tomorrow_extralight.name
                                pixelSize: 15
                            }
                        }
                    }
                }
            }

            TableViewColumn {
                role: "assetNames"
                id: coinColumn

                //% "Coin"
                title:     qsTrId("tx-table-asset")
                //width:     100
                width:     100 * transactionsTable.columnResizeRatio
                movable:   false
                resizable: false
                elideMode:  Text.ElideNone

                delegate: Item {
                    width: parent.width
                    Layout.fillWidth: true

                    CoinsList {
                        anchors.horizontalCenter: parent.horizontalCenter
                        //Layout.alignment: Qt.AlignCenter | Qt.AlignHCenter
                        height:   transactionsTable.rowHeight
                        icons:    model ? model.assetIcons : undefined
                        names:    model ? ["ARCTIS (ARC)"] : undefined //model ? model.assetNames : undefined
                        verified: model ? model.assetVerified: undefined
                    }
                }
            }

            TableViewColumn {
                role: "amountGeneral"

                //% "Amount"
                title:     qsTrId("general-amount")
                elideMode: Text.ElideRight
                //width:     115 * transactionsTable.columnResizeRatio
                width: 100 * transactionsTable.columnResizeRatio
                movable:   false
                resizable: false

                delegate: Item {
                    width: parent.width
                    Layout.fillWidth: true

                    RowLayout {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: transactionsTable.rowHeight

                        property var isIncome:    model && model.isIncome
                        property var prefix:      model && model.amountGeneral == "0" ? "" : (isIncome ? "+ " : "- ")
                        property var amountText:  model && model.amountGeneral ? [prefix, Utils.uiStringToLocale(BeamGlobals.roundWithPrecision(model.amountGeneral, 6))].join('') : "0"

                        //% "Multiple assets"
                        property var displayText: model && model.isMultiAsset ? qsTrId("general-multiple-assets") : amountText

                        SFText {
                            text:              parent.displayText
                            color:             parent.isIncome ? "#4cbd7b" : "#ff0000" //Style.accent_incoming : Style.accent_outgoing
                            Layout.fillWidth:  true
                            font.weight: Font.Bold
                            //Layout.leftMargin: 20
                            elide:             Text.ElideRight
                            font {
                                family: tomorrow_light.name
                                pixelSize: 16
                            }
                        }
                    }
                }
            }

            /*TableViewColumn {
                role: "amountSecondCurrency"

                title:     [tableViewModel.rateUnit || "USD",
                            //% "Value"
                            qsTrId("general-value")].join(' ')

                elideMode: Text.ElideRight
                width:     115 * transactionsTable.columnResizeRatio
                movable:   false
                resizable: false
                visible:   !control.isContracts

                delegate: Item { RowLayout {
                    width:  parent.width
                    height: transactionsTable.rowHeight

                    property var amount: BeamGlobals.roundWithPrecision(model && model.amountSecondCurrency ? model.amountSecondCurrency : "0", tableViewModel.rateUnit ? 6 : 2)
                    property var prefix: model && model.isIncome ? "+ " : "- "

                    SFText {
                        text:                   parent.amount != "0" ? [parent.prefix, Utils.uiStringToLocale(parent.amount)].join('') : ""
                        color:                  Style.content_main
                        Layout.fillWidth:       true
                        Layout.leftMargin:      20
                        elide:                  Text.ElideRight
                        font {
                            styleName: "Bold"
                            weight:    Font.Bold
                            pixelSize: 14
                        }
                    }
                }}
            }*/

            TableViewColumn {
                role: "source"
                id: sourceColumn

                //% "Source"
                title:      "Type" //qsTrId("wallet-txs-source")
                elideMode:  Text.ElideRight
                width:      80 * transactionsTable.columnResizeRatio
                movable:    false
                resizable:  false
                visible:    sourceVisible
                delegate: Item {

                    width: parent.width
                    Layout.fillWidth: true

                    RowLayout {
                        height:   transactionsTable.rowHeight
                        anchors.horizontalCenter: parent.horizontalCenter

                        SFText {
                            text: model && model.isIncome ? 'INCOMING' : 'OUTGOING'
                            elide: styleData.elideMode
                            color:             '#ffffff'
                            Layout.fillWidth:  true
                            font.weight: Font.Bold
                            //Layout.leftMargin: 20
                            font {
                                family: tomorrow_extralight.name
                                pixelSize: 15
                            }
                        }
                    }
                }
            }

            TableViewColumn {
                id: statusColumn
                role: "status"
                //% "Status"
                title: qsTrId("tx-table-status")
                // width: transactionsTable.getAdjustedColumnWidth(statusColumn) // 100 * transactionsTable.columnResizeRatio
                width: 280 * transactionsTable.columnResizeRatio
                //width: implicitWidth
                movable: false
                resizable: false
                delegate: Item {
                    property var myModel: model

                    width: parent.width
                    Layout.fillWidth: true

                    RowLayout {
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: transactionsTable.rowHeight
                        width: parent.width
                        id: statusRow

                        SFTextInput {
                            text: styleData && styleData.value ? styleData.value : ""
                            color: {
                                if (!model || model.isExpired) {
                                    color:  '#ffffff'
                                }
                                if (model.isInProgress) {
                                    return 'yellow';
                                }
                                if (model.isCompleted && model.isIncome) {
                                    return model.isShieldedTx ? '#4cbd7b' : 'white';
                                }
                                if (model.isCompleted && !model.isIncome) {
                                    //if (model.isSelfTransaction) {
                                    //    return Style.content_main;
                                    //}
                                    return model.isShieldedTx ? '#4cbd7b' : 'white';
                                } else if (model.isFailed) {
                                    return Style.accent_fail;
                                }
                                else {
                                    color: '#ffffff'
                                }
                            }
                            font.pixelSize: 15
                            font.capitalization: Font.AllUppercase
                            font.weight: Font.Bold
                            font.family:  tomorrow_extralight.name
                            disableBorder: true
                            readOnly: true
                            selectByMouse: true
                            leftPadding: 40
                            rightPadding: 40
                            width: 280 * transactionsTable.columnResizeRatio
                            Layout.preferredWidth: width
                            Layout.maximumWidth: width
                            //Layout.alignment: Qt.AlignCenter
                            horizontalAlignment: {
                                console.log('contentWidth: ' + contentWidth);
                                console.log('width: ' + width);


                                return contentWidth > width ? Text.AlignRight : Text.AlignHCenter
                            }
                        }

                        SFLabel {
                            visible: false
                            font.pixelSize:  15
                            font.family:  tomorrow_extralight.name
                            font.capitalization: Font.AllUppercase
                            font.weight: Font.Bold
                            width: 200 * transactionsTable.columnResizeRatio
                            Layout.preferredWidth: 200 * transactionsTable.columnResizeRatio
                            Layout.maximumWidth: 200 * transactionsTable.columnResizeRatio
                            Layout.alignment: Qt.AlignCenter
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            wrapMode: Text.WordWrap
                            text: styleData && styleData.value ? styleData.value : ""
                            color: {
                                if (!model || model.isExpired) {
                                    color:  '#ffffff'
                                }
                                if (model.isInProgress) {
                                    return 'yellow';
                                }
                                if (model.isCompleted && model.isIncome) {
                                    return model.isShieldedTx ? '#4cbd7b' : 'white';
                                }
                                if (model.isCompleted && !model.isIncome) {
                                    //if (model.isSelfTransaction) {
                                    //    return Style.content_main;
                                    //}
                                    return model.isShieldedTx ? '#4cbd7b' : 'white';
                                } else if (model.isFailed) {
                                    return Style.accent_fail;
                                }
                                else {
                                    color: '#ffffff'
                                }
                            }
                        }
                    }
                }
            }

            /*TableViewColumn {
                id: actionsColumn
                elideMode: Text.ElideRight
                width: 40
                movable: false
                resizable: false
                delegate: txActions
            }*/

            function showContextMenu(row) {
                if (transactionsTable.model.getRoleValue(row, "isContractTx"))
                {
                    //contractTxContextMenu.deleteEnabled = transactionsTable.model.getRoleValue(row, "isDeleteAvailable");
                    //contractTxContextMenu.txID = transactionsTable.model.getRoleValue(row, "rawTxID");
                    //contractTxContextMenu.popup();
                }
                else
                {
                    //txContextMenu.cancelEnabled = transactionsTable.model.getRoleValue(row, "isCancelAvailable");
                    //txContextMenu.deleteEnabled = transactionsTable.model.getRoleValue(row, "isDeleteAvailable");
                    //txContextMenu.txID = transactionsTable.model.getRoleValue(row, "rawTxID");
                    //txContextMenu.popup();
                }
            }

            Component {
                id: txActions
                Item {
                    Item {
                        width: parent.width
                        height: transactionsTable.rowHeight
                        CustomToolButton {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            icon.source: "qrc:/assets/icon-actions.svg"
                            //% "Actions"
                            ToolTip.text: qsTrId("general-actions")
                            onClicked: {
                                transactionsTable.showContextMenu(styleData.row);
                            }
                        }
                    }
                }
            }

            function showDeleteTransactionDialog(txId) {
                //% "The transaction will be deleted. This operation can not be undone"
                deleteTransactionDialog.text = qsTrId("wallet-txs-delete-message");
                deleteTransactionDialog.txID = txId;
                deleteTransactionDialog.open();
            }

            ContextMenu {
                id: txContextMenu
                visible: false
                modal: true
                dim: false
                property bool cancelEnabled
                property bool deleteEnabled
                property var txID

                Action {
                    //% "Show details"
                    text: qsTrId("general-show-tx-details")
                    icon.source: "qrc:/assets/icon-show_tx_details.svg"
                    onTriggered: {
                        transactionsTable.showDetails(txContextMenu.txID);
                    }
                }

                Action {
                    //% "Cancel"
                    text: qsTrId("general-cancel")
                    icon.source: "qrc:/assets/icon-cancel-white.svg"
                    enabled: txContextMenu.cancelEnabled
                    onTriggered: {
                        tableViewModel.cancelTx(txContextMenu.txID);
                    }
                }
                Action {
                    //% "Delete"
                    text: qsTrId("general-delete")
                    icon.source: "qrc:/assets/icon-delete.svg"
                    enabled: txContextMenu.deleteEnabled
                    onTriggered: {
                        transactionsTable.showDeleteTransactionDialog(txContextMenu.txID);
                    }
                }
            }

            ContextMenu {
                id: contractTxContextMenu
                modal: true
                dim: false
                property bool deleteEnabled
                property var txID

                Action {
                    //% "Show details"
                    text: qsTrId("general-show-tx-details")
                    icon.source: "qrc:/assets/icon-show_tx_details.svg"
                    onTriggered: {
                        transactionsTable.showDetails(contractTxContextMenu.txID);
                    }
                }

                Action {
                    //% "Delete"
                    text: qsTrId("general-delete")
                    icon.source: "qrc:/assets/icon-delete.svg"
                    enabled: contractTxContextMenu.deleteEnabled
                    onTriggered: {
                        transactionsTable.showDeleteTransactionDialog(contractTxContextMenu.txID);
                    }
                }
            }
        }

        Item {
            visible:              transactionsTable.model.count > 0

            Rectangle {
                id: line
                anchors.fill: transactionsTable
                y: 50
                x: 80 * transactionsTable.columnResizeRatio
                height: transactionsTable.height
                width: 1
                color: '#112a26'
            }


            Rectangle {
                id: line1
                anchors.fill: transactionsTable
                y: 50
                x: (140 * transactionsTable.columnResizeRatio)
                height: transactionsTable.height
                width: 1
                color: '#112a26'
            }


            Rectangle {
                id: line2
                anchors.fill: transactionsTable
                y: 50
                x: (240 * transactionsTable.columnResizeRatio)
                height: transactionsTable.height
                width: 1
                color: '#112a26'
            }


            Rectangle {
                id: line3
                anchors.fill: transactionsTable
                y: 50
                x: (340 * transactionsTable.columnResizeRatio)
                height: transactionsTable.height
                width: 1
                color: '#112a26'
            }


            Rectangle {
                id: line4
                anchors.fill: transactionsTable
                y: 50
                x: (420 * transactionsTable.columnResizeRatio)
                height: transactionsTable.height
                width: 1
                color: '#112a26'
            }
        }
    }
}
