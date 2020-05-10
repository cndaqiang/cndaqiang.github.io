---
layout: post
title:  "Intel Parallel Studio XE 编译siesta "
date:   2018-03-13 21:15:00 +0800
categories: DFT
tags: siesta Intel
author: cndaqiang
mathjax: true
---
* content
{:toc}

编译vasp方法类似,编译环境的安装参考[Intel Parallel Studio XE 编译VASP](/2018/01/15/intel-mpi-vasp/),只需要安装Intel Parallel Studio XE即可,安装运行遇到的其他问题和本文相关命令的解释见[Intel Parallel Studio XE 编译VASP](/2018/01/15/intel-mpi-vasp/)






## 安装Intel Parallel Studio XE
略
## 编译siesta
下载后
```
siesta-4.1-b1-intel/Obj$ cd Obj
siesta-4.1-b1-intel/Obj$ ../Src/obj_setup.sh 
 *** Compilation setup done. 
 *** Remember to copy an arch.make file or run configure as:
    ../Src/configure [configure_options]
#制定编译器,生成arch.make
siesta-4.1-b1-intel/Obj$ ../Src/configure --enable-mpi FC=ifort CC=ifort MPIFC=mpiifort
```
修改arch.make设置mkl数学库
```
MKL_PATH   = /opt/intel/compilers_and_libraries_2018.0.128/linux/mkl/lib/intel64
BLAS_LIBS=-L$(MKL_PATH) -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread -lmkl_blacs_intelmpi_lp64 -lmkl_scalapack_lp64
LAPACK_LIBS=
BLACS_LIBS=
SCALAPACK_LIBS=
```
然后
```
make
```
## 测试
以siesta-4.1为例,根目录有`Tests`文件夹,里面有示例
<br>修改Tests/test.mk
<br>设置并行核数和siesta地址
```
MPI=mpirun -np 2
SIESTA=<siesta的编译目录>/Obj/siesta
```
进如Tests内的任一示例目录
```
make
```
结果分析
