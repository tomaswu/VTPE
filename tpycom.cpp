#include "tpycom.h"
#include <iostream>
#include <QtGlobal>
#include <boost/python.hpp>
using namespace std;
namespace bpy = boost::python;

TPyCom::TPyCom()
{
    Py_Initialize();
    boostTest();
}
TPyCom::~TPyCom(){
    Py_Finalize();
}

int TPyCom::boostTest(){

    bpy::object m = bpy::import("data_process");
    m.attr("pyHello")();
//    Py_Finalize();
    cout<<"finished"<<endl;
    return 0;
}

// 边写边学，获取返回的string
//    char *bytes = PyBytes_AsString(res);
//    PyObject *str = PyUnicode_AsEncodedString(res, "utf-8", "~E~");
//    cout<<PyBytes_AS_STRING(str)<<endl;


// 一个使用python capi的例子
//int TPyCom::ComTest(){
//    Py_Initialize();
//    if(!Py_IsInitialized())
//    {
//        return -1;
//    }
//    const char * version = Py_GetVersion();
//    cout<<version<<endl;
//    #ifdef Q_OS_OSX
//    PyRun_SimpleString("import sys");
//    PyRun_SimpleString("sys.path.append('./../../../')");
//    #endif
//    PyObject* pModule = PyImport_ImportModule("data_process");
//    if(!pModule)
//    {
//        cout<<"open failure"<<endl;
//        return -1;
//    }
//    PyObject* pFunhello = PyObject_GetAttrString(pModule,"pyHello");
//    if(!pFunhello)
//    {
//        cout<<"get function hello failed"<<endl;
//        return -1;
//    }
//    PyObject_CallFunction(pFunhello, NULL);
//    Py_Finalize();
//    return 0;
//}
