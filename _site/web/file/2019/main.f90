program HC_SCE
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
!-----------------------------------------------------------------------------------------------------------------------------------
! BLACS基础功能
!-----------------------------------------------------------------------------------------------------------------------------------
    
    
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

!!```
!
!******************************
! ![](/uploads/2019/08/gemm.jpg)
!******************************
!-----------------------------------------------------------------------------------------------------------------------------------
! Driver Routines
!-----------------------------------------------------------------------------------------------------------------------------------


! ### Driver Routines
!     Driver Routines 使用来解绝特定问题(如HC=SCE)的程序
!     Computational Routines 完成特定的计算任务比如LU分解
!     可以理解Driver Routines调用Computational Routines完成特定问题
! #### 线性方程组 | AX=B  

!!```
    write(*,*) "================================================================="
    write(*,*) "======================Driver Routines============================"
    write(*,*) "================================================================="

    
    write(*,*) "***************************************"
    write(*,*) "*************  AX=B  ******************"
    write(*,*) "***************************************"
!********************************
![A]{X}={B} 线性问题,B可为矩阵或向量
!-SV simple,LU分解求解,B是标量
!-SVX expert,LU分解，比-SV提供更多的功能，比如误差分析等
!-SVM B是矢量
!-TRSM B(m,n) Solves a triangular matrix equation.
    !call dtrsm(side, uplo, transa, diag, m, n, alpha, a, lda, b, ldb)
    !X and B are m-by-n matrices,
!-TRSVB(m) Solves a system of linear equations whose coefficients are in a triangular matrix.
    !call dtrsv(uplo, trans, diag, n, a, lda, x, incx)
    !b and x are n-element vectors,
!********************************
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
    
!!```
!********************************
!  ![](/uploads/2019/08/gesv.jpg)
!********************************

    
! #### 最小二乘问题 | LLS(Linear Leqat squares problems)
!      `||Ax-b||2`

!!```
    write(*,*) "***************************************"
    write(*,*) "*********  min(||AX-B||2)  ************"
    write(*,*) "***************************************"
!*******************************
!找到X使得 (b(m)-A(m,n))的2范数||AX-B||2最小
! -LS 使用LU或QR分解计算
! -LSX  
! -LSS SVD奇异值分解
!*******************************
!QR 设 A(m,n). 则存在一个单位列正交矩阵 Q(M,n) (即 Q∗Q = I ) 和一个上三角矩阵 R ∈Cn×n, 使得A=Q*R
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
    
!! ```

! #### 标准本征值问题AX=EX
! ##### 对称本征值问题|SEP(Symmetric eigenproblems)
!        Ax=Ex ,A=A^T(real)  A=A^H(complex)
!!```
    write(*,*) "***************************************"
    write(*,*) "*************  AX=EX  *****************"
    write(*,*) "***************************************"
