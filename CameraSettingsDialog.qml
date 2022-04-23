import QtQuick
import QtQuick.Controls


Dialog {
    id : camera_settings_dialog
    width: 260
    height: 400
    background: Rectangle{
        id:dia_bg
        anchors.fill: parent
        radius:8
        color:"#ffffff"
    }

    Column{
        Row{
            Text {
                text: qsTr("分辨率:")
            }
            ComboBox{
                id:resolutions_combox
            }
        }
    }

    function refreshResolutions(re){
        resolutions_combox.model = re
    }

}
