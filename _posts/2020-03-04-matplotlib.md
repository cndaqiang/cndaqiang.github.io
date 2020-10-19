---
layout: post
title:  "挖坑 matplotlib 画图"
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

### 文本
#### latex展示
使用`r"$Latex语法$"`
```python
xyz=[r"$\alpha_{xx}$","yy","zz","average"]
```