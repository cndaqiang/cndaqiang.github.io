---
layout: post
title:  "Ubuntu16.04搭建openvpn服务器"
date:   2017-09-27 12:00:00 +0800
categories: Linux
tags: Linux ubuntu openvpn
author: cndaqiang
mathjax: true
---
* content
{:toc}




## 参考
[Ubuntu 16.04 架设 OpenVPN 服务](http://blog.topspeedsnail.com/archives/4860)

[在Ubuntu安装OpenVpn](https://vsxen.github.io/2017/05/15/openvpn-in-ubuntu/)

## 环境
 Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-91-generic x86_64)
## 安装
### 安装软件包
```
sudo su
apt-get update
apt-get install openvpn easy-rsa
```
easy-rsa为证书生成软件
### 证书制作
复制证书制作工具到文件夹(该文件夹应该不存在，复制后自动创建该文件夹)，`make-cadir`为easy-rsa安装后增加的命令
**证书的制作没有必要root权限，懒得退了就用root用户制作了**
```
make-cadir /etc/openvpn/ca
cd /etc/openvpn/ca
```
更改证书默认设置
```
vi vars
```
以下内容为证书的默认内容，可自定义，不能为空
```
export KEY_COUNTRY="US"
export KEY_PROVINCE="CA"
export KEY_CITY="SanFrancisco"
export KEY_ORG="Fort-Funston"
export KEY_EMAIL="me@myhost.mydomain"
export KEY_OU="MyOrganizationalUnit"
```
下面有个KEY_NAME，值可自定义，例如uuu
```
export KEY_NAME="uuu"
```
保存退出
使更改生效
```
source vars
```
#### CA证书
>CA数字证书认证机构,负责颁发证书，用于openvpn服务器和客户端的认证
```
./clean-all
./build-ca
```
`./build-ca `后一直回车确认，或者`./build-ca --batch`保持默认设置，无须回车确认
之后证书的制作命令，直接按照添加`--batch`执行，也可不添加，不再单独说明

#### 服务器证书
```
./build-key-server --batch uuu
```
uuu为之前vars里`export KEY_NAME="uuu"`的值
自定义uuu或者其他时后面需要在服务器配置文件中
client名称可自定义,如果修改最后在客户端配置文件中，需更改对应
```
cert server.crt
key server.key
```
为修改后的证书名称

#### 制作Diffie-Hellman key
```
./build-dh
```
#### 生成HMAC签名加强TLS认证
```
openvpn --genkey --secret keys/ta.key
```
#### 客户端证书
```
./build-key --batch client
```
client名称可自定义,如果修改最后在客户端配置文件中，更改对应
```
cert client.crt
key client.key
```
内容就行
### openvpn服务器配置
#### 移动证书
进入keys目录可以看到生成的证书文件
我们需要**ca.crt ca.key uuu.crt uuu.key ta.key dh2048.pem**
uuu为之前自定义的服务器证书名
```
# cd keys/
# ll
total 92
drwx------ 2 root root 4096 Sep 26 20:18 ./
drwx------ 3 root root 4096 Sep 26 20:10 ../
-rw-r--r-- 1 root root 5685 Sep 26 20:15 01.pem
-rw-r--r-- 1 root root 5578 Sep 26 20:18 02.pem
-rw-r--r-- 1 root root 1801 Sep 26 20:12 ca.crt
-rw------- 1 root root 1704 Sep 26 20:12 ca.key
-rw-r--r-- 1 root root 5578 Sep 26 20:18 client.crt
-rw-r--r-- 1 root root 1094 Sep 26 20:18 client.csr
-rw------- 1 root root 1708 Sep 26 20:18 client.key
-rw-r--r-- 1 root root  424 Sep 26 20:17 dh2048.pem
-rw-r--r-- 1 root root  287 Sep 26 20:18 index.txt
-rw-r--r-- 1 root root   21 Sep 26 20:18 index.txt.attr
-rw-r--r-- 1 root root   21 Sep 26 20:15 index.txt.attr.old
-rw-r--r-- 1 root root  142 Sep 26 20:15 index.txt.old
-rw-r--r-- 1 root root    3 Sep 26 20:18 serial
-rw-r--r-- 1 root root    3 Sep 26 20:15 serial.old
-rw------- 1 root root  636 Sep 26 20:37 ta.key
-rw-r--r-- 1 root root 5685 Sep 26 20:15 uuu.crt
-rw-r--r-- 1 root root 1090 Sep 26 20:15 uuu.csr
-rw------- 1 root root 1704 Sep 26 20:15 uuu.key
```
复制证书文件到/etc/openvpn
当前目录是`/etc/openvpn/ca/keys`，所以`../../`就是配置目录
```
cp ca.crt ca.key uuu.crt uuu.key ta.key dh2048.pem ../../
```
#### 修改配置文件
复制配置文件模板到`/etc/openvpn/`,解压后修改
```
cd ../../
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz .
gzip -d server.conf.gz
vi server.conf
```
以下内容替换为证书的路径名称，同路径下可直接写名称
```
ca ca.crt
cert server.crt
key server.key 
dh dh2048.pem
```
例
```
ca ca.crt
cert uuu.crt
key uuu.key 
dh dh2048.pem
```
>所以服务器证书一开始就命名为server默认值，后面就不用修改了

取消下面的注释（删掉；）
```
;push "redirect-gateway def1 bypass-dhcp"
;push "dhcp-option DNS 208.67.222.222"
;ush "dhcp-option DNS 208.67.220.220"
;user nobody
;group nogroup
```
去掉下面的注释，并再下一行添加`key-direction 0`
```
;tls-auth ta.key 0 # This file is secret
```
### 防火墙设置
#### 打开ip转发
修改/etc/sysctl.conf
```
vi /etc/sysctl.conf
```
取消注释
```
net.ipv4.ip_forward=1
```
生效
```
sysctl -p
```
#### 转发规则
```
ufw allow OpenSSH  # 在打开防火墙之前允许SSH连接
ufw enable
```
添加转发
```
vi /etc/ufw/before.rules
```
在最前面填入
```
# START OPENVPN RULES
# NAT table rules
*nat
:POSTROUTING ACCEPT [0:0] 
# Allow traffic from OpenVPN client to eth0
-A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
COMMIT
# END OPENVPN RULES
```
其中10.8.0.0/8为openvpn客户端获取的ip，如在server.conf里面修改，此处应替换为相应ip，eth0为ubuntu连接网络的网卡
```
vi /etc/default/ufw
```
将
```
DEFAULT_FORWARD_POLICY="DROP"
```
改为
```
DEFAULT_FORWARD_POLICY="ACCEPT"
```
#### 允许openvpn通行
```
ufw allow 1194/udp
ufw disable
ufw enable
```
其中1194为openvpn监听端口，udp为协议，也可在server.conf里自定义
### 启动openvpn服务器
```
systemctl start openvpn@server
systemctl enable openvpn@server
```
通过`ifconfig`可以查看新增的ip为`inet addr:10.8.0.1`的`tun0 `网卡
### 客户端配置文件制作
```
cd /etc/openvpn/ca/keys
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf .
```
因为是一直root权限操作，所以ubuntu普通用户没有访问证书目录的权限，可将
```
chmod -R +rx /etc/openvpn/ca/
```
赋予普通用户读取权限，当然之前使用普通用户制作证书就没这么麻烦

用scp等方法将keys中的`ca.crt  ta.key client.crt client.key client.conf` 文件复制到电脑上，或者赋予普通用户证书目录权限，然后scp后下载`ca.crt  ta.key client.crt client.key`
```
chmod ubuntu:ubuntu /etc/openvpn/ca/keys/
```

在电脑上打开client.conf
将
```
remote my-server-1 1194
```
中my-server-1 1194分别替换为服务器的ip/域名，端口
去掉前面的分号
```
;user nobody
;group nogroup
```
设置证书地址,如果自定义了客户端证书名称自行更改
```
ca ca.crt
cert client.crt
key client.key
```
删掉分号
```
;tls-auth ta.key 1
```
并在下一行添加
```
key-direction 1
```
#### 配置文件制作方案一
把client.conf命名为client.ovpn，然后在openvpn客户端配置目录新建文件夹，将**ca.crt ta.key client.crt client.key client.ovpn**复制到该目录
#### 配置方案二
文件数目少，导入ios更简单

将client.conf中
```
ca ca.crt
cert client.crt
key client.key
tls-auth ta.key 1
```
改为
```
ca [inline]
cert [inline]
key [inline]
tls-auth [inline] 1
```
按照下列顺序，将内容复制到新建client.ovpn文件
```
client.conf文件内容
<ca>
ca.crt文件内容
</ca>
<cert>
client.crt文件内容
</cert>
<key>
client.key文件内容
</key>
<tls-auth>
ta.key文件内容
</tls-auth>
```
然后将client.ovpn放到openvpn客户端目录，或者发送到手机用openvpn打开

也可以在ubuntu上直接进行上述操作
```
cat /etc/openvpn/ca/keys/client.conf <(echo -e '<ca>') /etc/openvpn/ca/keys/ca.crt <(echo -e '</ca>\n<cert>') /etc/openvpn/ca/keys/client.crt <(echo -e '</cert>\n<key>') /etc/openvpn/ca/keys/client.key <(echo -e '</key>\n<tls-auth>') /etc/openvpn/ca/keys/ta.key <(echo -e '</tls-auth>') > ~/client/ovpn/client.ovpn
```
然后下载client.ovpn\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
