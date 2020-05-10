---
layout: post
title:  "Fortran 函数库的使用"
date:   2019-02-01 12:09:00 +0800
categories: Fortran
tags:  Fortran
author: cndaqiang
mathjax: true
---
* content
{:toc}


shell+gfortran





## 参考
[《Fortran实用编程》系列视频教程 - Fortran Coder 研讨团队](http://v.fcode.cn/)<br>



## 静态库(.a) 动态库(.so)

**不同的编译器编译的函数库不能混用**

编译`.o`时不用链接其他需要的对象

编译主程序时，要在后面放上所有的对象

如

```
#-c编译，不用编入其他.o
m_matradd.o : m_matradd.f90 $(MPI)
               $(FC) $(FCFLAGE) -c -o $@  m_matradd.f90

#生成主程序，要所有对象
test:$(TEST) $(MPI)
        $(FC)  $(FCFLAGE)   -o $@  $(TEST) $(MPI)  $(LIB)
```



### lib静态库(.a)

静态库 lib，实际上，就是 obj 文件的集合。可以认为是打包在一起的若干 obj

#### 编译使用

因此它的编译过程是：

- 1.编译子程序源代码，得到若干 obj 文件 `gfortran -c xxx.f90 xx.f90`

- 2.打包这些 obj 文件，成为 lib 静态库`ar rv xxx.a xxx.o xxxx.o xx.o `

它的使用过程也比较简单：

编译主程序（或其他子程序），链接时，带上 lib 文件即可，与多文件编译链接一样

使用静态库编译的程序，运行时不依赖静态库

当然，有些编译器提供动态库，还是动态链接的,用`ldd a.out`可以查看，所以编译程序时，要设置好编译器的动态库,如`export LD_LIBRARY_PATH=/home/cndaqiang/soft/gcc-4.8.4/lib64:$LD_LIBRARY_PATH`

示例

```
cndaqiang@DESKTOP-N5I64SI:lib$ ls
fun.f90  main.f90  sub2.f90
cndaqiang@DESKTOP-N5I64SI:lib$ cat main.f90
program main
      use fun
      implicit none
      call sub1()
      call sub2()
end program main
cndaqiang@DESKTOP-N5I64SI:lib$ cat fun.f90
Module fun
      implicit none
      contains
              subroutine sub1()
                      implicit none
                      write(*,*) "this is sub1"
              end subroutine sub1
end module fun
cndaqiang@DESKTOP-N5I64SI:lib$ cat sub2.f90
subroutine sub2()
      implicit none
      write(*,*) "this is sub2"
end subroutine sub2
cndaqiang@DESKTOP-N5I64SI:lib$ gf -c fun.f90 sub2.f90
cndaqiang@DESKTOP-N5I64SI:lib$ ls
fun.f90  fun.mod  fun.o  main.f90  sub2.f90  sub2.o
!此处的fun.mod类似与为module的描述文件，需要有，才能正常调用module
cndaqiang@DESKTOP-N5I64SI:lib$ ar rv libfun.a fun.o sub2.o  !打包成静态库
ar: creating libfun.a
a - fun.o
a - sub2.o
cndaqiang@DESKTOP-N5I64SI:lib$ gf main.f90 libfun.a    !链接程序和静态库
cndaqiang@DESKTOP-N5I64SI:lib$ ./a.out
 this is sub1
 this is sub2
 cndaqiang@DESKTOP-N5I64SI:lib$ ldd a.out
        linux-vdso.so.1 (0x00007ffffd2af000)
        libgfortran.so.4 => /usr/lib/x86_64-linux-gnu/libgfortran.so.4 (0x00007fbecf830000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007fbecf430000)
        libquadmath.so.0 => /usr/lib/x86_64-linux-gnu/libquadmath.so.0 (0x00007fbecf1f0000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007fbecee50000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007fbecec30000)
        /lib64/ld-linux-x86-64.so.2 (0x00007fbed0000000)
```

### dll动态库(.so)

动态库 DLL，**实际上也是可执行文件**，所以intel的mkl库里面，`.so`文件是绿色可执行属性

只不过dll通常没有主程序而已,它必须由其他程序调用后才能运行 

程序运行时，需要能找到动态库如`export LD_LIBRARY_PATH=动态库目录:$LD_LIBRARY_PATH`

#### 编译使用

```
 gfortran fun.f90 sub2.f90 -shared -fPIC -o libfun.so
 gfortran main.f90 libfun.so   !动态库要放到后面
```

示例

```
cndaqiang@DESKTOP-N5I64SI:lib$ ls
fun.f90  main.f90  sub2.f90
cndaqiang@DESKTOP-N5I64SI:lib$ gf fun.f90 sub2.f90 -shared -fPIC -o libfun.so
cndaqiang@DESKTOP-N5I64SI:lib$ ls
fun.f90  fun.mod  libfun.so  main.f90  sub2.f90
cndaqiang@DESKTOP-N5I64SI:lib$ gfortran libfun.so main.f90 !把动态库写前面报错
/tmp/ccD5FpLx.o: In function `MAIN__':
main.f90:(.text+0x5): undefined reference to `__fun_MOD_sub1'
main.f90:(.text+0xf): undefined reference to `sub2_'
collect2: error: ld returned 1 exit status
cndaqiang@DESKTOP-N5I64SI:lib$ gfortran  main.f90 libfun.so
cndaqiang@DESKTOP-N5I64SI:lib$ ./a.out !找不到动态库目录报错
./a.out: error while loading shared libraries: libfun.so: cannot open shared object file: No such file or directory
cndaqiang@DESKTOP-N5I64SI:lib$ export LD_LIBRARY_PATH=$(pwd):$LD_LIBRARY_PATH
cndaqiang@DESKTOP-N5I64SI:lib$ ./a.out
 this is sub1
 this is sub2
 cndaqiang@DESKTOP-N5I64SI:lib$ ldd a.out
        linux-vdso.so.1 (0x00007fffd4cca000)
        libfun.so => /mnt/c/Storage/code/siesta/siesta4_1/siesta-4.1-b1/Fortran/bianyi/lib/libfun.so
(0x00007f6274330000)
        libgfortran.so.4 => /usr/lib/x86_64-linux-gnu/libgfortran.so.4 (0x00007f6273f50000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f6273b50000)
        libquadmath.so.0 => /usr/lib/x86_64-linux-gnu/libquadmath.so.0 (0x00007f6273910000)
        libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f6273570000)
        libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f6273350000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f6274800000)
