import QtQuick
import QtQuick.Controls

Window {
    width:300
    height: 280
    maximumWidth: width
    minimumWidth: width
    maximumHeight: height
    minimumHeight: height
    title: "PMB0100数据处理"
    property int figs: 0
    id:root

    Column{
        spacing: 15
        anchors.fill:parent
        padding:15

        Row{
            spacing: 10
            Row{
                anchors.verticalCenter: parent.verticalCenter
                spacing: 5
                Text {
                    text: "滤波(Hz)"
                    anchors.verticalCenter: parent.verticalCenter
                }
                CheckBox{
                    id:filter_cbx
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            TextField{
                id:filter_low_input
                enabled: filter_cbx.checked
                anchors.verticalCenter: parent.verticalCenter
                selectByMouse:true
                validator: RegularExpressionValidator {
                    regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}|[0-9][0-9]{0,2}|1000/
                }
                width: 40
                text: "0"
                onAccepted: {
                    focus = false
                }
            }

            Text {
                id: filter_ab_text
                text: qsTr("~")
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField{
                id:filter_high_input
                enabled: filter_cbx.checked
                anchors.verticalCenter: parent.verticalCenter
                selectByMouse:true
                validator: RegularExpressionValidator {
                    regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}|[0-9][0-9]{0,2}|1000/
                }
                width: 40
                text: "5"
                onAccepted: {
                    focus = false
                }
            }

        }//end row

        Row{
            spacing: 10
            Text{
                text: "帧率(fps)"
                anchors.verticalCenter: parent.verticalCenter
            }

            TextField{
                id:process_fps
                anchors.verticalCenter: parent.verticalCenter
                selectByMouse:true
                validator: RegularExpressionValidator {
                    regularExpression: /1000.00|[0-9][0-9]{0,2}[\.][0-9]{1,2}|[0-9][0-9]{0,2}|1000/
                }
                width: 64
                text: "40"
                onAccepted: {
                    focus = false
                }
            }

        }


        Row{
            spacing: 10
            Text{
                text: "绘图"
                anchors.verticalCenter: parent.verticalCenter
            }

            Button{
                id:add_line
                text: "添加曲线"
                onClicked: {
                    dialog.show()
                }
            }

            Button{
                id:del_line
                text: "删除曲线"
                onClicked: {
                    if(list_model.count>0){
                        list_model.remove(curve_list.currentIndex)
                    }
                }
            }

            Button{
                id:figure
                width:48
                text: "绘制"
                onClicked: {
                    if(root.figs==0){
                        var data = data_table.getDataList();
                        var filter =[0,0]
                        var para = []
                        for(var i =0;i<list_model.count;i++){
                           para.push([list_model.get(i).label,list_model.get(i).x_axis,list_model.get(i).y_axis])
                        }
                        var header = data_table.getHeaderName()
                        if(filter_cbx.checked){
                            filter = [filter_low_input.text,filter_high_input.text]
                        }
                        root.figs+=1
                        var r=shell.data_process(data,header,para,filter,process_fps.text)
                        root.figs-=1
                    }
                }
            }

        }

        Rectangle{
            width:parent.width-parent.padding*2
            height: 110
            border.color: "green"

            ListView{
                id:curve_list
                x:5
                y:5
                width:parent.width-10
                height:parent.height-10
                snapMode:ListView.SnapPosition
                displayMarginBeginning:-15
                displayMarginEnd:-15
                property real historty_index: -1

//                highlightRangeMode:ListView.StrictlyEnforceRange


                model: ListModel {
                    id:list_model

                }

                delegate:Component {
                    id: contactDelegate
                    Item {
                        width: curve_list.width; height: 24
                        Column {
                            padding:5
                            Text { text: `${label} ${x_axis}-${y_axis}`}
                        }
                    }//end ItemD
                }// end component

                highlight: Rectangle {
                    id: high_light_rect
                    color: "lightsteelblue"
                    radius: 3
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        var y = scrollBar.position*curve_list.contentHeight+mouseY
                        curve_list.currentIndex=curve_list.indexAt(mouseX,y)
                        curve_list.historty_index=-1
                    }
                }

                ScrollBar.vertical: ScrollBar {
                        id: scrollBar
                        onActiveChanged: {
                            active = true;
                        }
                        Component.onCompleted: {
//                            scrollBar.handle.color = "red";
//                            scrollBar.active = true;
//                            scrollBar.handle.width = 20;
//                            scrollBar.handle.height = 100;
                        }
                        onPositionChanged: {
                            curve_list.isCurrentItemHide()
                        }
                    }

                function isCurrentItemHide(){
                    var y = scrollBar.position*curve_list.contentHeight

                    if (curve_list.currentIndex*24<y&&curve_list.currentIndex!==-1){
                        curve_list.historty_index=curve_list.currentIndex
                        curve_list.currentIndex=-1
                    }
                    if(curve_list.currentIndex*24>y+curve_list.height){
                        curve_list.historty_index=curve_list.currentIndex
                        curve_list.currentIndex=-1
                    }
                    if(curve_list.historty_index*24>y&&curve_list.historty_index*24<y+curve_list.height&&curve_list.historty_index!=-1){
                        curve_list.currentIndex=curve_list.historty_index
                        curve_list.historty_index=-1
                    }

                }

                Connections{
                    target: dialog
                    function onConfirmed( label, x, y){
                        var s = label? label:"未命名"
                        list_model.append({"label":s,"x_axis":x,"y_axis":y})
                    }
                }

            }// end list view

        }
    }

    AddCurveDialog{
        id:dialog
    }

    function setCombox(r1,r2){
        dialog.setCombox(r1,r2)
    }

    function setFps(fps){
        process_fps.text = fps
    }

}
