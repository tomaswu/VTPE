import QtQuick
import QtQuick.Controls


Dialog {
    id : camera_settings_dialog
    width: 260
    height: 120
    background: Rectangle{
        id:dia_bg
        anchors.fill: parent
        radius:8
        color:"#ffffff"
    }

    Column{
        anchors.fill: parent
        padding:10
        spacing:10
        Row{
            padding:10
            spacing: 10
            Text {
                text: qsTr("分辨率:")
                anchors.verticalCenter: parent.verticalCenter
            }
            ComboBox{
                anchors.verticalCenter: parent.verticalCenter
                id:resolutions_combox
                onCurrentTextChanged: {
                    mcap.setResolution(currentText)
                }
            }
        }
        Row{
            anchors.horizontalCenter: parent.horizontalCenter
            Button{
                id:more_settings
                text: "更多设置"
                enabled: Qt.platform.os==="windows" ? true:false
                onClicked: {
                    camera_settings_dialog.close()
                    mcap.openSettings()
                }
            }
        }
    }

    function refreshResolutions(re){
        resolutions_combox.model = re
    }

}
