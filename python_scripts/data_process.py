# This Python file uses the following encoding: utf-8
import numpy as np
import sys
import time

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

if __name__ == "__main__":
   test = [[1,2,3,4,5],[4,5,6,7,8]]
   list2csv(test,'a.csv')
