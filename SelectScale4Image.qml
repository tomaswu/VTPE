import QtQuick

Item {
    // 目前暂时只支持在main中进行拖动选择，后期可以考虑增加一个自由变换的功能
    id: select_scale
    width:400
    height: 300
    visible: false
    property int maxgray: 255
    property int mingray: 0
    property double averagegray: 0
    property string textColor: "red"
    onWidthChanged: autoPosition()
    onHeightChanged: autoPosition()
    onVisibleChanged: {
        if(visible){
            timer.start()
        }
        else{
            timer.stop()
        }
    }

    Rectangle{
        id:bg
        border.width:1
        border.color: "lightgreen"
        color: Qt.rgba(1,1,1,0)
        anchors.fill: parent
    }

    Rectangle{
        id:text_bg
        x:info.x
        y:info.y
        width:info.width
        height: info.height
        color: Qt.rgba(1,1,1,0.8)
    }

    Text {
        id: info
        color: select_scale.textColor
        text:`max: ${select_scale.maxgray} min: ${select_scale.mingray} average: ${select_scale.averagegray}`
    }


    Timer{
        id:timer
        interval: 100
        repeat: true
        onTriggered: {
            if(mcap.isOpened()){
                if(camera_img.paintedWidth>0){
                    var row1,row2,col1,col2,x0,y0
                    x0 = camera_img.width/2
                    y0 = camera_img.height/2
                    col1 = (select_scale.x-x0)/(camera_img.paintedWidth)
                    col2 = (select_scale.x+select_scale.width-x0)/(camera_img.paintedWidth)
                    row1 = (select_scale.y-toolbar.height-y0)/(camera_img.paintedHeight)
                    row2 = (select_scale.y-toolbar.height+select_scale.height-y0)/(camera_img.paintedHeight)
                    var r = mcap.calSelectScale(row1,row2,col1,col2)
                    parent.maxgray = r[0]
                    parent.mingray = r[1]
                    parent.averagegray = r[2].toFixed(2)
                }
            }
        }// end on triggered
    }// end timer

    function setValue(a,b,c){
        maxgray = a
        mingray = b
        averagegray = c
    }

    function autoPosition(){
        if (y+height+info.height>=parent.height-camera_status_bar.height){
            info.y = -info.height-2
        }
        else{
            info.y = height+2
        }

        if(x+width+info.width>=parent.width){
            info.x = -info.width+width
        }
        else{
            info.x = 0
        }

    }

}
