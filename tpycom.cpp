#include "tpycom.h"
#include <iostream>
#include <QtGlobal>
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
    const char * version = Py_GetVersion();
    cout<<version<<endl;
    #ifdef Q_OS_OSX
    PyRun_SimpleString("import sys");
    PyRun_SimpleString("sys.path.append('./../../../')");
    #endif
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

// 边写边学，获取返回的string
//    char *bytes = PyBytes_AsString(res);
//    PyObject *str = PyUnicode_AsEncodedString(res, "utf-8", "~E~");
//    cout<<PyBytes_AS_STRING(str)<<endl;
