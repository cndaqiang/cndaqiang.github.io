---
layout: post
title:  "phpMyAdmin导入文件大小限制"
date:   2017-10-11 12:00:00 +0800
categories: web
tags: web Mysql phpMyAdmin
author: cndaqiang
mathjax: true
---
* content
{:toc}






## 参考
[Ubuntu中增加apache上传文件大小限制(突破Aapache默认2M上传限制)](http://blog.sina.com.cn/s/blog_575b2c5001019odj.html)

[解决phpmyadmin上传文件大小限制的配置方法](http://www.edbiji.com/doccenter/showdoc/25/nav/216.html)

[如何突破php上传文件大小限制](http://www.jquerycn.cn/a_25213)

[phpmyadmin导入sql文件大小限制](http://www.jianshu.com/p/00e6999b9b3b)
## 环境
Ubuntu 16.04.3 LTS (GNU/Linux 4.4.0-87-generic x86_64)
Apache/2.4.18 (Ubuntu)
PHP 版本： 5.6.31
## 操作
### 修改php上传限制
修改php目录下php.ini
```
$ vi /etc/php/apache2/php.ini
```
由于环境服务器上php是ppa安装的目录有所不同，实际操作为，因服务器而定
```
$ sudo vi /etc/php/5.6/apache2/php.ini
```
修改下列设置为自定义值
```
upload_max_filesize = 100M 
memory_limit = 256M 
post_max_size = 100M
```
重启apache
```
sudo /etc/init.d/apache2 restart
```
### 修改phpMyAdmin配置
进入phpMyAdmin配置目录，如
```
$ cd /var/www/html/phpMyAdmin
```
#### 修改配置文件
```
sudo vi ./libraries/config.default.php 
```
>有教程中文件为`./config.inc.php`

修改`cfg['ExecTimeLimit']`，默认为300，修改为0
```
$cfg['ExecTimeLimit'] = 0;
```
#### 修改import.php
```
sudo vi import.php
```
将 $memory_limit设置为`100*1024*1024`，可自定义
```
if (empty($memory_limit)) {
    $memory_limit = 100 * 1024 * 1024;
}
// In case no memory limit we work on 10MB chunks
if ($memory_limit == -1) {
    $memory_limit = 100 * 1024 * 1024;
}
```

自此可导入成功



------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
