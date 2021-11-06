import QtQuick 2.11
import QtQuick.Controls 2.3
import "."
import Beam.Wallet 1.0

CustomDialog {
	id: control

    FontLoader { id: agency_b;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyB.ttf" }
    FontLoader { id: agency_r;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyR.otf" }

	property var settingsViewModel: function() {
		var checkWalletPassword = function() {
			console.log("settingsViewModel::checkWalletPassword undefined");
		}
		var changeWalletPassword = function() {
			console.log("settingsViewModel::changeWalletPassword undefined");
		}
	}

	modal: true

    backgroundImage: "qrc:/assets/popups/popup-7.png"

    width: 720
    height: 572
	x: (parent.width - width) / 2
	y: (parent.height - height) / 2
	visible: false

    contentItem: Column {
    	anchors.fill: parent
        anchors.margins: 100

    	spacing: 30

		SFText {
			anchors.horizontalCenter: parent.horizontalCenter
			//% "Change wallet password"
			text: qsTrId("general-change-pwd")
			color: Style.content_main
            font.pixelSize: 30
            font.family: agency_b.name
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 4
		}

    	Column
    	{
    		width: parent.width

			SFText {
				//% "Enter old password"
				text: qsTrId("change-pwd-old-pwd-label")
				color: Style.content_main
                font.pixelSize: 18
                font.family: agency_r.name
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 2
			}

			SFTextInput {
				id: oldPass

				width: parent.width

                font.pixelSize: 18
                font.family: agency_r.name
                font.capitalization: Font.AllUppercase
				color: Style.content_main
				echoMode: TextInput.Password
                dottedBorderColor: 'white'
			}    		
    	}

    	Column
    	{
    		width: parent.width

			SFText {
				//% "Enter new password"
				text: qsTrId("change-pwd-new-pwd-label")
                color: Style.content_main
                font.pixelSize: 18
                font.family: agency_r.name
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 2
			}

			SFTextInput {
				id: newPass

				width: parent.width

                font.pixelSize: 18
                font.family: agency_r.name
                font.capitalization: Font.AllUppercase
				color: Style.content_main
				echoMode: TextInput.Password
                dottedBorderColor: 'white'
			}    		
    	}

    	Column
    	{
    		width: parent.width

			SFText {
				//% "Confirm new password"
				text: qsTrId("change-pwd-confirm-pwd-label")
                color: Style.content_main
                font.pixelSize: 18
                font.family: agency_r.name
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 2
			}

			SFTextInput {
				id: confirmPass

				width: parent.width

                font.pixelSize: 18
                font.family: agency_r.name
                font.capitalization: Font.AllUppercase
				color: Style.content_main
				echoMode: TextInput.Password
                dottedBorderColor: 'white'
			}

    	}

		Column  {
			width: parent.width
            //height: error.heigt

			SFText {
				id: error
                color: Style.validator_error
                font.pixelSize: 12
                font.family: agency_r.name
                font.capitalization: Font.AllUppercase
                font.letterSpacing: 2
			}			
		}    	

		Row {
			anchors.horizontalCenter: parent.horizontalCenter
			spacing: 30

			CustomButton {
				//% "Cancel"
				text: qsTrId("general-cancel")
				onClicked: control.close()
			}

            CustomButton {
				//% "Change password"
				text: qsTrId("change-pwd-ok")
				onClicked: {
					if(oldPass.text.length == 0)
					{
						//% "Please, enter old password"
						error.text = qsTrId("change-pwd-old-empty");
					}
					else if(newPass.text.length == 0)
					{
						//% "Please, enter new password"
						error.text = qsTrId("change-pwd-new-empty");
					}
					else if(confirmPass.text.length == 0)
					{
						//% "Please, confirm new password"
						error.text = qsTrId("change-pwd-confirm-empty");
					}
					else if(!settingsViewModel.checkWalletPassword(oldPass.text))
					{
						//% "The old password you have entered is incorrect"
						error.text = qsTrId("change-pwd-old-fail");
					}
					else if(newPass.text == oldPass.text)
					{
						//% "New password cannot be the same as old"
						error.text = qsTrId("change-pwd-new-same-as-old");
					}
					else if(newPass.text != confirmPass.text)
					{
						//% "New password doesn't match the confirm password"
						error.text = qsTrId("change-pwd-confirm-fail");
					}
					else
					{
						settingsViewModel.changeWalletPassword(newPass.text)
						control.close()
					}
				}
			}
		}
    }

	onOpened: {
		oldPass.forceActiveFocus(Qt.TabFocusReason);
		oldPass.text = newPass.text = confirmPass.text = error.text = ""
	}		
}
