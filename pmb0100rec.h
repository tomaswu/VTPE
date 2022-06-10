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
using recResult = vector<ctr>;

typedef struct _recPara{
    int threshold;
    int pointNum;
}Para;


void dsColor(cv::Mat &img,Points points,Points *bluePoint,Points *whitePoint);
void colorDraw(cv::Mat &img,Points points,RGB rgb);
ctr center(Points points,int maxR=35,int minR=5);
ctr centerBlue(Points points,Points pointsBlue,int maxR=35,int minR=5);
recResult recBall(cv::Mat img,Para para);

}
#endif // PMB0100REC_H
