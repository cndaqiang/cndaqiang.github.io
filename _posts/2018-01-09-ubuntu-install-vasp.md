---
layout: post
title:  "Ubuntu VASP安装和运行 "
date:   2018-01-09 21:15:00 +0800
categories: DFT
tags: vasp
author: cndaqiang
mathjax: true
---
* content
{:toc}

# 建议看此文[Intel Parallel Studio XE 编译VASP](/2018/01/15/intel-mpi-vasp/)更具有普遍性




<br><br><br><br>
这两天安装vasp可要被折腾死了，虽然组里服务器上有vasp，可是自己还没有进行计算的经验，在服务器上乱提交作业，被发现就不好了，还是在自己服务器上学习更放心大胆一些。
<br>这几天尝试了,好多个版本的编译器，vasp编译过4.6,5.3都失败了，最后发现这个帖子[[VASP] 教你从头编译vasp-5.4.1](http://bbs.keinsci.com/forum.php?mod=viewthread&tid=4267&highlight=vasp)提供的2011版的icc,ifort,icpc编译vasp5.4没有问题,成功在台式机,云服务器，windows10上bash编译完成.









# 需要的软件
[编译器,fftw,openmpi](https://pan.baidu.com/s/1bqZFjkz),也可以去相应网站下载<br>
[makefile.include](/web/file/2018/makefile.include),从`vasp.5.4.1/arch`中获得并修改<br>
vasp.5.4,vasp.5.lib源码,百度可搜,请购买正版
# 总述
安装VASP主要需要这几个部分
- 编译环境,编译器<br>
这里使用linux+ifc(intel icc ifort)
<br>intel的parallel_studio_xe编译器包含MKL,MPI,
<br>网上和intel网站有parallel_studio_xe_2013和2015的安装成功记录，我没有成功，最后使用2011版的l_ccompxe_2011 l_fcompxe_2011 
<br>使用其他编译器也可以，要选择合适的makefile文件并修改正确
- 并行计算mpi
<br>intel编译器包含mpi，也可使用openmpi<br>
最后使用openmpi<br>
- 数学库BLACS,LAPACK
<br>有Intel的MKL,GotoBlas,ATLAS
<br>这次使用Intel的MKL<br>
- FFT
<br>vasp自带fft，也使用额外的fftw
<br>最后使用fftw

## 理解
编译无需root操作，个人将所有软件安装在自己目录里也可以<br>
编译vasp时，在makefile文件中设置编译器,MKL,MPI,FFT，
<br>因此，可以在服务器上安装多个版本的编译器,MKL,MPI,FFT，选则合适的makefile，修改makefile中相应的目录即可<br>
仅编译安装vasp并不需要很大的计算量，对材料的计算可能需要很大<br>
在实验室台式机上编译intel_2011和vasp5.4正常，尝试在1核1G内存腾讯云服务器编译失败,查看后台内存占用接近峰值时编译失败，增加虚拟内存后，编译正常进行，如图。所以我之前用parallel_studio_xe_2013/2018和vasp5.4/5.3编译失败的原因很大可能是服务器内存不够了<br>
![](/uploads/2018/01/vaspinstall.png)

# 安装
## 安装环境
实验室的台式机
<br>ubuntu server 16.04.3 
<br>Intel(R) Core(TM) i5-3450 CPU @ 3.10GHz
<br> 6G内存
<br>这次是安装在单用户目录下面，而且过程都是编译，感觉与linux的哪个发行版关系不大
<br>另外，1核1G内存2G交换分区腾讯云主机也成功安装
<br>windows10上的bash 8G内存 Intel(R) Core(TM) i7-7500U CPU @ 2.70GHz，也安装完成
<br>windows10上的bash安装注意
- 建议关闭windows defender后安装
- intel编译器安装过程较卡，耐心等待
- 最后编译vasp大约用时30分钟

## 安装依赖
直接安装`l_ccompxe_`时提示缺少依赖,安装下面包后解决(下面的包应该是安装多了)
```
sudo apt update
sudo apt-get install gfortran
sudo apt-get install build-essential
sudo apt-get install libstdc++5
sudo apt-get install lib32stdc++6
sudo apt-get install libc6-dev-i386
sudo apt-get install g++-multilib
```
**另外，windows10的bash还需安装**
```
sudo apt install flex
sudo apt install texinfo
```

## intel编译器
### 安装
解压安装icc
```
tar xzvf l_ccompxe_2011.6.233
cd l_ccompxe_2011.6.233/
./install
```
安装时，选择单用户安装(root用户安装也可以，会安装到`/opt/intel`)，使用lic文件激活,其他保持默认<br>
文件最终安装在`用户目录/intel`中，如`/home/cndaqiang/intel`，以后编译设置里面的`/home/cndaqiang/intel`替换为你对应的目录即可
<br><br>同理安装`l_fcompxe_2011.6.233`

### 添加环境变量
是为了输入`ifort`等命令直接运行，不添加环境变量则要在makefile里指明编译器的位置如`FCC=/目录.../ifort`<br>
编辑`~/.bashrc`,添加以下内容，注意替换相关目录
```
source /home/cndaqiang/intel/composerxe/bin/compilervars.sh intel64
export PATH=/home/cndaqiang/intel/composerxe/bin:$PATH
export LD_LIBRARY_PATH=/home/cndaqiang/intel/composerxe/mkl/lib/intel64:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/home/cndaqiang/intel/lib/intel64:$LD_LIBRARY_PATH
```
编译生效
```
source ~/.bashrc 
```
环境变量配置成功，直接输入`which icc ifort icpc`会返回命令所在路径
## openmpi安装
### 编译安装
使用openmpi-1.6.5,可去其网站下载
```
tar xzvf openmpi-1.6.5.tar.gz
cd openmpi-1.6.5
```
生成makefile文件
```
./configure --prefix=安装目录 CC=icc CXX=icpc F77=ifort FC=ifort
```
- 安装目录为编译后openmpi安装到的目录
<br>我设置为`/home/cndaqiang/soft/openmpi`之后注意替换
- `CC=icc CXX=icpc F77=ifort FC=ifort`为使用哪种编译器编译openmpi

没有报错后，编译安装
```
make -j4
#-j4为使用4核安装，我的电脑只有4核，尽量使用多的核编译会快
make install
```
### 添加环境变量

编辑`~/.bashrc`,添加以下内容，注意替换相关目录
```
export PATH=/home/cndaqiang/soft/openmpi/bin:$PATH
export LD_LIBRARY_PATH=/home/cndaqiang/soft/openmpi/lib:$LD_LIBRARY_PATH
export MANPATH=/home/cndaqiang/soft/openmpi/share/man:$MANPATH
```
编译生效
```
source ~/.bashrc 
```
环境变量配置成功，直接输入`which mpif90`会返回命令所在路径
## fftw安装
### 编译安装
使用fftw-3.3.4，可去其网站下载<br>
编译同openmpi
```
tar xzvf fftw-3.3.4.tar.gz 
cd  fftw-3.3.4
./configure --prefix=安装目录 --enable-mpi
make -j4
make install
```
- 安装目录我设置为`/home/cndaqiang/soft/fftw`之后注意替换
- >帖子中说一定要加`--enable-mpi`否则在安装好的lib文件夹内无法生成此次编译VASP所必须的`libfftw3_mpi.a`文件

编辑`~/.bashrc`,添加以下内容，注意替换相关目录
```
export PATH=/home/cndaqiang/soft/fftw/bin:$PATH
export LD_LIBRARY_PATH=/home/cndaqiang/soft/fftw/lib:$LD_LIBRARY_PATH
```
编译生效
```
source ~/.bashrc 
```
<br>
准备工作做完了，开始编译vasp

## 编译VASP
**与之前vasp版本编译的不同，不需进入vasp.5.lib进行编译**
```
cp makefile.include vasp.5.4.1
cd vasp.5.4.1
vi makefile.include
```
修改makefile.include

- 28行设置MKL路径`MKLROOT    =/home/cndaqiang/intel/mkl`
- 33行只使用openmpi `BLACS      =-L$(MKL_PATH) -lmkl_blacs_openmpi_lp64`
- 38行设置fftw `OBJECTS    = fftmpiw.o fftmpi_map.o fftw3d.o fft3dlib.o /home/cndaqiang/soft/fftw/lib/libfftw3_mpi.a`
- 39行设置fftw `INCS       =-I/home/cndaqiang/soft/fftw/include`

开始编译,不建议加`-jn`命令，容易出错
```
make all
```
大概30分钟左右会完成编译，在bin文件夹中会生成三个可执行文件
```
cndaqiang@ubuntu:~/VASP-5.4/vasp.5.4.1$ ls ./bin
vasp_gam  vasp_ncl  vasp_std
```
- vasp_gam  /gamma版本的vasp
- vasp_std  /标准版本的vasp
- vasp_ncl  /非线性版本的vasp

`vasp_gam  vasp_ncl  vasp_std`三个文件夹里面分别有一个可执行程序vasp
## 添加环境变量
把VASP添加到PATH后，可以通过直接输入vasp运行<br>
例如我,新建了一个文件夹，里面创建三个软连接，分别指向三个版本的vasp，再将该目录设置为PATH目录，通过`vasp_gam`,`vasp_ncl`,`vasp_std`分别运行三个版本的vasp
```
mkdir ~/soft/vasp
cd ~/soft/vasp
ln -s /home/ubuntu/VAPS_install/vasp5.4/vasp.5.4.1/build/gam/vasp vasp_gam
ln -s /home/ubuntu/VAPS_install/vasp5.4/vasp.5.4.1/build/ncl/vasp vasp_ncl
ln -s /home/ubuntu/VAPS_install/vasp5.4/vasp.5.4.1/build/std/vasp vasp_std
```
在`~/.bashrc`中添加
```
export PATH=/home/ubuntu/soft/vasp:$PATH
```
编译`~/.bashrc`
```
source ~/.bashrc
```
或使用完整路径，如`/home/ubuntu/VAPS_install/vasp5.4/vasp.5.4.1/build/gam/vasp`也可以<br>

# 简单运行vasp
>生成输入文件->vasp->输出文件

## 运行
新建一个文件夹，里面放入输入文件(第一次可先搜索vasp实例得到下面的文件，之后再慢慢看每个文件的具体内容和编写方法),命名如下
```
INCAR  KPOINTS  POSCAR  POTCAR
```
直接运行(这里的`vasp_std`是我之前添加的快捷命令,可以用`/home/ubuntu/VAPS_install/vasp5.4/vasp.5.4.1/build/std/vasp`替换)
```
vasp_std
```
生成输出文件,如
```
ubuntu@VM-10-194-ubuntu:~/work/1_1_O_atom$ ls
CHG     CONTCAR  EIGENVAL  KPOINTS  OUTCAR  POSCAR  REPORT       WAVECAR
CHGCAR  DOSCAR   INCAR     OSZICAR  PCDAT   POTCAR  vasprun.xml  XDATCAR
```
可以将自己的运算结果和[Materials Project](https://www.materialsproject.org)进行对比
## 输入输出文件
输入输出文件的编写规则和vasp使用的相关教程资源就非常多了，不在这里整理了

## 后记
参考的教程太多了，恕不把每个链接放上了，仅再此感谢小木虫csdn计算化学公社等优秀的网友<br>
以后有时间，再整理一次makefile里面的参数对应哪些，串行，并行，其他mkl库，fftw等，先这样用着吧，先去学习vasp了









------
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
