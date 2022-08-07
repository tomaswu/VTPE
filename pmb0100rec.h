/*
 * 这部分基本是完成pmb0100产品识别算法的内容
 *
 */

#ifndef PMB0100REC_H
#define PMB0100REC_H

#include <vector>
#include <string>
#include <opencv2/core.hpp>

namespace pmb0100rec{

using namespace std;
using Points = vector<cv::Point2i>;
using RGB = uint8_t[3];
using ctr = cv::Point3f;

typedef struct __recResult{
    int pos=0;
    vector<ctr> data;

}recResult;



//识别参数的结构体
typedef struct _recPara{
    int pos; //当前帧数,识别算法不会用到,但在返回处理时,方便绑定;
    int threshold;  //灰度阈值,识别非黑点;
    int pointNum;  //点数阈值,只有比这个阈值大的,才进行小球识别;
    int col1;     //识别起始列
    int col2;      //识别结束列,下面两个对应行
    int row1;
    int row2;
    bool  standardUint; //是否转换为标准单位
    double ratio; //转换为标准单位的比例值,但这部分功能其实没有做,将其放在了界面表格功能中
}Para;

void dsColor(cv::Mat &img,Points points,Points *bluePoint,Points *whitePoint); //区分点的颜色
void colorDraw(cv::Mat &img,Points points,RGB rgb);//在画面中将点描成特定颜色
ctr center(Points points,double kr,int maxR=35,int minR=5); //将点集识别成小球
ctr centerBlue(Points points,Points pointsBlue,double kr,int maxR=35,int minR=5); //识别蓝色小球的算法,但并未实际使用,太慢
recResult recBall(cv::Mat img,Para para,double kr=1); //从一帧画面中识别出小球
cv::Mat preThreshold(cv::Mat img,int threshold); //预览灰度阈值的情况
void convertStandardUint(ctr* p, double ratio); //转换标准单位的函数,但在recball中其实没有实装

}
#endif // PMB0100REC_H
