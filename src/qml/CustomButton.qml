import QtQuick
import QtQuick.Controls

RoundButton  {
    id: button

    icon.color: button.hovered ? "black" : "lightgray"
    icon.width: button.pressed ? 36 : 32
    icon.height: button.pressed ? 36 : 32

    background: Rectangle {
        color: "transparent"
    }
}
