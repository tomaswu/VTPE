import QtQuick 2.15

Item {
    // 目前暂时只支持在main中进行拖动选择，后期可以考虑增加一个自由变换的功能
    id: cs //cut_scale
    width:400
    height: 300
    property real row1 : 50
    property real row2 : 100
    property real col1 : 50
    property real col2 : 300

    Canvas{
        id: cvs
        antialiasing: true
        anchors.fill: parent
        onPaint:{
            var ctx = getContext("2d")
            ctx.clearRect(0,0,500,500)
            ctx.fillStyle = Qt.rgba(0,0,0,0.45)
            ctx.strokeStyle = "lightgreen"
            ctx.lineWidth = 1
            ctx.beginPath()
            ctx.rect(0,0,cs.col1,cs.height)
            ctx.rect(cs.col1,0,cs.col2-cs.col1,cs.row1)
            ctx.rect(cs.col1,cs.row2,cs.col2-cs.col1,cs.height-cs.row1)
            ctx.rect(cs.col2,0,cs.width-cs.col2,cs.height)
            ctx.fill()
        }

    }

    MouseArea{
        id:ma //mouse area
        anchors.fill: parent

        property double x0: 0
        property double y0: 0
        onPressed: {
            x0 = mouseX
            y0 = mouseY
        }

        onPositionChanged: {
            var w = mouseX-x0
            var h = mouseY-y0
            if (w>0){
                cs.col1 = x0
                cs.col2 = mouseX
            }
            else{
                cs.col1 = mouseX
                cs.col2 = x0
            }

            if (h>=0){
                cs.row1=y0
                cs.row2=mouseY
            }
            else{
                cs.row1=mouseY
                cs.row2=y0
            }
            cvs.requestPaint()
        }
    } // end mouse area


    Rectangle{
        id: top_rect
        width: (cs.col2-cs.col1)/3
        height: 4
        color:"yellow"
        radius: 2
        x:(cs.col1+cs.col2-width)/2
        y:cs.row1-height/2
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.SizeVerCursor
            property real v0: 0
            onPressed: {
                v0 = mouseY
            }

            onPositionChanged: {
                var tmp=mouseY-v0+cs.row1
                cs.row1 = tmp>cs.row2 ? cs.row2 : tmp
                cvs.requestPaint()
            }
        }
    }
    Rectangle{
        id: bottom_rect
        width: (cs.col2-cs.col1)/3
        height: 4
        color:"yellow"
        radius: 2
        x:(cs.col1+cs.col2-width)/2
        y:cs.row2-height/2
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.SizeVerCursor
            property real v0: 0
            onPressed: {
                v0 = mouseY
            }

            onPositionChanged: {
                var tmp=mouseY-v0+cs.row2
                cs.row2 = tmp<cs.row1 ? cs.row1 : tmp
                cvs.requestPaint()
            }
        }
    }
    Rectangle{
        id: left_rect
        width: 4
        height: (cs.row2-cs.row1)/3
        color:"yellow"
        radius: 2
        x:cs.col1-width/2
        y:(cs.row1+cs.row2-height)/2
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.SizeHorCursor
            property real v0: 0
            onPressed: {
                v0 = mouseX
            }

            onPositionChanged: {
                var tmp=mouseX-v0+cs.col1
                cs.col1 = tmp>cs.col2 ? cs.col2 : tmp
                cvs.requestPaint()
            }
        }
    }
    Rectangle{
        id: right_rect
        width: 4
        height: (cs.row2-cs.row1)/3
        color:"yellow"
        radius: 2
        x:cs.col2-width/2
        y:(cs.row1+cs.row2-height)/2
        MouseArea{
            anchors.fill: parent
            cursorShape: Qt.SizeHorCursor
            property real v0: 0
            onPressed: {
                v0 = mouseX
            }

            onPositionChanged: {
                var tmp=mouseX-v0+cs.col2
                cs.col2 = tmp<cs.col1 ? cs.col1 : tmp
                cvs.requestPaint()
            }
        }
    }


}
