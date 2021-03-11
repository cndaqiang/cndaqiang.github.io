---
layout: post
title:  "利用Lapack和ScaLapack进行带状矩阵计算"
date:   2019-10-28 19:15:00 +0800
categories: Fortran 
tags:  Fortran Lapack ScaLapack
author: cndaqiang
mathjax: true
---
* content
{:toc}







## Lapack
### 矩阵存储
![](/uploads/2019/10/lapackband.png)

### 代码示例
```
subroutine inv_gb (N,KL,KU,A,invA,Info)
   implicit none 

   integer,intent(in) :: N         ! Size of the matrix.
   integer,intent(in) :: KL        ! Number of subdiagonals in the band of B.
   integer,intent(in) :: KU        ! Number of superdiagonals in the band of B.
   real(8),intent(in) :: A(N,N)    ! Banded atrix to be inverted(full matrix)
   real(8),intent(out):: invA(N,N) ! A^-1 (full matrix)
   integer,intent(out):: Info      ! Error codes.
 
 ! Local variables.
 
   real(8),allocatable:: LUdecom(:,:)
   integer,allocatable:: LUpivot(:)
   real(8),allocatable:: LUwork (:)
   integer :: i,j,m
 
 ! Allocate auxiliary memory.
 
   allocate (LUpivot(N));  LUpivot=0
   allocate (LUwork(N*N)); LUwork =0.d0 
   allocate (LUdecom(2*KL+KU+1,N))

   !change full matrix to banded matrix
   m=n
   Do j=1,N 
      DO i = max(1,j-ku),min(m,j+kl)
         LUdecom(kl+ku+1+i-j,j)=A(i,j)
      ENDDO
   ENDDO

 
 ! Perform LU decomposition.
   call DGBTRF (N,N,KL,KU,LUdecom,2*KL+KU+1,LUpivot,Info)
   if (Info.ne.0) return
 
 ! Perform matrix inversion.
 
   invA=0.d0
   do i=1,N
     invA(i,i)=1.d0
     call DGBTRS ('N',N,KL,KU,1,LUdecom,2*KL+KU+1,LUpivot,invA(i,:),N,Info)
   end do
 
   deallocate (LUpivot,LUwork,LUdecom)
   return
  end subroutine inv_gb
```

## ScaLapack

### 矩阵存储
![](/uploads/2019/10/scalapackbd.png)

### 代码示例

