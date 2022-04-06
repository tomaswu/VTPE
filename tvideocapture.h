#ifndef TVIDEOCAPTURE_H
#define TVIDEOCAPTURE_H

#include <QObject>
#include <opencv2/highgui.hpp>
#include <QImage>

class TVideoCapture : public QObject
{
    Q_OBJECT
public:
    explicit TVideoCapture(QObject *parent = nullptr);
    ~TVideoCapture();

    bool running_flag = true;

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
    QImage Mat2QImage(cv::Mat const &mat);
    cv::Mat QImage2Mat(QImage const &image);

signals:
    void stopped();
    void imgReady(QImage img);
    void startCapture();
};

#endif // TVIDEOCAPTURE_H
