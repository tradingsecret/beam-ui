import QtQuick 2.11
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import "."

CustomDialog {
	property var settingsViewModel: function() {
		return {
			checkWalletPassword: function() {
				console.log("settingsViewModel::checkWalletPassword undefined")
				return false
			}
		}
	}

    FontLoader { id: agency_b;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyB.ttf" }
    FontLoader { id: agency_r;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyR.otf" }

	property string dialogTitle: "title"
	property string dialogMessage: "message"
	property alias okButtonText: okButton.text
    property var okButtonIcon
	property alias cancelButtonText: cancelButton.text
    property var cancelButtonIcon
	property alias pwd: pwd.text
	property bool showError: false
	property var onDialogAccepted: function() {
		console.log("Accepted");
	}
	property var onDialogRejected: function() {
		console.log("Rejected");
	}
	property var onPwdEntered: function(password) {
		if (settingsViewModel.checkWalletPassword(password)) {
			accept();
		} else {
			showError = true;
			pwd.selectAll();
			pwd.focus = true;
		}
	}

	modal: true

    x: (parent.width - width) / 2
	y: (parent.height - height) / 2
	visible:        false
	parent:         Overlay.overlay
    topPadding: 80
    bottomPadding: 80
    leftPadding: 100
    rightPadding: 100

    backgroundImage: "qrc:/assets/popups/popup-8.png"
    width: 710
    height: 426

    contentItem: ColumnLayout {
        spacing: 30
        Layout.leftMargin: 50
        Layout.rightMargin: 50

		SFText {
			Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
			text: dialogTitle
			color: Style.content_main
            horizontalAlignment: Text.AlignHCenter
            font.letterSpacing: 4
            font.family: agency_b.name
            font.capitalization: Font.AllUppercase
            font.pixelSize: 30
            font.weight: Font.Bold
		}

		ColumnLayout {
            Layout.fillWidth:		true
			SFText {
                Layout.fillWidth:		true
				Layout.alignment:		Qt.AlignHCenter
                text:					dialogMessage
                color:					Style.content_main
                font.letterSpacing: 2
                font.family: agency_r.name
                font.capitalization: Font.AllUppercase
                font.pixelSize: 18
				wrapMode:				Text.Wrap
			}

			SFTextInput {
				id: pwd
				Layout.alignment: Qt.AlignHCenter
				Layout.fillWidth: true
				font.pixelSize: 14
				rightPadding:   0
				color: showError ? Style.validator_error : Style.content_main
				backgroundColor: showError ? Style.validator_error : Style.content_main
				echoMode: TextInput.Password
				onTextEdited: {
					showError = false;
				}
				Keys.onEnterPressed: {
					onPwdEntered(text);
				}
				Keys.onReturnPressed: {
					onPwdEntered(text);
				}
			}

			Item {
				Layout.preferredHeight: 16
				Layout.topMargin: -5
				SFText {
					Layout.fillWidth: true
					Layout.alignment: Qt.AlignHCenter
					color: Style.validator_error
					font.pixelSize: 12
                    font.family: agency_r.nameы
					//% "Please, enter password"
					text: qsTrId("general-pwd-empty-error")
					visible: showError && !pwd.text.length
				}
				SFText {
					Layout.fillWidth: true
					Layout.alignment: Qt.AlignHCenter
					color: Style.validator_error
					font.pixelSize: 12
                    font.family: agency_r.name
					//% "Invalid password provided"
					text: qsTrId("general-pwd-invalid")
					visible: showError && pwd.text.length
				}
			}
		}			 	

		RowLayout {
			spacing: 20
			Layout.topMargin: -10
			Layout.alignment: Qt.AlignHCenter

			CustomButton {
				id: cancelButton
				//% "Cancel"
				text: qsTrId("general-cancel")
				onClicked: reject()
			}

            CustomButton {
				id: okButton
				//: confirm password dialog, ok button
				//% "Proceed"
				text: qsTrId("general-proceed")
				enabled: !showError
				onClicked: {
					onPwdEntered(pwd.text);
				}
			}
		}
    }

	onOpened: {
		pwd.text = "";
		showError = false;
		pwd.forceActiveFocus(Qt.TabFocusReason);
	}

	onAccepted: {
		if (typeof onDialogRejected == "function") {
			onDialogAccepted();
		}
	}
	onRejected: {
		if (typeof onDialogRejected == "function") {
			onDialogRejected();
		}
	}	
}
