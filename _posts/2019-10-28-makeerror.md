---
layout: post
title:  "[挖坑]程序编译运行报错"
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
**应该用`A(1,1)`给buffer的起始地址**<br>
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
`. .` 与 `.　.`是不一样的空格，后面的空格和变量相连，程序都无法识别。


### 编译器混用报错
使用gcc8编译了一个,又使用gcc4来调用这个.o
```

    USE kinds, ONLY :  DP
       1
Fatal Error: Cannot read module file ‘kinds.mod’ opened at (1), because it was created by a different version of GNU Fortran
compilation terminated.
```
### `Unclassifiable statement` 变量名写错
```

             Haxu(1,:,:) =  Haxu(1,:,:) + DBLE (H_scissor_pdos(:,:,ispin,IK))
            1
Error: Unclassifiable statement at (1)
```

以及`: Syntax error in argument list` 把错误的变量名当成了函数报错
```
             Haux(1,:,:) =  Haxu(1,:,:) + DBLE (H_scissor_pdos(:,:,ispin,IK))
                                  1
Error: Syntax error in argument list at (1)
```

### `Syntax error, found END-OF-STATEMENT `
```
td_init.f90(213): error #5082: Syntax error, found END-OF-STATEMENT when expecting one of: ( % . = =>
         DALLOCATE(natweight(nat))
```
语法错误, 应为`ALLOCATE(natweight(nat))`



### `.f`文件长度有限制
```
             Haux(2,:,:) =  Haux(2,:,:) + AIMAG(H_scissor_pdos(:,:,ispin,IK))
                                                                        1
Error: Expected array subscript at (1)
```
换行即可, **续行符不能是中文句号**

### `file not recognized: File truncated`
```
/home/cndaqiang/code/intel/lib/libelpa.a: file not recognized: File truncated
```
因为libelpa.a没有正常产生, 不仅是库文件,`.o`的临时文件编译失败也会报错. 一种错误产生方式
```
touch libelpa.a
```

### `configure: error: something wrong with LDFLAGS="-L/usr/local/opt/ruby/lib"`
环境变量设置了`LDFLAGS="-L/usr/local/opt/ruby/lib"`,而实际上没有该目录. 
修改环境变量,或者`unset LDFLAGS`后继续编译


### `implicit declaration of function 'BI_imvcopy' is invalid in C99`
Mac的clang默认不允许编译c文件时,不声明直接调用. 解决方案可以把声明补上,或者添加到头文件. 但是这是一个程序包,总不能一个个文件去改,因此添加编译参数
```
-Wno-implicit-function-declaration
```

### `ld: cannot find -lstdc++`
- ld报错缺少库,有可能是动态库的目录没有配置对,此时通过`export LD_LIBRARY_PATH=ADDPATH:$LD_LIBRARY_PATH`,可以解决.
- 但如果还是报错找不到,就只能说是库和编译器不兼容. 此时通过制定合适(新)的编译器解决,如`export PATH=/share/apps/gcc-10.2.0/bin:$PATH`
- 上面的情况出现在调用icc的时候, 配合gcc10和gcc12都可以


## 运行报错

### `error while loading shared libraries: liblapack.so: cannot open shared object file: No such file or directory`
因为编译的时候使用动态库绝对地址. 运行时没有添加到动态库地址
```
MATHDIR=/home/users/cndaqiang/soft/gnu4-mvapich/math/lib
BLAS_LIBS=$(MATHDIR)/libblas.so
```
解决方案
```
export LD_LIBRARY_PATH=/home/users/cndaqiang/soft/gnu4-mvapich/math/lib:$LD_LIBRARY_PATH
```

