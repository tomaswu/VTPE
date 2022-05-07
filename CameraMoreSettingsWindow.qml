//这个窗口只是
import QtQuick
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.1
import QtCharts 2.15
import QtQuick.Dialogs

Window {
    id:sub_window
    width:400
    height: 480

    Column{
        Rectangle{
            id:para_bg
            anchors.horizontalCenter: parent.horizontalCenter
            width: 380
            height: 460
            border.width: 1
            border.color: "lightgreen"
        }


        Row{
            spacing: 12
            anchors.right:parent.right
            Button{
                id:confirm
                text:"确定"
                onClicked: {
                    dialog.visible=false
                    dia.showInfo("您的反馈意见已经发送成功!")
                }
            }
            Button{
                id:cancel
                text:"取消"
                onClicked: dialog.visible=false
            }

            Button{
                id:apply
                text:"应用"
                onClicked: dialog.visible=false
            }

        }

    }// end column


}