```



## 第三方库调用

### 背景知识

| 内容         | 通常所在的文件夹                 | 开源函数库                                                   | 闭源函数库 |
| ------------ | -------------------------------- | ------------------------------------------------------------ | ---------- |
| 文档         | document，docs，help，notes，man | 可能提供                                                     | 提供       |
| **源代码**   | src，source，code                | **提供 **                                                    | 不提供     |
| 接口文件     | src，source，interface           | 不提供                                                       | 可能提供   |
| **包含文件** | **include**                      | **不提供(编译后可能产生)，使用`-Iinclude所在目录`告诉编译器** | 提供       |
| **库文件**   | **lib**                          | **不提供(编译后产生)**                                       | 提供       |
| 范例代码     | test，examples，demo             | 可能提供                                                     | 可能提供   |
| 其他工具     | bin，tools                       | 可能提供                                                     | 可能提供   |
| 运行时库     | redist                           | 不提供                                                       | 可能提供   |

例fftw编译后的目录

```
[cndaqiang@managernode fftw-3.3.4]$ ls
bin  include  lib  share
[cndaqiang@managernode fftw-3.3.4]$ ls include/
fftw3.f  fftw3.f03  fftw3.h  fftw3l.f03  fftw3l-mpi.f03  fftw3-mpi.f03  fftw3-mpi.h  fftw3q.f03
[cndaqiang@managernode fftw-3.3.4]$ ls lib
libfftw3.a  libfftw3.la  libfftw3_mpi.a  libfftw3_mpi.la  pkgconfig
```

所有函数库的使用，归纳起来，总是离不开这么五个内容

|                                           | include      （mod）   编译时用到 | lib   链接时用到             | DLL   Runtime Library   运行时用到     |
| ----------------------------------------- | --------------------------------- | ---------------------------- | -------------------------------------- |
| 路径（在哪儿？）   一般只设置一次         | 把include的路径  告知编译器       | 把lib的路径   告知编译器     | 把运行时库加入   系统目录   或path目录 |
| 文件名（哪个？）   一般每个工程都需要设置 | 把所需的   module告知编译器       | 把所需的lib文件   告知编译器 |                                        |



### 调用语法

```
gfortran main.f90 xxx.o libxxx.so libxxx.a
gfortran main.f90 -lxxx -L/libxxx.so(a)所在目录
```



详细参数

- `-I`    指明头文件路径(include)
- `-L`    link的时候，gcc会先从-L指定的目录去找库<br>也可将库所在目录加入环境变量`LD_LIBRARY_PATH`(**运行时目录，动态库目录**，编译运行都需要加入环境变量)或`LIBRARY_PATH`(**静态库目录，编译时加入环境变量就行**)，就不用写`-L目录`了
- `-l`    指定库文件（库名）<br>注：`-l `紧接着就是库名，比如库文件名是libm.so的库名是m：**把库文件名的头lib和尾.so去掉就是库名**
- 第三方库如果编译`sudo make`默认到系统，则安装在`/usr/local/` 如`LIBCURL_CFLAGS='-I/usr/local/include'  LIBCURL_LIBS='-L/usr/local/lib -lcurl'`



编译vasp时，调用函数库示例

```
OBJECTS    = fftmpiw.o fftmpi_map.o fftw3d.o fft3dlib.o \
           /opt/fftw/lib/libfftw3_mpi.a
