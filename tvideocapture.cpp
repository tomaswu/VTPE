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

#ifdef Q_OS_WINDOWS
#include <IMVAPI/IMVApi.h>
#include <IMVAPI/IMVDefines.h>
#endif

TVideoCapture::TVideoCapture(QObject *parent)
    : QObject{parent}
{
    cap = new cv::VideoCapture;
    connect(this,&TVideoCapture::startCapture,this,&TVideoCapture::capture);
//    this->getCameraMatrix();
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
                    IMV_SetBoolFeatureValue(m_devHandle,"AcquisitionFrameRateEnable",true);
                    IMV_SetDoubleFeatureValue(m_devHandle, "AcquisitionFrameRate",50);

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
                      }
                      fps_count+=1;
                      emit imgReady(tmp);
                   }
                   if (fps_count==100){
                       t1=clock();
            #ifdef Q_OS_MACOS
                       fps = 100000000/(t1-t0);
            #elif defined Q_OS_WINDOWS
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
                    cv::waitKeyEx(40);
                    if(tque.size()==0){
                        continue;
                    }
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

                    }// end else
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
            supportedResolution.append("1280X720");
            supportedResolution.append("640X480");
            break;
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
    QImage img = Mat2QImage(photo_mat);
    QUrl s(path);
    bool ret = img.save(s.toLocalFile());
    photoReady=false;
    return ret;
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
    if (tvd->fps_count==100){
        clock_t t = clock();
        tvd->fps = 100000/(t-tvd->t0);
        emit tvd->newfps(tvd->fps);
        tvd->t0=t;
        tvd->fps_count=0;
    }
}

#endif //华谷动力相机只支持windows

void TVideoCapture::getCameraMatrix(){
    std::string filePath = "F:\\Users\\Tomas\\Desktop\\calipics";
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
    while (num < files.size())
    {
        image = cv::imread(files[num]);
        if (image.empty())
            break;

        cvtColor(image, grayimage, CV_BGR2GRAY);
        bool findchessboard = cv::checkChessboard(grayimage, ChessBoardSize);
        if (findchessboard)
        {
            bool find_corners_result = findChessboardCorners(grayimage, ChessBoardSize, tempcorners, 3);
            if (find_corners_result)
            {
                cornerSubPix(grayimage, tempcorners, cv::Size(15, 15), cv::Size(-1, -1), cv::TermCriteria(CV_TERMCRIT_EPS + CV_TERMCRIT_ITER, 30, 0.1));
                drawChessboardCorners(image, ChessBoardSize, tempcorners, find_corners_result);
//                imshow("corner_image", image);
//                cv::waitKey(100);
                objectv.push_back(object);
                imagev.push_back(tempcorners);
                std::cout << "capture " << num << " pictures" << std::endl;
            }
        }
        tempcorners.clear();
        num++;
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
