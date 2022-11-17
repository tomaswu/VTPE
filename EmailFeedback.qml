import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id:dialog
    width: 480
    height: 320
    color: "#ffffff"
    radius: 12

    Column{
        anchors.fill: parent
        spacing: 10
        padding: 24
        Rectangle{
            id:context_bg
            width:parent.width-2*parent.padding
            height: 200
            border.width: 1
            border.color: Qt.rgba(0,0,0,0.3)
            radius:4
            TextEdit{
                id: context
                x:5
                y:5
                width: parent.width-10
                height: parent.height-10
                Text{
                    id:placehoder
                    anchors.fill: parent
                    wrapMode: Text.WordWrap
                    opacity: 0.3
                    text:"请输入您的反馈意见,如果您留下您的联系方式与称呼,\我们将在采取您的提升建议后与您取得联系!\n感谢您的宝贵意见!"
                }
                onTextChanged: {
                    var s = text+preeditText
                    if (!s){
                        placehoder.visible=true
                    }
                    else
                    {
                        placehoder.visible=false
                    }
                }

                onPreeditTextChanged: {
                    var s = text+preeditText
                    //console.log(s)
                    if (s){
                        placehoder.visible=false
                    }
                    else
                    {
                        placehoder.visible=true
                    }

                }
                onFocusChanged: {
                    if(focus){
                        context_bg.border.color=Qt.rgba(0.2,0.6,0.95,0.8)
                    }
                    else
                    {
                        context_bg.border.color=Qt.rgba(0,0,0,0.3)
                    }
                }
           }

        }

        TextField{
            id: from_email
            width: context_bg.width
            placeholderText: "请输入您的联系邮箱"
        }

        Row{
            spacing: 12
            anchors.horizontalCenter: parent.horizontalCenter
            Button{
                id:confirm
                text:"发送"
                onClicked: {
                    dialog.visible=false
                    if(context.text.length>10){
                        console.log("email already")
                        var ret = shell.feedBackByEmail(context.text+"\nfrom: "+from_email.text)
                        if(ret){
                            dia.showInfo("您的反馈意见已经发送成功!")
                        }
                        else{
                            dia.showInfo("发送失败，请检查网络!")
                        }
                    }
                    else{
                        dia.showInfo("发送失败，字符长度需要大于10个字符！")
                    }

                }// end onclicked
            }
            Button{
                id:cancel
                text:"取消"
                onClicked: dialog.visible=false
            }
        }

    }//end column

}
