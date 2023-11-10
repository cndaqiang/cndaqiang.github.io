---
layout: post
title:  "Windows powershell/CMD 等命令学习"
date:   2023-08-28 16:03:00 +0800
categories: Windows
tags: Windows Powershell
author: cndaqiang
mathjax: true
---
* content
{:toc}

我也不清楚哪些命令是常用的，我需要哪些命令后就回来总结，先记录自己常用的，这不是本字典，命令现用现查







## 环境
win10

## netsh
### 端口转发
```
netsh interface portproxy add v4tov4 listenport=6555 connectaddress=127.0.0.1 connectport=5555 [可选择listenaddress=192.168.12.123]
#还要打开防火墙端口
#展示v4tov4的映射
netsh interface portproxy show all
#删除
netsh interface portproxy delete v4tov4 listenport=6555 listenaddress=192.168.12.123
```

### 打开防火墙端口
```
netsh advfirewall firewall add rule name="6555ADB" dir=in action=allow protocol=TCP localport=6555
#删除
netsh advfirewall firewall delet rule name="6555ADB"
```

## 软连接
```
New-Item -ItemType SymbolicLink -Path monizhan.win.py -Target .\duokai.py
```
这种方式创建的快捷方式在图形化界面右键属性无法修改.
硬连接`HardLink`



## start
start在cmd中才能**获得良好的体验**,powershell中执行的结果经常报错,参数识别的有问题
```

START ["title"] [/D path] [/I] [/MIN] [/MAX] [/SEPARATE | /SHARED]
      [/LOW | /NORMAL | /HIGH | /REALTIME | /ABOVENORMAL | /BELOWNORMAL]
      [/NODE <NUMA node>] [/AFFINITY <hex affinity mask>] [/WAIT] [/B]
      [command/program] [parameters]

    "title"     在窗口标题栏中显示的标题。
    path        启动目录。
    B           启动应用程序，但不创建新窗口。
                应用程序已忽略 ^C 处理。除非应用程序
                启用 ^C 处理，否则 ^Break 是唯一可以中断
                该应用程序的方式。
    I           新的环境将是传递
                给 cmd.exe 的原始环境，而不是当前环境。
    MIN         以最小化方式启动窗口。
    MAX         以最大化方式启动窗口。
    SEPARATE    在单独的内存空间中启动 16 位 Windows 程序。
    SHARED      在共享内存空间中启动 16 位 Windows 程序。
    LOW         在 IDLE 优先级类中启动应用程序。
    NORMAL      在 NORMAL 优先级类中启动应用程序。
    HIGH        在 HIGH 优先级类中启动应用程序。
    REALTIME    在 REALTIME 优先级类中启动应用程序。
    ABOVENORMAL 在 ABOVENORMAL 优先级类中启动应用程序。
    BELOWNORMAL 在 BELOWNORMAL 优先级类中启动应用程序。
    NODE        将首选非一致性内存结构(NUMA)节点指定为
                十进制整数。
    AFFINITY    将处理器关联掩码指定为十六进制数字。
```




------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
