import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtQuick.Shapes 1.0
import QtGraphicalEffects 1.0
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import "controls"
import "./utils.js" as Utils

ColumnLayout {
    id: control

    ReceiveViewModel {
        id: viewModel

        onNewAddressFailed: function () {
            var popup = Qt.createComponent("popup_message.qml").createObject(control)
            //% "You cannot generate new address. Your wallet doesn't have a master key."
            popup.message = qsTrId("can-not-generate-new-address-message")
            popup.open()
        }
    }

    property var defaultFocusItem: null
    property var onClosed: function () {} // set by parent
    property bool isShieldedSupported: true//statusbarModel.isConnectionTrusted && statusbarModel.isOnline

    property alias token:     viewModel.token
    property alias assetId:   viewModel.assetId
    property alias assetIdx:  amountInput.currencyIdx
    property var   assetInfo: viewModel.assetsList[control.assetIdx]

    function syncIdx () {
        for (var idx = 0; idx < viewModel.assetsList.length; ++idx) {
            if (viewModel.assetsList[idx].assetId == assetId) {
                 if (assetIdx != idx) {
                    assetIdx = idx
                 }
            }
        }
    }

    onAssetIdChanged: function () {
        // C++ sometimes provides asset id, combobox exepects index, need to fix this at some point
        syncIdx()
    }

    Component.onCompleted: function () {
        // asset id might be passed by other parts of the UI as a parameter to the receive view
        syncIdx()
    }

    Component.onDestruction: function () {
        viewModel.saveAddress()
    }

    TopGradient {
        mainRoot: main
        topColor: Style.accent_incoming
    }

    TokenInfoDialog {
        id:       tokenInfoDialog
        token:    viewModel.token
        incoming: true
        isShieldedSupported: control.isShieldedSupported
    }

    function isValid () {
        return viewModel.commentValid
    }

    function copyAndClose() {
        if (isValid()) {
            BeamGlobals.copyToClipboard(control.isShieldedSupported ? viewModel.token : viewModel.sbbsAddress);
            viewModel.saveAddress();
            control.onClosed()
        }
    }

    function copyAndSave() {
         if (isValid()) {
            BeamGlobals.copyToClipboard(control.isShieldedSupported ? viewModel.token : viewModel.sbbsAddress);
            viewModel.saveAddress();
         }
    }

    //
    // Title row
    //
    SubtitleRow {
        Layout.fillWidth:    true
        Layout.topMargin:    100
        Layout.bottomMargin: 30

        //% "Receive"
        text: qsTrId("wallet-receive-title")
        onBack: function () {
            control.onClosed()
        }

        visible: false
    }

    QR {
        id: qrCode
        address: control.isShieldedSupported ? viewModel.token : viewModel.sbbsAddress
    }

    ScrollView {
        id:                  scrollView
        Layout.fillWidth:    true
        Layout.fillHeight:   true
        Layout.bottomMargin: 10
        clip:                true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy:   ScrollBar.AsNeeded

        ColumnLayout {
            width: scrollView.availableWidth

            RowLayout {
                ColumnLayout {
                    Row {
                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                        Layout.topMargin: 30
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

                ColumnLayout {
                    CustomButton {
                        id: backBtn
                        Layout.alignment: Qt.AlignTop | Qt.AlignRight
                        Layout.leftMargin: 65

                        //anchors.verticalCenter: parent.verticalCenter
                        anchors.left:   parent.right

                        palette.button: "transparent"
                        leftPadding:    0
                        showHandCursor: true

                        //% "Back"
                        text:         "<= " + qsTrId("general-back")
                        //visible:      true

                        //onClicked: control.onClosed
                        onClicked: {
                            updateItem(0);
                            //control.onClosed();
                        }
                        customColor: 'white'
                        disableBorders: true

                        //background.border.width: 0
                        //contentItem.color: 'white'
                    }
                }
            }

            Row {
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.topMargin: 25
                spacing: 20

                CustomButton {
                    height: 38
                    id: sendButton
                    palette.button: Style.accent_outgoing
                    palette.buttonText: Style.content_opposite
                    //% "Send"
                    text: qsTrId("general-send")
                    enabled: true
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
                    enabled: false
                    onClicked: {
                        navigateReceive(assets.selectedId);
                    }
                    width: 200
                }
            }

            Item {
                Layout.fillHeight: true
            }

            //
            // Content row
            //
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                //
                // Left column
                //
                ColumnLayout {
                    Layout.alignment:       Qt.AlignTop
                    Layout.fillWidth:       true
                    Layout.preferredWidth:  400
                    spacing:                10

                    Panel {
                        //% "Address"
                        title: viewModel.isMaxPrivacy ? qsTrId("receive-anonymous-addr") : qsTrId("receive-addr")
                        Layout.fillWidth: true
                        backgroundColor: 'transparent'

                        content: ColumnLayout {
                            spacing: 12

                            RowLayout {
                                spacing: 0

                                ColumnLayout {
                                    id: controlCopy
                                    spacing: 0

                                    Layout.fillWidth:   true
                                    Layout.alignment:   Qt.AlignVCenter

                                    SFText {
                                        Layout.fillWidth:   true
                                        text:  control.isShieldedSupported ? viewModel.token : viewModel.sbbsAddress
                                        width: parent.width
                                        //color: Style.content_main
                                        elide: Text.ElideMiddle
                                        font.pixelSize: 18
                                        color:          '#bb69dd'
                                    }

                                    Rectangle {
                                            id: backgroundRect
                                            //y: 20
                                            height: 0
                                            //width: control.width - (control.leftPadding + control.rightPadding)
                                            //height: dottedBorder ? 0 : 1 //control.activeFocus || control.hovered ? 1 : 1
                                            //opacity: dottedBorder ? 1 : ((control.activeFocus || control.hovered)? 0.3 : 0.1)
                                            anchors.fill: parent
                                            color: 'transparent'

                                            Shape {
                                                anchors.fill: parent

                                                ShapePath {
                                                    strokeColor: "#616360"
                                                    strokeWidth: 2
                                                    strokeStyle: ShapePath.DashLine
                                                    startX: 0
                                                    startY: 23
                                                    PathLine { x: backgroundRect.width; y: 23 }
                                                }
                                                visible: true
                                            }
                                        }
                                }

                                Image {
                                    Layout.alignment: Qt.AlignVCenter
                                    //Layout.topMargin: 20

                                    source: "qrc:/assets/copy-icon.png"
                                    sourceSize: Qt.size(32, 32)
                                    //opacity: control.isValid() ? 1.0 : 0.45

                                    MouseArea {
                                        anchors.fill: parent
                                        acceptedButtons: Qt.LeftButton
                                        cursorShape: control.isValid() ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: function () {
                                                control.copyAndSave()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    //
                    // Requested amount
                    //
                    Panel {
                        //% "Requested amount"
                        title:                  qsTrId("receive-request")
                        //titleCapitalization:    Font.Normal
                        //% "(optional)"
                        titleTip:               qsTrId("receive-request-optional")
                        //Layout.fillWidth:       true
                        backgroundColor: 'transparent'
                        //folded:                 false
                        //
                        // Amount
                        //
                        content: Grid {
                            Layout.alignment: Qt.AlignHCenter
                            columns: 2
                            //Layout.fillWidth: true

                            ColumnLayout {
                                width: 250
                                Layout.fillWidth: true

                                AmountInput {
                                    id:          amountInput
                                    amount:      viewModel.amount
                                    currencies:  viewModel.assetsList
                                    multi:       viewModel.assetsList.length > 1
                                    resetAmount: false
                                    showRate:    false
                                    color:       '#56d288'

                                   onCurrencyIdxChanged: function () {
                                       var idx = amountInput.currencyIdx
                                       control.assetId = viewModel.assetsList[idx].assetId
                                   }
                                }

                                Binding {
                                    target:   viewModel
                                    property: "amount"
                                    value:    amountInput.amount
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.topMargin: -40

                        SFText {
                            padding: 20
                            visible:        true
                            font.pixelSize: 14
                            font.italic:    true
                            color:          '#616360'
                            text:           qsTrId("general-exchange-rate-not-available").arg(control.rateUnit)
                        }
                    }

                    ColumnLayout {
                        Layout.alignment:       Qt.AlignHCenter

                        CustomButton {
                            id: copyButton
                            Layout.topMargin:       30
                            customColor:            '#5fe795'
                            customBorderColor:      '#5fe795'
                            Layout.alignment:       Qt.AlignHCenter
                            //% "copy and close"
                            text:                   qsTrId("general-copy-and-close")
                            Layout.preferredHeight: 38
                            palette.buttonText:     Style.content_opposite
                            icon.color:             Style.content_opposite
                            palette.button:         Style.accent_incoming
                            enabled:                control.isValid()

                            onClicked: function () {
                                control.copyAndClose()
                            }
                        }

                        //
                        // Footers
                        //
                        SFText {
                            visible: false
                            property string mpLockTimeLimit: viewModel.mpTimeLimit
                            Layout.alignment:      Qt.AlignHCenter
                            Layout.preferredWidth: 428
                            Layout.topMargin:      15
                            font.pixelSize:        14
                            font.italic:           true
                            color:                 Style.content_disabled
                            wrapMode:              Text.WordWrap
                            horizontalAlignment:   Text.AlignHCenter
                            //visible:               viewModel.isMaxPrivacy
                            text: qsTrId("wallet-receive-text-offline-time")
                        }

                        SFText {
                            visible: false
                            //% "For an online payment to complete, you should get online during the 12 hours after coins are sent."
                            property string stayOnline: qsTrId("wallet-receive-stay-online")
                            Layout.alignment:      Qt.AlignHCenter
                            Layout.preferredWidth: 400
                            Layout.topMargin:      15
                            Layout.bottomMargin:   50
                            font.pixelSize:        14
                            font.italic:           true
                            color:                 Style.content_disabled
                            wrapMode:              Text.WordWrap
                            horizontalAlignment:   Text.AlignHCenter
                            text: control.isShieldedSupported
                                //% "Sender will be given a choice between online and offline payment."
                                ? qsTrId("wallet-receive-text-online-time") + "\n" + stayOnline
                                //% "Connect to integrated or own node to enable receiving maximum anonymity set and offline transactions."
                                : qsTrId("wallet-receive-max-privacy-unsupported") + "\n" + stayOnline
                            //visible:               !viewModel.isMaxPrivacy
                        }
                    }
                }

                //
                // Right column
                //
                ColumnLayout {
                    Layout.alignment:       Qt.AlignTop
                    Layout.fillWidth:       true
                    Layout.preferredWidth:  400
                    spacing:                10

                    //
                    // Comment
                    //
                    Panel {
                        //% "Comment"
                        title:                  qsTrId("general-comment")
                        //titleCapitalization:    Font.Normal
                        Layout.fillWidth:       true
                        //folded:                 false
                        backgroundColor: 'transparent'

                        content: ColumnLayout {
                            spacing: 0

                            SFTextInput {
                                id:                commentInput
                                font.pixelSize:    14
                                Layout.fillWidth:  true
                                dottedBorder:      true
                                dottedBorderColor: '#616360'
                                font.italic :      !viewModel.commentValid
                                backgroundColor:   viewModel.commentValid ? Style.content_main : Style.validator_error
                                color:             viewModel.commentValid ? Style.content_main : Style.validator_error
                                focus:             true
                                text:              viewModel.comment
                                placeholderText:   qsTrId("general-comment-local")
                                maximumLength:     BeamGlobals.maxCommentLength()
                            }

                            Binding {
                                target:   viewModel
                                property: "comment"
                                value:    commentInput.text
                            }

                            Item {
                                Layout.fillWidth: true
                                SFText {
                                    //% "Address with the same comment already exists"
                                    text:           qsTrId("general-addr-comment-error")
                                    color:          Style.validator_error
                                    font.pixelSize: 12
                                    visible:        !viewModel.commentValid
                                    font.italic:    true
                                }
                            }
                        }
                    }

                    Panel {
                        //% "Advanced"
                        title: qsTrId("general-advanced")
                        Layout.fillWidth: true
                        backgroundColor: 'transparent'
                        //folded: false

                        content: ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            id: addressType
                            // property bool isShieldedSupported: statusbarModel.isConnectionTrusted && statusbarModel.isOnline

                            ColumnLayout {
                                width: 500//parent.parent.width
                                height: 126
                                Layout.fillWidth: true

                                SFText {
                                    Layout.topMargin:      50
                                    Layout.leftMargin:     200
                                    color:                 viewModel.isMaxPrivacy ? '#3b3d3f' : '#0e84e9'
                                    wrapMode:              Text.WordWrap
                                    horizontalAlignment:   Text.AlignHCenter
                                    font.pixelSize:        20
                                    //visible:               viewModel.isMaxPrivacy
                                    text: 'Regular transaction'
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: 'transparent'
                                    //width: 1000

                                    Image {
                                        fillMode: Image.Stretch
                                        //anchors.fill: parent

                                        source: {
                                             viewModel.isMaxPrivacy ? "qrc:/assets/tx_public-default" : "qrc:/assets/tx_public-active"
                                        }
                                    }

                                    MouseArea {
                                      anchors.fill: parent
                                      onClicked: {
                                          viewModel.isMaxPrivacy = false
                                      }
                                    }
                                }
                            }


                            ColumnLayout {
                                width: 500//parent.parent.width
                                height: 126
                                Layout.fillWidth: true
                                Layout.topMargin: -75

                                SFText {
                                    Layout.topMargin:      50
                                    Layout.leftMargin:     200
                                    color:                 viewModel.isMaxPrivacy ? '#0e84e9' : '#3b3d3f'
                                    wrapMode:              Text.WordWrap
                                    horizontalAlignment:   Text.AlignHCenter
                                    font.pixelSize:        20
                                    //visible:               viewModel.isMaxPrivacy
                                    text: 'Anonymous transaction'
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    color: 'transparent'
                                    //width: 1000

                                    Image {
                                        //x: 20
                                        //y: 20
                                       // Layout.alignment: Qt.AlignVCenter
                                       // width: 90
                                       // height: 75
                                        //anchors.fill: parent
                                        fillMode: Image.Stretch
                                        //anchors.fill: parent

                                        source: {
                                             viewModel.isMaxPrivacy ? "qrc:/assets/tx_anonymous-active" :  "qrc:/assets/tx_anonymous-default"
                                        }
                                    }

                                    MouseArea {
                                      anchors.fill: parent
                                      onClicked: {
                                          viewModel.isMaxPrivacy = true
                                      }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }  // ColumnLayout
    }  // ScrollView
}
