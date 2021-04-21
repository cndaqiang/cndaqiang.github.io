---
layout: post
title:  "怀柔计算中心/SSLAB编译octopus记录"
date:   2020-10-19 21:48:00 +0800
categories: DFT
tags:  gnu octopus
author: cndaqiang
mathjax: true
---
* content
{:toc}





## [GNU]怀柔计算中心安装octopus10.1&4.1.2

```shell
#-------------------------------------------------------------
#加载编译环境
module swap gnu4 gnu8/8.3.0
module load gnu8/8.3.0
module load openmpi3/3.1.4
#创建编译目录
mkdir -p ~/soft/gnu8-openmpi/
cd ~/soft/gnu8-openmpi/
ROOT=$PWD
mkdir $ROOT/source
#创建编译脚本
cd $ROOT/source
cat << EOF > ./make.sh
#!/bin/bash
#SBATCH -J make
#SBATCH -p debug
#SBATCH -N 1
#SBATCH --ntasks-per-node=10
#SBATCH -o make.out


module load gnu8/8.3.0
module load module load openmpi3/3.1.4
if [ -e ./netlib.py ]
then
    ./setup.py --prefix=$ROOT/math --downall
else
    make -j10
    make install
fi
EOF


#编译scalapack
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/math/scalapack_installer_CNQ_WO_Net.tar.gz
tar xzvf scalapack_installer_CNQ_WO_Net.tar.gz
cd scalapack_installer
qsub ../make.sh


#libxc-4.3.4 for octopus-10.1
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/libxc/libxc-4.3.4.tar.gz
tar xzvf libxc-4.3.4.tar.gz 
cd libxc-4.3.4
./configure --prefix=$ROOT/libxc-4.3.4  CC=gcc CXX=g++ FC=gfortran
qsub ../make.sh

#libxc-2.0.0 for octous-4.1.2
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/libxc/libxc-2.0.0.tar.gz
tar xzvf libxc-2.0.0.tar.gz 
cd libxc-2.0.0
./configure --prefix=$ROOT/libxc-2.0.0  CC=gcc CXX=g++ FC=gfortran
qsub ../make.sh
#解决libxc编译错误
#按照 http://cndaqiang.gitee.io//2018/09/18/centos7-octopus-4.1.2/
#删除src/libxc.f90中的/* */以其之间的注释部分就可以编译了
vi src/libxc.f90
qsub ../make.sh

#gsl
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/gs/gsl-1.14.tar.gz
tar xzvf gsl-1.14.tar.gz
cd gsl-1.14
mkdir build; cd build
../configure --prefix=$ROOT/gsl-1.14
qsub ../../make.sh

#fft
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/fftw/fftw-3.3.3.tar.gz
tar xzvf fftw-3.3.3.tar.gz
cd fftw-3.3.3/
./configure --prefix=$ROOT/fftw-3.3.3 --enable-mpi
qsub ../make.sh



#------------ octopus-10.1 -------------------------------------------------
#环境展示
echo "
MATHDIR=$ROOT/math/lib
export LD_LIBRARY_PATH=$ROOT/libxc-4.3.4/lib:\$LD_LIBRARY_PATH
export PATH=$ROOT/gsl-1.14/bin:\$PATH
export LD_LIBRARY_PATH=$ROOT/gsl-1.14/lib:\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ROOT/fftw-3.3.3/lib:\$LD_LIBRARY_PATH
export PATH=$ROOT/fftw-3.3.3/bin:\$PATH
"
#octopus-10.1
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/octopus/octopus-10.1.tar.gz
tar xzvf octopus-10.1.tar.gz
cd octopus-10.1

./configure --prefix=$ROOT/octopus-10.1 \
    --with-blas="-L$ROOT/math/lib -lrefblas" \
    --with-lapack="-L$ROOT/math/lib -ltmg -lreflapack"  \
    --with-scalapack="-L$ROOT/math/lib -lscalapack" \
    --with-libxc-prefix=$ROOT/libxc-4.3.4    \
    --with-gsl-prefix=$ROOT/gsl-1.14  \
    --with-fftw-prefix=$ROOT/fftw-3.3.3  \
    --enable-mpi

qsub ../make.sh
#---------- octopus 4 ---------------------------------------------------
#环境展示
echo "
MATHDIR=$ROOT/math/lib
export LD_LIBRARY_PATH=$ROOT/libxc-2.0.0/lib:\$LD_LIBRARY_PATH
export PATH=$ROOT/gsl-1.14/bin:\$PATH
export LD_LIBRARY_PATH=$ROOT/gsl-1.14/lib:\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ROOT/fftw-3.3.3/lib:\$LD_LIBRARY_PATH
export PATH=$ROOT/fftw-3.3.3/bin:\$PATH
"

#octopus-4.1
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/octopus/octopus-4.1.2.tar.gz
tar xzvf octopus-4.1.2.tar.gz
cd octopus-4.1.2


./configure --prefix=$ROOT/octopus-4.1.2 \
    --with-blas="-L$ROOT/math/lib -lrefblas" \
    --with-lapack="-L$ROOT/math/lib -ltmg -lreflapack"  \
    --with-scalapack="-L$ROOT/math/lib -lscalapack" \
    --with-libxc-prefix=$ROOT/libxc-2.0.0    \
    --with-gsl-prefix=$ROOT/gsl-1.14  \
    --with-fft-lib=$ROOT/fftw-3.3.3/lib/libfftw3.a  \
    --enable-mpi

qsub ../make.sh
#提交作业报错终止后
#使用下面命令解决报错，参考来源 http://cndaqiang.gitee.io//2018/09/18/centos7-octopus-4.1.2/
cat << EOF > ./cnq.sh
#!/bin/bash
for i in basic  math   species   ions   grid   poisson   states   xc   hamiltonian   system   scf   td   opt_control   td   sternheimer   main
do
Makefile=src/\${i}/Makefile
#修改.F90.o
hang=\$(grep -n "^.F90.o:"  \$Makefile | awk '{printf "%d\n",\$1}' )
hang=\$(echo -e "\$hang+4"|bc)
sed -i "\${hang}i CNQsed -i '5,41d' \\$\*_oct.f90" \$Makefile
sed -i "\${hang}s/CNQ/\t/g" \$Makefile
hang=\$(echo -e "\$hang-4"|bc)
sed -i "\${hang}i ##### Add by CNQ " \$Makefile
hang=\$(echo -e "\$hang+8"|bc)
sed -i "\${hang}i ##### END CNQ " \$Makefile
#修改.F90_oct.f90
hang=\$(grep -n .F90_oct.f90 \$Makefile | awk '{printf "%d\n",\$1}' )
hang=\$(echo -e "\$hang+4"|bc)
sed -i "\${hang}i CNQsed -i '5,41d' \\$\*_oct.f90" \$Makefile
sed -i "\${hang}s/CNQ/\t/g" \$Makefile
hang=\$(echo -e "\$hang-4"|bc)
sed -i "\${hang}i ##### Add by CNQ " \$Makefile
hang=\$(echo -e "\$hang+6"|bc)
sed -i "\${hang}i ##### END CNQ " \$Makefile
done 
EOF
bash cnq.sh
#重新提交
qsub ../make.sh

```

