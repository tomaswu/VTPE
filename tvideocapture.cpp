#include "tvideocapture.h"
#include <QObject>
#include <qdebug.h>
#include <QImage>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgproc/types_c.h>
#include <QSysInfo>
#include <QMediaDevices>
#include <QCameraDevice>
#include <QString>
#include "qdebug.h"
#include <QSize>
#include <QUrl>
#include <IMVAPI/IMVApi.h>
#include <IMVAPI/IMVDefines.h>

TVideoCapture::TVideoCapture(QObject *parent)
    : QObject{parent}
{
    cap = new cv::VideoCapture;
    connect(this,&TVideoCapture::startCapture,this,&TVideoCapture::capture);
}

TVideoCapture::~TVideoCapture(){
    delete cap;
}

bool TVideoCapture::init(int index){
    bool ret=false;
    set_indexAndType(index);
    switch (this->CamType){
        case cvCam:
            getSupportedResolutions(this->index);
            if (QSysInfo::productType()=="windows"){
                ret = cap->open(this->index,cv::CAP_DSHOW);
            }
            else{
                ret = cap->open(this->index);
            }
            break;
        case workPowerCam:
            IMV_DeviceList p;
            IMV_EnumDevices(&p,IMV_EInterfaceType::interfaceTypeUsb3);
            char* key = p.pDevInfo[this->index].cameraKey;
            int res = IMV_CreateHandle(&m_devHandle,modeByCameraKey,key);
            if (res==IMV_OK){
                res = IMV_Open(m_devHandle);
                if(res==IMV_OK){
                    ret=true;
                }
            }
            break;
    }
    return ret;
}

void TVideoCapture::uninit(){
    switch (this->CamType){
        case cvCam:
            running_flag=false;
            break;
        case workPowerCam:
            running_flag=false;
            IMV_StopGrabbing(this->m_devHandle);
            IMV_Close(this->m_devHandle);
            m_devHandle = NULL;
            break;
    }
}

void TVideoCapture::set_indexAndType(int index){
    if (index<cvCamNum){
        this->index=index;
        this->CamType = cvCam;
    }
    else if(index>=cvCamNum && index<cvCamNum+workPowerCamNum){
        this->index=index-cvCamNum;
        this->CamType=workPowerCam;
    }
}

void TVideoCapture::capture(){
    switch (this->CamType){
        case cvCam:
            if (cap->isOpened()){
               fps_count=0;
               clock_t t0=clock();
               clock_t t1;
               while (running_flag)
               {
                   bool ret = cap->read(mat);
                   if (ret){
                      if (needPhoto){
                          photo_mat = mat;
                          needPhoto = false;
                          photoReady = true;
                      }
                      auto tmp=Mat2QImage(mat);
                      fps_count+=1;
                      emit imgReady(tmp);
                   }
                   if (fps_count==100){
                       t1=clock();
            #ifdef Q_OS_MACOS
                       fps = 100000000/(t1-t0);
            #elif defined Q_OS_WIN32
                       fps = 100000/(t1-t0);
            #endif
                       emit newfps(fps);
            //               qDebug()<<"camera fps:"<<fps; //打印一下帧率
                       t0=t1;
                       fps_count=0;
                   }

               }
               cap->release();
               running_flag=true;
               emit stopped();
            }
            break;
        case workPowerCam:
            int ret;
            ret = IMV_AttachGrabbing(this->m_devHandle,onGetFrame,this);
            if(ret==IMV_OK){
                IMV_StartGrabbing(this->m_devHandle);
                CFrameInfo frameInfo;
                QImage image;
                while(running_flag){
                    cv::waitKey(30);
                    this->tque.get(frameInfo);
                    if (gvspPixelMono8 == frameInfo.m_ePixelType){
                        image = QImage(frameInfo.m_pImageBuf, (int)frameInfo.m_nWidth, (int)frameInfo.m_nHeight, QImage::Format_Grayscale8);
                        emit imgReady(image);
                    }
                    else
                    {
                        // 转码
                        unsigned char* pRGBbuffer = NULL;
                        int nRgbBufferSize = 0;
                        nRgbBufferSize = frameInfo.m_nWidth * frameInfo.m_nHeight * 3;
                        pRGBbuffer = (unsigned char*)malloc(nRgbBufferSize);
                        if (pRGBbuffer == NULL)
                        {
                            // 释放内存
                            // release memory
                            free(frameInfo.m_pImageBuf);
                            printf("RGBbuffer malloc failed.\n");
                            continue;
                        }
                        IMV_PixelConvertParam stPixelConvertParam;
                        stPixelConvertParam.nWidth = frameInfo.m_nWidth;
                        stPixelConvertParam.nHeight = frameInfo.m_nHeight;
                        stPixelConvertParam.ePixelFormat = frameInfo.m_ePixelType;
                        stPixelConvertParam.pSrcData = frameInfo.m_pImageBuf;
                        stPixelConvertParam.nSrcDataLen = frameInfo.m_nBufferSize;
                        stPixelConvertParam.nPaddingX = frameInfo.m_nPaddingX;
                        stPixelConvertParam.nPaddingY = frameInfo.m_nPaddingY;
                        stPixelConvertParam.eBayerDemosaic = demosaicNearestNeighbor;
                        stPixelConvertParam.eDstPixelFormat = gvspPixelRGB8;
                        stPixelConvertParam.pDstBuf = pRGBbuffer;
                        stPixelConvertParam.nDstBufSize = nRgbBufferSize;
                        int ret = IMV_PixelConvert(m_devHandle, &stPixelConvertParam);
                        if (IMV_OK != ret)
                        {
                            // 释放内存
                            // release memory
                            printf("image convert to RGB failed! ErrorCode[%d]\n", ret);
                            free(frameInfo.m_pImageBuf);
                            free(pRGBbuffer);
                            continue;
                        }
                        free(frameInfo.m_pImageBuf);
                        image=QImage(pRGBbuffer, (int)stPixelConvertParam.nWidth, (int)stPixelConvertParam.nHeight,QImage::Format_RGB888);
                        emit imgReady(image);
                    }// end else
                } //end while
            }// end if
            this->running_flag=true;
            emit stopped();
            break;
    }//end switch
    QImage emptyImg;
    emit imgReady(emptyImg);
}

