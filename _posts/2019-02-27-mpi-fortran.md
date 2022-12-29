---
layout: post
title:  "MPI编程入门(Fortran)"
date:   2019-02-27 8:51:00 +0800
categories: Fortran
tags:  Fortran mpi
author: cndaqiang
mathjax: true
---
* content
{:toc}

MPI(openmpi)+Fortran(mpif90)<br>
不讲原理，只写代码，边用边补充




## 参考
⭐⭐[莫则尧, 袁国兴. 消息传递并行编程环境 MPI[M]. 科学出版社, 2001.](/web/file/2019/mzy_MPI.pdf)<br>
[Fortran 学习笔记](/2019/01/30/Fortran-learn/)<br>
[USTC超算中心:MPI分布内存并行程序开发-1.ppt](https://scc.ustc.edu.cn/_upload/article/files/e0/98/a9f0c4964abdb3281233d7943f9e/W020100308601033034327.ppt)<br>
[USTC超算中心:MPI分布内存并行程序开发-2.ppt](https://scc.ustc.edu.cn/_upload/article/files/e0/98/a9f0c4964abdb3281233d7943f9e/W020100308601033282447.ppt)<br>
[Open MPI v1.10.1 documentation](https://www.open-mpi.org/doc/v1.10/)<br>
[潘建瑜:MPI 编程基础](http://math.ecnu.edu.cn/~jypan/Teaching/ParaComp/mpi_lect_jypan.pdf)
[松山湖材料实验室：材料计算与超算应用系列webinar](http://www.sslab.org.cn/newsshow.php?id=388&from=singlemessage)

## MPI
MPI不是一门语言，而是给Fortran或C等语言提供并行通信协调各个进程的功能<br>
编译，运行
```
[cndaqiang@mu01 mpi]$ mpif90 pi.f90 
[cndaqiang@mu01 mpi]$ mpirun -np 5 a.out 
```
## 语法
语法速查[Open MPI v1.10.1 documentation](https://www.open-mpi.org/doc/v1.10/)

- MPI的所有常量、变量与函数 /过程均以MPI_ 开头
- MPI 的 C 语言接口为函数， **FORTRAN 接口为子程序 **，且对应接口的名称相同
- Fortran仅有两个函数不是子程序`MPI_WTIME() 和 MPI_WTICK()`
- 在C程序中，所有常数的定义除下划线外一律由大写字母组成，在函数和数据类型定义
中, 接MPI_ 之后的第一个字母大写，其余全部为小写字母，即MPI_Xxxx_xxx形式
-  **对于FORTRAN 程序， MPI 函数全部以过程方式调用，一般全用大写字母表示，即
MPI_XXXX_XXX形式（ FORTRAN不区分大小写）`call MPI_XXXX_XXX(一堆参数,ierr)`**
-  除 MPI_WTIME 和 MPI_WTICK 外，所有C函数调用之后都将返回一个错误信息码，
而 MPI 的**所有 FORTRAN 子程序中都有一个integer类型的输出参数（ IERR）代表调用错误码**
-  MPI 是按进程组(Process Group) 方式工作的，所有MPI 程序在开始时均被认为是在通信
器MPI_COMM_WORLD 所拥有的进程组中工作，之后用户可以根据自己的需要，建立
其它的进程组
-  所有MPI 的通信一定要在通信器(communicator) 中进行
- **REDUACE等的bufer要给`A(1,1)`,给`A`或`A(:,:)`会报错**

## 数据类型


### MPI程序流程
![](/uploads/2019/02/mpi.JPG)

- F77/F90:先引用`mpif.h`头文件<br>或F90可以用`use mpi`
- `call MPI_INIT(ierr)`进入MPI环境
- `call MPI_FINALIZE`结束MPI环境
- 在MPI环境中，各个进程均分别执行该部分代码
- 各个进程间数据独立，通过通信传递数据


引入mpi示例
```
PROGRAM test
use mpi
implicit none
!...
```
或
```
PROGRAM test
implicit none
include 'mpif.h'
!...
```

完整代码示例
```
program jifen_mpi
implicit none
include 'mpif.h'
integer :: node,np,ierr,status(mpi_status_size)
logical :: Ionode
integer :: n,i
real ::a,b,x,h,jifen,pi

call MPI_INIT(ierr)
call MPI_COMM_RANK(MPI_COMM_WORLD,node,ierr)
call MPI_COMM_SIZE(MPI_COMM_WORLD,np,ierr)

Ionode=(node .eq. 0)

if (Ionode) then
    write(*,*) "Plese input n:"
    read(*,*) n
    do i=1,np-1
        call MPI_SEND(n,1,MPI_INTEGER,i,99,MPI_COMM_WORLD,ierr)
    end do
else
    call MPI_RECV(n,1,MPI_INTEGER,0,99,MPI_COMM_WORLD,status,ierr)
end if

a=0.0
b=1.0
h=(b-a)/n
jifen=0.0

i=node+1
do while(i <= n)
x=h*(i*1.0-0.5)
jifen=jifen+4.0/(1.0+x*x)
i=i+np
end do

if (Ionode) then
do i=1,np-1
call MPI_RECV(sum_n,1,MPI_REAL,i,100,MPI_COMM_WORLD,status,ierr)
jifen=jifen+sum_n
end do
jifen=jifen*h
pi=3.141592653
write(*,"(f12.10)") pi
write(*,"(f12.10)") jifen

else
call MPI_SEND(jifen,1,MPI_REAL,0,100,MPI_COMM_WORLD,ierr)
end if

call MPI_FINALIZE(ierr)

end program jifen_mpi
```

### call MPI_INIT(ierr) 
进入MPI环境，ierr为`integer`型变量，执行成功返回0

### call MPI_INITIALIZED(FLAG, IERR)

```
MPI_INITIALIZED(FLAG, IERR) 
LOGICAL FLAG 
INTEGER IERR
```
如果已经`call MPI_INIT(ierr)`返回非零值

若未，则返回0

### call MPI_FINALIZE(ierr)
退出MPI环境，ierr为`integer`型变量，执行成功返回0



### 获得系统/进程信息
#### call MPI_COMM_RANK(comm,node,ierr)
- comm通信器名，`integer`型变量，系统自动创建通信器`MPI_COMM_WORLD`
- node，`integer`型变量，返回当前进程序号，取值范围0，1，2，3...进程数-1
- ierr为`integer`型变量，执行成功返回0

#### call MPI_COMM_SIZE(comm,np,ierr)
- comm通信器名，`integer`型变量，系统自动创建通信器`MPI_COMM_WORLD`
- np，`integer`型变量，返回总进程数
- ierr为`integer`型变量，执行成功返回0

#### call MPI_GET_PROCESSOR_NAME(name,namelen,ierr)进程所在机器名
在多节点运行时，返回节点的名称存储在name中
名称长度返回在namelen中
```
character(len=MPI_MAX_PROCESSOR_NAME) :: name
integer::namelen
call MPI_GET_PROCESSOR_NAME(name,namelen,ierr)
```
#### call MPI_GET_VERSION(VERSION, SUBVERSION, ierr) mpi版本 
```
MPI_GET_VERSION(VERSION, SUBVERSION, IERROR)
    INTEGER    VERSION, SUBVERSION, IERROR
```
## 点对点通信
进程与进程间的通信

### 函数总览

阻塞型：当前发送必须完成，或者备份到缓存区后才执行下一条语句<br>
非阻塞型：MPI系统在后台执行发送语句，程序先执行后续语句，需检测到发送/备份完成后在对相应数据行进更改

通信模式
- 标准模式
<br>1)发送数据量小时，先存入缓冲区，发送操作执行完成，MPI后台将缓冲区的数据发送给接收进程
<br>2)发送数据量大是，等待接收操作启动，发送数据直至发送操作完成
<br>缓冲区大小由MPI决定
- 缓冲模式(使用缓冲区的标准模式)
<br>用户定义、使用和回收缓冲区，将数据存入缓冲区，不管接收操作是否启动，发送操作都可以执行，但是必须保证缓冲区可用
- 同步模式(不使用缓冲区的标准模式)
<br>必须等到接受开始启动发送才可以返回
- 就绪模式
<br>只有当接收操作已经启动时，才可以在发送进程启动发送操作，否则发送将出错


| 函数类型      | 通信模式     | 阻塞型           | 非阻塞型           |
| ------------- | ------------ | ---------------- | ------------------ |
| 消息发送函数  | 标准模式     | **MPI_SEND**         | MPI_ISEND          |
|               | 缓冲模式     | MPI_BSEND        | MPI_IBSEND         |
|               | 同步模式     | MPI_SSEND        | MPI_ISSEND         |
|               | 就绪模式     | MPI_RSEND        | MPI_IRSEND         |
| 消息接收函数  |              | **MPI_RECV**         | MPI_IRECV          |
| 消息检测函数  |              | MPI_PROBE        | MPI_IPROBE         |
| 等待/查询函数 |              | MPI_WAIT         | MPI_TEST           |
|               | MPI_WAITALL  | MPI_TESTALL      |                    |
|               | MPI_WAITANY  | MPI_TESTANY      |                    |
|               | MPI_WAITSOME | MPI_TESTSOME     |                    |
| 释放通信请求  |              | MPI_REQUEST_FREE |                    |
| 取消通信      |              |                  | MPI_CANCEL         |
|               |              |                  | MPI_TEST_CANCELLED |


### 发送/接收数据在内存中的地址BUFF
指应用程序定义地用于发送或接收数据的地址<br>
Fortran中就是变量名/数组元素<br>
**特殊的BUFFER**<br>
**`MPI_IN_PLACE`**发送buffer也是接收buffer
```
  IF( root >= 0 ) THEN
     CALL MPI_REDUCE( MPI_IN_PLACE, ps, dim, MPI_INTEGER, MPI_SUM, root, comm, info )
     !CNQ MPI_IN_PLACE 当前进程既发送又接受数据，而且要发送的数据和在要接收的数据的保存在同一内存
     IF( info /= 0 ) CALL errore( 'reduce_base_integer', 'error in mpi_reduce 1', info )
  ELSE
     CALL MPI_ALLREDUCE( MPI_IN_PLACE, ps, dim, MPI_INTEGER, MPI_SUM, comm, info )
     IF( info /= 0 ) CALL errore( 'reduce_base_integer', 'error in mpi_allreduce 1', info )
  END IF
```

### 数据个数COUNT
从BUF开始发送/接收特定类型的数据个数<br>
数据类型的长度 * 数据个数的值为用户实际传递的消息长度

### 发送的数据类型
将Fortran定义的数据发送时，要通知MPI数据类型，Fortran与MPI的数据类型对应<br>
即使用Fortran的DATATYPE定义的变量，在MPI通信时，注明MPI DATATYPE

|    **MPI DATATYPE**    |     Fortran DATATYPE |
| -------------------- | ---------------- |
| MPI_CHARACTER        | character(1)     |
| MPI_INTEGER          | integer          |
| MPI_REAL             | real             |
| MPI_DOUBLE_PRECISION | double precision,适合REAL(kind=8) |
| MPI_COMPLEX          | complex          |
| MPI_LOGICAL          | logical          |
| MPI_BYTE             | 8 binary digits  |
| MPI_PACKED | data packed or unpacked   with MPI_Pack()/MPI_Unpack<br>打包发送的时候用,数量是打包pos |

### 发送目的地DEST
发送进程指定的接收该消息的目的进程，也就是**接收进程的进程号**
### 发送进程号SOURCE
接收进程指定的发送该消息的源进程，也就是**发送进程的进程号**。如果该值为MPI_ANY_SOURCE表示接收任意源进程发来的消息。
### 发送标识符TAG
取值非负整数值（0-32767），两进程间可能进行多次通信，**发送操作和接收操作的标识符要匹配才接收**，对于接收操作来说，如果tag指定为MPI_ANY_TAG则可与任何发送操作的tag相匹配。
### 通信器COMM
包含源与目的进程的一组上下文相关的进程集合，除非用户自己定义（创建）了新的通信因子，否则一般使用系统预先定义的全局通信因子MPI_COMM_WORLD。
### 状态STATUS
在FORTRAN程序中，这个参数是**包含MPI_STATUS_SIZE个整数的数组**<br>
在接收操作中使用，status（MPI_SOURCE）、status（MPI_TAG）和status（MPI_ERROR）分别表示数据的进程标识、发送数据使用tag 标识和接收操作返回的错误代码。
相当于一种在接受方对消息的监测机制，并且以其为依据对消息作出不同的处理（当用通配符接受消息时）。

### 函数
#### call MPI_SEND(BUF, COUNT, DATATYPE, DEST, TAG, COMM, IERROR)发送
```
MPI_SEND(BUF, COUNT, DATATYPE, DEST, TAG, COMM, IERROR)
    <type>    BUF(*)
    INTEGER    COUNT, DATATYPE, DEST, TAG, COMM, IERROR
```
从本进程的BUF变量所在的内存开始，按照DATATYPE的类型为基本单元，提取COUNT条数据发送到DEST进程，通信标签TAG，通信器COMM，执行成功IERROR返回0

#### call  MPI_RECV(BUF, COUNT, DATATYPE, SOURCE, TAG, COMM, STATUS, IERROR)接收
```
MPI_RECV(BUF, COUNT, DATATYPE, SOURCE, TAG, COMM, STATUS, IERROR)
    <type>    BUF(*)
    INTEGER    COUNT, DATATYPE, SOURCE, TAG, COMM
    INTEGER    STATUS(MPI_STATUS_SIZE), IERROR
```
从source进程，按照DATATYPE的类型为基本单元，接收COUNT条数据存储到本进程的BUF变量，通信标签TAG，通信器COMM，执行成功IERROR返回0

其他模式用法语法速查[Open MPI v1.10.1 documentation](https://www.open-mpi.org/doc/v1.10/)

## 集合通信
集合操作的三种类型：
- 同步(barrier)：集合中所有进程都到达此处后，每个进程再接着运行；
```
call MPI_BARRIER(COMM, IERROR)
```
- 数据传递：广播(broadcast)、分散(scatter)、收集(gather)、全部到全部(alltoall)

- 全局规约(reduction)：从所有进程收集数据进行计算
<br>如：求最大值、求最小值、加、乘等

**进程只有执行了集合通信语句，才会进行同步，传递，规约**

### call MPI_BARRIER(COMM, IERROR)
用于同步
### 广播
#### call MPI_BCAST(BUFFER, COUNT, DATATYPE, ROOT, COMM, IERROR)
将ROOT进程的BUFFER广播给所有进程的BUFFER，**变量名一致**
<br>进程只有执行了该语句，才会接收该条广播
<br>ROOT进程即发送也接收
```
MPI_BCAST(BUFFER, COUNT, DATATYPE, ROOT, COMM, IERROR)
    <type>    BUFFER(*)
    INTEGER    COUNT, DATATYPE, ROOT, COMM, IERROR
```


#### call MPI_SCATTER(SENDBUF, SENDCOUNT, SENDTYPE, RECVBUF, RECVCOUNT,RECVTYPE, ROOT, COMM, IERROR)

ROOT进程将SENDBUF**以`sendcnt*sendtype`为单元散发到不同节点**<br>
**sendcnt必须≤recvcnt相同**

```
MPI_SCATTER(SENDBUF, SENDCOUNT, SENDTYPE, RECVBUF, RECVCOUNT,RECVTYPE, ROOT, COMM, IERROR)
    <type>    SENDBUF(*), RECVBUF(*)
    INTEGER    SENDCOUNT, SENDTYPE, RECVCOUNT, RECVTYPE, ROOT
    INTEGER    COMM, IERROR
```

#### call MPI_GATHER(SENDBUF, SENDCOUNT, SENDTYPE, RECVBUF, RECVCOUNT,RECVTYPE, ROOT, COMM, IERROR)
收集数据存到root进程

每个节点送SENDCOUNT个数据，**从每个节点接收RECVCOUNT个数据，共接收RECVCOUNTx发送节点数**

```
MPI_GATHER(SENDBUF, SENDCOUNT, SENDTYPE, RECVBUF, RECVCOUNT,RECVTYPE, ROOT, COMM, IERROR)
    <type>    SENDBUF(*), RECVBUF(*)
    INTEGER    SENDCOUNT, SENDTYPE, RECVCOUNT, RECVTYPE, ROOT
    INTEGER    COMM, IERROR
```

### 函数示例
```
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!  聚合通信函数                                                                     !!!
!!! Author:       cndaqiang                                                           !!!
!!! ContactMe:    https://cndaqiang.github.io                                         !!! 
!!! Name:                                                                   !!!
!!! Last-update:  2019-05-10                                                          !!!
!!! Build-time:   2019-05-10                                                          !!!
!!! What it is:                   !!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
program juhetongxin
use m_mpi_my
call MPI_start()


!call t_mpi_reduce()
!call t_mpi_BCAST()
!call t_mpi_GATHER()
!call t_mpi_ALLGATHER()
!call t_mpi_GATHERv()
!call t_mpi_scatter()
!call t_MPI_SCATTERV()
!call t_mpi_ALLTOALL()
call t_mpi_ALLTOALLv()

call MPI_END()



contains
!=============================聚合通信
!在同一个COMM中所有进程都参与
!有任何一个进程不参与，通信都会等待
!因此可以对每个进程设置不同的发送BUFFER，COUNT
!----
!MPI_BARRIER
!阻塞所有的调用者直到所有的组成员都调用了它
!各个进程中这个调用 才可以返回
!确保数据都传输完成
!MPI_BARRIER(COMM, IERROR)    
!INTEGER COMM, IERROR
!----


!----
!MPI_BCAST( BUFFER, COUNT, DATATYPE, ROOT, COMM, IERROR ) 
!  BUFFER(*) INTEGER COUNT, DATATYPE, ROOT, COMM, IERRO
subroutine t_mpi_BCAST()
INTEGER :: a(3)
a=node
call MPI_BCAST(a,3,MPI_INTEGER,0,my_COMM,mpi_ierr)
if(node.eq.2) write(*,*) a
end subroutine t_mpi_BCAST
!----
!MPI_GATHER( SENDBUF, SENDCOUNT, SENDTYPE, RECVBUF, RECVCOUNT, RECVTYPE, ROOT, COMM, IERROR ) 
! SENDBUF(*), RECVBUF(*) INTEGER SENDCOUNT, SENDTYPE, RECVCOUNT, RECVTYPE, ROOT, COMM, IERROR
!每个节点送SENDCOUNT个数据，**从每个节点接收RECVCOUNT个数据，共接收(RECVCOUNT*发送节点数)
!SENDBUF ≤ RECVBUF
subroutine t_mpi_GATHER()
INTEGER :: a(6),b(3)
a=node
call MPI_GATHER(a,1,MPI_INTEGER,a,2,MPI_INTEGER,0,my_COMM,mpi_ierr)
if(IOnode) write(*,*) a
end subroutine t_mpi_GATHER
!---
!MPI_Allgather
!每一进程都从所有其它进程收集数据 相当于所有进程都执行了一个MPI_Gather调 用
!MPI_ALLGATHER( SENDBUF, SENDCOUNT, SENDTYPE, RECVBUF, RECVCOUNT, RECVTYPE, COMM, IERROR)
!  SENDBUF(*), RECVBUF(*) INTEGER SENDCOUNT, SENDTYPE, RECVCOUNT, RECVTYPE, COMM, IERROR
subroutine t_mpi_ALLGATHER()
INTEGER :: a(6),b(3)
a=node
call MPI_ALLGATHER(a,1,MPI_INTEGER,a,1,MPI_INTEGER,my_COMM,mpi_ierr)
if(node==1) write(*,*) a
end subroutine t_mpi_ALLGATHER
!---
!MPI GATHERV
!指定从每个进程接收的数量
!MPI_GATHERV( SENDBUF, SENDCOUNT, SENDTYPE, RECVBUF, RECVCOUNTS, DISPLS, RECVTYPE, ROOT, COMM, IERROR ) 
!SENDBUF(*), RECVBUF(*) INTEGER SENDCOUNT, SENDTYPE, RECVCOUNTS(*), DISPLS(*), RECVTYPE, ROOT, COMM, IERROR

subroutine t_mpi_GATHERv
INTEGER :: a(8),b(3),c(3),te(4)
do i=1,8
a(i)=node*10+i
end do
b(1)=2
b(2)=2
b(3)=4
c(1)=0
c(2)=2
c(3)=4
te=100
!对每个进程设置不同的发送BUFFER，COUNT
if(node .eq. 2) then
call MPI_GATHERV(te,3,MPI_INTEGER,a,b,c,MPI_INTEGER,0,my_COMM,mpi_ierr)
else
call MPI_GATHERV(a,2,MPI_INTEGER,a,b,c,MPI_INTEGER,0,my_COMM,mpi_ierr)
endif
if(IOnode) write(*,*) a
!DISPLS
!BUFFER的第一个位置的位移DISPLS=0
!发送小于接收时，不会覆盖RECVBUFF
!cndaqiang@win10:/mnt/e/work/CODE/MPI-course> mpirun -np 3 ./test
! 1           2          11          12         100         100         100           8
end subroutine t_mpi_GATHERv
!---
!MPI ALLGATHERV
!都gatherv 
!MPI_ALLGATHERV( SENDBUF, SENDCOUNT, SENDTYPE, RECVBUF, RECVCOUNTS, DISPLS, RECVTYPE,COMM,IERROR)
! SENDBUF(*), RECVBUF(*) INTEGER SENDCOUNT, SENDTYPE, RECVCOUNTS(*), DISPLS(*), RECVTYPE, COMM, IERROR
!略
!---
!scatter
!---
!MPI SCATTER 
!MPI_SCATTER(SENDBUF, SENDCOUNT, SENDTYPE, RECVBUF, RECVCOUNT, RECVTYPE, ROOT, COMM, IERROR ) 
!SENDBUF(*), RECVBUF(*) INTEGER SENDCOUNT, SENDTYPE, RECVCOUNT, RECVTYPE, ROOT, COMM, IERROR
!@
!** SENDCOUNT是发送到每个进程的大小，总发送SENDCOUNT*进程数 **
!@
!散发相同长度数据块。 根进程 root 将自己的 sendbuf 中的 np 个
!连续存放的数据块按进程号的顺序依次分发到 comm 的各个进程 (包括
!根进程自己) 的 recvbuf 中， 这里 np 代表 comm 中的进程数。 sendcnt
!和 sendtype 给出 sendbuf 中每个数据块的大小和类型， recvcnt 和
!recvtype 给出 recvbuf 的大小和类型， 
!其中参数 sendbuf、 sendcnt 和sendtype 仅对根进程有意义,就是其他进程
subroutine t_mpi_scatter()
INTEGER :: a(8),b(8),c(3),te(4)
a=0
if(IOnode) a=100
call MPI_SCATTER(a,1,MPI_INTEGER,a,2,MPI_INTEGER,0,my_COMM,mpi_ierr)
write(*,*) node,a
end subroutine t_mpi_scatter
!----
!6.21 MPI考试
!----
!scatterv
!MPI_SCATTERV(SENDBUF, SENDCOUNTS, DISPLS, SENDTYPE, RECVBUF, RECVCOUNT, RECVTYPE, ROOT, COMM, IERROR )
!SENDBUF(*), RECVBUF(*) INTEGER SENDCOUNTS(*), DISPLS(*), SENDTYPE, RECVCOUNT, RECVTYPE, ROOT, COMM, IERROR
!SENDBUF, SENDCOUNTS, DISPLS, SENDTYPE仅与根进程有关
subroutine t_MPI_SCATTERV()
INTEGER :: a(8),b(3),c(3),te(4)
a=0
b(1)=2
b(2)=3
b(3)=3
c(1)=0
c(2)=2
c(3)=2
do i=1,8
if(IOnode) a(i)=i
end do
call MPI_SCATTERV(a,b,c,MPI_INTEGER,a,3,MPI_INTEGER,0,my_COMM,mpi_ierr)
write(*,*) node,a
!DISPLS可以重复，太好了
!运行结果
!  1           3           4           5           0           0           0           0           0
!  2           3           4           5           0           0           0           0           0
!  0           1           2           3           4           5           6           7           8
           
end subroutine t_MPI_SCATTERV
!---
!MPI Alltoall
!转置分布
!node   | data
! 0     |   A01 A02 A03
! 1     |   A11 A12 A13
! 2     |   A21 A22 A23
!Alltoall 转置操作
!node   | data
! 0     |   A01 A11 A21
! 1     |   A02 A12 A22
! 2     |   A03 A13 A23
!---
!MPI_ALLTOALL(SENDBUF, SENDCOUNT, SENDTYPE, RECVBUF, RECVCOUNT, RECVTYPE, COMM, IERROR )
!SENDBUF(*), RECVBUF(*) INTEGER SENDCOUNT, SENDTYPE, RECVCOUNT, RECVTYPE, COMM, IERROR
!**  SENDCOUNT和RECVCOUNT都是发送接收单元，不是总数 **
!相同长度数据块的全收集散发： 进程 i 将 sendbuf 中的第 j 块数据
!发送到进程 j 的 recvbuf 中的第 i 个位置， i, j  0, . . . , np  1 (np 代表
!comm 中的进程数)。 sendbuf 和 recvbuf 均由 np 个连续的数据块构成， 每
!个数据块的长度/类型分别为 sendcnt/sendtype 和 recvcnt/recvtype。
!该操作相当于将数据在进程间进行一次转置。 例如， 假设一个二维数组按
!行分块存储在各进程中， 则调用该函数可很容易地将它变成按列分块存储
!在各进程中。
subroutine t_mpi_ALLTOALL()
INTEGER :: a(3)
do i=1,3
a(i)=(node+1)*10+i
end do
call MPI_ALLTOALL(a,1,MPI_INTEGER,a,1,MPI_INTEGER,my_COMM,mpi_ierr)
write(*,*) node,a
!运行结果
!cndaqiang@win10:/mnt/e/work/CODE/MPI-course> mpirun -np 3 ./test
!           0          11          21          31
!           1          12          22          32
!           2          13          23          33
end subroutine t_mpi_ALLTOALL
!---
!MPI_ALLTOALLV
!---
!发送数量，位移自定义
!接收数量位移自定义
!貌似发送=接收，不想测试了
!MPI_ALLTOALLV(SENDBUF, SENDCOUNTS, SDISPLS, SENDTYPE, RECVBUF, &
!               RECVCOUNTS, RDISPLS, RECVTYPE, COMM, IERROR )
!SENDBUF(*), RECVBUF(*) INTEGER SENDCOUNTS(*), SDISPLS(*), 
!SENDTYPE,RECVCOUNTS(*), RDISPLS(*), RECVTYPE, COMM, IERROR
!向node节点发送，SENDCOUNTS(node+1)个数据，每个数据开头相对SENDBUF位移SDSPLS(node+1)
!从node节点接收，RECVCOUNTS(node+1)个数据，每个数据存储位置相对RECVBUF位移SDSPLS(node+1)
!发送接收有覆盖时，好像容易出错
!---
subroutine t_mpi_ALLTOALLv
INTEGER :: a(8),b(3),c(3),se(3),re(3)
b(1)=3
b(2)=5
b(3)=6
c(1)=0
c(2)=1
c(3)=2
se=1
re=1
do i=1,8
a(i)=i+node*10
end do
write(*,*) "old",node,a
call MPI_ALLTOALLV(a,se,c,MPI_INTEGER,a,re,b,MPI_INTEGER,my_COMM,mpi_ierr)
!1 2 3;11 12 13;21 22 23;
!给每个节点发一个，从0，1，2w位置
!从每个节点接收一个，存到3，5，6位置
write(*,*) "new",node,a

end subroutine t_mpi_ALLTOALLv



!=============================规约操作
!MPI_REDUCE
subroutine t_mpi_reduce()
implicit none
INTEGER :: a(3,3),b(3,3),c(3,3)
a=node
b=node+1
c=node+2
!MPI_REDUCE(SENDBUF, RECVBUF, COUNT, DATATYPE, OP, ROOT, COMM,IERROR)
!SENDBUF与RECVBUF不能一样
call MPI_REDUCE(a,b,9,MPI_INTEGER,MPI_SUM,0,my_COMM,mpi_ierr)
IF(IOnode) write(*,*) b
end subroutine
!---
!其他的规约函数，见文章中，很详细
end program juhetongxin
```

#### 全局规约：从所有进程收集数据进行操作

##### 规约方式
**表格中的相加，表示对这些数据进行OP操作，并存储到相应node的recvbuff**
![](/uploads/2019/02/reduce.JPG)

##### OP操作类型

| MPI 规约操作 |                  | C语言数据类型                   | Fortran语言数据类型             |
| ------------ | ---------------- | ------------------------------- | ------------------------------- |
| MPI_MAX      | 求最大值         | integer, float                  | integer, real,   complex        |
| MPI_MIN      | 求最小值         | integer, float                  | integer, real,   complex        |
| MPI_SUM      | 和               | integer, float                  | integer, real,   complex        |
| MPI_PROD     | 乘积             | integer, float                  | integer, real,   complex        |
| MPI_LAND     | 逻辑与           | integer                         | logical                         |
| MPI_BAND     | 按位与           | integer, MPI_BYTE               | integer, MPI_BYTE               |
| MPI_LOR      | 逻辑或           | integer                         | logical                         |
| MPI_BOR      | 按位或           | integer, MPI_BYTE               | integer, MPI_BYTE               |
| MPI_LXOR     | 逻辑异或         | integer                         | logical                         |
| MPI_BXOR     | 按位异或         | integer, MPI_BYTE               | integer, MPI_BYTE               |
| MPI_MAXLOC   | 最大值和存储单元 | float, double and   long double | real,complex,double   precision |
| MPI_MINLOC   | 最小值和存储单元 | float, double and               | real,complex,double precision   |
| long double  |                  |                                 |                                 |


##### 规约  MPI_REDUCE
```
MPI_REDUCE(SENDBUF, RECVBUF, COUNT, DATATYPE, OP, ROOT, COMM,IERROR)
    <type>    SENDBUF(*), RECVBUF(*)
    INTEGER    COUNT, DATATYPE, OP, ROOT, COMM, IERROR
```


##### 全规约 MPI_ALLREDUCE
```
MPI_ALLREDUCE(SENDBUF, RECVBUF, COUNT, DATATYPE, OP, COMM, IERROR)
    <type>    SENDBUF(*), RECVBUF(*)
    INTEGER    COUNT, DATATYPE, OP, COMM, IERROR
```
##### 规约分发 MPI_REDUCE_SCATTER
```
MPI_REDUCE_SCATTER(SENDBUF, RECVBUF, RECVCOUNTS, DATATYPE, OP,
        COMM, IERROR)
    <type>    SENDBUF(*), RECVBUF(*)
    INTEGER    RECVCOUNTS(*), DATATYPE, OP, COMM, IERROR
```

##### 并行前缀规约 MPI_SCAN
```
MPI_SCAN(SENDBUF, RECVBUF, COUNT, DATATYPE, OP, COMM, IERROR)
    <type>    SENDBUF(*), RECVBUF(*)
    INTEGER    COUNT, DATATYPE, OP, COMM, IERROR
```



## MPI自定义数据类型

新类型的定义

```
INTEGER :: newtype
```

- 新类型需要被`CALL MPI_TYPE_COMMIT(newtype,mpi_ierr)`

- 旧类型若为自定义类型，只有提交后才能用于构建新类型

- 使用后，释放` CALL mpi_TYPE_FREE(newtype,mpi_ierr)`

```
program newtype
use m_mpi_my
implicit none
INTEGER :: contype,vectype
INTEGER :: typesize
INTEGER :: array(10)

call mpi_start()
!----------------------------------
!连续复制型数据A -> {AAA }
!-----
!都志辉_高性能计算之并行编程技术——%20MPI并行程序设计.pdf P174
!MPI_TYPE_CONTIGUOUS(COUNT,OLDTYPE,NEWTYPE,IERROR) 
!		INTEGER COUNT,OLDTYPE,NEWTYPE,IERROR
!call MPI_TYPE_CONTIGUOUS(5,MPI_INTEGER,contype,mpi_ierr)
!重复5次旧类型

!-----------------------------
!向量型 A -> {[AAA ][AAA ][AAA ][AAA ]}
!比重复
!------
!都志辉_高性能计算之并行编程技术——%20MPI并行程序设计.pdf P175
!MPI_TYPE_VECTOR(COUNT,BLOCKLENGTH,STRIDE,OLDTYPE, NEWTYPE,IERROR) 
!		INTEGER COUNT,BLOCKLENGTH,STRIDE,OLDTYPE,NEWTYPE,IERROR
!call MPI_TYPE_VECTOR(2,3,4,MPI_INTEGER,vectype,mpi_ierr)
!2块，每块里面有3旧类型，每块长总4个旧类型
!数据总长：块数*每块总长

!MPI_TYPE_HVECTOR(COUNT,BLOCKLENGTH,STRIDE,OLDTYPE,NEWTYPE,IERROR) 
!		INTEGER COUNT,BLOCKLENGTH,STRIDE,OLDTYPE,NEWTYPE,IERROR
!HVECTOR区别是STRIDE即每块总长度，单位从旧数据长度变为字节
!MPI_TYPE_HVECTOR(2,3,4,MPI_INTEGER,vectype,mpi_ierr) stride=length(块)=4*字节

!-------------------------
!索引型 A -> {[AA ][AAAA            ][AAA]}
!比向量总长度，个数更随意
!----------
!MPI_TYPE_INDEXED(count,array_of_blocklengths,array_of_displacemets,oldtype,newtype) 
!		INTEGR	count 块的数量 
!						array_of_blocklengths 每个块中所含元素个数(非负整数数组) 
!						array_of_displacements 各块偏移值 (整数数组) (就是每个块的初始位置，后面的可以比前面小
!						oldtype 旧数据类型(句柄) newtypr 新数据类型(句柄)
!MPI_TYPE_INDEXED(COUNT,ARRAY_OF_BLOCKLENGTHS,ARRAY_OF_DISPLACEMENTS,OLDTYPE,NEWTYPE,IERROR)
!ARRAY_OF_BLOCKLENGTHS(...) 每个块中的元素数，组成的数组
!ARRAY_OF_DISPLACEMENTS(...) 每个块的位置，组成的数组
!H是字节
!MPI_TYPE_HINDEXED(count,array_of_blocklengths,array_of_displacemets,oldtype,newtype)
!------
!示例：构建下三角矩阵
		subroutine sublamt(M,OLDTYPE,olddisp,NEWTYPE)
			INTEGER :: M,OLDTYPE,NEWTYPE
			INTEGER :: olddisp !OLDTYPE字节长度, 使用kind(A(1,1))获得
			INTEGER,allocatable :: DATALEN(:),BLOCKDISP(:) 
			INTEGER :: i
			!MPI_TYPE_INDEXED(count,array_of_blocklengths,array_of_displacemets,oldtype,newtype)
			allocate(BLOCKDISP(M),DATALEN(M))
			
			Do i=1,M
				!DATALEN(i)=M-i
				!BLOCKDISP(i)=(i-1)*olddisp
				!Fortran要考虑到存储的方式
				DATALEN(i)=M-i+1
				BLOCKDISP(i)=(i-1)*M+(i-1)
			END DO
			call MPI_TYPE_INDEXED(M,DATALEN,BLOCKDISP,OLDTYPE,NEWTYPE,mpi_ierr)
			deallocate(BLOCKDISP,DATALEN)
		end subroutine
!-------


!-------------------------------------------
!结构体类型 A,B,C ->{ { [AA ][BBBB      ][A][CCC ] } }
!比向量，类型更随意
!------
!MPI_TYPE_STRUCT(COUNT,ARRAY_OF_BLOCKLENGTHS,ARRAY_OF_DISPLACEMENTS, ARRAY_OF_TYPES * ,NEWTYPE,IERROR)
!IN count 块的数量 (整数)
!IN array_of_blocklengths 每个块中所含元素个数(整数数组)
!IN array_of_displacements 各块偏移字节数(整数数组)
!IN array_of_types 每个块中元素的类型(句柄数组)
!OUT newtypr 新数据类型(句柄)

!创建数据类型
call MPI_TYPE_CONTIGUOUS(5,MPI_INTEGER,contype,mpi_ierr)
!使用前要提交数据类型
call MPI_TYPE_COMMIT(contype,mpi_ierr)
if(node .eq. 0) then
array=10
!MPI_SEND(BUF, COUNT, DATATYPE, DEST, TAG, COMM, IERROR)
!新类型可以减少发送数据的COUNT
call MPI_SEND(array,2,contype,1,99,my_COMM,mpi_ierr)
array=20
call MPI_SEND(array,10,MPI_INTEGER,2,100,my_COMM,mpi_ierr)
endif
if(node .eq. 1) then
!MPI_RECV(BUF, COUNT, DATATYPE, SOURCE, TAG, COMM, STATUS, IERROR)
call MPI_RECV(array,2,contype,0,99,my_COMM,mpi_status,mpi_ierr)
write(*,*) array
endif
if(node .eq. 2) then
call MPI_RECV(array,10,MPI_INTEGER,0,100,my_COMM,mpi_status,mpi_ierr)
write(*,*) array
endif

!旧类型需要被提交才能创建新类型
call MPI_TYPE_VECTOR(2,3,4,contype,vectype,mpi_ierr)
!2块，3旧类型/块，length(块)=4*旧类型
!call MPI_TYPE_COMMIT(vectype,mpi_ierr)


call MPI_TYPE_EXTENT(vectype,typesize,mpi_ierr)
if(IOnode) write(*,*) "typesize",typesize
!call mpi_TYPE_FREE(vectype,mpi_ierr)


!使用后，释放类型
call mpi_TYPE_FREE(contype,mpi_ierr)


call mpi_end()

end program newtype
```

## MPI打包
### `MPI_PACK MPI_UNPACK`打包解包
打包：就是把一些来自各个变量A1,A2,A3...(不连续的缓冲区)存储到同一个变量B(缓冲区)中去<br>
然后传递这个B<br>
各个变量接收后，按照同样的规则读取(解包)(不按也行,对自己的数据了解就行)<br>
缓冲区变量，通常定义一个大的CHAR类型(因为kind(CHAR)=kind(MPI_PACKED)=1)<br>
传递(如send)buff时，可以全传递，或者先传递实际打包数量(就是最后pos的位置)<br>
pos会随着打包和解包自动增加，打包解包**都是增加**<br>
```
!用法
!--------------------
!打包
MPI_PACK(INBUF,INCOUNT,DATATYPE,OUTBUF,OUTCOUNT,POSITION,COMM, IERROR) 
         IN inbuf       输入缓冲区起始地址(可选数据类型)     
         IN incount     输入数据项个数(整型)     
         IN datatype    每个输入数据项的类型(句柄)     
         OUT outbuf    输出缓冲区开始地址(可选数据类型)     
         IN outcount    输出缓冲区大小(整型)     
         INOUT position 缓冲区当前位置(整型)  !即是输入也是输出pos=pos+kind(DTATYPE)*INCOUNT单位字节   
         IN comm       通信域(句柄)
!-------------------------
!解包
MPI_UNPACK(INBUF,INSIZE, POSITION,OUTBUF,OUTCOUNT, DATATYPE, COMM, IERROR) 
     IN inbuf 输入缓冲区起始(选择)     
     IN insize 输入数据项数目(整型)     
     INOUT position 缓冲区当前位置, 字节(整型)     
     OUT outbuf 输出缓冲区开始(选择)     
     IN outcount 输出缓冲区大小, 字节(整型)     
     IN datatype 每个输入数据项的类型(句柄)     
     IN comm 打包的消息的通信域(句柄)
!

```
### `MPI_PACK_SIZE`就是一个计算器
可以用来计算MPI个类型的占用空间了，可以用于构建数据类型时，确定字节大小
```
 call MPI_PACK_SIZE(a,MPI_REAL,my_COMM,b,mpi_ierr)
!计算存a个MPI_REAL个数据需要多少字节
```
示例程序：
```
program pack
        use m_mpi_my
        INTEGER :: a,b
        REAL(kind=8) :: c(2)
        CHARACTER :: buff(100)
        INTEGER :: mypos
        call MPI_start()
        a=0
        b=0
        c=0
        if(node .eq. 0) then
                a=1
                b=2
                c=100
                mypos=0
                call MPI_PACK(a,1,MPI_INTEGER,buff,50,mypos,my_COMM,mpi_ierr)
                write(*,*) "write 1 INTEGER mypos:",mypos
                call MPI_PACK(c,1,MPI_DOUBLE_PRECISION,buff,50,mypos,my_COMM,mpi_ierr)
                !此处传的REAL是kind=8的双精度，就能用MPI_REAL
                !                               要用MPI_DOUBLE_PRECISION
                write(*,*) "INTEGER(4),REAL(8):   ",mypos
                call MPI_SEND(mypos,1,MPI_INTEGER,1,100,my_COMM,mpi_ierr)
                call MPI_SEND(buff,mypos,MPI_PACKED,1,99,my_COMM,mpi_ierr)
        endif
        
        if(node .eq. 1) then
                !mypos=8
                call MPI_RECV(mypos,1,MPI_INTEGER,0,100,my_COMM,mpi_status,mpi_ierr)
                call MPI_RECV(buff,mypos,MPI_PACKED,0,99,my_COMM,mpi_status,mpi_ierr)
                !把mypos移到0开始从头解包
                mypos=0
                call MPI_UNPACK(buff,50,mypos,a,1,MPI_INTEGER,my_COMM,mpi_ierr)
                write(*,*) mypos,a
        endif

        call MPI_end()

end program pack
```

## 通信子函数
### 创建，备份
```
program comm_mpi
        implicit none
        include 'mpif.h'
        integer :: node,np,ierr,status(mpi_status_size)
        integer :: mycomm
        integer :: splitcomm,color,key,snode,snp
        call MPI_INIT(ierr)
        call MPI_COMM_RANK(MPI_COMM_WORLD,node,ierr)
        call MPI_COMM_SIZE(MPI_COMM_WORLD,np,ierr)
!----------------------------
!复制COMM
!MPI_COMM_DUP( COMM, NEWCOMM, IERROR ) 
!       INTEGER COMM, NEWCOMM, IERROR
        call MPI_COMM_DUP(MPI_COMM_WORLD,mycomm)
!-------------------------
!split comm
!Fortran
!MPI_COMM_SPLIT( COMM, COLOR, KEY, NEWCOMM, IERROR ) 
!       INTEGER COMM, COLOR, KEY, NEWCOMM, IERROR
!根据COLOR分组
!根据KEY决定node顺序，
!NEWCOMM 是整数!!!
!不同的COLOR他们的NEWCOMM值相同，但是newnode重新排序，newnp也重新确定
!可以用来按列，行分到同一comm，进行传递
        key=np-node
        if(node < 2) then
                color=0   
        else 
                color=1   
        endif
        
        call MPI_COMM_SPLIT(mycomm,color,key,splitcomm,ierr)
        call MPI_COMM_RANK(splitcomm,snode,ierr)
        call MPI_COMM_SIZE(splitcomm,snp,ierr)
        !write(*,*) node,snode,snp,splitcomm
        !输出表明，snode重排，snp重定，splitcomm一样
!-------------------------------
        call MPI_FINALIZE(ierr)
end program comm_mpi

````

### 使用Group来创建COMM

```
program comm_mpi
        implicit none
        include 'mpif.h'
        integer :: node,np,ierr,status(mpi_status_size)
        integer :: mycomm
        integer :: splitcomm,color,key,snode,snp
        call MPI_INIT(ierr)
        call MPI_COMM_RANK(MPI_COMM_WORLD,node,ierr)
        call MPI_COMM_SIZE(MPI_COMM_WORLD,np,ierr)
!----------------------------
!复制COMM
!MPI_COMM_DUP( COMM, NEWCOMM, IERROR ) 
!       INTEGER COMM, NEWCOMM, IERROR
        call MPI_COMM_DUP(MPI_COMM_WORLD,mycomm,ierr)
!-------------------------
!split comm
!Fortran
!MPI_COMM_SPLIT( COMM, COLOR, KEY, NEWCOMM, IERROR ) 
!       INTEGER COMM, COLOR, KEY, NEWCOMM, IERROR
!根据COLOR分组
!根据KEY决定node顺序，
!NEWCOMM 是整数!!!
!不同的COLOR他们的NEWCOMM值相同，但是newnode重新排序，newnp也重新确定
!可以用来按列，行分到同一comm，进行传递
        key=np-node
        if(node < 2) then
                color=0   
        else 
                color=1   
        endif
        
        call MPI_COMM_SPLIT(mycomm,color,key,splitcomm,ierr)
        call MPI_COMM_RANK(splitcomm,snode,ierr)
        call MPI_COMM_SIZE(splitcomm,snp,ierr)
        !write(*,*) node,MPI_COMM_WORLD,snode,snp,splitcomm
        !输出表明，snode重排，snp重定，splitcomm一样

!----------------------------------------
!=========================================
!======   创建COMM                    ====  
!======   MPI_COMM_SPLIT() 裂分       ====  
!======   MPI_COMM_CREAT() 由group创建====
!=========================================
        call mkgroup()
        call MPI_FINALIZE(ierr)
!-------------------------------
!---------------------------------------------------
!开始Group
        contains
        subroutine mkgroup
        INTEGER :: groupall,group01,group12,group23,group123,group01_23!01_23指node0,1/2,3所在comm
        INTEGER :: grouptest
        INTEGER :: groupsize
        iNTEGER :: rank,i,ranks(4),range3(3,3)
!group用于构造新的通信子
!---------------------------------------------------
!从COMM构建
!---------
!======group的创建和操作
        call MPI_COMM_GROUP(MPI_COMM_WORLD,groupall,ierr)
!---------------------------------------------------
!group操作
!查看组内进程数size==allnode
!--------------
        call MPI_GROUP_SIZE(groupall,groupsize,ierr)
                !这个ierr最易错
        !if(node .eq. 0) write(*,*) "groupall size",groupsize
        !返回值就是当前组里的进程数，此处为np
!---------------
!查看在组内的进程编号rank==comm内node
        call MPI_COMM_group(splitcomm,group01_23,ierr)
        call MPI_GROUP_RANK(group01_23,rank,ierr)
        !write(*,*) node,snode,rank
        !rank和snode就是一样的
        
!----------------------
!删除RANKS中前n个元素ranks(1：n)
!groupold 除去 ranks(n) -> groupnew
!即除去group中rank为ranks(1:n)的元素构成的新group
! int MPI_Group_excl(MPI_Group group, int n, int *ranks, MPI_Group, *newgroup, ierr) 

        DO i=1,4
                ranks(i)=i-1
        end do
        call MPI_GROUP_EXCL(groupall,1,ranks,group123,ierr)
        !call MPI_GROUP_RANK(group123,rank,ierr)
        !write(*,*) node,rank
        !ranks(1)==0,把0从group中删去
        !node1，2，3->rank0 1 2, node0=-32766
!-------
        call MPI_GROUP_EXCL(groupall,2,ranks,group23,ierr)
        !groupall-0-1->2 3
!---------------------------
!包含，取出原组中包含的的元素
!Fortran MPI_GROUP_INCL( GROUP1老组, N, RANKS, GROUP新组, IERROR )
!   INTEGER GROUP1, N, RANKS(*), GROUP, IERROR
!rank[0]=1,rank[1]=3
!N=2个数
!按数组排除，详解见下面的INCEL
!MPI_GROUP_RANGE_EXCL( GROUP1, N, RANGES, GROUP, IERROR )
!INTEGER GROUP1, N, RANGES(3, *), GROUP, IERROR
!-------------------------        
!GROUP_RANGE_INCEL
!按定义的数组提取
!Fortran MPI_GROUP_RANGE_INCL( GROUP1, N, RANGES, GROUP, IERROR )
!INTEGER GROUP1, N, RANGES(3, *), GROUP, IERROR
!Fortran是range(3,N),C是range(N,3),这是由存储方式决定的
!提取矩阵的前N*3组数据，每组数据定义了一种提取方式，初始range(1,i),终止eange(2,i),步长range(3,i)
!下图以C为例
!   |$$$$$|----|$$$$$|-----|
!   0     3    10    14
!rank[N][3] N组数
!rank[0][0]=0
!rank[0][1]=3
!rank[0][2]=2 步长 0:2:3 -> 0,2
!rank[1][0]=10
!rank[1][1]=14
!rank[1][2]=2 步长 10:2:14 -> 10,12,14
!--------
!Fortran代码实现
        range3(1,1)=0;      range3(1,2)=4;          range3(1,3)=3   !0,2,2 = 0,2
        range3(2,1)=2;      range3(2,2)=10;          range3(2,3)=4   !1,4,9=1 4 8
        range3(3,1)=2;      range3(3,2)=5;          range3(3,3)=3   !2,1,5=2 3 4 5
        !  0,2,2=0 2 !         4,5,10=4 9           !   3,3,4=3
        !node 0 2 4 9 3
        !rank 0 1 2 3  4
        !node的rank排序，由range里面的排序决定，如，此例 node(rank) 0(0) 2(1) 4(2) 9(3) 3(4)
        !call MPI_GROUP_RANGE_INCL(groupall,3,range3,grouptest,ierr)
        !call MPI_GROUP_RANK(grouptest,rank,ierr)
        !write(*,*) node,rank     
!按定义的数组提取剩下的
!Fortran MPI_GROUP_RANGE_EXCL( GROUP1, N, RANGES, GROUP, IERROR )
!INTEGER GROUP1, N, RANGES(3, *), GROUP, IERROR
!----------------


!------------------------------------
!在组与组之间进行操作
!组g1,组g2
        !差group12=groupall-groupall^group23 ^表示交集
        call MPI_GROUP_DIFFERENCE(groupall,group23,group01,ierr)
        !call MPI_GROUP_RANK(group01,rank,ierr)
        !write(*,*) node,rank

!------
!并
!用来求g1 U g2
!call MPI_GROUP_UNION(group1,group2,group3,mpi_ierr)
!write(*,*) node,group1
        call MPI_GROUP_UNION(group01,group23,grouptest,ierr)
        !group=group01+group23=group0123
!-------
!差g=g1-g1^g2 ^表示交
!Fortran MPI_GROUP_DIFFERENCE( GROUP1, GROUP2, GROUP, IERROR )
!INTEGER GROUP1, GROUP2, GROUP, IERROR
!-------


!集合操作
!|S|=n个数
!编号
!-----
!大小
!Fortran MPI_GROUP_SIZE( GROUP, SIZE, IERROR )
!INTEGER GROUP, SIZE, IERROR
!----
!编号
!Fortran MPI_GROUP_RANK( GROUP, RANK, IERROR )
!INTEGER GROUP, RANK, IERROR
!----
!转换
!这个group的编号对应另一个group的编号
!Fortran MPI_GROUP_TRANSLATE_RANKS( GROUP1, N, RANKS1, GROUP2,RANKS2, IERROR )
!INTEGER GROUP1, N, RANKS1(*), GROUP2, RANKS2(*), IERROR
!group2是group1产生的，才会使用这个

!====================================
!======group应用，构成新的通信子
!_---------------------
!只有当split不够用时，才用组通信
!----------------------
!
!Fortran MPI_COMM_CREATE( COMM, GROUP, NEWCOMM, IERROR )
!INTEGER COMM, GROUP, NEWCOMM, IERROR

!-------------
!Fortran MPI_GROUP_FREE( GROUP, IERROR )
!INTEGER GROUP, IERROR
!-------------
!Fortran MPI_GROUP_COMPARE( GROUP1, GROUP2, RESULT, IERROR )
!INTEGER GROUP1, GROUP2, RESULT, IERROR
!RESULT的值为：MPI IDENT§MPI SIMILAR§MPI UNEQUAL
        end subroutine mkgroup

end program comm_mpi

```



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
