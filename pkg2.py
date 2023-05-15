# This Python file uses the following encoding: utf-8
import os
import sys
import time
import shutil

tooldir = r'E:/pkgtools'

sys.path.append(os.getcwd())
sys.path.append(tooldir)

import tools

pkgdir =os.path.abspath('E:\work\projects\新高速摄影系列（中山大学）\iso(for中山大学)')

exp_name ='高速摄影实验平台' 
sft_name ='世纪中科高速摄影实验平台'
sft_dir = os.path.abspath('../build-VTPE-Desktop_Qt_6_5_0_MSVC2019_64bit-Release/deploy')
exe_name = os.path.basename('../build-VTPE-Desktop_Qt_6_5_0_MSVC2019_64bit-Release/deploy/VTPE.exe')

files=[ #r'E:\work\projects\陀螺仪\蓝牙接收器驱动\HC-USB-D驱动.zip',
        r'C:\Qt\vcredist\vcredist_msvc2019_x64.exe',
        r'"E:\work\以后会用到\华谷动力MVviewer_2.3.1.GEN_Build20210929\UT and GE_DriverV2.1.6\华谷动力UT及GE系列相机软件包2018\华谷动力SDKV_2.1.6\Drivers.zip"'
]

def create_iso(experiment_name,software_name,software_folder,exe_name,files,usbkey):
    try:
        ret=tools.create_ins(experiment_name,software_name,software_folder,exe_name,usbkey=usbkey)
        if ret:
            if usbkey:
                files.append(f'{tooldir}/sense_shield_installer_pub.exe')
            shutil.copy(tooldir+'/Setup.ico','.')
            shutil.copy(tooldir+'/Uninstall.ico','.')
            tools.makensis(f'./tmpt.nsi')
            tools.makeiso(software_name,files)
            os.remove('tmpt.nsi')
            os.remove('Setup.ico')
            os.remove('Uninstall.ico')
            return True
        return False
    except Exception as e:
        print(e)


if __name__ == "__main__":
    try:
#        if deploy.deployqt():
            print('make iso...')
            os.chdir(pkgdir)
            ret = create_iso(exp_name,sft_name,sft_dir,exe_name,files,False)
            if(ret):
                os.system(f'explorer {pkgdir}')
    except Exception as e:
        print(e)
