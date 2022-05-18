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
    maximumWidth: width
    minimumWidth: width
    maximumHeight: height
    minimumHeight: height
    title: "相机设置"
    onClosing:{
        setLastSettings()
    }

    Column{
        anchors.fill:parent
        spacing: 20
        padding:20
        Rectangle{
            id : para_widget
            width: parent.width-parent.padding*2
            height:420
            border.width: 1
            border.color: "skyblue"
            property int sapcing: 10

                Text {
                    id: fps_text
                    text: "帧率"
                    x:20
                    y:20
                }

                CheckBox{
                    id: fps_checked
                    x: 60
                    anchors.verticalCenter: fps_text.verticalCenter
                    checked:false
                    onCheckedChanged:mcap.setFpsEnabled(checked)
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
                    onValueChanged: mcap.setFps(value)
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
                    onAccepted: {
                        fps_slider.value = text
                        focus = false
                    }
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
                    onCurrentIndexChanged: {
                        mcap.setAutoExposure(currentIndex)
                        if(currentIndex===0){
                            mcap.setExposureTime(exposure_time_slider.value*1000)
                        }
                    }
                }
                Text {
                    id: exposure_time_text
                    text: qsTr("曝光时间")
                    x:fps_text.x
                    y:100
                }

                Slider{
                    id: exposure_time_slider
                    from: 0.01
                    to:1000
                    stepSize: 0.01
                    width: 180
                    x:fps_slider.x
                    value: 3.00
                    anchors.verticalCenter: exposure_time_text.verticalCenter
                    onValueChanged: mcap.setExposureTime(value*1000)
                }
                TextField{
                    id:exposure_time_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}|[0-9][0-9]{0,2}|1000/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: exposure_time_text.verticalCenter
                    text: exposure_time_slider.value.toFixed(2)
                    onAccepted: {
                        focus = false
                        exposure_time_slider.value = text
                    }
                }

                Text {
                    id: gian_text
                    text: qsTr("增益")
                    x:fps_text.x
                    y:140
                }

                Slider{
                    id: gian_slider
                    from: 1
                    to:32
                    stepSize: 0.01
                    width: 180
                    x:fps_slider.x
                    value: 0
                    anchors.verticalCenter: gian_text.verticalCenter
                    onValueChanged: mcap.setGain(value)
                }

                TextField{
                    id:gian_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /[0-2][0-9][\.][0-9]{1,2}|[3][0-2][\.][0-9]{1,2}|[0-2][0-9]|[0-9]/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: gian_text.verticalCenter
                    text: gian_slider.value.toFixed(2)
                    onAccepted: {
                        focus = false
                        gian_slider.value = text
                    }
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
                    to:4
                    stepSize: 0.01
                    width: 180
                    x:fps_slider.x
                    value: 0
                    anchors.verticalCenter: gamma_text.verticalCenter
                    onValueChanged: mcap.setGamma(value)
                }

                TextField{
                    id:gamma_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /4.00|[0-3][\.][0-9]{1,2}|[0-4]/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: gamma_text.verticalCenter
                    text: gamma_slider.value.toFixed(2)
                    onAccepted: {
                        focus = false
                        gamma_slider.value = text
                    }
                }


                Text {
                    id: denoise_text
                    text: qsTr("降噪")
                    x:fps_text.x
                    y:220
                }

                CheckBox{
                    id: denoise_checked
                    x: 60
                    anchors.verticalCenter: denoise_text.verticalCenter
                    checked:false
                    onCheckedChanged:mcap.setDenoiseEnabled(checked)
                }

                Slider{
                    id: denoise_slider
                    from: 0
                    to:100
                    stepSize: 1
                    width: 180
                    x:fps_slider.x
                    value: 0
                    anchors.verticalCenter: denoise_text.verticalCenter
                    onValueChanged: mcap.setDenoise(value)
                }

                TextField{
                    id:denoise_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /100|[0-9]{1,2}/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: denoise_text.verticalCenter
                    text: denoise_slider.value.toFixed(0)
                    onAccepted: {
                        focus = false
                        denoise_slider.value = text
                    }
                }

                Text {
                    id: acuity_text
                    text: qsTr("锐度")
                    x:fps_text.x
                    y:260
                }

                CheckBox{
                    id: acuity_checked
                    x: 60
                    anchors.verticalCenter: acuity_text.verticalCenter
                    checked:false
                    onCheckedChanged:mcap.setAcuityEnabled(checked)
                }

                Slider{
                    id: acuity_slider
                    from: 0
                    to:100
                    stepSize: 1
                    width: 180
                    x:fps_slider.x
                    value: 0
                    anchors.verticalCenter: acuity_text.verticalCenter
                    onValueChanged: mcap.setAcuity(value)
                }

                TextField{
                    id:acuity_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /100|[0-9]{1,2}/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: acuity_text.verticalCenter
                    text: acuity_slider.value.toFixed(0)
                    onAccepted: {
                        focus = false
                        acuity_slider.value = text
                    }
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
                    onValueChanged: mcap.setBrightness(value)
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
                    onAccepted: {
                        focus = false
                        brightness_slider.value = text
                    }
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
                    to:4
                    stepSize: 1
                    width: 180
                    x:fps_slider.x
                    value: 0
                    anchors.verticalCenter: digtalshift_text.verticalCenter
                    onValueChanged:mcap.setDigtalShift(value)
                }

                TextField{
                    id:digtalshift_input
                    selectByMouse:true
                    validator: RegularExpressionValidator {
                        regularExpression: /[0-4]/
                    }
                    width: 60
                    x:300
                    anchors.verticalCenter: digtalshift_text.verticalCenter
                    text: digtalshift_slider.value.toFixed(0)
                    onAccepted: {
                        focus = false
                        digtalshift_slider.value = text
                    }
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
                width:60
                text:"确定"
                onClicked: {
                    saveCurrentSettings()
                    subwindow.close()
                }
            }
            Button{
                id:cancel
                width:60
                text:"取消"
                onClicked: {setLastSettings()}
            }

            Button{
                id:apply
                width:60
                text:"应用"
                onClicked:saveCurrentSettings()
            }
        }// end row
    } // end Column

    Button{
        id:default_set
        text:"恢复默认参数"
        x:fps_text.x
        y: 460
        onClicked: {
            resetDefaultSettings();
        }
    }

    function resetDefaultSettings(){
        fps_checked.checked = false
        fps_slider.value=210
        auto_exposure_combox.currentIndex = 0
        exposure_time_slider.value = 1.0
        gian_slider.value = 0
        gamma_slider.value = 1.0
        denoise_checked.checked = false
        denoise_slider.value = 0
        acuity_checked.checked = false
        acuity_slider.value = 0
        brightness_slider.value = 50
        digtalshift_slider.value = 0
        balance_combox.currentIndex = 0
        emitSetSignal()
    }

    function setLastSettings(){
        fps_checked.checked = workPowerSettings.fpsEnabled
        fps_slider.value=workPowerSettings.fps
        auto_exposure_combox.currentIndex = workPowerSettings.auto_exposure
        exposure_time_slider.value = workPowerSettings.exposure_time
        gian_slider.value = workPowerSettings.gain
        gamma_slider.value = workPowerSettings.gamma
        denoise_checked.checked = workPowerSettings.denoiseEnabled
        denoise_slider.value = workPowerSettings.denoise
        acuity_checked.checked = workPowerSettings.acuityEnabled
        acuity_slider.value = workPowerSettings.acuity
        brightness_slider.value = workPowerSettings.brightness
        digtalshift_slider.value = workPowerSettings.digtalshift
        balance_combox.currentIndex = workPowerSettings.balance
        emitSetSignal()
    }

    function saveCurrentSettings(){
        workPowerSettings.fpsEnabled = fps_checked.checked
        workPowerSettings.fps = fps_slider.value
        workPowerSettings.auto_exposure = auto_exposure_combox.currentIndex
        workPowerSettings.exposure_time = exposure_time_slider.value
        workPowerSettings.gain = gian_slider.value
        workPowerSettings.gamma = gamma_slider.value
        workPowerSettings.denoiseEnabled = denoise_checked.checked
        workPowerSettings.denoise = denoise_slider.value
        workPowerSettings.acuityEnabled = acuity_checked.checked
        workPowerSettings.acuity = acuity_slider.value
        workPowerSettings.brightness = brightness_slider.value
        workPowerSettings.digtalshift = digtalshift_slider.value
        workPowerSettings.balance = balance_combox.currentIndex
    }

    function emitSetSignal(){
        fps_checked.checkedChanged()
        fps_slider.valueChanged()
        auto_exposure_combox.currentIndexChanged()
        exposure_time_slider.valueChanged()
        gian_slider.valueChanged()
        gamma_slider.valueChanged()
        denoise_checked.checkedChanged()
        denoise_slider.valueChanged()
        acuity_checked.checkedChanged()
        acuity_slider.valueChanged()
        brightness_slider.valueChanged()
        digtalshift_slider.valueChanged()
        balance_combox.currentIndexChanged()
    }

// settings
    Settings{
        id:workPowerSettings
        fileName: "Config.ini"
        category: "work power settings"
        property bool fpsEnabled: false
        property real fps: 210
        property real auto_exposure: 0
        property real exposure_time: 1.00
        property real gain: 0
        property real gamma: 1.0
        property bool denoiseEnabled: false
        property real denoise: 0
        property bool acuityEnabled: false
        property real acuity: 0
        property real brightness: 50
        property real digtalshift: 0
        property real balance: 0
        property real blanceR: 1.68
        property real blanceG: 1.0
        property real blanceB: 1.37
    }

}




