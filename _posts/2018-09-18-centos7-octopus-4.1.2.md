---
layout: post
title:  "centos7 gnu 编译octopus-4.1.2遇到问题和解决方案 "
date:   2018-09-18 21:12:00 +0800
categories: DFT
tags: gnu octopus
author: cndaqiang
mathjax: true
---
* content
{:toc}

Error: Invalid character in name at (1)<br>
/usr/include/stdc-predef.h:2.3:<br>
	Included at c_pointer.F90:1:<br>
	   This file is part of the GNU C Library.<br>
   1<br>







   
centos7编译octopus遇到的问题<br>
与在centos6上，使用相同版本的gcc-4.8.4,libxc-2.0.3,gsl-1.14,openmpi-1.10.3,fftw-3.3.3,sclapack进行编译<br>
octopus-4.1.2的configure命令没有报错，make时却报下面的错误
```
/* Copyright (C) 1991-2012 Free Software Foundation, Inc.
 1
Error: Invalid character in name at (1)
/usr/include/stdc-predef.h:2.3:
	Included at c_pointer.F90:1:

   This file is part of the GNU C Library.
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:4.3:
	Included at c_pointer.F90:1:

   The GNU C Library is free software; you can redistribute it and/or
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:4.39:
	Included at c_pointer.F90:1:

   The GNU C Library is free software; you can redistribute it and/or
									   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:5.3:
	Included at c_pointer.F90:1:

   modify it under the terms of the GNU Lesser General Public
```

