import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
import "controls"
import "utils.js" as Utils
import Beam.Wallet 1.0
import QtQuick.Layouts 1.12

Item
{
    id: rootLoading

    property bool isRecoveryMode: false
    property alias isCreating: viewModel.isCreating
    property var cancelCallback: undefined

    FontLoader { id: agency_b;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyB.ttf" }
    FontLoader { id: agency_r;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyR.otf" }

    ConfirmationDialog {
        id: confirmationDialog
        okButtonColor: Style.active
        //% "Try again"
        okButtonText: qsTrId("loading-try-again-button")
        okButtonIconSource: "qrc:/assets/icon-restore-blue.svg"
        //% "Change settings"
        cancelButtonText: qsTrId("general-change-settings")
        cancelButtonIconSource: "qrc:/assets/icon-settings-white.svg"
        backgroundImage: "qrc:/assets/popups/popup-1.png"
        width: 612
        height: 366
        footerBottomPadding: 95
        cancelButtonWidth: 140

        property alias titleText: title.text
        property alias messageText: message.text
        property var rejectedCallback

        contentItem: Item {
            id: confirmationContent
            ColumnLayout {
                anchors.fill: parent
                //spacing: 10

                SFText {
                    id: title
                    Layout.alignment: Qt.AlignHCenter
                    //Layout.minimumHeight: 21
                    Layout.leftMargin: 68
                    Layout.rightMargin: 68
                    Layout.topMargin: 70
                    font.pixelSize: 30
                    font.bold: true
                    font.letterSpacing: 2
                    font.family: agency_b.name
                    font.capitalization: Font.AllUppercase
                    font.weight: Font.Bold;
                    color: 'red'
                }

                SFText {
                    id: message
                    Layout.alignment: Qt.AlignHCenter
                    //Layout.minimumHeight: 18
                    Layout.topMargin: 35
                    Layout.leftMargin: 60
                    Layout.rightMargin: 60
                    //Layout.bottomMargin: 50
                    font.family: agency_r.name;
                    font.capitalization: Font.AllUppercase
                    font.pixelSize: 20
                    font.bold: true
                    font.letterSpacing: 2
                    color: Style.content_main
                }

                Rectangle {
                    anchors.fill: parent
                    color: 'transparent'
                }
            }
        }

        onRejected: {
            if (rejectedCallback) rejectedCallback();
        }
    }

    LoadingViewModel {
        id: viewModel 
        onSyncCompleted: {
            if (isRecoveryMode || isCreating)
                root.parent.source = "qrc:/main.qml";
            else
                rootLoading.parent.source = "qrc:/main.qml";
        }

        onWalletError: {
            confirmationDialog.titleText        = title;
            confirmationDialog.messageText      = message;
            confirmationDialog.okButtonVisible  = false;
            confirmationDialog.okButtonEnable   = false;
            confirmationDialog.closePolicy      = Popup.NoAutoClose;
            confirmationDialog.rejectedCallback = cancelCreating //isCreating ? cancelCreating : changeNodeSettings;
            confirmationDialog.open();
        }

        onWalletResetCompleted: {
            if(cancelCallback) {
                cancelCallback();
            }
        }
    }

    function cancelCreating() {
        viewModel.resetWallet();
    }

    function changeNodeSettings () {
        rootLoading.parent.setSource("qrc:/start.qml", {"isBadPortMode": true});
    }

    StartLayout {
        id: startLayout
        anchors.fill:   parent

        Item {
            Layout.fillWidth:   true
            Layout.fillHeight:  true
        }

        //SFText {
        //    Layout.alignment:       Qt.AlignHCenter | Qt.AlignTop
        //    Layout.preferredHeight: 16
        //    text: !isCreating ?
        //            //% "Loading wallet..."
        //            qsTrId("loading-loading") :
        //            ( isRecoveryMode ?
        //                //% "Restoring wallet..."
        //                qsTrId("loading-restoring") :
        //                //% "Creating wallet..."
        //                qsTrId("loading-creating"))
        //    font.pixelSize: 14
        //    color: Style.content_main
        //}

        //SFText {
        //    Layout.topMargin: 6
        //    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
        //    text: viewModel.progressMessage
        //    font.pixelSize: 14
        //    opacity: 0.5
        //    color: Style.content_main
        //}

        CustomProgressBar {
            Layout.alignment: Qt.AlignHCenter
            //Layout.topMargin: startLayout.isSqueezedHeight ? 10 : 24
            //Layout.bottomMargin: 150
            id: bar
            value: viewModel.progress
            visible: false
        }

        Image {
            Layout.alignment: Qt.AlignHCenter
            source: {
                var progress = Math.ceil((viewModel.progress*100));

                if (progress < 10) {
                    return 'qrc:/assets/progress_bar_sequence/00'+progress+'.png';
                }
                else if(progress < 100) {
                    return 'qrc:/assets/progress_bar_sequence/0'+progress+'.png';
                }

                return 'qrc:/assets/progress_bar_sequence/'+progress+'.png';
            }
        }

        //SFText {
        //    Layout.alignment: Qt.AlignHCenter
        //    Layout.topMargin: startLayout.isSqueezedHeight ? 10 : 30
        //    width: 584
        //    //% "Please wait for synchronization and do not close or minimize the application."
        //    text: qsTrId("loading-restore-message-line1")
        //    font.pixelSize: 14
        //    color: Style.content_secondary
        //    font.italic: true
        //    visible: isRecoveryMode
        //}
        //Row {
        //    Layout.alignment: Qt.AlignHCenter
        //    Layout.topMargin: startLayout.isSqueezedHeight ? 10 : 20
        //    SFText {
        //        horizontalAlignment: Text.AlignHCenter
        //        width: 548
        //        height: 30
        //        //% "Only the wallet balance (UTXO) can be restored, transaction info and addresses are always private and never kept in the blockchain."
        //        text: qsTrId("loading-restore-message-line2")
        //        font.pixelSize: 14
        //        color: Style.content_secondary
        //        wrapMode: Text.Wrap
        //        font.italic: true
        //        visible: isRecoveryMode
        //    }
        //}

        //Row {
        //    Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
        //    Layout.topMargin: {
        //        if (startLayout.isSqueezedHeight)
        //            return isRecoveryMode ? 20 : 32;
        //        else
        //            return isRecoveryMode ? 40 : 52;
        //    }

        //    CustomButton {
        //        visible: (isCreating || isRecoveryMode)
        //        enabled: true
        //        //% "Cancel"
        //        text: qsTrId("general-cancel")
        //        icon.source: "qrc:/assets/icon-cancel.svg"
        //        onClicked: {
        //            this.enabled = false;
        //            cancelCreating();
        //        }
        //    }
        //}
        Item {
            Layout.fillWidth:   true
            Layout.fillHeight:  true
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            viewModel.recalculateProgress();
        }
    }
}