OBJECTS    +=-L$(MKL_PATH) -lmkl_intel_lp64 
INCS       =-I/opt/fftw/include
!略
MKLROOT    = /opt/intel/compilers_and_libraries/linux/mkl
FC         = mpif90  -m64 -I${MKLROOT}/include
FCL        = mpif90  -m64 -I${MKLROOT}/include
```

编译siesta时

```
BLAS_LIBS=/home/chendq/soft/scalapack/lib/librefblas.a
LAPACK_LIBS=/home/chendq/soft/scalapack/lib/libreflapack.a
BLACS_LIBS=
SCALAPACK_LIBS=/home/chendq/soft/scalapack/lib/libscalapack.a
COMP_LIBS=dc_lapack.a

NETCDF_LIBS=
NETCDF_INTERFACE=

LIBS=$(SCALAPACK_LIBS) $(BLACS_LIBS) $(LAPACK_LIBS) $(BLAS_LIBS) $(NETCDF_LIBS)

!省略

siesta: check-siesta what version $(MPI_INTERFACE) $(FDF) $(WXML) $(XMLPARSER) \
                $(COMP_LIBS) $(ALL_OBJS) 
	$(FC) -o siesta \
	       $(LDFLAGS) $(ALL_OBJS) $(FDF) $(WXML) $(XMLPARSER) $(MPI_INTERFACE)\
               $(COMP_LIBS) $(FoX_LIBS) $(LIBS) 
#
```



### lapack使用示例

主程序所在文件lib.f90

我们传入了 A 和 b 及其大小，最终得到的结果覆盖了b，注意：**A也被覆盖了**因此我们用aa保存原来的值

最后，我们用 matmul 来检查计算是否正确。

```
program libla
        implicit none
        real:: a(3,3),aa(3,3),b(3)
        integer::v(3),iflag
        external sgesv !调用lapack中的sgesv用来求解 Ax=b 的线性方程组

        aa=reshape([2.0,1.0,3.0,6.0,2.0,-4.0,4.0,3.0,-6.0],[3,3])
        a=aa
        b=[998.0,999.0,1000.0]
        write(*,*) 'a=',a
        write(*,*) 'b=',b
        call sgesv(3,1,a,3,v,b,3,iflag)
        write(*,*) 'solve=',b
        write(*,*) matmul(aa,reshape(b,[3,1]))
end program libla
```

编译，运行

```
[cndaqiang@managernode fortran]$ ls $MATHDIR
librefblas.a  libreflapack.a  libscalapack.a  libtmg.a
[cndaqiang@managernode fortran]$ gfortran lib.f90 -lreflapack  -lrefblas -L$MATHDIR
!lapack依赖于blas库，需要调用两个库
[cndaqiang@managernode fortran]$ ./a.out 
 a=   2.00000000       1.00000000       3.00000000       6.00000000       2.00000000      -4.00000000       4.00000000       3.00000000      -6.00000000    
 b=   998.000000       999.000000       1000.00000    
 solve=   599.599915      -220.119980       279.879974    
   997.999878       998.999878       1000.00000  
```

关于lapack函数的更多介绍[Lapack中文帮助手册手册.pdf](/web/file/2019/lapack.pdf)

### 其他

**`-库名 -L目录 `当静态库动态库同时存在时，vasp默认调用的是动态库**

makefile

```
MKL_PATH   =/opt/intel/compilers_and_libraries_2018.3.222/linux/mkl/lib/intel64/
BLAS       =-L$(MKL_PATH) -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread
LAPACK     =-L$(MKL_PATH) -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -lpthread
BLACS      =-L$(MKL_PATH) -lmkl_blacs_intelmpi_lp64
SCALAPACK  = $(MKL_PATH)/libmkl_scalapack_lp64.a $(BLACS)
```

编译结果

```
[cndaqiang@managernode bin]$ ldd vasp_std 
	linux-vdso.so.1 =>  (0x00007ffe978fd000)
	libmkl_intel_lp64.so => /opt/intel/compilers_and_libraries_2018.3.222/linux/mkl/lib/intel64_lin/libmkl_intel_lp64.so (0x00002b38d432e000)
	libmkl_cdft_core.so => /opt/intel/compilers_and_libraries_2018.3.222/linux/mkl/lib/intel64_lin/libmkl_cdft_core.so (0x00002b38d4e41000)
	libmkl_scalapack_lp64.so => 
```



