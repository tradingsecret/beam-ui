import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import QtGraphicalEffects 1.0
import "controls"
import Beam.Wallet 1.0
import QtQuick.Layouts 1.12

Component {
    id: checkRecoveryPhrase
    Rectangle {
        color: Style.background_main
        property Item defaultFocusItem: null

        Image {
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent

            source: {
                 "qrc:/assets/bg-2.png"
            }
        }

        ColumnLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.fill: parent
            anchors.topMargin: 50
            Column {
                spacing: 30
                Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                Layout.preferredWidth: 730
                SFText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Qt.AlignHCenter
                    //% "Complete wallet verification"
                    text: qsTrId("general-complete-verification")
                    color: '#a4a8b1'
                    font.pixelSize: 48
                    font.family: agency_b.name
                    font.capitalization: Font.AllUppercase
                }
                SFText {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Qt.AlignHCenter
                    //% "To ensure the seed phrase is written down, please fill-in the specific words below"
                    text: qsTrId("start-check-seed-phrase-message")
                    wrapMode: Text.WordWrap
                    color: 'white'
                    font.pixelSize: 22
                    font.family: agency_b.name
                    font.weight: Font.Light
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 2
                }
            }

            SeedValidationHelper {
                id: seedValidationHelper
            }

            Grid{
                Layout.alignment: Qt.AlignHCenter
                columns: 3

                topPadding: 50
                columnSpacing: 30
                rowSpacing:  20

                Repeater {
                    model:viewModel.checkPhrases

                    Row {
                        width: 160
                        height: 38
                        spacing: 20
                        Item {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 20
                            height: 20
                            Rectangle {
                                color: "transparent"
                                width: 20
                                height: 20
                                SFText {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: modelData.index + 1

                                    font.pixelSize: 20
                                    color: (modelData.isCorrect || modelData.value.length == 0) ? '#5fe795' : Style.validator_error
                                    font.capitalization: Font.AllUppercase
                                    font.letterSpacing: 1
                                }
                                //visible: modelData.value.length == 0
                            }

                            //Rectangle {
                            //    id: correctPhraseRect
                            //    color: modelData.isCorrect ? '#5fe795' : Style.validator_error
                            //    width: 20
                             //   height: 20
                             //   radius: 10
                             //   SFText {
                             //       anchors.verticalCenter: parent.verticalCenter
                               //     anchors.horizontalCenter: parent.horizontalCenter
                               //     text: modelData.index + 1
                                //    font.pixelSize: 20
                                 //   color: modelData.isCorrect ? '#5fe795' : Style.validator_error
                                  //  font.capitalization: Font.AllLowercase
                                   // font.letterSpacing: 1
                              //  }
                               // visible: modelData.value.length > 0
                            //}

                            //DropShadow {
                            //    anchors.fill: correctPhraseRect
                                //radius: 5
                                //samples: 9
                            //    color: modelData.isCorrect ? Style.active : Style.validator_error
                           //     source: correctPhraseRect
                            //    visible: correctPhraseRect.visible
                           // }
                        }

                        SFTextInput {
                            id: phraseValue
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 0
                            width: 121
                            font.pixelSize: 20
                            color: (modelData.isCorrect || modelData.value.length == 0) ? '#5fe795' : Style.validator_error
                            backgroundColor: (modelData.isCorrect || modelData.value.length == 0) ? '#5fe795' : Style.validator_error
                            text: modelData.value
                            Component.onCompleted: {
                                modelData.value = "";
                                if (defaultFocusItem == null) {
                                    defaultFocusItem = phraseValue;
                                }
                            }
                        }
                        Binding {
                            target: modelData
                            property: "value"
                            value: phraseValue.text
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 120
            }

            Row {
                Layout.alignment: Qt.AlignHCenter

                spacing: 30

                CustomButton {
                    //% "Back"
                    text: "<= " + qsTrId("general-back")
                    onClicked: {
                        startWizzardView.pop();
                        if (!seedValidationHelper.isSeedValidatiomMode) {
                            viewModel.resetPhrases();
                        }
                    }
                }

                CustomButton {
                    id: checkRecoveryNextButton
                    //% "Next"
                    text: qsTrId("general-next")
                    enabled: {
                        var enable = true;
                        for(var i = 0; i < viewModel.checkPhrases.length; ++i)
                        {
                            enable &= viewModel.checkPhrases[i].isCorrect;
                        }
                        return enable;
                    }
                    onClicked: {
                        if (seedValidationHelper.isSeedValidatiomMode) {
                            seedValidationHelper.isSeedValidatiomMode = false;
                            seedValidationHelper.validate();
                            rootLoader.setSource("qrc:/main.qml");
                        } else {
                            startWizzardView.push(create);
                        }
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 67
                Layout.maximumHeight: 143
            }
        }
    }
}