<br><br><br><br>
## 有管理员权限时
根据[Yambo Community Forum](http://www.yambo-code.org/forum/viewtopic.php?f=1&t=842)的建议，应该是libxc的问题，无法识别`/usr/include/stdc-predef.h`中的注释部分
<br><br>备份`stdc-predef.h`后，删除其中的注释部分，也就是`/*注释。。。*/`里面的内容，再执行编译就可以了


## 无管理员权限时(2019-05-06更新)
在RedHat上编译libxc-2.0.0遇到，同样错误,也是`/usr/include/stdc-predef.h`的注释造成<br>
在make后的目录中，搜索注释中的语句`IEC`，发现`/usr/include/stdc-predef.h`已经被引入`src/libxc.f90`<br>
只要删除`src/libxc.f90`中的`/* */`部分继续make就可以编译了<br>

<br><br>发现错误和结局的过程如下
```
   The GNU C Library is distributed in the hope that it will be useful,
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:10.3:
    Included at ./libxc_master.F90:1:

   but WITHOUT ANY WARRANTY; without even the implied warranty of
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:10.29:
    Included at ./libxc_master.F90:1:

   but WITHOUT ANY WARRANTY; without even the implied warranty of
                             1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:11.3:
    Included at ./libxc_master.F90:1:

   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:12.3:
    Included at ./libxc_master.F90:1:

   Lesser General Public License for more details.
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:14.3:
    Included at ./libxc_master.F90:1:

   You should have received a copy of the GNU Lesser General Public
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:15.3:
    Included at ./libxc_master.F90:1:

   License along with the GNU C Library; if not, see
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:15.41:
    Included at ./libxc_master.F90:1:

   License along with the GNU C Library; if not, see
                                         1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:16.4:
    Included at ./libxc_master.F90:1:

   <http://www.gnu.org/licenses/>.  */
    1
Error: Invalid character in name at (1)
/usr/include/stdc-predef.h:21.1:
    Included at ./libxc_master.F90:1:

/* This header is separate from features.h so that the compiler can
 1
Error: Invalid character in name at (1)
/usr/include/stdc-predef.h:22.3:
    Included at ./libxc_master.F90:1:

   include it implicitly at the start of every compilation.  It must
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:23.3:
    Included at ./libxc_master.F90:1:

   not itself include <features.h> or any other header that includes
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:24.4:
    Included at ./libxc_master.F90:1:

   <features.h> because the implicit include comes before any feature
    1
Error: Invalid character in name at (1)
/usr/include/stdc-predef.h:25.3:
    Included at ./libxc_master.F90:1:

   test macros that may be defined in a source file before it first
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:26.3:
    Included at ./libxc_master.F90:1:

   explicitly includes a system header.  GCC knows the name of this
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:27.3:
    Included at ./libxc_master.F90:1:

   header in order to preinclude it.  */
   1
Error: Unclassifiable statement at (1)
/usr/include/stdc-predef.h:29.1:
    Included at ./libxc_master.F90:1:

/* We do support the IEC 559 math functionality, real and complex.  */
 1
Error: Invalid character in name at (1)
Fatal Error: Error count reached limit of 25.
make[3]: *** [libxc_la-libxc.lo] Error 1
make[3]: Leaving directory `/public/home/chendq/soft/gcc-openmpi/source/libxc-2.0.0/src'
make[2]: *** [all] Error 2
make[2]: Leaving directory `/public/home/chendq/soft/gcc-openmpi/source/libxc-2.0.0/src'
make[1]: *** [all-recursive] Error 1
make[1]: Leaving directory `/public/home/chendq/soft/gcc-openmpi/source/libxc-2.0.0'
make: *** [all] Error 2
```
在make后的目录中，搜索注释中的语句`IEC`，发现`/usr/include/stdc-predef.h`已经被引入`src/libxc.f90`<br>
```
[chendq@login3 libxc-2.0.0]$ fyou IEC
src/libxc.f90:33:/* We do support the IEC 559 math functionality, real and complex.  */
src/libxc.f90:37:/* wchar_t uses ISO/IEC 10646 (2nd ed., published 2011-03-15) /
```
只要删除`src/libxc.f90`中的`/* */`部分就可以编译了<br>

### [非管理员]对于octopus-4.1-2同样的错误
要改的信息更多，可以通过修改Makefile解决
```
cd /public/home/cndaqiang/soft/gcc-MVAPICH/source/octopus-4.1.2/src/basic
vi Makefile
```
做出如下更改
```
719 ########Add by cndaqiang
720 ####### 2019-05-07
721 .F90.o:
722         /lib/cpp -C -ansi  $(AM_CPPFLAGS) -I. $< > $*_oct.f90
723         $(top_srcdir)/build/preprocess.pl $*_oct.f90 \
724           "" "yes" "yes"
725         sed -i '5,41d' $*_oct.f90
726         mpif90 -O3      -I /public/home/chendq/soft/gcc-openmpi/libxc-2.0.0/include $(AM_FCFLAGS) -c  -o $@ $*_oct.    f90
727 #       @rm -f $*_oct.f90
728 

729 ########END cndaqiang
730 # This rule is basically to create a _oct.f90 file by hand for
731 # debugging purposes. It is identical to the first part of
732 # the .F90.o rule.
733 ##########Add by cndaqiang
734 ######### 2019-05-07
735 .F90_oct.f90:
736         /lib/cpp -C -ansi  $(AM_CPPFLAGS) -I. $< > $*_oct.f90
737         $(top_srcdir)/build/preprocess.pl $*_oct.f90 \
738           "" "yes" "yes"
739         sed -i '5,41d' $*_oct.f90
740 
741 ########END cndaqiang
```
针对下面Makefile做同样修改
```
vi src/math/Makefile
vi src/species/Makefile
vi src/ions/Makefile
vi src/grid/Makefile
vi src/poisson/Makefile
vi src/states/Makefile
vi src/xc/Makefile
vi src/hamiltonian/Makefile
vi src/system/Makefile
vi src/scf/Makefile
vi src/td/Makefile
vi src/opt_control/Makefile
vi src/td/Makefile
vi src/sternheimer/Makefile
vi src/main/Makefile
```
或者使用下面的脚本
```

#!/bin/bash
for i in basic  math   species   ions   grid   poisson   states   xc   hamiltonian   system   scf   td   opt_control   td   sternheimer   main
do
Makefile=src/${i}/Makefile
#修改.F90.o
hang=$(grep -n "^.F90.o:"  $Makefile | awk '{printf "%d\n",$1}' )
hang=$(echo -e "$hang+4"|bc)
sed -i "${hang}i CNQsed -i '5,41d' \$\*_oct.f90" $Makefile
sed -i "${hang}s/CNQ/\t/g" $Makefile
hang=$(echo -e "$hang-4"|bc)
sed -i "${hang}i ##### Add by CNQ " $Makefile
hang=$(echo -e "$hang+8"|bc)
sed -i "${hang}i ##### END CNQ " $Makefile
#修改.F90_oct.f90
hang=$(grep -n .F90_oct.f90 $Makefile | awk '{printf "%d\n",$1}' )
hang=$(echo -e "$hang+4"|bc)
sed -i "${hang}i CNQsed -i '5,41d' \$\*_oct.f90" $Makefile
sed -i "${hang}s/CNQ/\t/g" $Makefile
hang=$(echo -e "$hang-4"|bc)
sed -i "${hang}i ##### Add by CNQ " $Makefile
hang=$(echo -e "$hang+6"|bc)
sed -i "${hang}i ##### END CNQ " $Makefile

done 
```







------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
