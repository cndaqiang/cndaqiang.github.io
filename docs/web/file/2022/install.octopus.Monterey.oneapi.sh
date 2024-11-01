#by cndaqiang

#oneapi
. /opt/intel/oneapi/compiler/2022.2.0/env/vars.sh
. /opt/intel/oneapi/mkl/2022.2.0/env/vars.sh
# mpich
MPIPATH=/opt/mpich
PATH=$MPIPATH/bin:$PATH
LD_LIBRARY_PATH=$MPIPATH/lib:$LD_LIBRARY_PATH
LIBRARY_PATH=$MPIPATH/lib:$LIBRARY_PATH
C_INCLUDE_PATH=$MPIPATH/include:$C_INCLUDE_PATH


ROOT=$HOME/git/oneapi

mkdir -p $ROOT/source
#libxc
cd $ROOT/source
wget https://cndaqiang.github.io/packages//mirrors/libxc/libxc-4.3.4.tar.gz
tar xzvf libxc-4.3.4.tar.gz 
cd libxc-4.3.4
./configure --prefix=$ROOT/libxc-4.3.4  CC=icc CXX=icpc FC=ifort FCCPP=fpp CPP=cpp
make -j20
make install


#gs
cd $ROOT/source
wget https://cndaqiang.github.io/packages//mirrors/gs/gsl-1.14.tar.gz
tar xzvf gsl-1.14.tar.gz
cd gsl-1.14
mkdir build; cd build
../configure CC=icc --prefix=$ROOT/gsl-1.14
make -j10
make install

cd $ROOT/source
wget https://cndaqiang.github.io/packages//mirrors/fftw/fftw-3.3.3.tar.gz
tar xzvf fftw-3.3.3.tar.gz
cd fftw-3.3.3/
./configure --prefix=$ROOT/fftw-3.3.3 --enable-mpi CC=mpicc CXX=mpicxx FC=mpifort FCCPP=fpp

#octopus
cd $ROOT/source
wget https://cndaqiang.github.io/packages//mirrors/octopus/octopus-10.4.tar.gz
tar xzvf octopus-10.4.tar.gz
cd octopus-10.4



#清除octopus的代码异常
for tag in include define undef ifdef if endif else elif
do
    for file in $(egrep -rn "^[ ]+#$tag" src/ | awk -F: '{ print $1 }' | sort | uniq )
    do
    #echo sed -i "" "s/^[\ ]*#${tag}/#${tag}/g" $file
    sed -i "" "s/^[\ ]*#${tag}/#${tag}/g" $file
    done
done

MKL_DIR=$(echo $MKLROOT | awk -F: '{ print $1 }')

./configure CC=mpicc CXX=mpicxx FC=mpifort FCCPP=fpp \
    --prefix=$ROOT/octopus-10.4 \
    --with-libxc-prefix=$ROOT/libxc-4.3.4    \
    --with-fftw-prefix=$ROOT/fftw-3.3.3  \
    --with-blas="-L$MKL_DIR/lib/ -lmkl_blacs_mpich_lp64 -lmkl_scalapack_lp64 " \
    --with-gsl-prefix=$ROOT/gsl-1.14  \
    --enable-mpi

make -j20
make install