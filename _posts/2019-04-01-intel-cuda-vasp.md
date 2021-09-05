---
layout: post
title:  "Intel Parallel Studio XE & Cuda 10 编译GPU版本VASP-5.4.4 "
date:   2019-04-01 21:44:00 +0800
categories: DFT
tags: vasp centos Intel
author: cndaqiang
mathjax: true
---
* content
{:toc}


很多内容不解释了，前提工作同[Intel Parallel Studio XE 编译VASP](/2018/01/15/intel-mpi-vasp/)<br>
按照[Intel Parallel Studio XE 编译VASP](/2018/01/15/intel-mpi-vasp/)安装编译器<br>
按照[Centos 7 安装Cuda10 过程记录](/2019/03/31/cuda/)安装Cuda



## 参考
[GPU-ACCELERATED VASP](https://www.nvidia.com/en-us/data-center/gpu-accelerated-applications/vasp/)

## 解压修改
```
 tar xzvf vasp.5.4.4.tar.gz 
 cd vasp.5.4.4
 cp arch/makefile.include.linux_intel makefile.include 
 vi makefile.include 
```
### `makefile.include` 文件修改

MKL和编译器的配置同[Intel Parallel Studio XE 编译VASP](/2018/01/15/intel-mpi-vasp/)<br>

cuda配置

针对intel 15 和cuda10<br>
修改CUDA_LIB，指定`-lcublas -lcuda`的地址，如`CUDA_LIB   := -L$(CUDA_ROOT)/lib64 -lnvToolsExt -lcudart  -lcufft -L/usr/lib64 -lcuda -lcublas`<br>
我在安装cuda时自定义了安装目录，因此指定了`-L/home/data/software/usr/local/cuda-10.0/lib64 -lcublas`
```
# GPU Stuff

CPP_GPU    = -DCUDA_GPU -DRPROMU_CPROJ_OVERLAP -DUSE_PINNED_MEMORY -DCUFFT_MIN=28 -UscaLAPACK

OBJECTS_GPU = fftmpiw.o fftmpi_map.o fft3dlib.o fftw3d_gpu.o fftmpiw_gpu.o

CC         = icc
CXX        = icpc
CFLAGS     = -fPIC -DADD_ -Wall -openmp -DMAGMA_WITH_MKL -DMAGMA_SETAFFINITY -DGPUSHMEM=300 -DHAVE_CUBLAS

CUDA_ROOT  ?= /usr/local/cuda/
NVCC       := $(CUDA_ROOT)/bin/nvcc -ccbin=icc
CUDA_LIB   := -L$(CUDA_ROOT)/lib64 -lnvToolsExt -lcudart -lcuda -lcufft \
              -L/home/data/software/usr/local/cuda-10.0/lib64 -lcublas

GENCODE_ARCH    := -gencode=arch=compute_30,code=\"sm_30,compute_30\" \
                   -gencode=arch=compute_35,code=\"sm_35,compute_35\" \
                   -gencode=arch=compute_60,code=\"sm_60,compute_60\"

MPI_INC    = $(I_MPI_ROOT)/include64/
```

针对intel19还需更改一处，将`CFLAGS`中的`-openmp`改为`-oqpenmp`
```
CFLAGS     = -fPIC -DADD_ -Wall -oqpenmp -DMAGMA_WITH_MKL -DMAGMA_SETAFFINITY -DGPUSHMEM=300 -DHAVE_CUBLAS
```

## 编译
```
make gpu
```

在`bin`目录有GPU版本的vasp生成
```
$  ls bin
vasp_gam  vasp_gpu  vasp_ncl  vasp_std
```

## 运行
同非GPU版本一样`mpirun -np 核数 vasp_gpu`,运行过程

INCAR参数要添加
```
LREAL = .TRUE. or LREAL = A
NCORE = 1
```

运行途中，可以查看显卡的占用
![](/uploads/2019/04/vasp-gpu.PNG)

## Benchmark
在进行大体系计算时，计算速度明显
![](/uploads/2019/04/benchmark.JPG)
体系从小到大对比[GPU-vasp测试.pdf](/web/file/2019/GPU-vasp测试.pdf)



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
