---
layout: post
title:  "Ubuntu创建sudo用户"
date:   2017-09-28 12:00:00 +0800
categories: Linux
tags: Linux ubuntu sudo user
author: cndaqiang
mathjax: true
---
* content
{:toc}




# 参考
[Ubuntu创建sudo用户](http://topspeedsnail.com/ubuntu-add-sudo-user/)

## 添加用户
给人使用的用户
```
ubuntu@ubuntushixi:~$ sudo adduser --home /home/cndaqiang cndaqiang
Adding user `cndaqiang' ...
Adding new group `cndaqiang' (1001) ...
Adding new user `cndaqiang' (1001) with group `cndaqiang' ...
Creating home directory `/home/cndaqiang' ...
Copying files from `/etc/skel' ...
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
Changing the user information for cndaqiang
Enter the new value, or press ENTER for the default
Full Name []: cndaqiang
Room Number []:
Work Phone []:
Home Phone []:
Other []:
Is the information correct? [Y/n] y
ubuntu@ubuntushixi:~$
```
方案二，非人用？
```
sudo su
useradd -d 用户家目录 -M 用户名
passwd 用户名
```

## 加入sudo用户组
```
#ubuntu方式
sudo usermod -aG sudo 用户名
#Centos 方式
usermod -aG wheel cndaqiang
```
## 测试
切换用户测试
```
su -l 用户名
sudo apt-get update
```
## 创建家目录(选)
```
sudo mkdir 用户家目录
sudo chown 用户名:用户组 用户家目录
```------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
