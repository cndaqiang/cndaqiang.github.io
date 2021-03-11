---
layout: post
title:  "Fortran 科学计算"
date:   2019-04-06 15:03:00 +0800
categories: Fortran
tags:  Fortran ScaLapack
author: cndaqiang
mathjax: true
---
* content
{:toc}


该文不完全，边学边总结<br>





## 参考
[Fortran 入门——基本矩阵运算](https://www.cnblogs.com/djcsch2001/articles/2309440.html)

[BLAS库学习](https://blog.csdn.net/G_Spider/article/details/6054990)

[ScaLapack 简介](https://www.jianshu.com/p/8e58c28628a0)

## Fortran自身

矩阵可以直接相加减，与MATLAB中的矩阵点乘点除
```
C=A+-*/B 等价于 C(i,j)=A(i,j)+-*/B(i,j)
A+-*/c 等价于A(i,j)+-*/c
```
矩阵相乘
```
matmul(A,B)
```
矩阵 转置
```
transpose(A)
```
求和
```
sum(a) !a可以是任意维,求和为一个数
```

## 数学库间关系
数学库说明[并行程序开发工具与高性能程序库](/web/file/2019/并行程序开发工具与高性能程序库_张林波_并行计算导论.pdf)

> - FFT（快速傅立叶变换）
> - BLAS（基础线性代数函数库）
> -  Lapack（线性代数Package）、
> - ScaLapack（高扩展的Lapack，主要用于分布式内存体系结构，也就是Cluster结构的并行化的Lapack）

线性代数程序库
![](/uploads/2019/04/scalapack.png)
> 其中
>
> - BLAS （Basic Linear Algebra Subprograms），包含很多常用的线性代数运算子程序，如向量点积，矩阵和向量乘积，矩阵和矩阵乘积等；<br>
- BLACS （Basic Linear Algebra Communication Subprograms），是一个专门为线性代数运算而设计的消息传递库；<br>
- Lapack （Linear Algebra PACKage），包含一系列的程序，可以求解如线性方程组，最小二乘问题，本征值问题，奇异值问题等，通过调用 BLAS 完成大部分工作以获得高的运算性能；<br>
- PBLAS （Parallel BLAS），为 ScaLapack 而设计的一个分布式内存 BLAS 库



## 线性程序库
### BLAS (Basic Linear Algebra Subprograms) 基本线性代数子程序
####  编译连接 
netlib数学库编译
```
gfortran  -g -O2 -ffree-line-length-none    -o mytest  mytest.f90 -L/home/cndaqiang/soft/scalapack/lib -lrefblas 
```
使用ifort和mkl时，参考[自助调用](https://software.intel.com/en-us/articles/intel-mkl-link-line-advisor/)<br>
动态链接
```
ifort mytest.f90  ${MKLROOT}/lib/intel64/libmkl_blas95_ilp64.a -L${MKLROOT}/lib/intel64 -lmkl_intel_ilp64 -lmkl_sequential -lmkl_core -lpthread -lm -ldl
```
静态链接
```
ifort mytest.f90  ${MKLROOT}/lib/intel64/libmkl_blas95_ilp64.a -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_ilp64.a ${MKLROOT}/lib/intel64/libmkl_sequential.a ${MKLROOT}/lib/intel64/libmkl_core.a -Wl,--end-group -lpthread -lm -ldl
```


####  调用：直接使用
不用任何多余操作，直接调用函数，如计算矩阵积的函数
```
call SGEMM("N","N",3,3,3,1.0,A,3,B,3,0,C,3)
```

#### 函数命令

程序分为3个level
- Level 1
<br>Vector operations, e.g. y = /alpha x + y  向量操作
- Level 2
<br>Matrix-vector operations, e.g. y = /alpha A x + /beta y  矩阵(M)与向量(V)操作
- Level 3
<br>Matrix-matrix operations, e.g. C = /alpha A B + C    矩阵(M)与矩阵(M)的操作


#### 函数名XYYZZZ说明
- X:数据类型
  <br>`S` REAL，单精度实数
  <br>`D` DOUBLE PRECISION，双精度实数
  <br>`C` COMPLEX，单精度复数
  <br>`Z` COMPLEX*16 或 DOUBLE COMPLEX
- YY:数组的类型
  <br>`GE` 一般矩阵
  <br> **`SY` symmetric，对称阵不定矩阵
  <br> **`PO` symmetric postive-define 对称正定矩阵(s.p.d)** A=A^T,任意x!=0有 x^T*A*x>0
  <br>  ______ 如重叠矩阵:x^TSx=<x|x> >0
  <br>`BD` bidiagonal，双对角矩阵
  <br>`DI` diagonal，对角矩阵
  <br>`GB` general band，一般带状矩阵
  <br>

- ....
- 等等
- ZZ[Z]:处理计算方法
  <br> `MM` 矩阵乘矩作
  <br> `SV` 矩阵乘向量
  <br> 等等


[BLAS (Basic Linear Algebra Subprograms)](http://www.netlib.org/blas/)对各个函数进行了详细的说明，如`SGEMM`单精度普通矩阵与矩阵的乘法

~~~fortran
subroutine 	sgemm (TRANSA, TRANSB, M, N, K, ALPHA, A, LDA, B, LDB, BETA, C, LDC)
!说明：
 C := alpha*op( A )*op( B ) + beta*C
 A(M,K)
 B(K,N)
 TRANSA:op(A)
 	TRANSA="N", op(A)=A
 	TRANSA="T", op(A)=A**T 转置
 	TRANSA="C", op(A)=A**T
 TRANSB:op(B)
 	同TRANSA
 ALPHA:alpha
 BETA:beta
 LDA:A的列数
 LBB,LDC同A
~~~


### Lapack ( Linear Algebra PACKage) Lapack   线性代数包
同blas

### ScaLapack ( Scalable Linear Algebra PACKage) 可扩展的线性代数包（并行的Lapack）
对于与 Lapack 相对应的 ScaLapack 程序的名称，<br>
只是简单地在 Lapack 名称前面加一个 P,` PvYYZZZ `
说明[PBLAS Home Page](http://www.netlib.org/scalapack/pblas_qref.html)，下面函数名`PvYYZZZ`中，v换成`S、D、C、Z`



#### 编译连接
```
mpif90  -g -O2 -ffree-line-length-none    -o test  mytest.f90 m_mpi_my.o  /home/cndaqiang/soft/scalapack/lib/libscalapack.a  /home/cndaqiang/soft/scalapack/lib/libtmg.a  /home/cndaqiang/soft/scalapack/lib/libreflapack.a /home/cndaqiang/soft/scalapack/lib/librefblas.a
```

#### 调用过程
教程[ScaLapack Tutorial](http://www.netlib.org/scalapack/tutorial/)

1. Initialize the process grid 初始化处理器网格
2. Distribute the matrix on the process grid 分布矩阵
3. Call ScaLapack routine 执行计算
<br>**注意错误，若程序要求输入整数，单精度，双精度，一定要给对类型才能计算**
<br> **`1.0`是单精度，`1.0_8`是双精度**
4. Release the process grid 释放网格

#### 示例程序 1.从文件中读取数据并分发计算(2019-04-06，可能编程不规范)

程序图解![](/uploads/2019/04/scalapackrun.jpg)
~~~fortran
program mytest
        use m_mpi_my
        implicit none
        
        INTEGER :: i,j

        INTEGER :: ICTXT
        INTEGER :: NPROW=2, NPCOL=2, IRREAD,ICREAD,MYROW,MYCOL
        
        INTEGER,PARAMETER :: DLEN_=9,MAXLLDA=5,MAXLLDB=4,MAXLLDC=3,MAXLLDE=3,MAXLOCC=3
        INTEGER,PARAMETER :: SP=4,dp=8
        
        REAL(dp) :: A(4,4)=0,B(1,4)=0,C(1,4)=0,E(3,3)
        
        INTEGER :: DESCA(DLEN_),DESCB(DLEN_),DESCC(DLEN_)
        INTEGER :: INFO, ICSRC,IRSRC, LLD, M, MB, N, NB
        REAL(dp),allocatable :: WORK(:)

        call mpi_start()
 
!=======1.初始化
    !1.1初始化处理器网格化为NPROW*NPCOL
        !如果运行时 np > NPROW*NPCOL, 多余核的MYROW会从负数开始，可用于检测是否被分配
        !ICTXT BLACS句柄,并行计算空间索引
        call SL_INIT(ICTXT,NPROW,NPCOL)
        write(*,*) 123.0_8,456.0 
    !1.2 获得初始化信息,当前node所在网格的位置(MYROW,MYCOL)
        !CALL BLACS_GET( -1, 0, ICTXT )  !获得默认上下文 ICTX
        !CALL BLACS_GRIDINIT( ICTXT, 'Row-major', NPROW, NPCOL) !BLACS_GRIDINIT 定义进程网格，'Row-major' 说明网格是按照行优先的顺序排列的；
        !可以直接使用call BLACS_GRIFINFO
        !BLACS_GRIDINFO 获得本进程在进程网格中的位置信息  
        call BLACS_GRIDINFO(ICTXT,NPROW,NPCOL,MYROW,MYCOL)
        write(*,*) "node is :",node,"MYROW and MYCOL :",MYROW,MYCOL 
        call sleep(1)
        call MPI_BARRIER(my_COMM,mpi_ierr)
 
        
!=======2.初始化矩阵:分布到进程,分配信息存储到DESC中
     !2.1 创建分配规则
        M=8  !待分配矩阵的总行
        N=8  !            列
        MB=4 !M block 分块矩阵的行为MB
        NB=4 !N block         列  NB
        LLD=4 !必须==局域矩阵的LD(local leading dimension)
              ! 局域矩阵的最大行数  >= 分到每个节点总矩阵的最大值LDD,大约是(n-1)*MB~n*MB
              ! LLD >= MAX(1,LOCr(M)). LOCr(local cor 局域矩阵的行
              ! LLD 决定了读取了数据之后如何存储到本地矩阵中去
        IRSRC=master_node !矩阵被分开后，获得第一个行分块的node
        ICSRC=master_node !                    列
        !INFO 成功i执行返回0
        !执行错误返回< 0
        !错误代码核解释在descinit.f中有，在线搜索INFO:http://www.netlib.org/scalapack/explore-html/dd/d22/descinit_8f_source.html
        
        !DESC
        !创建分配规则(数组描述符)DESC, call DESCINIT()
        !每一个被分配的矩阵都有一个描述符DESC，是之后计算的必须因素
        !DESC源文件里面解释了所有的东西，静下心来读
        !DESC 共9个元素 INTEGER :: DESC(9), 每个维度的意思为
        !DTYPE_ = 1,CTXT_ = 2, M_ = 3, N_ = 4, MB_ = 5, NB_ = 6,RSRC_ = 7, CSRC_ = 8, LLD_ = 9
        !"_" 代表 of the global array
        call DESCINIT(DESCA,M,N,MB,NB,IRSRC,ICSRC,ICTXT,LLD,INFO)
        if ( node .eq. master_node ) then
                write(*,*) "OK 0?", INFO
                write(*,*) "DTYPE_ = 1,CTXT_ = 2, M_ = 3, N_ = 4, MB_ = 5, NB_ = 6,RSRC_ = 7, CSRC_ = 8, LLD_ = 9"
                write(*,*) DESCA
        endif
        call sleep(1)
     !2.2 分配矩阵到节点网格

        !A 分配后存储在各节点：局域矩阵名
        !A 的维度定义与DESCINIT()有对应关系
        IRREAD=0 !读取数据的进程在处理器网格中的位置(IRREAD, ICREAD)
        ICREAD=0  !读取数据的进程在处理器网格中的位置(IRREAD, ICREAD)
        allocate(WORK(5))  !一次读取数据的长度，要长一些，WORK维数 >= MB
        !http://www.netlib.org/scalapack/explore-html/d5/d47/pdlaread_8f_source.html
        !源码中DO K = 1, IB ; READ( NIN, FMT = * ) WORK( K )
        call PdLAREAD("A.data",A,DESCA,IRREAD,ICREAD,WORK)
        !数据文件A.data内容:
        	！第一行 M N
        	! 第i(i>1)行 A(i)，就一个数据
        
        !查看分布结果
        Do i=0,np-1
           call MPI_BARRIER(my_COMM,mpi_ierr)
           if (node .eq. i) then 
                Do j=1,size(A,dim=1)
                        write(*,*)"A", node,A(j,:)
                EndDO
           Endif
        EndDO
       
        call sleep(1)
 
       !分布B，解释同上
       ! 注释DESCINIT(DESCA,M,N,MB,NB,IRSRC,ICSRC,ICTXT,LLD,INFO)
        call DESCINIT(DESCB,2,8,1,2,IRSRC,ICSRC,ICTXT,1,INFO)
        !write(*,*) "node",node, INFO
        call PdLAREAD("B.data",B,DESCB,0,0,WORK)
       !分布C
        call DESCINIT(DESCC,2,8,1,2,IRSRC,ICSRC,ICTXT,1,INFO)
        !call PDLAREAD("B.data",C,DESCC,0,0,WORK)
        !if( (node .eq. 0 ) .or. (node .eq. 3)) 
        write(*,*)  "B",node, B
        call sleep(1)

!=======3. 计算操作
        
       !注释PvGEMM( TRANSA, TRANSB, M, N, K, ALPHA, A, IA, JA, DESCA, B, IB, JB,DESCB, BETA, C, IC, JC, DESCC ) 
        call Pdgemm("N","N",2,8,2,1.0_dp,A,1,1,DESCA,B,1,1,DESCB,0.0_dp,C,1,1,DESCC)
        write(*,*) "C",node,C
        !if( (node .eq. 0 ) .or. (node .eq. 3)) write(*,*) "C in node",node,"is", C
!=======4. 释放进程网络
        CALL BLACS_GRIDEXIT( ICTXT )
        !Exit the BLACS
        !CALL BLACS_EXIT( 0 ) 这个程序里包含MPI_FINALIZE,先不使用此函数退出
        deallocate(WORK)
        call mpi_end()
End program
~~~

运行结果
```
[cndaqiang@managernode matlib]$ !mp
mpirun -np 4 ./test 
   123.00000000000000        456.000000    
 node is :           0 MYROW and MYCOL :           0           0
   123.00000000000000        456.000000    
 node is :           1 MYROW and MYCOL :           0           1
   123.00000000000000        456.000000    
 node is :           2 MYROW and MYCOL :           1           0
   123.00000000000000        456.000000    
 node is :           3 MYROW and MYCOL :           1           1
 OK 0?           0
 DTYPE_ = 1,CTXT_ = 2, M_ = 3, N_ = 4, MB_ = 5, NB_ = 6,RSRC_ = 7, CSRC_ = 8, LLD_ = 9
           1           0           8           8           4           4           0           0           8
 A           0   1.0000000000000000        9.0000000000000000        17.000000000000000        25.000000000000000     
 A           0   2.0000000000000000        10.000000000000000        18.000000000000000        26.000000000000000     
 A           0   3.0000000000000000        11.000000000000000        19.000000000000000        27.000000000000000     
 A           0   4.0000000000000000        12.000000000000000        20.000000000000000        28.000000000000000     
 A           0   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           0   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           0   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           0   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           1   33.000000000000000        41.000000000000000        49.000000000000000        57.000000000000000     
 A           1   34.000000000000000        42.000000000000000        50.000000000000000        58.000000000000000     
 A           1   35.000000000000000        43.000000000000000        51.000000000000000        59.000000000000000     
 A           1   36.000000000000000        44.000000000000000        52.000000000000000        60.000000000000000     
 A           1   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           1   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           1   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           1   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           2   5.0000000000000000        13.000000000000000        21.000000000000000        29.000000000000000     
 A           2   6.0000000000000000        14.000000000000000        22.000000000000000        30.000000000000000     
 A           2   7.0000000000000000        15.000000000000000        23.000000000000000        31.000000000000000     
 A           2   8.0000000000000000        16.000000000000000        24.000000000000000        32.000000000000000     
 A           2   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           2   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           2   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           2   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           3   37.000000000000000        45.000000000000000        53.000000000000000        61.000000000000000     
 A           3   38.000000000000000        46.000000000000000        54.000000000000000        62.000000000000000     
 A           3   39.000000000000000        47.000000000000000        55.000000000000000        63.000000000000000     
 A           3   40.000000000000000        48.000000000000000        56.000000000000000        64.000000000000000     
 A           3   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           3   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           3   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 A           3   0.0000000000000000        0.0000000000000000        0.0000000000000000        0.0000000000000000     
 B           2   2.0000000000000000        0.0000000000000000        4.0000000000000000        0.0000000000000000        10.000000000000000        0.0000000000000000        12.000000000000000        0.0000000000000000     
 B           0   1.0000000000000000        0.0000000000000000        3.0000000000000000        0.0000000000000000        9.0000000000000000        0.0000000000000000        11.000000000000000        0.0000000000000000     
 B           1   5.0000000000000000        0.0000000000000000        7.0000000000000000        0.0000000000000000        13.000000000000000        0.0000000000000000        15.000000000000000        0.0000000000000000     
 B           3   6.0000000000000000        0.0000000000000000        8.0000000000000000        0.0000000000000000        14.000000000000000        0.0000000000000000        16.000000000000000        0.0000000000000000     
 C           2   22.000000000000000        0.0000000000000000        46.000000000000000        0.0000000000000000        118.00000000000000        0.0000000000000000        142.00000000000000        0.0000000000000000     
 C           0   19.000000000000000        0.0000000000000000        39.000000000000000        0.0000000000000000        99.000000000000000        0.0000000000000000        119.00000000000000        0.0000000000000000     
 C           3   70.000000000000000        0.0000000000000000        94.000000000000000        0.0000000000000000        166.00000000000000        0.0000000000000000        190.00000000000000        0.0000000000000000     
 C           1   59.000000000000000        0.0000000000000000        79.000000000000000        0.0000000000000000        139.00000000000000        0.0000000000000000        159.00000000000000        0.0000000000000000     
```

计算结果与matlab吻合

![](/uploads/2019/04/matlab.jpg)



#### 示例程序 2. 将已有矩阵进行重新分发(2019-04-30)

新的理解，关于scalapack的计算网格分发和数据的分发
![](/uploads/2019/04/scalapack1.jpg)
![](/uploads/2019/04/scalapack2.jpg)

~~~fortran
program test
    use m_mpi_my
    implicit none
    INTEGER :: dp=8,i,j
    REAL :: A(2,4),B(2,2)
    INTEGER :: AICTXT, BICTXT,ctxt_sys,EICTXT
    INTEGER :: NPROW=3, NPCOL=1, IRREAD,ICREAD,MYROW,MYCOL
    INTEGER,PARAMETER :: DLEN_=9
    INTEGER :: DESCA(DLEN_),DESCB(DLEN_)
    INTEGER :: INFO    
    !===Init=======    
    call mpi_start()
    call SL_INIT(ctxt_sys,3,NPCOL)    

    AICTXT=ctxt_sys
    call BLACS_GRIDINIT(AICTXT,'R',1,1)
    
    if (AICTXT >= 0) then
        call DESCINIT(DESCA,2,4,2,4,0,0,AICTXT,2,INFO)
    endif
    BICTXT=ctxt_sys
    call BLACS_GRIDINIT(BICTXT,'R',1,2)
    if (BICTXT >= 0 ) then
    call DESCINIT(DESCB,2,4,2,2,0,0,BICTXT,2,INFO)
    endif
    if( IOnode) then
        do j=1,4
            do i=1,2
            A(i,j)=10.0*(i-1)+j
            enddo
        enddo
    else
        A=20.0
    end if
    if(BICTXT>=0) then
    call psgemr2d(2,4, A, 1, 1, DESCA, B, 1, 1, DESCB, BICTXT)
    write(*,*) node,B
    endif
    if (AICTXT >= 0) CALL BLACS_GRIDEXIT( AICTXT )
    if (BICTXT >= 0) CALL BLACS_GRIDEXIT( BICTXT )
    CALL BLACS_EXIT( 0 )
   
    !call mpi_end()    
end program test
~~~
计算结果，成功分发
```
cndaqiang@win10:~/code/TDAP/Fortran/scalapack> mpirun -np 3 ./test
           0   1.00000000       11.0000000       2.00000000       12.0000000
           1   3.00000000       13.0000000       4.00000000       14.0000000
```

#### 数据读写
mkl不支持数据读写，Netlib支持
~~~fortran
#读
    call PdLAREAD("H.data",H,DESCH,0,0,WORK)
    #work(k)
#写
    call PdLAWRITE("out.data",5,5,H,1,1,DESCH,0,0,work)
    #work(k),k>=MB
    #http://www.netlib.org/scalapack/explore-html/d1/d81/pdlawrite_8f_source.html
    
~~~



## BLAS，Lapack，ScaLapack编译
**注：此处使用gcc-4.8.4(Centos)编译通过，高版本gcc(Debian 6.3.0)编译有问题**

```
tar xzvf blas.tgz 
cd BLAS-3.8.0/
mpif90 -c *.f
ar cr librefblas.a *.o
ls *.a
cd ..
ls
tar xzvf lapack.tgz 
cd lapack-3.8.0/
cp make.inc.example make.inc
vi make.inc
```
修改
```
FORTRAN = Fortran编译器
LOADER   = Fortran编译器
#BLASLIB用绝对路径
BLASLIB      = /public/home/cndaqiang/soft/mvapich-2.3.1/source/scalapack_installer/build/download/BLAS-3.8.0/librefblas.a
```
继续
```
make
ls *.a
cd ..
tar xzvf scalapack.tgz 
cd scalapack-2.0.2/
ls
cp SLmake.inc.example SLmake.inc
vi SLmake.inc
```
修改
```
FC            = mpif90
CC            = mpicc
BLASLIB       = /public/home/cndaqiang/soft/mvapich-2.3.1/source/scalapack_installer/build/download/BLAS-3.8.0/librefblas.a
LapackLIB     = /public/home/cndaqiang/soft/mvapich-2.3.1/source/scalapack_installer/build/download/lapack-3.8.0/liblapack.a /public/home/cndaqiang/soft/mvapich-2.3.1/source/scalapack_installer/build/download/lapack-3.8.0/libtmglib.a
```
继续

```
make
```

在siesta中使用
```
MATHDIR=/public/home/cndaqiang/soft/mvapich-2.3.1/math
BLAS_LIBS=$(MATHDIR)/librefblas.a
Lapack_LIBS=$(MATHDIR)/liblapack.a $(MATHDIR)/libtmglib.a
BLACS_LIBS=
SCALapack_LIBS=$(MATHDIR)/libscalapack.a
```




### 编译报错原因
#### 库和编译器不匹配
多发生在使用gcc和openmpi编译的数学库，调用mpicc时是intel的编译器
```
mpif90  -g -O2 -ffree-line-length-none    -o test  mytest.f90 m_mpi_my.o  -L/home/cndaqiang/soft/OPENMPI-GCC/LIB/mathlib -lrefblas -llapack  -lscalapack  -ltmglib  
/home/cndaqiang/soft/OPENMPI-GCC/LIB/mathlib/libscalapack.a(blacs_get_.o): In function `blacs_get_':
blacs_get_.c:(.text+0x92): undefined reference to `ompi_mpi_comm_world'
blacs_get_.c:(.text+0xd3): undefined reference to `MPI_Comm_c2f'
/home/cndaqiang/soft/OPENMPI-GCC/LIB/mathlib/libscalapack.a(blacs_pinfo_.o): In function `blacs_pinfo_':
blacs_pinfo_.c:(.text+0x61): undefined reference to `ompi_mpi_comm_world'
blacs_pinfo_.c:(.text+0x70): undefined reference to `MPI_Comm_c2f'
blacs_pinfo_.c:(.text+0x7a): undefined reference to `ompi_mpi_comm_world'
blacs_pinfo_.c:(.text+0x8d): undefined reference to `ompi_mpi_comm_world'
```

#### 库的链接顺序有要求
先链接`scalapack`的库
```
MATHDIR=/home/cndaqiang/soft/scalapack/lib
BLAS_LIBS=$(MATHDIR)/librefblas.a
Lapack_LIBS=$(MATHDIR)/libreflapack.a $(MATHDIR)/libtmg.a
BLACS_LIBS=
SCALapack_LIBS=$(MATHDIR)/libscalapack.a
LIBS=$(SCALapack_LIBS) $(BLACS_LIBS) $(Lapack_LIBS) $(BLAS_LIBS)
```
若将`blas`放在`scalapack`前会发生下面报错
```
mpif90  -g -O2 -ffree-line-length-none    -o test  mytest.f90 m_mpi_my.o      /home/cndaqiang/soft/scalapack/lib/librefblas.a  /home/cndaqiang/soft/scalapack/lib/libtmg.a /home/cndaqiang/soft/scalapack/lib/libscalapack.a   /home/cndaqiang/soft/scalapack/lib/libreflapack.a
/home/cndaqiang/soft/scalapack/lib/libscalapack.a(PB_Cdtypeset.o): In function `PB_Cdtypeset':
PB_Cdtypeset.c:(.text+0x183): undefined reference to `daxpy_'
PB_Cdtypeset.c:(.text+0x18e): undefined reference to `dcopy_'
PB_Cdtypeset.c:(.text+0x199): undefined reference to `dswap_'
PB_Cdtypeset.c:(.text+0x1a4): undefined reference to `dgemv_'
```

## FFT
FFT操作<br>
![](/uploads/2020/04/fft_dft.png)
**在周期性电子结构的时空间和倒空间变换时**<br>
$$\rho(\mathbf{r}) = \sum_G \rho(G) \cdot \exp(i\mathbf{Gr})$$<br>
$$\rho(\mathbf{G}) = \sum_r \rho(r) \cdot \exp(-i\mathbf{Gr})$$<br>
因此:<br>
$$\rho(\mathbf{r}) = IFFT[\rho(\mathbf{G})] $$<br>
$$V(\mathbf{r}) = IFFT[V(\mathbf{G})] $$<br>
如在QE，把在倒空间计算的Hartree用IFFT变到实空间:`invfft('Rho',aux,dfftp)`

原理
![](/uploads/2019/05/fft.jpg)


### FFTW3
编译连接，Fortran要`-I`指定include目录，并指定`fftw.a`
```
gfortran  -I/home/cndaqiang/soft/OPENMPI_1.10.3-GCC-4.8.5-opensuse/mathlib/fftw-3.3.4/include -o test bohanshufftw.o  /home/cndaqiang/soft/OPENMPI_1.10.3-GCC-4.8.5-opensuse/mathlib/fftw-3.3.4/lib/libfftw3.a
```
使用方法：1建立网格点->2计算FFT->3释放网格点
使用示例,合解释说明<br>
2维FFT与IFFT

~~~fortran
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!   ___                               _            _     _                       _  !!!
!!!  / __|  ___   _ __    _ __   _  _  | |_   __ _  | |_  (_)  ___   _ _    __ _  | | !!!
!!! | (__  / _ \ | '  \  | '_ \ | || | |  _| / _` | |  _| | | / _ \ | ' \  / _` | | | !!!
!!!  \___| \___/ |_|_|_| | .__/  \_,_|  \__| \__,_|  \__| |_| \___/ |_||_| \__,_| |_| !!!
!!!  ___   _             |_|  _                                                       !!!
!!! | _ \ | |_    _  _   ___ (_)  __   ___                                            !!!
!!! |  _/ | ' \  | || | (_-< | | / _| (_-<                                            !!!
!!! |_|   |_||_|  \_, | /__/ |_| \__| /__/                                            !!!
!!!  _  _         |__/                               _                                !!!
!!! | || |  ___   _ __    ___  __ __ __  ___   _ _  | |__                             !!!
!!! | __ | / _ \ | '  \  / -_) \ V  V / / _ \ | '_| | / /                             !!!
!!! |_||_| \___/ |_|_|_| \___|  \_/\_/  \___/ |_|   |_\_\                             !!!
!!!                                                                                   !!!
!!! Author:       cndaqiang                                                           !!!
!!! ContactMe:    https://cndaqiang.github.io                                         !!! 
!!! Name:         bohanshufftw                                                          !!!
!!! Last-update:  2019-05-23                                                          !!!
!!! Build-time:   2019-05-23                                                          !!!
!!! What it is:   波函数fft与ifft计算                                    !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

program bohanshufftw
    use,intrinsic :: iso_c_binding
    implicit none
    include 'fftw3.f03'
    INTEGER,PARAMETER :: N=50 !N=600
    INTEGER :: i,j
    !波函数f(x)=c1*exp(-i*2*pi*f1*x)+c2*exp(-i*2*pi*f2*x)
    REAL,PARAMETER :: pi=3.1415926
    REAL(C_DOUBLE)::x(N,N),y(N,N),kx(N,N),ky(N,N),dx,dy,k1x,k1y,c1,k2x,k2y,c2
    complex(C_DOUBLE_COMPLEX) :: fxy(N,N),fk(N,N),ffxy(N,N)!fx-FFT->fk-IFFT->ffx 
    REAL(C_DOUBLE) :: realf,imagef
    type(C_PTR) :: planfft,planifft
    complex(C_DOUBLE_COMPLEX),dimension(N,N) :: in,out
    k1x=20 !k1x
    k1y=30 !ky
    c1=sqrt(2.0/3.0)
    k2x=5
    k2y=7
    c2=sqrt(1.0/3.0)
    dx=0.02
    dy=dx
    DO j = 1,N
        Do i =1,N
        x(i,j)=(i-1.0)*dx
        kx(i,j)=(i-1.0)/N/dx
        y(i,j)=(j-1.0)*dy
        ky(i,j)=(j-1.0)/N/dy
        realf=c1*cos(2*pi*(k1x*x(i,j)+k1y*y(i,j)))+c2*cos(2*pi*(k2x*x(i,j)+k2y*y(i,j)))
        imagef=c1*sin(2*pi*(k1x*x(i,j)+k1y*y(i,j)))+c2*sin(2*pi*(k2x*x(i,j)+k2y*y(i,j)))
        fxy(i,j)=cmplx(realf,imagef)
        END DO
    END DO

    
    !数据结构类型
    !FFTW plans are type(C_PTR). 
    !Other C types are mapped in the obvious way via the iso_c_binding standard:
    !int turns into integer(C_INT), 
    !fftw_complex turns into complex(C_DOUBLE_COMPLEX), 
    !double turns into real(C_DOUBLE), and so on. 
    !See Section 7.3 [FFTW Fortran type reference], page 80. 
!-------------------
    !实数
    !REAL: real(C_DOUBLE), real(C_FLOAT), and real(C_LONG_DOUBLE)
!-------------------
    !复数
    !fftw_complex, fftwf_complex, and fftwl_complex 
    !complex(C_DOUBLE_COMPLEX), complex(C_FLOAT_COMPLEX), and complex(C_LONG_DOUBLE_COMPLEX)
!------fftw编译类型及调用方法
    !the FFTW subroutines and types are prefixed with 
    !‘fftw_’, fftwf_, and fftwl_ for the different precisions, 
    !and link to different libraries (-lfftw3, -lfftw3f, and -lfftw3l on Unix)
    !libfftw3.a这个应该是double的意思
    !use the same include file fftw3.f03 
    !and the same constants (all of which begin with ‘FFTW_’)
    !编译时，指定fftw时指定参数 --enable-float --enable-long-double 默认是double, 
    !--enable-avx等等是指令集 FFTW 支持 SSE、SSE2、 Altivec 和 MIPS 指令集
    !一次只能编译成一种类型
    !这就是超算上fftw有多种版本的原因吧
    !2.1.5-double  3.3.4-double-avx        3.3.4-icc-float   3.3.4-single-avx       3.3.5-double
    !3.3.4         3.3.4-double-avx-sse2   3.3.4-icc-single  3.3.4-single-avx-sse2  3.4.4
    !3.3.4-centos  3.3.4-double-fma-icc15  3.3.4-MPI         3.3.4-SSE2             mkl-14
    !3.3.4-double  3.3.4-gcc               3.3.4-MPICH2.1.5  3.3.5
    !用double就行了
    !将所有以小写"fftw_"开头的名字替换为"fftwf_"（float版本）或"fftwl_"（long double版本）。
    !比如将fftw_complex替换为fftwf_complex，将fftw_execute替换为fftwf_execute等。
    !所有以大写"FFTW_"开头的名字不变
!-------------------
    !整数
    !The C integer types int and unsigned (used for planner flags) 
    !become integer(C_ INT).
!-------------------    
    !数组
    !Numeric array pointer arguments (e.g. double *) become dimension(*),
!-------------------
!===========================================================
!------------------------
    !建立网格点
    !plan = fftw_plan_dft_2d(1000,1024,in,out,FFTW_FO RWARD,FFTW_ESTIMATE)
    !planr2c = fftw_plan_dft_r2c_1d(N,ytr,fftyc,FFTW_ESTIMATE)
    !plan = fftw_plan_dft_1d(N,ytc,ffty,FFTW_FORWARD,FFTW_ESTIMATE)
    !planc2r = fftw_plan_dft_c2r_1d(N,ytc2r,fftyc2r,FFTW_ESTIMATE)
    !其他类型的网格点，如 fftw_plan_dft_r2c_3d
    planfft=fftw_plan_dft_2d(N,N,in,out,FFTW_FORWARD,FFTW_ESTIMATE)
    planifft=fftw_plan_dft_2d(N,N,in,out,FFTW_BACKWARD,FFTW_ESTIMATE)
    !dft,dft_r2c,dft_c2r,r2r,解释见下,注r2r没有dft
    !维度1d,2d,3d
    !fftw_plan_dft_2d(N1,N2,in,out,FFTW_FORWARD,FFTW_ESTIMATE)
    !网格点N1*N2,输入输出矩阵in,out
    !sign表示是做DFT变换 FFTW_FORWARD == -1 *exp(-2*pi*fn*x)
    !还是逆FFT变换 IDFT  FFTW_BACKWARD == +1 *exp(+2*pi*fn*x)
    !优化方案
    !flags是策略生成方案。一般情况下为FFTW MEASURE或FFTW 
    !FFTW_MEASURE表示FFTW会先计算一些FFT并测量所用的时间，以便为大小为n的变换寻找最优的计算方法。 
    !FFTW_ESTIMATE则相反，它直接构造一个合理的但可能是次最优的方案。
    
    
!-----------------------
    !执行计算
    !call fftw_EXECUTE_dft_r2c(plan,y,ffty)
    !call fftw_EXECUTE_dft(plan,ytc,ffty)
    !call fftw_execute_dft_r2c(planr2c,ytr,fftyc)
    !call fftw_EXECUTE_dft_c2r(planc2r,ytc2r,fftyc2r)
    ! planc2r = fftw_plan_dft_c2r_1d(N,ytc,fftyc2r,FFTW_ESTIMATE)
    call fftw_EXECUTE_dft(planfft,fxy,fk)
    fk=fk/(N*N)
    call fftw_EXECUTE_dft(planifft,fk,ffxy)
!call fftw_execute(plan)也可以计算，但Fortran优化后经常出错，不要用
!计算网格命令要和创建网格命令匹配    
!You must use the correct type of execute function,
! matching the way the plan was created. 
!默认c2c即不写
!Complex DFT plans should use fftw_execute_dft, 
!input实数(REAL)->output复数(COMPLEX): r2c
!Real-input (r2c) DFT plans should use use fftw_execute_dft_r2c
!复数->实数：c2r
!and real-output (c2r) DFT plans should use fftw_execute_dft_c2r. 
!实数—>实数：r2r
!The various r2r plans should use fftw_execute_r2r   
    
!-----------------------    
    open(unit=12,file="fxy.dat")
    open(unit=13,file="fk.dat")
    open(unit=14,file="ffxy.dat")
    DO j = 1,N
        Do i =1,N
        if(i<N/2 .and. j<N/2) then
            write(12,*) x(i,j),y(i,j),abs(fxy(i,j))
            write(14,*) x(i,j),y(i,j),abs(ffxy(i,j))
        endif
        write(13,*) kx(i,j),ky(i,j),abs(fk(i,j))
        END DO
    END DO
    !
    !Do i = N-5,N
    !   write(*,*) fftx(i),fftyc2r(i)/N 
    !END DO
    !
    !write(*,*) "------------------------"
    !DO i = 1,6
    !    write(*,*) fftx(i),ffty(i)/N
    !END DO
    !
    !Do i = N-5,N
    !   write(*,*) fftx(i),ffty(i)/N 
    !END DO
    !释放网格点
    !call fftw_destroy_plan(planr2c)
    !call fftw_destroy_plan(plan)
    call fftw_destroy_plan(planfft)
    call fftw_destroy_plan(planifft)
    ! 
end program bohanshufftw
~~~
其中一次的计算结果
![](/uploads/2019/05/fftwbo.jpg)------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
