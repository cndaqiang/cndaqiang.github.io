source /share/apps/intel-oneAPI-2021/compiler/2022.0.2/env/vars.sh intel64
source /share/apps/intel-oneAPI-2021/mkl/2022.0.2/env/vars.sh intel64
source /share/apps/intel-oneAPI-2021/mpi/2021.5.1/env/vars.sh intel64
module load /share/modulefile/gnu/10.2.0

ROOT=$HOME/soft/oneapi21

mkdir -p $ROOT/source
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
make -j10
make install

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

