---
layout: post
title:  "单机centos编译安装使用PBS torque"
date:   2018-01-11 20:31:00 +0800
categories: Linux
tags: pbs 集群
author: cndaqiang
mathjax: true
---
* content
{:toc}

# 推荐看此文[从0搭建Centos7 计算集群](/2019/09/19/Centos7-CC19/)
2019-09-19:以后遇到的问题我也仅会更新到此文[从0搭建Centos7 计算集群](/2019/09/19/Centos7-CC19/)<br>
本文不再更新<br>
-------------------------------------------------<br>
本文主要在ubuntu编译失败的基础上复制过来，在centos上进行安装尝试。<br>
本文最初的目的是我希望搭建一个环境熟悉torque的命令的，所以搭建的并不适合从事集群计算
<br>搭建计算的集群可以参考[集群架设
](/doc/2018/01/xiada-ssh-mpich2-torque.pdf)和[CentOS下torque集群配置（一）-torque安装与配置](http://blog.csdn.net/dream_angel_z/article/details/44225669)




# 参考
[[转载]PBS！！](http://blog.sciencenet.cn/blog-478347-395684.html)
<br>[“cannot find -lssl; cannot find -lcrypto” when installing mysql-python using mariaDB library](https://stackoverflow.com/questions/25979525/cannot-find-lssl-cannot-find-lcrypto-when-installing-mysql-python-using-mar)
<br>[How to Install boost on Ubuntu?
](https://stackoverflow.com/questions/12578499/how-to-install-boost-on-ubuntu/12578564#12578564?newreg=1035048611464711a0444542ec818276)
<br>[PBS Torque 5.1.3安装配置](http://blog.51cto.com/rabbitjian/1862678)
<br>[CentOS下torque集群配置（一）-torque安装与配置](http://blog.csdn.net/dream_angel_z/article/details/44225669)
<br>[shell编程。ubuntu下的shell出错，提示第4行function: not found，还有第七行的 } 有错。高手教一下](https://zhidao.baidu.com/question/328528962.html)
<br>[RED5 INIT SCRIPT FOR UBUNTU](https://www.panda-os.com/blog/2013/06/red5-init-script-for-ubuntu/)
<br>[hosts文件详解](http://www.cnblogs.com/huangpeng/archive/2009/03/11/1408926.html)


# 集群系统
集群系统就好像一台服务器或者PC，集群资源由实现如下几个部分：
- 资源管理器
<br>为了确保分配给作业合适的资源，集群资源管理需要维护一个数据库。这个数据库记录了集群系统中各种资源的属性和状态、所有用户提交的请求和正在运行的作业。
- 作业调度策略管理器
<br>策略管理器根据资源管理器得到各个结点上的资源状况和系统的作业信息生成一个优先级列表。这个列表告诉资源管理器何时在哪些结点上运行哪个作业

>PBS作业分配的调度器 （scheduler），其主要任务是分配批作业计算任务到现有的计算资源上。 PBS的目前包括openPBS，PBS Pro和Torque三个主要分支。 其中OpenPBS是最早的PBS系统，目前已经没有太多后续开发，PBS pro是PBS的商业版本，功能最为丰富。Torque是Clustering公司接过了OpenPBS，并给与后续支持的一个开源版本。<br>
Maui作业调度器,想象为PBS中的一个插入部件。它采用积极的调度策略优化资源的利用和减少作业的响应时间

## 节点
对于torque PBS有以下节点
- 管理节点(master)
<br>集群系统的管理节点
<br>编译安装管理Torque PBS
<br>安装pbs_server
- 计算节点
<br>安装pbs_client
<br>安装pbs_mom
- 交作业节点
<br>安装pbs_client

# 单机安装
此次进行单机安装pbs，即管理节点，计算节点，作业节点都在一个服务器上,不安装Maui

## 主节点(master)配置
如无特殊说明，以root身份运行
## 环境
centos 7
## 下载
安装包下载地址[Torque Resource Manager](http://www.adaptivecomputing.com/products/open-source/torque/)
```
wget http://wpfilebase.s3.amazonaws.com/torque/torque-6.1.1.1.tar.gz
tar xzvf torque-6.1.1.1.tar.gz
cd torque-6.1.1.1
```
主机名可改为master,我不改了,查看主机名为VM_10_194_centos
```
[root@VM_10_194_centos torque-6.1.1.1]# echo $HOSTNAME
VM_10_194_centos
```
修改`/etc/hosts`使里有`127.0.0.1 主机名或域名 [别名] [别名]`
<br> 主机名必须放在别名前面，即`VM_10_194_centos`要在`localhost`前面，如
```
127.0.0.1  VM_10_194_centos localhost  localhost.localdomain
::1        VM_10_194_centos localhost localhost.localdomain localhost6 localhost6.localdomain6 
```
多节点时要设置各个节点的主机名和ip
## 安装依赖
```
yum install libxml2-devel openssl-devel gcc gcc-c++ boost-devel libtool -y
```
## 编译安装
编译安装
```
./configure --prefix=/usr/local/torque --with-default-server=$HOSTNAME
make
make install
```
其中
- `$HOSTNAME`是主机名
- `--prefix=安装目录`参数可以不带，则默认安装到`/usr/local/sbin`,`/usr/local/bin`目录
<br>此处安装到`/usr/local/torque`安装后需要添加PATH
<br>添加PATH:
<br>在`/etc/profile`里添加`export PATH=/usr/local/torque/bin:/usr/local/torque/sbin:$PATH`
<br>`source /etc/profile`或者退出重新登陆
<br>可通过`which pbs_server`查看是否添加成功
- 卸载命令` make uninstall`

`ls /usr/local/torque/sbin`可看到主要安装了这几个程序
- pbs_mom 
<br>PBS MOM守护进程， 负责监控本机并执行作业，位于所有计算节点上
- pbs_sched
<br>PBS调度守护进程，负责调度作业，位于服务节点上
- pbs_server
<br>PBS服务守护进程，负责接收作业提交，位于服务节点上

### 添加系统服务
将上述命令设置为系统服务
```
cp contrib/init.d/{pbs_{server,sched,mom},trqauthd} /etc/init.d/
```
之后可以使用系统服务命令快速启动关闭查看状态<br>
老版centos命令,centos7兼容
```
service pbs_server stop|start|restart|status
```
centos7还可以使用`systemctl`,
```
systemctl stop|start|restart|status pbs_server
```
### 添加开机启动
添加为系统服务后可以添加开机启动<br>
老版centos命令,centos7兼容
```
chkconfig pbs_server on
chkconfig pbs_sched on
chkconfig pbs_mom on
```
centos7还可以使用`systemctl enable`
```
systemctl enable pbs_server 
systemctl enable pbs_sched
systemctl enable pbs_mom
```
## 打包，生成个节点安装包
```
make packages
```

## 初始化
```
qterm
./torque.setup root
```
>qterm为终止pbs_server的运行,若不终止，无法初始化
<br>有教程中说root应为普通用户名
<br>如果`/etc/hosts`中主机名放在别名后面，会报错
```
qmgr obj= svr=default: Bad ACL entry in host list MSG=First bad host: VM_10_194_centos
ERROR: cannot set root@VM_10_194_centos in operators list
```

## 启动程序
```
for i in pbs_server pbs_sched pbs_mom ; do service $i restart; done
trqauthd
# centos7 还可以
for i in pbs_server pbs_sched pbs_mom ; do systemctl restart $i ; done
trqauthd
```
`ps -e | grep pbs`可以查看启动情况
```
[root@VM_10_194_centos cndaqiang]# ps -e | grep pbs
 8966 ?        00:00:00 pbs_server
 8987 ?        00:00:00 pbs_sched
 8995 ?        00:00:00 pbs_mom
```
## 配置节点
### 管理节点(调度节点,master)
**注:**,每次初始化`./torque.setup <username>` ，会清空管理节点的配置信息,需重新配置<br>
终止pbs_server
```
qterm
```
编辑`/var/spool/torque/server_priv/nodes`，填入管理节点主机名,如
```
VM_10_194_centos np=8 normal
#指定节点，节点的进程数目，节点属性
```
### 计算节点
编辑`/var/spool/torque/mom_priv/config`，填入
```
$pbsserver VM_10_194_centos
$logevent 255
```
重启
```
for i in pbs_server pbs_sched pbs_mom ; do service $i restart; done
trqauthd
```
查看节点
```
[root@VM_10_194_centos cndaqiang]# qnodes
VM_10_194_centos
     state = free
     power_state = Running
     np = 1
     ntype = cluster
     status = opsys=linux,uname=Linux VM_10_194_centos 3.10.0-514.21.1.el7.x86_64 #1 SMP Thu May 25 17:04:51 UTC 2017 x86_64,sessions=10148,nsessions=1,nusers=1,idletime=48030,totmem=3113664kb,availmem=2808244kb,physmem=1016516kb,ncpus=1,loadave=0.00,gres=,netload=2164774121,state=free,varattr= ,cpuclock=Fixed,version=6.1.1.1,rectime=1515722674,jobs=
     mom_service_port = 15002
     mom_manager_port = 15003
```

### 计算节点配置
由于这次是单机,计算节点和管理节点在同一机器，很多集权计算节点的配置不用做了<br>
安装软件包
```
./torque-package-clients-linux-x86_64.sh --install  
./torque-package-mom-linux-x86_64.sh --install
```
重启
```
for i in pbs_server pbs_sched pbs_mom ; do service $i restart; done
trqauthd
```

### 创建队列
```
[root@VM_10_194_centos torque]# qmgr
Max open servers: 9
Qmgr:  creat queue normal queue_type=execution
Qmgr:  set server default_queue=normal
Qmgr:  set queue normal started=true 
Qmgr:  set queue normal enabled=true
Qmgr:  set server scheduling=true
Qmgr:  (ctrl+d退出)
```
重启
```
for i in pbs_server pbs_sched pbs_mom ; do service $i restart; done
```
### 注
每次管理节点开机,都需要
```
trqauthd
```
和重新创建队列 

## 测试提交任务`qsub`
```
[root@VM_10_194_centos torque]# su cndaqiang
[cndaqiang@VM_10_194_centos torque]$ echo "sleep 30" |qsub
8.localhost
[cndaqiang@VM_10_194_centos torque]$ qstat
Job ID                    Name             User            Time Use S Queue
------------------------- ---------------- --------------- -------- - -----
8.localhost                STDIN            cndaqiang              0 R normal         
[cndaqiang@VM_10_194_centos torque]$ qstat
Job ID                    Name             User            Time Use S Queue
------------------------- ---------------- --------------- -------- - -----
8.localhost                STDIN            cndaqiang       00:00:00 C normal
```
30秒后，状态由`R`run变为了`C`complete


# 使用
该部分主要参考
<br>[PBS](http://hydro.igsnrr.ac.cn/data/resources/PBS.pdf)
<br>[[转载]PBS！！](http://blog.sciencenet.cn/blog-478347-395684.html)
## 命令
- 提交脚本
```
qsub <PBS作业脚本>
```
- 查询作业状态
```
cndaqiang@centos1:~$ qstat
Job ID                    Name             User            Time Use S Queue
------------------------- ---------------- --------------- -------- - -----
8.centos1                  STDIN            cndaqiang              0 R normal
```
状态:E退出,Q排队,H挂起,R运行,C结束
- 删除作业
```
qdel <Job ID>
```
- 挂起作业
```
qhold <Job ID>
```
- 取消挂起
```
qrls <Job ID>
```
- 交换作业顺序
```
qorder <Job ID> <Job ID>
```
- qstat
```
qstat 查看最近作业状态
qstat -f <Job ID> 查看作业信息(作业提交多了，忘记是什么必备)
qstat -n <Job ID> 查看作业节点
```

## PBS脚本文件
### 说明
- 本质是一个SHELL脚本,和bash语法相同,可直接调用shell命令
- `#`开头注释
- `#PBS`开头是PBS运行参数
- 环境变量
<br>类似于PHP的魔术变量(预定义常量)
![](/uploads/2018/01/pbs.png)

### PBS运行参数
可以在`qsub 运行参数 <作业脚本>`中设置<br>
也可以在脚本中以`#PBS 运行参数`设置<br>
`qsub 运行参数 <作业脚本>`设置的优先级更高<br>
详细参数设置
![](/uploads/2018/01/pbs2.png)

### 运行VASP示例
参考[北师-普通用户用pbs提交作业操作手册](http://cist.bnu.edu.cn/docs/20150427050417757608.docx)

**pbs脚本中用中文注释会报错**`qsub:  file must be an ascii script`

```
#####PBS参数设置#####
#PBS -N vasp
#程序名
#PBS -l nodes=1:ppn=3
#节点,每个节点核数
#PBS -l walltime=1:00:00:00
#作业运行最大时间1天，估算自己的作业最大运行时间，这里指定一下
#PBS -q batch
# 添加到队列batch
#PBS -V
#定义环境变量范围
#PBS -S /bin/bash 

#####设置PATH#####
source /opt/intel/compilers_and_libraries_2018.0.128/linux/bin/compilervars.sh intel64
source /opt/intel/compilers_and_libraries_2018.0.128/linux/bin/iccvars.sh intel64 
source /opt/intel/compilers_and_libraries_2018.0.128/linux/bin/ifortvars.sh intel64 
source /opt/intel/compilers_and_libraries/linux/mkl/bin/mklvars.sh intel64
source  /opt/intel/impi/2018.0.128/bin64/mpivars.sh

#####计算#####
cd $PBS_O_WORKDIR
#进入工作目录
EXEC=/home/cndaqiang/soft/vasp.5.4.1/build/std/vasp
#vasp
NP=`cat $PBS_NODEFILE | wc -l`
#wc -l 统计行数
#NP为 mpirun运行的np(number of processes,),核数
NN=`cat $PBS_NODEFILE | sort | uniq | tee /tmp/cqiang_nodes.$$ | wc -l`
#sort排序,uniq去除重复,tee重定向输出,$$代表shell本身的PID
#NN为节点数
cat $PBS_NODEFILE > /tmp/cqiang_nodefile.$$
#存储节点进程信息
mpirun -genv I_MPI_DEVICE rdssm -machinefile /tmp/cqiang_nodefile.$$ -n $NP $EXEC
# -machinefile :指定加入运算的资源
# -nolocal :本机器不参与运算
# -np :处理器数量

rm -rf /tmp/cqiang_nodefile.$$
rm -rf /tmp/cqiang_nodes.$$
```
将脚本放于vasp输入文件同一目录
```
qsub <脚本名>
```
即可运行







\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
