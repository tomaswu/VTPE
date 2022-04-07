#include "tvideocapture.h"
#include <QObject>
#include <qdebug.h>
#include <QImage>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgproc/types_c.h>
#include <QSysInfo>

TVideoCapture::TVideoCapture(QObject *parent)
    : QObject{parent}
{
    cap = new cv::VideoCapture;
    connect(this,&TVideoCapture::startCapture,this,&TVideoCapture::capture);
}

TVideoCapture::~TVideoCapture(){
    delete cap;
}

bool TVideoCapture::init(int index){
    bool ret=false;
    if ((QSysInfo::productType()=="windows")){
        ret = cap->open(index);
//        cap->set(cv::CAP_PROP_FRAME_WIDTH,1920);
//        cap->set(cv::CAP_PROP_FRAME_HEIGHT,1080);
    }
    else{
        ret = cap->open(index);
    }
    return ret;
}

void TVideoCapture::uninit(){
    running_flag=false;
}

void TVideoCapture::capture(){
    if (cap->isOpened()){
       fps_count=0;
       clock_t t0=clock();
       clock_t t1;
       while (running_flag)
       {
           bool ret = cap->read(mat);
           if (ret){
              auto tmp=Mat2QImage(mat);
              fps_count+=1;
              emit imgReady(tmp);
           }
           if (fps_count==100){
               t1=clock();
               qDebug()<<100000/(t1-t0);
               t0=t1;
               fps_count=0;
           }

       }
       cap->release();
       running_flag=true;
       emit stopped();
    }

}

void TVideoCapture::stopCapture(){

}

void TVideoCapture::startRecord(QString path){

}

void TVideoCapture::stopRecord(){

}

bool TVideoCapture::isOpened(){
    return cap->isOpened();
}

void TVideoCapture::openSettings(){
    cap->set(cv::CAP_PROP_SETTINGS,0);
}


QImage TVideoCapture::Mat2QImage(cv::Mat const& mat)
{
    cv::Mat temp;
    cv::cvtColor(mat, temp,CV_BGR2RGB);
    QImage image((const uchar *) temp.data, temp.cols, temp.rows, temp.step, QImage::Format_RGB888);
    image.bits();
    return image;
}

cv::Mat TVideoCapture::QImage2Mat(QImage const& image)
{
    cv::Mat tmp(image.height(),image.width(),CV_8UC3,(uchar*)image.bits(),image.bytesPerLine());
    cv::Mat mat;
    cv::cvtColor(tmp, mat,CV_BGR2RGB);
    return mat;
}