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
#include <opencv2/calib3d.hpp>
#include <opencv2/core.hpp>
#include <opencv2/opencv.hpp>
#include <vector>
#include <string>
#include <commandLineTools.h>
#include <fstream>

#ifdef Q_OS_WINDOWS
#include <IMVAPI/IMVApi.h>
#include <IMVAPI/IMVDefines.h>
#include "windows.h"
#endif

TVideoCapture::TVideoCapture(QObject *parent)
    : QObject{parent}
{
    cap = new cv::VideoCapture;
    connect(this,&TVideoCapture::startCapture,this,&TVideoCapture::capture);
    readCameraMatrix(intrinsics_matrix,distortion_coeff);

}

TVideoCapture::~TVideoCapture(){
    delete cap;
}

bool TVideoCapture::init(int index){
    bool ret=false;
    set_indexAndType(index);
    getSupportedResolutions(this->index);
    switch (this->CamType){
        case cvCam:     
            if (QSysInfo::productType()=="windows"){
                ret = cap->open(this->index,cv::CAP_DSHOW);
            }
            else{
                ret = cap->open(this->index);
            }
            break;
        #ifdef Q_OS_WINDOWS //华谷动力相机只支持windows
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
         #endif //华谷动力相机只支持windows
    }
    return ret;
}

void TVideoCapture::uninit(){
    switch (this->CamType){
        case cvCam:
            running_flag=false;
            break;
        #ifdef Q_OS_WINDOWS //华谷动力相机只支持windows
        case workPowerCam:
            running_flag=false;
            IMV_StopGrabbing(this->m_devHandle);
            IMV_Close(this->m_devHandle);
            m_devHandle = NULL;
            break;
        #endif //华谷动力相机只支持windows
    }
}

void TVideoCapture::set_indexAndType(int index){
    if (index<cvCamNum){
        this->index=index;
        this->CamType = cvCam;
    }
    #ifdef Q_OS_WINDOWS //华谷动力相机只支持windows
    else if(index>=cvCamNum && index<cvCamNum+workPowerCamNum){
        this->index=index-cvCamNum;
        this->CamType=workPowerCam;
    }
    #endif//华谷动力相机只支持windows
}

