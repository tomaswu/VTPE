#include "tpycom.h"
#include <iostream>
#include <QtGlobal>
#include <boost/python.hpp>
#include <Python.h>

using namespace std;
namespace bpy = boost::python;

TPyCom::TPyCom(QObject *parent):
    QObject{parent}
{
    if(!Py_IsInitialized()){
    Py_Initialize();
    }
    #ifdef Q_OS_OSX
    PyRun_SimpleString("import sys");
    PyRun_SimpleString("sys.path.append('./../../../')");
    #endif
}

TPyCom::~TPyCom(){

}

int TPyCom::boostTest(){
    if(!Py_IsInitialized()){
        Py_Initialize();
    }
    bpy::object m = bpy::import("data_process");
    m.attr("pyHello")();
    cout<<"finished from c++"<<endl;
    return 0;
}

std::vector<std::string> TPyCom::getFiles(std::string path){
    bpy::object m =bpy::import("os");
    auto p = m.attr("listdir")(path);
    auto a = std::vector<string>(boost::python::stl_input_iterator<string>(p),boost::python::stl_input_iterator<string>());
    for (int i=0;i<(int)a.size();i++){
        a[i]=path+"/"+a[i];
    }
    return a;
}

bool TPyCom::sendEmail(QString content,QString subject,QString to,QString from, QString password){
    bool ret = false;
    if(!Py_IsInitialized()){
        Py_Initialize();
    }
    bpy::object m = bpy::import("temail");
    bpy::object email = m.attr("Mail")();
    email.attr("sender") = from.toStdString();
    email.attr("mail_pass") = password.toStdString();
    bpy::list recvs;
    recvs.append(to.toStdString());
    email.attr("receivers") = recvs;
    bpy::object r = email.attr("send")(content.toStdString(),subject.toStdString());
    ret = bpy::extract<bool>(r);
    return ret;
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
