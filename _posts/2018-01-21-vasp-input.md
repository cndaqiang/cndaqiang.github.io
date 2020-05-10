---
layout: post
title:  "VASP输入文件总结"
date:   2018-01-21 17:29:00 +0800
categories: DFT
tags: vasp
author: cndaqiang
mathjax: true
---
* content
{:toc}
整理备查
vasp的[manual](http://cms.mpi.univie.ac.at/vasp/vasp/vasp.html)值得一读<br>
看资料遇到陌生的参数,查manual就好了<br>
INCAR输入参数推荐苏长荣老师的vasp安装和使用说明(后面有索引可以直接查)和[官方manual](http://cms.mpi.univie.ac.at/vasp/vasp/vasp.html)



## 说明
输入文件POSCAR，KPOINT，POTCAR，INCAR等,用`#`注释
## POTCAR 赝势
### 产生
来源VASP官网提供<br>
直接拼接赝库,顺序同POSCAR
```
cat POTCAR_AL POTCAR_N > POTCAR
```
### 说明
VASP赝势文件夹中包含两个压缩文件：potpaw_LDA和potpaw_PBE<br>
potpaw_LDA ==> PAW, LDA<br>
potpaw_PBE ==> PAW, GGA, PBE<br>

- 赝势的种类要一致
- 赝势使用的泛函要与INCAR中选择的泛函一致（PBE的泛函要选择 PBE的赝势）
<br>即:POTCAR中的LEXCH与INCAR中GGA的设置对应
<br>LEXCH=CA(LDA赝势) GGA不设置 VOSKOWN不设置
<br>LEXCH=91(PW91赝势) GGA=91 VOSKOWN=1
<br>LEXCH=PE GGA=PE VOSKOWN不设置

ENMAX截断能

## KPOINTS K点
**是KPOINTS,不是KPOINT**
- 布里渊区K点采样方式
- K点越多计算消耗的内存越大，在个人笔记本上计算时一定要先用小点的
K点数目试算一下，内存占用大容易死机

### 产生
#### 自动
```
Automaticmesh  首行注释
0              0表示自动产生K点
M/G            M表示采用Monkhorst-Pack方法生成K点坐标，G表示一定会取到Γ点
K1 K2 K3       K-mesh取K1xK2xK3网格，
0 0 0            原点平移大小
```
bbs.推荐用G
- K1 K2 K3的取值,使得K1xa=K2xb=K3xc，a,b,c为POSCAR中基失长度
![](/uploads/2018/01/k1k2k3mesh.jpg)
![](/uploads/2018/01/k1k2k3mesh2.jpg)
- **二维材料(c方向上只有一层原子)结构优化和自恰计算时K点可选取NxNx1**

#### Line-mode(一般仅在计算能带结构时使用)：
例:
```
k-pointsforMgO(100)(title) 注释
21             下面两个高对称K点之前插入的K点数目
Line-mode      L表示Line-mode
Rec           字母R打头表示为倒易空间坐标，否则为实空间的坐标)
0.0 0.0 0.0 !Γ   各高对称K点的以及权重
0.5 0.0 0.0 !Z
0.5 0.0 0.0 !Z
0.5 -0.5 0.0 !K
0.5 -0.5 0.0 !K
0.0 -0.5 0.0 !L
0.0 -0.5 0.0 !L
0.0 0.0 0.0 !Γ
```
高对称K点的选取:<br>
可以参考[High-throughput electronic band structure calculations: challenges and tools](https://arxiv.org/abs/1004.2974)
<br>[小木虫-【原创】k点设置的学习心得](http://muchong.com/bbs/viewthread.php?tid=2337146&fpage=1)
<br>如六角晶格的高对称点
![](/uploads/2018/01/hex.png)
<br>对应的KPOINTS文件
```
Line-mode        #注释
60               #每两个高对称点间产生的K点数
L                #使用Line-mode
Rec              #使用倒格点坐标
0 0 0            #G点/Γ点
-1/3 2/3 0       #M点
-1/3 2/3 0       #M点
1/2 0 0          #K点
1/2 0 0          #K点
0 0 0            #G点/Γ点
```
**LH师兄.自己的结构可能因为角度等不同和参考文献中的K点有些不同，可以使用POSCAR->VESTA->cif后导入MS，使用MS的Tools/Brillouin Zone Path功能识别高对称K点**，然后对比上面参考文献中的方法，手动添加K点坐标看是否符合自己的结构，如图CoCl2识别的加上我添加的K(0.333 0.333 0)<br>
![](/uploads/2018/01/mskpoints.png)

**说明**<br>
- 只要原胞时一样的，超胞如何构建，高对称点坐标不变


#### 手动定义各K点的坐标(一般仅在计算HSE能带结构时使用)：

### 说明
bbs.与结构优化相比,算DOS的时候,需要用到更多的K点数目,这是因为K点越多,画出来的DOS图质量越高
<br>一般来说,K * a = 45 左右之间完全可以满足要求

## POSCAR 晶格参数原子位置
### 产生
- 文献
- MS建模-cif-VESTA-POSCAR
- 数据网站

### 格式
```
AlN bulk (Title) 首行注释
1.0   缩放系数
3.11  0.00  0.00    第一个平移矢量a方向
-1.56   2.69  0.00  第二个平移矢量b方向
0.00    0.00  4.98  第三个平移矢量c方向
Al    N 原子种类
2   2   单胞内原子数目
Selective dynamics [可选]有对构型(原子坐标)进行部分优化，没有,则全优化
Direct  Direct分数坐标,Car实际坐标单位为埃
0.667   0.333     0.000    T   T   T  T表示对此方向优化，F表示对此方向不优化
0.333   0.667     0.500    T   T   T
0.667   0.333     0.382    T   T   T
0.333   0.667     0.882    F   F   F
```
## INCAR
计算的方式和内容<br>
可以内容为空保持默认,但不能没有该文件
### system=xxx
注释
### ISTART ICHARG INIWAV
- ISTARTT初始波函数产生方法
<br>默认存在WAVECAR时取1,否则0
<br>ISTART=0,根据INIWAV决定初始波函数的产生方法
<br>ISTART=1,波函数从WAVECAR文件读入
- INIWAV初始波函数产生方法
<br>尽在ISTARTT=0生效
<br>0 凝胶波函数
<br>1[默认]随机数
- ICHAGE初始电荷密度产生方法
<br>默认ISTART=0取2否则取0
<br> 0从初始波函数计算
<br> 1从CHGCAR(上次输出的电荷密度)读入
<br> +10非自洽运算,电荷密度在计算过程中保持不变
<br> 如1+10=11时，电荷密度保持CHGCAR中的值不变,适用于给定电荷密度求能级本征值(计算能带,输出EIGENVAL文件)和态密度(DOS,输出DOSCAR文件),用于能带计算

初次计算
```
ISTART=0 ICHARG=2
```
程序终止,恢复计算
```
ISTART=1 ICHARG=1
```
计算能带最后进行自洽时
```
ISTART=1 ICHARG=11
```

### EDIFF EDIFFG
EDIFF,EDIFFG 是控制收敛标准的两个参数。
- EDIFF 电子自洽过程(单个离子步内),能量的差别取值为1E-4或者1E-5即可
- EDIFFG 结构优化的过程
<br>力作为收敛标准,此时EDIFFG为负值。一般来说取值在-0.01到-0.05之间
<br>**在做NEB过渡态计算时，使用VTST的优化算法，EDIFFG需要取负值**
<br>使用能量作为标准:此时,EDIFFG 为正值,一般为0.001-0.0001
<br>如EDIFFG=-0.03或EDIFF=0.001，常EDIFF=1E-5,EDIFFG=1E-4,EDIFFG=-0.02

### ISPIN MAGMOM
由体系决定<br>
ISPIN=0(默认) 不考虑自旋
<br>ISPIN=2 考虑自旋，电子分为α,β电子计算计算,考虑磁性
<br>当ISPIN=2时,可指定体系的初始磁矩MAGMOM
- 格式
```
MAGMOM=原子种类1*自旋磁矩 原子种类2*自旋磁矩 ...
```
- 对于简单体系来说，MAGMOM可以采用默认值；
- MAGMOM设置的时候，初始值不要求与实验值完全一致，一般取大些（1.5倍）比较好

### IBRION NFREE NSW ISIF
如果体系不收敛,或者计算不符合物理图像时,进行结构优化,调整IBRION的值
- IBRION=3：你的初始结构很差的时候；
- IBRION=2：共轭梯度算法，很可靠的一个选择，一般来说都用它。(用于结构优化)
- IBRION=1：BFGS准牛顿方法(quasi-Newton RMM-DIIS),用于小范围内稳定结构的搜索
- IBRION=5,6等参考[VASP_manual](http://cms.mpi.univie.ac.at/vasp/vasp/IBRION_5_IBRION_6.html)配合NFREE,POTIM用于计算震动频率,IBRION = 6和ISIF=3 用于计算弹性常数等<br>
NFREE 确定每个方向和离子使用多少个位移，POTIM确定步长。如果在输入文件中提供的值太大，则步长POTIM默认为0.015(VASP.5.1)

NSW 控制几何结构优化的步数
<br>默认为0不进行优化,所以结构优化时必须设置
- NSW=最大优化步数 <br>一般来说，简单的体系200步内就可以正常结束。初始结构很差，或者设置了很严格的收敛标准，可取NSW=500或者更大
- 输出文件OSZICAR可以看到最终优化的步数,若优化步数小于NSW值表明达到收敛标准,- 若优化步数大于等于NSW值,可能
<br> 1. NSW设置的偏小； 
<br> 2. 初始结构不合理，计算需要更多的离子驰豫过程； 
<br> 3. 设置的收敛标准太严格， 比如：-0.01 或者 -0.001； 
<br> 4. 结构很复杂，每一离子步中的电子步骤收敛很困难
<br> 5. 刚好收敛，可以通过OUTCAR中是否有`reached required accuracy - stopping structural energy minimisation`判断

ISIF控制离子运动中计算应力张量，IBRION=0时默认0,其他情况默认2，常用2,3
![](/uploads/2018/01/isif.JPG)

### NELM
对应NSW为结构优化步数,NELM为电子优化步数,默认为60
<br>OSZICAR中,`DAV:   `后面跟着电子计算步数,若达到60停止计算，结果基本上无不符合物理规律
<br>

优化总结:
- 电子步（SCF）: EDIFF精度 <====> NELM计算步数 
- 离子步（结构优化）：EDIFFG 精度<====> NSW计算步数

bbs.如果达到最大优化步数60
- 1.如果第一个离子步中：SCF（也就是电子步）的计算不收敛，尝试下增加NELM的值；可以疯狂些： NELM = 500或者更高；

- 2.检查下初始结构是否合理(比如与实验值差太大,原子距离过小)，如果合理，且加大NELM后依然不收敛，尝试下改变AMIX，BMIX，官网推荐的参数如下：<br>
<div align="center" ><img src="/uploads/2018/01/NELM.jpeg" /></div>
- 3.第一个离子步收敛了，后面的不收敛，能量变的极大，首先应该想到的是去检查结构，一般在结构不合理的时候会出现类似的情况；调整结构再提交任务。
<br>第一直觉是去看结构而不是想着调节参数去怎么解决这个错误！！！
<br>结构不合适,调大了也没用

### POTIM
在结构优化`IBRION=2`时,尝试移动原子的位置大小有POTIM决定<br>
默认值是0.50，可能造成过度移动最后没法矫正回来,可以设置的参数小一些如0.2<br>
初始结构不合理时,缩小POTIM的值可以降低过渡优化结果不符的可能<br>

**搭建好初始模型才是最省心的**


### ENCUT 平面波截断能
例,单位eV
```
ENCUT=250
```
侯:推荐手动输入<br>
bbs.计算多个元素进行对比时，建议统一固定一个值
bbs.如果计算时体积发生了变化，我们需要增加ENCUT的值，比如说：<br>
ENCUT = 1.3 * max(ENMAX) 即取POTCAR中ENMAX最大元素的ENMAX值。
### PREC计算精度
决定ENCUT,FFT的网格大小和ROPT的默认值
```
PREC=Low|Medium|High|Normal|Accurate
```

### GGA VOSKOWN
POTCAR中的LEXCH与INCAR中GGA的设置对应
<br>LEXCH=CA(LDA赝势) GGA不设置 VOSKOWN不设置
<br>LEXCH=91(PW91赝势) GGA=91 VOSKOWN=1
<br>LEXCH=PE GGA=PE VOSKOWN不设置
### ISMEAR SIGMA
#### ISMEAR
ISMEAR用来确定如何确定电子的部分占有数。
- ISMEAR = -5，表示采用Blochl修正的四面体方法
<br>侯(侯柱峰老师).进行任何的静态计算或态密度计算，且k点数目大于4时，取ISMEAR = -5
<br>bbs.对所有体系,更加精确的时候用-5
<br>在DOS能带计算中,使用ISMEAR=-5画出的图形更平滑
<br>**结构优化时不能使用ISMEAR=-5**,计算DOS,结构保持不变可以使用ISMEAR=-5(半导体或绝缘体的计算(不论是静态还是结构优化)K点大于4，可取ISMEAR = -5)
- ISMEAR = -4，表示采用四面体方法，但是没有Blochl修正。
- ISMEAR = -1，表示采用Fermi-Dirac smearing方法。
- ISMEAR = 0，表示采用Gaussian smearing方法。
<br>原胞较大而k点数目较少（小于4个）时，取ISMEAR = 0，SIGMA取小一些如0.05
<br>一般说来，无论是对何种体系，进行何种性质的计算，采用ISMEAR =0，并选择一个合适的SIGMA值都能得到合理的结果
<br>bbs. 对于半导体和绝缘体体系,K点小于4, 一般用0
<br>对于分子,原子体系(也就是你把分子或者原子放到一个box里面),K点只有一个Γ点取ISMEAR=0，SIGMA必须要用很小的值,如0.01
- ISMEAR = N，表示采用N阶Methfessel-Paxton smearing方法，N为正整数

<br>
[【整理自好友lpf文章】用VASP计算能量态密度（DOS）和能带](http://blog.sciencenet.cn/blog-567091-675253.html)文中提到
<br>**非自洽计算能带：金属用ISMEAR=1；半导体或绝缘体，用ISMEAR=0**
<br>**计算DOS,用ISMEAR=-5更精确**
<br><br>
bbs.使用ISMEAR=-5和较多K点可用于计算DOS,以下情况不能使用ISMEAR=-5
- 模型很大=>K点少(小于4个)
- **结构优化时不能取-5**,(优化后计算DOS可设为-5)

bbs.不能使用ISMEAR=-5时
- 增加K点(简单推荐)
- 半导体绝缘体使用ISMEAR= 0(GS方法)(半导体绝缘体绝对不能大于0)
- 金属,可以使用GS方法 ISMEAR = 0,也可以使用MP方法ISMEAR = 1, 2….N,一般来说,ISMEAR =0和 1 基本就可以了。(金属可以等于0,也可大于0)

<br>bbs.对所有的体系四面体方法（ISMEAR = -5）不适合计算能带

#### SIGMA
SIGMA的取值和ISMEAR息息相关
- ISMEAR = -5 (对于所有体系),SIGMA的值可以忽略,也可以不管(VASP会自动略过)
- SIGMA的取值和KPOINTS密切相关,Kpoints确定之后,测试SIGMA取值合理性。标准是: grep 'entropy T'  OUTCAR   得出的能量除以体系中原子的数目,小于0.001 eV 合格
<br>
- 对于分子,原子体系(也就是你把分子或者原子放到一个box里面),K点只有一个Γ点取ISMEAR=0，SIGMA必须要用很小的值,如0.01
- MP方法(ISMEAR=1..N):SIGMA取值太大,计算出来的能量可能不正确;SIGMA取值越小,计算越精确,需要的时间也就越多
<br>从经验上来说:对于金属体系,使用MP方法(ISMEAR=1..N)时,SIGMA= 0.10 足够了,官网给的参考值是0.20。

- 对于高斯展宽Gaussian Smearing (ISMEAR = 0),
<br> 对于大部分的体系都能得到理想的结果
<br>SIGMA取值比较大的时候会得到与MP方法相近的误差;但是误差多大,GS方法不可以得到,而MP方法可以。从这一点上来说,MP要比GS好些;
<br>使用GS方法的时候(ISMEAR=0),SIGMA的数值要测试下,保证`grep "entropy T" OUTCAR |tail -1`结果平均到每个原子上小于0.001 eV也就是1meV。不想测试,对于金属体系:SIGMA=0.05是一个很安全的选择
<br>对于半导体和绝缘体,SIGMA取值要小,SIGMA = 0.01 – 0.05 之间也是很安全的。


计算DOS的时候,KPOINTS设置的要大一些,ISMEAR要用-5。 <br>Kpoints因计算硬件限制不能设置的很大,数目小于3的时候,
- 对于金属,非金属体系均可以使用ISMEAR=0,SIGMA的数值需要测试一下,一般来说在0.01-0.05之间足够了。
- 金属体系还可以用ISMEAR=1..N,官网建议SIGMA为0.20,太小的SIGMA值对收敛会产生影响。使用0.01-0.10的数值都是很安全的选择。

**非DOS计算的时候,对于金属来说ISMEAR不能等于 -5**,优先使用ISMEAR= 1。非金属来说(半导体和绝缘体),不能 > 0 。对于所有的体系, ISMEAR= 0 则是一个很安全的选择,但SIGMA的数值要测试一下。

在进行能带计算时ISMEAR,SIGMA保持默认就好



### NCORE NPAR
[Learn VASP The Hard Way （Ex21）：谁偷走的我的机时？（五）](http://www.bigbrosci.cn/newsitem/277955358)看完还是不清楚，仅确定
<br>NCORE：控制多少个核同时计算；(?单个节点上的核)
<br>NPAR：如何把计算任务分配到计算资源上面计算(?使用的节点数)
<br>它们之间的关系是：NCORE= 计算使用的核数(mpirun分配?) / NPAR
<br>注意：这两个参数只能选取一个来使用
<br>bbs.NPAR实在不懂的话，直接设置NCORE=单节点的核数，单节点的核数/2，单节点的核数/4…….
<br>师兄.我们组服务器不设置NCORE等并行参数,保持默认就好

### NWRITE
决定OUTCAR中文件的信息，默认2<br>
对计算结果不影响,可选<br>
详细信息[NWRITE_tag](http://cms.mpi.univie.ac.at/vasp/vasp/NWRITE_tag.html)

### PREC
截图自苏长荣老师的VASP安装和使用说明
![](/uploads/2018/01/prec.JPG)

### LCHARG 是否输出CHG,CHGCAR
默认 LCHARG= .TRUE. 输出<br>
自洽计算LCHARG= .TRUE.输出CHG
<br>下一步非自洽计算时设置ICHAGR=11使用CHG计算DOS
### LWAVE 是否输出WAVECAR
默认 LWAVE= .TRUE. 输出<br>
(WAVECAR占空间比较大时,可以选中不输出)<br>
读取上一步计算的WAVECAR可以减少该步(自洽/非自洽)的计算时间,所以推荐输出<br>
使用ISTART=1使用上一步计算的WAVECAR(默认就是读取WAVECAR)
### LORIBT 是否输出投影波函数到PROCAR PROOUT
- LORBIT = 10 
<br>把态密度分解到每个原子以及原子的spd轨道上面，称为为局域态密度，Local DOS (LDOS)
- LORBIT =11 
<br>在10的基础上，还进一步分解到px，py，pz等轨道上，称为投影态密度（Projected DOS）或者分波态密度(Partial DOS)，即PDOS。
<br>所以LORBIT = 11可以提供我们更多的信息,**计算DOS时设置为11**




