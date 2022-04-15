#ifndef TVIDEOCAPTURE_H
#define TVIDEOCAPTURE_H

#include <QObject>
#include <opencv2/highgui.hpp>
#include <QImage>
#include <QTimer>
#include <QStringList>

class TVideoCapture : public QObject
{
    Q_OBJECT
public:
    explicit TVideoCapture(QObject *parent = nullptr);
    ~TVideoCapture();

    bool running_flag = true;
    double fps = 0;
    int fps_count=0;
    QStringList supportedResolution;

    // method
    cv::VideoCapture *cap;
    cv::Mat mat;
    bool init(int index);
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
    void getSupportedResolutions(int index);
    void setResolution(QString s);

signals:
    void stopped();
    void imgReady(QImage img);
    void startCapture();
};

#endif // TVIDEOCAPTURE_H
