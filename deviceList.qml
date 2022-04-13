import QtQuick

Rectangle {
    id:devs
    width:360
    height: 480
    color: Qt.rgba(1,1,1,0.8)

    Component {
         id: contactDelegate
         Item {
             width:devs.width-10
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
            width:devs.width-10
            height: devs.height
            x:5
            delegate:contactDelegate
            model: ListModel{
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

}
