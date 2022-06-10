import QtQuick
import QtQuick.Controls

Rectangle {
    width:380
    height: 140
    property real rowSpacing : 20

    Text {
        id: threshold_text
        text: qsTr("灰度阈值")
        x:20
        y:20
    }

    Slider{
        id: threshold_slider
        from: 0.01
        to:1000
        stepSize: 0.01
        width: 180
        x:80
        value: 3.00
        anchors.verticalCenter: threshold_text.verticalCenter
        onValueChanged: console.log("threshold changed")
    }
    TextField{
        id:threshold_input
        selectByMouse:true
        validator: RegularExpressionValidator {
            regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}|[0-9][0-9]{0,2}|1000/
        }
        width: 60
        x:300
        anchors.verticalCenter: threshold_text.verticalCenter
        text: threshold_slider.value.toFixed(2)
        onAccepted: {
            focus = false
            threshold_slider.value = text
        }
    }


    Text {
        id: ratio_text
        text: qsTr("比例尺(mm : pixel)")
        x:threshold_text.x
        y:threshold_text.y+threshold_text.height+parent.rowSpacing
    }


    TextField{
        id:mm_input
        selectByMouse:true
        validator: RegularExpressionValidator {
            regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}|[0-9][0-9]{0,2}|1000/
        }
        width: 60
        x:140
        anchors.verticalCenter: ratio_text.verticalCenter
        text: "15"
        onAccepted: {
            focus = false
        }
    }

    Text {
        id: ratio_ab_text
        text: qsTr(":")
        x:210
        anchors.verticalCenter: ratio_text.verticalCenter
    }

    TextField{
        id:pixel_input
        selectByMouse:true
        validator: RegularExpressionValidator {
            regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}|[0-9][0-9]{0,2}|1000/
        }
        width: 60
        x:225
        anchors.verticalCenter: ratio_text.verticalCenter
        text: "40"
        onAccepted: {
            focus = false
        }
    }

    Row{
        anchors.horizontalCenter: parent.horizontalCenter
        y:ratio_text.y+ratio_text.height+parent.rowSpacing
        spacing: 12

        Button{
            id:confirm
            width:60
            text:"确定"
            onClicked: {

            }
        }
        Button{
            id:cancel
            width:60
            text:"取消"
            onClicked: {}
        }

        Button{
            id:apply
            width:60
            text:"应用"
            onClicked:{}
        }
    }// end row


}
