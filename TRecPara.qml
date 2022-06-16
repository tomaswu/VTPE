import QtQuick
import QtQuick.Controls

Window {
    id:para_window
    width:380
    height: 260
    maximumWidth: width
    minimumWidth: width
    maximumHeight: height
    minimumHeight: height
    title: "PMB0100分析参数"
    property real rowSpacing : 20
    property bool select: btn_scale.checked
    property bool standardUint: unit.checked
    onVisibleChanged: if(visible)mvid.preThreshold(threshold_slider.value)

    Text {
        id: threshold_text
        text: qsTr("灰度阈值")
        x:20
        y:20
    }

    Slider{
        id: threshold_slider
        from: 0
        to:255
        stepSize: 1
        width: 180
        x:80
        value: 60
        anchors.verticalCenter: threshold_text.verticalCenter
        onValueChanged: mvid.preThreshold(value)
    }
    TextField{
        id:threshold_input
        selectByMouse:true
        validator: RegularExpressionValidator {
            regularExpression: /[0-9]|[0-1][0-9]{0,2}|2[0-4][0-9]|25[0-5]/
        }

        width: 60
        x:300
        anchors.verticalCenter: threshold_text.verticalCenter
        text: threshold_slider.value.toFixed(0)
        onAccepted: {
            focus = false
            threshold_slider.value = text
        }
    }


    Text {
        id: ratio_text
        text: qsTr("比例尺(mm : pixel)")
        x:threshold_text.x
        y:threshold_text.y+threshold_text.height+para_window.rowSpacing
    }


    TextField{
        id:mm_input
        selectByMouse:true
        validator: RegularExpressionValidator {
            regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}|[0-9][0-9]{0,2}|1000/
        }
        width: 40
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
        x:190
        anchors.verticalCenter: ratio_text.verticalCenter
    }

    TextField{
        id:pixel_input
        selectByMouse:true
        validator: RegularExpressionValidator {
            regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}|[0-9][0-9]{0,2}|1000/
        }
        width: 40
        x:205
        anchors.verticalCenter: ratio_text.verticalCenter
        text: "40"
        onAccepted: {
            focus = false
        }
    }

    CheckBox{
        id:unit
        checked: false
        visible: false
        text:"标准单位"
        x:265
        anchors.verticalCenter: ratio_text.verticalCenter
    }

    Text {
        id: scale_text
        text: qsTr("识别范围：")
        x:threshold_text.x
        y:ratio_text.y+threshold_text.height+para_window.rowSpacing
    }


    Button{
        id:btn_scale
        width:60
        checkable: true
        text:"框选范围"
        x:scale_text.x+scale_text.width+15
        anchors.verticalCenter: scale_text.verticalCenter
        onCheckedChanged: {
            mouseArea_select_analysis.enabled = checked
            s4a.visible = checked
        }
    }

    Text {
        id: x_text
        text: qsTr("x：")
        x:80
        y:135

    }

    TextField{
        id:xmin_input
        enabled:false
        selectByMouse:true
        validator: RegularExpressionValidator {
            regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}|[0-9][0-9]{0,2}|1000/
        }
        width: 60
        x:110
        anchors.verticalCenter: x_text.verticalCenter
        text: "0"
        onAccepted: {
            focus = false
        }
    }

    Text {
        text: qsTr("－")
        x:180
        anchors.verticalCenter: x_text.verticalCenter
    }
    TextField{
        id:xmax_input
        enabled:false
        selectByMouse:true
        validator: RegularExpressionValidator {
            regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}|[0-9][0-9]{0,2}|1000/
        }
        width: 60
        x:210
        anchors.verticalCenter: x_text.verticalCenter
        text: "640"
        onAccepted: {
            focus = false
        }
    }


    Text {
        id: y_text
        text: qsTr("y：")
        x:80
        y:175

    }

    TextField{
        id:ymin_input
        enabled:false
        selectByMouse:true
        validator: RegularExpressionValidator {
            regularExpression:/[0-9]{0,4}/
        }
        width: 60
        x:110
        anchors.verticalCenter: y_text.verticalCenter
        text: "0"
        onAccepted: {
            focus = false
        }
    }

    Text {
        text: qsTr("－")
        x:180
        anchors.verticalCenter: y_text.verticalCenter
    }
    TextField{
        id:ymax_input
        enabled:false
        selectByMouse:true
        validator: RegularExpressionValidator {
            regularExpression: /[0-9]{0,4}/
        }
        width: 60
        x:210
        anchors.verticalCenter: y_text.verticalCenter
        text: "360"
        onAccepted: {
            focus = false
        }
    }


    Row{
        anchors.horizontalCenter: parent.horizontalCenter
        y:215
        spacing: 12

        Button{
            id:confirm
            width:120
            text:"开始识别"
            onClicked: {
                if(text==="开始识别"){
                    text="取消"
                    data_table.clear()
                    btn_scale.checked=false
                    var ratio = parseFloat(mm_input.text)/parseFloat(pixel_input.text)/1000
                    mvid.startRecognize(threshold_slider.value,pixel_input.text,mm_input,60,0,xmin_input.text,xmax_input.text,ymin_input.text,ymax_input.text,unit.checked,ratio)
                }
                else{
                    text="开始识别"
                    mvid.stopRecognize()
                    dia.showInfo("分析结束！")
                }
            }
        }

        Connections{
            target: mvid
            function onFinishedRec(){
                confirm.text="开始识别"
            }
        }

    }// end row

    function setScale(col1,col2,row1,row2){
        xmin_input.text = col1
        xmax_input.text = col2
        ymin_input.text = row1
        ymax_input.text = row2
    }

}
