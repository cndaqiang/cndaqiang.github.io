---
layout: post
title:  "SSLAB服务器上编译基于lammps引擎的SSAGES"
date:   2023-03-21 11:38:00 +0800
categories: MD
tags: ssages lammps
author: cndaqiang
mathjax: true
---
* content
{:toc}

编译yambo





## 下载源代码
因为编译的过程需要从github下载源码,国内服务器网络不畅.
将需要的代码同步到gitee平台.并修改SSAGES源码中下载其他依赖的环境,修改内容见附录


## 注意
- 编译完SSAGES后,lammps的源代码就被改了,后期更新lammps的包,就不能在lammps目录编译,而是要在SSAGES的目录执行编译命令
- 查看`./hooks/lammps/CMakeLists.txt`可以得到支持的lammps版本

```cmake
set (SUPPORTED_LAMMPS_VERSIONS
     "10 Aug 2015"  "7 Dec 2015"
     "16 Feb 2016" "14 May 2016" "30 Jul 2016"
     "5 Nov 2016" "17 Nov 2016"
     "31 Mar 2017" "11 Aug 2017"
     "16 Mar 2018" "22 Aug 2018" "12 Dec 2018"
     "5 Jun 2019" "7 Aug 2019"
     "3 Mar 2020" "29 Oct 2020"
    )
```

## 编译
```
#环境
module load compiler/gcc/gcc_8.3.0
module load mpi/openmpi/gcc/4.1.1
#去掉intel
delet=intel
VARS=( CP_INTEL_DIR PATH LD_LIBRARY_PATH LIBRARY_PATH  MANPATH INCLUDE FPATH CPATH INTEL_LICENSE_FILE MKLROOT TBBROOT MIC_LD_LIBRARY_PATH NLSPATH)
for VAR in ${VARS[@]}
do
    unset A
    for term in $(echo $(eval echo \$$VAR) | awk -F: '{for(i=1;i<=NF;i++){printf "%s ", $i}}')
    do
        if [ $( echo $term | grep -v $delet ) ]
        then
            if [ ! $A ]
            then
                A=$term
            else
                A=$A:$term
            fi
        fi
    done
    export $VAR=$A
done

#创建编译目录
ROOT=$HOME/soft/gnu8-openmpi411/
mkdir -p $ROOT
cd $ROOT
#lammps
wget https://download.lammps.org/tars/lammps-29Oct2020.tar.gz --no-check-certificate
tar xzvf lammps-29Oct2020.tar.gz
cd lammps-29Oct20/src
make serial -j30
make mpi -j20

#SSAGES
cd $ROOT
git clone https://gitee.com/cndaqiang/ssages_mirror_gitee.git
#如果没有网络环境，可以上传我打包的无网络版本https://gitee.com/cndaqiang/ssages_mirror_local
cd ssages_mirror_gitee
mkdir build ; cd build
#需要制定gcc路径,不然找的还是系统默认的gcc 4.8.5
cmake -DLAMMPS_SRC=$ROOT/lammps-29Oct20/src -DCMAKE_C_COMPILER=/public/software/compiler/gcc-8.3.0/bin/gcc -DCMAKE_CXX_COMPILER=/public/software/compiler/gcc-8.3.0/bin/g++ ..
make -j10
```


## 后期更新lammps需要的package
```
cd $ROOT/lammps-29Oct20/src
make yes-RIGID yes-KSPACE yes-MOLECULE yes-CLASS2
cd $ROOT/ssages_mirror_gitee/build/
make -j20
```
环境变量
```
echo "
export LD_LIBRARY_PATH=$ROOT/ssages_mirror_gitee/build:\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ROOT/lammps-29Oct20/src/:\$LD_LIBRARY_PATH
export PATH=$ROOT/ssages_mirror_gitee/build:\$PATH
export PATH=$ROOT/lammps-29Oct20/src/:\$PATH
"
```

