#ifndef TPYCOM_H
#define TPYCOM_H

#undef slots
#include <Python.h>
#define slots Q_SLOTS
#include <QObject>
#include <vector>
#include <string>

class TPyCom: public QObject
{
Q_OBJECT
public:
    explicit TPyCom(QObject *parent = nullptr);
    ~TPyCom();
    int boostTest();
     std::vector<std::string> getFiles(std::string path);

signals:


};

#endif // TPYCOM_H
