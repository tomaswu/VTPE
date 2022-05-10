#include <QApplication>
#include <QQmlApplicationEngine>
#include <tcamera.h>
#include <QQmlContext>
#include "pmc0100_com.h"
#include "commandLineTools.h"
#include <QIcon>
#include "tpycom.h"

int main(int argc, char *argv[])
{
    TPyCom com;
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/imgs/ico/Tico.ico"));
//    qmlRegisterType<TCamera>("TCamera",1,0,"TCamera");

    QQmlApplicationEngine engine;
    PMC0100_COM *pmc0100_com = new PMC0100_COM;
    engine.rootContext()->setContextProperty("pmc0100_com",pmc0100_com);
    TCamera *mcap = new TCamera;
    engine.rootContext()->setContextProperty("mcap",mcap);
    commandLineTools* shell = new commandLineTools;
    engine.rootContext()->setContextProperty("shell",shell);
    engine.addImageProvider("cameraImage",mcap->ipdr);
    const QUrl url(u"qrc:/VTPE/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);
    return app.exec();
}
