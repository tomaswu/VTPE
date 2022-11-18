QT += core \
      quick \
      quickcontrols2 \
      multimedia\
      serialport\
      charts\
      widgets\

CONFIG += c++17 #console #控制台，用于调试

QMAKE_CXXFLAGS_RELEASE += -O2

windows{
    QMAKE_CXXFLAGS += /MP
}

RC_FILE += logo.rc

HEADERS += \
    cameraMessageQue.h \
    commandLineTools.h \
    multirec.h \
    pmb0100rec.h \
    pmc0100_com.h \
    tcamera.h \
    tpycom.h \
    tvideoanalysis.h \
    tvideocapture.h

SOURCES += \
        commandLineTools.cpp \
        main.cpp \
    multirec.cpp \
    pmb0100rec.cpp \
        pmc0100_com.cpp \
        tcamera.cpp \
        tpycom.cpp \
        tvideoanalysis.cpp \
        tvideocapture.cpp \

resources.files = main.qml \
                  SToolButton.qml \
                  ToolbarVSplit.qml \
                  TriSlider.qml \
                  SToolButton2.qml \
                  MaskImage.qml \
                  TCheckBox.qml \
                  MeasureScale.qml \
                  EmailFeedback.qml \
                  DeviceList.qml\
                  CameraSettingsDialog.qml\
                  SelectScale4Image.qml \
                  CameraMoreSettingsWindow.qml \
                  Ttable.qml \
                  TRecPara.qml \
                  SelectScale4Analysis.qml \
                  AddCurveDialog.qml \
                  DataProcessPara.qml \
                  ZoomRect.qml \
                  StrobPara.qml


resources.prefix = /$${TARGET}

RESOURCES += resources qtquickcontrols2.conf \
    res.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    CameraMoreSettingsWindow.qml \
    CameraSettingsDialog.qml \
    ColorSelector.qml \
    CutScale.qml \
    DESIGN.md \
    DataProcessPara.qml \
    Depends/workPower/win32/vs2013shared/MVSDKmd.lib \
    Depends/workPower/x64/vs2013shared/MVSDKmd.lib \
    EmailFeedback.qml \
    MeasureScale.qml \
    README.md \
    SToolButton.qml \
    SToolButton2.qml \
    SelectScale4Analysis.qml \
    SelectScale4Image.qml \
    StrobPara.qml \
    TCheckBox.qml \
    TRecPara.qml \
    ToolbarVSplit.qml \
    TriSlider.qml \
    Ttable.qml \
    AddCurveDialog.qml \
    ZKY-PMB0100SS.pdf \
    ZoomRect.qml \
    deploy.py \
    deviceList.qml \
    logo.rc \
    maskImage.qml \
    python_scripts/data_process.py \
    python_scripts/temail.py \
    qtquickcontrols2.conf \
    softwareManual.pdf


CONFIG += debug_and_release

windows{

    INCLUDEPATH += \
        E:\Tomas_temp\opencv\opencv460\opencv\build\include \
        "C:\Program Files\General MVTech\MV Viewer\Development\Include" \
        "C:\Users\tomas\AppData\Local\Programs\Python\Python310\include" \
        "E:\boost_1_79_0\boost_1_79_0" \
        "C:\Program Files (x86)\CKCam\SDK\include"

    LIBS += -LE:\Tomas_temp\opencv\opencv460\opencv\build\x64\vc15\lib \
            -L"C:\Program Files\General MVTech\MV Viewer\Development\Lib\x64" \
            -L"C:\Users\tomas\AppData\Local\Programs\Python\Python310\libs" \
            -L"E:\boost_1_79_0\boost_1_79_0\stage\lib" \
            -L"C:\Program Files (x86)\CKCam\SDK\x64"

    CONFIG(debug,debug|release){
        LIBS += -lopencv_world460d -lMVSDKmd -lpython310_d -l_tkinter \ #这里如果使用python3_d则会在import numpy等三方库时出错
                -lboost_python310-vc143-mt-gd-x64-1_79 \
                -lCKCameraDLL_X64
        QMAKE_POST_LINK += copy \"$$PWD\\python_scripts\\data_process.py\" \"$$OUT_PWD\\release\\data_process.py\" && \
                           copy \"$$PWD\\python_scripts\\temail.py\" \"$$OUT_PWD\\release\\temail.py\"
    }
    CONFIG(release,debug|release){
        LIBS += -lopencv_world460 -lMVSDKmd -lpython310 -l_tkinter -lboost_python310-vc143-mt-x64-1_79 -lCKCameraDLL_X64
        QMAKE_POST_LINK += copy \"$$PWD\\python_scripts\\data_process.py\" \"$$OUT_PWD\\release\\data_process.py\" && \
                           copy \"$$PWD\\python_scripts\\temail.py\" \"$$OUT_PWD\\release\\temail.py\" && \
                           copy \"$$PWD\\ZKY-PMB0100SS.pdf\" \"$$OUT_PWD\\release\\ZKY-PMB0100SS.pdf\" &&\
                           copy \"$$PWD\\softwareManual.pdf\" \"$$OUT_PWD\\release\\softwareManual.pdf\"
    }
}


macx{
    QMAKE_MACOSX_DEPLOYMENT_TARGET = 12.0
    INCLUDEPATH += \#/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/13.1.6/include \
                   /opt/homebrew/Cellar/opencv/4.5.5/include/opencv4 \
                   /Library/Frameworks/Python.framework/Versions/3.10/include/python3.10 \
                   /Users/tomaswu/usr/boost_1_79_0

    LIBS += -L/opt/homebrew/Cellar/opencv/4.5.5/lib -lopencv_core -lopencv_imgproc -lopencv_imgcodecs -lopencv_highgui -lopencv_videoio -lopencv_calib3d
    LIBS += -L/Library/Frameworks/Python.framework/Versions/3.10/lib -lpython3.10
    LIBS += -L/Users/tomaswu/usr/boost_1_79_0/stage/lib -lboost_python310 -lboost_numpy310
    QMAKE_POST_LINK += cp $$PWD/python_scripts/data_process.py $$OUT_PWD/data_process.py

}
