import QtQuick
import QtQuick.Controls


Dialog {
    id : camera_settings_dialog
    property bool photoMode: true
    width: 260
    height: 180
    background: Rectangle{
        id:dia_bg
        anchors.fill: parent
        radius:8
        color:"#ffffff"
    }

    Column{
        anchors.fill: parent
        padding:10
        spacing:5
        Row{
            padding:10
            spacing: 10
            Text {
                text: qsTr("连拍模式:")
                anchors.verticalCenter: parent.verticalCenter
            }
            CheckBox{
                anchors.verticalCenter: parent.verticalCenter
                id:photomode_checkbox
                checked: camera_settings_dialog.photoMode
                onCheckedChanged: camera_settings_dialog.photoMode = checked
            }
        }

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
