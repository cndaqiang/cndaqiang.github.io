---
layout: post
title:  "openvz增加swap分区"
date:   2017-09-28 12:00:00 +0800
categories: Linux
tags: openvz swap
author: cndaqiang
mathjax: true
---
* content
{:toc}






## 参考
[swapon failed: Operation not permitted 解决办法](https://shipengliang.com/software-exp/swapon-failed-operation-not-permitted-%E8%A7%A3%E5%86%B3%E5%8A%9E%E6%B3%95.html)

[Create Fake Swap in OpenVZ VPS if you get swapon failed: Operation not permitted Error](http://linux-problem-solver.blogspot.com/2013/08/create-fake-swap-in-openvz-vps-if-you-get-swapon-failed-operation-not-permitted-error.html)
## 环境
Ubuntu 16.04 LTS (GNU/Linux 2.6.32-042stab116.2 x86_64)

openvz
 120M内存

## 操作
查看内存剩余
```
$ free -m
              total        used        free      shared  buff/cache   available
Mem:            128          17          80           7          29          32
```
编写增加内存脚本
```
vi mkswap.sh
```
填入
```
#!/bin/bash

SWAP="${1:-512}"

NEW="$[SWAP*1024]"; TEMP="${NEW//?/ }"; OLD="${TEMP:1}0"

umount /proc/meminfo 2> /dev/null
sed "/^Swap\(Total\|Free\):/s,$OLD,$NEW," /proc/meminfo > /etc/fake_meminfo
mount --bind /etc/fake_meminfo /proc/meminfo
```
保存后，赋予执行权限
```
chmod +x mkswap.sh
```
增加swap,下面1024单位为M，可自定义，缺省为512
```
sudo ./mkswap.sh 1024
```
查看是否增加
```
$ free -m
              total        used        free      shared  buff/cache   available
Mem:            128          20          71           9          36          24
Swap:          1024           0        1024
```
取消swap分区
```
sudo ./mkswap.sh 0
```



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
