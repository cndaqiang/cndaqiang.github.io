---
layout: post
title:  "无线宝云路由器AX1800 JD-Cloud RE-CP-02 的OpenWRT配置"
date:   2024-09-12 12:06:00 +0800
categories: OpenWRT
tags: OpenWRT
author: cndaqiang
mathjax: true
---
* content
{:toc}











## 刷机教程
* [京东鲁班云刷OP固件](https://post.smzdm.com/p/avxgd6r9/)
* [京东云无线宝鲁班TTL刷机](https://www.xubiaosunny.top/post/JDCloud_luban_TTL_flash_machine_m7ko.html)

简述
* 拆机、连接ttl线，xshell等软件打开串口连接
* 网线连接电脑和路由，配置ip, tftp
* 路由网页界面控制路由器重启，此时不断在xshell中敲空格，直到进入uboot界面
* 执行mtkupgrade降级固件
* 进入鲁班老版本固件，开启ssh
* ssh连接鲁班，scp上传uboot，刷入uboot
* 重启进uboot, 刷入kernel版openwrt
* 进入openwrt，升级最新版本openwrt
* 固件仓库里的机型**mt7621-jdcloud_re-cp-02**


## 开机后的操作
* 固定ip上网
* 挂载sd卡
* Luci>系统>软件包>OPKG配置, 替换镜像地址为`https://mirrors.cernet.edu.cn/immortalwrt`
* Luci>系统>备份与升级>配置, 添加额外的备份列表`/etc/cndaqiang`
* [ipv6](/2024/01/23/openwrt-rax3000m-nand/#ipv6)

```
opkg update
opkg install luci-theme-argon
opkg install htop
opkg install shadow-useradd
#
opkg install luci-app-fileassistant
opkg install luci-app-zerotier
opkg install vim-full
opkg install luci-app-ttyd
opkg install openssh-sftp-server
opkg install luci-i18n-samba4-zh-cn
opkg install ip6tables kmod-ipt-nat6
```


## samba
手机的文件管理器连不上ksmbd开启的共享，使用samba共享
```
opkg install luci-i18n-samba4-zh-cn
useradd -m cndaqiang
passwd cndaqiang
smbpasswd -a cndaqiang
service samba4 restart
```

## bt下载
* qbittorrent 貌似不支持mips架构，解决方案

### 编译旧版本tr
openwrt默认安装的`transmission-daemon_4.0.6`版本存在问题，临时被一些pt站ban了，去[编译旧版本](/2024/01/23/openwrt-rax3000m-nand/#不编译固件只编译特定包)解决

```
#opkg install transmission-daemon
opkg install transmission-daemon_4.0.5-1_mipsel_24kc.ipk
#tr更新到4.x之后，web-control不好用了，只能用web，基于web-control的luci-app-transmission就不用装了
opkg install transmission-web
#opkg install transmission-web-control 
#opkg instal luci-app-transmission
#opkg install  luci-i18n-transmission-zh-cn
#luci修改配置
/etc/init.d/transmission stop
/etc/init.d/transmission start
```

### 编译qbittorrent失败
openwrt默认安装的`qBittorrent-Enhanced-Edition`不支持MT7621, 
[MT7621 无法正常使用 qbittorrent](https://github.com/immortalwrt/packages/issues/573)中给出的方案是使用qt5.
查找qbit的历史版本，最初是基于qt5编译的，因此
```
cd /data/openwrt/immortalwrt/feeds/packages/net/qBittorrent-Enhanced-Edition
rm -rf *
#把旧版的内容https://github.com/immortalwrt/packages/tree/f5c7d4105d60ea36b4ea218adc6bf76010654fdb/net/qBittorrent-Enhanced-Edition，下载到本文件夹
#还要下载qt5 (packages-f5c7d4105d60ea36b4ea218adc6bf76010654fdb\libs\qt5)到feeds/packages/libs/qt5
make feeds/packages/libs/qt5/compile V=s
make package/feeds/packages/qBittorrent-Enhanced-Edition/compile V=s
```



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
