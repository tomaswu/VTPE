import QtQuick
import QtQuick.Controls

Item {
    id : measureScale
    property int markerType: 2
    property double iwidth: 80
    property string color:"#d71345"
    property bool caliFlag: true
    property double ratio: 1
    onHeightChanged: cvs.requestPaint()
    onWidthChanged: cvs.requestPaint()
    onCaliFlagChanged: {
        cvs.requestPaint()
        if(!caliFlag){
            cvs.x0 = -1
            cvs.y0 = -1
        }
    }
    onMarkerTypeChanged: cvs.requestPaint()

    Canvas {
        id: cvs
        property double x0 : 0
        property double y0 : 0
        property double pixLength: 0
        antialiasing: true
        anchors.fill: parent
        onPaint:{
            var ctx = getContext("2d")
            ctx.clearRect(0,0,width,height)
            ctx.strokeStyle = parent.color
            ctx.fillStyle = parent.color
            ctx.lineWidth = 1
            var tooth_length=14
            switch (parent.markerType){
                case 0:{
                    ctx.beginPath()
                    ctx.moveTo(0,height/2)
                    ctx.lineTo(width,height/2)
                    ctx.moveTo(width/2,0)
                    ctx.lineTo(width/2,height)
                    for (var ix=0;ix<width/2; ix+=iwidth){
                        if (ix>0){
                            ctx.moveTo(ix+width/2,height/2)
                            ctx.lineTo(ix+width/2,height/2-tooth_length)
                            ctx.moveTo(-ix+width/2,height/2)
                            ctx.lineTo(-ix+width/2,height/2-tooth_length)
                        }
                        if (iwidth>=50){
                            var mini_width=iwidth/10
                            for (var mini_x = ix+mini_width; mini_x < ix+iwidth; mini_x+=mini_width){
                                ctx.moveTo(mini_x+width/2,height/2)
                                ctx.lineTo(mini_x+width/2,height/2-tooth_length/3)
                                ctx.moveTo(-mini_x+width/2,height/2)
                                ctx.lineTo(-mini_x+width/2,height/2-tooth_length/3)
                            }//end for mini_x
                        }// end if
                    }// end for ix
                    for (var iy=0; iy<height/2;iy+=iwidth){
                        if (iy>0){
                            ctx.moveTo(width/2,iy+height/2)
                            ctx.lineTo(width/2+tooth_length,iy+height/2)
                            ctx.moveTo(width/2,-iy+height/2)
                            ctx.lineTo(width/2+tooth_length,-iy+height/2)
                        }
                        if(iwidth>=50){
                            for (var mini_y = iy+mini_width; mini_y < iy+iwidth; mini_y+=mini_width){
                                ctx.moveTo(width/2,mini_y+height/2)
                                ctx.lineTo(width/2+tooth_length/3,mini_y+height/2)
                                ctx.moveTo(width/2,-mini_y+height/2)
                                ctx.lineTo(width/2+tooth_length/3,-mini_y+height/2)

                            }//end for mini y
                        }//end if
                    }//end for iy
                    ctx.closePath()
                    ctx.stroke()
                    break
                } //end case 0
                case 1:{
                    ctx.beginPath()
                    var r_max = Math.min(width,height)
                    for (var ir=iwidth; ir*2<r_max; ir+=iwidth){
                        ctx.ellipse(width/2-ir,height/2-ir,ir*2,ir*2)
                    }
                    ctx.moveTo(0,height/2)
                    ctx.lineTo(width,height/2)
                    ctx.moveTo(width/2,0)
                    ctx.lineTo(width/2,height)
                    ctx.stroke()
                    break
                }//end case 1
                case 2:{
                    ctx.beginPath()
                    for (ix=0;ix<=width; ix+=iwidth){
                        ctx.moveTo(ix,0)
                        ctx.lineTo(ix,height)
                    }// end for ix
                    for (iy=0;iy<=width; iy+=iwidth){
                        ctx.moveTo(0,iy)
                        ctx.lineTo(width,iy)
                    }// end for iy
                    ctx.stroke()
                    break
                }//end case 2
            }// end switch
            //画一下比例尺
            ctx.font = "18px sans-serif"
            ctx.fillRule=Qt.SolidPattern
            ctx.beginPath()
            ctx.moveTo(width*0.9-iwidth,height*0.9)
            ctx.lineTo(width*0.9,height*0.9)
            ctx.moveTo(width*0.9-iwidth,height*0.9)
            ctx.lineTo(width*0.9-iwidth,height*0.9-tooth_length)
            ctx.moveTo(width*0.9,height*0.9)
            ctx.lineTo(width*0.9,height*0.9-tooth_length)
            ctx.stroke()
            var tmp = Math.round(measureScale.ratio*iwidth)
            var ts = `${tmp} ${cali_unit.currentText}`
            ctx.text(ts,width*0.9-(iwidth+ts.length*9)/2,height*0.9-tooth_length*1.1)
            ctx.fill()

            //下面是定标
            if (caliFlag && x0 >=0 && y0 >= 0){
                ctx.beginPath()
                ctx.strokeStyle=parent.color
                var k;
                if(canvasMouseArea.mouseY-y0==0){
                    k=20000 // 模拟无穷大
                }
                else{
                    k=-(canvasMouseArea.mouseX-x0)/(canvasMouseArea.mouseY-y0)
                }
                var m = Math.sqrt(100/(1+k*k))
                ctx.moveTo(x0-m,y0-k*m)
                ctx.lineTo(x0+m,y0+k*m)
                ctx.moveTo(x0,y0)
                ctx.lineTo(canvasMouseArea.mouseX,canvasMouseArea.mouseY)
                ctx.moveTo(canvasMouseArea.mouseX-m,canvasMouseArea.mouseY-m*k)
                ctx.lineTo(canvasMouseArea.mouseX+m,canvasMouseArea.mouseY+m*k)
                ctx.stroke()
            }

        }// end paint

        MouseArea{
            id:canvasMouseArea
            anchors.fill: parent
            onPressed: {
                cvs.x0 = mouseX
                cvs.y0 = mouseY
            }
            onPositionChanged: cvs.requestPaint()
            onReleased: {
                if(caliFlag){
                    cvs.pixLength=Math.sqrt(Math.pow(cvs.x0-mouseX,2)+Math.pow(cvs.y0-mouseY,2))
                    tinput.text=""
                    apop.open()
                }//end if
            }
        }//end MouseArea
    }//end canvas

    Popup{
        id: apop
        modal: true
        anchors.centerIn: parent
        width:260
        height:100
        background: Rectangle{
            anchors.fill:parent
            radius: 5
            color:Qt.rgba(1,1,1,0.85)

        }//end bg
        Column{
            anchors.fill: parent
            spacing: 12
            padding:16

            Row{
                width:parent.width
                spacing: 12
                TextField{
                    id: tinput
                    width:160
                    placeholderText: "输入实际长度"
                    validator: DoubleValidator{bottom: 0;top: 5000.0}
                    Keys.onReturnPressed:{
                        btn_ok.click()
                    }
                }//end input

                ComboBox{
                    id:cali_unit
                    implicitWidth: 48
                    currentIndex: 4
                    valueRole:"name"
                    model: ListModel{
                        ListElement{name:"km"}
                        ListElement{name:"m"}
                        ListElement{name:"dm"}
                        ListElement{name:"cm"}
                        ListElement{name:"mm"}
                        ListElement{name:"um"}
                        ListElement{name:"nm"}
                    }
                }//end combox for unit
            }//end row

            Row{
                leftPadding: 30
                rightPadding: 30
                spacing: 8
                width:parent.width
                Button{
                    id: btn_ok
                    text: "确认"
                    onClicked: {
                        apop.close()
                        var s = parseFloat(tinput.text)
                        if(s>0)cali(s)
                        measureScale.caliFlag=false
                    }
                }
                Button{
                    id: btn_no
                    text: "取消"
                    onClicked: apop.close()
                }
            }// end row
        } // end Column

    }//end popup

    function cali(s){
        measureScale.ratio=s/cvs.pixLength
        var judge=1
        while (judge/measureScale.ratio<=50){
            if (judge==1){
                judge=5
            }
            else{
                judge+=5
            }
        } // end while
        measureScale.iwidth=judge/measureScale.ratio
        cvs.requestPaint()
    }

} //end item
