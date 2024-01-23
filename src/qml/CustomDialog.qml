import QtQuick
import QtQuick.Controls

Dialog {
    modal: true
    closePolicy: Popup.CloseOnEscape
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
}