## [Intel]怀柔计算中心安装octopus10.4
```
module unload openmpi3/3.1.4
module load parallel_studio/2020.2.254
module load intelmpi/2020.2.254

cd $HOME/soft/ifort-impi2020
ROOT=$PWD
mkdir $ROOT/source

```
剩下的同**[Intel]SSLAB安装octopus10.4**

GNU/Intel编译10.4速度对比，差别不大

CalculationMode|GNU怀柔|Intel怀柔
--|--|--
gs|2.765s|2.870s
td|31.222s|32.15s


## [Intel]SSLAB安装octopus10.4

```shell
module load compiler/gcc/gcc_8.3.0
module load compiler/intel/intel-compiler-2019u3
module load mpi/intelmpi/2019u3

cd $HOME/soft/intel2019u3
ROOT=$PWD
mkdir $ROOT/source


#libxc
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/libxc/libxc-4.3.4.tar.gz
tar xzvf libxc-4.3.4.tar.gz 
cd libxc-4.3.4
./configure --prefix=$ROOT/libxc-4.3.4  CC=icc CXX=icpc FC=ifort
make -j20
make install


#gs
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/gs/gsl-1.14.tar.gz
tar xzvf gsl-1.14.tar.gz
cd gsl-1.14
mkdir build; cd build
../configure CC=icc --prefix=$ROOT/gsl-1.14
qsub ../../make.sh

#octopus
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/octopus/octopus-10.4.tar.gz
tar xzvf octopus-10.4.tar.gz
cd octopus-10.4

MKL_DIR=$(echo $MKLROOT | awk -F: '{ print $1 }')
./configure CC=mpiicc CXX=mpiicpc FC=mpiifort \
    --prefix=$ROOT/octopus-10.4 \
    --with-libxc-prefix=$ROOT/libxc-4.3.4    \
    FCFLAGS_FFTW=-I$MKL_DIR/include/fftw  \
    --with-blas="-L$MKL_DIR/lib/intel64 -Wl,--start-group -lmkl_intel_lp64 -lmkl_sequential -lmkl_core -Wl,--end-group -lpthread -lmkl_blacs_intelmpi_lp64 -lmkl_scalapack_lp64 " \
    --with-gsl-prefix=$ROOT/gsl-1.14  \
    --enable-mpi
make -j20
make install


```
运行环境，把下面命令的执行结果进行复制，放在octopus运行脚本的前面
```
echo "
MATHDIR=$ROOT/math/lib
export LD_LIBRARY_PATH=$ROOT/libxc-2.0.0/lib:\$LD_LIBRARY_PATH
export PATH=$ROOT/gsl-1.14/bin:\$PATH
export LD_LIBRARY_PATH=$ROOT/gsl-1.14/lib:\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ROOT/fftw-3.3.3/lib:\$LD_LIBRARY_PATH
export PATH=$ROOT/fftw-3.3.3/bin:\$PATH
"
```



------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
