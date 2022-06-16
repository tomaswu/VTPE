import QtQuick
import QtQuick.Controls

Window {
    width:300
    height: 260
    maximumWidth: width
    minimumWidth: width
    maximumHeight: height
    minimumHeight: height
    title: "数据处理与绘图"

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
                text: "15"
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
                text: "40"
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
                width: 40
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
            }

            Button{
                id:figure
                text: "绘制"
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

//                highlightRangeMode:ListView.StrictlyEnforceRange


                model: ListModel {
                    ListElement {
                        label: "小球1 x方向速度"
                    }
                    ListElement {
                        label: "小球1 y方向速度"
                    }
                    ListElement {
                        label: "小球1 y方向速度"
                    }
                    ListElement {
                        label: "小球1 y方向速度"
                    }
                    ListElement {
                        label: "小球1 y方向速度"
                    }
                    ListElement {
                        label: "小球1 y方向速度"
                    }
                    ListElement {
                        label: "小球1 y方向速度"
                    }
                    ListElement {
                        label: "小球1 y方向速度"
                    }
                    ListElement {
                        label: "小球1 y方向速度"
                    }

                }

                delegate:Component {
                    id: contactDelegate
                    Item {
                        width: parent.width; height: 24
                        Column {
                            padding:5
                            Text { text: label }
                        }
                    }//end ItemD
                }// end component

                highlight: Rectangle {
                    color: "lightsteelblue"
                    radius: 3
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        var y = scrollBar.position*curve_list.contentHeight+mouseY
                        curve_list.currentIndex=curve_list.indexAt(mouseX,y)
//                        console.log(y,curve_list.currentIndex)
                    }
                }

                ScrollBar.vertical: ScrollBar {
                        id: scrollBar
                        onActiveChanged: {
                            active = true;
                        }
                        Component.onCompleted: {
                            scrollBar.handle.color = "red";
                            scrollBar.active = true;
                            scrollBar.handle.width = 20;
                            scrollBar.handle.height = 100;
                        }
                        onPositionChanged: {

                        }
                    }

                function isCurrentItemHide(){
                    var y = scrollBar.position*curve_list.contentHeight
                    if (curve_list.currentIndex*24>y&&curve_list.currentIndex*24<current)
                }

            }



        }


    }



}
