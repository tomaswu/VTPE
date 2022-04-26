#include "commandLineTools.h"
#include <QProcess>
#include <QString>


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
