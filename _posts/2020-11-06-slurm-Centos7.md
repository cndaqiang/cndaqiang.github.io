---
layout: post
title:  "Centos7集群上搭建slurm作业管理系统"
date:   2020-11-06 22:10:00 +0800
categories: Linux Slurm Centos
tags:  Slurm 
author: cndaqiang
mathjax: true
---
* content
{:toc}



## 参考

[Ubuntu 18.04/Mint 19 单机安装Slurm](/2020/02/24/slurm/)

[从0搭建Centos7 计算集群](/2019/09/19/Centos7-CC19/)

[slurm安装配置](http://zhangcheng.fun/2018/06/14/slurm%E5%AE%89%E8%A3%85%E9%85%8D%E7%BD%AE/)


## 注意
- **`munge`完全可以使用默认的munge账户执行,不用像其他教程非要用slurm去启动munge**


## 环境
按照[从0搭建Centos7 计算集群](/2019/09/19/Centos7-CC19/)搭建好NIS,**安装EPEL仓库,关闭Selinux,NFS共享(单机时不需要)**
```
yum -y install python
yum -y install python3
yum -y install epel-release
yum -y install gtk2
yum -y install gtk2-devel
yum -y install munge
yum -y install munge-devel
yum -y install polkit
systemctl start polkit
```
把`/usr/local`目录添加到环境变量,后期slurm安装和配置都在这里,后面如果指定slurm安装位置则更改此处
```
mkdir /usr/local/etc
echo "
#slurm
USRLOCAL=/usr/local
export LD_LIBRARY_PATH=\${USRLOCAL}/lib:\$LD_LIBRARY_PATH
export LIBRARY_PATH=\${USRLOCAL}/lib:\$LIBRARY_PATH
export LIBRARY_PATH=\${USRLOCAL}/lib64:\$LIBRARY_PATH
export C_INCLUDE_PATH=\${USRLOCAL}/include:\$C_INCLUDE_PATH
export PATH=\${USRLOCAL}/bin:\$PATH
export PATH=\${USRLOCAL}/sbin:\$PATH
" >> /etc/profile
```

## 安装

### munge
生成密钥,并复制到所有节点
```
[root@master source]# /usr/sbin/create-munge-key 
Generating a pseudo-random key using /dev/urandom completed.
[root@master source]# scp /etc/munge/munge.key node8:/etc/munge
```
创建运行目录
```
chown munge:munge /etc/munge
chown munge:munge /var/run/munge
chown munge:munge /var/lib/munge
chown munge:munge /var/log/munge
chown munge:munge /etc/munge/munge.key
```
配置服务
```
vi /usr/lib/systemd/system/munge.service
```
内容
```
[Unit]
Description=MUNGE authentication service 
Documentation=man:munged(8)
After=network.target
After=syslog.target
After=time-sync.target

[Service]
Type=forking
ExecStart=/usr/sbin/munged --syslog
PIDFile=/var/run/munge/munged.pid
User=munge
Group=munge
Restart=on-abort
ExecStartPre=-/usr/bin/mkdir -m 0755 -p /var/log/munge
ExecStartPre=-/usr/bin/chown -R munge:munge /var/log/munge
ExecStartPre=-/usr/bin/mkdir -m 0755 -p /var/run/munge
ExecStartPre=-/usr/bin/chown -R munge:munge /var/run/munge

[Install]
WantedBy=multi-user.target
```
生效
```
systemctl daemon-reload
```
启用
```
[root@master ~]# systemctl start munge
[root@master ~]# systemctl status munge
[root@client01 ~]# systemctl status munge
● munge.service - MUNGE authentication service
   Loaded: loaded (/usr/lib/systemd/system/munge.service; enabled; vendor preset: disabled)
   Active: active (running) since Sat 2020-11-07 11:58:51 CST; 10min ago
     Docs: man:munged(8)
  Process: 4684 ExecStart=/usr/sbin/munged --syslog (code=exited, status=0/SUCCESS)
  Process: 4660 ExecStartPre=/usr/bin/chown -R munge:munge /var/run/munge (code=exited, status=0/SUCCESS)
  Process: 4609 ExecStartPre=/usr/bin/mkdir -m 0755 -p /var/run/munge (code=exited, status=0/SUCCESS)
  Process: 4588 ExecStartPre=/usr/bin/chown -R munge:munge /var/log/munge (code=exited, status=1/FAILURE)
  Process: 4546 ExecStartPre=/usr/bin/mkdir -m 0755 -p /var/log/munge (code=exited, status=0/SUCCESS)
 Main PID: 4724 (munged)
    Tasks: 4
   Memory: 672.0K
   CGroup: /system.slice/munge.service
           └─4724 /usr/sbin/munged --syslog

Nov 07 11:58:51 client01 munged[4724]: Found 3 users with supplementary groups in 0.003 seconds
```


### 设置slurm账户权限
```
[root@master source]# useradd slurm
[root@master source]# passwd slurm
#NIS同步更新账户
[root@master source]# make -C /var/yp
```
slurm运行目录
```
rm -rf  /var/spool/slurm-llnl
mkdir /var/spool/slurm-llnl
chown -R slurm.slurm /var/spool/slurm-llnl
rm -rf /var/run/slurm-llnl/
mkdir /var/run/slurm-llnl/
chown -R slurm.slurm /var/run/slurm-llnl/
```

### 编译安装slurm
```
cd /opt/source/
#从https://download.schedmd.com/slurm/下载最新版即可
wget https://download.schedmd.com/slurm/slurm-20.11.0-0rc1.tar.bz2
tar -jxvf slurm-20.11.0-0rc1.tar.bz2 
cd slurm-20.11.0-0rc1/
./configure #默认安装到/usr/local
make -j90 #注意需要python3
make install
```
复制系统服务
```
cp etc/{slurmctld.service,slurmdbd.service,slurmd.service} /usr/lib/systemd/system
```


### 修改配置文件
根据默认设置
```
[root@master slurm-20.11.0-0rc1]# cat /usr/lib/systemd/system/slurmctld.service 
[Unit]
Description=Slurm controller daemon
After=network.target munge.service
ConditionPathExists=/usr/local/etc/slurm.conf

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/slurmctld
ExecStart=/usr/local/sbin/slurmctld -D $SLURMCTLD_OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536


[Install]
WantedBy=multi-user.target
[root@master slurm-20.11.0-0rc1]# cat /usr/lib/systemd/system/slurmd.service 
[Unit]
Description=Slurm node daemon
After=munge.service network.target remote-fs.target
#ConditionPathExists=/usr/local/etc/slurm.conf

[Service]
Type=simple
EnvironmentFile=-/etc/sysconfig/slurmd
ExecStart=/usr/local/sbin/slurmd -D $SLURMD_OPTIONS
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
LimitNOFILE=131072
LimitMEMLOCK=infinity
LimitSTACK=infinity
Delegate=yes


[Install]
WantedBy=multi-user.target
```
确定配置文件是`/usr/local/etc/slurm.conf`
通过在线网址[https://slurm.schedmd.com/configurator.html](https://slurm.schedmd.com/configurator.html)<br>
或者`sz doc/html/configurator.html`本地浏览器打开配置,<br>
将生成的配置文件填入`/usr/local/etc/slurm.conf`<br>
注意事项见[Ubuntu 18.04/Mint 19 单机安装Slurm](/2020/02/24/slurm/),下面是示例文件
```bash
cat << EOF > /usr/local/etc/slurm.conf
# slurm.conf file generated by configurator.html.
# Put this file on all nodes of your cluster.
# See the slurm.conf man page for more information.
#
SlurmctldHost=master
#SlurmctldHost=
#
#DisableRootJobs=NO
#EnforcePartLimits=NO
#Epilog=
#EpilogSlurmctld=
#FirstJobId=1
#MaxJobId=999999
#GresTypes=
#GroupUpdateForce=0
#GroupUpdateTime=600
#JobFileAppend=0
#JobRequeue=1
#JobSubmitPlugins=1
#KillOnBadExit=0
#LaunchType=launch/slurm
#Licenses=foo*4,bar
#MailProg=/bin/mail
#MaxJobCount=5000
#MaxStepCount=40000
#MaxTasksPerNode=128
MpiDefault=none
#MpiParams=ports=#-#
#PluginDir=
#PlugStackConfig=
#PrivateData=jobs
ProctrackType=proctrack/pgid
#Prolog=
#PrologFlags=
#PrologSlurmctld=
#PropagatePrioProcess=0
#PropagateResourceLimits=
#PropagateResourceLimitsExcept=
#RebootProgram=
ReturnToService=1
SlurmctldPidFile=/var/spool/slurm-llnl/slurmctld.pid
SlurmctldPort=6817
SlurmdPidFile=/var/spool/slurm-llnl/slurmd.pid
SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurm-llnl
SlurmUser=slurm
#SlurmdUser=root
#SrunEpilog=
#SrunProlog=
StateSaveLocation=/var/spool/slurm-llnl
SwitchType=switch/none
#TaskEpilog=
TaskPlugin=task/affinity
#TaskProlog=
#TopologyPlugin=topology/tree
#TmpFS=/tmp
#TrackWCKey=no
#TreeWidth=
#UnkillableStepProgram=
#UsePAM=0
#
#
# TIMERS
#BatchStartTimeout=10
#CompleteWait=0
#EpilogMsgTime=2000
#GetEnvTimeout=2
#HealthCheckInterval=0
#HealthCheckProgram=
InactiveLimit=0
KillWait=30
#MessageTimeout=10
#ResvOverRun=0
MinJobAge=300
#OverTimeLimit=0
SlurmctldTimeout=120
SlurmdTimeout=300
#UnkillableStepTimeout=60
#VSizeFactor=0
Waittime=0
#
#
# SCHEDULING
#DefMemPerCPU=0
#MaxMemPerCPU=0
#SchedulerTimeSlice=30
SchedulerType=sched/backfill
SelectType=select/cons_tres
SelectTypeParameters=CR_Core
#
#
# JOB PRIORITY
#PriorityFlags=
#PriorityType=priority/basic
#PriorityDecayHalfLife=
#PriorityCalcPeriod=
#PriorityFavorSmall=
#PriorityMaxAge=
#PriorityUsageResetPeriod=
#PriorityWeightAge=
#PriorityWeightFairshare=
#PriorityWeightJobSize=
#PriorityWeightPartition=
#PriorityWeightQOS=
#
#
# LOGGING AND ACCOUNTING
#AccountingStorageEnforce=0
#AccountingStorageHost=
#AccountingStoragePass=
#AccountingStoragePort=
AccountingStorageType=accounting_storage/none
#AccountingStorageUser=
AccountingStoreJobComment=YES
ClusterName=cluster
#DebugFlags=
#JobCompHost=
#JobCompLoc=
#JobCompPass=
#JobCompPort=
JobCompType=jobcomp/none
#JobCompUser=
#JobContainerType=job_container/none
JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/none
SlurmctldDebug=info
#SlurmctldLogFile=
SlurmdDebug=info
#SlurmdLogFile=
#SlurmSchedLogFile=
#SlurmSchedLogLevel=
#
#
# POWER SAVE SUPPORT FOR IDLE NODES (optional)
#SuspendProgram=
#ResumeProgram=
#SuspendTimeout=
#ResumeTimeout=
#ResumeRate=
#SuspendExcNodes=
#SuspendExcParts=
#SuspendRate=
#SuspendTime=
#
#
# COMPUTE NODES
NodeName=master,client01 CPUs=96 State=UNKNOWN
PartitionName=long Nodes=master,client01 Default=YES MaxTime=INFINITE State=UP
EOF
```
设置权限
```
chown slurm:slurm /usr/local/etc/slurm.conf
```

### 启动

```
systemctl start slurmd
systemctl enable slurmd
systemctl start slurmctld
systemctl enable slurmctld
```
查看状态正常
```
[root@master slurm-20.11.0-0rc1]# systemctl status slurmctld
● slurmctld.service - Slurm controller daemon
   Loaded: loaded (/usr/lib/systemd/system/slurmctld.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2020-11-06 22:41:46 CST; 8s ago
 Main PID: 101889 (slurmctld)
   CGroup: /system.slice/slurmctld.service
           └─101889 /usr/local/sbin/slurmctld -D

Nov 06 22:41:46 master systemd[1]: Started Slurm controller daemon.
[root@master slurm-20.11.0-0rc1]# systemctl status slurmd
● slurmd.service - Slurm node daemon
   Loaded: loaded (/usr/lib/systemd/system/slurmd.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2020-11-06 22:41:36 CST; 20s ago
 Main PID: 101848 (slurmd)
   CGroup: /system.slice/slurmd.service
           └─101848 /usr/local/sbin/slurmd -D

Nov 06 22:41:36 master systemd[1]: Started Slurm node daemon.
```
查看上线信息,因为当前只配置了master节点，仅有一个上线
```
[root@master ~]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
long*        up   infinite      1   idle master
```
提交作业
```
[cndaqiang@master NVE-TDDFT-4000K_156_78x2_input]$ sbatch slurm.sh 
Submitted batch job 4
[cndaqiang@master NVE-TDDFT-4000K_156_78x2_input]$ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON) 
                 4      long      ECD cndaqian  R       0:04      1 master 
```

## 开始多节点配置
登陆计算节点client01
```
[cndaqiang@master ~]$ ssh root@node8
root@node8's password: 
Last login: Fri Nov  6 15:26:55 2020
[root@client01 ~]# 
```
配置和前面的管理节点完全相同，**只需启用`slurmd`服务**
```
[root@client01 slurm-20.11.0-0rc1]# systemctl start slurmd
[root@client01 slurm-20.11.0-0rc1]# systemctl status slurmd
● slurmd.service - Slurm node daemon
   Loaded: loaded (/usr/lib/systemd/system/slurmd.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2020-11-06 22:58:01 CST; 3s ago
 Main PID: 19608 (slurmd)
    Tasks: 1
   Memory: 1.1M
   CGroup: /system.slice/slurmd.service
           └─19608 /usr/local/sbin/slurmd -D

Nov 06 22:58:01 client01 systemd[1]: Started Slurm node daemon.
[root@client01 slurm-20.11.0-0rc1]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
long*        up   infinite      1  drain master
long*        up   infinite      1   idle client01
```

### 测试
提交双节点作业
```
[cndaqiang@master NVE-TDDFT-4000K_156_78x2_input]$ sbatch slurm.sh 
Submitted batch job 11
[cndaqiang@master NVE-TDDFT-4000K_156_78x2_input]$ squeue
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON) 
                11      long      ECD cndaqian  R       0:39      2 client01,master 
```
![](/uploads/2020/10/192slurm.png)



## 错误处理
### 状态为`drain`
```
[root@master ~]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
long*        up   infinite      1  drain master
long*        up   infinite      1   idle client01
```
解决
```
scontrol update NodeName=master State=RESUME
```
如果还报错，安装参考资料[SLURM 节点状态总是drained问题](https://blog.csdn.net/kongxx/article/details/48193333)方案
```
[root@master ~]# scontrol update NodeName=master State=DOWN Reason=cndaqiang
[root@master ~]# systemctl restart slurmd
[root@master ~]# scontrol update NodeName=master State=RESUME
[root@master ~]# sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
long*        up   infinite      2   idle client01,master
```
~~重启后节点都是down，添加到/etc/rc.local,暂时原因未知~~
```
#scontrol update NodeName=master State=RESUME
#scontrol update NodeName=client01 State=RESUME
```
### 状态为`down`,计算节点的`slurmd`服务正常
计算节点刚开机，还没连上管理节点(等待即可)或者其他原因，均可以
```
scontrol update NodeName=client01 State=RESUME
```

### 状态为`unk*`
```
[cndaqiang@master ~]$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
long*        up   infinite      1   unk* client01
long*        up   infinite      1   idle master
```
登陆计算节点查看
```
[root@client01 cndaqiang]# systemctl status slurmd
● slurmd.service - Slurm node daemon
   Loaded: loaded (/usr/lib/systemd/system/slurmd.service; disabled; vendor preset: disabled)
   Active: inactive (dead)
```
因为默认没有启动`slurmd`服务
```
[root@client01 cndaqiang]# systemctl enable  slurmd
Created symlink from /etc/systemd/system/multi-user.target.wants/slurmd.service to /usr/lib/systemd/system/slurmd.service.
[root@client01 cndaqiang]# systemctl start  slurmd
```
再查看
```
[cndaqiang@master ~]$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
long*        up   infinite      2   idle client01,master
```
### 状态`idle*`
```
[cndaqiang@client01 ~]$ sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
long*        up   infinite      1  idle* client01
long*        up   infinite      1   idle master
```
登陆计算节点，重启slurm服务

### `slurm_update error: Invalid user id`
使用`root`或`slurm`执行slurm管理命令


### slurm不自动启动
干脆使用开机脚本
```
systemctl disable slurmd
echo 'systemctl restart slurmd' >> /etc/rc.local
echo 'sleep 5' >> /etc/rc.local
echo 'scontrol update NodeName=client01 State=RESUME' >> /etc/rc.local

```

### 重启脚本
```
#下面仅在管理节点
/bin/systemctl restart slurmctld
scontrol update NodeName=master State=RESUME
scontrol update NodeName=client01 State=RESUME
```
