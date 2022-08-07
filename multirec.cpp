#include "multirec.h"
#include "qdebug.h"

MultiRec::MultiRec()
{
    pool = QThreadPool::globalInstance();
    qRegisterMetaType<pmb0100rec::recResult>("pmb0100rec::recResult");
    connect(this,&MultiRec::finishedRec,this,&MultiRec::onFinishedRec);
}


void MultiRec::addMission(cv::Mat img,pmb0100rec::Para para,double kr){
    RecFun* f= new RecFun(this,img,para,kr);
    this->pool->start(f);
}

void MultiRec::onFinishedRec(pmb0100rec::recResult r){
//    qDebug()<<"get result"<<r.pos;
    recAnswer.append(r);
    if(r.pos==curPos){
        emit recOrder(r);
        curPos+=1;
        while (getRecResult(curPos,this->currentResult,true)){
            curPos+=1;
        }
    }
}



bool MultiRec::getRecResult(int pos,pmb0100rec::recResult &p,bool needEmit){
    for (int i =0;i<recAnswer.size();i++){
        auto ans = recAnswer[i];
        if(ans.pos==pos){
            p=ans;
            if(needEmit){
                emit recOrder(p);
            }
            return true;
        }
    }
    return false;
}



RecFun::RecFun(QObject *p,cv::Mat img,pmb0100rec::Para para,double kr)
{
    this->setAutoDelete(true);
    this->img=img;
    this->para=para;
    this->kr=kr;
    this->p=p;
}

RecFun::~RecFun(){

}

void RecFun::run(){
    pmb0100rec::recResult res = pmb0100rec::recBall(img,para,kr);
    QMetaObject::invokeMethod(p,"finishedRec",Qt::QueuedConnection,Q_ARG(pmb0100rec::recResult,res));
}
