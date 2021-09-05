---
layout: post
title:  "Gcc OPENMPI Centos 编译octopus-9 遇到的问题和解决方案"
date:   2019-06-04 20:57:00 +0800
categories: DFT
tags:  DFT Linux octopus
author: cndaqiang
mathjax: true
---
* content
{:toc}






## 问题
```
make[2]: Entering directory `/public/home/cndaqiang/soft/gcc-MVAPICH/sourcecode/octopus-test/octopus-9.0/src'
/lib/cpp -ansi  -I../src/include -I../src/include -I../external_libs/spglib-1.9.9/src -I../liboct_parser -I/public/home/cndaqiang/soft/gcc-MVAPICH/gsl-1.14/include  -I/public/home/cndaqiang/soft/gcc-MVAPICH/fftw-3.3.3/include -DSHARE_DIR='"/public/home/cndaqiang/soft/gcc-MVAPICH/sourcecode/octopus-test/octopus-9.0/../../octopus-9.0/share/octopus"' -I../external_libs/metis-5.1/include/ -I. scf/scf.F90 | \
  ../build/preprocess.pl - \
  "" "yes" "yes" > scf/scf_oct.f90
mpif90 -O3 -ffree-line-length-none -I ../external_libs/bpdn -I ../external_libs/dftd3 -I ../external_libs/spglib-1.9.9/src/ -I /public/home/cndaqiang/soft/gcc-MVAPICH/libxc-2.0.0/include   -I/public/home/cndaqiang/soft/gcc-MVAPICH/fftw-3.3.3/include  -c  -o scf/scf.o scf/scf_oct.f90
scf/scf.F90:331.84:

d. bitand(hm%xc_family, XC_FAMILY_OEP + XC_FAMILY_MGGA + XC_FAMILY_HYB_MGGA) /=
                                                                           1
Error: Symbol 'xc_family_hyb_mgga' at (1) has no IMPLICIT type
make[2]: *** [scf/scf.o] Error 1
make[2]: Leaving directory `/public/home/cndaqiang/soft/gcc-MVAPICH/sourcecode/octopus-test/octopus-9.0/src'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/public/home/cndaqiang/soft/gcc-MVAPICH/sourcecode/octopus-test/octopus-9.0'
make: *** [all] Error 2
```
## 原因&解决方法
```
vi src/scf/scf.F90 
```
将
```
!  use xc_functl_oct_m
```
换为
```
  use xc_functl_oct_m, only:XC_FAMILY_HYB_MGGA
```
来自OCTOPUS交流群的@greensea说：升级gfortran也能解决

之后得编译安装，同[centos6.5 Gcc Openmpi 编译octopus-7.1](/2018/09/15/gun-openmpi-octopus-7.1/)

**编译后测试运行通过，运行结果正确性未测试。**

## 附录:在松山湖材料实验室超算上编译octopus-9
```
module load  mpi/mvapich2/gnu/2.3b
FFTWDIR=/public/home/cndaqiang/soft/gcc-MVAPICH/fftw-3.3.3
GSDIR=/public/home/cndaqiang/soft/gcc-MVAPICH/gsl-1.14
LIBXCDIR=/public/home/cndaqiang/soft/gcc-MVAPICH/libxc-2.0.0
MATHDIR=/public/home/cndaqiang/soft/gcc-MVAPICH/scalapack/lib
export LD_LIBRARY_PATH=$MATHDIR:$LD_LIBRARY_PATH
export PATH=$FFTWDIR/bin:$PATH
export LD_LIBRARY_PATH=$FFTWDIR/lib:$LD_LIBRARY_PATH
export PATH=$GSDIR/bin:$PATH
export LD_LIBRARY_PATH=$GSDIR/lib:$LD_LIBRARY_PATH
export PATH=$LIBXCDIR/bin:$PATH
export LD_LIBRARY_PATH=$LIBXCDIR/lib:$LD_LIBRARY_PATH

 ./configure --prefix=$(pwd)/../../octopus-9.0  --with-libxc-prefix=$LIBXCDIR  --with-blas='-L/public/home/cndaqiang/soft/gcc-MVAPICH/scalapack/lib -lrefblas' --with-lapack='-L/public/home/cndaqiang/soft/gcc-MVAPICH/scalapack/lib -ltmg -lreflapack' --with-scalapack='-L/public/home/cndaqiang/soft/gcc-MVAPICH/scalapack/lib -lscalapack' --with-gsl-prefix=$GSDIR  --with-fftw-prefix=$FFTWDIR --enable-mpi CC=mpicc FC=mpif90 CXX=mpicxx FCFLAGS="-O3 -ffree-line-length-none" CFLAGS=-O3   
```






------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
