---
layout: post
title:  "[挖坑]程序编译报错(Fortran)"
date:   2019-10-28 15:45:00 +0800
categories: Fortran
tags:  gnu Fortran mpif90 gfortran
author: cndaqiang
mathjax: true
---
* content
{:toc}

写程序编译报的错误







## 编译错误
### `Undefined symbols` or `‘mpi_allreduceqwmake_’未定义的引用`
```
Undefined symbols for architecture x86_64:
  "_showhy_", referenced from:
      _MAIN__ in benchmark.o
ld: symbol(s) not found for architecture x86_64
collect2: error: ld returned 1 exit status
make: *** [test] Error 1
```
再如
```
ibs/lapack.f:40482: more undefined references to `lsame_' follow
ld: libsiestaLAPACK.a(lapack.o): in function `zupmtr_':
/home/cndaqiang/work/TTTT/Normal-Final/TTTT-1.2.1/Src/Libs/lapack.f:40492: undefined reference to `xerbla_'
```

现象: 在benchmark.o中调用的`showhy`,没有此函数<br>
原因:
- 没有USE `showhy`所在的模块
- 函数名错误
- Makefile中没有添加`showhy`所在的模块为对象Obj `Obj+= xxx.o`
- 数学库掉错了，找不到相应函数
- Makefile写错，漏写`.o`,如此效果，是仅把这一个module编译成一个程序，自然少mian，少定义
```
cndaqiang@girl:~/code/O-TDAP/Obj$ make td_compute_jump
mpif90 -c -g -O2 -ffree-line-length-none   `FoX/FoX-config --fcflags` -DMPI -DFC_HAVE_FLUSH -DFC_HAVE_ABORT -DTDAP  /home/cndaqiang/code/O-TDAP/Src/td_compute_jump.F90 
cc   td_compute_jump.o   -o td_compute_jump
/usr/lib/gcc/x86_64-linux-gnu/7/../../../x86_64-linux-gnu/Scrt1.o: In function `_start':
(.text+0x20): undefined reference to `main'
td_compute_jump.o: In function `__td_compute_jump_MOD_hp':
/home/cndaqiang/code/O-TDAP/Src/td_compute_jump.F90:549: undefined reference to `__sys_MOD_die'
td_compute_jump.o: In function `__td_compute_jump_MOD_enpy':
```


### `There is no specific subroutine for the generic 'mpi_allreduce' `
```

), eo(:,:,1), no_u, MPI_DOUBLE_PRECISION, MPI_SUM,MPI_Comm_World, MPIerror)
                                                                           1
Error: There is no specific subroutine for the generic 'mpi_allreduce' at (1)
arch.make:62: recipe for target 'TDEvolve.o' failed
```
现象: 没有合适的`mpi_allreduce`<br>
可能原因: 输入参数不一致，send和recv的数组长度不同，找不到合适的interface<br>
解决:
```
CALL MPI_REDUCE( eo_tmp, eo, no_u*nspin*nkpnt, MPI_DOUBLE_PRECISION, MPI_SUM,0,MPI_Comm_World, MPIerror)
改为
CALL MPI_REDUCE( eo_tmp(1,1,1), eo(1,1,1), no_u*nspin*nkpnt, MPI_DOUBLE_PRECISION, MPI_SUM,0,MPI_Comm_World, MPIerror)
```

### `Invalid character`
```
      COMPLEX(dp), INTENT(IN,OUT) :: M(no_u, no_l)
                  1
Error: Invalid character in name at (1)
```
现象: 非法字符<br>
原因: 
- 前后语法有问题
- 该行过长，超过编译器限制
解决:
```
#改为
COMPLEX(dp), INTENT(INOUT) :: M(no_u, no_l)
```


### `Error: Incompatible ranks 0 and 1 in assignment at (1)`
维度不同赋值造成，**即使　INTEGER :: a(1),b,也不可以b=a 或a=b**<br>
如`UBOUND(a)`返回的是一维数组,即使只有一个元素也是数组,也不可以直接返回给整数,即`b=UBOUND(a)`也会这样报错<br>
可以采用
```
INTEGER     :: a(N),bound(1),i
bound=UBOUND(a)
i=bound(1)
i=UBOUND(a,1)
```

