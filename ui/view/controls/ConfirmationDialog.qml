import QtQuick 2.11
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.12
import "."

CustomDialog {
    id: control

    FontLoader { id: agency_b;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyB.ttf" }
    FontLoader { id: agency_r;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyR.otf" }

    property alias text: messageText.text
    property alias okButton: okButton
    property alias okButtonEnable: okButton.enabled
    property alias okButtonText: okButton.text
    property var okButtonIconSource
    property alias okButtonVisible: okButton.visible
    property alias okButtonColor: okButton.palette.button
    property alias okButtonAllLowercase: okButton.allLowercase
    property alias cancelButton: cancelButton
    property alias cancelButtonEnable: cancelButton.enabled
    property alias cancelButtonText: cancelButton.text
    property var cancelButtonIconSource
    property alias cancelButtonVisible: cancelButton.visible
    property alias cancelButtonColor: cancelButton.palette.button
    property alias cancelButtonAllLowercase: cancelButton.allLowercase
    property var   defaultFocusItem: cancelButton
    property var   beforeAccept: function(){return true}
    property int footerBottomPadding: 60
    property var cancelButtonWidth: undefined
    property var okButtonWidth: undefined

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    //leftPadding: 30
    //rightPadding: 30

    parent:  Overlay.overlay
    visible: false
    modal:   true

    header: SFText {
        text: control.title
        topPadding: 100
        visible: control.title.length > 0
        horizontalAlignment : Text.AlignHCenter
        font.pixelSize: 30
        font.family: agency_b.name
        font.letterSpacing: 4
        font.weight: Font.Bold
        color: Style.content_main
        font.capitalization: Font.AllUppercase
    }

    SFText {
        bottomPadding: 20
        topPadding: control.title.length > 0 ? 10 : 30
        leftPadding: 20
        rightPadding: 20
        id: messageText
        font.pixelSize: 14
        color: Style.content_main
        wrapMode: Text.Wrap
        horizontalAlignment : Text.AlignHCenter
        anchors.fill: parent
    }

    footer: Control {
        contentItem: RowLayout {
            Item {
                Layout.fillWidth: true
            }
            Row {
                spacing: 20
                height: 40
                leftPadding: 30
                rightPadding: 30
                bottomPadding: footerBottomPadding
                CustomButton {
                    width: cancelButtonWidth ? cancelButtonWidth : implicitWidth
                    id: cancelButton
                    //width: 60
                    focus: true
                    //% "Cancel"
                    text: qsTrId("general-cancel")
                    onClicked: function(){done(Dialog.Rejected)}
                }

                CustomButton {
                    width: okButtonWidth ? okButtonWidth : implicitWidth
                    id: okButton
                    palette.button: Style.active

                    //% "Delete"
                    text: qsTrId("general-delete")
                    palette.buttonText: Style.content_opposite

                    onClicked: function () {
                        if (beforeAccept()) {
                            done(Dialog.Accepted)
                        }
                    }
                }
            }
            Item {
                Layout.fillWidth: true
            }
        }
    }

    onOpened: {
        if (defaultFocusItem) {
            defaultFocusItem.forceActiveFocus(Qt.TabFocusReason)
        }
    }
}
