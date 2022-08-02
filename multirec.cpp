#include "multirec.h"
#include "qdebug.h"

MultiRec::MultiRec()
{
    pool = QThreadPool::globalInstance();
    qRegisterMetaType<pmb0100rec::recResult>("pmb0100rec::recResult");
}


void MultiRec::addMission(cv::Mat img,pmb0100rec::Para para,double kr){
    RecFun* f= new RecFun(this,img,para,kr);
    this->pool->start(f);
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
