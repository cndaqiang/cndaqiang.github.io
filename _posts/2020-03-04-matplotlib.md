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
[Python中画图时候的线类型](https://blog.csdn.net/qq_34940959/article/details/78488208)


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

#### 颜色（color 简写为 c）：

![](/uploads/2021/05/color.png)


- 蓝色： 'b' (blue)
- 绿色： 'g' (green)
- 红色： 'r' (red)
- 蓝绿色(墨绿色)： 'c' (cyan)
- 红紫色(洋红)： 'm' (magenta)
- 黄色： 'y' (yellow)
- 黑色： 'k' (black)
- 白色： 'w' (white)
- 灰度表示： e.g. 0.75 ([0,1]内任意浮点数)
- RGB表示法： e.g. '#2F4F4F' 或 (0.18, 0.31, 0.31)
- 任意合法的html中的颜色表示： e.g. 'red', 'darkslategray'

**得到n个颜色**
```python
cmap = plt.cm.get_cmap("viridis", n)
colors = cmap(np.linspace(0, 1, n))
#循环取颜色
color=colors[i%len(colors)]
```

更多颜色序列
![](/uploads/2021/10/colororder.png)

反向颜色序列加`_r`
```
 supported values are 'Accent', 'Accent_r', 'Blues', 'Blues_r', 
 'BrBG', 'BrBG_r', 'BuGn', 'BuGn_r', 'BuPu', 'BuPu_r', 'CMRmap', 
 'CMRmap_r', 'Dark2', 'Dark2_r', 'GnBu', 'GnBu_r', 'Greens', 
 'Greens_r', 'Greys', 'Greys_r', 'OrRd', 'OrRd_r', 'Oranges', 
 'Oranges_r', 'PRGn', 'PRGn_r', 'Paired', 'Paired_r', 'Pastel1', 
 'Pastel1_r', 'Pastel2', 'Pastel2_r', 'PiYG', 'PiYG_r', 'PuBu', 
 'PuBuGn', 'PuBuGn_r', 'PuBu_r', 'PuOr', 'PuOr_r', 'PuRd', 'PuRd_r', 
 'Purples', 'Purples_r', 'RdBu', 'RdBu_r', 'RdGy', 'RdGy_r', 'RdPu', 
 'RdPu_r', 'RdYlBu', 'RdYlBu_r', 'RdYlGn', 'RdYlGn_r', 'Reds', 
 'Reds_r', 'Set1', 'Set1_r', 'Set2', 'Set2_r', 'Set3', 'Set3_r', 
 'Spectral', 'Spectral_r', 'Wistia', 'Wistia_r', 'YlGn', 'YlGnBu', 
 'YlGnBu_r', 'YlGn_r', 'YlOrBr', 'YlOrBr_r', 'YlOrRd', 'YlOrRd_r', 
 'afmhot', 'afmhot_r', 'autumn', 'autumn_r', 'binary', 'binary_r', 
 'bone', 'bone_r', 'brg', 'brg_r', 'bwr', 'bwr_r', 'cividis', 
 'cividis_r', 'cool', 'cool_r', 'coolwarm', 'coolwarm_r', 'copper', 
 'copper_r', 'cubehelix', 'cubehelix_r', 'flag', 'flag_r', 
 'gist_earth', 'gist_earth_r', 'gist_gray', 'gist_gray_r', 
 'gist_heat', 'gist_heat_r', 'gist_ncar', 'gist_ncar_r', 
 'gist_rainbow', 'gist_rainbow_r', 'gist_stern', 'gist_stern_r', 
 'gist_yarg', 'gist_yarg_r', 'gnuplot', 'gnuplot2', 'gnuplot2_r', 
 'gnuplot_r', 'gray', 'gray_r', 'hot', 'hot_r', 'hsv', 'hsv_r', 
 'inferno', 'inferno_r', 'jet', 'jet_r', 'magma', 'magma_r', 
 'nipy_spectral', 'nipy_spectral_r', 'ocean', 'ocean_r', 'pink', 
 'pink_r', 'plasma', 'plasma_r', 'prism', 'prism_r', 'rainbow', 
 'rainbow_r', 'seismic', 'seismic_r', 'spring', 'spring_r', 'summer', 
 'summer_r', 'tab10', 'tab10_r', 'tab20', 'tab20_r', 'tab20b', 
 'tab20b_r', 'tab20c', 'tab20c_r', 'terrain', 'terrain_r', 'turbo', 
 'turbo_r', 'twilight', 'twilight_r', 'twilight_shifted', 
 'twilight_shifted_r', 'viridis', 'viridis_r', 'winter', 'winter_r'
```

#### 线型（linestyle 简写为 ls）：

- 实线： '-'
- 虚线： '--'
- 虚点线： '-.'
- 点线： ':'
- 点： '.' 


#### 点型（标记marker）：

- 像素： ','
- 圆形： 'o'
- 上三角： '^'
- 下三角： 'v'
- 左三角： '<'
- 右三角： '>'
- 方形： 's'
- 加号： '+' 
- 叉形： 'x'
- 棱形： 'D'
- 细棱形： 'd'
- 三脚架朝下： '1'（就是丫）
- 三脚架朝上： '2'
- 三脚架朝左： '3'
- 三脚架朝右： '4'
- 六角形： 'h'
- 旋转六角形： 'H'
- 五角形： 'p'
- 垂直线： '|'
- 水平线： '_'
- gnuplot 中的steps： 'steps' （只能用于kwarg中）


标记大小（markersize 简写为 ms）： 
markersize： 实数
 
标记边缘宽度（markeredgewidth 简写为 mew）：
markeredgewidth：实数

标记边缘颜色（markeredgecolor 简写为 mec）：
markeredgecolor：颜色选项中的任意值

标记表面颜色（markerfacecolor 简写为 mfc）：
markerfacecolor：颜色选项中的任意值

透明度（alpha）：
alpha： [0,1]之间的浮点数

线宽（linewidth）：
linewidth： 实数


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

### 清空
```
plt.cla()
```
### Axis  上下左右线，即坐标轴
```
    #设置x轴标签及其字号
    plt.xlabel(xlabel,fontsize=Fontsize)
    #设置y轴标签及其字号
    plt.ylabel(ylabel,fontsize=Fontsize)
    #宽度
    axs.spines["bottom"].set_linewidth(axisw)
    axs.spines["top"].set_linewidth(axisw)
    axs.spines["left"].set_linewidth(axisw)
    axs.spines["right"].set_linewidth(axisw)
```
### ticks 上下左右线上的小刻度
```
#ticks位置
axs.set_xticks(ticks)
#ticks标签
axs.set_xticklabels(tickslabel)
#等价于
axs.set(xticks=ticks, xticklabels=tickslabel)

# 设置xtick和ytick的方向：in、out、inout
plt.rcParams['xtick.direction'] = 'in'
plt.rcParams['ytick.direction'] = 'in'
```

### 对数坐标
```python
axs.set_yscale("log")
#要在设置xlim,ylim之前设置,不然在前面的设置的xlim等信息会无效
axs.set(xlim=xlim,ylim=ylim,ylabel=ylabel, xlabel=xlabel)
```

### 其他
#### 水平线
```
matplotlib.pyplot.axhline(y=0, xmin=0, xmax=1, hold=None, **kwargs)
import matplotlib.pyplot as plt
plt.axhline(y=0, xmin=0, xmax=1, hold=None, **kwargs)
#
plt.hlines(y, xmin, xmax)
plt.hlines(0, 0, 0.5, colors = "r", linestyles = "dashed")
```
#### 垂直线
```
matplotlib.pyplot.axvline(x=0, ymin=0, ymax=1, hold=None, **kwargs)
vlines(x, ymin, ymax)
```

#### 透明背景
```
      plt.savefig(filename,dpi=200,transparent=True)
```



## 扇形图
```
plt.pie([1.0/2,1.0/3,1.0/6],labels=[1,2,3],colors = ['tomato', 'lightskyblue', 'goldenrod'])
```

![](/uploads/2021/10/pie123.png)


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

### scatter画的图层比plot要低
即使先用`plot`画图,再画`scatter`,散点图也会在plot的图下面,通过`zorder`指定图层顺序,把散点图整上去
```python
axs.plot(xpoint,EIG[:,ispin,ibnd],label=label,color=colors[icolor],linewidth=bandw,zorder=ibnd)
axs.scatter(xpoint, EIG[:,ispin,ibnd], s=add  [:,ispin,ibnd]*scale, color= "red" , alpha=1.0,zorder=ibnd+5)  
```


## 最新理解
matplot皆是基于对象画图.
- 每一个图,每一条线都是一个对象,可以进行设置
- 注意`subplots`和`subplot`含义不同

### 一些有助于学习的命令
- `dir(plt)` 查看该对象的子属性和方法
- `plt.getp(plt)` 查看该对象可以设置的图形属性,如背景色,字体等
- `plt.setp(plt,key="value")` 设置该对象(或者群组)的图形属性,同上
- 查看源代码  
```python
import inspect
print(inspect.getsource(plt.plot))
```

### plt,figure,axes,axis的关系
- `plt`只有一个,用于生成和调控各种对象  
  - Artist对象包括简单类型(e.g. 图形,文字),**容器类型(Figure,Axes,Axis)**
- `figure`和Matlab中的Figure类似,**每一个figure就是一个画图窗口,不同figure之间是独立的**  
  - 创建figure `plt.figure()`(一个大图),`plt.subplots()`(带子图)
  - `figure`的编号从`1`开始  
     查看有几个figure: `plt.get_fignums()`  
     切换活动figure`plt.figure(i)`,i=1,2,...,N in `plt.get_fignums()`    
  - ,`plt.savefig("test.png")`只能保存当前的活动figure
  - **`plt.gcf()`获得当前的figure对象**
  - 重新调整大小`plt.gcf().set_size_inches(1, 3)`
- axes,子图,**绘图子区域**  
  - axes是figure的下层对象,`plt.gcf().axes[0-N]`是figure上包含的一些列的子图区域
  - 每个figure中可以创建多个子图,即划分成多个绘图区域
  - 创建子图的方法  
  `plt.subplots(2,2)`在创建figure时创建  
  `plt.subplot(231)` 在当前的figure中添加一个  
  `plt.subplot2grid()` 更加的随意,给初始点和尺寸创建
  - 子图的作用: 画多幅图,把colorbar画到别的子图上,实现colorbar随意位置
  - **`plt.gca()`获得当前的axes**
  - 可以在一个figure上不断添加绘图区域,如果新增的区域和之前的区域重合,则旧区域会被删除,如  
```python
#先按照2x2创建了4个子图
fig,axs=plt.subplots(2,2)
#创建了4个子图,gca()默认指向第一个子图,axs是所有子图的集合
plt.gca().patch.set_facecolor("green")
axs[0,1].patch.set_facecolor("blue")
#修改axis对象
axis=axs[0,1].xaxis
axis.set(ticks=[])
#
#又按照2x3的规则,在2x3的第一个区创建了一个子图,原来的第一个子图就会被覆盖掉
axs231=plt.subplot(231)
#只创建了一个新子图,等号左边赋值,则后面直接可以用axs231操纵这个区域
plt.gca().patch.set_facecolor("red")
plt.plot(x,x/(x+1))
#
#又按照把figure分成4x4份,以行3列1为起点,选取行1列2的区域,最初2x2的左下角会被覆盖掉
plt.subplot2grid((4,4),(3,0),rowspan=1,colspan=2)
#只创建了一个新子图
plt.gca().patch.set_facecolor("yellow")
plt.plot(x,x)
#
#所有的子图都存在列表plt.gcf().axes里,新增的子图顺序在前面
plt.gcf().axes[0].plot(x,x*0+1)
plt.gcf().axes[1].plot(x,x*0+10)
plt.gcf().axes[2].plot(x,x*0+20)
plt.gcf().axes[3].plot(x,x*0+30)
#
plt.savefig("test.png")
```
![](/uploads/2022/04/subpot.png)
- **axis,图的元素,刻度线,坐标轴,标题等**  
  - axis是axes的下层对象,`plt.gca().xaxis`是axes上的x轴
  - axes提供了一些创建axis的方法,通过`dir(plt.gca())`发现`plt.gca().set_xlabel("xlabel")`
  - plt也提供了一些,如`plt.xlabel("XXlabel")`
  - 获得x轴并修改,结果如上图  
```python
#修改axis对象
axis=axs[0,1].xaxis
axis.set(ticks=[])
```


### 修改对象的性质
- `plt.getp`查看,然后使用`plt.setp`,`.set_**`的方式修改  
   - 问题是,查看到的性质,并不能全部套用`plt.setp`,`.set_**`的方式去修改
- 不同层级的对象可能体统实现相同功能的方法,如  
`plt.xlabel("XXlabel")`和`plt.gca().set_xlabel("xlabel")`


#### getp可以查看的性质修改
- `getp`,查看对象的性质  
  - `plt.getp(fig)`,`plt.getp(axes)`,`plt.getp(axis)`  
  - 示例`plt.getp(plt.gca().xaxis)`
```
    ticks_direction = ['in' 'in' 'in' 'in']
    ticks_position = bottom
```
- `getp`查看到的性质,都可以用`setp`修改, 示例  
`plt.setp(plt.gca().xaxis,ticks_position = "top")`  
`setp`的好处是可以同时设置一组对象,如`plt.setp(plt.gcf().axes,xlabel="xlabel")`  
然而问题是,我们不查手册,不好设置输入,如`plt.setp(plt.gca().xaxis,ticks_direction = ['in' 'in' 'in' 'in'] )` 这样设置就会报错  
- 和setp等价的方式,每个对象的`a.set_性质()`
`plt.gca().xaxis.set_ticks_position("bottom")`  
同样的问题,不存在`plt.gca().xaxis.set_ticks_direction(['in' 'in' 'in' 'in'])`

#### dir()直接查看有哪些方法可以调用进行修改

```
dir(plt)
[
#...
 'xscale',
 'xticks',
 'ylabel',
 'ylim',
 'yscale',
 'yticks']
 ]
```

#### 搜索引擎...


## 默认画图参数设置
### 参数设置
```python
#设置默认字体大小
plt.rcParams['font.size']=fontsize
plt.rcParams['axes.labelsize']=fontsize+2

plt.rcParams['xtick.major.width']=majorticksw
plt.rcParams['ytick.major.width']=majorticksw
plt.rcParams['xtick.minor.width']=minorticksw
plt.rcParams['ytick.minor.width']=minorticksw
plt.rcParams['xtick.direction']="in"
plt.rcParams['ytick.direction']="in"
```
### 文件设置
```
import matplotlib as mpl
mpl.get_configdir()
```
修改返回目录`'/home/cndaqiang/.config/matplotlib'`的`matplotlibrc`文件,或者运行目录的`matplotlibrc`文件,
```
#按照字典的方式写好
font.size           : 100.0
```
可以参考`~/anaconda3/./lib/python3.7/site-packages/matplotlib/mpl-data/matplotlibrc`文件




------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
