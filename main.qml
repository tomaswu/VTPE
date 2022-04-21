import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1
import QtCharts 2.15

Window {
    id:root
    minimumWidth: 1024
    minimumHeight: 720
    visible: true
    title: qsTr("摄影物理实验工具")
    color:"#e1e1e1"

    ToolBar{
        id:toolbar
        width:parent.width-16
        height: 120
        y:0
        z:5
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

            Column{
                height: parent.height
                topPadding: 18
                leftPadding: 14
                rightPadding: 0
                bottomPadding: 0
                spacing: 18
                SToolButton{
                    id:undo
                    imgSrc: "qrc:/imgs/ico/undo.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("undo\n撤销",undo)
                    onClicked: {
                        console.log("undo")
                    }
                }

                SToolButton{
                    id:redo
                    imgSrc: "qrc:/imgs/ico/redo.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("redo\n重做",redo)
                    onClicked: console.log("redo")
                }
                Text{
                    id: label_undo
                    text: "撤消"
                }
            }

            ToolbarVSplit{}

            GridLayout{
                height: parent.height
                columns: 4
                rows: 4

                ComboBox{
                    id:camera_list
                    Layout.columnSpan: 3
                    model:mcap.cameraList
                    Connections{
                        target: mcap
                        function onCameraListChanged(){
                            camera_list.model=mcap.cameraList
                        }
                    }

                }

                SToolButton{
                    id:camera_open
                    imgSrc: "qrc:/imgs/ico/camera2.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("open/close camera\n打开/关闭相机",camera_open)
                    onClicked: {
                        if(!mcap.isOpened()){
                            var ret = mcap.open(camera_list.currentIndex)
                            if (!ret){
                                dia.showInfo("未能打开该相机！")
                            }
                            else{
                                mcap.startCapture()
                                mcap.setResolution("1280X720")
                            }
                        }
                        else{
                            mcap.release()
                        }
                    }//end onclick
                    Connections{
                        target:mcap
                        function onStopped(){
                            camera_img.source=""
                        }
                    }// end Connections
                }

                SToolButton{
                    id:camera_setting
                    imgSrc: "qrc:/imgs/ico/setting1.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("camera settings\n打开相机设置",camera_setting)
                    onClicked: mcap.openSettings()
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

                TCheckBox{
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

            ToolbarVSplit{}

            GridLayout{
                height: parent.height
                columns: 8
                rows: 4

                TCheckBox{
                    id: measurement_mark
                    implicitWidth: 64
                    checked:false
                    Layout.alignment: Qt.AlignLeft
                    text: "标尺"
                    Layout.columnSpan:2
                }

                ComboBox{
                    id:measuerment_scale_type
                    implicitWidth: 64
                    Layout.columnSpan: 2
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
                    checkable: true
                    onCheckedChanged: mscale.caliFlag = measurement_cali.checked
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
                    imgSrc: "qrc:/imgs/ico/text.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("put text\n添加文字",measurement_putText)
                    onClicked: console.log("camera open")
                }


                Text{
                    id:label_rotation
                    text: "旋转:"
                    color:global_color.primary
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
                    Layout.columnSpan: 8
                    Layout.alignment: Qt.AlignHCenter
                }


            }// end gird for measurement functions
            ToolbarVSplit{}

            GridLayout{
                height: parent.height
                columns: 8
                rows: 4

                SToolButton{
                    id:video_player
                    Layout.row: 0
                    Layout.column: 0
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/film.png"
                    checkable: true
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("show/hide player\n tools\n显示/关闭播放工具",video_player)
                    onClicked: playerbar.visible=!playerbar.visible
                }

                Text{
                    text: "分析方法:"
                    color:global_color.primary
                    Layout.row: 0
                    Layout.column: 1
                    Layout.columnSpan: 2
                }

                ComboBox{
                    id:rec_method
                    implicitWidth: 96
                    Layout.columnSpan: 4
                    valueRole:"name"
                    model: ListModel{
                        ListElement{name:"PMB0100"}
                        ListElement{name:"单色识别"}
                        ListElement{name:"帧差法"}
                    }
                }

                SToolButton{
                    id:video_analysis_para
                    Layout.row: 1
                    Layout.column: 0
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/para.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("set analysis paras\n设置分析参数",video_analysis_para)
                    onClicked: console.log("para settings")
                }


                SToolButton{
                    id:video_table
                    Layout.row: 1
                    Layout.column: 1
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/table.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("open tables\n打开表格窗口",video_table)
                    onClicked: console.log("data tables")
                }

                SToolButton{
                    id:video_fig
                    Layout.row: 1
                    Layout.column: 2
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/curve3.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("open figures\n打开绘图窗口",video_fig)
                    onClicked: console.log("data figures")
                }

                SToolButton{
                    id:video_export
                    Layout.row: 2
                    Layout.column: 7
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/export.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("export data\n导出数据",video_export)
                    onClicked: console.log("data export")
                }

                Text{
                    id: label_video_analysis
                    text: "视频识别"
                    Layout.row: 3
                    Layout.column: 0
                    Layout.columnSpan: 8
                    Layout.alignment: Qt.AlignHCenter
                }


            }// end for recognize

            ToolbarVSplit{}

            GridLayout{
                height: parent.height
                columns: 1
                rows: 4

                SToolButton{
                    id:opendevice
                    Layout.row: 0
                    Layout.column: 0
                    Layout.rowSpan: 2
                    Layout.alignment: Qt.AlignCenter
                    imgSrc: "qrc:/imgs/ico/device.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("open device\n打开设备",opendevice)
                    onClicked: devList.visible=true
                }
                Text{
                    id: label_device
                    text: "其他设备"
                    Layout.row: 3
                    Layout.column: 0
                    Layout.columnSpan: 1
                    Layout.alignment: Qt.AlignHCenter|Qt.AlignBottom
                }
            }// end devices

            ToolbarVSplit{}

            GridLayout{
                height: parent.height
                columns: 2
                columnSpacing: 12
                rows: 3
                SToolButton{
                    id:help
                    imgSrc: "qrc:/imgs/ico/help.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("help\n帮助",help)
                    onClicked: console.log("help")
                }
                SToolButton{
                    id:info
                    imgSrc: "qrc:/imgs/ico/info.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("about\n关于",info)
                    onClicked: dia.showInfo("名称:摄影物理实验工具\n版本:1.0\n\联系方式:tomasiwt@gmail.com")
                }

                SToolButton{
                    id:experiments_mannul
                    imgSrc: "qrc:/imgs/ico/book.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("experiment mannul\n实验手册",experiments_mannul)
                }

                SToolButton{
                    id:feedback
                    imgSrc: "qrc:/imgs/ico/feedback.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("feedback\n反馈",feedback)
                    onClicked: feedback_dialog.visible=true
                }


                Text{
                    id: label_help
                    text: "帮助"
                    Layout.row: 2
                    Layout.column: 0
                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignHCenter|Qt.AlignBottom
                }
            }// end help

            ToolTip{
                id: stoolbutton_tooltip
                y:toolbar.visible? toolbar.height:30
                z:101
                delay: 400
                text:"hello name"
                background: Rectangle{
                    width: 124
                    height: 60
                    border.width: 1
                    border.color: Qt.rgba(0,0,0.8,0.25)
                }
            }

        } //end row

    ParallelAnimation{
        id: animation_showToolbar
        NumberAnimation{
            target: toolbar
            properties: "y"
            from:-toolbar.height
            to: 0
            duration: 250;
            easing.type: Easing.Linear
        }
        NumberAnimation{
            target: toolbar
            properties: "opacity"
            from: 0.2
            to: 1
            duration: 250;
            easing.type: Easing.Linear
        }
        onStarted: toolbar_show.visible=false

    }

    ParallelAnimation{
        id: animation_closeToolbar
        NumberAnimation{
            target: toolbar
            properties: "y"
            from:0
            to: -toolbar.height
            duration: 250;
            easing.type: Easing.Linear
        }
        NumberAnimation{
            target: toolbar
            properties: "opacity"
            from: 1
            to: 0.2
            duration: 250;
            easing.type: Easing.Linear
        }
        onFinished: toolbar_show.visible=true
    }

        SToolButton{
            id:toolbar_hide
            imgSrc: "qrc:/imgs/ico/up.png"
            btnName: ""
            width: 16
            height: 16
            x:toolbar.x+toolbar.width-width-20
            y:toolbar.y+toolbar.height-width-2
            onHoveredChanged: tbntip("hide/show toolbar\n隐藏/显示工具栏",toolbar_hide)
            onClicked: animation_closeToolbar.start()
        }

    }// end toolbar

    SToolButton{
        //隐藏工具栏后的呼出热键
        id:toolbar_show
        imgSrc: "qrc:/imgs/ico/down.png"
        btnName: ""
        width: 24
        height: 24
        radius: 4
        x:toolbar_hide.x+4
        y:height/2
        z:101
        visible: false
        onClicked: animation_showToolbar.start()
    }

    // player bar
    Rectangle {
        id : playerbar
        width: toolbar.width
        height: 120
        color:Qt.rgba(1,1,1,0.25)
        anchors.left: toolbar.left
        radius:8
        y:parent.height-height-35
        visible: video_player.checked
        z:3

            Column{
                anchors.fill: parent
                padding:16
                spacing:8

                Text {
                    id: video_fileName
                    width: 20
                    text: qsTr("C:/Users/tomas wu/videos/test.avi")
                }

                TriSlider{
                    id: slider
                    width:parent.width-2*parent.padding
                    height: 30
                }

                Row{
                    //播放按钮组
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing:20

                    SToolButton2{
                        id:backward
                        imgSrc: "qrc:/imgs/ico/backward.png"
                        btnName: ""
                        width: 24
                        height: 24
                        onClicked: if (slider.value1>slider.value0)slider.value1-=1

                    }
                    SToolButton{
                        id:play
                        imgSrc: "qrc:/imgs/ico/play.png"
                        btnName: ""
                        width: 24
                        height: 24
                    }
                    SToolButton2{
                        id:forward
                        imgSrc: "qrc:/imgs/ico/forward.png"
                        btnName: ""
                        width: 24
                        height: 24
                        onClicked: if (slider.value1<slider.value2)slider.value1+=1
                    }
                }// end buttons row

            } //end column

    } // end player bar

    function tbntip(s,item){
        if (item.hovered){
            stoolbutton_tooltip.x=item.x+item.parent.x
            if (stoolbutton_tooltip.x+stoolbutton_tooltip.width>root.width){
                stoolbutton_tooltip.x=stoolbutton_tooltip.x-stoolbutton_tooltip.width
            }
            stoolbutton_tooltip.show(s,5000)
        }
        else{
            stoolbutton_tooltip.hide()
        }

    }//end function

    Dialog{
        // 用来显示一些信息,比如版本信息等
        id: dia
        anchors.centerIn: parent
        width: 300
        height: 120
        background: Rectangle{
            id:dia_bg
            anchors.fill: parent
            radius:8
            color:"#ffffff"
        }
        RowLayout{
            anchors.centerIn: parent
            spacing: 16
            width:parent.width-10
            height: parent.height-10
            MaskImage {
                id: dia_img
                width: 50
                height: 50
                source: "qrc:/imgs/ico/info.png"
                Layout.alignment: Qt.AlignCenter
                Layout.maximumWidth: width
                Layout.maximumHeight: height
            }


            Text{
                id:dia_text
                wrapMode: Text.WordWrap
                Layout.alignment: Qt.AlignVCenter
            }
        }

        function showInfo(s){
            dia_text.text=s
            dia.height = dia_text.contentHeight<=120 ? 130 : dia_text.contentHeight+10
            dia.open()
        }

    }// end dialog

    SwipeView{
        id:centerWidget
        implicitWidth: parent.width
        height: parent.height-toolbar.height-toolbar.y
        anchors.top: toolbar.bottom
        z:0

        Page{
            id:camera_widget
            title: "camera"
            Rectangle{
                id:camera_widget_bg
                anchors.fill:parent
                color: Qt.rgba(0,0.6,0.6,0.2)
                Image {
                    id:camera_img
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source:""
                    cache: false
                    Connections{
                        target: mcap
                        function onImageRefreshed(){
                            camera_img.source=""
                            camera_img.source="image://cameraImage"
                        }
                    }//end Connections
                } // end image
            } // end rect

            ChartView {
                id:pmc0100_chart
                width:centerWidget.width
                height: 300
                anchors.bottom: parent.bottom
                antialiasing: false
                SplineSeries {
                    id : pmc0100_data
                    property int mycount: 0
                    useOpenGL: true
                    name: "拉力大小（mV）"
                    axisX: ValuesAxis{
                        id:pmc0100_chart_x
                        min:0
                        max:200
                    }
                    axisY: ValuesAxis{
                        id:pmc0100_chart_y
                        min:0
                        max:200
                    }
                    XYPoint { x: 0; y: 0.0 }
                } // end data

                Connections {
                    target: pmc0100_com
                    function onNewValueReady(value){
//                        console.log(value)
                        pmc0100_data.mycount+=1
                        if (pmc0100_data.count>200){
                            pmc0100_data.removePoints(0,1)
                            pmc0100_chart_x.min+=1
                            pmc0100_chart_x.max+=1
                        }
                        pmc0100_data.append(pmc0100_data.mycount,value)
                    }
                }

            }

        }// page camera widget

        Page{
            id:video_widget
            title: "video"

            Rectangle{
                id:video_widget_bg
                anchors.fill:parent
                color: Qt.rgba(0.6,0.6,0,0.2)
            }

            Image{

            }

        }// page video widget



    }// end swipe

    // Measurement item
    MeasureScale{
        id : mscale
        x:toolbar.x
        y:centerWidget.y
        z:2
        width: centerWidget.width
        height: centerWidget.height
        visible: measurement_mark.checked
        markerType: measuerment_scale_type.currentIndex
        caliFlag: false
        onCaliFlagChanged: measurement_cali.checked=caliFlag
    }//end MeasureScale

    //email feedback Dialog
    EmailFeedback{
        id:feedback_dialog
        anchors.centerIn: parent
        z:101
        color:"white"
        visible: false
    }


    // Device list pannel
    DeviceList{
        id:devList
        anchors.centerIn: parent
        radius: 8
        visible: false
        width:260
        height: 360
    }


    // -------------------- setting ------------------------
    Settings{
        id:global_color
        fileName: "colorSetting.ini"
        category: "global_color"
        property string primary: "#555555"//"#33a3dc"
        property string ancent: "lightgray"
    }

    function backDefaultGlobalSettings(){
        global_color.primary = "#505050"
        global_color.ancent = "lightgray"
    }

    // ----------------------end setting ---------------------


}// end window
