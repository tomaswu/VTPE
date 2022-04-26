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
    connect(this->cap,&TVideoCapture::stopped,this,&TCamera::alreadyStopped);
    getCameraList();
    timer->start();
    timer_refresh = new QTimer();
    timer_refresh->setInterval(40);
    connect(timer_refresh,&QTimer::timeout,this,&TCamera::setTimerFresh);
    timer_refresh->start();
    connect(cap,&TVideoCapture::newfps,this,&TCamera::refreshFps);
}

TCamera::~TCamera(){
    delete timer;
    delete ipdr;
    thread.terminate();
}

QStringList TCamera::getSupportedResolutions(){
    return cap->supportedResolution;
}

void TCamera::refreshImage(QImage img){
    if (time_to_refresh){
        this->ipdr->setImage(img);
        emit this->imageRefreshed();
        time_to_refresh=false;
    }
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
    bool ret = cap->isOpened();
    if(ret!=opened){
        opened = ret;
        emit openedChanged();
    }
}

bool TCamera::isOpened(){
    return cap->isOpened();
}

void TCamera::release(){
    cap->uninit();
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

void TCamera::refreshFps(double f){
    if (fps!=f){
        fps=f;
        emit fpsChanged();
    };
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
