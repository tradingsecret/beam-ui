import QtQuick 2.12
import QtQuick.Controls 2.4
import Beam.Wallet 1.0
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtMultimedia 5.15
import "../utils.js" as Utils
import "."

Rectangle
{
    id: root

    FontLoader { id: tomorrow_semibold;  source: "qrc:/assets/fonts/SF-Pro-Display-TomorrowSemiBold.ttf" }

    readonly property bool isSqueezedHeight : Utils.isSqueezedHeight(root.height)

    color: Style.background_main
    default property alias content: contentLayout.children
    property bool showNetworkLabel
    property bool playVideo: false
    property bool showSkipIntro: false

    Video {
        id: video_preview
        anchors.fill: parent
        fillMode: VideoOutput.Stretch
        //width: 1200
        //height: 800
        autoPlay: true
        source: "qrc:/assets/wallet_video.avi"
        visible: playVideo
        onStopped: function() {
            playVideo = false
        }
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true
        onMouseXChanged: {
            showSkipIntro = true;

            if (hideSkipIntro.running) {
                hideSkipIntro.stop();
            }

            hideSkipIntro.start();
        }
        onPressed: {
            mouse.accepted = false
        }
    }

    Timer {
        id: hideSkipIntro
        running: false
        repeat: false
        interval: 3000
        onTriggered: {
            showSkipIntro = false
        }
    }

    SFText {
        anchors.bottom: video_preview.bottom
        anchors.right: video_preview.right
        anchors.bottomMargin: 20
        anchors.rightMargin: 20
        //Layout.alignment:               Qt.AlignHCenter
        horizontalAlignment:            Text.AlignHCenter
        //Layout.topMargin:               13
        //Layout.minimumWidth:            430
        //Layout.maximumWidth:            430
        wrapMode:                       Text.WordWrap

        text:       "skip intro"
        color:      Qt.rgba(168, 169, 174, 0.5)
        //opacity:    0.5

        font {
            family:    tomorrow_semibold.name
            pixelSize: 34
            capitalization: Font.AllUppercase
            letterSpacing: 5
        }
        visible: playVideo && showSkipIntro
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                video_preview.stop();
            }
            hoverEnabled: true
        }
    }

    Image {
        visible: !playVideo
        id: backgroundImage
        fillMode: Image.PreserveAspectCrop
        anchors.fill: parent

        source: {
             "qrc:/assets/bg-1.png"
        }
    }

    BgLogo {
        visible: !playVideo
    }

    ColumnLayout {
        visible: !playVideo
        id: rootColumn
        anchors.fill: parent
        spacing: 0

        LogoComponent {
            id: logoComponentId
            Layout.topMargin:  root.isSqueezedHeight ? 13 : 83
            Layout.alignment:  Qt.AlignHCenter
            isSqueezedHeight:  root.isSqueezedHeight
            hideNetworkLabel:  !showNetworkLabel
        }

        ColumnLayout {
            id:                 contentLayout
            Layout.fillWidth:   true
            Layout.fillHeight:  true
            Layout.alignment:   Qt.AlignHCenter
        }

        Image {
            //Layout.topMargin: -100
            source:  "qrc:/assets/copyright.png"
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 30
        }
    }
}
