import QtQuick
import QtQuick.Controls

Rectangle {
    id:devs
    width:320
    height: 480
    color: Qt.rgba(1,1,1,0.8)
    property int padding: 20

    Component {
         id: contactDelegate
         Item {
             width:devs.width-devs.padding*2
             height: 40
             Column {
                 padding:5
                 Text { text: '<b>设备:</b> ' + description;color:"#101010" }
                 Text { text: '<b>型号:</b> ' + systemType;color:"#202020" }
             }
         }
     }//end Component

        ListView{
            id:devlist
            width:devs.width-devs.padding*2
            height: devs.height-devs.padding*2
            x:devs.padding
            y:devs.padding
            delegate:contactDelegate
            model: ListModel{
                id:md
                ListElement{
                    name:"dev1_name"
                    description:"液体表面张力实验仪"
                    systemType:"ZKY-PMC0101"
                }
                ListElement{
                    name:"dev2_name"
                    description:"数据采集器"
                    systemType:"ZKY-BD0005"
                }
            }
            focus:true
            highlight:Rectangle{
                color:"skyblue"
                radius: 3
            }
            MouseArea{
                anchors.fill: parent
                onClicked: devlist.currentIndex=devlist.indexAt(mouseX,mouseY)
            }

        }// end list view

        Row{
            spacing: 12
            padding: 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            Button{
                id:confirm
                text:"发送"
                onClicked: {
                    devs.visible=false
                    var s = devlist.model.get(devlist.currentIndex).description
                    dia.showInfo(`${s}打开成功!`)
                }
            }
            Button{
                id:cancel
                text:"取消"
                onClicked: devs.visible=false
            }
        }

}
