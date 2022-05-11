QT += quick \
      quickcontrols2 \
      multimedia\
      serialport\
      charts\
      widgets

HEADERS += \
    cameraMessageQue.h \
    commandLineTools.h \
    include/IMVAPI/IMVApi.h \
    include/IMVAPI/IMVDefines.h \
    pmc0100_com.h \
    tcamera.h \
    tpycom.h \
    tvideoanalysis.h \
    tvideocapture.h

SOURCES += \
        commandLineTools.cpp \
        main.cpp \
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
                  CameraMoreSettingsWindow.qml


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
    Depends/workPower/win32/vs2013shared/MVSDKmd.lib \
    Depends/workPower/x64/vs2013shared/MVSDKmd.lib \
    EmailFeedback.qml \
    MeasureScale.qml \
    README.md \
    SToolButton.qml \
    SToolButton2.qml \
    SelectScale4Image.qml \
    TCheckBox.qml \
    ToolbarVSplit.qml \
    TriSlider.qml \
    deviceList.qml \
    maskImage.qml \
    python_scripts/data_process.py \
    qtquickcontrols2.conf \


CONFIG += debug_and_release

windows{

    INCLUDEPATH += \
        E:\Tomas_temp\opencv\op4\opencv\build\include \
        ./include \
        "C:\Users\Tomas Wu\AppData\Local\Programs\Python\Python310\include" \
        "E:\boost_1_79_0\boost_1_79_0"

    LIBS += -LE:\Tomas_temp\opencv\op4\opencv\build\x64\vc15\lib \
            -LE:\private\TomasWu\CPP_programs\VTPE\Depends\workPower\x64\vs2013shared \
            -L"C:\Users\Tomas Wu\AppData\Local\Programs\Python\Python310\libs" \
            -L"E:\boost_1_79_0\boost_1_79_0\stage\lib"

    CONFIG(debug,debug|release){
        LIBS += -lopencv_world455d -lMVSDKmd -lpython310 -l_tkinter \ #这里如果使用python3_d则会在import numpy等三方库时出错
                -lboost_python310-vc142-mt-x64-1_79
        QMAKE_POST_LINK += copy \"$$PWD\\python_scripts\\data_process.py\" \"$$OUT_PWD\\debug\\data_process.py\"
    }
    CONFIG(release,debug|release){
        LIBS += -lopencv_world455 -lMVSDKmd -lpython310 -l_tkinter -lboost_python310-vc142-mt-x64-1_79
        QMAKE_POST_LINK += copy \"$$PWD\\python_scripts\\data_process.py\" \"$$OUT_PWD\\release\\data_process.py\"
    }
}


macx{
    QMAKE_MACOSX_DEPLOYMENT_TARGET = 12.0

    INCLUDEPATH += /opt/homebrew/Cellar/opencv/4.5.5/include/opencv4 \
                   /Library/Frameworks/Python.framework/Versions/3.10/include/python3.10

    LIBS += -L/opt/homebrew/Cellar/opencv/4.5.5/lib -lopencv_core -lopencv_imgproc -lopencv_imgcodecs -lopencv_highgui -lopencv_videoio
    LIBS += -L//Library/Frameworks/Python.framework/Versions/3.10/lib -lpython3.10

    QMAKE_POST_LINK += cp $$PWD/python_scripts/data_process.py $$OUT_PWD/data_process.py

}
