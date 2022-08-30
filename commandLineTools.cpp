#include "commandLineTools.h"
#include <QProcess>
#include <QString>
#include <QFileDialog>
#include <QFileInfo>
#include <iostream>
#include <QDesktopServices>
#include <QUrl>
#include <QMessageBox>

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
    delete tpycom;
    thread->terminate();
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

bool commandLineTools::feedBackByEmail(QString s){
    return tpycom->sendEmail(s);
}

void commandLineTools::list2csv(QList<QList<double>> l,QString path,bool standardUnit){
    tpycom->list2csv(l,path,standardUnit);
}

QString commandLineTools::getExistingFolder(QString title,QString dir){
    auto s = QFileDialog::getExistingDirectory(nullptr,title,dir);
    return s;
}

QString commandLineTools::getNewNameByTime(QString dic,QString tail){
    return tpycom->getNewNameByTime(dic,tail);
}

void commandLineTools::data_process(QList<QList<double>> data,QList<QString> header,QList<QList<QString>> para,QList<double> filter,double fps){
    tpycom->data_process(data,header,para,filter,fps);
}

bool commandLineTools::showFrequencyImage(cv::Mat mat){
    return tpycom->showFrequencyImage(mat);
}

QString commandLineTools::getDirByFilePaht(QString filepath){
    return tpycom->getDirByFilePaht(filepath);
}

void commandLineTools::openFile(QString file){
    QDesktopServices::openUrl(QUrl::fromLocalFile(file));
}

bool commandLineTools::isFile(QString file){
    QFileInfo fileInfo(file);
    if(fileInfo.exists())
    {
        return true;
    }
    return false;
}

bool commandLineTools::confirm_message(QString info,QString title){
    QMessageBox msgBox;
    msgBox.setText(title);
    msgBox.setInformativeText(info);
    msgBox.setStandardButtons(QMessageBox::Ok | QMessageBox::Cancel);
    msgBox.setDefaultButton(QMessageBox::Ok);
    int ret = msgBox.exec();
    if(ret == QMessageBox::Ok){
        return true;
    }
    else{
        return false;
    }
}
