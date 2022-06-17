# This Python file uses the following encoding: utf-8
import numpy as np
import sys,os
import time

import matplotlib.pyplot as plt
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

def list2csv(l,filepath):
    try:
        with open(filepath,"w") as t:
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


def pmb0100_process(dl:list,hl:list,p:list,ft:list):
    cols=len(hl)
    data = np.array(dl).reshape(-1,cols)
    fig = plt.figure()
    fig.canvas.set_window_title('绘图')
    ax=plt.subplot()
    for i in p:
        label = i[0]
        x_axis = hl.index(i[1])
        y_axis = hl.index(i[2])
        ax.plot(data[:,x_axis],data[:,y_axis],label=label)
    plt.legend()
    plt.show()
