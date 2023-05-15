# This Python file uses the following encoding: utf-8
import numpy as np
import sys,os
import time
import scipy.signal

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('TkAgg')
plt.rcParams['font.sans-serif']=['SimHei'] #用来正常显示中文标签
plt.rcParams['axes.unicode_minus']=False #用来正常显示负号

def print(obj,end='\n'):
    s=obj.__str__()
    sys.stdout.write(s+end)
    sys.stdout.flush()

def pyHello():
    a = np.linspace(1, 10, 10)
    print(f"print test! {time.ctime()}")
    print(a)
    print("hello world! python")

def list2csv(l,filepath,standardUnit=False):
    try:
        with open(filepath,"w") as t:
            if standardUnit:
                t.write("times(s),x1(mm),y1(mm),x2(mm),y2(mm)\n")
            else:
                t.write("frame,x1,y1,x2,y2\n")
            for i in l:
                s = ','.join([str(k) for k in i])
                t.write(s+"\n")
        return True
    except Exception as e:
        print(e)
        return False

def getNewNameByTime(dic:str='./',tail:str='.png') -> str:
    a=time.strftime(r"%Y%m%d_%H%M%S",time.localtime())
    fn=a+tail
    return os.path.abspath(os.path.join(dic,fn))


def pmb0100_process(dl:list,hl:list,p:list,ft:list,fps:float):
    try:
        cols=len(hl)
        data = np.array(dl).reshape(-1,cols)         
        fig = plt.figure()
        plt.get_current_fig_manager().set_window_title('绘图')
        ax=plt.subplot()
        for i in p:
            label = i[0]
            if i[1] not in hl:
                plt.close()
                return
            x_axis = hl.index(i[1])
            y_axis = hl.index(i[2])
            xx,yy=data[:,x_axis],data[:,y_axis]
            yy = smooth(yy,ft,fps)
            ax.plot(xx,yy,label=label)
        plt.legend()
        plt.show()
    except Exception as e:
        print(e)

def smooth(data,band,sampling=1e4):
    try:
        if band==[0,5000] or band[0]>=band[1]:
            return data
        N=1
        band=[2*band[0]/sampling,2*band[1]/sampling]
        if band[0]==0:
            sty='lowpass'
            b, a = scipy.signal.butter(N, band[1], sty)
        elif band[1]==1:
            sty='highpass'
            b, a = scipy.signal.butter(N, band[0], sty)
        elif 0<band[0]<band[1]<1:
            sty='bandpass'
            b, a = scipy.signal.butter(N, band, sty)
        elif 0<band[1]<band[0]<1:
            sty='bandstop'
            b, a = scipy.signal.butter(N, [band[1],band[0]], sty)
        #配置滤波器 8 表示滤波器的阶数
        else:
            return data
        filtedData = scipy.signal.filtfilt(b, a, data)  #data为要过滤的信号
        return filtedData
    except Exception as e:
        print(e)
        return data

def stroboscopic_map(img:np.ndarray):
    nimg = img.copy()
    strob=plt.figure()
    plt.get_current_fig_manager().set_window_title('频闪图')
    ax=plt.subplot()
    ax.imshow(nimg)
#    plt.ion() #mac需要加上这一条但win不能加
    plt.show()
    return True
