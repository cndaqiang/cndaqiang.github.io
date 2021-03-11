---
layout: post
title:  "[已放弃]<s>单机ubuntu编译安装PBS torque</s>"
date:   2018-01-11 10:00:00 +0800
categories: Linux
tags: pbs 集群
author: cndaqiang
mathjax: true
---
* content
{:toc}
# 2020-02-24: Ubuntu建议安装Slurm作业系统 <br> ->[Ubuntu 18.04/Mint 19 单机安装Slurm](/2020/01/24/slurm/)
尝试在组里的服务器运行vasp，需要使用提交任务脚本，不允许在登陆节点直接运算，师兄给了一个pbs的脚本。<br>
还是现在自己服务器上安装pbs看看<br>
**建议ubuntu还是使用apt安装吧**，放弃编译，直接编译后，很多运行脚本的语法都是为RedHat/Centos编写的。<br>
想到组里的服务器是RedHat，把我的服务器由ubuntu重装为centos<br>




# 放弃尝试，仅供参考
# 参考
[[转载]PBS！！](http://blog.sciencenet.cn/blog-478347-395684.html)
<br>[“cannot find -lssl; cannot find -lcrypto” when installing mysql-python using mariaDB library](https://stackoverflow.com/questions/25979525/cannot-find-lssl-cannot-find-lcrypto-when-installing-mysql-python-using-mar)
<br>[How to Install boost on Ubuntu?
](https://stackoverflow.com/questions/12578499/how-to-install-boost-on-ubuntu/12578564#12578564?newreg=1035048611464711a0444542ec818276)
<br>[PBS Torque 5.1.3安装配置](http://blog.51cto.com/rabbitjian/1862678)
<br>[CentOS下torque集群配置（一）-torque安装与配置](http://blog.csdn.net/dream_angel_z/article/details/44225669)
<br>[shell编程。ubuntu下的shell出错，提示第4行function: not found，还有第七行的 } 有错。高手教一下](https://zhidao.baidu.com/question/328528962.html)
<br>[RED5 INIT SCRIPT FOR UBUNTU](https://www.panda-os.com/blog/2013/06/red5-init-script-for-ubuntu/)


# 集群系统
集群系统就好像一台服务器或者PC，集群资源由实现如下几个部分：
- 资源管理器
<br>为了确保分配给作业合适的资源，集群资源管理需要维护一个数据库。这个数据库记录了集群系统中各种资源的属性和状态、所有用户提交的请求和正在运行的作业。
- 作业调度策略管理器
<br>策略管理器根据资源管理器得到各个结点上的资源状况和系统的作业信息生成一个优先级列表。这个列表告诉资源管理器何时在哪些结点上运行哪个作业

>PBS作业分配的调度器 （scheduler），其主要任务是分配批作业计算任务到现有的计算资源上。 PBS的目前包括openPBS，PBS Pro和Torque三个主要分支。 其中OpenPBS是最早的PBS系统，目前已经没有太多后续开发，PBS pro是PBS的商业版本，功能最为丰富。Torque是Clustering公司接过了OpenPBS，并给与后续支持的一个开源版本。

>Maui作业调度器,想象为PBS中的一个插入部件。它采用积极的调度策略优化资源的利用和减少作业的响应时间


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


# 安装
此次进行单机安装pbs，即管理节点，计算节点，作业节点都在一个服务器上,不安装Maui

## 环境
ubuntu 16.04
<br> win10 bash
<br>不得不说，单核的云服务器比我笔记本上的win10 bash快的不止一点
## 下载
安装包下载地址[Torque Resource Manager](http://www.adaptivecomputing.com/products/open-source/torque/)
```
wget http://wpfilebase.s3.amazonaws.com/torque/torque-6.1.1.1.tar.gz
tar xzvf torque-6.1.1.1.tar.gz
cd torque-6.1.1.1.tar.gz
```
## 依赖
在编译过程中提示错误,安装下列依赖解决
```
sudo apt install libxml2-dev
sudo apt install zlib1g-dev
sudo apt install libboost-all-dev
sudo apt install libssl-dev
```




## 编译安装(管理节点)
编译安装
```
./configure  --with-default-server=master
make
sudo make install
```

编译安装后，在当前文件夹下有`torque.setup`文件，用于之后生成各节点软件包
<br>执行程序默认安装在`/usr/local/sbin`,`/usr/local/bin`目录
<br>也可通过`--prefix=安装目录`改变安装目录,安装后需要添加PATH,添加PATH方法见[Linux常用命令学习](https://cndaqiang.github.io/2017/09/10/linux-command/)
<br>`ls /usr/local/sbin`可以看到相关文件，主要
- pbs_mom 
<br>PBS MOM守护进程， 负责监控本机并执行作业，位于所有计算节点上
- pbs_sched
<br>PBS调度守护进程，负责调度作业，位于服务节点上
- pbs_server
<br>PBS服务守护进程，负责接收作业提交，位于服务节点上

也可将上述命令利用系统服务来启动(**不适用于ubuntu**,原因如下)
```
sudo cp contrib/init.d/{pbs_{server,sched,mom},trqauthd} /etc/init.d/
```
之后可以使用
```
sudo /etc/init.d/pbs_server stop|start|restart
```
来使用
<br>
**然而非常悲剧的是**`/etc/init.d/pbs_server`中使用了`success`和`failure`命令， **This init Script is written for CentOS and not for Ubuntu.**


## 初始化(此步有错误提示,详见下)
```
sudo ./torque.setup 用户名
```
错误提示
```
cqiang@DESKTOP-BMKQE7V:~/soft/torque/torque-6.1.1.1$ sudo ./torque.setup root
./torque.setup: 8: ./torque.setup: function: not found
```
通过修改`./torque.setup`文件,将开头的`#!/bin/sh`修改为`#!/bin/bash`,再运行`sudo ./torque.setup 用户名`就不报错了
```
chmod +w ./torque.setup
vi ./torque.setup
```
想卸载可使用下列命令
```
sudo make uninstall
```

## 打包，生成个节点安装包
使用普通用户打包，不要使用root用户或sudo
<br>使用普通用户是为了，拷贝到其他机器上可以直接运行
```
ubuntu@VM-10-194-ubuntu:~/torque_install/torque-6.1.1.1$  make packages
```
得到各节点所需要的，安装程序
```
torque-package-clients-linux-x86_64.sh
torque-package-devel-linux-x86_64.sh
torque-package-doc-linux-x86_64.sh
torque-package-mom-linux-x86_64.sh
torque-package-server-linux-x86_64.sh
```
将其他节点需要的程序传过去即可，此次我们单机安装，无需传输


## 单机安装节点程序
单机作为管理,计算,交作业节点，需安装client,server,mom包
```
sudo ./torque-package-server-linux-x86_64.sh --install
sudo ./torque-package-clients-linux-x86_64.sh --install
sudo ./torque-package-mom-linux-x86_64.sh --install
```








\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
