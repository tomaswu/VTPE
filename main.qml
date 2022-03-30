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
        height: 60
        anchors.top: parent.top
        Row{
            spacing: 8
            padding: 5
            anchors.verticalCenter: parent.verticalCenter
            Button{
                id:openDrawer
                text: "open"
                onClicked: console.log(drawer.x)
            }
        }// end row

        Drawer{
            id:drawer
            width: 300
            height: parent.height-toolbar.height
            y:toolbar.height
            x:-300
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
            y:toolbar.height
            x:drawer.x+300
            width: parent.width-x
            height: drawer.height
            border.width: 1
            anchors.left:drawer.Right
            color:"skyblue"
        }
    }

}// end window