void TVideoCapture::capture(){
    clock_t showtime;
    bool time2show;
    switch (this->CamType){
        case cvCam:
            if (cap->isOpened()){
               fps_count=0;
               t0=clock();
               clock_t t1;
               QImage tmp;
               while (running_flag)
               {
                   bool ret = cap->read(mat);
                   if (ret){
                      if(this->record_flag){
                          this->outputVideo.write(mat);
                      }
                      showtime = clock();
                      #ifdef Q_OS_MACOS
                      time2show = (40000<(showtime-this->t_show));
                      #elif defined Q_OS_WINDOWS
                      time2show = (40<(showtime-this->t_show));
                      #endif
                      if(time2show){
                          this->t_show = showtime;
                          if (cali_flag){
                              if(correctSize.width!=mat.size[1] || correctSize.height!=mat.size[0]){
                                  initUndistort(mat.size);
                              }
                              cv::remap(mat, correctedMat, mapx, mapy, cv::INTER_LINEAR, cv::BORDER_DEFAULT);
                              if(needPhoto){
                                  photo_mat = correctedMat;
                                  needPhoto = false;
                                  photoReady = true;
                              }
                              tmp=Mat2QImage(correctedMat);
                          }else{
                              if(needPhoto){
                                  photo_mat = mat;
                                  needPhoto = false;
                                  photoReady = true;
                              }
                              tmp=Mat2QImage(mat);
                          } // end cali_falg
                          emit imgReady(tmp);
                      }
                      fps_count+=1;
                   }
                   if (fps_count==100){
                       t1=clock();
            #ifdef Q_OS_MACOS
                       fps = 100000000/(t1-t0);
            #elif defined Q_OS_WINDOWS
                       fps = 100000/(t1-t0);
            #endif
                       emit newfps(fps);
                       if(record_flag){
                           emit rfpsChanged(fps);
                       }
                       t0=t1;
                       fps_count=0;
                   }
               }
               cap->release();
               running_flag=true;
               emit stopped();
            }
            break;
        #ifdef Q_OS_WINDOWS //华谷动力相机只支持windows
        case workPowerCam:
            int ret;
            ret = IMV_AttachGrabbing(this->m_devHandle,onGetFrame,this);
            cv::Mat tmp;
            if(ret==IMV_OK){
                IMV_StartGrabbing(this->m_devHandle);
                CFrameInfo frameInfo;
                QImage image;
                while(running_flag){
                    if(tque.size()==0){
                        continue;
                    }      
                    showtime = clock();
                    time2show = (40<(showtime-this->t_show));

                    if(time2show){
                        this->t_show=showtime;
                        this->tque.get(frameInfo);
                        if (gvspPixelMono8 == frameInfo.m_ePixelType){ //黑白相机暂不支持拍照和校正等功能，没有黑白相机验证。
                            image = QImage(frameInfo.m_pImageBuf, (int)frameInfo.m_nWidth, (int)frameInfo.m_nHeight, QImage::Format_Grayscale8);
                            tmp = QImage2Mat(image);
                            tmp.copyTo(mat);
                            tmp.release();
                            free(image.bits());
                            emit imgReady(Mat2QImage(mat));
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
                            if(cali_flag){
                                tmp = QImage2Mat(image);
                                tmp.copyTo(mat);
                                tmp.release();
                                free(image.bits());
                                if(correctSize.width!=mat.size[1] || correctSize.height!=mat.size[0]){
                                    initUndistort(mat.size);
                                }
                                cv::remap(mat, correctedMat, mapx, mapy, cv::INTER_LINEAR, cv::BORDER_DEFAULT);
                                if(needPhoto){
                                    photo_mat = correctedMat;
                                    needPhoto = false;
                                    photoReady = true;
                                }
                                emit imgReady(Mat2QImage(correctedMat));

                            }
                            else{
                                tmp = QImage2Mat(image);
                                tmp.copyTo(mat);
                                tmp.release();
                                free(image.bits());
                                if(needPhoto){
                                    photo_mat = mat;
                                    needPhoto = false;
                                    photoReady = true;
                                }
                                emit imgReady(Mat2QImage(mat));
                            }
                        }// end 转码 else
                    }// end if time2show
                    else{
                        cv::waitKey(5);
                    }
                } //end while
            }// end if
            this->running_flag=true;
            emit stopped();
            break;
        #endif //华谷动力相机只支持windows
    }//end switch
}

void TVideoCapture::getSupportedResolutions(int index){
    supportedResolution.clear();
    switch (this->CamType){
        case cvCam:
        {
            QMediaDevices mds;
            QString s;
            QList<QCameraDevice> rlist = mds.videoInputs();
            auto c = rlist[index];
            auto resolutions = c.photoResolutions();
            for (auto &c : resolutions){
                s="%1X%2";
                s=s.arg(c.width()).arg(c.height());
                if (!supportedResolution.contains(s)){
                    supportedResolution.append(s);
                }
            }
            break;
        }
        case workPowerCam:
        {
            supportedResolution.append("1280X1024");
            supportedResolution.append("640X480");
            break;
        }
    }
}

void TVideoCapture::setResolution(QString s){
    auto r = s.split("X");
    int width = r[0].toInt();
    int height = r[1].toInt();
    switch (this->CamType){
        case cvCam:
            cap->set(cv::CAP_PROP_FRAME_WIDTH,width);
            cap->set(cv::CAP_PROP_FRAME_HEIGHT,height);
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            IMV_StopGrabbing(this->m_devHandle);
            if(width!=1280&&height!=1024){
                IMV_SetIntFeatureValue(m_devHandle,"Width",width);
                IMV_SetIntFeatureValue(m_devHandle,"Height",height);
                IMV_SetIntFeatureValue(m_devHandle,"OffsetX",(1280-width)/2);
                IMV_SetIntFeatureValue(m_devHandle,"OffsetY",(1024-height)/2);
            }
            else{
                IMV_SetIntFeatureValue(m_devHandle,"OffsetX",0);
                IMV_SetIntFeatureValue(m_devHandle,"OffsetY",0);
                IMV_SetIntFeatureValue(m_devHandle,"Width",width);
                IMV_SetIntFeatureValue(m_devHandle,"Height",height);
            }
            IMV_StartGrabbing(this->m_devHandle);
            break;
        #endif
    }
}

