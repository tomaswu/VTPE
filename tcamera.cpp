#include "tcamera.h"
#include <QtMultimedia/QMediaDevices>
#include <qdebug.h>
#include <QCameraDevice>
#include <QTimer>
#include <QStringList>
#include <QImage>
#include <QPixmap>
#include <QQuickImageProvider>
#include <tvideocapture.h>

bool equalList(QStringList m,QStringList n){

    if (m.length()!=n.length()){
        return false;
    };
    if (m.length()>0){
        for (int i=0;i<m.length();i++){
            if (m[i]!=n[i]){
                return false;
            };
        }
    }
    return true;
}

TCamera::TCamera(QObject *parent)
    : QObject{parent}
{
    cap = new TVideoCapture;
    ipdr = new imgProvider;
    cap->moveToThread(&thread);
    thread.start();
    timer = new QTimer;
    timer->setInterval(3000);
    connect(timer,&QTimer::timeout,this,&TCamera::getCameraList);
    connect(this->cap,&TVideoCapture::imgReady,this,&TCamera::refreshImage);
    timer->start();

}

TCamera::~TCamera(){
    delete timer;
    delete ipdr;
    thread.terminate();
}

void TCamera::refreshImage(QImage img){
    this->ipdr->setImage(img);
    this->imageRefreshed();
}

void TCamera::getCameraList(){
    QMediaDevices mds;
    history_list = camera_list;
    QList<QCameraDevice> rlist = mds.videoInputs();
    camera_list.clear();
    for (auto &c: rlist){
        camera_list.append(c.description());
    };
    emit cameraListRefreshed();
    if(!equalList(camera_list,history_list)){
        emit cameraListChanged();
        history_list=camera_list;
    }
}


void TCamera::printCameralist(){
    for (auto &i : camera_list){
       qDebug()<<i;
    }
    qDebug()<<"已经打印所有相机名称";

}

bool TCamera::open(int index){
    bool ret = cap->init(index);
    return ret;
}


//==============================================

imgProvider::imgProvider(): QQuickImageProvider(QQuickImageProvider::Image)
{
};

imgProvider::~imgProvider(){

};


QImage imgProvider::requestImage(const QString &id,QSize *size,const QSize &requestexSize){
    return this->img;
};

QPixmap imgProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    return QPixmap::fromImage(this->img);
};


//=========================================
