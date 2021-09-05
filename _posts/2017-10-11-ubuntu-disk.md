---
layout: post
title:  "Ubuntu16.04挂载新硬盘并格式化硬盘"
date:   2017-10-11 12:00:00 +0800
categories: Linux
tags: Linux ubuntu 
author: cndaqiang
mathjax: true
---
* content
{:toc}








## 参考
[为 Ubuntu 加载新硬盘](http://huifeng.me/2016/04/19/new-disk-mount-to-Ubuntu/)
[ubuntu 添加新硬盘](https://gist.github.com/1292765944/387215102522dbbac233b2580e646c8c)
## 环境
Ubuntu 16.04.3 LTS (GNU/Linux 4.4.0-87-generic x86_64)
## 操作
### 查看硬盘
#### 查看方法一
##### 查看/dev下面的设备文件
>Linux 硬盘识别：
2.6 kernel以后,linux会将识别到的硬件设备,在/dev/下建立相应的设备文件.
如:
sda 表示第1块SCSI硬盘，第二块是sdb，以此类推
hda 表示第1块IDE硬盘(即连接在第1个IDE接口的Master口上)
scd0 表示第1个USB光驱.
当添加了新硬盘后,在/dev目录下会有相应的设备文件产生.cciss的硬盘是个例外,它的
设备文件在/dev/cciss/目录下.

```
$ ll -h /dev/sd*
brw-rw---- 1 root disk 8,  0 10月 11 09:20 /dev/sda
brw-rw---- 1 root disk 8,  1 10月 11 09:20 /dev/sda1
brw-rw---- 1 root disk 8,  2 10月 11 09:20 /dev/sda2
brw-rw---- 1 root disk 8,  5 10月 11 09:20 /dev/sda5
brw-rw---- 1 root disk 8, 16 10月 11 09:20 /dev/sdb
```
我们可以看到新sdb硬盘没有建立分区

#### 通过`sudo fdisk -l`也可以查看
```
$ sudo fdisk -l
Disk /dev/sdb: 40 GiB, 42949672960 bytes, 83886080 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes


Disk /dev/sda: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x6e488164

Device     Boot   Start      End  Sectors  Size Id Type
/dev/sda1  *       2048   999423   997376  487M 83 Linux
/dev/sda2       1001470 20969471 19968002  9.5G  5 Extended
/dev/sda5       1001472 20969471 19968000  9.5G 8e Linux LVM
```

可看到sda1已分区，sdb未分区
### 新建分区

```
$ sudo fdisk /dev/sdb
```
之后进入command状态，大概是这么操作的：
- 输入 m 查看帮助
- 输入 p 查看 /dev/sdb 分区的状态
- 输入 n 创建sdb这块硬盘的分区
- 选 p primary =>输入　p
- Partition number =>分一个区所以输入　1
- 其他的默认回车即可
- 最后输入 w 保存并退出 Command 状态。

操作示例
```
Command (m for help): n
# n创建分区
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
# p(primary主分区） e(extended拓展分区)
Partition number (1-4, default 1): 1
# 分区号
First sector (2048-83886079, default 2048): 
# 默认
Last sector, +sectors or +size{K,M,G,T,P} (2048-83886079, default 83886079): 
# 大小，可自定义，保持默认
Created a new partition 1 of type 'Linux' and of size 40 GiB.

Command (m for help): p
# 查看分区情况
Disk /dev/sdb: 40 GiB, 42949672960 bytes, 83886080 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xbb6c1792

Device     Boot Start      End  Sectors Size Id Type
/dev/sdb1        2048 83886079 83884032  40G 83 Linux

Command (m for help): w
# 保存
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```
在通过查看命令即可查看，新增的硬盘
### 格式化
```
$ sudo mkfs.ext4 /dev/sdb1
```

ext4为分区格式

### 挂载
#### 创建目录并挂载
```
sudo mkdir /home/data
sudo mount /dev/sdb1 /home/data
```
#### 开机自动挂载
查看sdb1的UUID
```
$ sudo blkid
```
添加UUID到`/etc/fstab`
添加`UUID=63295b70-daec-4253-b659-821f51200be9 /home/data ext4 defaults,errors=remount-ro    0       1`到`/etc/fstab`
其中UUID后面跟sdb1的UUID
重启
## 后续
如果涉及新硬盘的权限问题，可以通过chown，chmod命令调整权限

### 将GPT分区格式化为MBR
参考[Linux下GPT格式磁盘重新格式化为MBR格式](https://blog.csdn.net/zougen/article/details/79552056)<br>
使用`parted`命令

```
parted /dev/vdb
(parted)mktable
New disk label type? msdos              #分区格式MBR分区被称作msdos，其它分区aix, amiga, bsd, dvh, gpt, mac, msdos, pc98, sun, loop
Warning: The existing disk label on /dev/vdb will be destroyed and all data on
this disk will be lost. Do you want to continue?
Yes/No?Yes
```
之后再使用fdisk格式化具体格式

### 坏道检测
```
#查询坏道(时间较久)
badblocks /dev/sdb bad-blocks
#然后利用上面新建分区的方式，建的分区避开bad-blocks文件中的扇区
```



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
