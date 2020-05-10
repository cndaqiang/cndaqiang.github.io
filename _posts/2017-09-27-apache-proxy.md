---
layout: post
title:  "Apache 反向代理"
date:   2017-09-27 12:00:00 +0800
categories: web
tags: web ubuntu 反向代理 
author: cndaqiang
mathjax: true
---
* content
{:toc}





## 参考
[Apache的ProxyPass指令详解](http://www.javacui.com/service/318.html)

## 反向代理
具体看[wiki反向代理](https://zh.wikipedia.org/wiki/%E5%8F%8D%E5%90%91%E4%BB%A3%E7%90%86)
现在有一个网站A，由于某些原因用户无法访问，但是用户可以访问服务器B，B可以访问网站A，所以使用B做反向代理，用户访问网站B，B连同用户和网站A，如图B为Proxy，A为Web server
![反向代理wiki](http://upload-images.jianshu.io/upload_images/4575564-50a02efd53d21d8b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
## 环境
代理服务器 Apache Ubuntu
网站服务器 本实例针对的是discuz网站，其实不用操作
## 步骤

### 1. 安装apache
```
sudo su
apt-get update
apt-get install apache2   #安装apache
a2enmod proxy proxy_balancer proxy_http
#启用代理模块
```
### 2. 修改配置
```
cd /etc/apache2/sites-enabled
vi 000-default.conf 
```
在最前面添加
```
<VirtualHost *:80>
    Servername  代理服务器ip或者域名
        ProxyRequests Off
#off表示开启反向代理，on表示开启正向代理
        ProxyPass / 被代理的网站
        ProxyPassReverse  / 被代理的网站
        <Proxy *>
           Order Deny,Allow
           Allow from all
        </Proxy>
</VirtualHost>
```

如图

![image.png](http://upload-images.jianshu.io/upload_images/4575564-7cfcd6e438f57311.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 3. 重启生效
```
/etc/init.d/apache2 restart
```
效果
可以通过http://23.95.-.-访问http://---.net


## 存在问题
并不是所有网站都能代理，先能代理这个再说，需要再说
全是问题，apache还没正式了解过。。。