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
                text: display
                anchors.centerIn: parent
                font.pointSize: 8
                color: "black"
            }
        }

    }

    Component.onCompleted: {
        addRowByList([1,44,55,67,88])
        addRowByList([2,48,55,67,88])
        addRowByList([3,51,55,67,88])
        addRowByList([4,66,55,67,88])
        addRowByList([5,66,55,67,88])
        addRowByList([6,66,55,67,88])
        addRowByList([7,66,55,67,88])
        addRowByList([8,66,55,67,88])
        addRowByList([9,66,55,67,88.54])
        addRowByList([10,66,55,67,88])
        addRowByList([11,66,55,67,88])
        addRowByList([12,66,55,67,88])
        export2csv()
        tableModel.clear();
    }
    function addRowByList(s){
        tableModel.appendRow({"frame":s[0],"x1":s[1],"y1":s[2],"x2":s[3],"y2":s[4]})
    }

    function export2csv(){
        var ml = []
        console.log(tableModel.rowCount)
        for(var i=0;i<tableModel.rowCount;i++){
            var ob = tableModel.rows[i];
            ml.push([ob.frame,ob.x1,ob.y1,ob.x2,ob.y2])
        }
        console.log(ml)
    }

    Connections{
        target:mvid
        function onRecognizedOneFrame(res){
            addRowByList(res)
            sclbar.position=1-sclbar.size
        }
    }

}

