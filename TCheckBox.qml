import QtQuick 2.15
import QtQuick.Controls 2.15

CheckBox {
    id: control
    text: qsTr("CheckBox")
    checked: true

//    indicator: Rectangle {
//        implicitWidth: 26
//        implicitHeight: 26
//        x: control.leftPadding
//        y: parent.height / 2 - height / 2
//        radius: 3
//        border.color: control.down ? "#17a81a" : "#21be2b"

//        Rectangle {
//            width: 14
//            height: 14
//            x: 6
//            y: 6
//            radius: 2
//            color: control.down ? "#17a81a" : "#21be2b"
//            visible: control.checked
//        }
//    }

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        color: global_color.primary
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}
