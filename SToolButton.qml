import QtQuick

Rectangle{
    property string imgSrc: ""
    property string btnName: "button"
    property string textColor: "black"
    property bool hovered: false
    signal clicked;
    id:background
    width: 48
    height: 48
    radius:width/12
    color:Qt.rgba(1,1,1,0)
    border.color:Qt.rgba(0,0,0,0.2)
    border.width: 0
    Image{
        width:parent.btnName ? parent.width*0.67:parent.width
        height: width
        source: parent.imgSrc
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        fillMode: Image.PreserveAspectFit
        mipmap:true
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
            background.color = Qt.rgba(0.75,0.75,0.75,0.4)
            background.border.width=1
            if(!pressedButtons){
                parent.hovered = true
            }
        }
        onExited: {
            background.color = Qt.rgba(1,1,1,0)
            background.border.width=0
            parent.hovered = false

        }
        onPressed: {
            background.color = Qt.rgba(0.5,0.5,0.5,0.6)
        }
        onReleased: {
            if (mouseX>0 && mouseX<parent.width && mouseY>0 && mouseY<parent.height){
                background.color = Qt.rgba(0.75,0.75,0.75,0.6)
            }
        }
        onClicked: if (mouseX>0 && mouseX<parent.width && mouseY>0 && mouseY<parent.height)parent.clicked()

    }


}


