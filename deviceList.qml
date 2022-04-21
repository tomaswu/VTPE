import QtQuick
import QtQuick.Controls

Rectangle {
    id:devs
    width:320
    height: 480
    color: Qt.rgba(1,1,1,0.8)
    property int padding: 20
    Row{
        id:port_row
        spacing: 16
        anchors.horizontalCenter: parent.horizontalCenter
        x:devs.padding
        y:devs.padding/2
        Text{text:"端口:";font.pixelSize: 12;anchors.verticalCenter: parent.verticalCenter}
        ComboBox{
            id:port_index
        }
    }// end port row

    Component {
         id: contactDelegate
         Item {
             width:devs.width-devs.padding*2
             height: 40
             Column {
                 padding:5
                 Text { text: description ;color:"#101010";font.pixelSize: 14 }
                 Text { text: systemType ;color:"#202020";font.pixelSize: 10 }
             }
         }
     }//end Component

        ListView{
            id:devlist
            width:devs.width-devs.padding*2
            height: devs.height-devs.padding*2
            x:devs.padding
            y:devs.padding+port_row.height
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
                onClicked: {
                    devlist.currentIndex=devlist.indexAt(mouseX,mouseY)
                }
            }
            onCurrentIndexChanged: {
                var m;
                switch (devlist.currentIndex){
                    case 0:
                        m = pmc0100_com.enumDevice()
                        port_index.model=m
                        break
                    case 1:
                        port_index.model = "" //暂时为空
                        break
                    default:
                        port_index.model = ""
                        break
                }
            }

        }// end list view

        Row{
            spacing: 12
            padding: 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            Button{
                id:confirm
                text:"打开"
                onClicked: {
                    devs.visible=false
                    var s = devlist.model.get(devlist.currentIndex).description
                    pmc0100_com.start(0);
                }
            }
            Button{
                id:cancel
                text:"取消"
                onClicked: devs.visible=false
            }
        }

}
