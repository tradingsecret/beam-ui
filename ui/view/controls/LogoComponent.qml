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

    function themeName() {
        return Theme.name();
    }

    function isMainNet() {
        return themeName() == "mainnet";
    }

    spacing: 0

    Item {
        Layout.fillWidth:       true
        Layout.preferredHeight: 60
        visible: isMainNet()
    }

    SFText
    {
        Layout.alignment:               Qt.AlignHCenter
        horizontalAlignment:            Text.AlignHCenter
        Layout.topMargin:               13
        Layout.fillHeight:              true
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
        font.pixelSize:      16
        color:               Qt.rgba(255, 255, 255, 1)
        text:                'v 1.09.1505'
    }

    SFText
    {
        Layout.alignment:               Qt.AlignHCenter
        horizontalAlignment:            Text.AlignHCenter
        Layout.topMargin:               13
        Layout.fillHeight:              true
        Layout.minimumWidth:            430
        Layout.maximumWidth:            430
        wrapMode:                       Text.WordWrap

        text:       qsTrId('imperium')
        color:      Style.content_main
        opacity:    1

        font {
            family:    agency_b.name
            weight:    Font.Bold
            pixelSize: 200
            capitalization: Font.AllUppercase
            letterSpacing: 30
        }
    }

    SFText
    {
        visible: !isMainNet()
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: 20
        Layout.topMargin: isSqueezedHeight ? 10 : 40
        //color: Style.content_secondary
        text: 'TESTNET'
        color: '#808e90'

        font {
            styleName:      tomorrow_semibold.name
            pixelSize:      30
            weight:         Font.Bold;
            capitalization: Font.AllUppercase
        }
    }

    Item {
        Layout.fillWidth:       true
        Layout.preferredHeight: isSqueezedHeight ? 10 : 30 
    }
}
