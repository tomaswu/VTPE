#ifndef TPYCOM_H
#define TPYCOM_H

#undef slots
#include <Python.h>
#define slots

class TPyCom
{
public:
    TPyCom();
    int ComTest();
};

#endif // TPYCOM_H
