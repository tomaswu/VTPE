#ifndef TVIDEOANALYSIS_H
#define TVIDEOANALYSIS_H

#include <QObject>
#include <opencv2/highgui.hpp>
#include <QImage>
#include <QTimer>
#include <tcamera.h>
#include <string>
#include <vector>

enum _recType{
    PMB0100,
    BOHR,
    NZ
};

class TVideoAnalysis : public QObject
{
    Q_OBJECT
public:
    explicit TVideoAnalysis(QObject *parent = nullptr);
    ~TVideoAnalysis();

    //member
    QString                             videoName;
    int                                 rec_method;
    cv::VideoCapture                    *video_reader;
    cv::Mat                             img;
    int                                 pos;
    int                                 beginPos;
    int                                 endPos;
    imgProvider                         *ipdr;
    QTimer                              *play_timer;
    std::string                          testfile="C:\\Users\\Tomas Wu\\Videos\\202203151103光镊演示.mp4";

    //method
    cv::Mat                             QImage2Mat(QImage const& image);
    QImage                              Mat2QImage(cv::Mat const& mat);
    Q_INVOKABLE int                     getPos();
    Q_INVOKABLE bool                    setPos(int i);
    Q_INVOKABLE int                     getBeginPos();
    Q_INVOKABLE void                    setBeginPos(int i);
    Q_INVOKABLE int                     getEndPos();
    Q_INVOKABLE void                    setEndPos(int i);
    Q_INVOKABLE int                     getFrameCount();
    Q_INVOKABLE void                    open(QString path);
    Q_INVOKABLE bool                    isOpened();
    void                                getFrame();
    void                                setPlaySpeed(double speed);
    Q_INVOKABLE void                    play_pause();

    // qml read
    Q_PROPERTY(int pos MEMBER pos NOTIFY posChanged);


signals:
    void imageRefreshed();
    void posChanged();
    void alreadyOpened();

};

#endif // TVIDEOANALYSIS_H
