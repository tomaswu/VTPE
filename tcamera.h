#ifndef TCAMERA_H
#define TCAMERA_H

#include <QObject>
#include <tvideocapture.h>
#include <QtMultimedia/qcameradevice.h>
#include <QtMultimedia/QMediaDevices>
#include <QTimer>
#include <QStringList>
#include <QThread>
#include <QImage>
#include <QPixmap>
#include <QQuickImageProvider>

class imgProvider: public QQuickImageProvider
{
public:
    QImage img;
    imgProvider();
    ~imgProvider();
    QImage requestImage(const QString &id,QSize *size,const QSize &requestexSize);
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
    void setImage(QImage img){this->img=img;};

};

class TCamera : public QObject
{
    Q_OBJECT
public:
    explicit TCamera(QObject *parent = nullptr);
    ~TCamera();
    // member
    imgProvider *ipdr;
    QThread thread;
    TVideoCapture *cap;
    QMediaDevices *uvc_cap;
    QTimer *timer;
    QStringList camera_list;
    QStringList history_list;
    Q_PROPERTY(QStringList cameraList MEMBER camera_list);

    // method
    void getCameraList();
    Q_INVOKABLE bool open(int index);
    Q_INVOKABLE void startCapture(){emit cap->startCapture();};
    Q_INVOKABLE bool isOpened();
    Q_INVOKABLE void release();
    void printCameralist();
    void refreshImage(QImage img);
    void alreadyStopped(){emit stopped();}

signals:
    void cameraListRefreshed();
    void cameraListChanged();
    void imageRefreshed();
    void stopped();

};

#endif // TCAMERA_H
