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

    property bool copied: false

    Timer {
        id: timer
        running: false
        repeat: false

        property var callback

        onTriggered: callback()
    }

    function setTimeout(callback, delay)
    {
        if (timer.running) {
            console.error("nested calls to setTimeout are not supported!");
            return;
        }
        timer.callback = callback;
        // note: an interval of 0 is directly triggered, so add a little padding
        timer.interval = delay + 1;
        timer.running = true;
    }

    MainViewModel {
        onClipboardChanged: function(message) {
            control.copied = true;
            setTimeout(function() {
                control.copied = false;
            }, 5000);
        }
    }

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
            updateItem(0);
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
        ScrollBar.vertical.policy:   ScrollBar.AlwaysOff
        ScrollBar.vertical.interactive: false
        wheelEnabled: false


        ColumnLayout {
            width: scrollView.availableWidth

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

                    ColumnLayout {
                        anchors.right: parent.right
                        anchors.top: parent.top

                        CustomButton {
                            id: backBtn
                            Layout.alignment: Qt.AlignRight
                            leftPadding: 0
                            rightPadding: 0
                            //Layout.leftMargin: 75

                            //anchors.verticalCenter: parent.verticalCenter
                            //anchors.left:   parent.right

                            palette.button: "transparent"
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

                        Rectangle {
                            visible: true
                            anchors.fill: parent
                            color: 'transparent'
                            //border.width: 3
                            //border.color: 'purple'
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
                        enabled: false
                        onClicked: {
                            navigateReceive(assets.selectedId);
                        }
                        width: 200
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
                        leftPadding: 0

                        content: ColumnLayout {
                            Layout.alignment:       Qt.AlignTop
                            //spacing: 12

                            RowLayout {
                                Layout.alignment:       Qt.AlignTop
                                spacing: 0
                                Layout.topMargin: -5

                                ColumnLayout {
                                    Layout.alignment:       Qt.AlignTop
                                    id: controlCopy
                                    spacing: 0

                                    Layout.fillWidth:   true
                                    //Layout.alignment:   Qt.AlignVCenter

                                    /*SFText {
                                        Layout.fillWidth:   true
                                        text:  control.isShieldedSupported ? viewModel.token : viewModel.sbbsAddress
                                        width: parent.width
                                        //color: Style.content_main
                                        elide: Text.ElideMiddle
                                        font.pixelSize: 18
                                        color:          '#bb69dd'
                                    }*/

                                    SFTextInput {
                                        property bool tokenError:  viewModel.token && !viewModel.tokenValid

                                        Layout.fillWidth:  true
                                        id:                tokenOutput
                                        font.pixelSize:    18
                                        font.italic:       false
                                        dottedBorder:      true
                                        readOnly:          true
                                        dottedBorderColor: '#616360'
                                        color:             '#bb69dd' //tokenError ? Style.validator_error : Style.content_main
                                        backgroundColor:   tokenError ? Style.validator_error : Style.content_main
                                        //font.italic :      tokenError
                                        text:              viewModel.token
                                        validator:         RegExpValidator { regExp: /[0-9a-zA-Z]{1,}/ }
                                        selectByMouse:     true

                                        //% "Paste recipient address here"
                                        placeholderText:  qsTrId("send-contact-address-placeholder")
                                        onTextChanged: function () {
                                            var isSwap = BeamGlobals.isSwapToken(text)
                                            if (isSwap && typeof onSwapToken == "function") {
                                                onSwapToken(text);
                                            }
                                        }
                                    }

                                    Binding {
                                        target:   viewModel
                                        property: control.isShieldedSupported ? "token" : "sbbsAddress"
                                        value:    tokenInput.tokenOutput
                                    }
                                }


                                Image {
                                    Layout.alignment: Qt.AlignVCenter
                                    //Layout.topMargin: 5

                                    source: "qrc:/assets/copy-icon.png"
                                    sourceSize: Qt.size(24, 24)
                                    //opacity: control.isValid() ? 1.0 : 0.45

                                    MouseArea {
                                        anchors.fill: parent
                                        acceptedButtons: Qt.LeftButton
                                        cursorShape: control.isValid() ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: function () {
                                            control.copyAndSave();
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.rightMargin: 45
                                anchors.topMargin: -20
                                //anchors.fill: parent
                                color: 'transparent'
                                //Layout.fillWidth: true
                                //horizontalAlignment: Text.AlignHCenter
                                Layout.alignment:      Qt.AlignRight

                                SFText {
                                    Layout.alignment:      Qt.AlignRight
                                    font.pixelSize:        14
                                    font.italic:           true
                                    color:                 '#bb69dd'
                                    horizontalAlignment:   Text.AlignHCenter
                                    text: control.copied ? "Copied!" : ""
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
                        leftPadding: 0
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

                        ColumnLayout {
                            Layout.topMargin:   30
                            height: 5
                            //Layout.fillWidth: true
                            //horizontalAlignment: Text.AlignHCenter
                            Layout.alignment:      Qt.AlignHCenter

                            SFText {
                                Layout.alignment:      Qt.AlignHCenter
                                font.pixelSize:        14
                                font.italic:           true
                                color:                 '#bb69dd'
                                horizontalAlignment:   Text.AlignHCenter
                                text: control.copied ? "Copied!" : ""
                            }
                        }

                        CustomButton {
                            id: copyButton
                            Layout.topMargin:       5
                            Layout.alignment:       Qt.AlignHCenter
                            //% "copy and close"
                            text:                   qsTrId("general-copy-and-close")
                            Layout.preferredHeight: 38
                            palette.buttonText:     Style.content_opposite
                            icon.color:             Style.content_opposite
                            palette.button:         Style.accent_incoming
                            enabled:                control.isValid()
                            hoveredTextColor:       '#5fe795'
                            textColor:              '#696969'
                            hoveredBorderColor:     '#5fe795'
                            borderColor:            '#696969'

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
                        rightPadding: 0

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
                        visible: true
                        //% "Advanced"
                        title: qsTrId("general-advanced")
                        Layout.fillWidth: true
                        backgroundColor: 'transparent'
                        rightPadding: 0
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
