---
layout: post
title:  "编译vasp5.4.1+VTST"
date:   2018-12-07 20:28:00 +0800
categories: DFT
tags:  vasp 过渡态 NEB
author: cndaqiang
mathjax: true
---
* content
{:toc}



## 参考
科大李会民老师的[VASP 5.4.1+VTST编译安装](http://hmli.ustc.edu.cn/doc/app/vasp.5.4.1-vtst.htm)
<br>[Installation — Transition State Tools for VASP](http://theory.cm.utexas.edu/vasp/installation.html)

## 编译
### 下载代码
下面的下载地址已失效，从这里下载：[http://theory.cm.utexas.edu/vtsttools/download.html](http://theory.cm.utexas.edu/vtsttools/download.html)
```
wget http://theory.cm.utexas.edu/code/vtstcode.tgz
```
编译不用这个脚本，不过在NEB过渡态和其他处理中这个脚本都有用
```
wget http://theory.cm.utexas.edu/code/vtstscripts.tgz
```
### 增加VTST代码
解压`vtstcode.tgz`后，复制里面的内容到vasp目录下`src`目录

## 修改代码，增加编译依赖关系
修改`src/main.F`文件，在3222行
将

````
3222       CALL CHAIN_FORCE(T_INFO%NIONS,DYN%POSION,TOTEN,TIFOR, &
3223            LATT_CUR%A,LATT_CUR%B,IO%IU6)
```

修改为

```
3222       CALL CHAIN_FORCE(T_INFO%NIONS,DYN%POSION,TOTEN,TIFOR, &
3223            TSIF,LATT_CUR%A,LATT_CUR%B,IO%IU6)
3224            !LATT_CUR%A,LATT_CUR%B,IO%IU6)
```
在`src/.objects`里面的chain.o前面添加
```
bfgs.o dynmat.o instanton.o lbfgs.o sd.o cg.o dimer.o bbm.o \
fire.o lanczos.o neb.o qm.o opt.o \
```
例如
```
 67         bfgs.o dynmat.o instanton.o lbfgs.o sd.o cg.o dimer.o bbm.o \
 68         fire.o lanczos.o neb.o qm.o opt.o \
 69         chain.o \
```

### 编译

编译设置与编译vasp没有区别，参考[Intel Parallel Studio XE 编译VASP ](/2018/01/15/intel-mpi-vasp/)




------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
