#ifndef TVIDEOCAPTURE_H
#define TVIDEOCAPTURE_H

#include <QObject>
#include <opencv2/highgui.hpp>
#include <QImage>
#include <QTimer>
#include <QStringList>
#include <string>
#include <vector>
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
    clock_t                 t_show = clock(); //用来判断是否到时间显示了
    #ifdef Q_OS_WINDOWS
    IMV_HANDLE              m_devHandle; //华谷动力用的 *cap
    TMessageQue<CFrameInfo> tque;
    #endif
    cv::VideoCapture        *cap;
    cv::VideoWriter         outputVideo;
    bool                    record_flag = false;
    cv::Mat                 mat;
    cv::Mat                 correctedMat;
    cv::Mat                 photo_mat;
    QStringList             supportedResolution;
    bool                    cali_flag=false;
    cv::Matx33d             intrinsics_matrix;
    cv::Vec4d               distortion_coeff;
    cv::Mat                 mapx;
    cv::Mat                 mapy;
    cv::Size2i              correctSize;

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
    void                getCameraMatrix();
    void                getFiles(std::string path, std::vector<std::string> *files);
    bool                readCameraMatrix(cv::Matx33d &K, cv::Vec4d &D);
    bool                initUndistort(cv::MatSize size);
    cv::Size            getCurrentResolution();
    //相机设置
    void                setResolution(QString s);
    bool                setExposureTime(double minisecond); //曝光时间
    bool                setAdjustPluse(double dGainRaw); //增益
    bool                setGamma(double gamma); //gamma
    bool                setFps(double fps); //手动设置帧率
    bool                setFpsEnabled(bool e); //手动帧率
    bool                setAutoExposure(int e); //自动曝光
    bool                setBrightness(int b); //亮度
    bool                setDigtalShift(int shift); //数字位移
    bool                setAcuityEnabled(bool e); //启用锐度
    bool                setAcuity(int acuity); //锐度
    bool                setDenoiseEnabled(bool e);//启用降噪
    bool                setDenoise(int denoise); // 降噪
    bool                setAutoBalance(int e); //自动白平衡
    bool                setBalanceR(double r);
    bool                setBalanceG(double g);
    bool                setBalanceB(double b);

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
