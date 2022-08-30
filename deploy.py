# This Python file uses the following encoding: utf-8
import os
import shutil


class EPath():
    boost_python=r'E:\boost_1_79_0\boost_1_79_0\bin.v2\libs\python\build\msvc-14.2\release\python-3.10\threading-multi\boost_python310-vc142-mt-x64-1_79.dll'
    boost_numpy=r'E:\boost_1_79_0\boost_1_79_0\stage\lib\boost_numpy310-vc142-mt-x64-1_79.dll'
    python_script=r'E:\private\TomasWu\CPP_programs\VTPE\python_scripts'
    qmldir=r'E:\private\TomasWu\CPP_programs\VTPE'
    pythonHome = r'F:\Users\Tomas\AppData\Local\Programs\Python\Python310'
    pythonLib = r'E:\pkgtools\vtpepython\Lib'
    pythonTcl = r'E:\pkgtools\vtpepython\tcl'
    opencv_world =r'E:\Tomas_temp\opencv\opencv460\opencv\build\x64\vc15\bin\opencv_world460.dll'
    opencv_ffmpeg = r'E:\Tomas_temp\opencv\opencv460\opencv\build\bin\opencv_videoio_ffmpeg460_64.dll'
    mvsdk = r'C:\Program Files\General MVTech\MV Viewer\Runtime\x64'
    vcredist_2013 = r'E:\work\以后会用到\华谷动力MVviewer_2.3.1.GEN_Build20210929\UT and GE_DriverV2.1.6\华谷动力UT及GE系列相机软件包2018\华谷动力SDKV_2.1.6\Tools\vcredist\vcredist_2013_x64.exe'
    softwareManual = r'E:\private\TomasWu\CPP_programs\VTPE\softwareManual.pdf'
    ex_manual = r'E:\private\TomasWu\CPP_programs\VTPE\ZKY-PMB0100SS.pdf'
    cameraMatrix = r'E:\private\TomasWu\CPP_programs\build-VTPE-Desktop_Qt_6_3_1_MSVC2019_64bit-Release\cameraMatrix'

def copyPython(dst):
    print('复制python310.dll')
    shutil.copy(os.path.join(EPath.pythonHome,'python310.dll'),dst)
    print('复制python DLLs')
    shutil.copytree(EPath.pythonHome+'/DLLs',dst+'/DLLs')
    print('复制python Lib')
    shutil.copytree(EPath.pythonLib,dst+'/Lib')
    print('复制python tcl')
    shutil.copytree(EPath.pythonTcl,dst+'/tcl')

def copyMVSDK(dst):
    for i in os.listdir(EPath.mvsdk):
        print('复制',i)
        shutil.copy(os.path.join(EPath.mvsdk,i),dst)

def deployqt():
    exeFile=r'E:\private\TomasWu\CPP_programs\build-VTPE-Desktop_Qt_6_3_1_MSVC2019_64bit-Release\release\VTPE.exe'
    deployPath=r'E:\private\TomasWu\CPP_programs\build-VTPE-Desktop_Qt_6_3_1_MSVC2019_64bit-Release\deploy'
    if os.path.isdir(deployPath):
        print('清空发布历史...')
        shutil.rmtree(deployPath)
    print('创建发布目录',deployPath)
    os.mkdir(deployPath)
    print('复制可执行文件...')
    shutil.copy(exeFile,deployPath)
    print('复制Qt库文件...')
    cwd = os.getcwd()
    os.chdir(deployPath)
    os.system(f'windeployqt VTPE.exe --qmldir {EPath.qmldir}')

    print('复制相关python脚本文件....')
    for i in os.listdir(EPath.python_script):
        f = os.path.join(EPath.python_script,i)
        shutil.copy(f,deployPath)
    print('复制python库...')
    copyPython(deployPath)
    print('复制boost库...')
    shutil.copy(EPath.boost_python,deployPath)
    shutil.copy(EPath.boost_numpy,deployPath)
    print('复制opencv库...')
    shutil.copy(EPath.opencv_world,deployPath)
    print('复制opencv ffmpeg库...')
    shutil.copy(EPath.opencv_ffmpeg,deployPath)
    print('复制华谷动力相机库...')
    copyMVSDK(deployPath)
    print('复制vc发布运行库')
    shutil.copy(EPath.vcredist_2013,deployPath)
    print('复制cameraMatrix')
    shutil.copy(EPath.cameraMatrix,deployPath)
    print('复制说明书')
    shutil.copy(EPath.softwareManual,deployPath)
    shutil.copy(EPath.ex_manual,deployPath)
    os.system(f'explorer {deployPath}')
    print('发布完成！')
    



if __name__ == "__main__":
    deployqt()
