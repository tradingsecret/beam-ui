import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls 2.4
import QtQuick.Controls.Styles 1.2
import "controls"
import Beam.Wallet 1.0
import QtQuick.Layouts 1.12

Component {
    id: generateRecoveryPhrase

    Rectangle {
        id: generateRecoveryPhraseRectangle

        FontLoader { id: agency_b;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyB.ttf" }
        FontLoader { id: agency_r;   source: "qrc:/assets/fonts/SF-Pro-Display-AgencyR.otf" }

        Image {
            fillMode: Image.PreserveAspectCrop
            anchors.fill: parent

            source: {
                 "qrc:/assets/bg-2.png"
            }
        }

        color: Style.background_main
        property Item defaultFocusItem: nextButton

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
                    //% "Seed phrase"
                    text: qsTrId("general-seed-phrase")
                    color: '#a4a8b1'
                    font.pixelSize: 48
                    font.family: agency_b.name
                    font.capitalization: Font.AllUppercase
                }
                SFText {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    horizontalAlignment: Qt.AlignHCenter
                    //% "Your seed phrase is the access key to all the cryptocurrencies in your wallet. Write down the phrase to keep it in a safe or in a locked vault. Without the phrase you will not be able to recover your money."
                    text: qsTrId("start-generate-seed-phrase-message")
                    wrapMode: Text.WordWrap
                    color: 'white'
                    font.pixelSize: 22
                    font.family: agency_b.name
                    font.weight: Font.Light
                    font.capitalization: Font.AllUppercase
                    font.letterSpacing: 2
                }
            }
            ConfirmationDialog {
                id: confirRecoveryPhrasesDialog
                //% "I understand"
                okButtonText: qsTrId("start-confirm-seed-phrase-button")
                okButtonIconSource: "qrc:/assets/icon-done.svg"
                cancelButtonVisible: false
                //width: 460
                //% "It is strictly recommended to write down the seed phrase on a paper. Storing it in a file makes it prone to cyber attacks and, therefore, less secure."
                //text: qsTrId("start-confirm-seed-phrase-message")
                onAccepted: {
                    onClicked: startWizzardView.push(checkRecoveryPhrase);
                }
                topPadding: 30
                backgroundImage: "qrc:/assets/popups/popup-4.png"
                width: 710
                height: 490
                footerBottomPadding: 95


                contentItem: Column {
                    width: parent.width
                    //height: confirRecoveryPhrasesDialog.implicitHeight + restoreWalletConfirmationMessage.implicitHeight

                    SFText {
                        topPadding: 60
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 400
                        horizontalAlignment: Qt.AlignHCenter
                        text: "NOTICE!"
                        color: Style.content_main
                        font.pixelSize: 30
                        font.letterSpacing: 3
                        font.family: agency_b.name
                        font.weight: Font.Bold
                        wrapMode: Text.Wrap
                    }

                    SFText {
                        id: restoreWalletConfirmationTitle
                        topPadding: 30
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment: Qt.AlignHCenter
                        //% "Restore wallet"
                        text: "SAVE YOUR SEED PHRASE"
                        color: Style.content_main
                        font.family: agency_b.name;
                        font.underline: true
                        font.capitalization: Font.AllUppercase
                        font.pixelSize: 30
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    SFText {
                        id: restoreWalletConfirmationMessage
                        topPadding: 30
                        padding: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        horizontalAlignment : Text.AlignHCenter
                        width: parent.width - 100
                        text: qsTrId("start-confirm-seed-phrase-message")
                        color: Style.content_main
                        font.family: agency_b.name;
                        font.capitalization: Font.AllUppercase
                        font.pixelSize: 20
                        font.bold: true
                        font.letterSpacing: 2
                        wrapMode: Text.Wrap
                    }
                }
            }
            SeedValidationHelper {
                id: seedValidationHelper
                Component.onCompleted: {
                    if (seedValidationHelper.isSeedValidatiomMode) {
                        viewModel.loadRecoveryPhraseForValidation();
                    }
                }
            }
            Grid{
                id: phrasesView
                Layout.alignment: Qt.AlignHCenter
                columns: 3

                topPadding: 100
                columnSpacing: 30
                rowSpacing:  20

                Repeater {
                    model:viewModel.recoveryPhrases //TODO zavarza
                    Rectangle{
                        color: "transparent"
                        width: 200
                        height: 38
                        radius: 30
                        SFText {
                            anchors.verticalCenter: parent.verticalCenter
                            horizontalAlignment: Qt.AlignLeft
                            text: modelData.index + 1 + ". " + modelData.phrase
                            font.pixelSize: 20
                            color: '#5fe795'
                            font.capitalization: Font.AllLowercase
                            font.letterSpacing: 1
                        }
                    }
                }
            }
            
            Item {
                Layout.fillHeight: true
                Layout.minimumHeight: 50
            }

            Row {
                Layout.alignment: Qt.AlignHCenter

                spacing: 30

                CustomButton {
                    //% "Back"
                    text: "<= " + qsTrId("general-base-back")
                    font.capitalization: Font.AllUppercase
                    onClicked: {
                        if (seedValidationHelper.isSeedValidatiomMode) {
                            rootLoader.setSource("qrc:/main.qml");
                        } else {
                            startWizzardView.pop();
                            viewModel.resetPhrases();
                        }
                    }
                }

                CustomButton {
                    //% "I will do it later"
                    text: "          " + qsTrId("general-do-later") + "          "
                    font.capitalization: Font.AllUppercase
                    visible: !seedValidationHelper.isSeedValidatiomMode
                    onClicked: {
                        PRINT.print(viewModel.recoveryPhrases);

                        viewModel.saveSeed = true; //tmp
                        startWizzardView.push(create); //tmp
                    }
                }

                CustomButton {
                    id: nextButton
                    //% "Complete verification"
                    text: qsTrId("general-complete-verification-button")
                    font.capitalization: Font.AllUppercase
                    onClicked: {confirRecoveryPhrasesDialog.open();}
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
