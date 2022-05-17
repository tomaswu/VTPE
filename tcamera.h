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
#include <QVariantList>

class imgProvider: public QQuickImageProvider
{
public:
    QImage img;
    imgProvider();
    ~imgProvider();
    QImage requestImage(const QString &id,QSize *size,const QSize &requestexSize);
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
    void setImage(QImage img);
};

class TCamera : public QObject
{
    Q_OBJECT
public:
    explicit TCamera(QObject *parent = nullptr);
    ~TCamera();
    // member
    imgProvider                             *ipdr;
    QThread                                 thread;
    TVideoCapture                           *cap;
    QMediaDevices                           *uvc_cap;
    QTimer                                  *timer;
    QTimer                                  *timer_refresh;
    QStringList                             camera_list;
    QStringList                             history_list;
    double                                  fps = 0;
    bool                                    opened = false;
    bool                                    time_to_refresh = true;

    Q_PROPERTY(QStringList cameraList MEMBER camera_list NOTIFY cameraListChanged);
    Q_PROPERTY(double fps MEMBER fps NOTIFY fpsChanged);
    Q_PROPERTY(bool opened MEMBER opened NOTIFY openedChanged);

    // method
    void getCameraList();
    Q_INVOKABLE bool                open(int index);
    Q_INVOKABLE void                startCapture(){emit cap->startCapture();};
    Q_INVOKABLE bool                isOpened();
    Q_INVOKABLE void                release();
    Q_INVOKABLE QStringList         getSupportedResolutions();
    Q_INVOKABLE void                needPhoto(){cap->needPhoto=true;};
    Q_INVOKABLE bool                savePhoto(QString path){return cap->photo(path);};
    Q_INVOKABLE QVariantList        calSelectScale(double row1,double row2, double col1, double col2);
    Q_INVOKABLE int                 getCameraType();
    void                            printCameralist();
    void                            refreshImage(QImage img);
    void                            alreadyStopped(){emit stopped();}
    void                            setTimerFresh(){time_to_refresh=true;};
    void                            refreshFps(double f);
    Q_INVOKABLE void                setCaliFlag(bool flag);

    // 相机设置函数
    Q_INVOKABLE void                openSettings(){cap->openSettings();};
    Q_INVOKABLE void                setResolution(QString s){cap->setResolution(s);};
    Q_INVOKABLE bool                setExposureTime(double minisecond){return cap->setExposureTime(minisecond);}; //曝光时间
    Q_INVOKABLE bool                setGain(double dGainRaw){return cap->setAdjustPluse(dGainRaw);}; //增益
    Q_INVOKABLE bool                setGamma(double gamma){return cap->setGamma(gamma);}; //gamma


signals:
    void cameraListRefreshed();
    void cameraListChanged();
    void imageRefreshed();
    void stopped();
    void fpsChanged();
    void openedChanged();
};

#endif // TCAMERA_H
