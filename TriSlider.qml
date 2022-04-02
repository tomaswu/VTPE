import QtQuick 2.15
import QtQuick.Controls 2.15

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
            onXChanged: triSlider.raise(0)
            MouseArea{
                anchors.fill: parent
                onMouseXChanged: {
                    var tmp=s0.x+mouseX
                    if(tmp>=0 && tmp<=s1.x)triSlider.value0=Math.round((to-from)*(tmp-head.width/2)/lines.pwidth)
                    if(tmp<0)triSlider.value0=triSlider.from
                    if(tmp>s1.x)triSlider.value0=triSlider.value1
                    label.showOn(0)
                    label.focus=false
                }
                onReleased: {
                    label.delay_hide(800)
                }
                onDoubleClicked: {
                    label.showOn(0)
                    label.focus=true
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
            onXChanged: triSlider.raise(1)
            MouseArea{
                anchors.fill: parent
                onMouseXChanged: {
                    var tmp=s1.x+mouseX
                    if(tmp>=s0.x && tmp<=s2.x)triSlider.value1=Math.round((to-from)*tmp/triSlider.width)
                    if (tmp<s0.x)triSlider.value1=triSlider.value0
                    if(tmp>s2.x)triSlider.value1=triSlider.value2
                    label.showOn(1)
                    label.focus=false
                }
                onReleased: {
                    label.delay_hide(800)
                }
                onDoubleClicked: {
                    label.showOn(1)
                    label.focus=true
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
            onXChanged: triSlider.raise(2)
            MouseArea{
                anchors.fill: parent
                onMouseXChanged: {
                    var tmp=s2.x+mouseX
                    if(tmp>=s1.x && tmp<=lines.pwidth+head.width/2)triSlider.value2=Math.round((to-from)*(tmp-head.width/2)/lines.pwidth)
                    if(tmp>lines.pwidth+head.width/2)triSlider.value2=triSlider.to
                    if(tmp<s1.x)triSlider.value2=triSlider.value1
                    label.showOn(2)
                    label.focus=false
                }
                onReleased: {
                    label.delay_hide(800)
                }
                onDoubleClicked: {
                    label.showOn(2)
                    label.focus=true
                }
            }
        }// end s2



        TextField{
            id:label
            width:35
            height: 20
            opacity: 0
            validator: IntValidator{bottom:triSlider.from;top:triSlider.to}
            y:s0.y-3-height
            property int hand: 0
            Keys.onEscapePressed: {
                focus=false
                label.delay_hide(200)
            }
            Keys.onReturnPressed: acceptLabelValue()
            Keys.onEnterPressed: acceptLabelValue()

            function acceptLabelValue(){
                var val=parseInt(label.text)
                switch (hand){
                case 0:
                    if (val<0)val=0
                    if (val>triSlider.value1)val=triSlider.value1
                    triSlider.value0=val
                    break
                case 1:
                    if (val<triSlider.value0)val=triSlider.value0
                    if (val>triSlider.value2)val=triSlider.value2
                    triSlider.value1=val
                    break
                case 2:
                    if (val<triSlider.value1)val=triSlider.value1
                    if (val>triSlider.to)val=triSlider.to
                    triSlider.value2=val
                    break
                }//end switch
                label.showOn(label.hand)
            }

            NumberAnimation {
                id:label_hide
                target: label
                property: "opacity"
                duration: 200
                from:1
                to:0
                easing.type: Easing.InOutQuad
            }

            Timer{
                id:timer
            }

            function _hide(){
                if(!label.focus)label_hide.start()
            }

            function delay_hide(delayTime) {
                timer.interval = delayTime;
                timer.repeat = false;
                timer.triggered.connect(_hide);
                timer.start();
            }

            function showOn(index){
                label.hand=index
                var x;
                var s;
                switch (index){
                case 0:
                    x=s0.x
                    s=triSlider.value0
                    break
                case 1:
                    x=s1.x
                    s=triSlider.value1
                    break
                case 2:
                    x=s2.x
                    s=triSlider.value2
                    break
                }
                label.x=x
                label.text=s
                label.opacity=1
            }
        }// end label text

        function raise(index){
            switch (index){
            case 0:
                s0.z=102
                s1.z=101
                s2.z=101
                break
            case 1:
                s0.z=101
                s1.z=102
                s2.z=101
                break
            case 2:
                s0.z=101
                s1.z=101
                s2.z=102
                break
            }//end switch
        }

}

