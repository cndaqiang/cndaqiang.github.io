---
layout: post
title:  "Intel MPI编译yambo"
date:   2022-10-23 17:25:00 +0800
categories: DFT
tags: vasp centos Intel
author: cndaqiang
mathjax: true
---
* content
{:toc}

编译yambo





# 下载源代码
[yambo](https://github.com/yambo-code/yambo/wiki/Releases-(tar.gz-format))<br>
本次使用[yambo-5.1.1](https://github.com/yambo-code/yambo/archive/refs/tags/5.1.1.tar.gz)[2022/07/25]


# 备注
- 从todo和mk中都看到了`./sbin/compilation/helper.sh`是用于生成Makefile的,**我们如果因为各种原因需要修改Makefile可以改这里**
- 编译的日志在`$(compdir)/log/compile_$@.log`,**yambo编译过程不显示日志,找不到报错原因,看这个文件，例如`log/compile_qe_pseudo.log`可以看到编译失败的原因**
- 编译次数多了后,**建议重新解压**,`make clean_all`没用.

# 编译环境
以怀柔服务器为例
```
module unload openmpi3/3.1.4
module load parallel_studio/2020.2.254
module load intelmpi/2020.2.254
module load gnu8/8.3.0
```

# 配置编译参数

## configure和编译
```
[HUAIROU cndaqiang@login01 yambo-5.1.1]$./configure  FC=ifort CC=icc MPIFC=mpiifort MPICC=mpiicc
....
# - COMPILERS -
#
# FC kind = intel ifort version 19.1.2.254
# MPI kind= Intel(R) MPI Library 2019 Update 8 for Linux* OS
#
# [ CPP ] icc -E -ansi -D_HDF5_LIB -D_HDF5_IO -D_MPI -D_FFTW -D_FFTW_OMP       -D_TIMING     -D_P2Y_QEXSD_HDF5
# [ FPP ] fpp -free -P -D_HDF5_LIB -D_HDF5_IO -D_MPI -D_FFTW -D_FFTW_OMP       -D_TIMING
# [ CC  ] mpiicc -O2 -std=gnu99 -no-multibyte-chars -D_C_US -D_FORTRAN_US
# [ FC  ] mpiifort -assume bscc -O3 -g -ip
# [ FCUF] -assume bscc -O0 -g
# [ F77 ] mpiifort -assume bscc -O3 -g -ip
# [ F77U] -assume bscc -O0 -g
# [Cmain] -nofor_main
#
# You can modify compilers and flags by editing the file "config/setup"
#
```
**编译全部**
```
[HUAIROU cndaqiang@login01 yambo-5.1.1]$make core -j 60
```
如果没有问题就编译通过了
```
[HUAIROU cndaqiang@login01 yambo-5.1.1]$ls bin/
a2y  c2y  p2y  yambo  ypp
```

**但是建议分步编译**
```
make iotk
make qe_pseudo
#上面两个能正常结束后,再
make core 
```


# 报错解决
## `Error in opening the compiled module file.  Check INCLUDE paths.`
```
	[lib/qe_pseudo] qe_pseudo (checking work to be done)
make[1]: *** [atom.o] 错误 1
atom.f90(14): error #7002: Error in opening the compiled module file.  Check INCLUDE paths.   [RADIAL_GRIDS]
```
通过`log/compile_qe_pseudo.log`发现,是编译依赖关系没弄好
```
atom.f90(14): error #7002: Error in opening the compiled module file.  Check INCLUDE paths.   [RADIAL_GRIDS]
  USE radial_grids, ONLY : radial_grid_type
------^
atom.f90(19): error #6406: Conflicting attributes or multiple declaration of name.   [RADIAL_GRID_TYPE]
```
通过`rm log/compile_qe_pseudo.log; make qe_pseudo; cat log/compile_qe_pseudo.log`一套组合拳,找到所有的依赖关系,把下面的内容添加到`config/mk/local/makefile`,再make就解决了
```
atom.o:radial_grids.o
radial_grids.o:kind.o
radial_grids.o:constants.o
becmod.o:qe_auxdata.o recvec.o
qe_auxdata.o:parameters.o
s_psi.o:spin_orb.o uspp.o
uspp.o:invmat.o
init_us_1.o:us_module.o
#upf.o需要iotk，先make iotk
upf.o:read_upf_v1.o read_upf_v2.o
read_pseudo.o:read_uspp.o
```


## 备注
### Makefile 引用的
- `config/mk/global/actions/compile_internal_libraries.mk` 包含了qe_pseudo等库的的编译方式,如
```
qe_pseudo:
        @+LIBS="qe_pseudo"; BASE="lib" ; ADF="$(STAMP_DBLE)"; LAB=""; $(todo_lib); $(mk_lib)
```

- 上面的`$(todo_lib)` 在`config/mk/global/functions/todo.mk`中定义
```
define todo_lib
 for lib in $$LIBS; do \
  $(ECHO) "\t[$$BASE/$$lib] $$lib (checking work to be done)"; \
  ./sbin/compilation/helper.sh -n -t lib$$LAB$$lib -d $$BASE/$$lib -N $(MAKEFLAGS) -m $(fast) -g $@  -- $(xcpp) $$ADF;\
 done
endef
```

- 上面的`$(mk_lib)` 在`config/mk/global/functions/mk_lib.mk`中定义
```
define mk_lib
 for lib in $$LIBS; do \
  if test ! -f $(compdir)/config/stamps_and_lists/lib$$LAB$$lib.a.stamp; then \
   if test ! -d "$$BASE/$$lib" ; then mkdir -p "$$BASE/$$lib" ; fi ; \
   ./sbin/compilation/helper.sh -d $$BASE/$$lib -t lib$$LAB$$lib.a -o .objects -m l -g $@ -- "$(xcpp) $$ADF" ; \
   cd $$BASE/$$lib ; $(MAKE) $(MAKEFLAGS) VPATH=$(srcdir)/$$BASE/$$lib lib || { grep Error $(compdir)/log/compile_$@.log ; \
   touch $(compdir)/config/stamps_and_lists/compilation_stop_$@.stamp;  exit "$$?"; } ; cd $(compdir); \
  fi;\
 done
endef
```

- 从todo和mk中都看到了`./sbin/compilation/helper.sh`是用于生成Makefile的
- 编译的日志在`$(compdir)/log/compile_$@.log`

```
(python37) [HUAIROU chendq@login01 yambo-5.1.1]$grep include Makefile
 include config/mk/global/defs.mk
 include config/mk/defs.mk
 include config/mk/global/no_configure_help.mk
include config/mk/global/targets.mk
include config/mk/global/libraries.mk
include config/mk/global/actions/download_external_libraries.mk
include config/mk/global/actions/compile_external_libraries.mk
include config/mk/global/actions/compile_internal_libraries.mk
include config/mk/global/actions/compile_yambo_libraries.mk
include config/mk/global/actions/compile_yambo.mk
include config/mk/global/actions/compile_interfaces.mk
include config/mk/global/actions/compile_ypp.mk
include config/mk/global/actions/clean.mk
include config/mk/global/functions/global_check.mk
include config/mk/global/functions/get_libraries.mk
include config/mk/global/actions/dependencies.mk
include config/mk/global/functions/todo.mk
include config/mk/global/functions/help.mk
include config/mk/global/functions/mk_lib.mk
include config/mk/global/functions/mk_external_lib.mk
include config/mk/global/functions/mk_exe.mk
include config/mk/global/functions/cleaning.mk
```




------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
