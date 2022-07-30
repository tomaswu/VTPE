#include "tpycom.h"
#include <iostream>
#include <QtGlobal>
#include <boost/python.hpp>
#include <boost/python/numpy.hpp>
#include <Python.h>

using namespace std;
namespace bpy = boost::python;
namespace np  = boost::python::numpy;

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
    bpy::list lrs;
    lrs.append("nice");
    lrs.append(15);
    int s = bpy::extract<int>(lrs[1]);
    cout<<"list test: ,"<<s<<endl;
    cout<<"finished from c++"<<endl;
    return 0;
}

std::vector<std::string> TPyCom::getFiles(std::string path){
    bpy::object m =bpy::import("os");
    auto p = m.attr("listdir")(path);
    auto a = std::vector<string>(bpy::stl_input_iterator<string>(p),bpy::stl_input_iterator<string>());
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

void TPyCom::list2csv(QList<QList<double>> l,QString path){
    if(!Py_IsInitialized()){
        Py_Initialize();
    }
    bpy::object m = bpy::import("data_process");
    bpy::list li;
    bpy::list row_li;
    for(auto &i : l){
        row_li={};
        for(auto &j : i){
            row_li.append(j);
        }
        li.append(row_li);
    }
    m.attr("list2csv")(li,path.toStdString());
}


QString TPyCom::getNewNameByTime(QString dic,QString tail){
    if(!Py_IsInitialized()){
        Py_Initialize();
    }
    bpy::object m = bpy::import("data_process");
    bpy::object fn = m.attr("getNewNameByTime")(dic.toStdString(),tail.toStdString());
    std::string s = bpy::extract<std::string>(fn);
    return QString::fromStdString(s);
}

void TPyCom::data_process(QList<QList<double>> data,QList<QString> header,QList<QList<QString>> para,QList<double> filter, double fps){
    std::cout<<"hello data process"<<std::endl;
    if(!Py_IsInitialized()){
        Py_Initialize();
    }
    bpy::object m = bpy::import("data_process");
    bpy::list dl,hl,p,ft,tmp;
    ft.append(filter[0]);
    ft.append(filter[1]);
    for(auto &i : data){
        tmp={};
        for(auto &j : i){
            tmp.append(j);
        }
        dl.append(tmp);
    }
    for (auto &i:header){
        hl.append(i.toStdString());
    }
    for(auto &i:para){
        tmp={};
        for(auto &j : i){
            tmp.append(j.toStdString());
        }
        p.append(tmp);
    }
    m.attr("pmb0100_process")(dl,hl,p,ft,fps);
}

void TPyCom::showFrequencyImage(cv::Mat mat){
    cout<<"call python:"<<"mat size: "<<mat.size<<endl;
    if(!Py_IsInitialized()){
        Py_Initialize();
    }
    np::initialize();
    bpy::tuple shape = bpy::make_tuple(mat.rows,mat.cols,3);
    bpy::tuple stride = bpy::make_tuple(mat.cols*3,3,1);
    bpy::object own;
    np::dtype dt = np::dtype::get_builtin<uchar>();
    np::ndarray array = np::from_data(mat.data,dt,shape,stride,own);
    bpy::object m = bpy::import("data_process");
    m.attr("stroboscopic_map")(array);

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
