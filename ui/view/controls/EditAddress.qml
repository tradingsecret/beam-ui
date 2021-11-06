import QtQuick 2.11
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import "../utils.js" as Utils
import "."

CustomDialog {
	id:      control
	modal:   true
	x:       (parent.width - width) / 2
	y:       (parent.height - height) / 2
    padding: 80
    leftPadding: 60
    //width: 700
    //height: 450


    backgroundImage: "qrc:/assets/popups/popup-12.png"
    width: 718
    height: 528

    FontLoader { id: agency_b;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyB.ttf" }
    FontLoader { id: agency_r;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyR.otf" }

    property var  viewModel
    property var  addressItem
    property bool isShieldedSupported: true

    property var     token:         addressItem.token
    property var     walletID:      addressItem.walletID
    property var     isOldAddr:     addressItem.token == addressItem.walletID
    property string  comment:       addressItem.name
    property var     expiration:    addressItem.expirationDate
    property bool    expired:       expiration < new Date(Date.now())
    property bool    neverExpires:  expiration.getTime() == (new Date(4294967295000)).getTime()
    property bool    commentValid:  comment == "" || comment == addressItem.name || viewModel.commentValid(comment)
    property bool    extended:      false

    contentItem: Item {
        Layout.fillHeight: true

        ColumnLayout {
            spacing: 0
            Layout.margins: 80
            Layout.leftMargin: 60
            Layout.fillHeight: true
            width: 600 //isShieldedSupported

            SFText {
                Layout.alignment: Qt.AlignHCenter
                //% "Edit address"
                text: qsTrId("edit-addr-title")
                color: Style.content_main
                font.pixelSize: 30
                font.bold: true
                font.letterSpacing: 4
                font.family: agency_b.name
                font.capitalization: Font.AllUppercase
                font.weight: Font.Bold
            }


            RowLayout {
                Layout.topMargin: 30
                Layout.alignment: Qt.AlignCenter
                anchors.horizontalCenter: parent.horizontalCenter

                SFText {
                    //% "Expires on"
                    text: qsTrId("edit-addr-expires-label") + ":"
                    color:            Style.content_main
                    font.pixelSize:   18
                    font.letterSpacing: 2
                    font.family: agency_r.name
                    font.capitalization: Font.AllUppercase
                }

                SFText {
                    text: control.expired ?
                        //% "This address is already expired"
                        qsTrId("edit-addr-expired") :
                        //% "This address never expires"
                        Utils.formatDateTime(control.expiration, BeamGlobals.getLocaleName(), qsTrId("edit-addr-never-expires"))

                    color: Style.content_main
                    font.pixelSize:   18
                    font.letterSpacing: 2
                    font.bold: true
                    font.weight: Font.Bold
                    font.family: agency_r.name
                    font.capitalization: Font.AllUppercase
                }
            }

            SFText {
                Layout.topMargin: 20
                //% "Address"
                text: qsTrId("edit-addr-addr")
                color: Style.content_main
                font.pixelSize: 14
                font.weight: Font.Bold
                visible: false
            }

            ScrollView {
                Layout.topMargin: 30
                Layout.leftMargin: 20
                Layout.rightMargin: 20
                Layout.maximumHeight:         200
                Layout.preferredWidth:        555 //control.isOldAddr ? 510: 582
                clip:                         true
                ScrollBar.horizontal.policy:  ScrollBar.AlwaysOff
                ScrollBar.vertical.policy:    ScrollBar.AsNeeded

                SFLabel {
                    id:                       addressID
                    width:                    555 //control.isOldAddr ? 490: 562
                    copyMenuEnabled:          true
                    wrapMode:                 Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize:           18
                    color:                    '#44f56a'
                    font.capitalization: Font.AllUppercase
                    text:                     {
                        var address = isShieldedSupported ? control.token : control.walletID;
                        return control.isOldAddr ? address : address.substring(0, address.length - 150);
                    }
                    Layout.alignment: Qt.AlignCenter

                    onCopyText: function () {
                        BeamGlobals.copyToClipboard(isShieldedSupported ? control.token : control.walletID)
                    }
                }
            }

            Row {
                visible: false
                spacing: 15
                Layout.topMargin: 10

                LinkButton {
                    visible:  !control.expired
                    fontSize: 13

                    //% "Expire now"
                    text: qsTrId("edit-addr-expire-now")
                    enabled: !viewModel.isWIDBusy(control.walletID)

                    onClicked: {
                        var newExpiration = new Date(Date.now() - 1000)
                        control.expiration = newExpiration
                    }
                }

                LinkButton {
                    fontSize: 13
                    visible: !control.neverExpires && (control.expired || !control.extended)

                    text: control.expired ?
                        //% "Activate"
                        qsTrId("edit-addr-activate") :
                        //% "Extend"
                        qsTrId("edit-addr-extend")

                    onClicked: {
                        var newExpiration = new Date()
                        newExpiration.setDate(newExpiration.getDate() + 61)
                        control.expiration = newExpiration
                        control.extended = true
                    }
                }
            }

            SFText {
                //% "There is an active transaction for this address, therefore it cannot be expired."
                text: qsTrId("edit-addr-no-expire")
                color:            Style.content_secondary
                Layout.topMargin: 7
                font.pixelSize:   13
                font.italic:      true
                visible:          viewModel.isWIDBusy(control.walletID)
            }

            SFText {
                //% "Comment"
                text: qsTrId("general-comment")
                visible: false

                Layout.topMargin: 25
                color:            Style.content_main
                font.pixelSize:   14
                font.styleName:   "Bold";
                font.weight:      Font.Bold
            }

            ColumnLayout {
                visible: false
                Layout.fillWidth: true
                Layout.preferredWidth: addressID.width
                spacing: 0

                SFTextInput {
                    id: addressName
                    Layout.preferredWidth: addressID.width

                    font.pixelSize:  14
                    font.italic :    !control.commentValid
                    backgroundColor: control.commentValid ? Style.content_main : Style.validator_error
                    color:           control.commentValid ? Style.content_main : Style.validator_error
                    text:            control.comment
                }

                Item {
                    Layout.fillWidth: true
                    SFText {
                        //% "Address with the same comment already exists"
                        text:    qsTrId("general-addr-comment-error")
                        color:   Style.validator_error
                        visible: !control.commentValid
                        font.pixelSize: 12
                    }
                }
            }

            Binding {
                target: control
                property: "comment"
                value: addressName.text
            }

            RowLayout {
                visible: false
                Layout.topMargin: 30
                Layout.alignment: Qt.AlignHCenter
                spacing: 15

                CustomButton {
                    Layout.preferredHeight: 40

                    //% "Cancel"
                    text:        qsTrId("general-cancel")
                    icon.color:  Style.content_main

                    onClicked: {
                        control.destroy()
                    }
                }

                PrimaryButton {
                    id: saveButton
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignHCenter

                    //% "Save"
                    text: qsTrId("edit-addr-save-button")
                    enabled: control.commentValid &&
                             (
                               control.comment !==  addressItem.name ||
                               control.expiration.getTime() !==  addressItem.expirationDate.getTime()
                            )

                    onClicked: {
                        viewModel.saveChanges(control.walletID, control.comment, control.expiration)
                        control.destroy()
                    }
                }
            }

            Rectangle {
                //border.width: 1
                //border.color: 'purple'
                color: 'transparent'
                anchors.fill: parent

            }
        }
    }

    footer: Control {
        contentItem: RowLayout {
            Item {
                Layout.fillWidth: true
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                Layout.alignment: Qt.AlignCenter
                spacing: 20
                bottomPadding: 95

                CustomButton {
                    Layout.alignment: Qt.AlignCenter | Qt.AlignBottom
                    palette.button: Style.background_second
                    palette.buttonText : Style.content_main
                    text: 'Close'

                    onClicked: {
                        control.close();
                    }
                }

                CustomButton {
                    Layout.alignment: Qt.AlignCenter | Qt.AlignBottom
                    palette.button: Style.background_second
                    palette.buttonText : Style.content_main
                    text: 'Copy and close'

                    onClicked: {
                        BeamGlobals.copyToClipboard(isShieldedSupported ? control.token : control.walletID);
                        control.close();
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }
        }
    }
}
