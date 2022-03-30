import QtQuick
import QtQuick.Controls 2.15

Window {
    width: 1024
    height: 720
    visible: true
    title: qsTr("Hello World")

    ToolBar{
        id:toolbar
        width:parent.width
        anchors.top: parent.top
        Button{
            id:openDrawer
            text: "open"
            onClicked: console.log(drawer.x)
        }

        Drawer{
            id:drawer
            width: 300
            height: parent.height-toolbar.height
            y:toolbar.height
            edge:Qt.LeftEdge
//            anchors.top : toolbar.bottom
            background: Rectangle{
                anchors.fill: parent
                color:"yellow"
                opacity: 0.5
            }
            onAvailableWidthChanged: console.log("hello")
        }// end drawer

        Rectangle{
            id : center_widget
            height: drawer.height/2
            width: parent.width
            y:toolbar.height
            anchors.left:drawer.Right
            color:"skyblue"
        }
    }

}// end window
