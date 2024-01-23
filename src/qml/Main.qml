import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick3D

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    title: "RGBD Viewer"

    ImageDialog {
        id: textureImagePathDialog
        onAccepted: {
            viewer.textureImagePath = selectedFile
            texturePath.text = selectedFile
        }
    }

    ImageDialog {
        id: depthImagePathDialog
        onAccepted: {
            viewer.depthImagePath = selectedFile
            depthPath.text = selectedFile
        }
    }

    Viewer {
        id: viewer
        textureImagePath: "file:img/texture.jpg"
        depthImagePath: "file:img/depth.jpg"
    }

    CustomButton  {
        id: settingsButton

        anchors.horizontalCenter: parent.right
        anchors.verticalCenter: parent.bottom
        anchors.horizontalCenterOffset: -40
        anchors.verticalCenterOffset: -40

        icon.source: "file:icons/gear.png"

        onClicked: settingsDialog.open()
    }

    CustomButton  {
        id: helpButton

        anchors.horizontalCenter: parent.right
        anchors.verticalCenter: parent.bottom
        anchors.horizontalCenterOffset: -40
        anchors.verticalCenterOffset: -90

        icon.source: "file:icons/questionmark.png"

        onClicked: helpDialog.open()
    }

    CustomDialog {
        id: settingsDialog
        title: "Settings"
        standardButtons: Dialog.Close
        width: 400

        GridLayout {
            id: mainLayout
            anchors.left: parent.left
            anchors.right: parent.right
            columns: 3
            uniformCellWidths: false

            Label {
                text: "Texture Image"
            }

            TextField {
                id: texturePath
                placeholderText: "Texture File Path"
                Layout.fillWidth: true
                readOnly: true
            }

            Button {
                text: "Browse..."
                onPressed: textureImagePathDialog.open()
            }

            Label {
                text: "Depth Image"
            }

            TextField {
                id: depthPath
                placeholderText: "Depth File Path"
                Layout.fillWidth: true
                readOnly: true
            }

            Button {
                text: "Browse..."
                onPressed: depthImagePathDialog.open()
            }
        }
    }

    CustomDialog {
        id: helpDialog
        title: "Help"
        standardButtons: Dialog.Ok

        Text {
            anchors.left: parent.left
            anchors.right: parent.right

            text: [
                "• Use [Left Mouse Button] to rotate the model in 3D space\n",
                "• Use [Mouse Wheel] to zoom in and out on the model\n",
                "• Use [SHIFT] + [Mouse Wheel] to change the depth map scale\n",
                "• The model will start rotating automatically after 5s of inactivity"
            ].join("")
        }
    }
}
