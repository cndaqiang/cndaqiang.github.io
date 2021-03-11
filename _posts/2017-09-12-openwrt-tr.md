---
layout: post
title:  "OpenWrt使用transmission下载挂pt"
date:   2017-09-12 21:39:00 +0800
categories: OpenWrt
tags: OpenWrt transmission 
author: cndaqiang
mathjax: true
---
* content
{:toc}





## 环境
CHAOS CALMER (15.05.1, r48532)
## 参考
[byr [个人经验]NAS+Transmission配置](http://bt.byr.cn/forums.php?action=viewtopic&forumid=9&topicid=7422)<br>
[TP-LINK WR703N 刷OpenWrt并设置pppoe联网、安装LUCI、添加新用户、挂载USB设备、配置ftp服务、借由transmission实现脱机下载(续)](http://www.xuebuyuan.com/1814574.html)
## 操作
### 硬盘挂载
参考[openwrt 挂载U盘/硬盘+交换分区](http://www.jianshu.com/p/adff41e500d8)
### 安装
```
opkg update  #更新
opkg install libartnet libopus luci-app-transmission luci-i18n-transmission-zh-cn transmission-cli transmission-daemon transmission-remote transmission-web 
```
### 配置
网页端配置
<br>LuCI-->服务-->transmission 
<br>可进入配置页面 
<br>配置如图
![](/uploads/2017/09/tr1.png)
### 外网访问
**开启下载peer端口**
<br>将transmission配置页面的peer端口，默认51413添加防火墙端口
<br>LuCI->网络->防火墙->Traffic Rules添加一个协议为TCP+UDP的51413的端口
![](/uploads/2017/09/tr2.webp)


或者ssh后输入
```
iptables -I INPUT -p udp --dport 51413 -j ACCEPT
iptables -I INPUT -p tcp --dport 51413 -j ACCEPT
```
**外网管理**
<br>防火墙，添加转发规则到192.168.1.1的transmission管理端口，
![](/uploads/2017/09/tr3.webp )

还要在rcp白名单里添加ip，推荐挂vpn或者ssh隧道连上路由器后用内网ip管理

### 启动
启动，Luci配置页面里勾选启用，保存应用也可启动
```
transmission-daemon 
```
关闭命令,并不能彻底关闭，会自动重启，彻底关闭需要在Luci配置页面里不勾选启用
```
killall transmission-daemon 
```
**开机启动**
<br>Luci -->系统-->启动项-->
<br>本地启动脚本中加入
```
(sleep 16 ;   transmission-daemon)&
```

### 拓展
[transmission禁用ipv4的尝试](http://www.jianshu.com/p/7a8daf7cec4c)\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
