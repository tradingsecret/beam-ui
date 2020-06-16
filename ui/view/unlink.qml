import QtQuick 2.11
import QtQuick.Layouts 1.3
import Beam.Wallet 1.0
import "controls"

ColumnLayout {
    id: unlinkView
    Layout.fillWidth:    true
    Layout.fillHeight:   true

    // callbacks set by parent
    property var onClosed: undefined

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 105
        Layout.bottomMargin: 30
        Layout.preferredHeight: 16
        Layout.maximumHeight: 16
        Item {
            Layout.fillWidth:  true
            Layout.fillHeight: true
            RowLayout {
                spacing: 0
                Image {
                    source:  "qrc:/assets/icon-back.svg"
                    width:   16
                    height:  16
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (unlinkView.onClosed && typeof unlinkView.onClosed == "function") unlinkView.onClosed();
                        }
                    }
                }

                SFText {
                    Layout.leftMargin: 14
                    font.pixelSize:  14
                    font.styleName:  "Bold"; font.weight: Font.Bold
                    color:           Style.content_main
                    //% "back"
                    text:            qsTrId("unlink-back")
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (unlinkView.onClosed && typeof unlinkView.onClosed == "function") unlinkView.onClosed();
                        }
                    }
                }
            }

            SFText {
                anchors.horizontalCenter : parent.horizontalCenter
                font.pixelSize:  14
                font.styleName:  "Bold"
                font.weight: Font.Bold
                font.letterSpacing: 4
                color:           Style.content_main
                //% "UNLINK"
                text:            qsTrId("unlink-title")
            }
        }
    }

    RowLayout  {
        Layout.fillWidth: true
        spacing:    10

        //
        // Left column
        //
        ColumnLayout {
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "green"
            }
        }
        //
        // Right column
        //
        ColumnLayout {
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "red"
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 30
        SFText {
            font.pixelSize:  14
            color:           Style.content_secondary
            font.italic: true
            //% "Please notice that unlinking funds may take up to few days to proceed."
            text: qsTrId("unlink-notice")
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 10
        SFText {
            font.pixelSize:  14
            color:           Style.content_main
            text:            "Estimated time: 2 days 5 hours"
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 20
        Layout.bottomMargin: 150
        PrimaryButton {
            Layout.preferredHeight: 38
            //% "unlink"
            text: qsTrId("unlink-confirm-button")
            icon.source: "qrc:/assets/icon-unlink-black.svg"
            onClicked: {
                console.log("unlink accepted");
            }
        }
    }
}
