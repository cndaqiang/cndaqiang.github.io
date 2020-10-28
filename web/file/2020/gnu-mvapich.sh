#ROOT=$HOME/opt/gnu-mvapich
ROOT=/opt/gnu-mvapich
rm -rf $ROOT
mkdir -p $ROOT
mkdir $ROOT/source

#创建编译脚本
cd $ROOT/source
cat << EOF > ./make.sh
if [ -e ./netlib.py ]
then
    ./setup.py --prefix=$ROOT/math --downall
else
    make -j10
    make
    make install
fi
EOF


MATHDIR=$ROOT/math/lib
export LD_LIBRARY_PATH=$ROOT/libxc-4.3.4/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ROOT/fftw-3.3.3/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ROOT/math/lib:$LD_LIBRARY_PATH
export LIBRARY_PATH=$ROOT/libxc-4.3.4/lib:$LIBRARY_PATH
export LIBRARY_PATH=$ROOT/fftw-3.3.3/lib:$LIBRARY_PATH
export LIBRARY_PATH=$ROOT/math/lib:$LIBRARY_PATH
export C_INCLUDE_PATH=$ROOT/libxc-4.3.4/include:$C_INCLUDE_PATH
export C_INCLUDE_PATH=$ROOT/fftw-3.3.3/include:$C_INCLUDE_PATH
export C_INCLUDE_PATH=$ROOT/math/include:$C_INCLUDE_PATH
export PATH=$ROOT/fftw-3.3.3/bin:$PATH


#mvapich
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages/mirrors/mvapich2/mvapich2-2.3.1.tar.gz 
tar xzvf mvapich2-2.3.1.tar.gz
cd mvapich2-2.3.1/
./configure --prefix=$ROOT/mvapich2-2.3.1 CC=gcc FC=gfortran CXX=g++
make -j40
#安装
make install


#libxc-4.3.4 for octopus-10.1
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/libxc/libxc-4.3.4.tar.gz
tar xzvf libxc-4.3.4.tar.gz 
cd libxc-4.3.4
#--enable-shared 动态库
./configure --prefix=$ROOT/libxc-4.3.4  CC=gcc CXX=g++ FC=gfortran --enable-shared 
bash ../make.sh

#fft
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/fftw/fftw-3.3.3.tar.gz
tar xzvf fftw-3.3.3.tar.gz
cd fftw-3.3.3/
./configure --prefix=$ROOT/fftw-3.3.3 --enable-mpi --enable-shared
bash ../make.sh



#从0编译动态库scalapack
if [ ! -d $ROOT/math ]
then
    mkdir $ROOT/math
    mkdir $ROOT/math/lib
    mkdir $ROOT/math/include
fi

cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/math/lapack-3.8.0.tar.gz
rm -rf lapack-3.8.0
tar xzvf lapack-3.8.0.tar.gz
cd lapack-3.8.0/
#修改编译参数，并默认输出动态库

#BLAS&LAPACK
echo -e "
all:libblas.so
libblas.so: \$(ALLOBJ)
\t \$(FORTRAN) -shared -Wl,-soname,\$@ -o \$@ \$(ALLOBJ)
" >> BLAS/SRC/Makefile
#TMG
echo -e "
all:libtmg.so
libtmg.so: \$(ALLOBJ)
\t \$(FORTRAN) -shared -Wl,-soname,\$@ -o \$@ \$(ALLOBJ)
" >> TESTING/MATGEN/Makefile
#LAPACK
echo -e "
all: liblapack.so
liblapack.so: \$(ALLOBJ)
\t \$(FORTRAN) -shared -Wl,-soname,\$@ -o \$@ \$(ALLOBJ)
" >> SRC/Makefile

cp make.inc.example make.inc
echo "OPTS += -fPIC" >> make.inc
echo "NOOPT += -fPIC" >> make.inc
echo -e "
MATHDIR=$ROOT/math/lib
install:all
\t cp $PWD/BLAS/SRC/libblas.so \$(MATHDIR)
\t cp $PWD/SRC/liblapack.so \$(MATHDIR)
\t cp $PWD/TESTING/MATGEN/libtmg.so \$(MATHDIR)
\t cp $PWD/*.a \$(MATHDIR)
" >> make.inc
#安装
make -j36 #必须用make，用其他参数/完成后再输make会编译测试程序，没必要
#不可以注释Makefile中
#   all: lapack_install lib blas_testing lapack_testing
#为
#   all: lapack_install lib
#   #blas_testing lapack_testing
#可以跳过测试的过程，编译更快
# 因为blas_testing依赖blas的编译
#如果非要注释，要添加依赖blas

#Scalapack
cd $ROOT/source
wget https://cndaqiang.gitee.io/packages//mirrors/math/scalapack-2.0.2.tgz
rm -rf scalapack-2.0.2
tar xzvf scalapack-2.0.2.tgz
cd scalapack-2.0.2

#echo -e "
#ALLOBJ += \$(SLASRC) \$(DLASRC)  \$(CLASRC) \$(ZLASRC)  \
#\t   \$(SCLAUX) \$(DZLAUX) \$(ALLAUX)
#all:libscalapack.so
#libscalapack.so: \$(ALLOBJ)
#\t \$(FC) -shared -Wl,-soname,\$@ -o \$@ \$(ALLOBJ)
#" >> SRC/Makefile

#使用fPIC参数，这样静态库可以转为动态库
cp SLmake.inc.example SLmake.inc
echo "FC += -fPIC" >> SLmake.inc
echo "CC += -fPIC" >> SLmake.inc
echo -e "
MATHDIR=$ROOT/math/lib
install: all
\t \$(FC) -shared -o $PWD/libscalapack.so -Wl,--whole-archive $PWD/libscalapack.a -Wl,--no-whole-archive
\t cp $PWD/libscalapack.so \$(MATHDIR)
" >> SLmake.inc
#不支持-j20,就得逐个编译，把每个库依次打包添加到libscalapack.a，没编译成功也有libscalapack.a
make  install

