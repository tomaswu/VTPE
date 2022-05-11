# This Python file uses the following encoding: utf-8
import numpy as np
import sys

def print(obj,end='\n'):
    s=obj.__str__()
    sys.stdout.write(s+end)
    sys.stdout.flush()

def pyHello():
    a = np.linspace(1, 10, 10)
    print("print test!")
    print(a)
    print("hello world! python")

if __name__ == "__main__":
   pyHello()
