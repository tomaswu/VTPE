//这个窗口只是华谷动力相机的设置页面
import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1
import QtCharts 2.15
import QtQuick.Dialogs

Rectangle{
    id: subwindow
    width: 420
    height: 480

    Column{
        anchors.fill:parent
        spacing: 10
        padding:20
        Rectangle{
            id : para_widget
            width: parent.width-parent.padding*2
            height: 400
            border.width: 1
            border.color: "lightgreen"
            property int sapcing: 10

                Text {
                    id: fps_text
                    text: "帧率"
                    x:30
                    y:20
                }

                Slider{
                    id: fps_slider
                    from: 1
                    to:210
                    stepSize: 1
                    width: 180
                    x:100
                    value: fps_spinbox.value
                    anchors.verticalCenter: fps_text.verticalCenter
                }

                TextField{
                    id:fps_input
                    width: 60
                    x:300
                    anchors.verticalCenter: fps_text.verticalCenter
                    validator: IntValidator{
                        bottom:1
                        top: 210
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
                    text: exposure_time_slider.value
                    onTextChanged: exposure_time_slider.value = text
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
                onClicked: { }
            }

            Button{
                id:apply
                text:"应用"
                onClicked:{ }
            }
        }// end row

    }

}


