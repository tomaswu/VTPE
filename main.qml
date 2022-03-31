import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    width: 1024
    height: 720
    visible: true
    title: qsTr("Hello World")
    color:"lightgray"

    ToolBar{
        id:toolbar
        width:parent.width-16
        height: 120
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        background: Rectangle{
            anchors.fill: parent;
            color:"white"
            radius: 10
        }

        Row{
            height: parent.height
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            padding:2
            spacing: 5
            GridLayout{
                height: parent.height
                columns: 2
                rows: 3
                SToolButton{
                    id:btnOpen
                    imgSrc: "qrc:/imgs/ico/camera2.png"
                    btnName: "拍照"
                    width: 64
                    height: 64
                    onClicked: console.log("time up")
                    Layout.rowSpan: 2
                }

                SToolButton{
                    id:btnOpen2
                    imgSrc: "qrc:/imgs/ico/setting1.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onClicked: console.log("time up")
                }
                SToolButton{
                    id:btnOpen3
                    imgSrc: "qrc:/imgs/ico/setting2.png"
                    btnName: ""
                    width: 24
                    height: 24
                    onClicked: console.log("time up")
                }
                Text{
                    text: "相机功能"
                    Layout.row: 3
                    Layout.column: 0
                    Layout.columnSpan: 2
                    Layout.alignment: Qt.AlignHCenter
                }

            }// end gird
            Rectangle{
                color:Qt.rgba(0,0,0,0.2)
                width: 1
                height: parent.height-parent.padding*2
            }

         } //end column
    }// end toolbar

}// end window
