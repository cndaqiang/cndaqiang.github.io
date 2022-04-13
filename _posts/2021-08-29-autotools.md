---
layout: post
title:  "[草稿]使用autotools创建configure,Makefile"
date:   2021-08-29 20:04:00 +0800
categories: Fortran
tags:  Fortran mpi
author: cndaqiang
mathjax: true
---
* content
{:toc}

编译程序时,常遇到使用`./configure`生成Makefile的方式,使用autotool可以创建`configure`<br>
边用边补充




## 参考
⭐⭐[unix上c项目构建过程简析](https://fantiq.github.io/2019/03/06/unix%E4%B8%8Ac%E9%A1%B9%E7%9B%AE%E6%9E%84%E5%BB%BA%E8%BF%87%E7%A8%8B%E7%AE%80%E6%9E%90/)<br>
[Petazzoni.pdf@elinux](https://elinux.org/images/4/43/Petazzoni.pdf)<br>
[linux使用---automake学习(从原理到实践，一步步完成automake)](https://www.huaweicloud.com/articles/86875c5d72bc078e6736cd17edc66e03.html)<br>



## 流程图
**我们需要准备`configure.ac`&`Makefile.am`**
- `configure.ac`或`configure.in`
- - 可由`autoscan`生成模版然后修改
- - 也可以自己写
- - **所有文件的生成都离不开`configure.ac`**
- - **定义需要的编译器类型(C/Fortran/CXX/...),程序名,版本号,automake等程序的要求,......**
- `Makefile.am`
- - 自己写
- - **`automake`根据`makefile.am`生成`Makefile.in`,最终生成Makefile**
- - **和源码直接相关**,定义了需要编译的程序,该程序需要的源代码文件,以及依赖关系等等
- - 可以写入Makefile的代码
- - **目前没发现autotools可以检测源代码之间的依赖关系,所以还要在这里添加上依赖关系(或者通过include的方式)**
- 头文件暂略

![](/uploads/2021/08/autotools.jpg)

## 示例
文件列表
```
.
├── configure.ac 编译配置
├── qtool.f90    源码
├── Makefile.am Makefile配置
└── m_mod.f90 源码
```
执行顺序
```
aclocal
#automake和autoconf无先后之分
automake
autoconf
./configure --prefix=$HOME/soft/qtool FC=ifort
make
make instal
~/soft/qtool/bin/qtool
```
~~后续如果更新了`configure.ac,Makefile.am`可以通过`autoreconf`一键更新~~


**通过`make dist`可以打包成发布版本,如[qtool-1.0.tar.gz](/web/file/2021/08/qtool-1.0.tar.gz). 里面也包含了`configure.ac`&`Makefile.am`**
![](/uploads/2021/08/autorun.jpg)

## 配置文件
`configure.ac`&`Makefile.am`的参数多同时生效,两个文件不是独立的

### `configure.ac`
[编写configure.ac](https://blog.csdn.net/john_crash/article/details/49889949)

可由`autoscan`生成模版然后修改<br>
**`configure.ac`用于生成`configure`,`configure.ac`里面的注释和shell脚本会被复制到`configure`中去,配置的命令也会被转译成`configure`中相应的命令**
猜
- `AC`autoconf
- `AM`automake

```bash
#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
# 要求的autoconf版本
AC_PREREQ([2.69])
#AC_INIT开始, 程序名,版本号, 出错联系方法
AC_INIT([qtool], [1.0], [who@cndaqiang.ac.cn])

#使用autoreconf调用automake生成Makefile.in, (或者自己执行automake时)会根据此参数检测是否复合响应的发布标准
#里面跟的参数是Makefile.am中的AUTOMAKE_OPTIONS参数，详见下
#如gnu需要NEWS,README, AUTHORS, etc
AM_INIT_AUTOMAKE([foreign 1.15.1])
#foreign,dist-bzip2,dist-xz等等
#后面的版本是automake的最低版本，automake --version 获得automake版本

#源代码文件,用于autoconf检查是否准备好了
AC_CONFIG_SRCDIR([qtool.f90])

#确保编译器等程序可用,AC_PROG_CC,AC_PROG_CXX,AC_PROG_AWK,AC_PROG_GREP,AC_PROG_F77
AC_PROG_FC

#从AC_CONFIG_FILES, 用file.in创建file
AC_CONFIG_FILES([Makefile])
#Makefile.in定义一些变量和要实现的目标
#Makefile.in可以自己写,也可以通过automake生成
#automake需要Makefile.am生成Makefile.in
#AC_OUTPUT结束

#
#AC_CONFIG_HEADERS([config.h])
#用autoheader从config.h.in产生
#最终的头文件有configure产生为config.h

AC_OUTPUT

```

#### `AC_SUBST`定义变量
```
AC_SUBST([变量名], [值])
```
例如
```
AC_SUBST([QLIBS],[-lgsl])
```
可以在`Makefile.am`中使用`QLIBS`的变量
```
qtool_LDADD=-lxcf90 $(QLIBS)
```
也可以
```
QLIBS=-lgsl2
AC_SUBST([QLIBS])
```
或
```
AC_SUBST([QLIBS])
QLIBS=-lgsl3
```

#### 使用bash语法
因为`configure.ac`中的`[ ]`会在翻译成`configure`时会被删除,因此不能直接用`if [ 判读语句 ]`的方式进行判断,可以使用`test`,如根据环境变量定义变量<br>
**bash语法错误,不会被报错,是转译到configure的,执行`./configure`时报错**
```
if test "$USER" = cndaqiang
then
        QLIBS=-lqqq
fi
AC_SUBST([QLIBS])
```


### `Makefile.am`


- `automake`提示缺少文件时`automake --add-missing`
- **至少包含`bin_PROGRAMS`和其源码`xxxx_SOURCES`**
- `automake`会同时读取`makefile.am`和 **`configure.ac`**



```makefile
#用于生成Makefile.in
#Makefile.in定义一些变量和要实现的目标
#可以直接写Makefile的语法

#参数有默认值,如AUTOMAKE_OPTIONS
#如AUTOMAKE_OPTIONS用于检查软件的发布规范,参数:foreign,gnu,gnits,不同规法需要提供的文件不同
#如设置AUTOMAKE_OPTIONS=foreign时,需要missing install-sh文件
#如设置AUTOMAKE_OPTIONS=gnu时,需要存在INSTALL NEWS README AUTHORS ChangeLog COPYING文件
#如果不存在这些文件,可通过automake --add-missing自动补全
#也可以通过touch INSTALL NEWS README AUTHORS ChangeLog COPYIN 解决
#
AUTOMAKE_OPTIONS=gnu

#至少包含bin_PROGRAMS和其源码 xxxx_SOURCES,将会安装到$prefix/bin,可以有多个程序
bin_PROGRAMS=qtool
#编译源程序,并链接到可执行程序
qtool_SOURCES=qtool.f90 m_mod.f90 test_pp.F90
#可选,其他的库,具体效果见下
#最后生成可执行文件时添加的库
qtool_LDADD=-lxcf90
#预编译源码的参数
qtool_CPPFLAGS=-I/usr/include/
#qtool_LIBADD=

#依赖关系
qtool.o:m_mod.o
```

`qtool_LDADD=-lxcf90`和`qtool_CPPFLAGS=-I/usr/include/`对编译的影响
```
gfortran -DPACKAGE_NAME=\"qtool\" -DPACKAGE_TARNAME=\"qtool\" -DPACKAGE_VERSION=\"1.0\" -DPACKAGE_STRING=\"qtool\ 1.0\" -DPACKAGE_BUGREPORT=\"who@cndaqiang.ac.cn\" -DPACKAGE_URL=\"\" -DPACKAGE=\"qtool\" -DVERSION=\"1.0\" -I.  -I/usr/include/   -g -O2 -c -o qtool-test_pp.o `test -f 'test_pp.F90' || echo './'`test_pp.F90
gfortran  -g -O2   -o qtool qtool.o m_mod.o qtool-test_pp.o -lxcf90
```



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
