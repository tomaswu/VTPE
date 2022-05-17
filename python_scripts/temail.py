#!/usr/bin/python3
# -*- encoding: utf-8 -*-
'''
    @File   : email.py
    @Time   : 2020/09/21 13:09:30
    @Author : Tomaswu 
    @Contact: tomaswu@qq.com
    @Desc   :
'''

import sys
import smtplib
from email.mime.text import MIMEText
from email.header import Header

def print(obj,end='\n'):
    s=obj.__str__()
    sys.stdout.write(s+end)
    sys.stdout.flush()

def test():
    print("email module test")

class Mail:
    def __init__(self, receivers=[]):
        # 第三方 SMTP 服务
        self.mail_host="smtp.qq.com"       #设置服务器:这个是qq邮箱服务器，直接复制就可以
        self.mail_pass=""           #刚才我们获取的授权码
        self.sender = ""      #你的邮箱地址 
        self.receivers = []  #收件人的邮箱地址，可设置为你的QQ邮箱或者其他邮箱，可多个

    def send(self,content=None,subject=None,msgtype=None):
        if content is None:
            content = f'你要发送的邮件内容。\nThis is a test email.\nDo not reply.\nthanks\nbest wishes!\nTomas Wu'
        if msgtype=='html':
            message=MIMEText(content,'html','utf-8')
        else:
            message = MIMEText(content, 'plain', 'utf-8')
        message['From'] = Header(self.sender, 'utf-8')  
        message['To'] =  Header("Tomas Wu", 'utf-8')
        if subject is None:
            subject = 'python email test'  #发送的主题，可自由填写
        message['Subject'] = Header(subject, 'utf-8') 
        try:
            smtpObj = smtplib.SMTP_SSL(self.mail_host, 465) 
            smtpObj.login(self.sender,self.mail_pass)  
            smtpObj.sendmail(self.sender, self.receivers, message.as_string())
            smtpObj.quit()
            return True
        except smtplib.SMTPException as e:
            print(f'邮件发送失败   {e}')
            return False

# just for test
if  __name__ == '__main__':
    mail = Mail()
    mail.send()