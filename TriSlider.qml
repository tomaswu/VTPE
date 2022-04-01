import QtQuick 2.15

Item{
        id:triSlider
        property real from: 0
        property real to: 100
        property real value0: 0
        property real value1: 50
        property real value2: 100
        property real sliderHeight: 18
        property real sliderWidth: 6
        property string lineColor1: "gray"
        property string lineColor2: "skyblue"
        property string scolor0: "green"
        property string scolor1: "blue"
        property string scolor2: "red"
        width: 60
        height: 20

        Item{
            id:lines
            width: parent.width-triSlider.sliderWidth
            height: parent.height
            property real pwidth: width-head.width
            x:triSlider.sliderWidth/2
            Rectangle{
                id:head
                x:0
                y:(parent.height-height)/2
                width: 6
                height: 6
                radius: 3
                color:triSlider.lineColor1
            }
            Rectangle{
                id:line0
                x:head.width/2
                y:head.y
                width: parent.pwidth*value0/(to-from)
                height: 6
                color:head.color
            }
            Rectangle{
                id:line1
                x:line0.x+line0.width
                y:head.y
                width: parent.pwidth*Math.abs(value2-value0)/(to-from)
                height: 6
                color:triSlider.lineColor2
            }
            Rectangle{
                id:line2
                x:line1.x+line1.width
                y:head.y
                width: parent.pwidth*(to-value2)/(to-from)
                height: 6
                color:head.color
            }
            Rectangle{
                id:tail
                x:line2.x+line2.width-width/2
                y:head.y
                width: 6
                height: 6
                radius: 3
                color:head.color
            }
        }
        Rectangle{
            id:s0
            x:lines.pwidth*value0/(to-from)-width/2+head.width
            y:(parent.height-height)/2
            width: parent.sliderWidth
            height: parent.sliderHeight
            radius: 2
            color:triSlider.scolor0
            MouseArea{
                anchors.fill: parent
                onMouseXChanged: {
                    var tmp=s0.x+mouseX
                    if(tmp>=0 && tmp<=s1.x){
                        triSlider.value0=Math.round((to-from)*(tmp-head.width/2)/lines.pwidth)
                    }
                }
            }
        }// end s0
        Rectangle{
            id:s1
            x:lines.pwidth*value1/(to-from)-width/2+head.width
            y:(parent.height-height)/2
            width: parent.sliderWidth
            height: parent.sliderHeight
            radius: 2
            color:triSlider.scolor1
            MouseArea{
                anchors.fill: parent
                onMouseXChanged: {
                    var tmp=s1.x+mouseX
                    if(tmp>=s0.x && tmp<=s2.x){
                        triSlider.value1=Math.round((to-from)*tmp/triSlider.width)
                    }
                }
            }
        }// end s1

        Rectangle{
            id:s2
            x:lines.pwidth*value2/(to-from)-width/2+head.width
            y:(parent.height-height)/2
            width: parent.sliderWidth
            height: parent.sliderHeight
            radius: 2
            color:triSlider.scolor2
            MouseArea{
                anchors.fill: parent
                onMouseXChanged: {
                    var tmp=s2.x+mouseX
                    if(tmp>=s1.x && tmp<=lines.pwidth+head.width/2){
                        triSlider.value2=Math.round((to-from)*(tmp-head.width/2)/lines.pwidth)
                    }
                }
            }
        }// end s2

}

