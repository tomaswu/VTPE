//这个窗口只是华谷动力相机的设置页面
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1
import QtCharts 2.15
import QtQuick.Dialogs

Window{
    id: subwindow
    width: 420
    height: 500

    Column{
        anchors.fill:parent
        spacing: 20
        padding:20
        Rectangle{
            id : para_widget
            width: parent.width-parent.padding*2
            height:420
            border.width: 1
            border.color: "lightgreen"
            property int sapcing: 10

                Text {
                    id: fps_text
                    text: "帧率"
                    x:20
                    y:20
                }

                Slider{
                    id: fps_slider
                    from: 1
                    to:815
                    stepSize: 1
                    width: 180
                    x:100
                    value: 210
                    anchors.verticalCenter: fps_text.verticalCenter
                }

                TextField{
                    id:fps_input
                    width: 60
                    x:300
                    anchors.verticalCenter: fps_text.verticalCenter
                    validator: IntValidator{
                        bottom:1
                        top: 815
                    }
                    selectByMouse: true
                    text: fps_slider.value
                    onTextChanged: fps_slider.value = text
                }

                Text {
                    id: auto_exposure_text
                    text: qsTr("自动曝光")
                    x:fps_text.x
                    y:60
                }
                ComboBox{
                    id:auto_exposure_combox
                    x:fps_slider.x
                    anchors.verticalCenter: auto_exposure_text.verticalCenter
                    model: ["关闭","一次","连续"]
                }
                Text {
                    id: exposure_time_text
                    text: qsTr("曝光时间")
                    x:fps_text.x
                    y:100
                }

                Slider{
                    id: exposure_time_slider
                    from: 1
                    to:1000
                    stepSize: 0.01
                    width: 180
                    x:fps_slider.x
                    value: 3.00
                    anchors.verticalCenter: exposure_time_text.verticalCenter
                }
                TextField{
                    id:exposure_time_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: exposure_time_text.verticalCenter
                    text: exposure_time_slider.value.toFixed(2)
                    onTextChanged: exposure_time_slider.value = text
                }

                Text {
                    id: gian_text
                    text: qsTr("增益")
                    x:fps_text.x
                    y:140
                }

                Slider{
                    id: gian_slider
                    from: 0
                    to:1
                    stepSize: 0.01
                    width: 180
                    x:fps_slider.x
                    value: 0
                    anchors.verticalCenter: gian_text.verticalCenter
                }

                TextField{
                    id:gian_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /1.00|0[\.][0-9]{1,2}/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: gian_text.verticalCenter
                    text: gian_slider.value.toFixed(2)
                    onTextChanged: gian_slider.value = text
                }

                Text {
                    id: gamma_text
                    text: qsTr("伽马")
                    x:fps_text.x
                    y:180
                }

                Slider{
                    id: gamma_slider
                    from: 0
                    to:1
                    stepSize: 0.01
                    width: 180
                    x:fps_slider.x
                    value: 0
                    anchors.verticalCenter: gamma_text.verticalCenter
                }

                TextField{
                    id:gamma_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /1.00|0[\.][0-9]{1,2}/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: gamma_text.verticalCenter
                    text: gamma_slider.value.toFixed(2)
                    onTextChanged: gamma_slider.value = text
                }


                Text {
                    id: denoise_text
                    text: qsTr("降噪")
                    x:fps_text.x
                    y:220
                }

                Slider{
                    id: denoise_slider
                    from: 0
                    to:1
                    stepSize: 0.01
                    width: 180
                    x:fps_slider.x
                    value: 0
                    anchors.verticalCenter: denoise_text.verticalCenter
                }

                TextField{
                    id:denoise_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /1.00|0[\.][0-9]{1,2}/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: denoise_text.verticalCenter
                    text: denoise_slider.value.toFixed(2)
                    onTextChanged: denoise_slider.value = text
                }

                Text {
                    id: acuity_text
                    text: qsTr("锐度")
                    x:fps_text.x
                    y:260
                }

                Slider{
                    id: acuity_slider
                    from: 0
                    to:1
                    stepSize: 0.01
                    width: 180
                    x:fps_slider.x
                    value: 0
                    anchors.verticalCenter: acuity_text.verticalCenter
                }

                TextField{
                    id:acuity_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /1.00|0[\.][0-9]{1,2}/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: acuity_text.verticalCenter
                    text: acuity_slider.value.toFixed(2)
                    onTextChanged: acuity_slider.value = text
                }

                Text {
                    id: brightness_text
                    text: qsTr("亮度")
                    x:fps_text.x
                    y:300
                }

                Slider{
                    id: brightness_slider
                    from: 0
                    to:100
                    stepSize: 1
                    width: 180
                    x:fps_slider.x
                    value: 50
                    anchors.verticalCenter: brightness_text.verticalCenter
                }

                TextField{
                    id:brightness_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /100|[0-9]{1,2}/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: brightness_text.verticalCenter
                    text: brightness_slider.value.toFixed(0)
                    onTextChanged: brightness_slider.value = text
                }


                Text {
                    id: digtalshift_text
                    text: qsTr("数字位移")
                    x:fps_text.x
                    y:340
                }

                Slider{
                    id: digtalshift_slider
                    from: 0
                    to:100
                    stepSize: 1
                    width: 180
                    x:fps_slider.x
                    value: 0
                    anchors.verticalCenter: digtalshift_text.verticalCenter
                }

                TextField{
                    id:digtalshift_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /100|[0-9]{1,2}/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: digtalshift_text.verticalCenter
                    text: digtalshift_slider.value.toFixed(0)
                    onTextChanged: digtalshift_slider.value = text
                }
                Text {
                    id: balance_text
                    text: qsTr("自动白平衡")
                    x:fps_text.x
                    y:380
                }
                ComboBox{
                    id:balance_combox
                    x:fps_slider.x
                    anchors.verticalCenter: balance_text.verticalCenter
                    model: ["关闭","一次","连续"]
                }

        }// end para widget

        Row{
            spacing: 12
            anchors.right: para_widget.right
            Button{
                id:confirm
                text:"确定"
                onClicked: { }
            }
            Button{
                id:cancel
                text:"取消"
                onClicked: { resetDefaultSettings() }
            }

            Button{
                id:apply
                text:"应用"
                onClicked:{ }
            }
        }// end row

    }

    function resetDefaultSettings(){
        fps_slider.value=210
        auto_exposure_combox.currentIndex = 0
        exposure_time_slider.value = 3.00
        gian_slider.value = 0
        gamma_slider.value = 0
        denoise_slider.value = 0
        acuity_slider.value = 0
        brightness_slider.value = 50
        digtalshift_slider.value = 0
        balance_combox.currentIndex = 0
    }


// settings
    Settings{
        id:workPowerSettings
        fileName: "Config.ini"
        category: "work power settings"
        property real fps: 210
        property real auto_exposure: 0
        property real exposure_time: 3.00
        property real gian: 0
        property real gamma: 0
        property real denosie: 0
        property real acuity: 0
        property real brightness: 50
        property real digtalshift: 0
        property real balance: 0
    }

}




