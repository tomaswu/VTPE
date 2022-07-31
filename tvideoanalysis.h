#ifndef TVIDEOANALYSIS_H
#define TVIDEOANALYSIS_H

#include <QObject>
#include <opencv2/highgui.hpp>
#include <QImage>
#include <QTimer>
#include <tcamera.h>
#include <string>
#include <vector>
#include <pmb0100rec.h>

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
    double                              play_speed;
    bool                                recFlag=false;
    imgProvider                         *ipdr;
    QTimer                              *play_timer;
    std::string                          testfile="C:\\Users\\Tomas Wu\\Videos\\202203151103光镊演示.mp4";
    pmb0100rec::Para                    pmb0100rec_para;
    std::vector<pmb0100rec::recResult>  recResult;

    //method
    cv::Mat                             QImage2Mat(QImage const& image);
    QImage                              Mat2QImage(cv::Mat const& mat);
    Q_INVOKABLE double                  getFps();
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
    Q_INVOKABLE void                    setPlaySpeed(double speed);
    Q_INVOKABLE void                    play_pause();
    Q_INVOKABLE bool                    isPlaying(){return play_timer->isActive();};
    Q_INVOKABLE void                    startRecognize(int threshold,int pixel,int millimeter,int pointNum=60,int method=0,int c1=0,int c2=640,int r1=0,int r2=480,bool standardUint=false,double raito=1.0);
    Q_INVOKABLE void                    stopRecognize();
    Q_INVOKABLE QList<int>              getImageSize();
    Q_INVOKABLE void                    preThreshold(int threshold);
    Q_INVOKABLE void                    showFrequencyImage(int start,int number,int interval);


    // qml read
    Q_PROPERTY(int pos MEMBER pos NOTIFY posChanged);


signals:
    void imageRefreshed();
    void posChanged();
    void alreadyOpened();
    void recognizedOneFrame(QList<double> rec);
    void finishedRec();
};

#endif // TVIDEOANALYSIS_H
