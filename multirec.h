#ifndef MULTIREC_H
#define MULTIREC_H

#include <QObject>
#include <QThreadPool>
#include <QRunnable>
#include <QList>

#include <pmb0100rec.h>


class RecFun: public QRunnable
{

public:
    RecFun(QObject *p,cv::Mat img,pmb0100rec::Para para,double kr=1);
    ~RecFun();
    cv::Mat img;
    pmb0100rec::Para para;
    double kr;
    QObject *p;
    void run();
};


class MultiRec: public QObject
{
    Q_OBJECT
public:
    MultiRec();

    //member
    QThreadPool                                 *pool;
    QList<pmb0100rec::recResult>                recAnswer;
    int                                         curPos;
    pmb0100rec::recResult                       currentResult;

    //method
    void addMission(cv::Mat img,pmb0100rec::Para para,double kr=1);
    bool getRecResult(int pos,pmb0100rec::recResult &p,bool needEmit=false); // needEmit决定了是否向外发送recOrder
    void onFinishedRec(pmb0100rec::recResult res);


signals:
    void finishedRec(pmb0100rec::recResult res); //线程池中向外返回结果;
    void recOrder(pmb0100rec::recResult res); //按帧顺序向外发送信号,方便播放显示;
};

#endif // MULTIREC_H
