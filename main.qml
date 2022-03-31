import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    width: 1024
    height: 720
    visible: true
    title: qsTr("Hello World")
    color:"lightgray"

    ToolBar{
        id:toolbar
        width:parent.width-16
        height: 120
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        background: Rectangle{
            anchors.fill: parent;
            color:"white"
            radius: 10
        }

        Row{
            height: parent.height
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            padding:2
            spacing: 16
            GridLayout{
                height: parent.height
                columns: 4
                rows: 4

                ComboBox{
                    id:camera_list
                    Layout.columnSpan: 3

                }

                SToolButton{
                    id:camera_open
                    imgSrc: "qrc:/imgs/ico/camera.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("open/close camera\n打开/关闭相机",camera_open)
                    onClicked: console.log("camera open")
                }

                SToolButton{
                    id:camera_setting
                    imgSrc: "qrc:/imgs/ico/setting1.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("camera settings\n打开相机设置",camera_setting)
                    onClicked: console.log("camera setting")
                }

                SToolButton{
                    id:camera_savePhoto
                    imgSrc: "qrc:/imgs/ico/save2.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("save a photo\n保存一张预览图片",camera_savePhoto)
                    onClicked: console.log("camera setting")
                }

                SToolButton{
                    id:camera_capture
                    imgSrc: "qrc:/imgs/ico/video.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("strat/stop capture\n开始/停止录像",camera_capture)
                    onClicked: console.log("camera setting")
                }

                SToolButton{
                    id:camera_setVideoName
                    imgSrc: "qrc:/imgs/ico/file.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("set video path\n设置录像保存位置",camera_setVideoName)
                    onClicked: console.log("camera setting")
                }

                CheckBox{
                    id:camera_cali
                    text: "畸变校正"
                    Layout.columnSpan: 3
                }

                SToolButton{
                    id:camera_matrix
                    imgSrc: "qrc:/imgs/ico/matrix2.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("Calculate camera \nmatrix\n计算相机矩阵",camera_matrix)
                    onClicked: console.log("camera setting")
                }

                Text{
                    id: label_camera
                    text: "相机功能"
                    Layout.row: 3
                    Layout.column: 0
                    Layout.columnSpan: 4
                    Layout.alignment: Qt.AlignHCenter
                }

            }// end gird  for camera functions
            Rectangle{
                color:Qt.rgba(0,0,0,0.2)
                width: 1
                height: parent.height-parent.padding*2
            }

            GridLayout{
                height: parent.height
                columns: 8
                rows: 4

                CheckBox{
                    id: measurement_mark
                    implicitWidth: 64
                    Layout.alignment: Qt.AlignLeft
                    text: "标尺"
                    Layout.columnSpan:2
                }

                ComboBox{
                    id:measuerment_scale_type
                    implicitWidth: 64
                    Layout.columnSpan: 2
//                    Layout.alignment: Qt.AlignLeft
                    valueRole:"name"
                    model: ListModel{
                        ListElement{name:"十字"}
                        ListElement{name:"同心圆"}
                        ListElement{name:"网格"}
                    }

                }

                SToolButton{
                    id:measurement_cali
                    imgSrc: "qrc:/imgs/ico/ruler.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("calibrate the scale\n定标比例尺",measurement_cali)
                    onClicked: console.log("camera open")
                }

                SToolButton{
                    id:measurement_select
                    Layout.row: 1
                    Layout.column: 0
                    Layout.alignment: Qt.AlignCenter
                    imgSrc: "qrc:/imgs/ico/select.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("select a select for \nmeasurement\n选择范围进行测量",measurement_select)
                    onClicked: console.log("camera open")
                }

                SToolButton{
                    id:measurement_cut
                    Layout.row: 1
                    Layout.column: 1
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/cut.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("cut image\n裁剪",measurement_cut)
                    onClicked: console.log("camera open")
                }

                SToolButton{
                    id:measurement_gray_curve
                    Layout.row: 1
                    Layout.column: 2
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/curve.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("gray curve\n灰度曲线测量",measurement_gray_curve)
                    onClicked: console.log("camera open")
                }

                SToolButton{
                    id:measurement_putText
                    Layout.row: 1
                    Layout.column: 3
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/text-field.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("put text\n添加文字",measurement_putText)
                    onClicked: console.log("camera open")
                }


                Text{
                    id:label_rotation
                    text: "旋转:"
                    Layout.row: 2
                }

                Slider{
                    id:rotation_deg
                    implicitWidth: 96
                    Layout.row: 2
                    Layout.column: 1
                    Layout.columnSpan: 3
                    Layout.alignment: Qt.AlignCenter
                    from: 0
                    to: 360
                    value:rotation_deg_spinbox.value
                    onValueChanged: {rotation_deg_spinbox.value=rotation_deg.value;console.log("changed")}
                }// end slider

                SpinBox{
                    id:rotation_deg_spinbox
                    implicitWidth: 45
                    Layout.row: 2
                    Layout.column: 4
                    from: 0
                    to:360
                } // end SpinBox

                Text{
                    id: label_camera_measurement
                    text: "测量工具"
                    Layout.row: 3
                    Layout.column: 0
                    Layout.columnSpan: 4
                    Layout.alignment: Qt.AlignHCenter
                }


            }// end gird for measurement functions
            Rectangle{
                color:Qt.rgba(0,0,0,0.2)
                width: 1
                height: parent.height-parent.padding*2
            }

            ToolTip{
                id: stoolbutton_tooltip
                y:toolbar.height
                z:101
                delay: 400
                text:"hello name"
                background: Rectangle{
                    width: 120
                    height: 60
                }
            }

         } //end row

    }// end toolbar

    function tbntip(s,item){
        if (item.hovered){
            stoolbutton_tooltip.x=item.x+item.parent.x
            stoolbutton_tooltip.show(s,5000)
        }
        else{
            stoolbutton_tooltip.hide()
        }
    }//end function

}// end window
