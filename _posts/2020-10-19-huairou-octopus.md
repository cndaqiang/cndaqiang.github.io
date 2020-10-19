---
layout: post
title:  "怀柔计算中心安装octopus10.1&4.1.2"
date:   2020-10-19 21:48:00 +0800
categories: DFT
tags:  gnu octopus
author: cndaqiang
mathjax: true
---
* content
{:toc}



```bash
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
cat << EOF > ./make.sh
#!/bin/bash
#SBATCH -J make
#SBATCH -p debug
#SBATCH -N 1
#SBATCH --ntasks-per-node=10
#SBATCH -o make.out

module load gnu8/8.3.0
module load module load openmpi3/3.1.4
if [ -e ./setup.py ]
then
    ./setup.py --prefix=$PWD/../../math --downall
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
#解决libxc编译错误http://cndaqiang.gitee.io//2018/09/18/centos7-octopus-4.1.2/
qsub ../make.sh

#gsl
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/gs/gsl-1.14.tar.gz
tar xzvf gsl-1.14.tar.gz
cd gsl-1.14
mkdir build; cd build
../configure --prefix=$ROOT/gsl-1.14
qsub ../make.sh

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
#解决libxc编译错误http://cndaqiang.gitee.io//2018/09/18/centos7-octopus-4.1.2/
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