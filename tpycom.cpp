#include "tpycom.h"
#include <iostream>

using namespace std;

TPyCom::TPyCom()
{
    ComTest();

}

int TPyCom::ComTest(){


    Py_Initialize();
    if(!Py_IsInitialized())
    {
        return -1;
    }
    PyObject* pModule = PyImport_ImportModule("data_process");
    if(!pModule)
    {
        cout<<"open failure"<<endl;
        return -1;
    }
    PyObject* pFunhello = PyObject_GetAttrString(pModule,"pyHello");
    if(!pFunhello)
    {
        cout<<"get function hello failed"<<endl;
        return -1;
    }
    PyObject_CallFunction(pFunhello, NULL);
    Py_Finalize();

    return 0;

}
