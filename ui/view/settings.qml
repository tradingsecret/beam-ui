import QtQuick 2.11
import QtQuick.Controls 1.2
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.12
import "controls"
import "controls/settings"
import "utils.js" as Utils
import Beam.Wallet 1.0

ColumnLayout {
    id: settingsView
    Layout.fillWidth: true
    state: "general"

    property string  linkStyle:  "<style>a:link {color: '#00f6d2'; text-decoration: none;}</style>"
    property string  swapMode:   ""
    property bool    creating:   true
    property string  tabActive:  'general_settings'

    property bool settingsPrivacyFolded: true

    Component.onCompleted: {
        settingsView.creating = false
    }

    SettingsViewModel {
        id: viewModel
    }

    property var items : [
        {name: "general_settings", title: "General Settings", header: "Change your setup", enabled: true},
        {name: "privacy_and_security", title: "Privacy and security", header: "Privacy and security", enabled: true},
        {name: "wallet_settings", title: "Wallet Settings", header: "Wallet Settings", enabled: true, selected: false},
        {name: "notification_settings", title: "Notification Settings", header: "Notification Settings", enabled: false},
        {name: "dapps_settings", title: "DAPPS Settings", header: "DAPPS Settings", enabled: true},
        {name: "found_bug", title: "Found a bug ?", header: "Found a bug ?", enabled: true},
        //{name: "hall_of_fame", title: "Hall of fame", header: "Hall of fame", enabled: true},
    ]

    ScrollView {
        Layout.topMargin: 48
        Layout.fillWidth: true
        Layout.fillHeight: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy:   ScrollBar.AsNeeded
        clip: true

        ColumnLayout {
            //width: settingsView.width
            Layout.fillWidth: true
            Layout.fillHeight: true
            width: parent.width
            height: parent.height

            RowLayout {
                Layout.fillWidth: true
                width: parent.width
                height: parent.height
                Layout.fillHeight: true
                spacing: 25

                Rectangle {
                    anchors.fill: parent
                    color: 'transparent'

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        //propagateComposedEvents: true
                        onClicked: function() {
                            console.log('clicked outside');

                            generalBlock.autoLockPanelVisible = false;
                            generalBlock.languagePanelVisible = false;
                        }
                    }
                }

                ColumnLayout {
                    Layout.topMargin: 47
                    Layout.preferredWidth: 300
                    //Layout.width: 400
                    Layout.alignment: Qt.AlignTop
                    spacing: 10

                    Repeater {
                        model: items
                        //Layout.width: parent.width

                        ColumnLayout {
                            Layout.fillWidth: true

                            CustomButton {
                                id:  button1
                                Layout.preferredWidth: 300

                                height: 40
                                text: modelData.title
                                font.pixelSize: 16
                                customColor: '#b4b4b4'
                                enabled: modelData.enabled

                                hasShadow: false
                                disableRadius: true
                                radius: 0

                                background: Rectangle {
                                    color:      "transparent"

                                    Image {
                                        anchors.fill: parent
                                        fillMode: Image.Stretch
                                        source: {
                                            if (!modelData.enabled) {
                                                return "qrc:/assets/settings/button-default.png"
                                            }
                                            else if (tabActive == modelData.name) {
                                                return "qrc:/assets/settings/button-active.png"
                                            }
                                            else {
                                                return button1.hovered ?  "qrc:/assets/settings/button-hover.png" :  "qrc:/assets/settings/button-default.png"
                                            }
                                        }
                                    }
                                }

                                onClicked: {
                                    if (modelData.enabled) {
                                        tabActive = modelData.name
                                    }
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    SFText {
                        Layout.alignment:     Qt.AlignHCenter
                        horizontalAlignment:  Text.AlignHCenter
                        font.capitalization:  Font.AllUppercase
                        font.pixelSize:       18
                        color:                'white'
                        //lineHeight:           1.43
                        text:                 "Change your setup"
                    }

                    ColumnLayout {
                        Layout.topMargin: 20
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Item {
                            Layout.fillWidth: true
                            Layout.margins: 38

                            NewSettingsGeneral {
                                id: generalBlock
                                Layout.fillWidth: true
                                width: parent.width
                                height: parent.height
                                viewModel: viewModel
                                visible: tabActive ==  'general_settings'
                            }

                            NewSettingsPrivacy {
                                id: privacylBlock
                                Layout.fillWidth: true
                                width: parent.width
                                height: parent.height
                                viewModel: viewModel
                                visible: tabActive ==  'privacy_and_security'
                            }

                            NewSettingsUtilities {
                                id: utilitiesBlock
                                Layout.fillWidth: true
                                width: parent.width
                                height: parent.height
                                viewModel: viewModel
                                visible: tabActive ==  'wallet_settings'
                            }

                            NewSettingsDapps {
                                id: dappsBlock
                                Layout.fillWidth: true
                                width: parent.width
                                height: parent.height
                                viewModel: viewModel
                                visible: tabActive ==  'dapps_settings'
                            }

                            NewSettingsFoundABug {
                                id: foundABugBlock
                                Layout.fillWidth: true
                                width: parent.width
                                height: parent.height
                                viewModel: viewModel
                                visible: tabActive ==  'found_bug'
                            }

                            NewSettingsHallOfFame {
                                id: hallOfFameBlock
                                Layout.fillWidth: true
                                width: parent.width
                                height: parent.height
                                viewModel: viewModel
                                visible: tabActive ==  'hall_of_fame'
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                           Layout.fillHeight: true
                        }

                        Rectangle {
                            anchors.fill: parent
                            border.color: '#112a26'
                            border.width: 1
                            color: 'transparent'
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: 'transparent'
        }
    }
}
