# arch.mk for BerkeleyGW codes
#
# suitable for Edison at NERSC
#
# JRD
# 2016, NERSC
#
# Run the following command before compiling:
# module load cray-hdf5-parallel

# Precompiler options

COMPFLAG  = -DINTEL
PARAFLAG  = -DMPI -DOMP
MATHFLAG  = -DUSESCALAPACK -DUNPACKED -DUSEFFTW3
# -DHDF5
# Only uncomment DEBUGFLAG if you need to develop/debug BerkeleyGW.
# The output will be much more verbose, and the code will slow down by ~20%.
#DEBUGFLAG = -DDEBUG

FCPP    = /usr/bin/cpp -ansi
F90free = mpiifort -free -qopenmp
LINK    = mpiifort -qopenmp
FOPTS   = -O3  -g
FNOOPTS = $(FOPTS)
MOD_OPT = -module 
INCFLAG = -I

C_PARAFLAG  = -DPARA -DMPICH_IGNORE_CXX_SEEK
CC_COMP = mpiicpc
C_COMP  = mpiicc
C_LINK  = mpiicc
C_OPTS  = -O3  -qopenmp
C_DEBUGFLAG =

REMOVE  = /bin/rm -f

# Math Libraries
#
#FFTWPATH     = 
FFTWLIB      = ${MKLROOT}/lib/intel64/libmkl_scalapack_lp64.a -Wl,--start-group ${MKLROOT}/lib/intel64/libmkl_intel_lp64.a ${MKLROOT}/lib/intel64/libmkl_core.a \
               ${MKLROOT}/lib/intel64/libmkl_intel_thread.a ${MKLROOT}/lib/intel64/libmkl_blacs_intelmpi_lp64.a -Wl,--end-group -lpthread -lm -ldl -z muldefs
FFTWINCLUDE  = $(MKLROOT)/include/fftw/

#HDF5_LDIR    =  $(HDF5_DIR)/lib
#HDF5LIB      =  $(HDF5_LDIR)/libhdf5hl_fortran.a \
#                $(HDF5_LDIR)/libhdf5_hl.a \
#                $(HDF5_LDIR)/libhdf5_fortran.a \
#                $(HDF5_LDIR)/libhdf5.a -lz -ldl
#HDF5INCLUDE  = #$(HDF5_DIR)/include

PERFORMANCE  = 

LAPACKLIB = ${FFTWLIB}

TESTSCRIPT = sbatch edison.scr
