---
layout: post
title:  "python报错"
date:   2019-05-13 14:01:00 +0800
categories: Python
tags: python 
author: cndaqiang
mathjax: true
---
* content
{:toc}

放一些杂七杂八的用法









## 
### python enumerate用法总结
[python enumerate用法总结](https://blog.csdn.net/churximi/article/details/51648388)
```python
>>> for i,name in enumerate( ('x','y','z') ):
...  print i, name
...
0 x
1 y
2 z
```

## 问题
python脚本开头没写python运行,执行后，因`import`命令使鼠标变成十字<br>
参考[Ubuntu(Linux)下鼠标锁死变成十字](https://www.jianshu.com/p/4c25b864c516)

解决
```
(python37) cndaqiang@girl:~$ ps -e | grep import
21090 pts/1    00:00:00 import
(python37) cndaqiang@girl:~$ kill -9 21090
```


### `divide by zero encountered in double_scalars`
```
RuntimeWarning: divide by zero encountered in double_scalars
```
因为自己写自相关函数时，当`t=总步长-1`时,只有一个数据, 分母 $ \< x^2 \> - \< x \> ^2 == 0 $

### `if [ ] `用错判断符号
应该用`()`或不用
```python
>>> if [ 2 > 3 ]:
...  print("2>3")
...
2>3
```

### `'builtin_function_or_method' object is not subscriptable`
```
    def fermi_dirac_fitting(Es,Os,Ein=np.zeros[1]):
TypeError: 'builtin_function_or_method' object is not subscriptable
```
函数定义时出错,应该是`np.zeros(1)`
```
def fermi_dirac_fitting(Es,Os,Ein=np.zeros(1)):
```


## 面向对象编程学习
### 写错了init的名字,报错没有参数
```python
class deviceOB2:
    def __int__(self,设备类型="IOS",设备编号=0,LINK="ios:///http://192.168.12.130:8100",APPID=None):
        print("hello")
class auto_airtest2:
    def __init__(self, mynode=1, totalnode=1,设备类型="IOS"):
        self.移动端=deviceOB2(设备类型=self.设备类型,设备编号=self.mynode,LINK=self.LINK,APPID=self.APPID)
# 如果文件被直接执行，则执行以下代码块
if __name__ == "__main__":
    run=auto_airtest2()    
```

报错
```
(base) cndaqiang@macmini WZRY_AirtestIDE_emulator$ python object.py
Traceback (most recent call last):
  File "/Users/cndaqiang/git/WZRY_AirtestIDE_emulator/object.py", line 170, in <module>
    run=auto_airtest()
        ^^^^^^^^^^^^^^
  File "/Users/cndaqiang/git/WZRY_AirtestIDE_emulator/object.py", line 167, in __init__
    self.移动端=deviceOB2(设备类型=self.设备类型,设备编号=self.mynode,LINK=self.LINK,APPID=self.APPID)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
TypeError: deviceOB2() takes no arguments
```



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
