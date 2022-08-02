#include "pmb0100rec.h"
#include <opencv2/imgproc.hpp>
#include <opencv2/highgui.hpp>
#include <cmath>
#include <iostream>
#include <exception>

using namespace pmb0100rec;
using namespace std;

void pmb0100rec::dsColor(cv::Mat &img,Points points,Points *bluePoint,Points *whitePoint){
    int r,g,b;
    for(auto &i:points){
        b = img.at<cv::Vec3b>(i.x,i.y)[0];
        g = img.at<cv::Vec3b>(i.x,i.y)[1];
        r = img.at<cv::Vec3b>(i.x,i.y)[2];
        if(b-g>20&&b-r>20){
            bluePoint->push_back(i);
        }
        else{
            whitePoint->push_back(i);
        }
    }
}

void pmb0100rec::colorDraw(cv::Mat &img,Points points,RGB rgb){
    if(img.channels()==1){
        cv::cvtColor(img,img,cv::COLOR_GRAY2BGR);
    }
    for(auto &p: points){
        img.at<cv::Vec3b>(p.y,p.x)[0]=rgb[2];
        img.at<cv::Vec3b>(p.y,p.x)[1]=rgb[1];
        img.at<cv::Vec3b>(p.y,p.x)[2]=rgb[0];
    }
}

ctr pmb0100rec::center(Points points,double kr,int maxR,int minR){
    ctr ct(0,0,0);
    vector<double> ds;
    int count;
    double d,r,r1,r2,tmp,r1_max,r1_min,r2_max,r2_min,s;
    r1_max=0;
    r1_min=0;
    r2_max=0;
    r2_min=0;
    s=0;
    for(int i=0;i<points.size();i++){
       tmp=points[i].x;
       r1_max = r1_max<tmp ? tmp:r1_max;
       r1_min = r1_min>tmp ? tmp:r1_min;
       tmp=points[i].y;
       r2_max = r2_max<tmp ? tmp:r2_max;
       r2_min = r2_min>tmp ? tmp:r2_min;
    }
    r1 = r1_max - r1_min;
    r2 = r2_max - r2_min;
    r = r1>r2 ? r1:r2;
    r = r<maxR ? r:maxR;
    for(auto &ip : points){
        ds.clear();
        for(int i=0;i<points.size();i++){
           d=sqrt(pow(points[i].x-ip.x,2)+pow(points[i].y-ip.y,2));
           ds.push_back(d);
        }
        for(int ir = minR;ir<=r;ir++){
            count = 0;
            for(auto &d:ds){
                if(d<=ir)count++;
            }
            tmp=count/ir;
            if(tmp>s){
                s=tmp;
                ct.x=(float)ip.x/kr;
                ct.y=(float)ip.y/kr;
                ct.z=(float)ir/kr;
            }
        }
    }
    return ct;
}

ctr pmb0100rec::centerBlue(Points points,Points pointsBlue,double kr,int maxR,int minR){
    ctr ct(0,0,0);
    vector<double> ds;
    int count;
    double d,r,r1,r2,tmp,r1_max,r1_min,r2_max,r2_min,s;
    r1_max=0;
    r1_min=0;
    r2_max=0;
    r2_min=0;
    s=0;
    for(int i=0;i<pointsBlue.size();i++){
       tmp=pointsBlue[i].x;
       r1_max = r1_max<tmp ? tmp:r1_max;
       r1_min = r1_min>tmp ? tmp:r1_min;
       tmp=pointsBlue[i].y;
       r2_max = r2_max<tmp ? tmp:r2_max;
       r2_min = r2_min>tmp ? tmp:r2_min;
    }
    r1 = r1_max - r1_min;
    r2 = r2_max - r2_min;
    r = r1>r2 ? r1:r2;
    r = r<maxR ? r:maxR;
    cv::Point2i ip;
    for(int x=(int)r1_min;x<=r1_max;x++){
        for(int y=(int)r2_min;y<r2_max;y++){
            ip.x=x;
            ip.y=y;
            ds.clear();
            for(int i=0;i<points.size();i++){
               d=sqrt(pow(points[i].x-ip.x,2)+pow(points[i].y-ip.y,2));
               ds.push_back(d);
            }
            for(int ir = minR;ir<=r;ir++){
                count = 0;
                for(auto &d:ds){
                    if(d<=ir)count++;
                }
                tmp=count/ir;
                if(tmp>s){
                    s=tmp;
                    ct.x=(float)ip.x/kr;
                    ct.y=(float)ip.y/kr;
                    ct.z=(float)ir/kr;
                }
            }
        }

    }
    return ct;
}

recResult pmb0100rec::recBall(cv::Mat img,Para para,double kr){
    Points points;
    recResult res;
    res.pos=para.pos;
    cv::resize(img,img,cv::Size(),kr,kr);
    cv::Mat gray_img;
    cv::cvtColor(img,gray_img,cv::COLOR_BGR2GRAY);
    for(int row=para.row1*kr;row<para.row2*kr;row++){
        for(int col=para.col1*kr;col<para.col2*kr;col++){
            if(gray_img.at<uchar>(row,col)>=para.threshold){
                points.push_back(cv::Point(col,row));
            }
        }
    }
    Points whitePoints,bluePoints;
    ctr whiteBall(-1,-1,-1);
    ctr blueBall(-1,-1,-1);
    dsColor(img,points,&bluePoints,&whitePoints);
    cout<<bluePoints.size()<<endl;
    if(whitePoints.size()>=para.pointNum){
        whiteBall = center(whitePoints,kr);
    }
    if(bluePoints.size()>=para.pointNum){
        blueBall = centerBlue(points,bluePoints,kr);
    }
    RGB green = {0,255,0};
    RGB red = {255,0,0};
    colorDraw(img,whitePoints,green);
    colorDraw(img,bluePoints,red);
    cv::imshow("test",img);
    cv::waitKey(20);
    res.data.push_back(whiteBall);
    res.data.push_back(blueBall);
    return res;
}


cv::Mat pmb0100rec::preThreshold(cv::Mat img,int threshold){
    cv::Vec3b color(0,0,255);
    cv::Mat gray,new_img;
    if(img.channels()==1){
        cv::cvtColor(img,new_img,cv::COLOR_GRAY2BGR);
    }
    else{
        img.copyTo(new_img);
    }
    cv::cvtColor(img,gray,cv::COLOR_BGR2GRAY);
    for(int i=0;i<img.size().height;i++){
        for(int j=0;j<img.size().width;j++){
            if(gray.at<uchar>(i,j)>threshold){
                new_img.at<cv::Vec3b>(i,j)=color;
            }
        }
    }
    return new_img;
}


void pmb0100rec::convertStandardUint(ctr* p,double ratio){
    p->x *= ratio;
    p->y *= ratio;
    p->z *= ratio;
}



