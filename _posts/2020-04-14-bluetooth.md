---
layout: post
title:  "Mint 使用蓝牙鼠标问题"
date:   2020-04-14 17:44:00 +0800
categories: Linux
tags:  Linux
author: cndaqiang
mathjax: true
---
* content
{:toc}


![](/uploads/2020/04/desk.jpg)





买桌子，在家办公。

把电脑连上新买的蓝牙鼠标后，蓝牙各种问题，反应速度也极慢，延迟到难受。


## 删除冗余的蓝牙设备
参考[如何删除蓝牙设备？](https://chubuntu.com/questions/21129/how-can-i-remove-a-bluetooth-device.html)

在Mint的蓝牙管理界面，一个鼠标，连接失败，又多次连接后，留下很多个鼠标，图形化界面不能删除，使用命令删除
```
bluetoothctl #打开蓝牙管理器，然后在前几行就会现实已安装的蓝牙设备
#进入管理状态后就
remove MAC地址   #进行删除
```
删除`Mi Silent Mouse`示例
```
root@girl:/home/cndaqiang# bluetoothctl
[NEW] Controller AC:E0:10:DD:2E:64 girl [default]
[NEW] Device E4:C4:38:A0:4D:ED Mi Silent Mouse
[NEW] Device DC:2C:26:CF:C7:B8 RK-Bluetooth keyboard
[NEW] Device E4:C6:38:A0:4D:ED Mi Silent Mouse
#.........
[bluetooth]# remove E4:C4:38:A0:4D:ED
[DEL] Device E4:C4:38:A0:4D:ED Mi Silent Mouse
Device has been removed
[NEW] Device E4:C6:38:A0:4D:ED Mi Silent Mouse
[DEL] Device E4:C6:38:A0:4D:ED Mi Silent Mouse
[NEW] Device E4:C6:38:A0:4D:ED Mi Silent Mouse
[CHG] Device E4:C6:38:A0:4D:ED RSSI: -34
[bluetooth]# exit
```

## 蓝牙鼠标反应滞后
参考<br>
[Linux 下蓝牙鼠标延迟严重](https://www.dianbanjiu.com/post/linux-%E4%B8%8B%E8%93%9D%E7%89%99%E9%BC%A0%E6%A0%87%E5%BB%B6%E8%BF%9F%E4%B8%A5%E9%87%8D/)<br>
[[bluez] linux下蓝牙鼠标的延迟问题](https://www.voorp.com/a/linux%E8%93%9D%E7%89%99%E5%8D%A1%E9%A1%BF)

好像因为新版的驱动，没有设置一些默认参数，添加参数到配置文件
```
vi /var/lib/bluetooth/<mac-of-your-adapter>/<mac-of-your-mouse>/info
```
一般会默认电脑蓝牙的mac地址,鼠标的mac地址可用`bluetoothctl`或者图形界面查看.<br>
添加参数
```
[ConnectionParameters]
MinInterval=6
MaxInterval=6
Latency=59
Timeout=300
```
只重启蓝牙设备好像不管用，需要**重启电脑**

后续:<br>
锁屏回来后，就又是卡顿，唉～～
注销重新登陆，重连鼠标又可以了。。。
\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