void TVideoCapture::getSupportedResolutions(int index){
    QMediaDevices mds;
    QString s;
    QList<QCameraDevice> rlist = mds.videoInputs();
    supportedResolution.clear();
    auto c = rlist[index];
    auto resolutions = c.photoResolutions();
    for (auto &c : resolutions){
        s="%1X%2";
        s=s.arg(c.width()).arg(c.height());
        if (!supportedResolution.contains(s)){
            supportedResolution.append(s);
        }
    }
}


void TVideoCapture::setResolution(QString s){
    auto r = s.split("X");
    int width = r[0].toInt();
    int height = r[1].toInt();
    cap->set(cv::CAP_PROP_FRAME_WIDTH,width);
    cap->set(cv::CAP_PROP_FRAME_HEIGHT,height);
}


void TVideoCapture::stopCapture(){

}

void TVideoCapture::startRecord(QString path){
    qDebug()<<"qdebug:"<<path;
}

void TVideoCapture::stopRecord(){

}

bool TVideoCapture::isOpened(){
    switch (this->CamType){
        case cvCam:
            return cap->isOpened();
        case workPowerCam:
            return IMV_IsOpen(this->m_devHandle);
        default:
            return false;
    }
}

void TVideoCapture::openSettings(){
    cap->set(cv::CAP_PROP_SETTINGS,0);
}

bool TVideoCapture::photo(QString path){
    QImage img = Mat2QImage(photo_mat);
    QUrl s(path);
    bool ret = img.save(s.toLocalFile());
    photoReady=false;
    return ret;
}


QImage TVideoCapture::Mat2QImage(cv::Mat const& mat)
{
    cv::Mat temp;
    cv::cvtColor(mat, temp,CV_BGR2RGB);
    QImage image((const uchar *) temp.data, temp.cols, temp.rows, temp.step, QImage::Format_RGB888);
    image.bits();
    return image;
}

cv::Mat TVideoCapture::QImage2Mat(QImage const& image)
{
    cv::Mat tmp(image.height(),image.width(),CV_8UC3,(uchar*)image.bits(),image.bytesPerLine());
    cv::Mat mat;
    cv::cvtColor(tmp, mat,CV_BGR2RGB);
    return mat;
}

//work power camera callback function for grabbing
// Data frame callback function
static void onGetFrame(IMV_Frame* pFrame, void* pUser)
{
    TVideoCapture* tvd = (TVideoCapture*)pUser;
    if (pFrame == NULL)
    {
        printf("pFrame is NULL\n");
        return;
    }

//    printf("Get frame blockId = %llu\n", pFrame->frameInfo.blockId);
    CFrameInfo frameInfo;
    frameInfo.m_nWidth = (int)pFrame->frameInfo.width;
    frameInfo.m_nHeight = (int)pFrame->frameInfo.height;
    frameInfo.m_nBufferSize = (int)pFrame->frameInfo.size;
    frameInfo.m_nPaddingX = (int)pFrame->frameInfo.paddingX;
    frameInfo.m_nPaddingY = (int)pFrame->frameInfo.paddingY;
    frameInfo.m_ePixelType = pFrame->frameInfo.pixelFormat;
    frameInfo.m_pImageBuf = (unsigned char *)malloc(sizeof(unsigned char) * frameInfo.m_nBufferSize);
    frameInfo.m_nTimeStamp = pFrame->frameInfo.timeStamp;
    memcpy(frameInfo.m_pImageBuf, pFrame->pData, frameInfo.m_nBufferSize);
    tvd->tque.push_back(frameInfo);
    if (tvd->tque.size() > 16)
    {
        CFrameInfo frameOld;
        if (tvd->tque.get(frameOld))
        {
            free(frameOld.m_pImageBuf);
            frameOld.m_pImageBuf = NULL;
        }
    }

    return;
}
