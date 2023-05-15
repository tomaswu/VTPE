#include "pmc0100_com.h"
#include <QThread>
#include <QTimer>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QList>
#include <QString>
#include <QStringList>
#include <qdebug.h>

PMC0100_COM::PMC0100_COM(QObject *parent)
    : QObject{parent}
{
    th = new QThread;
    com = new QSerialPort;
    com->setBaudRate(QSerialPort::Baud115200);
    th = new QThread;
    timer = new QTimer;
    timer->setInterval(40);
    connect(timer,&QTimer::timeout,this,&PMC0100_COM::read);
}

PMC0100_COM::~PMC0100_COM(){
    delete com;
    delete  timer;
    delete th;
}


bool PMC0100_COM::start(int index){
    QSerialPortInfo sp;
    auto clist = sp.availablePorts();
    QString portName = clist[index].portName();
    com->setPortName(portName);
    com->open(QSerialPort::ReadOnly);
    timer->start();
    return true;
}

bool PMC0100_COM::stop(){
    timer->stop();
    com->close();
    return true;
}

void PMC0100_COM::read(){
    com->waitForReadyRead(5);
    auto s = com->readAll();
    com->waitForReadyRead(5);
    if(s.size()==0)return;
    QString value;
    for (int i = 0;i<s.length();i++){
        value.append(s[i]);
        if (s[i]==0x0a){
            emit newValueReady(value.toInt());
            value.clear();
        }
    }
}

QStringList PMC0100_COM::enumDevice(){
    QSerialPortInfo sp;
    auto clist = sp.availablePorts();
    QStringList res;
    for (auto &i: clist){
        res.append(i.portName());
    }
    return res;
}