void TVideoCapture::stopCapture(){

}

void TVideoCapture::startRecord(QString path){
    emit rfpsChanged(0);
    cv::Size size=getCurrentResolution();
    switch (this->CamType){
        case cvCam:
            outputVideo.open(path.toStdString(),cv::VideoWriter::fourcc('X', 'V', 'I', 'D'),this->fps,size,true);
            if(outputVideo.isOpened()){
                record_flag=true;
            }
            break;
        #ifdef Q_OS_WINDOWS// 华谷动力相机仅支持windows
        case workPowerCam:
            record_flag=true;
            this->record_thread = new recordThread(this->m_devHandle,path,this->fps,size,&this->recordQue,NULL);
            connect(this->record_thread,&recordThread::recordFinished,this,&TVideoCapture::onRecordFinished);
            connect(this->record_thread,&recordThread::recordFpsChanged,this,&TVideoCapture::onRfpsChanged);
            this->record_thread->start();
            break;
        #endif
    }
}

void TVideoCapture::stopRecord(){
    switch (this->CamType){
        case cvCam:
            record_flag = false;
            outputVideo.release();
            emit rfpsChanged(-1);
        #ifdef Q_OS_WINDOWS// 华谷动力相机仅支持windows
        case workPowerCam:
            record_flag = false;
            record_thread->stopRecord();
        #endif
    }
}

void TVideoCapture::onRfpsChanged(double rfps){
    emit this->rfpsChanged(rfps);
}

void TVideoCapture::onRecordFinished(){
#ifdef Q_OS_WINDOWS
    record_thread->wait();
    delete this->record_thread;
    emit recordFinished("内存满了自动停止");
#endif
}


bool TVideoCapture::isOpened(){
    switch (this->CamType){
        case cvCam:
            return cap->isOpened();
        #ifdef Q_OS_WINDOWS// 华谷动力相机仅支持windows
        case workPowerCam:
            return IMV_IsOpen(this->m_devHandle);
        #endif
        default:
            return false;
    }
}

void TVideoCapture::openSettings(){
    cap->set(cv::CAP_PROP_SETTINGS,0);
}

bool TVideoCapture::photo(QString path){
    QString filename;
    if(path.startsWith("file")){
        QUrl s(path);
        filename = s.toLocalFile();
    }
    else{
        filename = path;
    }
    QImage img = Mat2QImage(mat);
    bool ret = img.save(filename);
    photoReady=false;
    return ret;
}

cv::Size TVideoCapture::getCurrentResolution(){
    cv::Size size;
    int64_t width;
    int64_t height;
    switch (this->CamType){
        case cvCam:
            size.width = cap->get(cv::CAP_PROP_FRAME_WIDTH);
            size.height = cap->get(cv::CAP_PROP_FRAME_HEIGHT);
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            IMV_GetIntFeatureValue(this->m_devHandle,"Width",&width);
            size.width = width;
            IMV_GetIntFeatureValue(this->m_devHandle,"Height",&height);
            size.height = height;
            break;
        #endif
    }
    return size;
}

