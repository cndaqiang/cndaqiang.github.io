---
layout: post
title:  "ubuntu 16.04/18.04 编译 可跳过散列检测的 transmission-2.92"
date:   2018-11-17 12:53:00 +0800
categories: OpenWrt
tags: openwrt ubuntu nas
author: cndaqiang
mathjax: true
---
* content
{:toc}

路由器的usb2.0挂pt太慢了，为充分利用千兆网，换了千兆小主机挂pt了










## 参考
[superlukia/transmission-2.92_skiphashcheck](https://github.com/superlukia/transmission-2.92_skiphashcheck)<br>
[源码编译安装Transmission 2.93（debian 7)](https://www.jianshu.com/p/551ed5464e81)<br>
[Ubuntu 16.04 and transmission 2.92](https://forum.odroid.com/viewtopic.php?t=23992)<br>
[ubuntu开放指定端口](https://www.jianshu.com/p/2ec5d16db02b)<br>
[Bug 1468077 - Transmission-gtk: Update to support openssl 1.1 (rather than the compat package)](https://bugzilla.redhat.com/show_bug.cgi?id=1468077)<br>
得益于大佬[superlukia](https://github.com/superlukia)对transmission的修改，可以跳过transmission的散列检测

## 环境
Ubuntu 16.04.5 LTS<br>
小主机:
- Intel(R) Atom(TM) CPU N270   @ 1.60GHz
- 内存： 2G ddr2

## 编译
### 依赖
```
sudo apt update
sudo apt-get -y  install libcurl4-openssl-dev
sudo apt-get -y  install libevent-dev
sudo apt-get -y  install zlib1g
sudo apt-get -y  install zlib1g.dev
sudo apt-get -y  install libssh-dev
sudo apt-get -y  install intltool
sudo apt-get -y  install libssh-dev
```
### 编译
下载
```
wget https://github.com/cndaqiang/transmission-2.92_skiphashcheck/archive/master.zip
unzip master.zip
cd transmission-2.92_skiphashcheck-master/
```
检查
```
./configure
```
编译，安装
```
make
sudo su
make install
```

**Ubuntu 18.04 由于openssl版本为1.1**,transmission-2.9x支持到1.0,直接编译会报错
```
crypto-utils-openssl.c: In function ‘tr_dh_new’:
crypto-utils-openssl.c:244:29: error: dereferencing pointer to incomplete type ‘DH {aka struct dh_st}’
   if (!check_pointer (handle->p = BN_bin2bn (prime_num, prime_num_length, NULL)) ||
                             ^
crypto-utils-openssl.c:92:56: note: in definition of macro ‘check_pointer’
 #define check_pointer(pointer) check_openssl_pointer ((pointer), __FILE__, __LINE__)
                                                        ^~~~~~~
Makefile:1249: recipe for target 'crypto-utils-openssl.o' failed
make[1]: *** [crypto-utils-openssl.o] Error 1
make[1]: Leaving directory '/home/oem/test/transmission-2.92_skiphashcheck-master/libtransmission'
Makefile:507: recipe for target 'all-recursive' failed
make: *** [all-recursive] Error 1
```
下载[0001-transmission-build-against-openssl-1.1.0.patch](/web/file/2019/0001-transmission-build-against-openssl-1.1.0.patch),传到编译目录
```
oem@boy:~/test/transmission-2.92_skiphashcheck-master$ patch -p0 < 0001-transmission-build-against-openssl-1.1.0.patch
can't find file to patch at input line 15
Perhaps you used the wrong -p or --strip option?
The text leading up to this was:
--------------------------
|From 1108498d2a1a9c47931f41b04f248616b29383d6 Mon Sep 17 00:00:00 2001
|From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
|Date: Mon, 5 Sep 2016 21:49:07 +0000
|Subject: [PATCH] transmission: build against openssl 1.1.0
|
|Signed-off-by: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
|---
| libtransmission/crypto-utils-openssl.c | 73 ++++++++++++++++++++++++++++++++--
| 1 file changed, 69 insertions(+), 4 deletions(-)
|
|diff --git a/libtransmission/crypto-utils-openssl.c b/libtransmission/crypto-utils-openssl.c
|index 77a628bea..16a37b205 100644
|--- a/libtransmission/crypto-utils-openssl.c
|+++ b/libtransmission/crypto-utils-openssl.c
--------------------------
File to patch: libtransmission/crypto-utils-openssl.c
patching file libtransmission/crypto-utils-openssl.c
```
之后就可以make了

### 配置
#### 使用`systemctl`管理程序
```
vi /etc/systemd/system/transmission.service
```
填入
```
[Unit]
Description=Transmission BitTorrent Daemon
After=network.target

[Service]
User=root
LimitNOFILE=100000
ExecStart=/usr/local/bin/transmission-daemon -f --log-error -g /usr/local/share/transmission

[Install]
WantedBy=multi-user.target
```
控制命令
```
#查看状态
systemctl status transmission.service
#重新载入配置信息
systemctl daemon-reload
#启动
systemctl start transmission.service
#关闭
systemctl stop transmission.service
#添加到开机启动
systemctl enable transmission.service
#关闭开开机启动
systemctl disable transmission.service
```

#### 配置文件
关闭`transmission`后在修改配置文件<br>
生成初始配置
```
systemctl daemon-reload
systemctl start transmission.service
systemctl stop transmission.service
```
配置相关目录
```
/usr/local/share/transmission
```
修改
```
vi /usr/local/share/transmission/settings.json
```
其中,设置rpc网页访问
```
    "rpc-authentication-required": false,
    "rpc-bind-address": "0.0.0.0",
    "rpc-enabled": true,
    "rpc-password": "123456", #密码，填入明文，启动后会自动转成密文
    "rpc-port": 9091,         #端口
    "rpc-url": "/transmission/",
    "rpc-username": "root",   #用户名，rpc用户名和密码与系统用户名密码不一样
    "rpc-whitelist": "192.168.1.*,127.0.0.1",  #允许访问的ip
    "rpc-whitelist-enabled": true,
```
之后
```
systemctl start transmission.service
```
就可以通过`http://ip:9091`来访问transmission,然后通过网页配置了

#### 添加防火墙端口
临时生效，其中51413是transmission的Peer listen port
```
iptables -I INPUT -p tcp --dport 51413 -j ACCEPT
iptables-save
```
永久生效
```
sudo apt-get install iptables-persistent
sudo netfilter-persistent save
sudo netfilter-persistent reload
```

## 跳过散列检测
在网页访问时，在任何一个种子上，右键`Ask tracker for more peers`<br>
就会跳过当前的检测

## 自动添加种子
种子多时，网页版经常卡，设置watch目录，自动添加种子<br>
[Transmission2.92配置文件参数中文解释](https://blog.whsir.com/post-1182.html)
```
    "watch-dir": "/home/data/zhongzi",
    "watch-dir-enabled": true
```
**注：每行以`,`结尾,最后一行无符号**\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
