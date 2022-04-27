#include "commandLineTools.h"
#include <QProcess>
#include <QString>
#include <QFileDialog>


commandLineTools::commandLineTools(QObject *parent)
    : QObject{parent}
{
    p = new QProcess;
}

commandLineTools::~commandLineTools(){
    delete p;
}

void commandLineTools::system(QString s){
    p->startCommand(s);
}

QString commandLineTools::getSaveFileName(QString title,QString dir,QString filter){
    auto s  = QFileDialog::getSaveFileName(nullptr,title,dir,filter);
    return s;
}