## 运行
```
cd $ROOT/ssages_mirror_gitee//Examples/User/Umbrella/LAMMPS
$mpirun -np 4 $ROOT/ssages_mirror_gitee/build/ssages umbrella_input.json
```
输出
```
[SSLAB cndaqiang@login2 LAMMPS]$mpirun -np 4 $ROOT/ssages_mirror_gitee/build/ssages umbrella_input.json
--------------------------------------------------------------------------
WARNING: There was an error initializing an OpenFabrics device.

  Local host:   login2
  Local device: mlx5_0
--------------------------------------------------------------------------
LAMMPS (29 Oct 2020)
Reading data file ...
  orthogonal box = (-22.206855 -19.677099 -19.241968) to (18.793145 21.322901 21.758032)
  1 by 2 by 2 MPI processor grid
  reading atoms ...
  14 atoms
  scanning bonds ...
  4 = max bonds/atom
  scanning angles ...
  6 = max angles/atom
  scanning dihedrals ...
  9 = max dihedrals/atom
  reading bonds ...
  13 bonds
  reading angles ...
  24 angles
  reading dihedrals ...
  27 dihedrals
Finding 1-2 1-3 1-4 neighbors ...
  special bond factors lj:    0.0      0.0      0.5
  special bond factors coul:  0.0      0.0      0.5
     4 = max # of 1-2 neighbors
     6 = max # of 1-3 neighbors
     9 = max # of 1-4 neighbors
    13 = max # of special neighbors
  special bonds CPU = 0.000 seconds
  read_data CPU = 0.010 seconds
14 atoms in group mobile
PPPM initialization ...
  using 12-bit tables for long-range coulomb (../kspace.cpp:328)
  G vector (1/distance) = 0.25404746
  grid = 30 30 30
  stencil order = 5
  estimated absolute RMS force accuracy = 3.1790139e-06
  estimated relative force accuracy = 9.573506e-09
  using double precision KISS FFT
  3d grid and FFT values/proc = 17908 7200
Neighbor list info ...
  update every 1 steps, delay 0 steps, check yes
  max neighbors/atom: 2000, page size: 100000
  master list distance cutoff = 14
  ghost atom cutoff = 14
  binsize = 7, bins = 6 6 6
  1 neighbor lists, perpetual/occasional/extra = 1 0 0
  (1) pair lj/cut/coul/long, perpetual
      attributes: half, newton on
      pair build: half/bin/newton
      stencil: half/bin/3d/newton
      bin: standard
Setting up Verlet run ...
  Unit style    : real
  Current step  : 0
  Time step     : 1.0
Per MPI rank memory allocation (min/avg/max) = 13.25 | 13.27 | 13.29 Mbytes
---------------- Step        0 ----- CPU =      0.0000 (sec) ----------------
TotEng   =         4.3057 KinEng   =         0.0000 PotEng   =         4.3057
E_bond   =         1.4573 E_angle  =         0.8367 E_dihed  =         0.0000
E_impro  =         0.0000 E_vdwl   =         0.0530 E_coul   =         8.0587
E_long   =        -6.0998 Temp     =         0.0000 Press    =        45.1869
Volume   =     68921.0000
---------------- Step      100 ----- CPU =      0.1748 (sec) ----------------
TotEng   =        96.2003 KinEng   =        49.3740 PotEng   =        46.8263
E_bond   =         6.7676 E_angle  =        35.7110 E_dihed  =         1.8397
E_impro  =         0.0000 E_vdwl   =         1.0362 E_coul   =         7.5581
E_long   =        -6.0864 Temp     =      1274.1505 Press    =        -7.6435
Volume   =     68921.0000
```


## 附录
### 修改的部分代码使用gitee镜像  
注:Googletest没有用到，其实不用修改
```diff
(python37) cndaqiang@mommint:~/code/ssages_mirror_gitee$ git diff fb178779371cf8d7bbc25ce6b86f31b79395489c
diff --git a/cmake/Modules/FetchGoogletest.cmake b/cmake/Modules/FetchGoogletest.cmake
index ec53a9b..f490da4 100644
--- a/cmake/Modules/FetchGoogletest.cmake
+++ b/cmake/Modules/FetchGoogletest.cmake
@@ -1,4 +1,4 @@
-set(GTEST_REPOSITORY "https://github.com/google/googletest.git")
+set(GTEST_REPOSITORY "https://gitee.com/cndaqiang/googletest.git")
 set(GTEST_TAG "release-1.10.0")

 # http://stackoverflow.com/questions/9689183/cmake-googletest
diff --git a/cmake/Modules/FetchJsonCpp.cmake b/cmake/Modules/FetchJsonCpp.cmake
index 677dd63..740d3df 100644
--- a/cmake/Modules/FetchJsonCpp.cmake
+++ b/cmake/Modules/FetchJsonCpp.cmake
@@ -1,4 +1,4 @@
-set(JSONCPP_REPOSITORY "https://github.com/open-source-parsers/jsoncpp.git")
+set(JSONCPP_REPOSITORY "https://gitee.com/cndaqiang/jsoncpp.git")
 set(JSONCPP_TAG 1.9.4)

 ExternalProject_Add(jsoncpp
diff --git a/cmake/Modules/FetchMxx.cmake b/cmake/Modules/FetchMxx.cmake
index 69bff58..ae766f3 100644
--- a/cmake/Modules/FetchMxx.cmake
+++ b/cmake/Modules/FetchMxx.cmake
@@ -1,4 +1,4 @@
-set(MXX_REPOSITORY "https://github.com/patflick/mxx.git")
+set(MXX_REPOSITORY "https://gitee.com/cndaqiang/mxx.git")
 set(MXX_TAG "master")
diff --git a/cmake/Modules/FetchEigen.cmake b/cmake/Modules/FetchEigen.cmake
index 61a271b..a357330 100644
--- a/cmake/Modules/FetchEigen.cmake
+++ b/cmake/Modules/FetchEigen.cmake
@@ -1,4 +1,4 @@
-set(EIGEN_REPOSITORY "https://gitlab.com/libeigen/eigen.git")
+set(EIGEN_REPOSITORY "https://gitee.com/cndaqiang/eigen.git")
 set(EIGEN_TAG 3.3.7)
 set(EIGEN_PATCH "${CMAKE_CURRENT_SOURCE_DIR}/include/patches/eigen-using-std-real.patch")
```

### 修改的代码无需网络环境编译
- https://gitee.com/cndaqiang/ssages_mirror_local
- 还是修改`cmake/Modules`目录的cmake文件,修改DOWNLOAD_COMMAND

如
```cmake
set(JSONCPP_REPOSITORY "${CMAKE_CURRENT_SOURCE_DIR}/Fetch_local/jsoncpp")
set(JSONCPP_TAG 1.9.4)

ExternalProject_Add(jsoncpp
    # Using DOWNLOAD_COMMAND instead of GIT_REPOSITORY to pass some convenient git flags.
    # For instance, GIT_SHALLOW is available from CMake 3.6
    DOWNLOAD_COMMAND cp -frp ${JSONCPP_REPOSITORY} ${CMAKE_CURRENT_SOURCE_DIR}/build/jsoncpp-prefix/src/
```
Mxx和Eigen同理修改,需要下载的依赖已经提前下载到`Fetch_local`目录



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
