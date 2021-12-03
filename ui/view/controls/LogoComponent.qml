import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import "."

ColumnLayout
{
    FontLoader { id: agency_b;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyB.ttf" }
    FontLoader { id: tomorrow_semibold;  source: "qrc:/assets/fonts/SF-Pro-Display-TomorrowSemiBold.ttf" }

    property bool isSqueezedHeight: false
    property bool hideNetworkLabel: false

    function themeName() {
        return Theme.name();
    }

    function isMainNet() {
        return themeName() == "mainnet";
    }

    spacing: 0

    SFText
    {
        Layout.alignment:               Qt.AlignHCenter
        horizontalAlignment:            Text.AlignHCenter
        Layout.topMargin:               -20
        Layout.minimumWidth:            550
        Layout.maximumWidth:            550
        wrapMode:                       Text.WordWrap

        //% "Confidential DeFi Platform and Cryptocurrency"
        text:       qsTrId('main-page-text')
        color:      Style.content_main
        opacity:    1
        

        font {
            pixelSize:  20
        }
    }

    SFText {
        Layout.alignment:    Qt.AlignHCenter
        Layout.topMargin:    13
        //Layout.fillHeight:   true
        font.pixelSize:      16
        color:               Qt.rgba(255, 255, 255, 1)
        text:                'v ' + BeamGlobals.version()
    }

    //Item {
    //    Layout.fillWidth:       true
    //    Layout.preferredHeight: 30
    //    visible: isMainNet()
    //}

    ColumnLayout {
        width: 880
        Layout.alignment:               Qt.AlignHCenter
        Layout.fillHeight:              true
        Layout.topMargin:               35
        //color: 'transparent'
        //border.color: 'pink'

        Image {
            Layout.alignment: Qt.AlignCenter
            source: "qrc:/assets/imperium_main.png"
        }

        ColumnLayout {
            visible: false
            SFText {
                //Layout.alignment:               Qt.AlignHCenter
                horizontalAlignment:            Text.AlignHCenter
                //Layout.topMargin:               13
                //Layout.minimumWidth:            430
                //Layout.maximumWidth:            430
                wrapMode:                       Text.WordWrap

                text:       qsTrId('imperium')
                color:      Style.content_main

                font {
                    family:    agency_b.name
                    weight:    Font.Bold
                    pixelSize: 200
                    capitalization: Font.AllUppercase
                    letterSpacing: 30
                }
            }
        }

        ColumnLayout {
            visible: false
            width: parent.width
            Layout.topMargin: -50
            Layout.leftMargin: -17
            //visible: !hideNetworkLabel && !isMainNet()

            Row {
                width: parent.width

                SFText
                {
                    width: parent.parent.width
                    Layout.fillWidth: true

                    //Layout.fillWidth: true
                    horizontalAlignment:            Qt.AlignRight
                    Layout.alignment:               Qt.AlignRight
                    //horizontalAlignment:            Text.AlignRight
                    text: 'TESTNET'
                    color:  Style.content_main
                    wrapMode:                       Text.WordWrap


                    font {
                        styleName:      agency_b.name
                        pixelSize:      30
                        weight:         Font.Bold;
                        capitalization: Font.AllUppercase
                    }
                }
            }
        }
    }

    /*Item {
        Layout.fillWidth:  true
        Layout.fillHeight: true
        Layout.preferredHeight: isSqueezedHeight ? 10 : 30
        visible: !hideNetworkLabel
    }*/

    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        //Layout.topMargin: isSqueezedHeight ? 10 : 40
        width: 100
        height: 100
        color: 'transparent'
        visible: !hideNetworkLabel

        Image {
            visible: false
            anchors.fill: parent
            fillMode: Image.Stretch
            source: {
                 "qrc:/assets/ImperiumLogo.png"
            }
        }
    }

    /*Item {
        Layout.fillWidth:  true
        Layout.fillHeight: true
        Layout.preferredHeight: isSqueezedHeight ? 10 : 30
    }*/
}
