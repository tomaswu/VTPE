import QtQuick 2.12
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
        mipmap:true

    }

    ColorOverlay {
        anchors.fill: mask
        source: mask
        color: parent.color
    }

}
