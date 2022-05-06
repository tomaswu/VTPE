#include "tvideoanalysis.h"

TVideoAnalysis::TVideoAnalysis(QObject *parent)
    : QObject{parent}
{

}

TVideoAnalysis::~TVideoAnalysis(){


}

int TVideoAnalysis::getPos(){

    return 0;
}

bool TVideoAnalysis::setPos(){

    return false;
}


int TVideoAnalysis::getBeginPos(){

    return 0;
}

bool TVideoAnalysis::setBeginPos(){

    return false;
}

int TVideoAnalysis::getEndPos(){

    return 0;
}

bool TVideoAnalysis::setEndPos(){

    return false;
}

int TVideoAnalysis::getFrameCount(){

    return 0;
}
