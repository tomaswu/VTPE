#ifndef MULTIREC_H
#define MULTIREC_H

#include <QObject>
#include <QThreadPool>
#include <QRunnable>

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
    QThreadPool *pool;
    void addMission(cv::Mat img,pmb0100rec::Para para,double kr=1);

signals:
    void finishedRec(pmb0100rec::recResult res);
};

#endif // MULTIREC_H
