#ifndef COMMANDLINETOOLS_H
#define COMMANDLINETOOLS_H

#include <QObject>
#include <QProcess>
#include <QString>
#include <tpycom.h>
#include <QThread>

class commandLineTools : public QObject
{
    Q_OBJECT
public:
    explicit commandLineTools(QObject *parent = nullptr);
    ~commandLineTools();
    //member
    QProcess            *p;
    QThread             *thread;
    TPyCom              *tpycom;

    //method
    Q_INVOKABLE void system(QString s);
    Q_INVOKABLE QString getSaveFileName(QString title,QString dir,QString filter);
    Q_INVOKABLE QString getOpenFileName(QString title,QString dir,QString filter);
    Q_INVOKABLE QString getFolderFromFilePath(QString path);
    Q_INVOKABLE QString getExistingFolder(QString title,QString dir);
    Q_INVOKABLE void pyScriptTest(){tpycom->boostTest();};
    Q_INVOKABLE bool feedBackByEmail(QString s);
    Q_INVOKABLE void list2csv(QList<QList<double>> l,QString path,bool standardUnit);
    Q_INVOKABLE QString getNewNameByTime(QString dic,QString tail);
    Q_INVOKABLE void data_process(QList<QList<double>> data,QList<QString> header,QList<QList<QString>> para,QList<double> filter, double fps);
    Q_INVOKABLE bool showFrequencyImage(cv::Mat mat);
    Q_INVOKABLE QString getDirByFilePaht(QString filepath);
    Q_INVOKABLE void openFile(QString file);

signals:

};

extern commandLineTools* shell;//全局变量

#endif // COMMANDLINETOOLS_H
