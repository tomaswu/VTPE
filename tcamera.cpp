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
#include <QVariantList>
#include <opencv2/imgproc.hpp>
#include <iostream>

//#ifdef  Q_OS_WINDOWS //华谷动力相机仅支持windows
//#include <IMVAPI/IMVApi.h>
//#include <IMVAPI/IMVDefines.h>
//#endif

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
    timer->stop();
    timer_refresh->stop();
    thread.terminate();
    delete cap;
    delete timer;
    delete ipdr;
    delete timer_refresh;
}

QStringList TCamera::getSupportedResolutions(){
    return cap->supportedResolution;
}

void TCamera::refreshImage(QImage img){
    if (time_to_refresh){
        this->ipdr->setImage(img,this->cap->CamType);
        emit this->imageRefreshed();
        time_to_refresh=false;
    }
}

void TCamera::getCameraList(){
    QMediaDevices mds;
    history_list = camera_list;
    QList<QCameraDevice> rlist = mds.videoInputs();
    cap->cvCamNum =  rlist.length();
    camera_list.clear();
    for (auto &c: rlist){
        camera_list.append(c.description());
    };
#ifdef Q_OS_WINDOWS //华谷动力相机只支持windows系统
    IMV_DeviceList *p = new IMV_DeviceList;
    IMV_EnumDevices(p,IMV_EInterfaceType::interfaceTypeUsb3);
    cap->workPowerCamNum = p->nDevNum;
    for (uint i=0;i<p->nDevNum;i++){
        if(strlen(p->pDevInfo[i].cameraName)){
            camera_list.append(p->pDevInfo->cameraName);
        }
        else{
            camera_list.append(p->pDevInfo[i].modelName);
        }
    }
#endif
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

QVariantList TCamera::calSelectScale(double row1,double row2, double col1, double col2){
    QVariantList res;
    double max=0;
    double min=255;
    double ave=0;
    int count = 0;
    int r1,r2,c1,c2;
    if(cap->mat.empty()){
        res.append(-1);
        res.append(-1);
        res.append(-1);
        return res;
    }

    if(row1<-0.5){
        r1=0;
    }
    else if(row1>0.5){
        r1 = cap->mat.size[0];
    }
    else{
        r1 = cap->mat.size[0]*(row1+0.5);
    }

    if(row2<-0.5){
        r2=0;
    }
    else if(row2>0.5){
        r2 = cap->mat.size[0];
    }
    else{
        r2 = cap->mat.size[0]*(row2+0.5);
    }

    if(col1<-0.5){
        c1=0;
    }
    else if(col1>0.5){
        c1 = cap->mat.size[1];
    }
    else{
        c1 = cap->mat.size[1]*(col1+0.5);
    }

    if(col2<-0.5){
        c2=0;
    }
    else if(col2>0.5){
        c2 = cap->mat.size[1];
    }
    else{
        c2 = cap->mat.size[1]*(col2+0.5);
    }

    uchar* p;
    cv::Mat img;
    img = this->cap->QImage2Mat(this->ipdr->img);
    cv::Mat gray;
    if (img.channels()==3){
        cv::cvtColor(img,gray,cv::COLOR_BGR2GRAY);
    }
    else{
        gray = img;
    }
    for(int i=r1;i<r2;i++){
        p = gray.ptr<uchar>(i);
        for(int j = c1;j<c2;j++){
            max = max>p[j] ? max:p[j];
            min = min<p[j] ? min:p[j];
            ave = count==0 ? p[j]:(p[j]+ave)/2;
            count+=1;
        }
    }
    res.append(max);
    res.append(min);
    res.append(ave);
    return res;

}

int TCamera::getCameraType(){
    return cap->CamType;
}

void TCamera::setCaliFlag(bool flag){
    this->cap->cali_flag=flag;
}


//==============================================

imgProvider::imgProvider(): QQuickImageProvider(QQuickImageProvider::Image)
{
};

imgProvider::~imgProvider(){

};

void imgProvider::setImage(QImage img,int camera_type){
    switch (camera_type){
        case cvCam:
            this->img=img;
            break;
        case workPowerCam:
            QImage tmp;
            tmp=this->img;
            this->img=img;
            if (!tmp.isNull())free(tmp.bits());
            break;
    }
}


QImage imgProvider::requestImage(const QString &id,QSize *size,const QSize &requestexSize){
    if (this->img.isNull()){
        QImage bimg(640,480,QImage::Format_RGB888);
        bimg.fill("black");
        return bimg;
    }
    return this->img;
};

QPixmap imgProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    if (this->img.isNull()){
        QPixmap bimg(640,480);
        bimg.fill("black");
        return bimg;
    }
    return QPixmap::fromImage(this->img);
};


//=========================================