```fortran
subroutine PDGBTRF_EXAMPLE3ZZ()

!
!     This is an example of using PDGBTRF and PDGBTRS.
!     A matrix of size 9x9 is distributed on a 1x3 process
!     grid, factored, and solved in parallel.
!     
!
      INTEGER          ICTXT, INFO, MYCOL, MYROW, NPCOL, NPROW
      INTEGER          BWL, BWU, N, NB, LAF, LWORK

      PARAMETER       (BWL = 1, BWU = 1, NB = 4 , N = 10) !NB Blocksize 4 4 2 
                       ! P*NB>= mod(JA-1,NB)+N.
                       !算法要求一个处理器不能分布两block矩阵
                       !有些时候，算法还不能保证分布能算出来，INFO > 0
                       !这还和数据有关系
      PARAMETER       (LDA = 1+2*BWL+2*BWU +10 , LNA=4) 
      PARAMETER       ( LDB=NB+10 , NRHS=N) !LNB=NRHS
      PARAMETER       (LAF=(NB+BWU)*(BWL+BWU)+6*(BWL+BWU)*(BWL+2*BWU) +10 )
      PARAMETER       (LWORK = NRHS*(NB+2*BWL+4*BWU)+ 10 )

      INTEGER          DESCA(7), DESCB(7), IPIV(NB+10), FILL_IN,I
      !                                      IPIV(>= DESCA( NB ))
      !DOUBLE PRECISION A(LDA,LNA),B(LDB,NRHS),AF(LAF),WORK(LWORK)
      COMPLEX(16) A(LDA,LNA),B(LDB,NRHS),AF(LAF),WORK(LWORK)

!     
!     INITIALIZE THE PROCESS GRID
!
      NPROW = 1
      NPCOL = 3
      CALL SL_INIT( ICTXT, NPROW, NPCOL )

      CALL BLACS_GRIDINFO( ICTXT, NPROW, NPCOL, MYROW, MYCOL )
      IF( MYROW.LT.0 .OR. MYCOL.LT.0 ) THEN
         return
      ENDIF

!
!     DISTRIBUTE THE MATRIX ON THE PROCESS GRID
!     Initialize the array descriptors for the matrices A and B
!
      DESCA( 1 ) = 501                   ! descriptor type
      DESCA( 2 ) = ICTXT                 ! BLACS process grid handle
      DESCA( 3 ) = N                     ! number of rows in A
      DESCA( 4 ) = NB                    ! Blocking factor of the distribution
      DESCA( 5 ) = 0                     ! size of block rows
      DESCA( 6 ) = LDA         ! leading dimension of A
      DESCA( 7 ) = 0                     ! process row for 1st row of A

      !这个只决定行分布，列都是一样的NRHS

      DESCB( 1 ) = 502                   ! descriptor type
      DESCB( 2 ) = ICTXT                 ! BLACS process grid handle
      DESCB( 3 ) = N                     ! number of rows in B
      DESCB( 4 ) = NB                    ! Blocking factor of the distribution
      DESCB( 5 ) = 0                     ! size of block rows
      DESCB( 6 ) = LDB                   ! leading dimension of B
      DESCB( 7 ) = 0                     ! process row for 1st row of B

!
!     Generate matrices A and B and distribute them to the process grid
!    AX=B
!     Perform LU factorization
!'

      !A的值无所谓了，只要能分解就行
      A=cmplx(1.0_dp,1.0_dp)

      !write(*,*) "LAF,LWORK",LAF,LWORK
      CALL PZGBTRF( N, BWL, BWU, A(1,1), 1, DESCA, IPIV, &
               AF, LAF, WORK, LWORK, INFO )
      !INFO < 0  为非法值
      !INFO > 0 LU分解失败，矩阵不合理，local(intro)失败，inter失败
      !write(*,*) "LAF,LWORK After",AF(1),WORK(1)

      IF (INFO/=0) THEN
         write(*,*) 'Info flag from PDGBTRF = ',INFO, ', Col = ',MYCOL
         GOTO 100
      END IF

      write(*,*) "Done PDGBTRF"


!
!     Solve using the LU factorization from PDGBTRF
!
      
      CALL PZGBTRS('N', N, BWL, BWU, NRHS, A(1,1), 1, DESCA, IPIV, &
             B(1,1), 1, DESCB, AF, LAF, WORK, LWORK, INFO)
      CALL blacs_barrier( ICTXT, 'A' )
      


!call pdgbtrs(trans, n, bwl, bwu, nrhs, a, ja, desca, ipiv, b, ib, descb, af, laf, work, lwork, info)

      IF (INFO/=0) THEN
         write(*,*) 'Info flag from PDGBTRS = ',INFO, ', Col = ',MYCOL
         GOTO 100
      END IF

      IF(MYCOL .eq. 0) THEN
         DO I=1,NRHS
         write(*,*) "Mycol",MYCOL,"NRHS",I,B(:,I)
         ENDDO
      ENDIF

         !write(*,200) 'X(',3*MYCOL+1,':',3*MYCOL+NB,') = ',B
200  format((a2,I3,a1,I3,a4,3(f10.2,2x)))
!
!     Release the process grid and exit BLACS
!
100  CALL BLACS_GRIDEXIT( ICTXT )
     CALL BLACS_EXIT( 0 )
     stop
   end subroutine PDGBTRF_EXAMPLE3ZZ

```



------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
