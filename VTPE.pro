QT += quick \
      quickcontrols2 \
      multimedia\
      serialport


SOURCES += \
        main.cpp \
        pmc0100_com.cpp \
        tcamera.cpp \
        tvideocapture.cpp \
        pmc0100_com.cpp

resources.files = main.qml \
                  SToolButton.qml \
                  ToolbarVSplit.qml \
                  TriSlider.qml \
                  SToolButton2.qml \
                  MaskImage.qml \
                  TCheckBox.qml \
                  MeasureScale.qml \
                  EmailFeedback.qml \
                  DeviceList.qml


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
    ColorSelector.qml \
    EmailFeedback.qml \
    MeasureScale.qml \
    README.md \
    SToolButton.qml \
    SToolButton2.qml \
    TCheckBox.qml \
    ToolbarVSplit.qml \
    TriSlider.qml \
    deviceList.qml \
    maskImage.qml \
    qtquickcontrols2.conf


CONFIG += debug_and_release

win32{

    INCLUDEPATH += \
        E:\Tomas_temp\opencv\op4\opencv\build\include
    LIBS += -LE:\Tomas_temp\opencv\op4\opencv\build\x64\vc15\lib

    CONFIG(debug,debug|release){

        LIBS += -lopencv_world455d
    }
    CONFIG(release,debug|release){

        LIBS += -lopencv_world455
    }

}
macx{
    QMAKE_MACOSX_DEPLOYMENT_TARGET = 12.0
    INCLUDEPATH += /opt/homebrew/Cellar/opencv/4.5.5/include/opencv4
    LIBS += -L/opt/homebrew/Cellar/opencv/4.5.5/lib -lopencv_core -lopencv_imgproc -lopencv_imgcodecs -lopencv_highgui -lopencv_videoio

}

HEADERS += \
    pmc0100_com.h \
    tcamera.h \
    tvideocapture.h
