import QtQuick 2.15
import QtQuick.Controls 2.15

Window {
    width:320
    height: 180
    title:"频闪图参数设置"
    id:root
    property bool show_flag: false
    Rectangle{
        id:bg
        anchors.fill: parent
        color:"white"
    }

    Text {
        id: name1
        x:30
        y:20
        text: qsTr("开始帧数")
    }

   SpinBox{
       id:_start
       x:name1.x+name1.width+40
       editable: true
       anchors.verticalCenter: name1.verticalCenter
       from: 0
       to:1000
   }

   Text {
       id: name2
       x:name1.x
       y:name1.y+40
       text: qsTr("叠加数量")
   }

  SpinBox{
      id:_number
      x:name2.x+name2.width+40
      editable: true
      from: 1
      to:100
      anchors.verticalCenter: name2.verticalCenter
  }

  Text {
      id: name3
      x:name2.x
      y:name2.y+40
      text: qsTr("叠加间隔")
  }

 SpinBox{
     id:_interval
     x:name3.x+name3.width+40
     from: 1
     to:10000
     editable: true
     anchors.verticalCenter: name3.verticalCenter
 }

 Button{
     id:btn_start
     text: "生成"
     anchors.horizontalCenter: parent.horizontalCenter
     y:name3.y+35
     onClicked: {
        if(!root.show_flag){
            root.show_flag=true
            var r = mvid.showFrequencyImage(_start.value,_number.value,_interval.value)
            root.show_flag=false
            if(!r){
                dia.showInfo("错误的参数！")
            }
        }
     }
 }

 function setFrameCount(count){
     _start.to=count
 }

 function setStartPos(pos){
     _start.value=pos
 }

}
