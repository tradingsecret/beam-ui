import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.12
import Beam.Wallet 1.0
import "."

ColumnLayout
{
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

    SvgImage
    {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 329
        Layout.preferredHeight: 329
        source: "qrc:/assets/start-logo.svg"
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

        //% "Confidential DeFi Platform and Cryptocurrency"
        text:       'Full Privacy Cryptocurrency Platform with Atomic Swaps by the Mechanics of the Future'
        color:      Style.content_main
        opacity:    0.7
        

        font {
            styleName:  "Bold"
            weight:     Font.Bold
            pixelSize:  16
        }
    }

    SFText
    {
        visible: !isMainNet()
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: 20
        Layout.topMargin: isSqueezedHeight ? 10 : 40
        color: Style.content_secondary
        text: 'TESTNET'

        font {
            styleName:      "DemiBold"
            weight:         Font.DemiBold
            pixelSize:      18
            capitalization: Font.AllUppercase
        }
    }

    Item {
        Layout.fillWidth:       true
        Layout.preferredHeight: isSqueezedHeight ? 10 : 30 
    }
}
