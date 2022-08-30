import QtQuick

Item {
    // 目前暂时只支持在main中进行拖动选择，后期可以考虑增加一个自由变换的功能
    id: select_scale
    width:400
    height: 300
    visible: false

    Rectangle{
        id:bg
        border.width:1
        border.color: "yellow"
        color: Qt.rgba(1,1,1,0)
        anchors.fill: parent
    }

    onVisibleChanged: setScale()

    function setScale(){
        if(mvid.isOpened()){
            if(video_img.paintedWidth>0){
                var row1,row2,col1,col2,x0,y0,cw,ch
                x0 = video_img.width/2+(data_table.width+data_table.x)+video_img.x//+data_table.width+data_table.x
                if(data_table.visible){
                    x0-=data_table.width
                }

//                console.log(x0)
                y0 = video_img.height/2+video_img.y
                cw = video_img.paintedWidth*video_img.scale
                ch = video_img.paintedHeight*video_img.scale

                col1 = (select_scale.x-x0)/cw
                col2 = (select_scale.x+select_scale.width-x0)/cw
                row1 = (select_scale.y-toolbar.height-y0)/ch
                row2 = (select_scale.y-toolbar.height+select_scale.height-y0)/ch
                var size = mvid.getImageSize()
                var c1,c2,r1,r2
                c1=(size[0]*col1+size[0]/2).toFixed()
                c2=(size[0]*col2+size[0]/2).toFixed()
                r1=(size[1]*row1+size[1]/2).toFixed()
                r2=(size[1]*row2+size[1]/2).toFixed()


                if(c1<0)c1=0
                if(c1>size[0]){c1=size[0];c2=c1}
                if(c2<0){c1=0;c2=c1}
                if(c2>size[0])c2=size[0]
                if(r1<0)r1=0
                if(r1>size[1]){r1=size[1];r2=r1}
                if(r2<0){r2=0;r1=r2}
                if(r2>size[1])r2=size[1]

//                console.log(c1,c2,r1,r2)

                pmb0100_para_window.setScale(c1,c2,r1,r2)

            }
        }
    }
}