### 全角字符不识别各种报错
` `与`　`是不一样的空格，后面的空格和变量相连，程序都无法识别。

## SCALAPACK 运行报错
### `PBLAS ERROR 'Illegal `，程序退出
```
PBLAS ERROR 'Illegal JY = 0, JY must be at least 1'
from {0,0}, pnum=0, Contxt=1, in routine 'PDSWAP'.

PBLAS ERROR 'Parameter number 9 had an illegal value'
from {0,0}, pnum=0, Contxt=1, in routine 'PDSWAP'.

{0,0}, pnum=0, Contxt=1, killed other procs, exiting with error #-9.

PBLAS ERROR 'Illegal JY = 0, JY must be at least 1'
from {0,1}, pnum=1, Contxt=1, in routine 'PDSWAP'.

PBLAS ERROR 'Parameter number 9 had an illegal value'
from {0,1}, pnum=1, Contxt=1, in routine 'PDSWAP'.
..........
..........
--------------------------------------------------------------------------
MPI_ABORT was invoked on rank 1 in communicator MPI_COMM_WORLD 
with errorcode -9.

NOTE: invoking MPI_ABORT causes Open MPI to kill all MPI processes.
You may or may not see output from other processes, depending on
exactly when Open MPI kills them.
--------------------------------------------------------------------------
```
现象: 第9个参数非法<br>
原因:
-  漏写了参数，输入参数数不足

### `On entry to PDGETRI parameter number    8 had an illegal value`，程序返回错误代码
```
{    0,    1}:  On entry to PDGETRI parameter number    8 had an illegal value
{    0,    2}:  On entry to PDGETRI parameter number    8 had an illegal value
{    0,    3}:  On entry to PDGETRI parameter number    8 had an illegal value
{    0,    4}:  On entry to PDGETRI parameter number    8 had an illegal value
```
现象: 第8个参数非法<br>
原因:
-  参数类型写错
-  该位置放错变量
-  数组的长度太小，查说明书，看代码里面对变量的具体要求

### `Program received signal SIGSEGV: Segmentation fault - invalid memory reference`

```
Program received signal SIGSEGV: Segmentation fault - invalid memory reference.

Backtrace for this error:

Program received signal SIGSEGV: Segmentation fault - invalid memory reference.

Backtrace for this error:
#0  0x11201d882
#1  0x11201e03e
#2  0x7fff644cab5c
#0  0x104a69882
#1  0x104a6a03e
#2  0x7fff644cab5c
#3  0x102ba4397
#3  0x11015b397
```


现象: 内存问题<br>
原因: **太多了!!!**
- 数据内容不合理，导致程序根据错的信息访问了不可访问的内存<br>
  如未运行`PZGBTRF`就运行`PZGBTRI`
- 函数输入参数未指定维度，进行调用，如下面的错误二

错误二: 
```
#错误
   real(8),intent(in) :: A(:,:) ! Banded atrix to be inverted.
   write(*,*) A(1,1)
Program received signal SIGSEGV: Segmentation fault - invalid memory reference.

Backtrace for this error:
#0  0x101f0f882
#1  0x101f1003e
#2  0x7fff644cab5c
#3  0x101fe4090
#4  0x101fe6724
#5  0x101fe726e
#6  0x101ef0cba
#7  0x101ef0889
#8  0x101ef7aae
make: *** [test] Segmentation fault: 11
make: *** Deleting file `test'

#正常
   real(8),intent(in) :: A(N,N) ! Banded atrix to be inverted.
   write(*,*) A(1,1)

```


### `Program received signal SIGFPE: Floating-point exception - erroneous arithmetic operation.`
```
Program received signal SIGFPE: Floating-point exception - erroneous arithmetic operation.

Backtrace for this error:
#0  0x109c9e882
#1  0x109c9f03e
#2  0x7fff644cab5c
#3  0x109931dba
#4  0x1098902a8
#5  0x10988e7d8
#6  0x1099909ae
--------------------------------------------------------------------------
mpirun noticed that process rank 0 with PID 15152 on node cndaqiangdeMac exited on signal 8 (Floating point exception: 8).
--------------------------------------------------------------------------
```
现象: 内存问题<br>
原因: **未知**<br>
解决: 
- 使用ifort编译
- 把gfortran的优化参数由`-O2`改为`-O`或`-O0`

