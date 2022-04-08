#include "tvideocapture.h"
#include <QObject>
#include <qdebug.h>
#include <QImage>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgproc/types_c.h>
#include <QSysInfo>
#include <QCamera>
#include <QCameraDevice>
#include <QMediaDevices>
#include <QMediaCaptureSession>
#include <QImageCapture>
#include <QVideoWidget>
#include <QVideoSink>
#include <QMediaRecorder>
#include <QUrl>


TVideoCapture::TVideoCapture(QObject *parent)
    : QObject{parent}
{
    vsk = new QVideoSink;
    recorder = new QMediaRecorder;
    timer = new QTimer;
    timer->setInterval(1);
    connect(timer,&QTimer::timeout,this,&TVideoCapture::capture);
    connect(this,&TVideoCapture::startCapture,this,&TVideoCapture::capture);
}

TVideoCapture::~TVideoCapture(){

}


bool TVideoCapture::init(const QCameraDevice &index){
    camera = new QCamera(index);
    auto dev = camera->cameraDevice();
    QMediaCaptureSession *pcs = new QMediaCaptureSession;
    imgCap = new QImageCapture();
    imgCap->setParent(camera);
    pcs->setCamera(camera);
    pcs->setImageCapture(imgCap);
    pcs->setVideoSink(vsk);
    pcs->setRecorder(recorder);
    camera->start();
    timer->start();
    t0 = clock();
//    recorder->setOutputLocation(QUrl::fromLocalFile("c:/mytets.avi"));
    qDebug()<<recorder->outputLocation();
    return camera->isActive();
}

void TVideoCapture::uninit(){
    delete imgCap;
    delete camera;
}

void TVideoCapture::capture(){
    auto vf = vsk->videoFrame();
    emit this->imgReady(vf.toImage());
    frame_count+=1;
    if (frame_count==100){
        t1=clock();
//        qDebug()<<10000/(t1-t0),vf.size();
        t0=t1;
        frame_count=0;
    }
}

void TVideoCapture::stopCapture(){

}

void TVideoCapture::startRecord(QString path){
    qDebug()<<"start record";
    recorder->record();
    qDebug()<<recorder->recorderState();
}

void TVideoCapture::stopRecord(){
    qDebug()<<"stop record";
    recorder->stop();
}

bool TVideoCapture::isOpened(){
    return false;
}

void TVideoCapture::openSettings(){

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
