---
layout: post
title:  "OpenWrt搭建ocserv服务器"
date:   2017-09-27 12:00:00 +0800
categories: OpenWrt
tags: OpenWrt ocserv 
author: cndaqiang
mathjax: true
---
* content
{:toc}






## 环境
CHAOS CALMER (15.05.1, r48532)
## 参考
[Openwrt搭建OpenConnect VPN](http://www.hooklearn.top/2016/04/27/openwrt%E6%90%AD%E5%BB%BAopenconnect-vpn/)
## 操作
### 安装
```
opkg update
opkg install ocserv luci-app-ocserv
```
### 配置
LuCI-》服务-》OpenConnect VPN
- Enable Server：打钩表示启动服务。
- User Authentication：用户认证方式，选择plain，表示使用OpenWRT路由器上面定义的用户名和密码登录VPN。
- Firewall Zone：选择Lan
- 端口：默认是443，可自定义
- Max Clients最大连接数
- Max same Clients 同一个账号能够登录几个。
- Enable compression：打钩表示启用压缩。
- Enable UDP：打钩表示启用UDP协议。
- AnyConnect client compatibility：打钩表示允许 Cisco 的 Anyconnect Client 作为VPN客户端软件连接

***

VPN客户端连到内网之后，获得的IP地址的网段范围**有两种配置方案**

VPN IPv4-Network-Address： 客户端ip地址

VPN IPv4-Netmask：子网掩码

---

#### VPN 网段和OpenWRT所在的网段不同（简单推荐）

例

OpenWRT的路由器的IP地址为：192.168.1.1，子网掩码为255.255.255.0

设置为
```
IPv4-Network-Address：192.168.2.0（0表示网络地址）
VPN IPv4-Netmask：255.255.255.0
```
***

#### VPN 网段和OpenWRT所在的网段一样
使用其中某一段子网IP地址，但是所有接口上的ARP代理功能

例如我使用的是192.168.1.10~192.168.1.17这几个ip，涉及子网掩码的计算，计算方法简如下，原理略
```
192.168.1.10     192.168.1.0000 1010 #10的二进制0000 1010
192.168.1.17     192.168.1.0000 1111 #17的二进制0000 1111
11111111.11111111.11111111.1111 0000   255.255.255.240# 240的二进制1111 0000
VPN IPv4-Netmask为192.168.1.10 和VPN IPv4-Netmask为255.255.255.240
```
**启用代理ARP**

编辑` /etc/sysctl.conf`
新增一条：
```
net.ipv4.conf.all.proxy_arp=1
```
保存,重新载入配置
```
sysctl -p
```
***

### 设置访问账户密码
LuCI-->服务-->OpenConnect VPN-->User Settings
在Available users里填入账号密码即可，保存后，密码自动显示为密文
### 配置防火墙
**开放访问端口**

使用端口为4433，则要在防火墙上把这个口打开
LuCI-》网络-》防火墙-》Traffic Rules
Open ports on router:
![](http://upload-images.jianshu.io/upload_images/4575564-39d1aef77a0e4fcb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
名称 自定义

协议TCP+UDP 

External port 4433

保存应用

**允许VPN的流量访问内网资源**

编辑/etc/firewall.user，添加下列内容
```
iptables -A input_rule -i vpns+ -j ACCEPT
iptables -A forwarding_rule -i vpns+ -j ACCEPT
iptables -A forwarding_rule -o vpns+ -j ACCEPT
iptables -A output_rule -o vpns+ -j ACCEPT
```
重启防火墙
```
/etc/init.d/firewall restart
```

### 启动
重启

Luci -->系统-->启动项-->ocserv

**开机启动**

虽然Luci -->系统-->启动项-->ocserv设为了开机启动，没有效果，解决方案

Luci -->系统-->启动项-->

本地启动脚本中加入
```
(sleep 11; /etc/init.d/ocserv start)&
```
### 客户端连接
下载客户端
[Android](http://www.cisco.com/c/en/us/support/security/anyconnect-secure-mobility-client/tsd-products-support-series-home.html)

[IOS](https://itunes.apple.com/cn/app/cisco-anyconnect/id392790924?mt=8)

PC端，搜索anyconnect

服务器地址ip:端口，连接时提示危险就在设置里不勾选阻止不信任的服务器，接受之类的

## 问题
**1.移动端提示"安全网关已拒绝所尝试的连接操作。需要尝试与同一或其他安全网关建立新连接。新连接要求重新进行身份验证。"PC端提示"anyconnect was not able to establish a connection to the specified secure gateway please try again"**

解决方案参考[Ubuntu上安装ocserv](/2017/08/03/ubuntu-ocserv/)




------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
