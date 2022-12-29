---
layout: post
title:  "OpenMP学习(Fortran)"
date:   2022-12-22 19:17:00 +0800
categories: Fortran
tags:  Fortran OpenMP
author: cndaqiang
mathjax: true
---
* content
{:toc}

OpenMP+Fortran<br>
不讲原理，只写代码，边用边补充




## 参考
- [OpenMP fortran 学习](https://www.cnblogs.com/jiangleads/p/11664235.html)
- [OpenMP并行编程](https://scc.ustc.edu.cn/zlsc/cxyy/200910/W020121113517997951933.pdf)
- [OpenMP中数据属性相关子句详解（1）：private/firstprivate/lastprivate/threadprivate之间的比较](https://blog.csdn.net/gengshenghong/article/details/6985431)
- [【OpenMP】OpenMP: 多线程文件操作](https://blog.csdn.net/qq_43331089/article/details/124469616)
- [Visual C++ 中的 OpenMP](https://learn.microsoft.com/zh-cn/cpp/parallel/openmp/openmp-in-visual-cpp?view=msvc-170)



## 备注
- OpenMP是基于线程的并行编程模型。
- OpenMP采用Fork-Join并行执行方式：<br>
 OpenMP程序开始于一个单独的主线程（Master Thread），然后主线程一直串行执行，直到遇见第一个并行域(Parallel Region)，然后开始并行执行并行区域。其过程如下：
- - Fork:主线程创建一个并行线程队列，然后，并行域中的代码在不同的线程上并行执行；
- - Join:当并行域执行完之后，它们或被同步或被中断，最后只有主线程在执行。
- 每个分线程可以继续创建新的并行区域,之前的分线程在新的并行区域就是主线程.详见下面的嵌套指令
- Fortran语法不区分大小写
- 不加编译参数`-qopenmp`或者删除标志符`!$OMP`,编译出的就是串行版本,也能执行,但是可以用于debug,但若有规约等依赖并行的操作,结果可能不对
- 线程数、并行方案等很多控制参数可以通过环境变量设置,也可以通过库函数设置，亦可以通过子句设置,<br>如设置线程数: `export OMP_NUM_THREADS=8`,`CALL omp_set_num_threads(8)`,子句(优先级最高)`!$OMP PARALLEL num_threads(8)`

## 示例
### 编译参数

- intel: `ifort -qopenmp main.f90`<br>`icc -qopenmp 1.c`
- pgi:   `pgfortran -mp main.f90`
- gnu:   `gfortran -fopenmp main.f90`<br>`gcc -fopenmp  1.c`

对于`f95`格式,ifort的指令为
```
ifort -qopenmp -Tf   main.f95 -free
#-free必须放在最后,不然报错compilation aborted for -free (code 1)
#暂时不去找原因了
```

### 运行参数
```
#设置最大线程数
export OMP_NUM_THREADS=4
./a.out
```

### 代码
main.f90
```
program main
write(*,*) "hello: main"
!$OMP PARALLEL
write(*,*) "hello: parallel"
!$OMP END PARALLEL
end program
```

```
cndaqiang@macmini openmp1$ ifort -qopenmp main.f90
cndaqiang@macmini openmp1$ export OMP_NUM_THREADS=4
cndaqiang@macmini openmp1$ ./a.out
 hello: main
 hello: parallel
 hello: parallel
 hello: parallel
 hello: parallel
```


## 制导语句

### 语法
```
制导标识符(!$OMP, #pragma omp)  制导指令(parallel,DO/for,..) [子句(private,shared,...)]
```
- 在并行域结尾有一个隐式同步(barrier),即并行都结束后才进入串行区域
- 子句可省略,不同的制导指令有特定的字句[详细组合见下]<br>在Fortran语言中，子句间用逗号或空格分隔；<br>C/C++子句间用空格分开
- 可以有多层并行域语句进行嵌套
- Fortran的每个制导语句(`!$OMP 制导指令`)跟一个结束的制导语句(`!$OMP END 制导指令`)配套使用确定并行域大小. <br>C没有结束的制导语句,并行域仅是制导语句紧跟的第一个代码段/行
- 语法可以写多行, 每行开头都是指导标识符, Fortran的续航符用`&`,如
```
!$OMP PARALLEL &
!$OMP num_threads(5)
```


### 制导标识符
就是语言的注释开头,每个制导语句必须以制导标识符开头
- C:`#pragma omp`, 
- Fortran: `!$OMP`,如果是固定格式用`!`,`*`,即`C$OMP`,`*$OMP`

### 制导指令(名称)
**并行域指令**:划定[新的]并行区域,产生[新的]多个线程,并行区域内代码被多个线程并行执行负责
- `parallel` 用在一个代码段之前，表示这段代码将被多个线程并行执行<br>
可以在串行区域添加,也可以在并行区域创建新的并行区域

**工作共享指令**,只负责任务划分，并分发给各个线程。<br>
工作共享指令必须位于并行域中才能起到并行执行任务的作用，原因是工作共享指令不能产生新的线程，因此如果位于串行域中的话，任务只能被一个线程执行。<br>
**每个工作分享结构结束处会隐含障碍同步(子任务个数小于线程个数时多余的线程,或者提前执行完的线程,将在工作共享结束语法`END DO, END SECTIONS, END SINGLE`处等待),除非显式指明NOWAIT**
- `for/do` 自动划分循环任务<br>用于for循环(C)或者do循环(Fortran)之前，将循环任务按照`schedule`分配到多个线程中并行执行<br>**一定要注意变量的私有性,不能出现有冲突的共享变量,不要出现不同循环之间有依赖**
- `sections` 手动划分任务. <br>人为设置一段段代码，每段代码section是一个子任务,被一个线程执行<br>子任务个数大于线程个数时，任务分配由编译器指定，尽量负载平衡
- `single` 并行域中的串行任务<br>第一个遇到 SINGLE 指令的线程执行相应的代码
- `workshare` 主要负责 Fortran 95 中本身可并行执行的语句<br>
结构块中只能包括以下语句
<br>矩阵赋值（包括作用在矩阵上的函数，如 SUM， MATMUL 等）
<br>标量赋值（只有一个线程负责执行，其它线程等待）
<br>FORALL 语句， FORALL 结构
<br>WHERE 语句， WHERE 结构
<br>ATOMIC 结构， CRITICAL 结构， PARALLEL 结构
- 简化代码可以把并行域指令`parallel`和工作共享指令组合
<br> `parallel for/do` parallel 和 for语句的结合
<br> `parallel sections` parallel和sections两个语句的结合
<br> `parallel workshare` parallel和workshare两个语句的结合


**同步指令**
- `barrier`，用于并行区内代码的线程同步<br>
在所有的线程到达之前，没有线程可以提前通过一个barrier<br>
在工作共享指令(DO/FOR,SECTIONS,SINGLE,WORKSHARE)结束后，有一个隐式barrier存在；使用`nowait`子句可以去除循环<br>
如果有一个线程没有执行barrier命令,则所有线程会被卡死
- `Master` 结构体代码**仅由主线程执行**；其它线程*跳过*并继续执行；通常用于I/O；<br>`single` 则是由第一个遇到的线程执行,并有隐含`barrier`
- `critical[(名字)]` 同一时间内仅有一个线程执行下面的*代码段*,所有线程将依次执行 CRITICAL 块<br>主要用于共享变量的更新，写文件等，避免数据竞争,<br>例如可以用于求各个线程中某局域变量的和或者最大值并保存到共享变量<br>并行域中可以包含多个 CRITICAL 块,所有没有名字的 CRITICAL 块被看作是一个整体,建议给每个 CRITICAL 块起名字,名字用小括号扩起来<br>同名的临界区被看作是一个整体：同一时间，同名块中只能有一个线程<br>
- `Atomic` 同一时间内仅有一个线程执行紧随的*赋值命令*,所有线程将依次执行下面的赋值命令<br>
和`critical`类似,但是`critical`是单线程执行一段代码(串行更新变量,不仅能赋值),<br>
**`atomic`如果赋值的区域不同,可以(并行)更新共享变量**<br>
紧随的*赋值命令*只能是下面的格式:`x=x operator expr`,`x=intrinsic(x,expr)`,`x` 是共享标量， `expr` 中不含 `x`(详细规则见下)<br>
**原子改写的含义是指：读取该存储地址`x`的内容、做所需运算、然后把新值写回该存储地址`x`这一连串操作不会被其它线程间断，它保证所有操作要么全部完成，要么保持原封不动**<br>
无论何时，当需要在更新共享存储单元的语句中避免数据竞争，应该先使用`atomic`，然后再使用临界段
- `ordered` 一般在循环体内部使用,<br>一个do循环内部只能用一次ordered指令<br>同一时刻只允许一个线程执行ordered内部结构<br>执行顺序是循环顺序<br>需要在制导指令`DO`后面设置子句`ordered`
- `flush[(变量列表)]`,FLUSH语句是用来确保执行中存储器中的数据一致的同步点。保证一个变量从内存中的读取结果相同

**数据环境指令**
- `threadprivate(变量列表)` 指定变量或公共数据块是线程私有的，且在同一个线程内是全局的(在所有的并行空间每个线程始终保留各自变量的内存空间)<br>仅能在声明/定义代码附近写threadprivate指令<br>fortran定义这些变量时要加上SAVE属性<br>见下示例


#### 综合示例
```
!并行域指令
!$OMP PARALLEL private(i_p,i)
i_p=omp_get_thread_num()
!并行执行DO循环
!$OMP DO
DO i=1,4
write(*,*) "I'm",i_p,"set i_s",i
ENDDO
!$OMP END DO
!并行执行几个section
!$OMP SECTIONS
!$OMP SECTION
    write(*,*) "I'm",i_p,"SECTION1"
!$OMP SECTION
    write(*,*) "I'm",i_p,"SECTION2"
!$OMP SECTION
    write(*,*) "I'm",i_p,"SECTION3"
!$OMP END SECTIONS
CALL sleep(i_p+1)
!$OMP SINGLE
!结构体代码仅由一个线程执行；并由首先执行到该代码的线程执行；其它线程等待直至该结构块被执行完
i_s(:)=1
write(*,*) "I'm",i_p,"SINGLE"
!$OMP END SINGLE
!$OMP END PARALLEL
```
结果
```
 I'm           0 set i_s           1
 I'm           3 set i_s           4
 I'm           2 set i_s           3
 I'm           1 set i_s           2
 I'm           0 SECTION1
 I'm           2 SECTION3
 I'm           1 SECTION2
 I'm           0 SINGLE
```

#### PARALLEL+X
- 如果PARALLEL并行域内紧跟X(DO/SECTIONS),可以合并为同一个

```
!$OMP PARALLEL
i_p=omp_get_thread_num()
!$OMP DO PRIVATE(i)
DO i=1,4
    write(*,*) "I'm",i_p,"i=",i
ENDDO
!$OMP END  DO
!$OMP END PARALLEL
```
或者
```
!$OMP PARALLEL DO PRIVATE(i)
DO i=1,4
    i_p=omp_get_thread_num()
    write(*,*) "I'm",i_p,"i=",i
ENDDO
!$OMP END PARALLEL DO
```
结果,两个线程分别执行特定的DO循环体
```
 I'm           0 i=           1
 I'm           0 i=           2
 I'm           1 i=           3
 I'm           1 i=           4
```
如果`!$OMP DO`后面没有紧跟`DO`循环命令,则会编译报错`error #7644: The statement or directive following this OpenMP* directive is incorrect.`



#### critical、ATOMIC示例
**ATOMIC紧跟的原子改写规则**
- Fortran:
```
!$OMP ATOMIC
statement
```
- C/C++：
```
#pragma omp atomic
statement
```

在fortran中， statement必须是下列形式之一：`x=x op expr、 x=expr op x 、 x=intr(x, expr)或x=intr(expr， x)`。
- 其中： op是`+、 - 、 * 、 / 、 .and. 、 .or. 、 .eqv. 、或.neqv. `之一；
- intr是`MAX 、 min 、 IAND 、 IOR或IEOR`之一。

在C/C++中， statement必须是下列形式之一：`x binop=expr、x++ 、 x-- 、 ++x 、 或--xx`。
- 其中： `binop`是二元操作符： `+、 - 、 * 、 / 、 & 、 ^ 、 <<或 >>`之一

```fortran
j=0
!$OMP BARRIER
!直接求最大值,由于各线程读存的顺序不同,结果是随机的
j=max(j,i_p)
!$OMP BARRIER
if (i_p .EQ. 0) write(*,*) "j=",j
!$OMP BARRIER
j=0
!$OMP BARRIER
!CRITICAL同一时间只有一个线程操作内存区域,最终能保存最大值
!CRITICAL [(name)] 的name可以省略,也可以自定义
!$OMP CRITICAL (name)
j=max(j,i_p)
!$OMP END CRITICAL (name)
!$OMP BARRIER
if (i_p .EQ. 0) write(*,*) "j=",j
!$OMP BARRIER

j=0
!$OMP BARRIER
!ATOMIC也可以实现单线程操作内存区域
!$OMP ATOMIC
j=max(j,i_p)
!$OMP BARRIER
if (i_p .EQ. 0) write(*,*) "j=",j
```




#### ordered示例
如果不是ordered下面大概率会先执行i=3时的write命令,而用上ordered后,在ordered内会按照i=1,2,3,4顺序执行
```fortran
!$OMP DO ordered
DO i=1,4
CALL sleep(10-i*2)
!$OMP ordered
write(*,*) "I'm",i_p,"set i_s",i
!$OMP end ordered
ENDDO
!$OMP END DO
```

#### flush示例
一般在使用OpenMP的时候也很少遇到flush语句,因为flush在下面几种情况下会隐含运行（nowait子句除外）：

- `!$OMP BARRIER`
- `!$OMP CRITICAL 和 !$OMP END CRITICAL`
- `!$OMP END DO`
- `!$OMP END SECTIONS`
- `!$OMP END SINGLE`
- `!$OMP END WORKSHARE`
- `!$OMP ORDERED` 和 `!$OMP END ORDERED`
- `!$OMP PARALLEL DO` 和 `!$OMP END PARALLEL DO`
- `!$OMP PARALLEL SECTIONS` 和 `!$OMP END PARALLEL SECTIONS`
- `!$OMP PARALLEL WORKSHARE` 和 `!$OMP END PARALLEL WORKSHARE`

下列指令不隐含数据同步
- `!$OMP DO`
- `!$OMP MASTER`
- `!$OMP END MASTER`
- `!$OMP SECTIONS`
- `!$OMP SINGLE`
- `!$OMP WORKSHARE`


示例,还没找到flush起重要作用的算法
```c
//http://www.openmp.org/wp-content/uploads/openmp-examples-4.0.2.pdf
//Example mem_model.2c, from Chapter 2 (The OpenMP Memory Model)
#include<omp.h>
int main() {
   int data, flag = 0;
   #pragma omp parallel num_threads(2)
   {
      if (omp_get_thread_num()==0) {
         /* Write to the data buffer that will be read by thread */
         data = 42;
         /* Flush data to thread 1 and strictly order the write to data
            relative to the write to the flag */
         #pragma omp flush(flag, data)
         /* Set flag to release thread 1 */
         flag = 1;
         /* Flush flag to ensure that thread 1 sees S-21 the change */
         #pragma omp flush(flag)
      }
      else if (omp_get_thread_num()==1) {
         /* Values of flag and data are undefined */
         printf("flag=%d data=%d\n", flag, data);
         /* Loop until we see the update to the flag */
         while (flag < 1) {
            #pragma omp flush(flag, data)
         }
         /* Values data will be 42 */
         printf("flag=%d data=%d\n", flag, data);
      }
   }
   return 0;
}
```


### 子句
**常规属性**
- `IF(逻辑表达式)`指定循环是应并行执行还是串行执行
- `num_threads(N)`，指定线程的个数
- `collapse(循环层数)` 把几层for/do循环进行并行执行,默认只有最外层循环分给各个线程,`COLLAPSE(2)`把两层循环分给各个线程
- `ordered`，用来指定for循环的执行要按顺序执行<br>是`for/do`循环的子句<br>说明for循环内有ordered制导语句
- `schedule`，指定如何调度do/for循环迭代,`SCHEDULE（ kind[, int chunksize]）`<br>
`kind`为`STATIC,DYNAMIC,GUIDED,RUNTIME`,用法见下<br>
`chunksize`对于`STATIC,DYNAMIC`:把总循环任务数按照每`chunksize`(默认1)个循环作为一个任务,然后把任务按照静态/动态策略进行分配<br>
`chunksize`对于`GUIDED`:把总任务按照每`>=chunksize`个循环作为一个任务,每个任务的长度不固定(开始长后面短),然后把任务进行分配<br>
`RUNTIME`表示根据执行程序时环境变量决定`export OMP_SCHEDULE="static,4"`,chunksize也有环境变量读入,不能在代码中写chunksize<br>
**静态调度开销最小，能用静态调度的话尽量用静态调度**
- `nowait`，忽略指定中暗含的等待<br>
在工作共享指令(DO/FOR,SECTIONS,SINGLE,WORKSHARE)结束后，有一个隐式barrier存在；使用`nowait`子句可以去除循环<br>
示例`!$OMP DO ... !$OMP END DO NOWAIT`,`#pragma omp for nowait`


**数据共享属性**
- `default`，用来指定并行处理区域内的变量的使用方式`DEFAULT(SHARED|PRIVATE|NONE)`，缺省是shared<br>
c/c++: `default(shared | none)`,fortran`default(private | firstprivate | shared | none)`
- `shared(变量列表)`，指定一个或多个变量为多个线程间的共享变量
- `private(变量列表)`, 指定每个线程都有它自己的**变量私有副本**<br>即创建新的内存空间(*没有初值*)<br>和并行区域外的变量没有任何关联
- `firstprivate(变量列表)`，指定每个线程都有它自己的变量私有副本，并且变量要被*继承主线程中的初值*
- `lastprivate(变量列表)`，主要是用来指定将线程中的私有变量的值在并行处理结束后复制回主线程中的对应变量。<br>
是语法上的最后值赋值给主线程,不是最后执行完的的线程的值<br>
如，对于for而言，就是最后一个循环迭代所在线程的副本值，用于对共享变量赋值<br>
如果是section构造，那么是最后一个section语句中的值赋给对应的共享变量
- `reduction`，用来指定一个或多个变量是**私有的**(与private功能相同),并(按照归约的类型)给初值，<br>并且在并行处理结束后处理这些**变量私有副本**和**并行区域之外的同名变量**,执行归约运算,<br>如`+, -, *, .and., .or., .eqv.,.neqv. , max, min, iand, ior, ieor`,<br>结果保存到并行区域之外的同名变量<br>
示例`!$OMP PARALLEL reduction(max:ip) reduction(min:ip1)`
- `copyprivate`，用于`single`制导中的指定变量广播到并行区中其它线程<br>如用single读取数据后广播给其他变量<br>对于Fortran在`END SINGLE`结束语句处使用, `!$OMP END SINGLE COPYPRIVATE(变量列表)`<br>变量列表是各种pricate变量,包括THREADPRIVATE
- `copyin(threadprivate变量列表)`，将主线程的threadprivate变量广播给其它线程的threadprivate变量








#### 变量类型示例
- shared的变量执行完并行区域后,里面的值的更改会保留
- private的变量更改仅在并行区域有效,即额外创建了一份私有内存空间,不会改变原来变量区域
```fortran
integer :: i_s(2),i_p=10,i=100
!$OMP PARALLEL shared(i_s,i),default(private)
i_p=omp_get_thread_num()+1
i_s(i_p)=i_p
!$OMP END PARALLEL
write(*,*) "i_p",i_p,"i_s",i_s
```
结果
```
 i_p          10 i_s           1           2
```

#### private/firstprivate/lastprivate/threadprivate对比
- private/firstprivate/lastprivate是子句,仅在负责的并行区域有效
- threadprivate是制导指令(指令),在所有的并行区域都有效
- private在并行区域开辟新的空间,不同线程互补干扰,与并行区域外的变量无关. 没有赋初值
- firstprivate同private,但是初值来自并行区域外
- lastprivate结束并行区域后,把语法上执行的最后一次的值赋值给并行区域外
- 变量可以同时是firstprivate+lastprivate. 但是不能是private+firstprivate/lastprivate
- `copyin(threadprivate_i)`可以把主线程的threadprivate变量同步到各个线程

示例
```fortran
program main
USE OMP_LIB
implicit NONE
integer :: private_i,firstprivate_i,lastprivate_i
!仅能在声明/定义处使用THREADPRIVATE
integer,SAVE :: threadprivate_i !THREADPRIVATE的变量要有SAVE属性
!$OMP THREADPRIVATE(threadprivate_i)
integer :: i
write(*,*) "hello: main"
i=100
threadprivate_i=1
private_i=2
firstprivate_i=3
lastprivate_i=4
!$OMP PARALLEL private(private_i) &
!$OMP          firstprivate(firstprivate_i)
if ( omp_get_thread_num() .EQ. 0 ) write(*,*) "parallel: private_i",private_i
if ( omp_get_thread_num() .EQ. 0 ) write(*,*) "parallel: firstprivate_i",firstprivate_i
!lastprivate_i为i=5的循环结果
!$OMP DO private(i) lastprivate(lastprivate_i)
DO i=1,5
call sleep(6-i)
lastprivate_i=i
threadprivate_i=i
ENDDO
!$OMP END DO
!$OMP END PARALLEL
write(*,*) "ROOT: lastprivate_i",lastprivate_i
!主线程即0线程的结果
write(*,*) "ROOT: threadprivate_i",threadprivate_i
!$OMP PARALLEL
!所有线程保留各自的值
write(*,*) "ID",omp_get_thread_num(), "parallel: threadprivate_i",threadprivate_i
!$OMP END PARALLEL

end program
```
两个线程的执行结果
```
 parallel: private_i           0
 parallel: firstprivate_i           3
 ROOT: lastprivate_i           5
 ROOT: threadprivate_i           3
 ID           0 parallel: threadprivate_i           3
 ID           1 parallel: threadprivate_i           5
```


#### DO+schedule

这里使用`runtime`举例
```fortran
N=20
!$OMP PARALLEL  PRIVATE(ip,ip2) SHARED(C)
!$OMP DO schedule(runtime)
DO i=1,N
C(i)=omp_get_thread_num()
END DO
!$OMP END DO
!$OMP END PARALLEL

WRITE(*,"(A4)",advance="no") "DO:"
FLUSH(6)
DO i=1,N
WRITE(*,"(I4)",advance="no") i
FLUSH(6)
ENDDO
WRITE(*,*) ""
WRITE(*,"(A4)",advance="no") "IP:"
DO i=1,N
WRITE(*,"(I4)",advance="no") C(i)
FLUSH(6)
ENDDO
WRITE(*,*) ""
```

##### static
```
export OMP_SCHEDULE="static,4"
#或者在代码中
!$OMP DO schedule(static,4)
```
- `chunksize=4`每4个循环作为一个基础任务
- **`static`就是依次分配给每个线程**

结果
```
 DO:   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20
 IP:   0   0   0   0   1   1   1   1   0   0   0   0   1   1   1   1   0   0   0   0
```

##### dynamic
```
export OMP_SCHEDULE="dynamic,4"
#或者在代码中
!$OMP DO schedule(dynamic,4)
```
- `chunksize=4`每4个循环作为一个基础任务
- **`dynamic`谁先执行到此任务,谁执行**,<br>如下面0线程执行的最快,先执行了三个任务`[1-4][5-8][9-12]`,1线程执行了`[13-16]`,0线程又执行`[17-20]`

结果
```
 DO:   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20
 IP:   0   0   0   0   0   0   0   0   0   0   0   0   1   1   1   1   0   0   0   0
```

##### guided
```
export OMP_SCHEDULE="guided,4"
#或者在代码中
!$OMP DO schedule(guided,4)
```
- `chunksize=4`每`>=4`个循环作为一个基础任务
- **`dynamic` 动态设置每个任务的循环长度,先长后短**

结果
```
 DO:   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19  20
 IP:   0   0   0   0   0   1   1   1   1   1   1   1   1   0   0   0   0   1   1   1
```

#### DO + COLLAPSE 示例
```fortran
!$OMP PARALLEL DO ORDERED PRIVATE(i,j)
DO i=1,2
DO j=1,2
!$OMP ORDERED
write(*,*) "ID",omp_get_thread_num(),i,j
!$OMP END ORDERED
ENDDO
ENDDO
!$OMP END PARALLEL DO
!$OMP PARALLEL DO COLLAPSE(2) ORDERED PRIVATE(i,j)
DO i=1,2
DO j=1,2
!$OMP ORDERED
write(*,*) "ID",omp_get_thread_num(),i,j
!$OMP END ORDERED
ENDDO
ENDDO
!$OMP END PARALLEL DO
```
结果,默认情况只有两个线程执行循环,使用collapse后可以用更多的线程参与
```
 ID           0           1           1
 ID           0           1           2
 ID           1           2           1
 ID           1           2           2
 ID           0           1           1
 ID           1           1           2
 ID           2           2           1
 ID           3           2           2
 ```

#### reduction详解
- 指定一个或多个变量是私有的，并且在并行处理结束后对这些变量+并行区域外的同名变量执行指定的归约操作（如求和），然后将结果返回给主线程中的同名变量
- 语法:`reduction(op:var1) reduction(op:var2) reduction(op:var3) `

```fortran
!$OMP PARALLEL reduction(max:ip) reduction(min:ip1)
write(*,*) omp_get_thread_num(),ip,ip1
!$OMP END PARALLEL
```

对于Fortran

规约函数|初值
-|-
`+` | `0`
`*` | `1`
`-` | `0`
`.and.` | `.true.`
`.or.` | `.false.`
`.eqv.` | `.true`
`.neqv` | `.false.`
`max` | 最小数
`min` | 最大数
`iand` (位运算) | all bits on
`ior ` (位运算) | 0
`ieor` (位运算) | 0


#### IF 示例
```fortran
ip= 1
!对于Fortran判断语句可以时 ip > 0, 或者ip .GT. 0, 用.TRUE.等都可以
!$OMP PARALLEL IF(ip .GT. 0)
write(*,*) ".GT.",omp_get_thread_num()
!$OMP END PARALLEL
!$OMP PARALLEL IF(ip .LE. 0)
write(*,*) ".LE.",omp_get_thread_num()
!$OMP END PARALLEL
```
结果
```
 .GT.           0
 .GT.           1
 .LE.           0
```


### 子句和制导指令的组合使用
只有并行域指令和工作共享指令才常和子句搭配使用,图源[并行计算@潘建瑜](https://math.ecnu.edu.cn/~jypan/):
![](/uploads/2022/12/omp_zhiling_ziju.png)


### 指令绑定规则
- DO, SECTIONS, SINGLE, MASTER 和 BARRIER 指令绑定到动态的封装 PARALLEL 中，如果没有并行域执行，这些语句是无效的。
- ORDERED 指令绑定到包围它的动态 DO 中。
- ATOMIC 指令迫使所有线程做互斥访问，而不仅是当前组里的线程。
- CRITICAL 指令迫使所有的线程做互斥访问，而不仅是当前组里的线程。
- 指令总是绑定到包围它的最内层 PARALLEL 中

### 指令嵌套
- 动态的位于另一个 PARALLEL 指令中的 PARALLEL 指令逻辑上建立一个新的组，如果不允许嵌套并行(默认`export OMP_NESTED=FALSE`)，则这个新组仅由当前线程执行。
<br>使用嵌套时需要设置`export OMP_NESTED=TRUE`或者`CALL omp_set_nested(.TRUE.)`(优先级更高)
<br>新版OpenMP的嵌套命令使用`export OMP_MAX_ACTIVE_LEVELS=2`指定嵌套层数
- 受同一PARALLEL指令控制的 DO， SECTIONS， SINGLE 指令不允许彼此嵌套。<br>即PARALLEL中的DO不能直接套DO等任务分配,需要重新PARALLEL创建新的并行区域<br>如PARALLEL中可以有DO, DO中可以套PARALLEL再套DO循环下去,<br>
如果只是简单的双层DO嵌套,用`collapse`子句更简单
- DO， SECTIONS 和 SINGLE 指令不允许出现在 CRITICAL 和MASTER 的动态区域中。
- BARRIER 指令不允许出现在 DO， SECTIONS， SINGLE， MASTER和 CRITICAL 指令的动态区域中。
- MASTER 指令不允许出现在 CRITICAL 区的动态区域中。
- ORDERED 区不允许出现在 CRITICAL 区的动态区域中。
- 可以在并行域的动态区域中出现的指令，也可在并行域的动态区域外出现，但它仅由主线程执行

#### 指令嵌套示例
```fortran
!$OMP PARALLEL  PRIVATE(ip,ip2)
!$OMP DO
DO i=1,2
    ip=omp_get_thread_num()
    !$OMP PARALLEL  firstprivate(i,ip)
    !$OMP DO
    DO j=1,4
        CALL sleep(i*10+j)
        write(*,*) "P1",ip+1,"P2",omp_get_thread_num()+1,"i",i,"j",j
        CALL cal()
    END DO
    !$OMP END DO
    !$OMP END PARALLEL
END DO
!$OMP END DO
!$OMP END PARALLEL
```
当开启嵌套时(`export OMP_NESTED=TRUE`),开始的两个线程，每个线程作为主线程又创建了4个线程
```
 P1           1 P2           1 i           1 j           1
 P1           1 P2           2 i           1 j           2
 P1           1 P2           3 i           1 j           3
 P1           1 P2           4 i           1 j           4
 P1           2 P2           1 i           2 j           1
 P1           2 P2           2 i           2 j           2
 P1           2 P2           3 i           2 j           3
 P1           2 P2           4 i           2 j           4
```
而若关闭嵌套(`export OMP_NESTED=FALSE`),开始的两个线程需要执行j的循环
```
 P1           1 P2           1 i           1 j           1
 P1           2 P2           1 i           2 j           1
 P1           1 P2           1 i           1 j           2
 P1           1 P2           1 i           1 j           3
 P1           2 P2           1 i           2 j           2
 P1           1 P2           1 i           1 j           4
 P1           2 P2           1 i           2 j           3
 P1           2 P2           1 i           2 j           4
 ```




## 库函数
使用这些库函数需要Fortran `USE OMP_LIB`,C`#include<omp.h>`

### 基础库函数
- `omp_set_num_threads(int N)`, 设置并行执行代码的线程个数,**必须在并行区域之外执行才有效**,是subroutine
- `omp_get_num_threads()`, 返回当前并行区域中的活动线程个数。`export OMP_NUM_THREADS=8`或者`CALL omp_set_num_threads(4)`指定,或者子句的方式指定`!$OMP PARALLEL num_threads(5)`
- `OMP_GET_MAX_THREADS()` 返回并行域中可用的最大线程个数
- `omp_get_thread_num()`, 返回线程号,`0,1,2,...,omp_get_num_threads()-1`
- `omp_get_num_procs()`, 返回运行本线程的多处理机的处理器个数。如果开了超线程,就是总逻辑处理器
- `OMP_IN_PARALLEL()` 判断是否在并行域中
- `OMP_SET_DYNAMIC(LOG_EXPR)` 启用或关闭线程数目的动态改变
- `OMP_GET_DYNAMIC()` 判断系统是否支持动态改变线程数目
- `OMP_SET_NESTED(LOG_EXPR)` 启用或关闭并行域嵌套
- `OMP_GET_NESTED()` 判断系统是否支持并行域的嵌套
- `omp_init_lock(OMP_LOCK_KIND)`, 初始化一个简单锁. *LOCK详见下面*
- `omp_set_lock(OMP_LOCK_KIND)`， 上锁操作
- `omp_unset_lock(OMP_LOCK_KIND)`， 解锁操作，要和omp_set_lock函数配对使用。
- `omp_destroy_lock(OMP_LOCK_KIND)`， `omp_init_lock`函数的配对操作函数，关闭一个锁
- `omp_test_lock(OMP_LOCK_KIND)` 试图获得互斥器，如果获得成功则返回true，否则返回false<br>该函数可以看作是omp_set_lock的非阻塞版本。
- `omp_get_wtime()`. 获取 wall time，以秒为单位，双精度型的实数,就是带小数的时间戳
- `omp_get_wtick()`. 获取每个时钟周期的秒数，即 omp_get_wtime 的精度(如omp_get_wtime精度是小数点后6位,就返回1e-6)

### OpenMP 3.1 新增库函数
查表吧
- omp_set_schedule
- omp_get_schedule
- omp_get_thread_limit
- ...


### 获取线程信息示例
```fortran
USE OMP_LIB
CALL omp_set_num_threads(4)
!$OMP PARALLEL
write(*,*) "omp_get_num_procs",   omp_get_num_procs()
write(*,*) "omp_get_num_threads",   omp_get_num_threads()
write(*,*) "omp_get_thread_num",omp_get_thread_num()
!$OMP END PARALLEL
```

### LOCK例程
设定锁和解除锁之间的区域,同一时间只能有一个线程执行,而别的线程仅能在设定锁的线程解除锁(执行完锁定区域代码)后才能设定锁(执行锁定区域代码).

Fortran: `USE OMP_LIB;integer(OMP_LOCK_KIND) :: var`
- `Subroutine OMP_INIT_LOCK(VAR)`
- `Subroutine OMP_SET_LOCK(VAR)`
- `LOGICAL FUNCTION OMP_TEST_LOCK(VAR)`
- `Subroutine OMP_UNSET_LOCK(VAR)`
- `Subroutine OMP_DESTROY_LOCK(VAR)`

C/C++：`#include<OMP.h>`,`omp_lock_t * lock;`
- `void omp_init_lock(omp_lock_t *lock);`
- `void omp_set_lock(omp_lock_t *lock);`
- `int omp_test_lock(omp_lock_t *lock);`
- `void omp_unset_lock(omp_lock_t *lock);`
- `void omp_destroy_lock(omp_lock_t *lock);`

示例:<br>
- 如果不设置`LOCK`,输出到屏幕的顺序是多个循环同时输出的<br>
而设置`LOCK`后,则由先执行到LOCK的线程先执行锁定区间的内容
- `OMP_set_LOCK`和`OMP_TEST_LOCK`是相同的级别,不能同时使用
```fortran
integer(OMP_LOCK_KIND) :: var
CALL OMP_init_LOCK(ilock) !必须先初始化,才能执行其他的命令,如OMP_TEST_LOCK
!若不初始化,直接执行其他LOCK命令,会卡死
!$OMP PARALLEL SHARED(ilock)
!$OMP DO private(i) 
DO i=1,2
    !只能有一个线程执行下面的锁定内容,其他线程被锁定(阻塞)
    CALL OMP_set_LOCK(ilock)
    write(*,*) "ID",omp_get_thread_num(),i
    CALL sleep(3-i)
    write(*,*) "ID",omp_get_thread_num(),i*10
    CALL OMP_unset_LOCK(ilock)
ENDDO
!$OMP END DO
!$OMP DO private(i) 
DO i=1,2
    !尝试获得lock,若没获得也可以执行其他的命令,可视为omp_set_lock的非阻塞版本
    DO WHILE( .not. OMP_TEST_LOCK(ilock) )
        !do someting else
        call sleep(1)
        write(*,*) "ID",omp_get_thread_num(),"sleep"
    END DO
    !只能有一个线程执行下面的锁定内容
    write(*,*) "ID",omp_get_thread_num(),i
    CALL sleep(3-i)
    write(*,*) "ID",omp_get_thread_num(),i*10
    CALL OMP_unset_LOCK(ilock)
ENDDO
!$OMP END DO
!$OMP END PARALLEL
CALL OMP_DESTROY_LOCK(ilock)
```
结果
```
 ID           1           2
 ID           1          20
 ID           0           1
 ID           0          10
 ID           0           1
 ID           1 sleep
 ID           0          10
 ID           1 sleep
 ID           1           2
 ID           1          20
```


## 环境变量

变量 | 含义
- | -
`OMP_NUM_THREADS` | 设置线程个数<br>示例`export OMP_NUM_THREADS=4`<br>亦可`CALL omp_set_num_threads(4)`指定<br>子句的方式指定`!$OMP PARALLEL num_threads(4)`<br>num_threads子句的优先权高于库例程omp_set_num_threads和环境变量OMP_NUM_THREADS
`OMP_SCHEDULE`  | 设置循环任务的调度模式 <br>示例`export OMP_SCHEDULE="DYNAMIC, 4"`
`OMP_DYNAMIC`  | 设置线程数的动态变化<br>是否动态设定并行域执行的线程数
`OMP_NESTED`  | 设置并行域的嵌套<br>`export  OMP_NESTED=TRUE`,新版是`export OMP_MAX_ACTIVE_LEVELS=N`<br>亦可`CALL omp_set_nested(.TRUE.)`/`CALL omp_set_max_active_levels(N)`
`OMP_STACKSIZE`  | 线程的堆栈的大小，缺省单位是 K
`OMP_THREAD_LIMIT`  | 整个 OpenMP 程序的线程的最大个数



## MPI混编OpenMP

```fortran
program main
USE OMP_LIB
USE MPI
implicit NONE
integer :: ierr,ip,i,np
CALL MPI_INIT(ierr)
CALL MPI_COMM_RANK(MPI_COMM_WORLD,ip,ierr)
CALL MPI_COMM_SIZE(MPI_COMM_WORLD,np,ierr)
CALL SLEEP(ip)
!$OMP PARALLEL PRIVATE(i)
!$OMP DO
DO i=ip+1,10,np
    write(*,*) "MPI:",ip,"OpenMP",omp_get_thread_num(),"I",i
    CALL cal()
ENDDO
!$OMP END DO
!$OMP END PARALLEL 
CALL MPI_FINALIZE(ierr)
CONTAINS
subroutine cal()
integer :: i,j
    DO while ( .TRUE. )
    i=1
    j=10
    j=j+i*j+j*j
    ENDDO
end subroutine cal
end program
```
运行,使用`top`查看共两个PID程序(mpi),每个PID程序占用CPU400%(4个OpenMP线程)
```
mpiifort  -qopenmp   -O0 main.f90
mpirun -np 2 ./a.out
 MPI:           0 OpenMP           3 I           9
 MPI:           0 OpenMP           2 I           7
 MPI:           0 OpenMP           1 I           5
 MPI:           0 OpenMP           0 I           1
 MPI:           1 OpenMP           0 I           2
 MPI:           1 OpenMP           2 I           8
 MPI:           1 OpenMP           3 I          10
 MPI:           1 OpenMP           1 I           6
#top
PID    COMMAND      %CPU  TIME     #TH    #WQ  #PORTS MEM    PURG   CMPRS  PGRP  PPID  STATE    BOOSTS
78969  a.out        395.1 08:09.01 6/4    0    17     4088K  0B     0B     78969 78968 running  *0[1]
78970  a.out        395.0 08:05.04 6/4    0    16     4212K  0B     0B     78970 78968 running  *0[1]
```

## 报错警告
### `A specification statement cannot appear in the executable section`
详情
```
main.f90(8): error #6236: A specification statement cannot appear in the executable section.
!$OMP THREADPRIVATE(threadprivate_i)
```
由于`!$OMP THREADPRIVATE(threadprivate_i)`只能在声明处执行,移到变量定义附近即可

### `A variable that appears in a THREADPRIVATE directive and is not declared in the scope of a module must have the SAVE attribute`
```
main.f90(5): error #7909: A variable that appears in a THREADPRIVATE directive and is not declared in the scope of a module must have the SAVE attribute.   [THREADPRIVATE_I]
integer :: threadprivate_i
```
因为定义了`!$OMP THREADPRIVATE(threadprivate_i)`,`threadprivate_i`对于不同线程是独立的,全局的,因此需要定义时添加SAVE属性,即`integer,SAVE :: threadprivate_i`

### `Syntax error, found 'LASTPRIVATE' when expecting one of: PRIVATE ALLOCATE FIRSTPRIVATE REDUCTION DEFAULT SHARED COPYIN PROC_BIND NUM_THREADS`
```
main.f90(14): error #5082: Syntax error, found 'LASTPRIVATE' when expecting one of: PRIVATE ALLOCATE FIRSTPRIVATE REDUCTION DEFAULT SHARED COPYIN PROC_BIND NUM_THREADS ...
!$OMP PARALLEL private(private_i) lastprivate(lastprivate_i) &
----------------------------------^
```
说明`PARALLEL`不支持`LASTPRIVATE`的子句,语法不对.应该把`LASTPRIVATE`子句移到DO指令行

### `OMP: Info #269: OMP_NESTED variable deprecated, please use OMP_MAX_ACTIVE_LEVELS instead.`
```
OMP: Info #269: OMP_NESTED variable deprecated, please use OMP_MAX_ACTIVE_LEVELS instead.
```
使用`OMP_MAX_ACTIVE_LEVELS`变量
```
unset OMP_NESTED
export OMP_MAX_ACTIVE_LEVELS=2
```
类似的
```
OMP: Info #277: omp_set_nested routine deprecated, please use omp_set_max_active_levels instead.
```
使用`CALL omp_set_max_active_levels(2)`替代`CALL omp_set_nested(.TRUE.)`



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