!********************************
!********************************
!AX=EX 本征值问题
!-SYEV simple,L U 分解
!-SYEVX expert,比-EV提供更多的功能，比如误差分析等
!-SYEVD 不同的算法而已;根据测试EVR最快,EVD次之,SIESTA采用的EVD
!-SYEVR 不同的算法而已;测试[LAPACK Benchmark](https://www.netlib.org/lapack/lug/node71.html)
!-SYEVX 不同的算法而已;如图![Figure 3.2: Timings of driver routines for computing all eigenvalues and eigenvectors of a dense symmetric matrix. The upper graph shows times in seconds on an IBM Power3. The lower graph shows times relative to the fastest routine DSYEVR, which appears as a horizontal line at 1.](/uploads/2019/08/img255.gif)
!********************************
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
!! ```

! ##### 非对称本征值问题|NEP(Nonsymmetric eigenproblems) 
!        Ax=Ex ,A=QTQ^T(real)  A=QTQ^H(complex)
!                 Q幺正矩阵,T上三角矩阵
!!```
!********************************
!AX=EX 本征值问题
!-GEES simple Schur因子
!-GEESX expert,比-GEES提供更多的功能，比如误差分析等
!-GEEV 本征值本征矢
!-GEEVX expert
!********************************
!程序遇到问题，先搁置


!Error:         !        !call dgees(jobvs, sort, select, n, a, lda, sdim, wr, wi, vs, ldvs, work, lwork, bwork, info)
!Error:         !        !wr(>=n),wi(>=n)本征值的实部虚部,是T的对角元素
!Error:         !        !Arrays, size at least max (1, n) each. 
!Error:         !        !Contain the real and imaginary parts, respectively, of the computed eigenvalues, 
!Error:         !        !in the same order that they appear on the diagonal of the output real-Schur form T. Complex conjugate pairs of eigenvalues appear consecutively with the eigenvalue having positive imaginary part first.
!Error:         !        !select:是一个函数参数，逻辑型
!Error:         !            allocate(A(n,n),E(n))
!Error:         !            A=H
!Error:         !            E=0
!Error:         !            allocate(wr(n),wi(n))
!Error:         !            lwork=max(1,3*n)
!Error:         !            allocate(work(lwork))
!Error:         !            ldvs=n
!Error:         !            allocate(vs(ldvs,n))
!Error:         !            allocate(bwork(n))
!Error:         !            allocate(select(n,n))
!Error:         !            select=.true.
!Error:         !            bwork=.true.
!Error:         !            
!Error:         !            call DGEES('V','S',select,n,A,n,sdim,wr,wi,vs,ldvs,work,lwork,bwork,info)
!Error:         !            
!Error:         !            
!Error:         !            deallocate(bwork)
!Error:         !            deallocate(vs)
!Error:         !            deallocate(work)
!Error:         !            deallocate(wr,wi)
!Error:         !            deallocate(A,E)
    
!! ```


! ##### 奇异值问题|SVD(Singular value decomposion)
!! ```
!********************************
!暂时还不懂
!-GESVD 
!********************************
!! ```

! ### 广义的本征值问题 | Generalized eigenvalue problems
! #### 对称的本征值问题|**GSEP** Generalized symmetric-definite eigenproblems
! AX=EBX
! ABX=EX
! BAX=EX
! 其中A,B是对称的或哈密顿量 ， **B是正定的**
!! ```
!********************************
!-SYGV
!-HEGV
!-SPGV
!-HPGV
!********************************
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

!! ```

! #### 广义非对称的本征值问题|**GNEP** Generalized nonsymmetric  eigenproblems
!! ```
!********************************
!-GEES
!-GEESX
!-GEEV
!-GEEVX
!********************************
!暂时懒得看了
!! ```








!-----------------------------------------------------------------------------------------------------------------------------------
!Computational Routines
!-----------------------------------------------------------------------------------------------------------------------------------
! ### Computational Routines
!自己组合Computational Routines来解决一个问题，如分解，变为三角阵
!通常的过程,先分解(factorize -TRF)再处理,如求逆(-TRI)、求GSEP(-SYGST)等
! 通过这些程序，我们也可以一步步实现分解(LU,chol,QR...),解决线性方程,LLS,SVD,(广义)本征值问题
! 下面为几个示例
! #### Facrotize分解(-TRF)
! 不同类型的矩阵分解结果不同，如[Routines for Matrix Factorization](https://scc.ustc.edu.cn/zlsc/tc4600/intel/2017.0.098/mkl/common/mklman_f/index.htm#GUID-2EB693ED-69F3-48C7-B100-31F030797DDD.htm)
!! ```
    write(*,*) "================================================================="
    write(*,*) "======================Computational Routine======================"
    write(*,*) "================================================================="
!*********************************
!- 通常的矩阵:：LU分解 `-GETRF` A=PLU
!- 正定对称矩阵：Cholesky 分解 `-POTRF` A=U^T*U or L*L^T
!- 对称非正定矩阵：系统非正定分解  `-SYTRF` A=P^TU^TDUP or PLDL^TP^T
!*********************************

!******
!LU分解
!******
    write(*,*) "***************************************"
    write(*,*) "*********  LU -> AX=B H^-1************"
    write(*,*) "***************************************"
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
    write(*,*) "***************************************"
    write(*,*) "*****  Cholesky -> S^-1 HC=ESC ********"
    write(*,*) "***************************************"  
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
    
!! ```
! 除了上述之外，还有很多的computational routines
! 先这样吧,补充相关知识后再回来补充

    deallocate(H,S,B,C)

 
end program HC_SCE
