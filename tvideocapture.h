#ifndef TVIDEOCAPTURE_H
#define TVIDEOCAPTURE_H

#include <QObject>
#include <opencv2/highgui.hpp>
#include <QImage>
#include <QTimer>
#include <QCamera>
#include <QMediaDevices>
#include <QImageCapture>
#include <QVideoWidget>
#include <QVideoSink>
#include <QVideoFrame>
#include <QMediaRecorder>

class TVideoCapture : public QObject
{
    Q_OBJECT
public:
    explicit TVideoCapture(QObject *parent = nullptr);
    ~TVideoCapture();

    //member
    QCamera *camera;
    QImageCapture *imgCap;
    QVideoSink *vsk;
    QTimer *timer;
    QMediaRecorder *recorder;
    int frame_count=0;
    clock_t t0;
    clock_t t1;


    // method

    bool init(const QCameraDevice &index);
    bool isOpened();
    void capture();
    void uninit();
    void stopCapture();
    bool photo(QString path);
    void startRecord(QString path);
    void stopRecord();
    void openSettings();
    QImage Mat2QImage(cv::Mat const &mat);
    cv::Mat QImage2Mat(QImage const &image);

signals:
    void stopped();
    void imgReady(QImage img);
    void startCapture();
};

#endif // TVIDEOCAPTURE_H
