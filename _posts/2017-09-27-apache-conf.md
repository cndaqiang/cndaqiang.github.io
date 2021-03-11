---
layout: post
title:  "Apache配置实例"
date:   2017-09-27 12:00:00 +0800
categories: web
tags: web Apache
author: cndaqiang
mathjax: true
---
* content
{:toc}





## 注意
目录必须存在，不然重启apache会失败，即使是log目录
## 参考
[如何配置Apache虚拟主机？（基于IP、基于端口、基于域名）](http://10240214.blog.51cto.com/6634068/1177701)
## 环境
ubuntu16.04
apache2
## 虚拟主机

```
ServerName  主机名/域名
ServerAdmin  管理员邮箱
DocumentRoot 网站目录
ErrorLog 日志目录
CustomLog 日志目录
Deny from 阻止访问IP
```
### 基于ip
需有多个ip
```
<VirtualHost IP1:80>
        ServerName  a.com
        ServerAdmin  webmaster@localhost
        DocumentRoot /home/data/www/a
        ErrorLog /home/data/log/a_error.log
        CustomLog /home/data/log/a_access.log combined
</Virtualhost>
<VirtualHost IP2:80>
        ServerName b.com
        ServerAdmin webmaster@localhost
        DocumentRoot /home/data/www/b
        ErrorLog /home/data/log/b_error.log
        CustomLog /home/data/log/b_access.log combined
</Virtualhost>
```
### 基于域名
```
<VirtualHost *:80>
        ServerName a.com
        ServerAdmin webmaster@localhost
        DocumentRoot /home/data/www/a
        ErrorLog /home/data/log/a_error.log
        CustomLog /home/data/log/a_access.log combined
</Virtualhost>
<VirtualHost *:80>
        ServerName b.com
		ServerAdmin webmaster@localhost
        DocumentRoot /home/data/www/b
        ErrorLog /home/data/log/b_error.log
        CustomLog /home/data/log/b_access.log combined
</Virtualhost>
```
### 基于端口
需要开启端口监听配置
```
Listen 80
Listen 8080
```
网站配置
```
<VirtualHost IP:80>
        ServerName a.com
        ServerAdmin webmaster@localhost
        DocumentRoot /home/data/www/a
        ErrorLog /home/data/log/a_error.log
        CustomLog /home/data/log/a_access.log combined
</Virtualhost>
<VirtualHost IP:8080>
        ServerName b.com
		ServerAdmin webmaster@localhost
        DocumentRoot /home/data/www/b
        ErrorLog /home/data/log/b_error.log
        CustomLog /home/data/log/b_access.log combined
</Virtualhost>
```
### IP，域名，端口的组合
解析的时候 一个域名对应一个IP
所以 虚拟主机一个IP只能对应一个ServerName，一个IP/ServerName可以对应多个端口
## 实例
### 一个域名访问一个网页
```
<VirtualHost *:80>
    Servername  php.gac.cn
	DocumentRoot /var/www/html/php
#网站的目录设置为/var/www/html/php访问时用http://php.gac.cn
</VirtualHost>
```
### 域名/关键字 访问不同的网页
```
<VirtualHost *:80>
    Servername  php.gac.cn
	DocumentRoot /var/www/html/php
#网站的目录设置为/var/www/html/php访问时用http://php.gac.cn
</VirtualHost>
```
在`/var/www/html/php`目录下新建php1，php2目录，在每个目录里放上网页，则可通过`http://php.gac.cn/php1`,`http://php.gac.cn/php2`访问两个网页
好像还有其他语法可以实现不同关键字访问不同网页，并不涉及目录

### apache反向代理 一个域名反向代理多个discuz站
#### 参考
[Ubuntu Apache 反向代理](/2017/09/27/apache-proxy/)
#### 案例环境
反向代理服务器 :Centos apache
discuz站所在服务器: Ubuntu apache
#### 实现 
通过http://www.domain.cn/xxx，访问Ubuntu里面里面已存在的不同的discuz网站
#### 问题
 discuz会根据访问的域名如http://xxx.cn生成返回的html网页中的连接，所以访问discuz的连接必须是http://www.domain.cn/xxx，而在公网上www.domain.cn指向的是反向代理服务器 （Centos ）
#### 一种方案
**反向代理服务器 （Centos apache)配置**
apache配置文件填入
```

<VirtualHost *:80>
    Servername  www.domain.cn
        ProxyRequests Off
#zx站
        ProxyPass /zx/ http://www.domain.cn/zx/
        ProxyPassReverse /zx/  http://www.domain.cn/zx/
#hjl站
        ProxyPass /hjl/ http://www.domain.cn/hjl/
        ProxyPassReverse /hjl/  http://www.domain.cn/hjl/
       <Proxy *>
           Order Deny,Allow
           Allow from all
        </Proxy>
</VirtualHost>
```
因为在公网上www.domain.cn指向代理服务器(centos)，所以为了让代理服务器(centos)将www.domain.cn解析为discuz所在的服务器(ubuntu)，在代理服务器(centos)中添加hosts
```
echo discuz所在的服务器(ubuntu)ip www.domain.cn >> /etc/hosts
```
**discuz所在的服务器(ubuntu,apache)配置**
apache配置文件填入
```
#proxy
<VirtualHost *:80>
        ServerName  www.domain.cn
        DocumentRoot /var/www
        ErrorLog /var/data/log/proxy.log
        CustomLog /var/data/log/proxy.log combined
</Virtualhost>
```
将zx站的目录放在/var/www/zx目录下，hjl站的目录放在/var/www/hjl目录下

这样当访问http://www.domain.cn/zx/（对公网来说www.domain.cn指向代理服务器）时，代理服务器会自动请求http://www.domain.cn/zx/(对代理服务器来说www.domain.cn指向disucz站点服务器)，discuz返回的网页里面所有的连接也都是http://www.domain.cn/zx/开头的，可以持续访问。
**discuz操作**
zx站和hjl站的域名都是www.domain.cn，他们的cookies保存如果都在根目录就会冲突，将zx站默认cookies目录设置为/zx/,hjl站默认cookie目录设置为/hjl/就不会冲突
```
vi discuz目录/config/config_global.php
```

把`$_config['cookie']['cookiepath'] = '';`更改为`$_config['cookie']['cookiepath'] = '/xxx/';`
xxx代表zx或hjl

discuz控制面板里也把相应的连接设置为http://www.domain.cn/xxx/

#### 暂时发现这些\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
