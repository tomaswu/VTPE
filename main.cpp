#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <tcamera.h>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
//    qmlRegisterType<TCamera>("TCamera",1,0,"TCamera");
    QQmlApplicationEngine engine;
    TCamera *mcap = new TCamera;
    engine.rootContext()->setContextProperty("mcap",mcap);
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
