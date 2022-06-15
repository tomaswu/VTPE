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
                text: qsTr("自动命名拍照:")
                anchors.verticalCenter: parent.verticalCenter
            }
            CheckBox{
                anchors.verticalCenter: parent.verticalCenter
                id:photomode_checkbox
                checked: camera_settings_dialog.photoMode
                onCheckedChanged: camera_settings_dialog.photoMode = checked
            }

            Button{
                id:camera_setFolder
                text: "照片保存位置"
                onClicked:{
                    var s = shell.getExistingFolder("保存",folder_recording.photoFolder)
                    if (s!==""){
                        folder_recording.photoFolder = s
                    }
                }// end clicked
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
                onClicked: {
                    camera_settings_dialog.close()
                    if(Qt.platform.os === "windows"){
                        var camtype = mcap.getCameraType()
                        switch (camtype){
                            case 0:
                                mcap.openSettings()
                                break
                            case 1:
                                camera_settings_widnow.show()
                                camera_settings_widnow.setLastSettings()
                                break
                        }
                    }
                    else{
                        camera_settings_widnow.show()
                    }
                }
            }
        }
    }

    function refreshResolutions(re){
        resolutions_combox.model = re
    }

}
