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
            spacing: 5
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
                    Layout.row: 4
                    Layout.column: 0
                    Layout.columnSpan: 3
                    Layout.alignment: Qt.AlignHCenter
                }

            }// end gird
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

         } //end column


    }// end toolbar

    function tbntip(s,item){
        if (item.hovered){
            stoolbutton_tooltip.x=item.x
            stoolbutton_tooltip.show(s,5000)
        }
    }//end function

}// end window
