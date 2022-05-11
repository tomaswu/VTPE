#ifndef TPYCOM_H
#define TPYCOM_H

#undef slots
#include <Python.h>
#define slots Q_SLOTS

class TPyCom
{
public:
    TPyCom();
    ~TPyCom();
    int boostTest();
};

#endif // TPYCOM_H
