---
layout: post
title:  "Ubuntu上安装ocserv"
date:   2017-08-03 12:00:00 +0800
categories: Linux
tags: Linux ubuntu ocserv
author: cndaqiang
mathjax: true
---
* content
{:toc}





## 环境
Ubuntu 14.04 64 bit （vps ）

## 1. 下载
```
root@p:~# wget ftp://ftp.infradead.org/pub/ocserv/ocserv-0.10.7.tar.xz
```
## 2. 解压,安装依赖，编译
```
root@p:~# tar -xf ocserv-0.10.7.tar.xz 
root@p:~# cd ocserv-0.10.7
# 安装依赖，依赖的包可root@p:~/ocserv-0.10.7# cat README 
查看
root@p:~# apt-get update
root@p:~/ocserv-0.10.7# apt-get install build-essential pkg-config libgnutls28-dev libwrap0-dev libpam0g-dev libseccomp-dev libreadline-dev libnl-route-3-dev
# 编译
root@p:~/ocserv-0.10.7# ./configure 
root@p:~/ocserv-0.10.7# make
root@p:~/ocserv-0.10.7# make install
```
## 3. 生成密钥，证书
```
root@p:~/ocserv-0.10.7# mkdir /etc/ocserv && cd /etc/ocserv
# 安装certtool命令用于后序生成密钥证书
root@p:/etc/ocserv# apt-get install gnutls-bin
# 创建CA
## 创建ca模板
root@p:/etc/ocserv# vi ca.tmpl
## 填入以下内容
cn = "Your CA name" 
organization = "Your fancy name" 
serial = 1 
expiration_days = 3650
ca 
signing_key 
cert_signing_key 
crl_signing_key 
## 生成CA密钥
root@p:/etc/ocserv# certtool --generate-privkey --outfile ca-key.pem
## 生成CA证书
root@p:/etc/ocserv# certtool --generate-self-signed --load-privkey ca-key.pem --template ca.tmpl --outfile ca-cert.pem
## ls后可看到生成的两个文件和模板
root@ubuntu:/etc/ocserv# ls
ca-cert.pem  ca-key.pem  ca.tmpl
# 同理创建server
root@p:/etc/ocserv# vi server.tmpl
## 填入 这里的cn项必须对应你最终提供服务的hostname或IP，否则AnyConnect客户端将无法正确导入证书
cn = "Your hostname or IP" 
organization = "Your fancy name" 
expiration_days = 3650
signing_key 
encryption_key
tls_www_server
## 生成密钥，证书
root@p:/etc/ocserv# certtool --generate-privkey --outfile server-key.pem
root@p:/etc/ocserv# certtool --generate-certificate --load-privkey server-key.pem --load-ca-certificate ca-cert.pem --load-ca-privkey ca-key.pem --template server.tmpl --outfile server-cert.pem
# 如果需要改成证书认证，还要继续创建user，本文先以账户认证，如有机会，补上证书认证
```
## 4. 配置文件
```
# 移动配置文件模板到/etc/ocserv/    sample.config源目录根据你的文件位置调整目录
root@p:/etc/ocserv# cp ~/ocserv-0.10.7/doc/sample.config ocserv.conf
# 修改配置文件
root@p:/etc/ocserv# vi ocserv.conf
## 设置密码认证
把auth = "plain[passwd=./sample.passwd]"修改为auth = "plain[/etc/ocserv/ocpasswd]"
同时禁用其他 auth = ""的项，在前面加个#号即禁用，最后即为
#auth = "pam"
#auth = "pam[gid-min=1000]"
auth = "plain[/etc/ocserv/ocpasswd]"
#auth = "certificate"
#auth = "radius[config=/etc/radiusclient/radiusclient.conf,groupconfig=true]"
## 设置监听端口修改此部分为你喜欢的端口号
tcp-port = 443
udp-port = 443
## 设置证书密钥地址，修改下列两项为之前创建的证书目录
server-cert = ../tests/server-cert.pem
server-key = ../tests/server-key.pem
ca-cert = ../tests/ca.pem
### 修改后为
server-cert = /etc/ocserv/server-cert.pem
server-key = /etc/ocserv/server-key.pem
ca-cert = /etc/ocserv/ca.pem
## 其他修改
### 允许同时连接的客户端数量
max-clients = 4
### 限制同一客户端的并行登陆数量
max-same-clients = 2
### 服务监听的IP（服务器IP，可不设置）
listen-host = 1.2.3.4
### 自动优化VPN的网络性能
try-mtu-discovery = true
### 客户端连上vpn后使用的dns
dns = 8.8.8.8
dns = 8.8.4.4
### 注释掉所有的route，让服务器成为gateway
#route = 192.168.1.0/255.255.255.0
### 启用cisco客户端兼容性支持
cisco-client-compat = true
# 保存退出
```
## 5. 生成密码 your_name为认证用户名
```
root@p:/etc/ocserv# ocpasswd -c /etc/ocserv/ocpasswd your_name
Enter password: 
Re-enter password: 
```
## 6.网络设置
```
#把其中的443改成你之前设置的端口
oot@ubuntu:/etc/ocserv# iptables -t filter -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
root@ubuntu:/etc/ocserv# iptables -t filter -A INPUT -p udp -m udp --dport 443 -j ACCEPT
root@ubuntu:/etc/ocserv# iptables -t nat -A POSTROUTING  -j MASQUERADE
#修改/etc/sysctl.conf，启用 net.ipv4.ip_forward=1
root@ubuntu:/etc/ocserv# vi /etc/sysctl.conf
#生效
root@ubuntu:/etc/ocserv# sysctl -p /etc/sysctl.conf
```
## 7.启动
```
ocserv -f -d 1
```
如果端口被占用可已换端口，或者关闭相应端口，关闭某端口占用程序命令
```
lsof -i:端口号
kill -9 PID(进程号)
#例
root@VM-10-194-ubuntu:/etc/ocserv# lsof -i:443
COMMAND     PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
ocserv-ma 16409 root    4u  IPv4  31213      0t0  TCP *:https (LISTEN)
ocserv-ma 16409 root    5u  IPv4  31216      0t0  UDP *:https 
root@VM-10-194-ubuntu:/etc/ocserv# kill -9 16409
```
## 9.客户端AnyConnect
ios [Cisco AnyConnect](https://itunes.apple.com/us/app/cisco-anyconnect/id1135064690?mt=8)

其他平台下载
注:
1. Android和ios客户端要在设置里取消勾选"阻止不信任的服务器",PC客户端连接时也会提示不信任之类的，选仍然连接

## 10.遇到的问题
### 1.移动端提示"安全网关已拒绝所尝试的连接操作。需要尝试与同一或其他安全网关建立新连接。新连接要求重新进行身份验证。"PC端提示"anyconnect was not able to establish a connection to the specified secure gateway please try again"

使用GigsGigsCloud.com的Ubuntu 14.04 64bit(hk机房)遇到该问题，换到腾讯云的上海机房就没有此提示，表明与机房防火墙有关，ocserv的安装过程没有问题

另外另有一路由器(openwrt)安装了ocserv在校园网内，校外网连接时也会出现此提示
**已解决**hk机房问题，在vps控制面板看到一个开关TUN/TAP打开后既能连接了

![image.png](http://upload-images.jianshu.io/upload_images/4575564-cfe26d8a1ba8369c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 2.腾讯云除了上述设置外，还要添加安全组允许访问机器的443端口,否则客户端连不上，服务器端没反应**

### 3.我所在的网络ISP(网络服务提供商)不允许访问外网的FTP(21号端口)，所以如果你选择的端口不合适可能会被ISP阻止
## 参考
[Ubuntu ocserv搭建](https://fewspider.github.io/2015/08/16/ubuntu-ocserv-deploy.html)

[折腾笔记：架设OpenConnect Server给iPhone提供更顺畅的网络生活](https://bitinn.net/11084/)

[安装ocserv和anyconnect](http://www.sbbok.com/discussion/2/%E5%AE%89%E8%A3%85ocserv%E5%92%8Canyconnect)\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
