#ifndef TPYCOM_H
#define TPYCOM_H

#undef slots
#include <Python.h>
#define slots Q_SLOTS
#include <QObject>
#include <vector>
#include <string>
#include <opencv2/core.hpp>

class TPyCom: public QObject
{
Q_OBJECT
public:
    explicit TPyCom(QObject *parent = nullptr);
    ~TPyCom();
    int boostTest();
    std::vector<std::string> getFiles(std::string path);
    bool sendEmail(QString content,QString subject = "VTPE project feedback",QString to = "tomaswu@qq.com",QString from = "hurinkazan@qq.com", QString password = "rrkfddrxxwlzbjhh");
    void list2csv(QList<QList<double>> l,QString path);
    QString getNewNameByTime(QString dic,QString tail);
    void data_process(QList<QList<double>> data,QList<QString> header,QList<QList<QString>> para,QList<double> filter, double fps);
    bool showFrequencyImage(cv::Mat mat);
    QString getDirByFilePaht(QString filepath);

signals:


};

#endif // TPYCOM_H
