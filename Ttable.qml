import QtQuick
import QtQuick.Controls
import Qt.labs.qmlmodels

Rectangle {
    width:260
    height: 480

    Rectangle{
        id:header
        width: parent.width
        height: 30

        Row{
            spacing: 0

            Repeater{
                id:header_re
                model: ["Frame","x1","y1","x2","y2"]
                Rectangle{
                    width: header.width/5
                    height: header.height
                    color: "#99cccc"
                    border.width: 0
                    border.color: "#303030"

                    Canvas{
                        id: header_line
//                        antialiasing: true
                        anchors.fill: parent
                        onPaint:{
                            var ctx = getContext("2d")
                            ctx.clearRect(0,0,width,height)
                            ctx.strokeStyle = "black"
                            ctx.fillStyle = "black"
                            ctx.lineWidth = 2
                            ctx.beginPath()
                            ctx.moveTo(0,0)
                            ctx.lineTo(0,height)
                            ctx.moveTo(0,-1)
                            ctx.lineTo(width,-1)
                            ctx.moveTo(0,height)
                            ctx.lineTo(width,height)
                            ctx.closePath()
                            ctx.stroke()
                        }
                    }
                    Text {
                        text: modelData
                        anchors.centerIn: parent
                        font.pointSize: 10
                        color: "#ffffff"
                    }
                }
            }
        }
    }

    TableView{
        id:tableView
        anchors.top:header.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        boundsBehavior: Flickable.OvershootBounds

        ScrollBar.vertical: ScrollBar {
            id:sclbar
            anchors.right:parent.right
            anchors.rightMargin: 0
            visible: tableModel.rowCount > 15
            background: Rectangle{
                color:"#666666"
            }
            onActiveChanged: {
                active = true;
            }
            contentItem: Rectangle
            {
                implicitWidth  : 6
                implicitHeight : 30
                radius : 3
                color  : "#303030"
            }
        }

        model: TableModel {
            id:tableModel

            TableModelColumn{display: "frame"}
            TableModelColumn{display: "x1"}
            TableModelColumn{display: "y1"}
            TableModelColumn{display: "x2"}
            TableModelColumn{display: "y2"}

        }
        delegate:Rectangle{
            color: "white"
            implicitWidth: tableView.width/5
            implicitHeight: 26

            Canvas{
                id: gird_line
                antialiasing: true
                anchors.fill: parent
                onWidthChanged: {
                    gird_line.requestPaint()
                }

                onPaint:{
                    var ctx = getContext("2d")
                    ctx.clearRect(0,0,width,height)
                    ctx.strokeStyle = "black"
                    ctx.fillStyle = "black"
                    ctx.lineWidth = 2
                    ctx.beginPath()
                    ctx.moveTo(0,0)
                    ctx.lineTo(0,height)
                    ctx.moveTo(0,-1)
                    ctx.lineTo(width,-1)
                    ctx.moveTo(0,height)
                    ctx.lineTo(width,height)
                    ctx.closePath()
                    ctx.stroke()
                }
            }

            Text {
                text: pmb0100_para_window.standardUint? display.toLocaleString(Qt.locale("en-US"),"e",2): display
                anchors.centerIn: parent
                font.pointSize: 8
                color: "black"
            }
        }

    }

    Menu{
        id: menu
        width:120

        MenuItem{
            id:unit_convert
            text:"转换为标准单位"
            onTriggered: {
                if(text==="转换为标准单位"){
                    text="转换为像素单位"
                }
                else{
                    text="转换为标准单位"
                }
            }
        }
    }

    MouseArea{
        id:ma
        anchors.fill: parent
        z:parent.z
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function (mouse){
            if(mouse.button===Qt.RightButton){
                menu.popup()
            }
        }
    }

    Component.onCompleted: {

//        addRowByList([1,2,3,4,5])
//        addRowByList([6,7,8,9,0])
        tableModel.clear();
    }

    function isEmpty(){
        if(tableModel.rowCount>0){
            return false
        }
        return true
    }

    function addRowByList(s){
        tableModel.appendRow({"frame":s[0],"x1":s[1],"y1":s[2],"x2":s[3],"y2":s[4]})
    }

    function clear(){
        tableModel.clear()
    }

    function getDataList(){
        var ml = []
        for(var i=0;i<tableModel.rowCount;i++){
            var ob = tableModel.rows[i];
            ml.push([ob.frame,ob.x1,ob.y1,ob.x2,ob.y2])
        }
        return ml
    }

    function export2csv(){
        var ml = getDataList()
        var path = shell.getSaveFileName("导出数据",folder_recording.lastSaveFolder,"csv(*.csv)")
        dia.showInfo("导出数据成功！")
        if(path){
            shell.list2csv(ml,path)
            var cmd
            switch(Qt.platform.os){
               case "windows":
                   path = path.replace(new RegExp("/", "g"),"\\")
                   cmd = `explorer /select, ${path}`
                   shell.system(cmd)
                   break
               case "osx":
                   cmd = `open -R /${path}`
                   shell.system(cmd)
                   break
               default:
                   dia.showInfo("本系统暂不支持在文件系统\n中显示该文件")
                   break
            }//end switch
        }
    }

    Connections{
        target:mvid
        function onRecognizedOneFrame(res){
            addRowByList(res)
            sclbar.position=1-sclbar.size
        }
    }

    function getHeaderName(){
        return header_re.model
    }

}

