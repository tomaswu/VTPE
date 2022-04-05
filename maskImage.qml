import QtQuick 2.0
import Qt5Compat.GraphicalEffects

Item {
    property string source: ""
    property string color: "#323232"
    property int fillMode: Image.Stretch

    Image{
        id:mask
        anchors.fill: parent
        source: parent.source
        fillMode: parent.fillMode
    }

    ColorOverlay {
        anchors.fill: mask
        source: mask
        color: parent.color
    }

}
