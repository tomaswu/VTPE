import QtQuick
import QtQuick.Controls

Window {
    id: curve_dialog

    width:240
    height: 140
    maximumWidth: width
    minimumWidth: width
    maximumHeight: height
    minimumHeight: height
    modality: Qt.ApplicationModal
    title: "添加曲线"
    signal confirmed(var label,var x,var y)

    TextField{
        id:label_input
        selectByMouse:true
        x:20
        y:10
        width: 200
        text: ""
        placeholderText: "输入曲线标签"
        onAccepted: {
            focus = false
        }
    }
    Text {
        id: x_text
        text: qsTr("X轴数据")
        x:20
        y:50
    }
    ComboBox{
        id:x_combox
        x:80
        anchors.verticalCenter: x_text.verticalCenter

    }
    Text {
        id: y_text
        text: qsTr("Y轴数据")
        x:20
        y:80
    }
    ComboBox{
        id:y_combox
        x:80
        anchors.verticalCenter: y_text.verticalCenter

    }

    Button{
        id:confirm
        text:"确定"
        anchors.horizontalCenter: parent.horizontalCenter
        y:110
        onClicked: {
            confirmed(label_input.text,x_combox.currentText,y_combox.currentText)
            curve_dialog.close()
        }

    }

    function setCombox(r1,r2){
        x_combox.model=r1
        y_combox.model=r2
    }


}
