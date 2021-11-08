import QtQuick 2.11
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import "."

ConfirmationDialog {
    id: thisDialog
    property string pwd: ""

    FontLoader { id: agency_b;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyB.ttf" }
    FontLoader { id: agency_r;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyR.otf" }

    property var settingsViewModel: function() {
		return {
			getOwnerKey: function() {
				console.log("settingsViewModel::getOwnerKey undefined")
				return false
			}
		}
	}

    //: settings tab, show owner key dialog title
    //% "Owner key"
    title: qsTrId("settings-show-owner-key-title")
    okButtonText: qsTrId("general-copy")
    okButtonIconSource: "qrc:/assets/icon-copy-blue.svg"
    cancelButtonIconSource: "qrc:/assets/icon-cancel-white.svg"
    cancelButtonText: qsTrId("general-close")
    cancelButtonVisible: true
    //width: 460
    backgroundImage: "qrc:/assets/popups/popup-9.png"
    width: 720
    height: 572
    footerBottomPadding: 95

    contentItem: Item {
        ColumnLayout {
            anchors.fill: parent
            spacing: 0
            SFLabel {
                id: ownerKeyValue
                Layout.fillWidth: true
                leftPadding: 60
                rightPadding: 60
                topPadding: 15
                font.pixelSize: 18
                color: '#44f56a'
                font.family: agency_r.name
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 2
                wrapMode: Text.WrapAnywhere
                horizontalAlignment : Text.AlignHCenter
                text: ""
                copyMenuEnabled: true
                onCopyText: BeamGlobals.copyToClipboard(text)
            }

            ColumnLayout {
                spacing: 10
                width: parent.width

                RowLayout {
                    width: parent.width
                    Layout.alignment: Qt.AlignCenter

                    SFText {
                        leftPadding: 60
                        color: Style.content_main
                        font.pixelSize: 18
                        font.family: agency_b.name
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 2
                        wrapMode: Text.Wrap
                        horizontalAlignment : Text.AlignHCenter
                        text: "IMPORTANT: "
                        font.weight: Font.Bold
                    }

                    SFText {
                        rightPadding: 60
                        color: Style.content_main
                        font.pixelSize: 18
                        font.family: agency_r.name
                        font.capitalization: Font.AllUppercase
                        font.letterSpacing: 2
                        wrapMode: Text.Wrap
                        horizontalAlignment : Text.AlignHCenter
                        text: "Don't share your private key with anyone."
                    }
                }

                SFText {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                    width: parent.width
                    leftPadding: 60
                    rightPadding: 60
                    color: Style.content_main
                    font.pixelSize: 18
                    font.family: agency_r.name
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 2
                    wrapMode: Text.Wrap
                    horizontalAlignment : Text.AlignHCenter
                    text: "This private key allows access to your wallet funds."
                }
            }
        }
    }

    onAccepted: {
        BeamGlobals.copyToClipboard(ownerKeyValue.text);
    }

    onOpened: {
        ownerKeyValue.text = settingsViewModel.getOwnerKey(thisDialog.pwd);
    }
}
