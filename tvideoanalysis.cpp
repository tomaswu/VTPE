#include "tvideoanalysis.h"
#include <string>
#include <vector>
#include <iostream>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <tcamera.h>
#include <pmb0100rec.h>


using namespace std;

TVideoAnalysis::TVideoAnalysis(QObject *parent)
    : QObject{parent}
{
    ipdr = new imgProvider;
    video_reader = new cv::VideoCapture;
    play_timer = new QTimer;
    connect(this->play_timer,&QTimer::timeout,this,&TVideoAnalysis::getFrame);
    play_timer->setInterval(5);
//    this->open(this->testfile);
}

TVideoAnalysis::~TVideoAnalysis(){
    play_timer->stop();
    delete play_timer;
    video_reader->release();
    delete video_reader;
}

void TVideoAnalysis::open(QString path){
    if(play_timer->isActive())
    {
        play_timer->stop();
    }
    if(video_reader->isOpened()){
        video_reader->release();
    }
    video_reader->open(path.toStdString());
    if (video_reader->isOpened()){
        setPlaySpeed(1.0);
        setBeginPos(0);
        setEndPos(getFrameCount());
        getFrame();
        emit alreadyOpened();
    }
}

int TVideoAnalysis::getPos(){
    int p = video_reader->get(cv::CAP_PROP_POS_FRAMES);
    if (p!=pos){
        emit posChanged();
    }
    pos=p;
    return pos;
}

bool TVideoAnalysis::setPos(int i){
    bool ret = video_reader->set(cv::CAP_PROP_POS_FRAMES,i);
    if (ret){
        pos=i;
        emit posChanged();
    }
    return ret;
}


int TVideoAnalysis::getBeginPos(){
    return 0;
}

void TVideoAnalysis::setBeginPos(int i){
    this->beginPos = i;
}

int TVideoAnalysis::getEndPos(){
    return 0;
}

void TVideoAnalysis::setEndPos(int i){
    this->endPos=i;
}

int TVideoAnalysis::getFrameCount(){
    return video_reader->get(cv::CAP_PROP_FRAME_COUNT);
}

bool TVideoAnalysis::isOpened(){
    return video_reader->isOpened();
}

void TVideoAnalysis::getFrame(){
    bool ret = video_reader->read(img);
    if(!ret){
        return;
    }
    ipdr->img = Mat2QImage(img);
    emit imageRefreshed();

    if(recFlag){
        qDebug()<<"hello";
        pmb0100rec::recResult r = pmb0100rec::recBall(img,pmb0100rec_para);

        QList<double> res;
        res.append(pos);
        for(auto &i:r){
            res.append(i.x);
            res.append(i.y);
        }
        qDebug()<<res;

    }

    getPos();
    if(pos==endPos){
        setPos(beginPos);
        if(recFlag){
            recFlag=false;
            emit finishedRec();
        }
    }
}

void TVideoAnalysis::startRecognize(int threshold,int pixel,int millimeter,int pointNum,int method,int c1,int c2,int r1,int r2){
    qDebug()<<method;
    switch(method){
    case 0:
        pmb0100rec_para.threshold=threshold;
        pmb0100rec_para.pointNum=pointNum;
        pmb0100rec_para.col1=c1;
        pmb0100rec_para.col2=c2;
        pmb0100rec_para.row1=r1;
        pmb0100rec_para.row2=r2;
        recFlag=true;
        break;
    }
    if(play_timer->isActive()){
        play_timer->stop();
    }
    play_timer->setInterval(1);
    setPos(beginPos);
    play_timer->start();
}

void TVideoAnalysis::stopRecognize(){
    recFlag=false;
    setPlaySpeed(play_speed);
}

void TVideoAnalysis::setPlaySpeed(double speed){
    play_speed = speed;
    int fps = video_reader->get(cv::CAP_PROP_FPS);
    double itv = 1000/(fps*speed);
    int new_time = itv;
    play_timer->setInterval(new_time);
}

void TVideoAnalysis::play_pause(){
    if(play_timer->isActive()){
        play_timer->stop();
    }
    else{
        play_timer->start();
    }
}

double TVideoAnalysis::getFps(){
   return video_reader->get(cv::CAP_PROP_FPS);
}

QList<int> TVideoAnalysis::getImageSize(){
    QList<int> size;
    size.append(img.size().width);
    size.append(img.size().height);
    return size;
}


QImage TVideoAnalysis::Mat2QImage(cv::Mat const& mat)
{
    cv::Mat temp;
    cv::cvtColor(mat, temp,cv::COLOR_BGR2RGB);
    QImage image((const uchar *) temp.data, temp.cols, temp.rows, temp.step, QImage::Format_RGB888);
    image.bits();
    return image;
}

cv::Mat TVideoAnalysis::QImage2Mat(QImage const& image)
{
    cv::Mat tmp(image.height(),image.width(),CV_8UC3,(uchar*)image.bits(),image.bytesPerLine());
    cv::Mat mat;
    cv::cvtColor(tmp, mat,cv::COLOR_BGR2RGB);
    return mat;
}
