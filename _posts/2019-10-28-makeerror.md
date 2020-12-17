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


### 编译器混用报错
使用gcc8编译了一个,又使用gcc4来调用这个.o
```

    USE kinds, ONLY :  DP
       1
Fatal Error: Cannot read module file ‘kinds.mod’ opened at (1), because it was created by a different version of GNU Fortran
compilation terminated.
```

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


### 管理节点运行正常，作业节点编译运行报错
```
error while loading shared libraries: libibmad.so.5: cannot open shared object file: No such file or directory
```
还有缺`ibraries: libosmcomp.so.4`

现象: 计算节点和管理节点不同缺少库<br>
原因:计算节点少安装<br>
解决:
- 在计算节点安装
- [非管理员],通过`whereis libibmad.so.5`找到缺少的库复制到计算个管理节点共享的目录，添加目录到环境变量`LD_LIBRARY_PATH`


## 语法报错
### 重复定义
```
 #6418: This name has already been assigned a data type.   [ET2]
   et2 = 0.0_DP
---^
```
错误代码
```fortran
   REAL(DP) :: et2(nbnd,nkstot)
   COMPLEX(DP) :: c_il(nbnd,nbnd,nkstot)
   !
   INTEGER :: lbnd, &! counter on tdks
   ik,   &! counter on k points   !因为这个地方忘记删除逗号和续行符了
   !
   et2 = 0.0_DP
```
## Intel运行报错
### format的格式不合理
下面报错给出了error的具体位置
```
forrtl: severe (61): format/variable-type mismatch, unit 6, file /home/NFS/work/tdpw/TDAPW-intel-2020-12-06/Manypw/input_0.out
Image              PC                Routine            Line        Source
tdpw.x             0000000000E7497B  Unknown               Unknown  Unknown
tdpw.x             0000000000ED711A  Unknown               Unknown  Unknown
tdpw.x             0000000000ED4C6E  Unknown               Unknown  Unknown
tdpw.x             0000000000459718  td_psi_a_psi_             202  td_psi_r_psi.f90
tdpw.x             0000000000453B44  td_analysis_md_           312  td_analysis.f90
tdpw.x             0000000000407652  run_pwscf_                225  run_pwscf.f90
tdpw.x             0000000000406B01  MAIN__                    115  tdpw.f90
tdpw.x             0000000000406882  Unknown               Unknown  Unknown
libc-2.27.so       000014E8FDF2DB97  __libc_start_main     Unknown  Unknown
tdpw.x             000000000040676A  Unknown               Unknown  Unknown

===================================================================================
=   BAD TERMINATION OF ONE OF YOUR APPLICATION PROCESSES
=   RANK 1 PID 65033 RUNNING AT mommint
=   KILLED BY SIGNAL: 9 (Killed)
===================================================================================
```

## srun提示
### Bus error (core dumped)
正在执行的程序被删除/覆盖了
```
srun: error: comput123: tasks 29,31: Bus error
srun: error: comput157: tasks 38,40,42-44,46,50,52-54,56,60-62,64,66,68,70-71: Bus error
srun: error: comput123: tasks 0,4,15,25: Bus error (core dumped)
srun: error: comput123: tasks 1-3,5-10,12-14,16-24,26-28,30,32,34-35: Bus error
srun: error: comput157: tasks 37,39,41,45,47,51,55,57,59,63,65,67,69: Bus error
srun: error: comput123: task 33: Bus error (core dumped)
srun: error: comput123: task 11: Bus error (core dumped)
srun: error: comput157: tasks 36,48: Bus error (core dumped)
srun: error: comput157: task 58: Bus error (core dumped)
srun: error: comput157: task 49: Bus error (core dumped)
```