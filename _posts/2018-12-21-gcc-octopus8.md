---
layout: post
title:  "Gcc OPENMPI 编译octopus-8 遇到的问题和解决方案"
date:   2018-12-21 20:48:00 +0800
categories: DFT
tags:  DFT Linux octopus
author: cndaqiang
mathjax: true
---
* content
{:toc}





## 参考
[2.2 Options controlling Fortran dialect](https://gcc.gnu.org/onlinedocs/gfortran/Fortran-Dialect-Options.html)

## Error: Unterminated character constant beginning at (1)
在使用[centos6.5 gcc Openmpi 编译octopus-7.1](/2018/09/15/gun-openmpi-octopus-7.1/)编译octopus8时，报错

```
mpif90 -O3 -I ../../src/basic -I ../../src/math -I ../../src/species -I ../../src/ions -I ../../src/grid -I ../../src/poisson -I ../../src/frozen -I ../../src/basis_set -I ../../src/states -I ../../src/system -I ../../src/hamiltonian -I ../../src/scf -I ../../src/td -I ../../src/opt_control -I ../../src/sternheimer -I ../../external_libs/bpdn -I ../../external_libs/dftd3 -I ../../external_libs/spglib-1.9.9/src/ -I /home/cndaqiang/soft/libxc-2.0.3/include   -I/home/cndaqiang/soft/OPENMPI-GCC/LIB/fftw-3.3.4/include  -c  -o ps.o ps_oct.f90
ps.F90:842.124:

a,l1)') 'n = ', ps%conf%n(j), 'l = ', ps%conf%l(j), 'j = ', ps%conf%j(j), 'boun
                                                                           1
Error: Unterminated character constant beginning at (1)
make[3]: *** [ps.o] Error 1
make[3]: Leaving directory `/home/cndaqiang/soft/OPENMPI-GCC/octopus-8.3/src/species'
make[2]: *** [all-recursive] Error 1
make[2]: Leaving directory `/home/cndaqiang/soft/OPENMPI-GCC/octopus-8.3/src'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/home/cndaqiang/soft/OPENMPI-GCC/octopus-8.3'
make: *** [all] Error 2
```


## 原因&解决方法
因为gfrtran默认单行代码最大长度为132个字符,octopus的`ps.F90`文件的改行代码过长<br>
我尝试通过改该行代码，使用`&`变成两行，可以编译通过，但之后这样的问题频繁出现，不止一个文件需要改源码<br>
通过查gcc编译参数，可通过`FCFLAGS="-ffree-line-length-none"`让gfortran编译时不限制单行代码数量，编译通过<br>
使用`make check`可以正常


## 附录:在算盘上编译octopus-8
```
GCCDIR=/opt/software/gcc-4.8.4-release
MPIDIR=/opt/software/openmpi
FFTWDIR=/opt/lib/fftw-3.3.7
GSDIR=/opt/lib/gsl-1.9
LIBXCDIR=/opt/lib/libxc-3.0.0

export PATH=$GCCDIR/bin:$PATH
export LD_LIBRARY_PATH=$GCCDIR/lib64:$LD_LIBRARY_PATH
export PATH=$MPIDIR/bin:$PATH
export LD_LIBRARY_PATH=$MPIDIR/lib:$LD_LIBRARY_PATH
export PATH=$FFTWDIR/bin:$PATH
export LD_LIBRARY_PATH=$FFTWDIR/lib:$LD_LIBRARY_PATH
export PATH=$GSDIR/bin:$PATH
export LD_LIBRARY_PATH=$GSDIR/lib:$LD_LIBRARY_PATH
export PATH=$LIBXCDIR/bin:$PATH
export LD_LIBRARY_PATH=$LIBXCDIR/lib:$LD_LIBRARY_PATH
source /opt/software/intel/mkl/bin/mklvars.sh intel64

 ./configure --prefix=$(pwd)/../../octopus-8.3  --with-libxc-prefix=$LIBXCDIR  --with-blas="-lmkl_gf_lp64 -lmkl_sequential -lmkl_core -lmkl_blas95_lp64"  --with-gsl-prefix=$GSDIR  --with-fftw-prefix=$FFTWDIR --enable-mpi CC=mpicc FC=mpif90 CXX=mpicxx FCFLAGS="-O3 -ffree-line-length-none" CFLAGS=-O3   
```


------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
