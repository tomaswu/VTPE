#include <QApplication>
#include <QQmlApplicationEngine>
#include <tcamera.h>
#include <QQmlContext>
#include "pmc0100_com.h"
#include "commandLineTools.h"
#include <QIcon>
#include "tpycom.h"
#include <iostream>
#include <Python.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

//    qmlRegisterType<TCamera>("TCamera",1,0,"TCamera");

    QQmlApplicationEngine engine;
    PMC0100_COM *pmc0100_com = new PMC0100_COM;
    engine.rootContext()->setContextProperty("pmc0100_com",pmc0100_com);
    TCamera *mcap = new TCamera();
    engine.rootContext()->setContextProperty("mcap",mcap);
    engine.rootContext()->setContextProperty("shell",shell);
    engine.addImageProvider("cameraImage",mcap->ipdr);
    const QUrl url(u"qrc:/VTPE/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);
    app.setWindowIcon(QIcon(":/imgs/ico/Tico.ico"));
    int app_ret = app.exec();

    //资源释放,结束python解释器
    if(Py_IsInitialized()){
        Py_Finalize();
        Py_Exit(0);
    }

    delete shell; //全局指针变量，可以控制释放顺序,在mac下，如果不py_exit则无法结束线程
    delete mcap; //不知道为什么在释放时还会被qml读取一些变量,导致程序崩溃，py_exit后也没这个问题了
    delete pmc0100_com;

    return app_ret;
}
