---
layout: post
title:  "discuz站点迁移记录"
date:   2017-10-11 12:00:00 +0800
categories: web
tags: web discuz 
author: cndaqiang
mathjax: true
---
* content
{:toc}
论坛所在服务器版本为ubuntu14.04，准备更换硬盘，并装系统16.04，记录如下





## 参考
[DISCUZ X3 论坛更换域名详细图文教程
](http://www.51php.com/discuz/17182.html)

[Can not write to cache files, please check directory ./data/ and ./data/sysda...](http://www.discuz.net/thread-3258692-1-1.html)

[菜鸟入门之centos的文件夹权限继承](http://www.chinaz.com/server/2009/0512/75598.shtml)
## 环境
### old
Ubuntu 14.04.1 LTS (GNU/Linux 3.13.0-132-generic x86_64)

Apache/2.4.7 (Ubuntu)

PHP 5.5.9-1ubuntu4.22 (cli)

discuz 3.1

### new
Ubuntu 16.04.3 LTS (GNU/Linux 4.4.0-87-generic x86_64)

Apache/2.4.18 (Ubuntu)

PHP 5.6.31-6+ubuntu16.04.1+deb.sury.org+1 (cli) 

## 操作
### 新环境搭建
需要搭建php5
参见[Ubuntu16.04搭建LAMP(php5)](/2017/10/11/ubutnu1604-lamp5/)

根据需要设置apache，建立必要的文件夹和权限
### 网站备份
#### 打包旧网站数据
```
$ tar -czf www.backup.full.20171011.tar.gz www
```
#### 下载数据库
登录phpmyadmin下载相应论坛数据库
参考[Mysql&Phpmyadmin简单学习](/2017/09/27/mysql/)

记录论坛数据库用户密码权限
通过查看
```
discuz目录/config/config_global.php 
discuz目录/config/config_ucenter.php
discuz目录uc_server/data/config.inc.php 
```
确定
### 上传网站到新网站根目录
此处使用wget

在old服务器内
```
$ mv www.backup.full.20171011.tar.gz www
```
new服务器内
```
$ wget http://old服务器域名或地址/www.backup.full.20171011.tar.gz
```
new服务器内解压
```
$ tar xvf www.backup.full.20171011.tar.gz
```
移动到合适位置，如果命令不方便移动，就用winscp
### 更改部分文件夹权限
```
chmod -R 777 网站目录/data
chmod -R 777 网站目录/uc_server/data
```
### 恢复数据库
上传old数据库，并设置好用户权限
对于较大的数据库可能需要[phpmyadmin导入文件大小限制](/2017/10/11/phpmyadmin-import/)

>论坛文件中数据库配置涉及以下文件
```
config/config_global.php 
config/config_ucenter.php
uc_server/data/config.inc.php 
```

可根据配置文件，调节不同数据库的用户和权限

### 涉及域名调节
参考
[discuz更换域名](/2017/10/12/discuz-change-domain/)
\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
