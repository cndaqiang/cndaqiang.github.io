---
layout: post
title:  "PC端笔记方案_VeraCrypt+Zim+同步云盘"
date:   2018-01-25 17:16:00 +0800
categories: 生活
tags: 全平台 tool 笔记
author: cndaqiang
mathjax: true
---
* content
{:toc}
主要为了解决我的密码保存问题,之前密码都是保存在onenote,加个密码,每次解密后快速搜索,而且手机也支持,昨天onenote居然卡顿了,而且onenote在linux平台一直不能很顺利的使用,也是我笔记本基本不用linux的最大原因.







## 2019-06-15更新
在不同的系统下完全有各自的加密方式，比如win的Bitlocker，可以开机自动挂载，密码输入正确就可以，也不错，再用<br>
因关机没有挂载Bitlocker分区时，添加盘符，进入控制面板解锁


## 笔记软件
### 需求
- 全平台,至少PC端可以全平台使用
- 云同步,可以使用第三方云盘解决
- 一些笔记需要加密,隐藏,保证在电脑丢失的情况下
<br>信息不被一些没有技术的人轻松获取
- 电脑丢失不影响我的生活(上述要求满足,此条件自然满足)
- 没必要只是用单一笔记软件
<br>有些笔记不需要满足上述要求,完全可以多个笔记软件混合使用

### 考虑过的笔记方案
#### 笔记软件
- onenote
<br>除了linux不能流畅使用,满足全平台+同步+加密条件,简直是我的最爱了,足够优秀。<br>
加密的笔记搜索起来很慢<br>
继续使用,不再使用加密功能,用于生活琐事,和移动端看笔记。

- [印象笔记](https://www.yinxiang.com/)
<br>免费用户不支持离线,直接放弃,标准版8元/月,不想额外付费了。
- [有道笔记](https://note.youdao.com/)
<br>有广告
- [为知笔记](https://www.wiz.cn/)
<br>免费用户只能使用100天,放弃

#### 本地/云网站+云盘同步
- wordpress+php+mysql博客类
<br>本地需要定期备份数据库,额外运行网站服务,没必要
<br>服务器运行,不支持离线,服务器安全需要维护
- jekyll等静态网页
<br>编辑起来不太方便,复制粘贴格式无法保留

#### 离线笔记软件
- [Mybase](http://www.wjjsoft.com)
<br>我非常喜欢,适用于PC全平台,自带加密功能,离线使用,编辑器也不错<br>
正版需要付费,(因为不知道这个软件是否会继续开发,所以我不愿意付费和使用破解版)
- md编辑器,gitbook等
<br>gitbook运行起来太卡了,md编辑器粘贴图形困难
- Zim等离线笔记软件
<br>考虑Zim支持PC全平台,编辑器也不错(不支持md语法,不是必须条件)
<br>致命弱点不能加密,所以需要第三方加密软件进行加密


## PC端笔记方案_VeraCrypt+Zim+同步云盘
### [Zim - A Desktop Wiki](http://zim-wiki.org/)
虽然没有onenote那么强大,但笔记功能还可以,可以从粘贴板复制图片等并保持排版
<br>开源,免费,支持Linux，[OSX](http://zim-wiki.org/install.html),Windows.

### [VeraCrypt](https://veracrypt.codeplex.com/)
VeraCrypt 是一款基于已终止的 TrueCrypt项目开发的开源即时加密软件，它可以创建一个虚拟的加密磁盘或者加密分区，用来保护隐私文件。详细信息和安装[@小众软件](https://www.appinn.com/veracrypt/)<br>
<br>主要是用于对存放含有密码的笔记,开源,免费支持Linux，OSX,Windows.(移动端也有第三方客户端)
<br><br>我最喜欢的地方是,开机一次解密,挂载成一个分区,断电或关机数据都会加密.而且存储文件没有格式要求,**可以把加密盘,命名为`xxx.dll`等名称藏在C盘某个目录内,减少电脑失窃后某些文件/笔记被偷看的可能**。
<br><br>除了给笔记加密,还有更多有趣的玩法

### 同步云盘
避免数据丢失,对Zim的笔记进行备份,因为日常备份都用坚果云了,所以选择[坚果云](https://www.jianguoyun.com)

## 安装使用
### Zim
#### 安装
从[Zim - A Desktop Wiki](http://zim-wiki.org/)下载安装即可<br>
#### 中文支持
参考[Zim桌面wiki系统](http://menxu.lofter.com/post/164b9d_3ebf7b)<br>
使用中文:我的电脑（计算机）右键属性里的环境变量里增加一个变量，变量名为 “LANG”，值为 “zh_CN.UTF-8″，皆不带引号
#### 常用
`ctrl +/-`调节页面文本显示大小
#### 插入图片过大
选中图片,ctrl+E,调整大小
#### 常用插件
Edit>Preferences>Plugins
- 插入代码块高亮Source View<br>
插入后就可以Insert>Code Block
![](/uploads/2020/06/source.PNG)
- 目录插件 Table of Contents

## 安装VeraCrypt
参考[Please add these info for Linux/Ubuntu users](https://sourceforge.net/p/veracrypt/discussion/technical/thread/1056ed16/)<br>
从[VeraCrypt](https://veracrypt.codeplex.com/)下载安装即可,教程很多<br>
ubuntu错误提示
```
VeraCrypt:process::Execute:88
```
安装下列解决
```
sudo apt install exfat-fuse  exfat-utils dmsetup
```
### 同步盘
选择你喜欢的。

### 效果图
win10和ubuntu16.04编辑同一笔记
![](/uploads/2018/01/zimlin.PNG)
![](/uploads/2018/01/zimwin.PNG)
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
