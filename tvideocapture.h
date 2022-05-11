#ifndef TVIDEOCAPTURE_H
#define TVIDEOCAPTURE_H

#include <QObject>
#include <opencv2/highgui.hpp>
#include <QImage>
#include <QTimer>
#include <QStringList>
#include <string>
#include <vector>
#include <io.h>
#include <fstream>

#ifdef Q_OS_WINDOWS// 华谷动力相机仅支持windows
#include <IMVAPI/IMVApi.h>
#include <IMVAPI/IMVDefines.h>
#include <cameraMessageQue.h>
#endif // 华谷动力相机仅支持windows

enum CameraType{
    cvCam,
    workPowerCam
};

#ifdef Q_OS_WINDOWS// 华谷动力相机仅支持windows
class CFrameInfo //华谷动力相机帧信息
{
public:
    CFrameInfo()
    {
        m_pImageBuf = NULL;
        m_nBufferSize = 0;
        m_nWidth = 0;
        m_nHeight = 0;
        m_ePixelType = gvspPixelMono8;
        m_nPaddingX = 0;
        m_nPaddingY = 0;
        m_nTimeStamp = 0;
    }

    ~CFrameInfo()
    {
    }

public:
    unsigned char*	m_pImageBuf;
    int				m_nBufferSize;
    int				m_nWidth;
    int				m_nHeight;
    IMV_EPixelType	m_ePixelType;
    int				m_nPaddingX;
    int				m_nPaddingY;
    uint64_t		m_nTimeStamp;
};
#endif


class TVideoCapture : public QObject
{
    Q_OBJECT
public:
    explicit TVideoCapture(QObject *parent = nullptr);
    ~TVideoCapture();
    bool                    running_flag = true;
    bool                    needPhoto = false;
    bool                    photoReady = false;
    int                     cvCamNum = 0;  // opencv相机 在Tcamera中刷新列表时同步刷新此数量
    int                     workPowerCamNum = 0; //华谷动力相机 同上
    int                     index = -1; //当前打开的相机序号
    int                     CamType;
    double                  fps = 0;
    int                     fps_count=0;
    clock_t                 t0 = clock(); //for fps calculation start time
    #ifdef Q_OS_WINDOWS
    IMV_HANDLE              m_devHandle; //华谷动力用的 *cap
    TMessageQue<CFrameInfo>  tque;
    #endif
    cv::VideoCapture        *cap;
    cv::Mat                 mat;
    cv::Mat                 photo_mat;
    QStringList             supportedResolution;

    // method
    void                set_indexAndType(int index);
    bool                init(int index);
    bool                isOpened();
    void                capture();
    void                uninit();
    void                stopCapture();
    bool                photo(QString path);
    void                startRecord(QString path);
    void                stopRecord();
    void                openSettings();
    QImage              Mat2QImage(cv::Mat const &mat);
    cv::Mat             QImage2Mat(QImage const &image);
    void                getSupportedResolutions(int index);
    void                setResolution(QString s);
    void                setExposureTime(double millisecond);
    void                getCameraMatrix();
    void                getFiles(std::string path, std::vector<std::string> *files);

signals:
    void stopped();
    void imgReady(QImage img);
    void startCapture();
    void newfps(double fps);
};

#ifdef Q_OS_WINDOWS //华谷动力相机只支持windows 图像处理回调函数
static void onGetFrame(IMV_Frame* pFrame, void* pUser);
#endif //华谷动力相机只支持windows

#endif // TVIDEOCAPTURE_H
