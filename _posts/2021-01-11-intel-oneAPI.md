---
layout: post
title:  "Intel® oneAPI Toolkits(Intel Parallel Studio XE的代替品)安装使用"
date:   2021-01-11 19:00:00 +0800
categories: Linux
tags:  Intel oneAPI MPI
author: cndaqiang
mathjax: true
---
* content
{:toc}

Intel® oneAPI Toolkits(Intel Parallel Studio XE的代替品)安装使用<br>
以后个人PC再也不用下载那么大的Intel Parallel Studio XE和定期申请激活码了







## 参考
[Installing Intel® oneAPI Toolkits via APT](https://software.intel.com/content/www/cn/zh/develop/articles/installing-intel-oneapi-toolkits-via-apt.html)

[Installing Intel® oneAPI Toolkits via YUM (DNF)](https://software.intel.com/content/www/us/en/develop/articles/installing-intel-oneapi-toolkits-via-yum.html)

## Mint19安装记录
centos系可以参考[Installing Intel® oneAPI Toolkits via YUM (DNF)](https://software.intel.com/content/www/us/en/develop/articles/installing-intel-oneapi-toolkits-via-yum.html)

### 安装
完全按照[Installing Intel® oneAPI Toolkits via APT](https://software.intel.com/content/www/cn/zh/develop/articles/installing-intel-oneapi-toolkits-via-apt.html)
的教程
```shell
cndaqiang@mommint:~/work/tdpw/Restart-2020-12-24/rpmd/RPMD.in_B2$ cd /tmp
cndaqiang@mommint:/tmp$ wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
cndaqiang@mommint:/tmp$ sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
cndaqiang@mommint:/tmp$ echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
cndaqiang@mommint:/tmp$ sudo apt update
#....
(python37) cndaqiang@mommint:/tmp$ sudo apt install intel-basekit
#有点漫长
```
### 查找其他的可选安装包
```
cndaqiang@mommint:/tmp$ sudo apt-cache pkgnames intel | grep kit$
intel-aikit
intel-iotkit
intel-basekit
intel-dlfdkit
intel-renderkit
intel-hpckit
```
### 安装编译器
```
cndaqiang@mommint:/tmp$ sudo apt install intel-hpckit
```
所有的程序都安装到了`/opt/intel`,如`icc,ifort`
```
cndaqiang@mommint:/tmp$ ls /opt/intel/oneapi/compiler/latest/linux/bin/intel64
codecov  fortcom  fpp  icc  icc.cfg  icpc  icpc.cfg  ifort  ifort.cfg  libcilkrts.so.5  map_opts  mcpcom  profdcg  profmerge  profmergesampling  proforder  tselect  xiar  xiar.cfg  xild  xild.cfg
```
### 启用环境
```
source /opt/intel/oneapi/compiler/latest/env/vars.sh intel64
source /opt/intel/oneapi/mpi/latest/env/vars.sh intel64
source /opt/intel/oneapi/mkl/latest/env/vars.sh intel64
```

### module
各个组件也提供了module file好评
```
cndaqiang@mommint:/opt/intel/oneapi$ ls mpi/latest/modulefiles
mpi
```

## 编译测试
### QE-6.6
```
./configure MPIF90=mpiifort FC=ifort CC=icc
```
没有问题,数学库也识别了
```
The following libraries have been found:
  BLAS_LIBS=  -lmkl_intel_lp64  -lmkl_sequential -lmkl_core
  LAPACK_LIBS=
  FFT_LIBS=
```
编译
```
make pwall -j20
```
可以运行

### VASP-6.1
```
tar xvf vasp.6.1.0.tar vasp.6.1.0/
cd vasp.6.1.0/
cp arch/makefile.include.linux_intel makefile.include
echo \$MKLROOT=$MKLROOT >> makefile.include
make
#除了GPU版都编译通过
cndaqiang@mommint:~/code/vasp.6.1.0$ ls bin/
vasp_gam  vasp_ncl  vasp_std
```
运行正常
```
cndaqiang@mommint:~/work/vasp/H2O$ mpirun -np 10 vasp_std
 running on   10 total cores
 distrk:  each k-point on   10 cores,    1 groups
 distr:  one band on    1 cores,   10 groups
 using from now: INCAR
 vasp.6.1.0 28Jan20 (build Jan 11 2021 20:12:18) complex
```

------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
