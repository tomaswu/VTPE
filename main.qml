﻿import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1
import QtCharts 2.15
import QtQuick.Dialogs


Window {
    id:root
    minimumWidth: 1024
    minimumHeight: 720
    visible: true
    title: qsTr("摄影物理实验工具")
    color:"#e1e1e1"

    Component.onCompleted: {
        var s=shell.getNewNameByTime(folder_recording.photoFolder,".png")
    }

    onClosing:function (close){
        stro_para_window.close()
        data_process_firgure.close()
        pmb0100_para_window.close()
        camera_settings_widnow.close()
        feedback_dialog.visible=false
        camera_settings_dialog.visible=false
        if(stro_para_window.show_flag || data_process_firgure.figs>0){
            close.accepted=false
            dia.showInfo("需要先关闭绘图窗口！")
        }
        if(mvid.isOpened()){
            mvid.close()
        }
    }

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
                            if(camera_list.count<=0){
                                dia.showInfo("没有找到可打开的相机！")
                                return
                            }

                            var ret = mcap.open(camera_list.currentIndex)
                            if (!ret){
                                dia.showInfo("未能打开该相机！")
                            }
                            else{
                                mcap.startCapture()
                                var rlist = mcap.getSupportedResolutions()
                                camera_settings_dialog.refreshResolutions(rlist)
                                centerWidget.currentIndex = 0
                            }
                        }
                        else{
                            if(mcap.isRecord()){
                                mcap.stopRecord()
                            }
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
                    onClicked: {
                        if(mcap.isOpened()){
                            camera_settings_dialog.open()
                        }
                        else{
                            dia.showInfo("请先打开相机！")
                        }
                    }
                }

                SToolButton{
                    id:camera_savePhoto
                    imgSrc: "qrc:/imgs/ico/save2.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("save a photo\n保存一张预览图片",camera_savePhoto)
                    onClicked: {
                        if (mcap.isOpened()){
                            mcap.needPhoto()
                            if(camera_settings_dialog.photoMode){
                                var fn = shell.getNewNameByTime(folder_recording.photoFolder,".png")
                                var ret = mcap.savePhoto(fn)
                                if(ret){
                                    var s = `图片已保存 file:\\\\\\${fn}`
                                    camera_saveinfo.camera_saveinfoShow(s)
                                }
                            }
                            else{
                                fileSave_dialog.open()
                            }
                        }
                        else{
                            dia.showInfo("请先打开相机！")
                        }
                    }
                }

                SToolButton{
                    id:camera_capture
                    imgSrc: "qrc:/imgs/ico/video.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("strat/stop capture\n开始/停止录像",camera_capture)
                    onClicked: {
                        if(mcap.isOpened()){
                            if(!mcap.isRecord()){
                                if(!folder_recording.recordPath || !folder_recording.recordPath.endsWith(".avi")){
                                    dia.showInfo("请先设置录像保存路径！")
                                }
                                else{
                                    if(shell.isFile(folder_recording.recordPath)){
                                        var ret = shell.confirm_message("是否覆盖？",folder_recording.recordPath+"已经存在!")
                                        if(!ret){
                                            return
                                        }
                                    }
                                    mcap.startRecord(folder_recording.recordPath)
                                    if(mcap.isRecord()){
                                        record_led_blink_timer.start()
                                    }
                                }
                            }
                            else{
                                mcap.stopRecord();
                                record_led_blink_timer.stop()
                                record_led.color = "darkgray"
                                camera_saveinfo.camera_saveinfoShow("视频已保存 file:\\\\\\"+folder_recording.recordPath)
                            }
                        }
                        else{
                            dia.showInfo("请先打开相机！")
                        }
                    }
                    Connections {
                        target:mcap
                        function onRecordFinished(info){
                            if (info==="mem stop"){
                                dia.showInfo("因CPU性能不足导致内存已满,\n已自动停止录像！\n请耐心等待程序编码内存中的内容！")
                            }
                            else{
                                dia.close()
                                record_led_blink_timer.stop()
                                record_led.color = "darkgray"
                                camera_saveinfo.camera_saveinfoShow("视频已保存 file:\\\\\\"+folder_recording.recordPath)
                            }
                        }
                    }
                }

                SToolButton{
                    id:camera_setVideoName
                    imgSrc: "qrc:/imgs/ico/file.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("set video path\n设置录像保存位置",camera_setVideoName)
                    onClicked:{
                        var s = shell.getSaveFileName("保存",folder_recording.recordPath,"avi(*.avi)")
                        if (s!==""){
                            folder_recording.recordPath = s
                        }
                    }// end clicked
                }

                TCheckBox{
                    id:camera_cali
                    text: "畸变校正"
                    Layout.columnSpan: 3
                    checked: false
                    onCheckStateChanged: {
                        mcap.setCaliFlag(checked)
                        mvid.setCaliFlag(checked)
                        if(mvid.isOpened()){
                            mvid.reloadFrame()
                        }
                    }
                }

                SToolButton{
                    id:camera_matrix
                    imgSrc: "qrc:/imgs/ico/matrix2.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("Calculate camera \nmatrix\n计算相机矩阵",camera_matrix)
                    onClicked: {
                        var fd = shell.getExistingFolder("选择校正图片所在文件夹",folder_recording.lastOPenedFolder)
                        if(fd){
                            folder_recording.lastOPenedFolder=fd
                            var s = mcap.calibration(fd)
                            dia.showInfo(s)
                        }
                    }
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
                    onCheckedChanged: {
                        if(measurement_select.checked&&checked)measurement_select.checked=false
                        mscale.caliFlag = measurement_cali.checked
                    }
                }

                SToolButton{
                    id:measurement_select
                    checkable: true
                    Layout.row: 1
                    Layout.column: 0
                    Layout.alignment: Qt.AlignCenter
                    imgSrc: "qrc:/imgs/ico/select.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("select a scale for \nmeasurement\n选择范围进行测量",measurement_select)
                    onCheckedChanged: {
                        mouseArea_select.enabled = checked
                        s4i.visible = checked
                    }
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
                    onClicked: dia.showInfo("暂不支持的功能！")
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
                    onClicked: dia.showInfo("暂不支持的功能！")
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
                    onClicked: dia.showInfo("暂不支持的功能！")
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
                    id:video_open
                    Layout.row: 0
                    Layout.column: 0
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/file.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("open video\n打开视频",video_open)
                    onClicked: {
                        var fileName=shell.getOpenFileName("打开视频",folder_recording.recordPath,"video(*.avi *.mp4)")
                        if(fileName){
                            if(mvid.isPlaying()){
                                play.clicked()
                            }
                            var dir = shell.getFolderFromFilePath(fileName)
                            folder_recording.recordPath = dir
                            centerWidget.currentIndex = 1
                            if(Qt.platform.os==="windows"){
                                fileName = fileName.replace(new RegExp("/", "g"),"\\")
                            }//end switch
                            mvid.open(fileName)
                            if(mvid.isOpened()){
                                slider.value0=0
                                var fps = mvid.getFps().toFixed(2)
                                video_fps_text.text = `视频帧率: ${fps}`
                                data_process_firgure.setFps(fps)
                                mvid.setPlaySpeed(play_speed.currentText)
                                video_player.checked=true
                                data_table.fps=fps
                                stro_para_window.setFrameCount(mvid.getFrameCount())
                                var img_size = mvid.getImageSize()
                                pmb0100_para_window.setScale(0,img_size[0],0,img_size[1])
                            }
                            else{
                                dia.showInfo("未能打开视频！")
                            }
                        }
                    }
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
                    id:video_player
                    Layout.row: 1
                    Layout.column: 0
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/film.png"
                    checkable: true
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("show/hide player\n tools\n显示/关闭播放工具",video_player)
                    onCheckedChanged: {
                        if(checked){
                            centerWidget.currentIndex=1
                            centerWidget.interactive = false
                        }
                        else{
                            centerWidget.interactive = true
                        }
                        playerbar.visible=!playerbar.visible
                    }
                }

                SToolButton{
                    id:video_analysis_para
                    Layout.row: 1
                    Layout.column: 1
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/para.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("set analysis paras\n设置分析参数",video_analysis_para)
                    onClicked: {
                        if(mvid.isOpened()){
                            switch (rec_method.currentIndex){
                                case 0:
                                    centerWidget.currentIndex = 1
                                    pmb0100_para_window.show()
                                    data_table.unitRatio=pmb0100_para_window.getRatio()
                                    break
                                default:
                                    dia.showInfo("暂不支持的方法")
                            }
                        }
                        else{
                            dia.showInfo("需要先打开视频！")
                        }
                    }
                }


                SToolButton{
                    id:video_table
                    Layout.row: 1
                    Layout.column: 2
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/table.png"
                    btnName: ""
                    width: 24
                    height: 24
                    checkable: true
                    onHoveredChanged: tbntip("open tables\n打开表格窗口",video_table)
                    onCheckedChanged: {
                        if(checked){
                            centerWidget.currentIndex=1
                            animation_show_table.start()
                            mouseArea_zoom.x=data_table.width
                            mouseArea_zoom.width=centerWidget.width-15-data_table.width
                        }
                        else{
                            animation_hide_table.start()
                            mouseArea_zoom.x=centerWidget.x+15
                            mouseArea_zoom.width=centerWidget.width-30
                        }
                    }
                }

                SToolButton{
                    id:video_fig
                    Layout.row: 1
                    Layout.column: 3
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/curve3.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("process and figure\n数据处理与绘图",video_fig)
                    onClicked: {
                        if(data_table.isEmpty()){
                            dia.showInfo("没有可处理的数据")

                        }
                        else{
                            data_process_firgure.show()
                            var r = data_table.getHeaderName()
                            data_process_firgure.setCombox(r,r)
                        }
                    }
                }

                SToolButton{
                    id:stroboscopic_map
                    Layout.row: 1
                    Layout.column: 4
                    Layout.alignment: Qt.AlignLeft
                    imgSrc: "qrc:/imgs/ico/frequency.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("stroboscopic map\n频闪图",stroboscopic_map)
                    onClicked: {
                        if(!mvid.isOpened()){
                            dia.showInfo("没有打开视频！")
                        }
                        else{
                            if(data_table.dataList.length<=0){
                                dia.showInfo("没有识别信息可供生成频闪图！")
                            }
                            else{
                                stro_para_window.show();
                            }
                        }
                    }
                }

                Text{
                    text: "播放速度:"
                    color:global_color.primary
                    Layout.row: 2
                    Layout.column: 0
                    Layout.columnSpan: 2
                }

                ComboBox{
                    id:play_speed
                    implicitWidth: 64
                    Layout.columnSpan: 4
                    valueRole:"name"
                    currentIndex:2
                    model: ListModel{
                        ListElement{name:"0.25"}
                        ListElement{name:"0.5"}
                        ListElement{name:"1.0"}
                        ListElement{name:"1.5"}
                    }
                    onCurrentTextChanged:{
                        if(mvid.isOpened()){
                            mvid.setPlaySpeed(currentText)
                        }
                    }
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
                    onClicked: {
                        data_table.export2csv()
                    }
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
                    onClicked:{
                        var mf=shell.getDirByFilePaht(Qt.application.arguments[0])+"\\softwareManual.pdf"
                        shell.openFile(mf)
                    }
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
                    id:experiments_manual
                    imgSrc: "qrc:/imgs/ico/book.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onHoveredChanged: tbntip("experiment mannul\n实验手册",experiments_manual)
                    onClicked: {
                        var mf=shell.getDirByFilePaht(Qt.application.arguments[0])+"\\ZKY-PMB0100SS.pdf"
                        shell.openFile(mf)
                    }
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

//    Rectangle{
//        id:toolbar_bg //用来挡一下图像移动位置时从工具栏缝里露出来的
//        x:0
//        y:toolbar.y
//        z:toolbar.z-1
//        width:root.width
//        height: toolbar.height
//        color:root.color

//    }

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
        z:5
        visible: false
        onClicked: animation_showToolbar.start()
    }

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
        z:5
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
        height:parent.height-toolbar.height-toolbar.y
        anchors.top: toolbar.bottom
        clip:true
        z:0

        Page{
            id:camera_widget
            z:1
            title: "camera"
            Rectangle{
                id:camera_widget_bg
                anchors.top: parent.top
                width: parent.width
                height: parent.height-camera_status_bar.height
                color: "#f3f3f3"//Qt.rgba(0,0.6,0.6,0.2)
                z:1
                Image {
                    id:camera_img
//                   anchors.fill: parent
                    property real timgWidth: 0
                    property real timgHeight:0
                    x:(centerWidget.width-timgWidth)/2
                    y:(centerWidget.height-timgHeight)/2
                    z:2
                    fillMode: Image.PreserveAspectFit
                    source:""
                    cache: false
                    Connections{
                        target: mcap
                        function onImageRefreshed(){
                            if(mcap.isOpened()){
                            camera_img.source=""
                            camera_img.source="image://cameraImage"
                            camera_img.timgWidth=camera_img.width
                            camera_img.timgHeight=camera_img.height
                            }else{
                                camera_img.source=""
                            }
                        }
                    }//end Connections
                    onTimgHeightChanged: zoom_label.adjustScreen()
                    onTimgWidthChanged: zoom_label.adjustScreen()

                } // end image
            } // end rect

            // pmc0100 chart view for the serial port data
            ChartView {
                id:pmc0100_chart
                width:parent.width
                height: 400
                backgroundColor: Qt.rgba(1,1,1,0)
//                x:(camera_img.width-camera_img.paintedWidth)/2
//                y:(camera_img.height-camera_img.paintedHeight)/2
                x:parent.x
                y:0
                z:3
                antialiasing: true
                visible: false

                Text{
                    id:pmc0100_chart_value_text
                    x:parent.width-width-80
                    y:110
                    z:3
                    text: "当前值:0"
                    color: "red"
                }

                SplineSeries {
                    id : pmc0100_data
                    color: Qt.rgba(0,1,0,1)
                    width: 2
                    property int mycount: 0
                    useOpenGL: true
                    name: "拉力大小（mV）"
                    axisXTop: ValuesAxis{
                        id:pmc0100_chart_x
                        gridVisible:false
                        min:0
                        max:10000
                        color:"red"
                    }
                    axisY: ValuesAxis{
                        id:pmc0100_chart_y
                        gridVisible:false
                        min:0
                        max:1200
                        minorTickCount: 5
                        minorGridVisible: false
                        tickCount:7
                        color:"red"
                    }
                    XYPoint { x: 0; y: 0.0 }
                } // end data

                Connections {
                    target: pmc0100_com
                    function onNewValueReady(value){
                        pmc0100_data.mycount+=1
                        var dc = 20
                        if(pmc0100_data.mycount%dc==0){
                            if (pmc0100_data.count>(pmc0100_chart_x.max-pmc0100_chart_x.min)/dc/2){
                                pmc0100_data.removePoints(0,1)
                                pmc0100_chart_x.min+=dc
                                pmc0100_chart_x.max+=dc
                            }
                            pmc0100_data.append(pmc0100_data.mycount,value)
                            pmc0100_chart_value_text.text = "当前值:"+value.toString()
                        }
                    }
                }

                SToolButton{
                    id: btn_close_pmc0100
                    width:22
                    height: 22
                    x:parent.width-width-20
                    y:20
                    z:3
                    imgSrc: "qrc:/imgs/ico/close.png"
                    btnName: ""
                    icoColor: hovered ? "red": "lightgreen"
                    visible: parent.visible
                    onClicked: {
                        pmc0100_com.stop()
                        parent.visible=false
                    }
                }// end close button

                SToolButton{
                    id: btn_pause_pmc0100
                    width:22
                    height: 22
                    x: btn_close_pmc0100.x-width-20
                    y:20
                    z:3
                    property bool flag: true
                    imgSrc: flag ?"qrc:/imgs/ico/pause.png" : "qrc:/imgs/ico/play.png"
                    btnName: ""
                    icoColor: "lightgreen"
                    visible: parent.visible
                    onClicked: {
                        if (flag){
                            pmc0100_com.pause()
                            flag = !flag
                        }
                        else{
                            pmc0100_com.restartFromPause()
                            flag = !flag
                        }
                    }
                }// end close button

                function clear(){
                    pmc0100_data.clear()
                    pmc0100_chart_x.min = 0
                    pmc0100_chart_x.max = 10000
                    pmc0100_data.mycount = 0
                }
            }// end chart view

            // camera stauts bar
            Rectangle{
                id: camera_status_bar
                width: parent.width
                height: 24
                z:4
                color:"#007acc"
                anchors.bottom: parent.bottom


                Text {
                    id: camera_fps_text
                    z:4
                    x:10
                    anchors.verticalCenter: parent.verticalCenter
                    text: mcap.opened ? "相机帧率: " + mcap.fps.toString() : "相机帧率: 未打开"
                    color: "#ffffff"//"#3c3c3c"
                    Connections{
                        target: mcap
                        function onFpsChanged(fps){
                            camera_fps_text.text = "相机帧率: " + mcap.fps.toString()
                        }
                    }
                    Connections{
                        target: mcap
                        function onOpenedChanged(){
                            if(!mcap.opened)camera_fps_text.text = "相机帧率: 未打开"
                        }
                    }
                }

                Rectangle{
                    id: record_led
                    x: camera_fps_text.x+camera_fps_text.width+15
                    anchors.verticalCenter: parent.verticalCenter
                    z:4
                    width: 12
                    height: width
                    radius: width/2
                    color:"darkgray"
                    property bool light: false
                    Timer{
                        id:record_led_blink_timer
                        interval:800
                        repeat: true
                        onTriggered: {
                            if(record_led.light){
                                record_led.color="darkgray"
                            }
                            else{
                                record_led.color="red"
                            }
                            record_led.light=!record_led.light
                        }


                    }
                }

                Text {
                    id: record_fps_text
                    x: record_led.x+record_led.width+15
                    anchors.verticalCenter: parent.verticalCenter
                    z:4
                    text: "录像帧率: "
                    color: "#ffffff"//"#3c3c3c"
                    Connections{
                        target: mcap
                        function onRecordFpsChanged(rfps){
                            if(rfps>=0){
                                record_fps_text.text = "录像帧率: "+rfps.toString()
                            }
                            else{
                                record_fps_text.text = "录像帧率: "
                            }
                        }
                    }
                }

                Text {
                    id: camera_saveinfo
                    z:4
                    x: record_fps_text.x+record_fps_text.width+15
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width-x-(parent.width-camera_statusbar_zoom_label.x)
                    text: ""
                    color:"#ffffff"
                    font.underline: true
                    elide: Text.ElideRight
                    MouseArea{
                        id:camera_saveinfo_mouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var path = camera_saveinfo.text.slice(14,camera_saveinfo.length)
                            var cmd
                            switch(Qt.platform.os){
                               case "windows":
                                   path = path.replace(new RegExp("/", "g"),"\\")
                                   cmd = `explorer /select, ${path}`
                                   shell.system(cmd)
                                   break
                               case "osx":
                                   cmd = `open -R /${path}`
                                   shell.system(cmd)
                                   break
                               default:
                                   dia.showInfo("本系统暂不支持在文件系统\n中显示该文件")
                                   break
                            }//end switch
                        }// end onClicked
                    }//end MouseArea

                    Timer{
                        id:camera_saveinfo_timer
                        interval: 18000
                        triggeredOnStart: false
                        repeat: false
                        onTriggered: camera_saveinfo.text=""
                    }
                    function camera_saveinfoShow(s){
                        camera_saveinfo.text=s
                        camera_saveinfo_timer.start()
                    }
                }


                Text {
                    id: camera_statusbar_zoom_label
                    z:4
                    anchors.verticalCenter: parent.verticalCenter
                    x:camera_status_bar.width-80
                    text: "缩放:100% "
                    color: "#ffffff"//"#3c3c3c"
                }

            }// end status bar

        }// page camera widget

        Page{
            id:video_widget
            title: "video"
            z:1

            Ttable{
                id: data_table
                x:-width
                z:3
                visible: false
                anchors.top: parent.top
                anchors.bottom: video_status_bar.top
            }

            Rectangle{
                id:video_widget_bg
                z:1
                anchors.fill:parent
                color: Qt.rgba(0.6,0.6,0,0.2)
            }

            Image{
                id:video_img
                z:2
//                anchors.left: data_table.right
//                anchors.right: parent.right
//                anchors.top: parent.top
//                anchors.bottom: video_status_bar.top
                property real timgWidth: 0
                property real timgHeight:0
                x:(centerWidget.width-timgWidth)/2
                y:(centerWidget.height-timgHeight)/2
                fillMode: Image.PreserveAspectFit
                source:""
                cache: false
                Connections{
                    target: mvid
                    function onImageRefreshed(){
                        if(mvid.isOpened()){
                        video_img.source=""
                        video_img.source="image://videoImage"
                        video_img.timgWidth=video_img.width
                        video_img.timgHeight=video_img.height
                        }else{
                            camera_img.source=""
                        }
                    }
                }//end Connections
                onTimgHeightChanged: zoom_label.adjustScreen()
                onTimgWidthChanged: zoom_label.adjustScreen()
            } //end image

            // player bar
            Rectangle {
                id : playerbar
                width: toolbar.width
                height: 120
                color:Qt.rgba(1,1,1,0.25)
                x:toolbar.x
                z:3
                radius:8
                y:parent.height-height-35
                visible: video_player.checked

                    Column{
                        anchors.fill: parent
                        padding:16
                        spacing:8

                        Text {
                            id: video_fileName
                            z:3
                            width: 20
                            text: qsTr("C:/Users/tomas wu/videos/test.avi")
                        }

                        TriSlider{
                            id: slider
                            z:3
                            width:parent.width-2*parent.padding
                            height: 30
                            onValue0Changed: mvid.setBeginPos(value0)
                            onValue2Changed: mvid.setEndPos(value2)
                            onSetValue1:mvid.setPos(value1)
                            Connections{
                                target: mvid
                                function onPosChanged(){
                                    if(!slider.mouseControled){
                                        slider.value1 = mvid.pos
//                                        console.log(mvid.pos)
                                    }
                                }
                            }
                            Connections{
                                target: mvid
                                function onAlreadyOpened(){
                                    slider.from = 0
                                    slider.to = mvid.getFrameCount()
                                    slider.value2 = slider.to
                                    slider.value1=0
                                }
                            }
                        }

                        Row{
                            //播放按钮组
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing:20

                            SToolButton2{
                                id:backward
                                z:3
                                imgSrc: "qrc:/imgs/ico/backward.png"
                                btnName: ""
                                width: 24
                                height: 24
                                onClicked: {
                                    if (slider.value1>slider.value0){
                                        slider.value1-=1
                                        slider.setValue1()
                                    }
                                }

                            }
                            SToolButton2{
                                id:play
                                z:3
                                imgSrc: "qrc:/imgs/ico/play.png"
                                btnName: ""
                                width: 24
                                height: 24
                                onClicked: {
                                    if (mvid.isOpened()){
                                        mvid.play_pause()
                                        if(mvid.isPlaying()){
                                            imgSrc = "qrc:/imgs/ico/pause.png"
                                        }
                                        else{
                                            imgSrc = "qrc:/imgs/ico/play.png"
                                        }
                                    }
                                    else{
                                        dia.showInfo("请先打开视频！")
                                    }
                                }
                            }
                            SToolButton2{
                                id:forward
                                z:3
                                imgSrc: "qrc:/imgs/ico/forward.png"
                                btnName: ""
                                width: 24
                                height: 24
                                onClicked: {
                                    if (slider.value1<slider.value2){
                                        slider.value1+=1
                                        slider.setValue1()
                                    }
                                }
                            }
                        }// end buttons row

                    } //end column

            } // end player bar

            // camera stauts bar
            Rectangle{
                id: video_status_bar
                z:3
                width: parent.width
                height: 24
                color:"#68217a"
                anchors.bottom: parent.bottom

                Row{
                    spacing: 30
                    padding:10
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        id: video_fps_text
                        z:3
                        text: "视频帧率: 未打开"
                        color: "#ffffff"//"#3c3c3c"
                    }

                }//end row

                Text {
                    id: video_statusbar_zoom_label
                    z:4
                    anchors.verticalCenter: parent.verticalCenter
                    x:camera_status_bar.width-80
                    text: "缩放:100% "
                    color: "#ffffff"//"#3c3c3c"
                }

            }// end status bar

        }// end page video widget

    }// end swipe  centerWidget

    ZoomRect{
        id:zoom_label
        anchors.horizontalCenter:centerWidget.horizontalCenter
        height: 36
        y:centerWidget.y+50
        visible: false
        z:3
    }

    MouseArea{
        id: mouseArea_zoom
        x:centerWidget.x+15
        y:centerWidget.y+15
        width:centerWidget.width-30
        height: camera_widget_bg.height-30
        z:4
        enabled: true

        drag.target: camera_img
        drag.axis: Drag.XAndYAxis
        drag.minimumX: 20 - drag.target.width
        drag.maximumX: centerWidget.width - 20
        drag.minimumY: 20 - drag.target.height
        drag.maximumY: centerWidget.height - 20
        propagateComposedEvents: true
        onWheel: function (wheel){
            if(wheel.modifiers & Qt.ControlModifier){
                var a = wheel.angleDelta.y
                var m;
                if(centerWidget.currentIndex===0){
                    m = camera_img.scale
                }
                else{
                    m = video_img.scale
                }

                if (a>0){
                   m+=0.1
                   m = m>4? 4:m
                }
                else{
                    m-=0.1
                    m = m<0.2? 0.2:m
                }

                zoom_label.show()
                if(centerWidget.currentIndex===0){
                    if(mcap.isOpened()){
                        camera_img.scale=m
                        zoom_label.setValue(m)
                    }
                }
                else{
                    if(video_img.visible){
                        video_img.scale=m
                        zoom_label.setValue(m)
                    }
                }
                zoom_label.delay_hide(3000)

            }
        }
        Connections{
            target: centerWidget
            function onCurrentIndexChanged(){
                if(centerWidget.currentIndex===1 && video_player.checked){
                    mouseArea_zoom.height=camera_widget_bg.height-30-playerbar.height-20
                }
                else{
                    mouseArea_zoom.height=camera_widget_bg.height-30
                }
                switch (centerWidget.currentIndex){
                    case 0:
                        mouseArea_zoom.drag.target=camera_img
                        break
                    case 1:
                        mouseArea_zoom.drag.target=video_img
                        break
                    default:
                        break
                }
            }
        }
        Connections{
            target:video_player
            function onCheckedChanged(){
                if(centerWidget.currentIndex===1 && video_player.checked){
                    mouseArea_zoom.height=camera_widget_bg.height-30-playerbar.height-20
                }
                else{
                    mouseArea_zoom.height=camera_widget_bg.height-30
                }
            }
        }
    } // end mouse area

    MouseArea{
        id: mouseArea_select
        x:centerWidget.x
        y:centerWidget.y
        width:centerWidget.width
        height: camera_widget_bg.height
        z:4
        enabled: measurement_select.checked
        property double x0: 0
        property double y0: 0
        onPressed: {
            x0 = mouseX
            y0 = mouseY
        }

        onPositionChanged: {
            var w,h
            if(measurement_select.checked){
                w = mouseX-x0
                h = mouseY-y0
                s4i.visible = true
                if (w>0){
                    s4i.width = w
                    s4i.x = x0+centerWidget.x
                }
                else{
                    s4i.width = -w
                    s4i.x = mouseX+centerWidget.x
                }

                if (h>=0){
                    s4i.height = h
                    s4i.y = y0+centerWidget.y
                }
                else{
                    s4i.height = -h
                    s4i.y = mouseY+centerWidget.y
                }
            }
        } //end onPositionChanged
    } // end mouse area

    MouseArea{
        id: mouseArea_select_analysis
        x:centerWidget.x
        y:centerWidget.y
        width:centerWidget.width
        height: camera_widget_bg.height
        z:4
        hoverEnabled: true
        enabled: pmb0100_para_window.select
        property double x0: 0
        property double y0: 0
        property bool draw_flag: false
        property bool size_flag: false
        property real sizeMethod: 0
        onPressed: {
            x0 = mouseX
            y0 = mouseY
            if(cursorShape==Qt.ArrowCursor){
                draw_flag=true
            }
            else{
                size_flag=true
            }
        }
        onReleased: {
            size_flag=false
            draw_flag=false
        }

        onPositionChanged: {
            var dx,dy,x,y;
            if(draw_flag){
                var w,h
                if(pmb0100_para_window.select){
                    w = mouseX-x0
                    h = mouseY-y0
                    s4a.visible = true
                    if (w>0){
                        s4a.width = w
                        s4a.x = x0+centerWidget.x
                    }
                    else{
                        s4a.width = -w
                        s4a.x = mouseX+centerWidget.x
                    }

                    if (h>=0){
                        s4a.height = h
                        s4a.y = y0+centerWidget.y
                    }
                    else{
                        s4a.height = -h
                        s4a.y = mouseY+centerWidget.y
                    }
                    s4a.setScale()
                }
            }
            else if(size_flag){
                dx = mouseX-x0
                dy = mouseY-y0
                x0=mouseX
                y0=mouseY
                //中，左，右，上，下，左上，右上，左下，右下
                switch (sizeMethod){
                    case 0:
                        s4a.x+=dx
                        s4a.y+=dy
                        break
                    case 1:
                        s4a.x+=dx
                        s4a.width-=dx
                        break
                    case 2:
                        s4a.width+=dx
                        break
                    case 3:
                        s4a.y+=dy
                        s4a.height-=dy
                        break
                    case 4:
                        s4a.height+=dy
                        break
                    case 5:
                        s4a.x+=dx
                        s4a.width-=dx
                        s4a.y+=dy
                        s4a.height-=dy
                        break
                    case 6:
                        s4a.width+=dx
                        s4a.y+=dy
                        s4a.height-=dy
                        break
                    case 7:
                        s4a.x+=dx
                        s4a.width-=dx
                        s4a.height+=dy
                        break
                    case 8:
                        s4a.height+=dy
                        s4a.width+=dx
                        break
                }//end switch
                s4a.setScale()
            }
            else{
                x = mouseX+centerWidget.x
                y = mouseY+centerWidget.y
                //4个点，左上，右上，左下，右下，a,b,c,d
                var ax=s4a.x
                var ay=s4a.y
                var bx=s4a.x+s4a.width
                var by=s4a.y
                var cx=s4a.x
                var cy=s4a.y+s4a.height
                dx=s4a.x+s4a.width
                dy=s4a.y+s4a.height
                //中心
                var ox = s4a.x+s4a.width/2
                var oy = s4a.y+s4a.height/2
                var p=5;//边界宽度

                if(x>ax+p && x<bx-p && y>ay+p && y<cy-p){
                    //内
                    cursorShape=Qt.OpenHandCursor
                    sizeMethod=0
                }
                else if(x<ax+p && x>ax-p && y>ay+p && y<cy-p){
                    //左
                    cursorShape=Qt.SizeHorCursor
                    sizeMethod=1
                }
                else if(x>bx-p && x<bx+p && y>ay+p && y<cy-p){
                    //右
                    cursorShape=Qt.SizeHorCursor
                    sizeMethod=2
                }
                else if(y>ay-p &&y<ay+p && x>ax+p && x<bx-p){
                    //上
                    cursorShape=Qt.SizeVerCursor
                    sizeMethod=3
                }
                else if(y>cy-p && y<cy+p && x>ax+p && x<bx-p){
                    //下
                    cursorShape=Qt.SizeVerCursor
                    sizeMethod=4
                }
                else if(x>ax-p &&x<ax+p && y<ay+p && y>ay-p){
                    //左上
                    cursorShape=Qt.SizeFDiagCursor
                    sizeMethod=5
                }
                else if(x>bx-p && x<bx+p && y<by+p && y>by-p){
                    //右上
                    cursorShape=Qt.SizeBDiagCursor
                    sizeMethod=6
                }
                else if(x>cx-p && x<cx+p && y<cy+p && y>cy-p){
                    //左下
                    cursorShape=Qt.SizeBDiagCursor
                    sizeMethod=7
                }
                else if(x>dx-p &&x<dx+p && y<dy+p && y>dy-p){
                    //右下
                    cursorShape=Qt.SizeFDiagCursor
                    sizeMethod=8
                }
                else{
                    cursorShape=Qt.ArrowCursor
                }

            }
        } //end onPositionChanged
    } // end mouse area

    SelectScale4Image{
        id:s4i
        y:centerWidget.y
        visible: false
    }

    SelectScale4Analysis{
        id:s4a
        y:centerWidget.y
        visible: false
    }

    // save picture dialog
    FileDialog{
        id: fileSave_dialog
        title: "保存图片"
        currentFolder: folder_recording.lastSaveFolder
        fileMode:FileDialog.SaveFile
        nameFilters: ["png (*.png)"]
        onAccepted: {
            folder_recording.lastSaveFolder = currentFolder
            var ret = mcap.savePhoto(currentFile)
            if(ret){
                var s = `图片已保存 ${currentFile}`
                camera_saveinfo.camera_saveinfoShow(s)
            }
        }
        onRejected: { }
        Component.onCompleted: visible = false
    }// save fileDialog end


    // Measurement item
    MeasureScale{
        id : mscale
        x:toolbar.x
        y:centerWidget.y
        z:4
        width: centerWidget.width
        height: camera_widget_bg.height
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
        z:101
        anchors.centerIn: parent
        radius: 8
        visible: false
        width:260
        height: 360
    }

    // camera settings dialog
    CameraSettingsDialog{
        id:camera_settings_dialog
        anchors.centerIn: parent
    }

    CameraMoreSettingsWindow{
        id : camera_settings_widnow
    }

    // analysis para dialog
    TRecPara{
        id : pmb0100_para_window
    }

    // data process and figure dialog
    DataProcessPara{
        id:data_process_firgure
    }

    StrobPara{
        id:stro_para_window
    }

    //data table window animation
    ParallelAnimation{
        id: animation_show_table
        NumberAnimation{
            target: data_table
            properties: "x"
            from:data_table.x
            to: 0
            duration: 250;
            easing.type: Easing.Linear
        }
        NumberAnimation{
            target: data_table
            properties: "opacity"
            from: 0.2
            to: 1
            duration: 250;
            easing.type: Easing.Linear
        }
        onStarted: data_table.visible=true
    }
    ParallelAnimation{
        id: animation_hide_table
        NumberAnimation{
            target: data_table
            properties: "x"
            from:data_table.x
            to: -data_table.width
            duration: 250;
            easing.type: Easing.Linear
        }
        NumberAnimation{
            target: data_table
            properties: "opacity"
            from: 1
            to: 0.2
            duration: 250;
            easing.type: Easing.Linear
        }
        onFinished: data_table.visible=false
    }



    // -------------------- setting ------------------------
    Settings{
        id:global_color
        fileName: "Config.ini"
        category: "global_color"
        property string primary: "#555555"//"#33a3dc"
        property string ancent: "lightgray"
    }

    Settings{
        id:folder_recording
        fileName: "Config.ini"
        category: "folder recording"
        property string lastSaveFolder: ""
        property string recordPath: ""
        property string lastOPenedFolder:""
        property string photoFolder:""
    }

    function backDefaultGlobalSettings(){
        global_color.primary = "#505050"
        global_color.ancent = "lightgray"
    }

    // ----------------------end setting ---------------------


}// end window
