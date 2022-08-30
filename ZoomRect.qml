import QtQuick
import QtQuick.Controls

Item {
    id:root
    width:120
    height: 40
    Rectangle{
        id:lbg
        height: parent.height
        width:30
        color:Qt.rgba(1,1,1,1)
        radius: 5
    }

    Rectangle{
        id:rbg
        height: parent.height
        width:30
        color:btn.color
        radius: 5
        x:btn.x+btn.width-20
    }

    Rectangle{
        id:bg
        x:lbg.x+15
        height: parent.height
        width:70
        color:Qt.rgba(1,1,1,1)

    }
    Text {
        id: txt
        text: qsTr("150%")
        color:Qt.rgba(0.1,0.1,0.1,0.8)
        anchors.verticalCenter: parent.verticalCenter
        x:parent.width/12
        font.pixelSize: 20
    }

    Rectangle{
        id:btn
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: 50
        height: parent.height
        color: "#008acc"

        Text {
            id: name
            anchors.verticalCenter: parent.verticalCenter
            x:16
            text: "重 置"
            color:"white"
            font.pointSize: 10
        }

        MouseArea{
            anchors.fill: btn
            hoverEnabled: true
            onClicked: {
//                if(centerWidget.currentIndex===0){
//                    camera_img.scale=1
//                    camera_img.x=(centerWidget.width-camera_img.timgWidth)/2
//                    camera_img.y=(centerWidget.height-camera_img.timgHeight)/2
//                }
//                else{
//                    video_img.scale=1
//                    video_img.x=(centerWidget.width-video_img.timgWidth)/2
//                    video_img.y=(centerWidget.height-video_img.timgHeight)/2
//                }
//                txt.text="100%"
                adjustScreen()
            }
            onEntered: {
                btn.color = "#003399"
            }


            onExited: {
                btn.color = "#008acc"
            }
        }
    }

    NumberAnimation {
        id:label_hide
        target: root
        property: "opacity"
        duration: 120
        from:1
        to:0
        easing.type: Easing.InOutQuad
    }

    Timer{
        id:timer
    }

    function show(){
        root.visible=true
        root.opacity=1
    }

    function _hide(){
        if(!root.focus)label_hide.start()
    }

    function delay_hide(delayTime) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(_hide);
        timer.start();
    }

    function setValue(d){
        var m=d*100
        var s=`${m.toFixed()}%`
        txt.text=s
        if(centerWidget.currentIndex===0){
            camera_statusbar_zoom_label.text="缩放:"+s
        }
        else{
            video_statusbar_zoom_label.text="缩放:"+s
        }
    }

    function adjustScreen(){
        var tmp;
        var scl = 1.0;
        var w = centerWidget.width
        var h = centerWidget.height-camera_status_bar.height
        var tw = camera_img.timgWidth
        var th = camera_img.timgHeight
        var a = w/tw
        var b = h/th
        if(centerWidget.currentIndex===0){
            if(w>=tw&&h>=th){
                scl = a>b? b:a
            }
            else if(w>=tw&&h<=th){
                scl = b
            }
            else if(w<=tw && h>=th){
                scl = a
            }
            else{
                scl = a>b? b:a
            }
            tmp = scl.toFixed(1)
            scl = tmp>scl? tmp-0.1:tmp
            camera_img.scale = scl
            setValue(scl);
            camera_img.x=(w-camera_img.timgWidth)/2
            camera_img.y=(h-camera_img.timgHeight)/2
        }
        else{
            var table_shift = (data_table.width+data_table.x)
            tw = video_img.timgWidth-table_shift
            th = video_img.timgHeight
            a = w/tw
            b = h/th
            if(w>=tw&&h>=th){
                scl = a>b? b:a
            }
            else if(w>=tw&&h<=th){
                scl = b
            }
            else if(w<=tw && h>=th){
                scl = a
            }
            else{
                scl = a>b? b:a
            }
            tmp = scl.toFixed(1)
            scl = tmp>scl? tmp-0.1:tmp
            video_img.scale = scl
            setValue(scl);
            video_img.x=(w+table_shift-video_img.timgWidth)/2
            video_img.y=(h-video_img.timgHeight)/2
        }
    }

}

