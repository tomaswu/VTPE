#ifndef TVIDEOANALYSIS_H
#define TVIDEOANALYSIS_H

#include <QObject>
#include <opencv2/highgui.hpp>
#include <QImage>
#include <QTimer>
#include <tcamera.h>

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
    int                                 pos;
    int                                 beginPos;
    int                                 endPos;
    imgProvider                         *ipdr;

    //method
    Q_INVOKABLE int  getPos();
    Q_INVOKABLE bool setPos();
    Q_INVOKABLE int  getBeginPos();
    Q_INVOKABLE bool setBeginPos();
    Q_INVOKABLE int  getEndPos();
    Q_INVOKABLE bool setEndPos();
    Q_INVOKABLE int  getFrameCount();

signals:
    void imageRefreshed();

};

#endif // TVIDEOANALYSIS_H
