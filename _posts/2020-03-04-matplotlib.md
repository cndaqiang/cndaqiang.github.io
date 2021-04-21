---
layout: post
title:  "[挖坑]python画图学习"
date:   2020-03-04 20:57:00 +0800
categories: Python
tags:  Python matplotlib
author: cndaqiang
mathjax: true
---
* content
{:toc}

```
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
```








## 参考
[Matplotlib 教程](https://www.runoob.com/w3cnote/matplotlib-tutorial.html)<br>
[wizardforcel Matplotlib 入门教程](https://legacy.gitbook.com/book/wizardforcel/matplotlib-intro-tut/details)

## 注意
- **plt.show()之后会清空画板，所有绘图数据删除，保存前不要执行**
- 在没有图形化界面的环境下，要执行`plt.switch_backend('agg')`
- **官方的案例最好了[Examples](https://matplotlib.org/gallery/index.html)**
- 无图形化的终端画图
```
import matplotlib as mpl
mpl.use('Agg')
import matplotlib.pyplot as plt
```

## 绘图
### 二维图形绘制
```
x=np.linspace(0, 2*np.pi, num=100, endpoint=True)
ysin=np.sin(x)
ycos=np.cos(x)
#创建画板,内含1x1
fig, ax = plt.subplots(1,1,sharex=True,sharey=False,figsize=(8,6))
ax.plot(x,ysin,label="sin")
ax.plot(x,ycos,label="cos")
ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_title("sin and cos")
ax.legend() #上图例，plt里面的label
```
显示`plt.show()`,**plt.show()之后会清空画板，所有绘图数据删除，保存前不要执行**
![](/uploads/2020/03/pltshowq.png)
保存图形命令
```
figfile="sincos.png" #支持png,pdf等多种格式
plt.savefig(figfile,dpi=60)
```
#### 多个画板
```
fig, [ax1,ax2] = plt.subplots(1,2,sharex=True,sharey=False,figsize=(8,6))
ax1.plot(x,ysin,label="sin")
ax2.plot(x,ycos,label="cos")
ax1.set_title("sin")
ax2.set_title("cos")
ax1.legend() #上图例，plt里面的label
ax2.legend() #上图例，plt里面的label
figfile="sincos.png" #支持png,pdf等多种格式
plt.savefig(figfile,dpi=100)
```
也可以
```
fig, ax = plt.subplots(1,2,sharex=True,sharey=False,figsize=(8,6))
ax[0].plot(x,ysin,label="sin")
ax[1].plot(x,ycos,label="cos")
```
![](/uploads/2020/03/sincos2.png)

#### 填充图 
```
ysin=np.sin(x)
ycos=np.cos(x)-0.5
fig, ax = plt.subplots(1,1,sharex=True,sharey=False,figsize=(8,6))
ax.fill_between(x, 0, ysin,alpha=0.5) #,, facecolor='blue', alpha=0.5)
ax.fill_between(x, 0, ycos,alpha=0.5) #,, facecolor='red', alpha=0.5)
```
![](/uploads/2020/03/fill.png)

### 性质
```
axs.set(xlim=xlim, ylim=ylim, title=title, ylabel=ylabel, xlabel=xlabel) 
```
#### y轴显示为科学计数法
[matplotlib刻度值使用科学记数法](https://blog.csdn.net/HackerTom/article/details/112102637)
```
axs.ticklabel_format(style='sci', scilimits=(-1,2), axis='y')
```
- style='sci' 指明用科学记数法；
- scilimits=(-1,2) 表示对 (10^-1,10^2) 范围之外的值换科学记数法，范围内的数不换；
- axis='y' 指明对 y 轴用，亦可以是 x、both。

或者这样
```
import matplotlib.ticker as mtick
axs.yaxis.set_major_formatter(mtick.FormatStrFormatter('%1.1e'))
```

### 文本
#### latex展示
使用`r"$Latex语法$"`
```python
xyz=[r"$\alpha_{xx}$","yy","zz","average"]
```

## 常用代码段
### 画峰值出x坐标
```python
def peaklabel(plt,xdata,ydata):
    scale=1.1
    left=ydata[0:-1]-ydata[1:]*scale>0#我在左面时大
    right=ydata[1:]-ydata[0:-1]*scale>0#我在右面时大
    left=np.append(left,True)
    choose=np.append(left[0],left[1:] & right[:] )
    #choose=choose & ( ydata > np.average(ydata) )
    #choose=choose & ( ydata > np.max(ydata)/5.0 )
    x=xdata[choose]
    y=ydata[choose]
    for xy in zip(x, y):
        plt.annotate("%2.3f" % xy[0], xy=xy, xytext=(-20, 10), textcoords='offset points')
```

### 周期逐增画上x的位置
```python

deltaeV=1.0 #画图标签间隔,可以理解为带间距
N_each_deltaeV=20 #deltaeV内Y方向最多有多少个标签，若超过取余从0计数
mine=-1E15
for i in np.arange(gap.size):
   #垂直线
   plt.vlines(gap[i], ylimit[0], ylimit[1], colors = "g", linestyles = "dashed",color=colors[i])
   #plt.annotate(str(round(gap[i],2)),
   #            xytext=(gap[i], 1.0*(ylimit[1]-ylimit[0])/gap.size*(i+1) ), 
   #            textcoords='offset points',color=colors[i])
   x=gap[i]
   if False:
      left=gap.size - gapnum
      if i < left:
         y=(ylimit[1]-ylimit[0])*1.0/(left+2)*(left-i)+ylimit[0]
      else:
         y=(ylimit[1]-ylimit[0])*1.0/(gapnum+2)*(i-left+1)+ylimit[0]
   else:
      if(gap[i] - mine > deltaeV ):
         mine = gap[i]
         position=1
      else:
         position=position+1
         position=position%N_each_deltaeV
      y=(ylimit[1]-ylimit[0])*(1.0*position/N_each_deltaeV)#在deltaeV内等间距插入N_each_deltaeV个点
   if ( xlimit[0] == None or x > xlimit[0]) and ( xlimit[1] == None or x < xlimit[1] ):
      plt.text(x,y,str(round(gap[i],2)),fontsize=15,
               color=colors[i],
               bbox=dict(boxstyle='square,pad=0.1', fc="white",alpha=1.0,lw=0.0),
               verticalalignment="center",horizontalalignment="center")
```

## 差值拟合
### 高斯滤波器
致谢[@GliderHX](https://github.com/GliderHX)

```python
#原始画图方法
axs.plot(DBgrid,avTDB[i],label=DBlable[i])
#滤波后画图
from scipy.ndimage import gaussian_filter1d
avTDB[i] = gaussian_filter1d(avTDB[i], 2) #参数解释(原始数据,sigma,)
axs.plot(DBgrid,avTDB[i],label=DBlable[i])
```
![](/uploads/2020/12/gauss.png)

### 插值
致谢[@GliderHX](https://github.com/GliderHX)<br>
[10. Scipy Tutorial-插值interp1d](http://liao.cpython.org/scipytutorial10/)

```python
from scipy.interpolate import interp1d
#获得插值函数的参数
f = interp1d(x, y, kind='cubic')#参数(原始数据x,y,插值算法)
#计算插值数据
xx = np.linspace(5,10,10000)
yy = f(xx)
```
插值算法有`'linear', 'nearest', 'zero', 'slinear', 'quadratic', 'cubic'`
- linear 线性
- cubic 三次

高斯滤波后再插值效果更好
![](/uploads/2020/12/spec.png)




------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