bool TVideoCapture::setExposureTime(double minisecond){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            ret = this->cap->set(cv::CAP_PROP_EXPOSURE,minisecond);
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetDoubleFeatureValue(m_devHandle, "ExposureTime", minisecond)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setAdjustPluse(double dGainRaw){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            ret = this->cap->set(cv::CAP_PROP_GAIN,dGainRaw);
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetDoubleFeatureValue(m_devHandle, "GainRaw",dGainRaw)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setGamma(double gamma){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            ret = this->cap->set(cv::CAP_PROP_GAMMA,gamma);
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetDoubleFeatureValue(m_devHandle, "Gamma",gamma)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setFps(double fps){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            ret = this->cap->set(cv::CAP_PROP_FPS,fps);
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetDoubleFeatureValue(m_devHandle, "AcquisitionFrameRate",fps)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setFpsEnabled(bool e){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            return true;
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetBoolFeatureValue(m_devHandle, "AcquisitionFrameRateEnable",e)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setAutoExposure(int e){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            return false;
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetEnumFeatureValue(m_devHandle,"ExposureAuto",e)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setBrightness(int b){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            ret = cap->set(cv::CAP_PROP_BRIGHTNESS,b);
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetIntFeatureValue(m_devHandle,"Brightness",b)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setDigtalShift(int shift){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            return false;
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetIntFeatureValue(m_devHandle,"DigitalShift",shift)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setAcuityEnabled(bool e){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            return false;
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetBoolFeatureValue(m_devHandle,"SharpnessEnabled",e)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setAcuity(int acuity){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            return false;
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetIntFeatureValue(m_devHandle,"Sharpness",acuity)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setDenoiseEnabled(bool e){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            return false;
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetBoolFeatureValue(m_devHandle,"DenoisingEnabled",e)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setDenoise(int deniose){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            return false;
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetIntFeatureValue(m_devHandle,"Denoising",deniose)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setAutoBalance(int e){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            return false;
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetEnumFeatureValue(m_devHandle,"BalanceWhiteAuto",e)==0){
                ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setBalanceR(double r){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            return false;
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetEnumFeatureValue(m_devHandle,"BalanceRatioSelector",0)==0){
                if(IMV_SetDoubleFeatureValue(m_devHandle,"BalanceRatio",r)==0)ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setBalanceG(double g){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            return false;
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetEnumFeatureValue(m_devHandle,"BalanceRatioSelector",1)==0){
                if(IMV_SetDoubleFeatureValue(m_devHandle,"BalanceRatio",g)==0)ret = true;
            }
            break;
        #endif
    }
    return ret;
}

bool TVideoCapture::setBalanceB(double b){
    bool ret = false;
    switch (this->CamType){
        case cvCam:
            return false;
            break;
        #ifdef Q_OS_WIN
        case workPowerCam:
            if(IMV_SetEnumFeatureValue(m_devHandle,"BalanceRatioSelector",2)==0){
                if(IMV_SetDoubleFeatureValue(m_devHandle,"BalanceRatio",b)==0)ret = true;
            }
            break;
        #endif
    }
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

#ifdef Q_OS_WINDOWS //华谷动力相机只支持windows
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
    tvd->fps_count+=1;
//    printf("Get frame blockId = %llu\n", pFrame->frameInfo.blockId);
    CFrameInfo frameInfo;
    CFrameInfo recordFrameInfo;
    frameInfo.m_nWidth = (int)pFrame->frameInfo.width;
    frameInfo.m_nHeight = (int)pFrame->frameInfo.height;
    frameInfo.m_nBufferSize = (int)pFrame->frameInfo.size;
    frameInfo.m_nPaddingX = (int)pFrame->frameInfo.paddingX;
    frameInfo.m_nPaddingY = (int)pFrame->frameInfo.paddingY;
    frameInfo.m_ePixelType = pFrame->frameInfo.pixelFormat;
    frameInfo.m_pImageBuf = (unsigned char *)malloc(sizeof(unsigned char) * frameInfo.m_nBufferSize);
    frameInfo.m_nTimeStamp = pFrame->frameInfo.timeStamp;
    memcpy(frameInfo.m_pImageBuf, pFrame->pData, frameInfo.m_nBufferSize);


    if(tvd->record_flag){
//        qDebug()<<"内存"<<getMemSize();
        if(getMemSize()>200){
            cv::Mat image;
            IMV_PixelConvertParam stPixelConvertParam;
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
                return;
            }
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
            int ret = IMV_PixelConvert(tvd->m_devHandle, &stPixelConvertParam);
            if (IMV_OK != ret)
            {
                // 释放内存
                // release memory
                printf("image convert to RGB failed! ErrorCode[%d]\n", ret);
                free(frameInfo.m_pImageBuf);
                free(pRGBbuffer);
                return;
            }

    //        image=QImage(pRGBbuffer, (int)stPixelConvertParam.nWidth, (int)stPixelConvertParam.nHeight,QImage::Format_RGB888);
            image = cv::Mat((int)stPixelConvertParam.nHeight,(int)stPixelConvertParam.nWidth,CV_8UC3,pRGBbuffer);
            tvd->recordQue.enqueue(image);
        }
        else{
            tvd->record_flag=false;
            tvd->record_thread->stopRecord();
            emit tvd->recordFinished("mem stop");
        }
    }

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
    if (tvd->fps_count==100){
        clock_t t = clock();
        tvd->fps = 100000/(t-tvd->t0);
        emit tvd->newfps(tvd->fps);
        tvd->t0=t;
        tvd->fps_count=0;
    }
}

#endif //华谷动力相机只支持windows

QString TVideoCapture::getCameraMatrix(QString fd){
    std::string filePath = fd.toStdString();
    //获取该路径下的所有文件
    std::vector<std::string> files = shell->tpycom->getFiles(filePath);

    const int board_w = 6;
    const int board_h = 9;
    const int NPoints = board_w * board_h;//棋盘格内角点总数
    const int boardSize = 25; //mm
    cv::Mat image,grayimage;
    cv::Size ChessBoardSize = cv::Size(board_w, board_h);
    std::vector<cv::Point2f> tempcorners;

    int flag = 0;
    flag |= cv::fisheye::CALIB_RECOMPUTE_EXTRINSIC;
    //flag |= cv::fisheye::CALIB_CHECK_COND;
    flag |= cv::fisheye::CALIB_FIX_SKEW;
    //flag |= cv::fisheye::CALIB_USE_INTRINSIC_GUESS;

    std::vector<cv::Point3f> object;
    for (int j = 0; j < NPoints; j++)
    {
        object.push_back(cv::Point3f((j % board_w) * boardSize, (j / board_w) * boardSize, 0));
    }

    cv::Matx33d intrinsics;//z:相机内参
    cv::Vec4d distortion_coeff;//z:相机畸变系数

    std::vector<std::vector<cv::Point3f> > objectv;
    std::vector<std::vector<cv::Point2f> > imagev;

    cv::Size corrected_size(1920, 1080);
    cv::Mat mapx, mapy;
    cv::Mat corrected;
    std::ofstream camera_matrix("cameraMatrix");

    int num = 0;
    char tmp;
    while (num < files.size())
    {
        //----解决一下中文路径问题----
        std::vector<char> buffer;
        QFile f(QString::fromStdString(files[num]));
        f.open(QIODevice::ReadOnly);
        QDataStream data(&f);
        while(!data.atEnd()){
            data>>tmp;
            buffer.push_back(tmp);
        }
        f.close();
        //------------------------
        image = cv::imdecode(buffer,cv::IMREAD_COLOR);
        if (image.empty()){
            std::cout<<"empty buff:"<<files[num]<<std::endl;
            num++;
            continue;
        }

        cvtColor(image, grayimage, CV_BGR2GRAY);
        bool findchessboard = cv::checkChessboard(grayimage, ChessBoardSize);
        if (findchessboard)
        {
            bool find_corners_result = findChessboardCorners(grayimage, ChessBoardSize, tempcorners, 3);
            if (find_corners_result)
            {
                cornerSubPix(grayimage, tempcorners, cv::Size(15, 15), cv::Size(-1, -1), cv::TermCriteria(CV_TERMCRIT_EPS + CV_TERMCRIT_ITER, 30, 0.1));
                drawChessboardCorners(image, ChessBoardSize, tempcorners, find_corners_result);
                imshow("corner_image", image);
                cv::waitKey(100);
                objectv.push_back(object);
                imagev.push_back(tempcorners);
                std::cout << "capture " << num << " pictures" << std::endl;
            }
        }
        tempcorners.clear();
        num++;
    }
    if(objectv.size()==0){
        return "校正失败";
    }

    cv::fisheye::calibrate(objectv, imagev, cv::Size(image.cols,image.rows), intrinsics, distortion_coeff, cv::noArray(), cv::noArray(), flag, cv::TermCriteria(3, 20, 1e-6));

    //这部分为保存参数到文件
    for(int i=0; i<3; ++i)
    {
        for(int j=0; j<3; ++j)
        {
            camera_matrix<<std::setiosflags(std::ios::left)<<std::setw(20)<<std::setfill(' ')<<intrinsics(i,j);
        }
        camera_matrix<<std::endl;
    }
    for(int i=0; i<4; ++i)
    {
        camera_matrix<<std::setiosflags(std::ios::left)<<std::setw(20)<<std::setfill(' ')<<distortion_coeff(i);
    }
    camera_matrix.close();

    //以下部分为校正后的图像
//    cv::fisheye::initUndistortRectifyMap(intrinsics, distortion_coeff, cv::Matx33d::eye(), intrinsics, corrected_size, CV_16SC2, mapx, mapy);
//    num = 0;
//    while (num < files.size())
//    {
//        image = cv::imread(files[num++]);
//        if (image.empty())
//            break;
//        cv::remap(image, corrected, mapx, mapy, cv::INTER_LINEAR, cv::BORDER_DEFAULT);
//        cv::imshow("corner_image", image);
//        cv::imshow("corrected", corrected);
//        cv::waitKey(0);
//    }

//    cv::destroyWindow("corner_image");
//    cv::destroyWindow("corrected");

    image.release();
    grayimage.release();
    corrected.release();
    mapx.release();
    mapy.release();
    readCameraMatrix(this->intrinsics_matrix,this->distortion_coeff);

    if(objectv.size()<5){
        return "校正成功，但可用棋盘图较少！";
    }
    return  "校正成功!";
}

bool TVideoCapture::readCameraMatrix(cv::Matx33d &K,cv::Vec4d &D){
    std::ifstream camera_matrix("cameraMatrix");
    if(!camera_matrix.is_open()){
        return false;
    }
    double tmp;
    int n=0;
    while(camera_matrix>>tmp){
        if (n<9){
             K(n/3,n%3)=tmp;
        }
        else{
           D((n-9)%4)=tmp;
        }
        n+=1;
    }
    if (n>13){
        return false;
    }
    return true;
}

bool TVideoCapture::initUndistort(cv::MatSize size){
    this->correctSize.width=size[1];
    this->correctSize.height=size[0];
    cv::fisheye::initUndistortRectifyMap(intrinsics_matrix, distortion_coeff, cv::Matx33d::eye(), intrinsics_matrix, correctSize, CV_16SC2, mapx, mapy);
    return true;

}


#ifdef Q_OS_WINDOWS
recordThread::recordThread(IMV_HANDLE mdev,QString filePath,double fps,cv::Size size,QQueue<cv::Mat> *que,QObject *parent):
    QThread(parent)
{
    this->que = que;
    this->dev = mdev;
    getMemSize();
    outputVideo.open(filePath.toStdString(),cv::CAP_FFMPEG,cv::VideoWriter::fourcc('X', 'V', 'I', 'D'),fps,size,true);
}

void recordThread::run(){
    int count=0;
    cv::Mat mat,tmp,tmp2;
    recordFps=0;
    clock_t t0,t1;
    t0 = clock();
    while (runFlag){
        if(que->size()>0){
            mat = this->que->dequeue();
            count+=1;
            if(count%100==0){
                t1 = clock();
                recordFps = 100000/(t1-t0);
                t0=t1;
                emit recordFpsChanged(recordFps);
            }
            mat.copyTo(tmp);
            cv::cvtColor(tmp,tmp2,cv::COLOR_RGB2BGR);
            outputVideo<<tmp2;
            free(mat.data);
        }
    }
    runFlag = true;

    //是否丢弃未写入的内容
    if(this->forceQuit){
        outputVideo.release();
        emit recordFinished();
        //如果列表没清空则清空再退出，防止下次再录时有上一段视频的结尾
        while (que->size()>0)
        {
            mat = que->dequeue();
            free(mat.data);
        }
        return ;
    }

    //非强制退出则把没写完的写完
    while (que->size()>0){
        mat = this->que->dequeue();
        count+=1;
        if(count%100==0){
            t1 = clock();
            recordFps = 100000/(t1-t0);
            t0=t1;
            emit recordFpsChanged(recordFps);
        }
        mat.copyTo(tmp);
        cv::cvtColor(tmp,tmp2,cv::COLOR_RGB2BGR);
        outputVideo<<tmp2;
        free(mat.data);
    }

    outputVideo.release();
    emit recordFinished();
    emit recordFpsChanged(-1);
    return ;
}

quint32 getMemSize(){
    MEMORYSTATUSEX statex;
    statex.dwLength=sizeof(statex);
    GlobalMemoryStatusEx(&statex);
//    qDebug() << QStringLiteral("可用的物理内存:") << statex.ullAvailPhys/1024/1024;
//    qDebug() << QStringLiteral("内存使用率:") << statex.dwMemoryLoad;
    quint32 um = statex.ullAvailPhys/1024/1024;
    return um;
}

#endif












