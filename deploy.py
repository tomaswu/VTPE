# This Python file uses the following encoding: utf-8
import os
import shutil

qt_version = '6.5.0'
qt_major,qt_middle,qt_small = qt_version.split('.')

qt_home = 'C:\\Qt'
windeployqt = f'{qt_home}\\{qt_version}\\msvc2019_64\\bin\\windeployqt.exe'


class EPath():
    boost_python=r'E:\boost_1_81_0\boost_1_81_0\bin.v2\libs\python\build\msvc-14.3\release\python-3.11\threading-multi\boost_python311-vc143-mt-x64-1_81.dll'
    boost_numpy=r'E:\boost_1_81_0\boost_1_81_0\bin.v2\libs\python\build\msvc-14.3\release\python-3.11\threading-multi\boost_numpy311-vc143-mt-x64-1_81.dll'
    python_script=r'E:\work\software_development\CPP_programs\VTPE\python_scripts'
    qmldir=r'E:/work/software_development/CPP_programs/VTPE'
    pythonHome = r'C:\Users\tomas\miniconda3\envs\py311'
    pythonLib = r'C:\Users\tomas\miniconda3\envs\py311\Lib'
    pythonLibrary = r'C:\Users\tomas\miniconda3\envs\py311\Library\bin'
    opencv_world =r'E:\Tomas_temp\opencv\opencv460\opencv\build\x64\vc15\bin\opencv_world460.dll'
    opencv_ffmpeg = r'E:\Tomas_temp\opencv\opencv460\opencv\build\bin\opencv_videoio_ffmpeg460_64.dll'
    mvsdk = r'C:\Program Files\General MVTech\MV Viewer\Runtime\x64'
    vcredist_2013 = r'E:\work\以后会用到\华谷动力MVviewer_2.3.1.GEN_Build20210929\UT and GE_DriverV2.1.6\华谷动力UT及GE系列相机软件包2018\华谷动力SDKV_2.1.6\Tools\vcredist\vcredist_2013_x64.exe'
    softwareManual = r'E:/work/software_development/CPP_programs/VTPE\softwareManual.pdf'
    ex_manual = r'E:/work/software_development/CPP_programs/VTPE\ZKY-PMB0100SS.pdf'
    cameraMatrix = r'E:\work\software_development\CPP_programs\VTPE\cameraMatrix'

def copyPython(dst):
    try:
        print('复制python.exe')
        shutil.copy(os.path.join(EPath.pythonHome,'python.exe'),dst)
        print('复制python311.dll')
        shutil.copy(os.path.join(EPath.pythonHome,'python311.dll'),dst)
        print('复制python DLLs')
        shutil.copytree(EPath.pythonHome+'/DLLs',dst+'/DLLs')
        print('复制python Lib')
        shutil.copytree(EPath.pythonLib,dst+'/Lib')
        print('复制python Library')
        for i in os.listdir(EPath.pythonLibrary):
            if i.endswith('.dll'):
                print(i)
                shutil.copy(f'{EPath.pythonLibrary}/{i}',dst)
    except Exception as e:
        print('copy python error:\n',e)

def copyMVSDK(dst):
    for i in os.listdir(EPath.mvsdk):
        print('复制',i)
        shutil.copy(os.path.join(EPath.mvsdk,i),dst)

def deployqt():
    exeFile=f'E:\\\work\\software_development\\CPP_programs\\build-VTPE-Desktop_Qt_{qt_major}_{qt_middle}_{qt_small}_MSVC2019_64bit-Release\\release\\VTPE.exe'
    deployPath=f'E:\\work\\software_development\\CPP_programs\\build-VTPE-Desktop_Qt_{qt_major}_{qt_middle}_{qt_small}_MSVC2019_64bit-Release\\deploy'
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
    os.system(f'{windeployqt} VTPE.exe --qmldir {EPath.qmldir}')

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
