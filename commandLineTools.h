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
    Q_INVOKABLE void pyScriptTest(){tpycom->boostTest();};

signals:

};

extern commandLineTools* shell;//全局变量

#endif // COMMANDLINETOOLS_H
