---
layout: post
title:  "Intel编译WannierTools"
date:   2022-09-14 20:44:00 +0800
categories: WannierTools
tags:  gnu WannierTools
author: cndaqiang
mathjax: true
---
* content
{:toc}





## 环境
松山湖新服务器:`CentOS Linux release 7.9.2009 (Core)`

## 依赖库
- [arpack](https://people.sc.fsu.edu/~jburkardt/f_src/arpack/arpack.html)
- Lapack

## 安装
### arpack
由于编译arpack需要libtool等一系列工具,而服务器上又没有,<br>
因此**我们直接下载编译好的arpack静态库以及其依赖库**

注
- 服务器的login001和login002节点的环境不一样
- 静态的arpack里面也有一些依赖,集群上没有,还需安装其他依赖<br>
具体需要补装的依赖,通过[普通用户yum安装软件包,rpm包](/2019/09/06/yumlocal/)中的`yum.sh`,安装动态的arpack,然后ldd查看找不到的项<br>
最后发现需要安装`arpack,libgfortran`

### Lapack
使用MKL
### WannierTools
```bash
#加载环境
source /share/apps/intel-oneAPI-2021/compiler/2022.0.2/env/vars.sh intel64
source /share/apps/intel-oneAPI-2021/mkl/2022.0.2/env/vars.sh intel64
source /share/apps/intel-oneAPI-2021/mpi/2021.5.1/env/vars.sh intel64
#创建编译目录
ROOT=$HOME/soft/oneapi21
mkdir -p $ROOT/source
#下载arpack-static包,下载静态包及其依赖,编译后不用添加动态的路径
cd $ROOT/source
wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/a/arpack-static-3.1.3-2.el7.x86_64.rpm
wget http://mirror.centos.org/centos/7/os/x86_64/Packages/libgfortran-static-4.8.5-44.el7.x86_64.rpm
for i in $( ls *.rpm );do rpm2cpio $i | cpio -idvm ; done
#安装WannierTools
cd $ROOT/source
git clone https://github.com/quanshengwu/wannier_tools.git
#如果上面下载太慢,浏览器下载https://github.com/quanshengwu/wannier_tools传到服务器上
cd wannier_tools/src/
cp Makefile.intel-mpi Makefile
echo ARPACK=$ROOT/source/usr/lib64/libarpack.a  $ROOT/source/usr/lib/gcc/x86_64-redhat-linux/4.8.2/libgfortran.a>> Makefile
make
```

## 测试
```
[SSLAB2 c n da qiang@login002 WC]$cd $ROOT/source/wannier_tools/examples/WC
[SSLAB2 cndaqiang@login002 WC]$ls
POSCAR  wannier90_hr.dat.tar.gz  wannier90.win  wt.in
#这里应该先运行一下VASP.这里就不运行了,直接测试wt.x能运行就可以
[SSLAB2 cndaqiang@login002 WC]$../../bin/wt.x -i wt.in
[SSLAB2 cndaqiang@login002 WC]$ls
POSCAR  POSCAR-Folded  POSCAR-mag  POSCAR-rotated  POSCAR-slab  POSCAR-SURFACE  wannier90_hr.dat.tar.gz  wannier90.win  wt.in  WT.out
[SSLAB2 cndaqiang@login002 WC]$grep 'CPU cores' WT.out
 You are using     1 CPU cores
#并行测试
[SSLAB2 cndaqiang@login002 WC]$mpirun -np 4 ../../bin/wt.x -i wt.in
[SSLAB2 cndaqiang@login002 WC]$grep 'CPU cores' WT.out
 You are using     4 CPU cores
#并行测试
```



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
