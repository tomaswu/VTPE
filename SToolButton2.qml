//另一个

import QtQuick


Rectangle{
    property string imgSrc: ""
    property string btnName: "button"
    property string textColor: "black"
    property bool hovered: false
    property bool checked: false
    property bool checkable: false
    property bool longPressedRepeat: false
    signal clicked
    id:background
    width: 48
    height: 48
    radius:width/12
    color:Qt.rgba(1,1,1,0)
    border.color:Qt.rgba(0,0,0,0.2)
    border.width: 0
    MaskImage{
        width:parent.btnName ? parent.width*0.67:parent.width
        height: width
        source: parent.imgSrc
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
    }
    Text {
        id: text
        font.pixelSize: parent.width/4
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        text: parent.btnName
        color: parent.textColor
    }

    MouseArea{
        id:ma
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            if (!parent.checked){
                background.color = Qt.rgba(0.75,0.75,0.75,0.4)
                background.border.width=1
                if(!pressedButtons){
                    parent.hovered = true
                }
            }// end if
        }

        onExited: {
            if (!parent.checked){
                background.color = Qt.rgba(1,1,1,0)
                background.border.width=0
                parent.hovered = false
            }// end if

        }
        onPressed: {
            background.color = Qt.rgba(0.5,0.5,0.5,0.6)
        }
        onReleased: {
            if (mouseX>0 && mouseX<parent.width && mouseY>0 && mouseY<parent.height){
                if(!parent.checkable || parent.checked){
                    background.color = Qt.rgba(0.75,0.75,0.75,0.6)
                }
            }
            timer.stop()
        }
        onClicked: {
            if (mouseX>0 && mouseX<parent.width && mouseY>0 && mouseY<parent.height)
                if (!parent.checkable){

                    parent.clicked()
                }
                else
                {
                    parent.checked=!parent.checked
                }
            } // end if mouse
        onPressAndHold: timer.start()
    }//end mousearea

    Timer{
        id:timer
        interval: 125
        onTriggered: parent.clicked()
        triggeredOnStart: true
        repeat: true
    }
}


