---
layout: post
title:  "Intel MPI编译BerkeleyGW"
date:   2022-10-21 11:51:00 +0800
categories: DFT
tags: vasp centos Intel
author: cndaqiang
mathjax: true
---
* content
{:toc}

编译BerkeleyGW





# 下载源代码
[BerkeleyGW](https://berkeleygw.org/)

```
[HUAIROU cndaqiang@login01 ifort-impi2020]$tar xzvf BerkeleyGW-3.0.1.tar.gz
[HUAIROU cndaqiang@login01 ifort-impi2020]$cd BerkeleyGW-3.0.1
```

# 编译环境
以怀柔服务器为例
```
module unload openmpi3/3.1.4
module load parallel_studio/2020.2.254
module load intelmpi/2020.2.254
module load gnu8/8.3.0
```

# 配置编译参数
### flavor.mk
```
[HUAIROU cndaqiang@login01 BerkeleyGW-3.0.1]$cp flavor_cplx.mk flavor.mk
```
## arch.mk
```
[HUAIROU cndaqiang@login01 BerkeleyGW-3.0.1]$cp config/edison.nersc.gov_intel.mk arch.mk
```
修改`vi arch.mk`
- 因为我没装HDF5,注释掉HDF5相关的内容

```
MATHFLAG  = -DUSESCALAPACK -DUNPACKED -DUSEFFTW3
# -DHDF5
#HDF5_LDIR    =  $(HDF5_DIR)/lib
#HDF5LIB      =  $(HDF5_LDIR)/libhdf5hl_fortran.a \
#                $(HDF5_LDIR)/libhdf5_hl.a \
#                $(HDF5_LDIR)/libhdf5_fortran.a \
#                $(HDF5_LDIR)/libhdf5.a -lz -ldl
#HDF5INCLUDE  = $(HDF5_DIR)/include
```
- 使用intel家编译器mpiicc mpiicpc mpiifort

```
FCPP    = /usr/bin/cpp -ansi
F90free = mpiifort -free -qopenmp
LINK    = mpiifort -qopenmp
FOPTS   = -O3  -g
FNOOPTS = $(FOPTS)
MOD_OPT = -module
INCFLAG = -I

C_PARAFLAG  = -DPARA -DMPICH_IGNORE_CXX_SEEK
CC_COMP = mpiicpc
C_COMP  = mpiicc
C_LINK  = mpiicc
C_OPTS  = -O3  -qopenmp
C_DEBUGFLAG =
```

最终我的[arch.mk](/web/file/2022/arch.mk)

## 编译
### 编译epsilon
```
[HUAIROU cndaqiang@login01 BerkeleyGW-3.0.1]$make epsilon -j40
```
### 编译所有
```
[HUAIROU cndaqiang@login01 BerkeleyGW-3.0.1]$make all-flavors -j 40
```




## 报错
### 预处理不合适
去掉`FCPP    = /usr/bin/cpp -ansi -C`中的`-C`参数, 更多解决办法见[Fortran预处理引入/usr/include/stdc-predef.h报错Unclassifiable statement](/2018/09/18/centos7-octopus-4.1.2/)

```
<命令行>(1): warning #5117: Bad # preprocessor line
# 1 "/usr/include/stdc-predef.h" 1 3 4
-----------------------------------^
/usr/include/stdc-predef.h(1): error #5082: Syntax error, found '/' when expecting one of: <LABEL> <END-OF-STATEMENT> ; <IDENTIFIER> TYPE MODULE ELEMENTAL IMPURE NON_RECURSIVE ...
/* Copyright (C) 1991-2012 Free Software Foundation, Inc.
^
```



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
