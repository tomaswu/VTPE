import QtQuick
import QtQuick.Controls

Item {
    id:root
    width:120
    height: 40
    Rectangle{
        id:bg
        height: parent.height
        width:70
        color:Qt.rgba(1,1,1,1)
        radius: 3
    }
    Text {
        id: txt
        text: qsTr("150%")
        color:Qt.rgba(0.1,0.1,0.1,0.8)
        anchors.verticalCenter: parent.verticalCenter
        x:parent.width/12
        font.pixelSize: 20
    }

    Button{
        id:btn
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        font.pointSize: 10
        width: 50
        height: parent.height
        text: "重 置"
        onClicked: {
            if(centerWidget.currentIndex===0){

            }
        }
    }

}
