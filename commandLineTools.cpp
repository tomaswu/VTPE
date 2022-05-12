#include "commandLineTools.h"
#include <QProcess>
#include <QString>
#include <QFileDialog>
#include <QFileInfo>
#include <iostream>

commandLineTools* shell = new commandLineTools; //全局变量

commandLineTools::commandLineTools(QObject *parent)
    : QObject{parent}
{
    p = new QProcess;
    tpycom = new TPyCom;
    thread = new QThread;
    tpycom->moveToThread(thread);
    thread->start();
}

commandLineTools::~commandLineTools(){
    delete p;
    thread->terminate();
    delete tpycom;
    delete thread;
}

void commandLineTools::system(QString s){
    p->startCommand(s);
}

QString commandLineTools::getSaveFileName(QString title,QString dir,QString filter){
    auto s  = QFileDialog::getSaveFileName(nullptr,title,dir,filter);
    return s;
}

QString commandLineTools::getOpenFileName(QString title,QString dir,QString filter){
    auto s = QFileDialog::getOpenFileName(nullptr,title,dir,filter);
    return s;
}

QString commandLineTools::getFolderFromFilePath(QString path){
    QFileInfo f(path);
    return f.dir().absolutePath();
}
