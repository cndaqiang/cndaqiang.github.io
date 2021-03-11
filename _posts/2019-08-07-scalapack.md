---
layout: post
title:  "[挖坑]BLAS, Lapack, Scalapack & Fortran 快速上手"
date:   2019-08-07 10:58:00 +0800
categories: Fortran
tags:  Fortran, BLAS, Lapack,ScaLapack
author: cndaqiang
mathjax: true
---
* content
{:toc}

不知啥时候能填完








## 参考
[9. Linear Algebra Computation](http://homepage.ntu.edu.tw/~wttsai/fortran/ppt/9.Linear_Algebra_Computation.pdf)
<br>[BLAS Quick Reference Guide](http://homepage.ntu.edu.tw/~wttsai/fortran/BLAS_LAPACK/BLAS%20Quick%20Reference%20Guide.pdf)
<br>[LAPACK Quick Reference Guide](http://homepage.ntu.edu.tw/~wttsai/fortran/BLAS_LAPACK/LAPACK%20Quick%20Reference%20Guide.pdf)
<br>[LAPACK Quick Reference Guide to Driver Routines](http://homepage.ntu.edu.tw/~wttsai/fortran/BLAS_LAPACK/LAPACK%20Quick%20Reference%20Guide%20to%20Driver%20Routines.pdf)
<br>[Preliminary LAPACK Users' Guide](http://homepage.ntu.edu.tw/~wttsai/fortran/BLAS_LAPACK/Preliminary%20LAPACK%20Users%20Guide.pdf)
<br>看此文前必须提前看过：[Fortran 科学计算](/2019/04/06/Fortran-math)
<br>Demmel J , 德梅尔, Demmel, et al. 应用数值线性代数[M]. 人民邮电出版社, 2007.




## 说明
### 总览
- 关于BLAS, Lapack, ScaLapack的更多介绍见[Fortran 科学计算](/2019/04/06/Fortran-math)
- 调用函数`call [P]XYYZZZ()`
<br>Scalapack在名称前多个P 
<br>X数据类型.  S: real, D: real(dp), C: complex, Z: complex(dp)
<br>YY矩阵类型. GE普通矩阵, PO对称正定矩阵, SY对称非正定矩阵
<br>ZZZ功能/运算
- BLAS，Lapack, ScaLapack会根据矩阵的类型有不同的输入输出参数, 从而提高效率
- 同一个功能可能由不同的函数YYY实现, 不同的YYY执行速度和附加功能有差异
- BLAS 提供基础的矩阵向量乘除运算功能 
- Lapack和ScaLapack提供`Driver Routines`和`Computational Routine`等丰富的线代功能
- `Driver Routines`一个函数就可以解决线代标准问题: 
<br> a. 线性方程组 $ Ax=B $
<br> b. 最小二乘问题(LLS) $ ||Ax - b ||_2  $
<br> c. 特征值问题  $ Ax = \lambda x $ 以及 量化中的 $ HC=SCE $等
<br> d. 奇异值问题(SVD)
- `Computational Routine` 通过组合解决不同的线代问题
<br>上一个函数的输出作为下一个函数的输入
- 解决问题: 
<br> 确定线代问题的求解过程
<br> 查找函数[BLAS Quick Reference Guide](http://homepage.ntu.edu.tw/~wttsai/fortran/BLAS_LAPACK/BLAS%20Quick%20Reference%20Guide.pdf), [LAPACK Quick Reference Guide](http://homepage.ntu.edu.tw/~wttsai/fortran/BLAS_LAPACK/LAPACK%20Quick%20Reference%20Guide.pdf),Scalapack可以查找Lapack然后加P
<br> 检索用法如[Developer Reference for Intel® Math Kernel Library 2017 - Fortran](https://scc.ustc.edu.cn/zlsc/tc4600/intel/2017.0.098/mkl/common/mklman_f/index.htm)
- 有些限制比如矩阵的大小，或者函数适合的环境在这些manual里面是没说的，比如带状矩阵的存储计算条件，需要自己去看Scalapack的源代码，注释里面说的很详细
- **`scalapack-2.0.2/TESTING/LIN`源码目录的测试程序是最好的学习资源**

### manual中的一些关键词解释
各个函数的源码中有对输入参数的解释，解释中包含了一些默认的名词没有解释，此处解释

- incx INTEGER. Specifies the increment for the elements of x.
  <br>`X(1,1+incx,1+2*incx,....,1+n*incx)`，向量的取样间隔
- SVD (singular value problems) 奇异值
- p.s.d `PO` symmetric postive-define 对称正定矩阵(s.p.d) A=A^T,任意x!=0有 `x^T*A*x>0`
    <br>   如重叠矩阵:`x^TSx=<x|x> >0`

#### ScaLapack

- M_A 总矩阵A(M,N)的行
- N_A 总矩阵A(M,N)的列
- MB_A=4 !M block 分块矩阵的行为MB
- NB_A=4 !N block           列  NB
<br>![](/uploads/2019/04/scalapack1.jpg)
- RSRC_A=0 !矩阵被分开后，获得第一个行分块的node
- CSRC_A=0 !                        列
- LLD_A 局域矩阵的lld(Fortran:行数)
- IA,JA  A(IA:IA+M-1,JA:JA+K-1), Fortran 一般 IA=JA=1
- LCM(least common multiple)最小公倍数
- lOCc 局域矩阵分到总矩阵的几**列**，不是几个块，可以用来分配空间
- LOCr 局域矩阵分到总矩阵的几**行**，不是几个块


######  `LOCc`,`LOCr`
示例
~~~fortran
  LWORK = LOCr(N+MOD(IA-1,MB_A))*NB_A. WORK is used to keep ...
  LIWORK = LOCc( N_A + MOD(JA-1, NB_A) ) + NB_A ...
~~~
含义
```
The values of LOCr() and LOCc() may be determined via a call to the
ScaLAPACK tool function, NUMROC:
        LOCr( M ) = NUMROC( M, MB_A, MYROW, RSRC_A, NPROW ),
        LOCc( N ) = NUMROC( N, NB_A, MYCOL, CSRC_A, NPCOL ).
An upper bound for these quantities may be computed by:
        LOCr( M ) <= ceil( ceil(M/MB_A)/NPROW )*MB_A
        LOCc( N ) <= ceil( ceil(N/NB_A)/NPCOL )*NB_A
```
调用
~~~fortran
    !声明变量时添加
    INTEGER, EXTERNAL :: numroc
    
    !直接调用,不需要ScaLapack初始化就可以调用
    nn = numroc(5,5,0,rsrc,1)
    ! NUMROC( N, NB, IPROC, ISRCPROC, NPROCS )
~~~


## 在代码中解释
读入数据，数据H原子的scf中由五条轨道(NAOs)作为基组得到的H,S: [H.data](/web/file/2019/H.data) [S.data](/web/file/2019/S.data)

下载代码[main.f90](/web/file/2019/main.f90)<br>
编译运行
```
(python27) cndaqiang@win10:~/code/TDAP/Fortran/scalapack/Lapack> make
gfortran -c -g -O2 -ffree-line-length-none     main.f90
gfortran  -g -O2 -ffree-line-length-none  -o test main.o      /mnt/d/CODE/soft/OPENMPI_1.10.3-GCC-4.8.5-opensuse/scalapack/lib/libreflapack.a /mnt/d/CODE/soft/OPENMPI_1.10.3-GCC-4.8.5-opensuse/scalapack/lib/libtmg.a /mnt/d/CODE/soft/OPENMPI_1.10.3-GCC-4.8.5-opensuse/scalapack/lib/librefblas.a
./test
```

下面代码和文字交叉出现，看代码直接下载[main.f90](/web/file/2019/main.f90)

创建变量
~~~fortran
program main.f90
    implicit none
    INTEGER,parameter :: dp=8
    REAL(dp),allocatable    ::  H(:,:),S(:,:),C(:,:),E(:),B(:),A(:,:),X(:),Y(:),work(:),iwork(:),wr(:),wi(:),vs(:,:)
    INTEGER,allocatable :: ipiv(:)
    INTEGER :: m,n,k,i,j,INFO,NRHS,incx,lwork,liwork,sdim,ldvs
    LOGICAL,allocatable :: select(:,:),bwork(:)
    
    m=5
    n=5
    k=5
    allocate(H(m,k),S(k,n),B(n),C(m,n))
    H = reshape((/  -0.42400401342556060 , -0.40143227390650277 , -6.9120337961858791E-006 , &
&                   8.6134463450626697E-010 , -6.9147694707777760E-006 , -0.40143227390650238 , &
&                   -0.29964623883643193 , -8.9726936647882560E-006 , 4.9061116280668671E-010 , &
&                   -8.9740202969982782E-006 , -6.9120337962066958E-006 , -8.9726936648298894E-006 , &
&                   0.80413378049744566 , -1.8838840210033680E-010 , -3.8197224985613721E-007 , &
&                   8.5924509174439834E-010 , 4.8774366490089704E-010 , -1.8838840210033680E-010 , &
&                   0.80417210170273057 , 1.5203947981790279E-011 , -6.9147694707755170E-006 , &
&                   -8.9740202969951222E-006 , -3.8197224985613721E-007 , 1.5203950672231617E-011 ,&
&                   0.80413378335169927/),(/m,k/))
    S = reshape( (/1.0000000107623999 , 0.95479507666315644 , 0.0000000000000000 , 5.3953328491069285E-013 , 0.0000000000000000 , 0.95479507666315644 , 0.99999999999886702 , 0.0000000000000000 , 6.3781864686742656E-013 , 0.0000000000000000 , 0.0000000000000000 , 0.0000000000000000 , 1.0000000364970107 , 0.0000000000000000 , 0.0000000000000000 , -5.3953328491104808E-013 , -6.3781864686711637E-013 , 0.0000000000000000 , 1.0000000364970068 , 0.0000000000000000 , 0.0000000000000000 , 0.0000000000000000 , 0.0000000000000000 , 0.0000000000000000 , &
    &               1.0000000364970110/),(/k,n/))
   
    B = reshape( (/1.0,2.0,3.0,4.0,5.0/),(/5/))
    write(*,*) "H is ------------------"
    do i =1,5
        write(*,*) "            ",H(i,:)
    enddo
    write(*,*) "S is ------------------"
    do i =1,5
        write(*,*) "            ",S(i,:)
    enddo
    write(*,*) "B is ------------------"
    write(*,*) B 
~~~


### BLAS基础功能
功能速查[BLAS Quick Reference Guide](http://homepage.ntu.edu.tw/~wttsai/fortran/BLAS_LAPACK/BLAS%20Quick%20Reference%20Guide.pdf)，或如图
![](/uploads/2019/08/blas.png)

~~~fortran
!********************************
!GEMV 矩阵向量乘
!********************************
!call dgemv(trans, m, n, alpha, a, lda, x, incx, beta, y, incy)
    allocate(X(2*n),Y(n))
    X(1:n)=B
    X(n+1:2*n)=B
    Y=0
    incx=1
    call dgemv('N',m,n,1.0_dp,H,m,X,incx,1.0_dp,Y,1)
    !X(incx,incx+n-1)
    !Y(incy,incy+m-1)
    !incx 向量的初始元素
    write(*,*) "H*B is --------------------"
    write(*,*) Y
    deallocate(X,Y)
!********************************
!SYMV 对称矩阵*向量
!********************************
!针对A是特殊的对称矩阵时
!参数和GESV不同
!call dsymv(uplo, n, alpha, a, lda, x, incx, beta, y, incy)
!y := alpha*A*x + beta*y,
!uplo 
!   If uplo = 'U' or 'u', then the upper triangular part of the array a is used.
!   If uplo = 'L' or 'l', then the low triangular part of the array a is used.
!https://scc.ustc.edu.cn/zlsc/tc4600/intel/2017.0.098/mkl/common/mklman_f/index.htm#GUID-2EB693ED-69F3-48C7-B100-31F030797DDD.htm

    allocate(X(2*n),Y(n))
    X(1:n)=B
    X(n+1:2*n)=B
    incx=2
    !X(1,1+incx,1+2*incx,....,1+n*incx)`,向量的取样间隔
    call dsymv('U',m,1.0_dp,H,m,X,incx,0.0_dp,Y,1)
    write(*,*) "H*[B,B](1:2:2n) symv is --------------"
    write(*,*) Y
    deallocate(X,Y)

!********************************
!GEMM 矩阵乘
!********************************
!DGEMM
!D:double precision
!GE:general matrix
!MM:matrix-matrix
    call DGEMM('N','N',m,n,k,1.0_dp,H,m,S,k,0.0_dp,C,m)
    !C=alpha*OP(H)*OP(S)+beta*C
    write(*,*) "*********DGEMM***********"
    write(*,*) "H*S is ------------------"
    do i =1,5
        write(*,*) "            ",C(i,:)
    enddo

~~~
![](/uploads/2019/08/gemm.jpg)

### Driver Routines
功能速查[LAPACK Quick Reference Guide](http://homepage.ntu.edu.tw/~wttsai/fortran/BLAS_LAPACK/LAPACK%20Quick%20Reference%20Guide.pdf)

Driver Routines 使用来解绝特定问题(如HC=SCE)的程序

Computational Routines 完成特定的计算任务比如LU分解

可以理解Driver Routines调用Computational Routines完成特定问题

#### 线性方程组 | AX=B  
$ AX=B $ 线性问题,B可为矩阵或向量

- `-SV  ` simple,LU分解求解,B是标量
- `-SVX ` expert,LU分解，比-SV提供更多的功能，比如误差分析等
- `-SM ` B是矢量
- `-TRSM` B(m,n) Solves a triangular matrix equation.
- `-TRSVB(m)` Solves a system of linear equations whose coefficients are in a triangular matrix.
- 等
    
~~~fortran
    allocate(A(m,m),X(m),ipiv(m))
    A=H
    X=B
    NRHS=1
    call DGESV(m,NRHS,A,m,ipiv,X,m,INFO)
    !Hx=X,结果保存到X中，
    !A LU分解后保存到A中
    !     A的上三角是U
    !     A的下三角(不包括对角线)是L
    !     MATLAB  [l,u,p]=lu(H)
    !m: A(m,m)
    !NRHS=1: X是一维的,若为AX=C(m,:)时，NRHS=m
    write(*,*) "H LU is ------------------"
    do i =1,5
        write(*,*)"            ", A(i,:)
    enddo
    write(*,*) "root of HX=B(-GESV) is ----------"
    write(*,*) X
    
    A=H
    X=B
    NRHS=1
    lwork=1!INTEGER. The size of the work array; lwork ≥ 1.
    allocate(work(lwork))!work is a workspace array, dimension at least max(1,lwork).
    !call dsysv( uplo, n, nrhs, a, lda, ipiv, b, ldb, work, lwork, info )
    call DSYSV('U',m,NRHS,A,m,ipiv,X,m,work,lwork,INFO)
    deallocate(work)
    write(*,*) "root of HX=B(-SYSV) is ----------"
    write(*,*) X

    A=H
    C=S
    NRHS=m
    call DGESV(m,NRHS,A,m,ipiv,C,m,INFO)
    write(*,*) "root of HX=C is ----------"
    do i =1,5
        write(*,*) "            ",C(i,:)
    enddo
    deallocate(A,X,ipiv)    
    
~~~

![](/uploads/2019/08/gesv.jpg)
    
#### 最小二乘问题 | LLS(Linear Leqat squares problems)
$ ||Ax-b||_2 $


找到X使得 $ ||Ax-b||_2 $ 最小
-  `-LS ` 使用LU或QR分解计算
-  `-LSX`   
-  `-LSS`  SVD奇异值分解
- 等

QR分解 设 A(m,n). 则存在一个单位列正交矩阵 Q(M,n) (即 Q∗Q = I ) 和一个上三角矩阵 R ∈Cn×n, 使得A=Q*R

~~~fortran
!call dgels(trans, m, n, nrhs, a, lda, b, ldb, work, lwork, info)
    allocate(A(m,n),X(n))
    A=H
    X=B
    NRHS=1
    lwork=min(m,n)+max(1,m,m,NRHS) !The size of the work array; must be at least min (m, n)+max(1, m, n, nrhs).
    allocate(work(max(1,lwork)))
    call DGELS('N',m,n,NRHS,A,m,X,n,work,lwork,INFO)
    !返回值A与MATLAB X=qr(H)返回值一样
    !A的右上角与[Q,R]=qr(H)中的R一样,暂时不知道QR分解的下矩阵是什么
    deallocate(work)
    write(*,*) "H QR is ------------------"
    do i =1,5
        write(*,*) "            ",A(i,:)
    enddo    
    write(*,*) "min(||AH-B||2), when X is (-GELS)"
    write(*,*) X
    deallocate(A,X)
~~~

#### 标准本征值问题AX=EX
##### 对称本征值问题|SEP(Symmetric eigenproblems)
$ Ax=Ex $ 
$ A=A^T(real) $   $ A=A^H(complex) $


- `-SYEV ` simple,L U 分解
- `-SYEVX`  expert,比-EV提供更多的功能，比如误差分析等
- `-SYEVD`  不同的算法而已;根据测试EVR最快,EVD次之,SIESTA采用的EVD
- `-SYEVR`  不同的算法而已;测试[LAPACK Benchmark](https://www.netlib.org/lapack/lug/node71.html)
- `-SYEVX`  不同的算法而已;如图
<br>![Figure 3.2: Timings of driver routines for computing all eigenvalues and eigenvectors of a dense symmetric matrix. The upper graph shows times in seconds on an IBM Power3. The lower graph shows times relative to the fastest routine DSYEVR, which appears as a horizontal line at 1.](/uploads/2019/08/img255.gif)


~~~fortran
!call dsyev(jobz, uplo, n, a, lda, w, work, lwork, info)
!jobz = 'N', then only eigenvalues are computed.
!jobz = 'V', then eigenvalues and eigenvectors are computed.
!uplo="U" or "L", 分解存储A的方式
!work is a workspace array, its dimension max(1, lwork).    
!lwork ≥ max(1, 3n-1).
!w本征值Array, size at least max(1, n)
!若jobz='V',A存储本征矢量,一列是一个本征矢,A(i,:)的本征值为w(i)
!若jobz='N',A存储A的L/U(uplo='L'/'U')会被用于计算，并无意义，不是LU分解
!MATLAB中lu(H),[l,u]=lu(H),[l,u,p]=lu(H)的结果不一样
    allocate(A(n,n),E(n))
    A=H
    E=0
    lwork=max(1,3*n-1)
    allocate(work(lwork))
    call DSYEV('V','U',n,A,n,E,work,lwork,INFO)
    deallocate(work)
    write(*,*) "HX=wX; w is ------------------"
    write(*,*) E
    write(*,*) "HX=wX; vectors is ------------------"
    do i =1,5
        write(*,*) "            ",A(i,:)
    enddo
    !H=U*U^T;U*U^T*X=EX
    !C=U^T*U;Cy=Ey, y=U^T*X
    deallocate(A,E)
~~~

##### 非对称本征值问题|NEP(Nonsymmetric eigenproblems) 
$ Ax=Ex $ $ A=QTQ^T(real) $  $  A=QTQ^H(complex) $
<br>Q幺正矩阵,T上三角矩阵

- `-GEES ` simple Schur因子
- `-GEESX`  expert,比-GEES提供更多的功能，比如误差分析等
- `-GEEV ` 本征值本征矢
- `-GEEVX`  expert
- 等

程序遇到问题，先搁置


##### 奇异值问题|SVD(Singular value decomposion)

暂时还不懂
- `-GESVD`



#### 广义的本征值问题 | Generalized eigenvalue problems
#### 广义对称的本征值问题|**GSEP** Generalized symmetric-definite eigenproblems

$$ AX=EBX $$
$$ ABX=EX $$
$$ BAX=EX $$

其中A,B是对称的或哈密顿量 ， **B是正定的**

- `-SYGV`
- `-HEGV`
- `-SPGV`
- `-HPGV`

~~~fortran
!call dsygv(itype, jobz, uplo, n, a, lda, b, ldb, w, work, lwork, info)
!itype
! itype = 1, the problem type is A*x = lambda*B*x;
! itype = 2, the problem type is A*B*x = lambda*x;
! itype = 3, the problem type is B*A*x = lambda*x.
! jobz = 'N' or 'U'
! B输入矩阵和输出本征矢量

    allocate(A(n,n),E(n))
    A=H
    C=S
    E=0
    lwork=max(1,3*n-1)
    allocate(work(lwork)) 
    call DSYGV(1,'V','U',n,A,n,C,n,E,work,lwork,INFO)
    !算完后，A被覆盖了一堆中间数据
    write(*,*) "HC=SCE; E is ------------------"    
    write(*,*) E
    write(*,*) "HC=SCE; C is ------------------"  
    do i =1,5
        write(*,*) "            ",C(i,:)
    enddo   
    deallocate(work)
    deallocate(A,E)
~~~


##### 广义非对称的本征值问题|**GNEP** Generalized nonsymmetric  eigenproblems

- `-GEES  `
- `-GEESX `
- `-GEEV  `
- `-GEEVX `

暂时懒得看了


### Computational Routines
自己组合Computational Routines来解决一个问题，如分解，变为三角阵
<br>通常的过程,先分解(factorize -TRF)再处理,如求逆(-TRI)、求GSEP(-SYGST)等
<br>通过这些程序，我们也可以一步步实现分解(LU,chol,QR...),解决线性方程,LLS,SVD,(广义)本征值问题
<br>下面为几个示例

#### Facrotize分解(-TRF)
不同类型的矩阵分解结果不同，如[Routines for Matrix Factorization](https://scc.ustc.edu.cn/zlsc/tc4600/intel/2017.0.098/mkl/common/mklman_f/index.htm#GUID-2EB693ED-69F3-48C7-B100-31F030797DDD.htm)


- 通常的矩阵GE：LU分解 `-GETRF` $ A=PLU $
- 正定对称矩阵PO：Cholesky 分解 `-POTRF` $ A=U^TU $ or $ LL^T $
- 对称非正定矩阵SY：系统非正定分解  `-SYTRF` $ A=P^TU^TDUP $ or $ PLDL^TP^T $

~~~fortran
!******
!LU分解
!******
!call dgetrf( m, n, a, lda, ipiv, info )
!返回值A,ipiv可用于后续计算
    allocate(A(m,n),E(n))
    A=H
    E=B
    allocate(ipiv(m))
    call DGETRF(m,n,A,m,ipiv,INFO)
    write(*,*) "lu(H) is ------------------"
    do i =1,5
        write(*,*) "            ",A(i,:)
    enddo
!LU分解求HX=B示例    
!call dgetrs( trans, n, nrhs, a, lda, ipiv, b, ldb, info )
!Solves a system of linear equations with an LU-factored square coefficient matrix, with multiple right-hand sides.
!ldbINTEGER. The leading dimension of b; ldb ≥ max(1, n)
!**ipiv 是-GETRF的返回值**
!**A也是-GERTF的LU分解后的矩阵***
!ipiv Array, size at least max(1, n). The ipiv array, as returned by ?getrf.
    call DGETRS('N', n,1,A,m,ipiv,E,n,INFO)
    write(*,*) "use lu(H) to solve HX=B, X is "
    write(*,*) E
!计算之后，不会改变A和ipiv的值

!LU分解求逆A^-1示例
! invert using factorization
!call dgetri( n, a, lda, ipiv, work, lwork, info )
    lwork=n
    allocate(work(lwork))
    call DGETRI(n,A,m,ipiv,work,lwork,INFO)
    write(*,*) "use lu(H) to get H^-1:"
    do i =1,5
        write(*,*) "            ",A(i,:)
    enddo      
    deallocate(work)    
    deallocate(ipiv)
    deallocate(A,E)

!**********************    
!Cholesky factorization
!**********************  
!call dpotrf( uplo, n, a, lda, info ) 
    allocate(A(m,n),E(n))
    A=H
    C=S
    E=B
    call DPOTRF('U',n,C,m,INFO)
    !上部分变为U,下三角部分不变
    write(*,*) "chol(S) is: -----------"
    do i =1,5
        write(*,*) "            ",C(i,:)
    enddo
!chol分解求HX=B示例    
!call dpotrs( uplo, n, nrhs, a, lda, b, ldb, info )
    call DPOTRS('U',n,1,C,m,E,m,INFO)
    write(*,*) "use chol(S) to solve SX=B, X is "
    write(*,*) E    
!chol分解求逆A^-1示例
!call dpotri( uplo, n, a, lda, info )  
    call DPOTRI('U',n,C,m,INFO)
    !结果inv(C)也是对称的，所以，C的上三角矩阵是逆，下三角依旧没变
    write(*,*) "use chol(S) to get S^-1:"
    do i =1,5
        write(*,*) "            ",C(i,:)
    enddo   
!chol分解求广义本征值HC=SCE示例


    A=H
    C=S
    E=0.0_dp
    write(*,*) "use chol(S) to solve HC=SCE"
    write(*,*) "    HC=SCE(-POTRF): 1. S=U^T*U,y=UC"
!***
    call DPOTRF('U',n,C,m,INFO)
    !C=U*U^T,仅改变C的上三角
!***
    write(*,*) "    HC=SCE(-SYGST): 2. tmpC=inv(U^-T)*H*inv(U)"
!call dsygst(itype, uplo, n, a, lda, b, ldb, info)
!The routine reduces real symmetric-definite generalized eigenproblems
!A*z = λ*B*z, A*B*z = λ*z, or B*A*z = λ*z
!itype=1,     2,              3
!to the standard form C*y = λ*y. 
!Here A is a real symmetric matrix, 
!and B is a real symmetric positive-definite matrix. 
!Before calling this routine, call ?potrf to compute the Cholesky factorization: B = UT*U or B = L*LT.
    call DSYGST(1,'U',n,A,m,C,m,INFO)
    !A=inv(U^T)*A*inv(U)，仅改变A的上三角
!***
    write(*,*) "    HC=SCE(-SYEV?): 3. tmpCy=Ey(本征值问题)"
!call dsyevd(jobz, uplo, n, a, lda, w, work, lwork, iwork, liwork, info)
    lwork=2*n*n + 6*n + 1
    allocate(work(lwork))
    liwork= 5*n + 3
    allocate(iwork(liwork))
    call DSYEVD('V','U',n,A,m,E,work,lwork,iwork,liwork,INFO)
    !y保存到A中了
    write(*,*) "    HC=SCE(-SYEV?):    E is:"
    write(*,*) "            ", E
!***
    write(*,*) "    HC=SCE(-SYEV?): 4. y=UC,(线性方程问题)"
    !可选方案很多，
    !a. inv(U)*y
    !因为U已经上三角了
    !b. Dirver routines解方程  -TRSM(B(m,n), -TRSV(B(n)) 
    !c. Computational routines  -TRTRS    
!call dtrsm(side, uplo, transa, diag, m, n, alpha, a, lda, b, ldb) B=AX
!call dtrtrs( uplo, trans, diag, n, nrhs, a, lda, b, ldb, info )
!AX=B结果输出到B
![Fortran使用Scalapack求解HC=SCE](/2019/08/04/HC_SCE)此文采用的TRSM
!此处采用TRTRS
    call DTRTRS('U','N','N',n,n,C,m,A,m,INFO)
    write(*,*) "    HC=SCE(-TRTRS):    C is:"
    do i =1,5
        write(*,*) "            ",A(i,:)
    enddo   
    deallocate(work,iwork)
    !释放内存结束程序
    deallocate(H,S,B,C)
end program    
~~~

除了上述之外，还有很多的computational routines
<br>先这样吧,补充相关知识后再回来补充


### Scalapack有与Lapack相同的函数
示例:<br>
求解HC=SCE问题: [Fortran使用Scalapack求解HC=SCE](/2019/08/04/HC_SCE)<br>
#### LU分解求逆
##### 原理
```
A=L*U
inv(A)*L*U=E
inv(A)*L=inv(U)
求解线性方程组得到inv(A)
```

##### LU分解`p?getrf`
![](/uploads/2019/08/LU.jpg)
##### 求逆`p?getri`
> [p?getri](https://scc.ustc.edu.cn/zlsc/tc4600/intel/2017.0.098/mkl/common/mklman_f/index.htm#GUID-2EB693ED-69F3-48C7-B100-31F030797DDD.htm)
:Computes the inverse of a LU-factored distributed matrix.


~~~fortran
program HC_SCE
    use m_mpi_my
    implicit none
    
    INTEGER,parameter :: dp=8,DLEN_=9
    COMPLEX(dp),allocatable    ::  S(:,:),B(:,:)
    COMPLEX(dp),allocatable    ::  H_2d(:,:),S_2d(:,:),C_2d(:,:),E_2d(:)
    REAL(dp)    :: Hall(25)
    INTEGER :: m,lm,ln,blocksize,i,j
    !矩阵H_aux(m,m), local H(lm,m)
    INTEGER :: work(80),iwork(80),ipiv(5)
    INTEGER :: lwork=80,liwork=45,rsrc,nn    
    
    INTEGER :: ICTXT,ICTXT_2d,NPROW,NPCOL,myROW,myCOL,LOCr,LOCc
    INTEGER :: DESCH(DLEN_),DESCH_2d(DLEN_),DESCE(DLEN_),INFO,DSCALE
    INTEGER :: ICTXT_1d,ICTXT_3d,ICTXT_4d
    CHARACTER*2 :: numchar
    INTEGER, EXTERNAL :: numroc
    
    
    call mpi_start()
    rsrc=0  

!********************************************************************************   
!1D网格计算
!********************************************************************************
!**************************
!处理器grid
!**************************
          NPCOL=4
          NPROW=1
          CALL BLACS_GET( -1, 0, ICTXT ) 
          
          call blacs_gridinit(ICTXT,'C',NPROW,NPCOL)
          call blacs_gridinfo(ICTXT,NPROW,NPCOL,myROW,myCOL)

    !write(*,*) node,NPROW,NPCOL,myROW,mycol
!**************************
!数据网格
!读入数据S
!**************************
       m=5
       lm=1
       if(node .eq. 0) lm=2
       allocate(S(m,lm),B(m,lm))
       blocksize=1
       call DESCINIT(DESCH,m,m,blocksize,blocksize,0,0,ICTXT,m,INFO)
    !   !call DESCINIT(DESCH,5,5,1,1,0,0,ICTXT,lm,INFO)
 
!数据处理
       data Hall /1.0000000107623999 , 0.95479507666315644 , 0.0000000000000000 , 5.3953328491069285E-013 , 0.0000000000000000 , 0.95479507666315644 , 0.99999999999886702 , 0.0000000000000000 , 6.3781864686742656E-013, 0.0000000000000000 , 0.0000000000000000 , 0.0000000000000000 , 1.0000000364970107 , 0.0000000000000000 , 0.0000000000000000 , -5.3953328491104808E-013, -6.3781864686711637E-013, 0.0000000000000000 , 1.0000000364970068 , 0.0000000000000000 , 0.0000000000000000, 0.0000000000000000, 0.0000000000000000, 0.0000000000000000, 1.0000000364970110/
       j=1
       DO i=0,4  
           if(node .eq. mod(i,np)  ) S(:,i/np+1)=cmplx(Hall(j:j+4))   !DO i=1,lm
           j=j+5
       END DO 
    
       if(IOnode) write(*,*) "A is : -------------------------------"
       DO i=0,4  
           if(node .eq. mod(i,np)  ) write(*,*) node,i,":",real(S(:,i/np+1))   !DO i=1,lm
           call sleep(1)           !    write(*,*) node,i,":",S(i,:) 
       END DO 
    
    
    
!****************************
!循环测试mkl内存问题

 
    B=S
 !  !进行PLU分解,B的右上角变为U矩阵，下部分存L的绝对部分(对角线是1不用存储)，P矩阵是单位矩阵
    call pzgetrf(m,m, B, 1, 1, DESCH, ipiv, info)
    !ipiv INTEGER Array of size LOCr(m_a)+ mb_a.

    if(IOnode) write(*,*) "LUA' is : -------------------------------"
    DO i=0,4  
        if(node .eq. mod(i,np)  ) write(*,*) node,i,":",real(B(:,i/np+1))   !DO i=1,lm
        call sleep(1)           !    write(*,*) node,i,":",S(i,:) 
    END DO 
    
    
   !lwork=LOCr(n+mod(ia-1,mb_a))*nb_a.
   !     =LOCr(m)*blocksize
   !     =NUMROC( M, MB_A, MYROW, RSRC_A, NPROW )*blocksize
   
    LOCr=numroc(m,blocksize,myROW,0,NPROW)
    LOCc=numroc(m,blocksize,myCOl,0,NPCOL)
    lwork=LOCr*blocksize
   !liwork=LOCc(n_a + mod(ja-1,nb_a)) + 
   !        max(ceil(ceil(LOCr(m_a)/mb_a)/(lcm/NPROW)),nb_a)
   !      =LOCc(m)+max(ceil(ceil(LOCr(m)/blocksize)/(lcm/NPROW)),blocksize)
   !      =LOCC(m)+max(ceil(LOCr(m)/(4)),blocksize)
   !      = NUMROC( m, NB_A, MYCOL, CSRC_A, NPCOL )
     !liwork=LOCc + max(ceiling(ceiling(1.0*LOCr/blocksize)/4.0),blocksize)
     !这样算的liwork还是小，不如直接liwork=LOCc+LOCr
    liwork=LOCc+LOCr
     
    call pzgetri(m, B, 1, 1, DESCH, ipiv, work, lwork, iwork, liwork, info)
    !pzgetri利用pzgetrf分解的LU求逆
 !  !call pzgetri(n, a, ia, ja, desca, ipiv, work, lwork, iwork, liwork, info)
 !  !ipiv Array of size LOCr(m_a)+ mb_a.
 !  !lwork≥LOCr(n+mod(ia-1,mb_a))*nb_a.
 !  !(local or global) INTEGER. The size of the array iwork.
 !  !The minimal value liwork of is determined by the following code:
 !  !
 !  !if NPROW == NPCOL then
 !  ! liwork = LOCc(n_a + mod(ja-1,nb_a))+ nb_a 
    !else 
    ! liwork = LOCc(n_a + mod(ja-1,nb_a)) + 
    !max(ceil(ceil(LOCr(m_a)/mb_a)/(lcm/NPROW)),nb_a)
    !LOCc(m)+max(ceil(LOCr(m)/(lcm/NPROW)),nb_a)
    !numroc(m,blocksize,myCOL,0,NPCOL)+ceil(numroc(m)/4.0)
    !end if
    !where lcm is the least common multiple of process rows and columns (NPROW and NPCOL).
    !LCM最小公倍数
    !**************************
    !**注：LOCr与LoCc是一个Scalapack的函数，
    ! *  The values of LOCr() and LOCc() may be determined via a call to the
    ! *  ScaLAPACK tool function, NUMROC:
    ! *          LOCr( M ) = NUMROC( M, MB_A, MYROW, RSRC_A, NPROW ),
    ! *          LOCc( N ) = NUMROC( N, NB_A, MYCOL, CSRC_A, NPCOL ).
    ! *  An upper bound for these quantities may be computed by:
    ! *          LOCr( M ) <= ceil( ceil(M/MB_A)/NPROW )*MB_A
    ! *          LOCc( N ) <= ceil( ceil(N/NB_A)/NPCOL )*NB_A
    
    if(IOnode) write(*,*) "invA is : -------------------------------"
    DO i=0,4  
        if(node .eq. mod(i,np)  ) write(*,*) node,i,":",real(B(:,i/np+1))   !DO i=1,lm
        call sleep(1)           !    write(*,*) node,i,":",S(i,:) 
    END DO 
        
    CALL BLACS_GRIDEXIT( ICTXT ) 
 !   
    deallocate(S,B)
    call mpi_end()
end program HC_SCE
~~~

结果
![](/uploads/2019/08/inv.jpg)
使用MATLAB验证
```
>> A

A =

   1.000000000000000   0.954795062541962                   0   0.000000000000540                   0
   0.954795062541962   1.000000000000000                   0   0.000000000000638                   0
                   0                   0   1.000000000000000                   0                   0
  -0.000000000000540  -0.000000000000638                   0   1.000000000000000                   0
                   0                   0                   0                   0   1.000000000000000

>> [l,u,p]=lu(A);
>> u'

ans =

   1.000000000000000                   0                   0                   0                   0
   0.954795062541962   0.088366388545492                   0                   0                   0
                   0                   0   1.000000000000000                   0                   0
   0.000000000000540   0.000000000000123                   0   1.000000000000000                   0
                   0                   0                   0                   0   1.000000000000000

>> l'

ans =

   1.000000000000000   0.954795062541962                   0  -0.000000000000540                   0
                   0   1.000000000000000                   0  -0.000000000001388                   0
                   0                   0   1.000000000000000                   0                   0
                   0                   0                   0   1.000000000000000                   0
                   0                   0                   0                   0   1.000000000000000
>> inv(A)

ans =

  11.316519962623509 -10.804957385470471                   0   0.000000000000786                   0
 -10.804957385470471  11.316519962623509                   0  -0.000000000001388                   0
                   0                   0   1.000000000000000                   0                   0
  -0.000000000000786   0.000000000001388                   0   1.000000000000000                   0
                   0                   0                   0                   0   1.000000000000000

```
可以看到`pzgetrf`将矩阵LU分解，并将LU存储到原矩阵中



## 报错
### `parameter number   10 had an illegal value`
```
{    0,    3}:  On entry to PZGETRI parameter number   10 had an illegal value
{    0,    2}:  On entry to PZGETRI parameter number   10 had an illegal value
{    0,    1}:  On entry to PZGETRI parameter number   10 had an illegal value
{    0,    0}:  On entry to PZGETRI parameter number   10 had an illegal value
```
第10个输入参数不合理

### `{    0,    2}:  On entry to PDGETRF parameter number  601 had an illegal value`
基本上都是输入参数不合理<br>
虽然有时候能算的出来，其他情况就算不不出来了<br>
可能因为某些输入变量没有赋值，算出来是残存内存的意外

### `PBLAS ERROR 'Illegal DESCA[IMB_] = 0` 其实还是输入参数顺序写错了，给了错的参数
```
mpirun -np 4 ./test 10
PBLAS ERROR 'Illegal DESCA[IMB_] = 0, DESCA[IMB_] must be at least 1'
from {0,3}, pnum=3, Contxt=0, in routine 'PDGEMM'.

PBLAS ERROR 'Illegal DESCA[MB_] = 0, DESCA[MB_] must be at least 1'
from {0,3}, pnum=3, Contxt=0, in routine 'PDGEMM'.

PBLAS ERROR 'Illegal DESCA[RSRC_] = 1023, DESCA[RSRC_] must be either -1, or >= 0 and < 1'
from {0,3}, pnum=3, Contxt=0, in routine 'PDGEMM'.

PBLAS ERROR 'Illegal DESCB[IMB_] = 0, DESCB[IMB_] must be at least 1'
from {0,3}, pnum=3, Contxt=0, in routine 'PDGEMM'.

PBLAS ERROR 'Illegal DESCB[MB_] = 0, DESCB[MB_] must be at least 1'
from {0,3}, pnum=3, Contxt=0, in routine 'PDGEMM'.
```
\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
