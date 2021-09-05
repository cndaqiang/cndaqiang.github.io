---
layout: post
title:  "Ubuntu使用vsftpd搭建ftp服务器"
date:   2017-09-27 12:00:00 +0800
categories: Linux
tags:  ubuntu vsftpd ftp
author: cndaqiang
mathjax: true
---
* content
{:toc}

## 这篇文章写的太乱了，不想更新了，如果仅想用的话，看[Ubuntu 16.04 使用vsftpd搭建ftp服务器](/2018/11/17/ubuntu-vsftp2/)



## 参考
[Ubuntu 14.04 配置vsftpd实现FTP服务器 - 通过FTP连接AWS](http://www.jianshu.com/p/9ea295f9e513)

[linux 更改文件所属用户及用户组](http://blog.csdn.net/zhouleiblog/article/details/9325913)

[linux修改文件的拥有者及组](http://blog.163.com/yanenshun@126/blog/static/128388169201203011157308/)

[chmod - 维基百科，自由的百科全书](https://zh.wikipedia.org/zh-hans/Chmod)
## 环境
 Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-53-generic x86_64)
## 建议
安装过程中发现连接不上，用FileZilla连接，看有没有什么异常消息，再搜索解决
更改ftp目录后，建议关闭FileZilla软件后再打开重新连接ftp
## 安装
```
apt-get update
apt-get install vsftpd
```
## 配置
### 配置文件
配置文件在/etc/vsftpd.conf，参照下面的配置文件语法，配置ftp服务器，如果配置文件中没有语法里面的内容，直接添加即可

### 配置文件语法

以下配置转载自[作者：Stinson Ubuntu 14.04 配置vsftpd实现FTP服务器 - 通过FTP连接AWS](http://www.jianshu.com/p/9ea295f9e513)

```
listen=<YES/NO> :设置为YES时vsftpd以独立运行方式启动，设置为NO时以xinetd方式启动（xinetd是管理守护进程的，将服务集中管理，可以减少大量服务的资源消耗）
listen_port=<port> :设置控制连接的监听端口号，默认为21
listen_address=<ip address> :将在绑定到指定IP地址运行，适合多网卡
connect_from_port_20=<YES/NO> :若为YES，则强迫FTP－DATA的数据传送使用port 20，默认YES
pasv_enable=<YES/NO> :是否使用被动模式的数据连接，如果客户机在防火墙后，请开启为YES
pasv_min_port=<n>
pasv_max_port=<m> :设置被动模式后的数据连接端口范围在n和m之间,建议为50000－60000端口
pasv_address=你的访问IP（服务器外网IP）
message_file=<filename> :设置使用者进入某个目录时显示的文件内容，默认为 .message
dirmessage_enable=<YES/NO> :设置使用者进入某个目录时是否显示由message_file指定的文件内容
ftpd_banner=<message> :设置用户连接服务器后的显示信息，就是欢迎信息
banner_file=<filename> :设置用户连接服务器后的显示信息存放在指定的filename文件中
connect_timeout=<n> :如果客户机连接服务器超过N秒，则强制断线，默认60
accept_timeout=<n> :当使用者以被动模式进行数据传输时，服务器发出passive port指令等待客户机超过N秒，则强制断线，默认60
accept_connection_timeout=<n> :设置空闲的数据连接在N秒后中断，默认120
data_connection_timeout=<n> : 设置空闲的用户会话在N秒后中断，默认300
max_clients=<n> : 在独立启动时限制服务器的连接数，0表示无限制
max_per_ip=<n> :在独立启动时限制客户机每IP的连接数，0表示无限制（不知道是否跟多线程下载有没干系）
local_enable=<YES/NO> :设置是否支持本地用户帐号访问
guest_enable=<YES/NO> :设置是否支持虚拟用户帐号访问
write_enable=<YES/NO> :是否开放本地用户的写权限
local_umask=<nnn> :设置本地用户上传的文件的生成掩码，默认为077
local_max_rate<n> :设置本地用户最大的传输速率，单位为bytes/sec，值为0表示不限制
local_root=<file> :设置本地用户登陆后的目录，默认为本地用户的主目录
chroot_local_user=<YES/NO> :当为YES时，所有本地用户可以执行chroot
chroot_list_enable=<YES/NO> 
chroot_list_file=<filename> :当chroot_local_user=NO 且 chroot_list_enable=YES时，只有filename文件指定的用户可以执行chroot
anonymous_enable=<YES/NO> :设置是否支持匿名用户访问
anon_max_rate=<n> :设置匿名用户的最大传输速率，单位为B/s，值为0表示不限制
anon_world_readable_only=<YES/NO> 是否开放匿名用户的浏览权限
anon_upload_enable=<YES/NO> 设置是否允许匿名用户上传
anon_mkdir_write_enable=<YES/NO> :设置是否允许匿名用户创建目录
anon_other_write_enable=<YES/NO> :设置是否允许匿名用户其他的写权限（注意，这个在安全上比较重要，一般不建议开，不过关闭会不支持续传）
anon_umask=<nnn> :设置匿名用户上传的文件的生成掩码，默认为077
```
### 主动模式和被动模式
>FTP是基于TCP的服务，使用2个端口，一个数据端口和一个命令端口（也可叫做控制端口）。通常来说这两个端口是21（命令端口）和20（数据端口）。但FTP工作方式的不同，数据端口并不总是20。这就是主动与被动FTP的最大不同之处。

> - 主动模式：数据连接上，服务端从20端口去连接客户端大于1024的端口
命令连接：客户端 （>1024端口） -> 服务器 21端口 
数据连接：客户端 （>1024端口） <- 服务器 20端口
优势：主动FTP对FTP服务器的管理有利，但对客户端的管理不利。因为FTP服务器企图与客户端的高位随机端口建立连接，而这个端口很有可能被客户端的防火墙阻塞掉。

>- 被动模式：数据连接上，客户端从大于1024端口去连接服务端大于1024的端口
命令连接：客户端 （>1024端口） -> 服务器 21端
数据连接：客户端 （>1024端口） -> 服务器 （>1024端口）
优势：被动FTP对FTP客户端的管理有利，但对服务器端的管理不利。因为客户端要与服务器端建立两个连接，其中一个连到一个高位随机端口，而这个端口很有可能被服务器端的防火墙阻塞掉。


## 案例
**是修改vsftpd.conf**文件，不是新建vsftps.conf

填入下面内容
### 一个用户对某目录具有写权限，特定端口
#### 主动模式
```
# 不支持匿名用户访问
anonymous_enable=NO
#监听端口1224
listen_port=1224;
#支持本地用户帐号访问
local_enable=YES
#是否开放本地用户的写权限
write_enable=YES
#本地用户登陆后的目录
local_root=/home/ftp
#[可选]限制用户只能访问ftp根目录，不然用户可以访问服务器根目录
chroot_local_user=YES
```
#### 被动模式
```
# 不支持匿名用户访问
anonymous_enable=NO
#监听端口1224
listen_port=1224;
#被动端口在1250-1260
pasv_min_port=1250
pasv_max_port=1260
#服务器ip
pasv_address=服务器ip
#支持本地用户帐号访问
local_enable=YES
#是否开放本地用户的写权限
write_enable=YES
#本地用户登陆后的目录
local_root=/home/ftp
#[可选]限制用户只能访问ftp根目录，不然用户可以访问服务器根目录
chroot_local_user=YES
```
**注:一些vps设置了安全组，还需要在控制面版里允许，监听端口和被动端口通过，类似在路由器下面没有公网的ftp服务器要设置防火墙端口转发**
#### 创建目录
```
#创建ftp根目录
mkdir /home/ftp
#必须去掉根目录的可读权限，不然连接时报错500 OOPS: vsftpd: refusing to run with writable root inside chroot()==
chmod a-w /home/ftp
```
#### 创建用户与读写权限
添加本地用户和设置密码

```
 useradd -d 用户家目录  -M 用户名
 passwd 用户名
```
例家目录为/home/ftp/ftptest，用户名为ftptest
理解，这就是ubuntu本地用户的创建过程，家目录是什么并不影响ftp（只不过不创建家目录，无法登陆ftp，家目录属于谁却无所谓），连接ftp时会用本地账户登陆然后自动跳转到ftp根目录，家目录就是家目录而已，**能够写入不仅需要ftp开启写入功能，还要看该linux用户是否拥有对该目录的写权限**
创建家目录
```
mkdir /home/ftp/ftptest
```

如果需要可将家目录拥有者设为ftptest
修改文件(夹)用户组方法
```
chown 用户名 文件(夹) //修改文件拥有者
chgrp 用户组名 文件(夹) //修改拥有者组 
chown 用户名:用户组名 文件(夹) // 使用 chown 一次性修改拥有者及组 
```
也可在需要的目录下新建文件夹，并将拥有者权限赋给ftptest，或通过chmod设置该目录不同用户的权限
chomd语法
```
chmod 数字1数字2数字3 文件(夹)
```
数字1数字2数字3 分别为拥有者用户，拥有者用户组其他成员，其他人员拥有的权限，数字值为下列需要权限代表的数字相加
- r读 4
- w写 2
- x执行 1
- \- 0
例`chmod 777 test `，所有人对test都可读可写可执行,其他方法，搜索chmod即可

**一定要设置好权限，例如在discuz设置远程附件时
![](http://upload-images.jianshu.io/upload_images/4575564-3770150f1e0505ad.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
，所以附件目录一定要设置在ftp账户目录的家目录里面**
#### 重启
```
service vsftpd restart
```
#### 登陆遇到530错误
530 login incorrect==错误，解决方式如下：
```
vi /etc/pam.d/vsftpd
```
注释掉
```
#auth    required pam_shells.so
```
重启
```
service vsftpd restart
```
#### 其他问题
- FileZilla可以访问，winscp访问报错无法列出根目录，windows10资源管理器访问也报错
- 刚开始被动模式还正常，后收到“服务器发回了不可路由的地址”，网上都让客户端改成主动模式，可是我希望的就是被动模式啊，防火墙全开了，安全组也全开了,还是不行，怀疑是vps服务商的某些限制

### 可访问所有目录的管理员
```
#限制用户只能访问ftp根目录
chroot_local_user=YES
#开启不受限制的用户列表
chroot_list_enable=YES
#不受限制用户列表
chroot_list_file=/etc/vsftpd.chroot_list
```



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