类似的报错,注意找不到的是**libimf.so**,而不是`icx-lto.so`
```
[cndaqiang@login002 q-e-qe-6.6]$ ifort test.f90
ld: /share/apps/intel-oneAPI-2021/compiler/2022.0.2/linux/bin/intel64/../../bin/intel64/../../lib/icx-lto.so: 加载插件程序时发生错误: libimf.so: 无法打开共享对象文件: 没有那个文件或目录
```
通过`ldd`可以进一步寻找,哪些都没有找到
```
[chendq@login002 q-e-qe-6.6]$ ldd /share/apps/intel-oneAPI-2021/compiler/2022.0.2/linux/bin/intel64/../../bin/intel64/../../lib/icx-lto.so
	linux-vdso.so.1 =>  (0x00007ffd247f6000)
	librt.so.1 => /lib64/librt.so.1 (0x00002b69ceaac000)
	libdl.so.2 => /lib64/libdl.so.2 (0x00002b69cecb4000)
	libimf.so => not found
	libm.so.6 => /lib64/libm.so.6 (0x00002b69ceeb8000)
	libz.so.1 => /lib64/libz.so.1 (0x00002b69cf1ba000)
	libsvml.so => not found
	libirng.so => not found
	libgcc_s.so.1 => /lib64/libgcc_s.so.1 (0x00002b69cf3d0000)
	libintlc.so.5 => not found
	libpthread.so.0 => /lib64/libpthread.so.0 (0x00002b69cf5e6000)
	libc.so.6 => /lib64/libc.so.6 (0x00002b69cf802000)
	/lib64/ld-linux-x86-64.so.2 (0x00002b69cb50a000)
```

### `free(): invalid next size (normal)`, `double free or corruption ( prev) `
ALLOCATED的数组,ALLOCATE分配的空间为0,或者调用时超过数组的范围

### `*** Error in `q_epsilon2.x': corrupted size vs. prev_size: 0x0000000003595a70 ***`
通过提示找到报错行是`DEALLOCATE ( focc, wgrid, STAT=ierr)`命令. <br>
是调用`focc`时,使用了`focc(0)`,访问了不属于`focc`的区域,所以在deallocate focc时,检测到的尺寸和allocate时不同<br>
解决办法: 合理设置输入参数/代码,focc从focc(1)开始访问
```
forrtl: severe (174): SIGSEGV, segmentation fault occurred
Image              PC                Routine            Line        Source
q_epsilon2.x       0000000000C222DD  Unknown               Unknown  Unknown
libpthread-2.17.s  00002AF0FDC06630  Unknown               Unknown  Unknown
libc-2.17.so       00002AF0FE19AAEC  cfree                 Unknown  Unknown
q_epsilon2.x       0000000000C6409D  Unknown               Unknown  Unknown
q_epsilon2.x       00000000004081AF  MAIN__                    140  epsilon.f90
q_epsilon2.x       000000000040671E  Unknown               Unknown  Unknown
libc-2.17.so       00002AF0FE137555  __libc_start_main     Unknown  Unknown
q_epsilon2.x       0000000000406629  Unknown               Unknown  Unknown
```



### 能跑完,但`free(): invalid next size (normal)`
调用变量超过数组维度,不会终止,但是会有错误抛出.
```
free(): invalid next size (normal)
Aborted (core dumped)
```


### forrtl: severe (174): SIGSEGV, segmentation fault occurred 
- 调用函数时少参数造成
_ 原因很多


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


```
forrtl: severe (174): SIGSEGV, segmentation fault occurred
Image              PC                Routine            Line        Source
tdpp.x             0000000000BB4CCA  Unknown               Unknown  Unknown
libpthread-2.27.s  00001486CF202890  Unknown               Unknown  Unknown
libc-2.27.so       00001486CEAF898D  cfree                 Unknown  Unknown
tdpp.x             0000000000BF80F3  Unknown               Unknown  Unknown
tdpp.x             000000000046B7A8  td_psi_k_mp_test_          80  td_psi_k.f90
tdpp.x             00000000004079F1  MAIN__                    350  postproc.f90
```

虽然报错在第80行` IF(ALLOCATED(mill_mesh))  DEALLOCATE( mill_mesh ), 但是实际错误时, ALLOCATE/定义的数组是`ALLOCATE( mill_mesh(dfftp%nr1x,dfftp%nr2x,dfftp%nr3x) )`, 中途用负下标修改了矩阵内容,结果修改时不报错, DEALLOCATE反而报错了, 如过不执行`DEALLOCATE`会出现下面的警告，改成`ALLOCATE( mill_mesh(-n1x:n1x,-n2x:n2x,-n3x:n3x) )`解决




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


## C语言
### icc for循环报错
```
icc main.c
main.c(11): error: expected an expression
      for ( int i=0; i<5; i++)
            ^
```
C规范太低导致,提高版本解决
```
icc -std=c11 main.c
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



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
