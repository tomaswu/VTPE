#include "tvideoanalysis.h"
#include <string>
#include <vector>
#include <iostream>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <tcamera.h>
#include <pmb0100rec.h>
#include <commandLineTools.h>


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
    bool ret;
    video_reader->set(cv::CAP_PROP_POS_FRAMES,i);
    this->getFrame();
    ret = video_reader->set(cv::CAP_PROP_POS_FRAMES,i);
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
    if(recFlag){
        pmb0100rec_para.pos=this->pos;
        pmb0100rec::recResult r = pmb0100rec::recBall(img,pmb0100rec_para);
        QList<double> res;
        res.append(pos);
        recResult.push_back(r);
        for(auto &i:r.data){
            if(pmb0100rec_para.standardUint){
                res.append(i.x*pmb0100rec_para.ratio);
                res.append(i.y*pmb0100rec_para.ratio);
            }
            else{
                res.append(i.x);
                res.append(i.y);
            }
            if(i.x>0&&i.y>0&&i.z>0){
                cv::circle(img,cv::Point(i.x,i.y),i.z,cv::Scalar(0,255,0),img.size().width/640);
            }
        }
        emit recognizedOneFrame(res);
    }
    ipdr->img = Mat2QImage(img);
    emit imageRefreshed();
    getPos();
    if(pos==endPos){
        setPos(beginPos);
        if(recFlag){
            recFlag=false;
            play_timer->stop();
            emit finishedRec();
        }
    }
}

void TVideoAnalysis::preThreshold(int threshold){
    if(play_timer->isActive()){
        this->play_pause();
    }
    cv::Mat img = pmb0100rec::preThreshold(this->img,threshold);
    ipdr->img = Mat2QImage(img);
    emit imageRefreshed();
}

void TVideoAnalysis::startRecognize(int threshold,int pixel,int millimeter,int pointNum,int method,int c1,int c2,int r1,int r2,bool standardUint,double ratio){
    switch(method){
    case 0:
        pmb0100rec_para.threshold=threshold;
        pmb0100rec_para.pointNum=pointNum;
        pmb0100rec_para.col1=c1;
        pmb0100rec_para.col2=c2;
        pmb0100rec_para.row1=r1;
        pmb0100rec_para.row2=r2;
        pmb0100rec_para.standardUint = standardUint;
        pmb0100rec_para.ratio = ratio;
        this->recResult.clear();
        break;
    }
    if(play_timer->isActive()){
        play_timer->stop();
    }
    play_timer->setInterval(1);
    setPos(beginPos);
    recFlag=true;
    play_timer->start();
}

void TVideoAnalysis::stopRecognize(){
    if(play_timer->isActive()){
        play_timer->stop();
    }
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


void TVideoAnalysis::showFrequencyImage(int start,int number,int interval){
    qDebug()<<"频闪图测试";
    uint i;
    for (i=0;i<recResult.size();i++){
        if(recResult[i].pos==start){
            break;
        }
    }
    if(i==recResult.size()){
        qDebug()<<"错误的参数";
        return;
    }
    else{
        int count=0;
        cv::Mat stro;
        for(uint j=i;j<recResult.size();j+=interval){
            int n=recResult[j].pos;
            this->setPos(n);
            cv::Mat fimg,mask;
            video_reader->read(fimg);
            if(stro.empty()){
                fimg.copyTo(stro);
                continue;
            }
            mask=cv::Mat::zeros(fimg.size(),CV_8UC1);
            cv::circle(mask,cv::Point(recResult[j].data[0].x,recResult[j].data[0].y),recResult[j].data[0].z,cv::Scalar(255),-1);
            fimg.copyTo(stro,mask);

            count+=1;
            if(count>=number){
                break;
            }
        }
        shell->showFrequencyImage(stro);
    }

//    shell->showFrequencyImage(QImage2Mat(ipdr->img));
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
