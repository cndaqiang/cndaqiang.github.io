---
layout: post
title:  "Linux常用命令学习"
date:   2017-09-10 12:00:00 +0800
categories: Linux
tags: Linux ubuntu 
author: cndaqiang
mathjax: true
---
* content
{:toc}

我也不清楚哪些命令是常用的，我需要哪些命令后就回来总结，先记录自己常用的，这不是本字典，命令现用现查







## 环境
Ubuntu 16.04.1 LTS (GNU/Linux 4.4.0-53-generic x86_64)

## 命令
如无特殊说明
[目录]支持绝对目录和相对目录
[文件]支持[目录]/文件
### 目录操作
#### ls [选项] [目录]
[ls 的顺序与倒序排列@everfight](https://www.cnblogs.com/everfight/p/linux_ls.html)
```
ls
```
查看当前目录下的文件
```
ls -a 
```
列出所有文件，包括隐藏文件和.
```
ls -l
```
显示权限，所有者信息，文件类型
```
ls -t
```
**按照时间排序**
```
ls -rt
```
**按照是时间反向排序**
```
ls -d */
ls -d $HOME/*/
```
**只展示文件夹**

![](http://upload-images.jianshu.io/upload_images/4575564-e202a67a455af2e5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


>**权限**
8进制 读r4 写w2 执行x1

>**文件类型**
-d 目录
-l 符号链接
-c 字符设备，如鼠标键盘
-d 区块设备，如硬盘
-s 数据接口文件(sockets)

>**ls彩色目录**
>1. 蓝色-->目录
>  2. 绿色-->可执行文件
>  3. 红色-->压缩文件
>4. 浅蓝色-->链接文件
>5. 灰色-->其他文件
>开启或关闭可搜索终端颜色设置

```
ls -R
```
显示当前文件和文件夹下面的所有文件(夹)
#### cd [目录]
```
根目录 \
用户目录 ~或/home/username
上级目录 ..
当前目录 .
上一目录 -
上一条命令中的目录 !$
```
例
```
root@VM-10-194-ubuntu:/home/ftp/ftptest# cd ..
root@VM-10-194-ubuntu:/home/ftp# cd !$
cd ..
root@VM-10-194-ubuntu:/home# cd -
/home/ftp
root@VM-10-194-ubuntu:/home/ftp# 
```
#### pwd
```
pwd
```
显示当前路径
```
pwd -L 链接路径默认
pwd -P 实际路径
```
#### mkdir [选项] [目录]
```
mkdir test
```
创建test目录
```
mkdir -p /tmp/test1/test2/test3
```
递归创建目录，不存在父目录则创建
```
mkdir -m 777 test
```
创建权限为777的test目录


```
root@VM-10-194-ubuntu:/tmp/test2# mkdir -p test/{1.1/,1.2/}2/{3.1,3.2}
root@VM-10-194-ubuntu:/tmp/test2# tree test
test
├── 1.1
│   └── 2
│       ├── 3.1
│       └── 3.2
└── 1.2
    └── 2
        ├── 3.1
        └── 3.2
```
创建目录树示例，中括号{}内是并列的，其他是包含关系
```
mkdir -v test
```
创建时显示信息
#### rm [选项][文件]

```
rm 文件
```
删除文件
```
rm test*
```
删除test开头的文件，*通配符，例如*test表示test结尾的文件
```
rm -r,-R 文件夹
```
递归删除文件夹及内部的文件
>-f, --force    忽略不存在的文件，从不给出提示。
    -i, --interactive 进行交互式删除
    -v, --verbose    详细显示进行的步骤
	
#### rmdir [选项] [空目录]
rmdir**只能删除空目录**，需要对父目录有写权限

```
rmdir test
```
删除test目录
```
rm -rf *
```
删除当前目录所有文件，不要提示
```
rmdir -p test
```
删除test目录后，父目录为空则一并删除
> -v 显示信息的删除

#### mv [选项] 原文件 目标文件
可用于重命名和移动
```
mv test /tmp/te
```
移动文件test到/tmp/下并命名为te
```
mv * ../
```
移动当前目录所有文件至上级目录
详见[每天一个linux命令（7）：mv命令](http://www.cnblogs.com/peida/archive/2012/10/27/2743022.html)
#### cp [选项] 原文件 目标文件
复制文件
```
cp test1 test2
```
当test2不存在时，复制test1命名为test2
当test2存在时，复制test1到test2目录中
>在命令行下复制文件时，如果目标文件已经存在，就会询问是否覆盖，不管你是否使用-i参数。但是如果是在shell脚本中执行cp时，没有-i参数时不会询问是否覆盖。这说明命令行和shell脚本的执行方式有些不同。 

直接复制时,若是软连接,会将链接指向的文件复制过去,使用-d参数只复制软链接
```
cp -d * ../../vasp.5.4.1/bin
```
#### touch [选项] [文件]
```
touch 文件
```
新建文件
### 查看文件内容
#### cat [选项] [文件]
```
cat 文件
```
显示文件
```
cat -n 文件
```
同时显示行号
还可与重定向>配合使用[20170805bash学习](http://www.jianshu.com/p/2438d563de06)<br>
输出到文件
```
# cat >b.txt <<EOF
content
> EOF
```
#### nl [选项] [文件]
```
nl 文件
```
列出文件内容和行号
#### more [选项] [文件]
```
more 文件
```
按行翻阅文件内容
#### 略
less，head，tail，
### 查找

#### which在PATH中查找命令
```
which ls
```
查找ls所在路径

#### whereis [-bmsu] [BMS 目录名 -f ] 文件名 
```
-b   定位可执行文件。
-m   定位帮助文件。
-s   定位源代码文件。
-u   搜索默认路径下除可执行文件、源代码文件、帮助文件以外的其它文件。
-B   指定搜索可执行文件的路径。
-M   指定搜索帮助文件的路径。
-S   指定搜索源代码文件的路径。
```
whereis命令只能用于程序名的搜索，基于数据库查询，而且只搜索二进制文件（参数-b）、man说明文件（参数-m）和源代码文件（参数-s）。如果省略参数，则返回所有信息。
 
例 
```
ubuntu@VM-10-194-ubuntu:~$ whereis ls
ls: /bin/ls /usr/share/man/man1/ls.1.gz
ubuntu@VM-10-194-ubuntu:~$ whereis -b ls
ls: /bin/ls
```

#### find [目录] [条件] [动作]
目录缺省为当前目录<br>
条件缺省匹配所有<br>
动作缺省，无动作<br>
```
举例：查找当前文件夹下所有文件，文件名或路径包含xv
find | grep xv
在/tmp目录中找名为test的文件
find /tmp -name test

目录：如~,.,/etc
条件：
-name 文件名(支持缩略，如"*.c"、"*xv*")
-perm 权限(如755)
-mmin -10 过去十分钟内更新的
动作：
-ls 显示详细信息

```
更多用法[每天一个linux命令（19）：find 命令概览](http://www.cnblogs.com/peida/archive/2012/11/13/2767374.html)

### 打包压缩
#### tar[必要参数][选择参数][文件] 
##### 使用tar进行解包打包，并不压缩
```
解包：tar xvf FileName.tar
打包：tar cvf FileName.tar DirName
```

用原来的文件权限还原文件；
```
tar xpvf FileName.tar
```

```
-A或--catenate：新增文件到以存在的备份文件； 
-B：设置区块大小； 
-c或--create：建立新的备份文件； 
-C <目录>：这个选项用在解压缩，若要在特定目录解压缩，可以使用这个选项。 
-d：记录文件的差别； 
-x或--extract或--get：从备份文件中还原文件； 
-t或--list：列出备份文件的内容； 
-z或--gzip或--ungzip：通过gzip指令处理备份文件； 
-Z或--compress或--uncompress：通过compress指令处理备份文件； 
-f<备份文件>或--file=<备份文件>：指定备份文件； 
-v或--verbose：显示指令执行过程； 
-r：添加文件到已经压缩的文件； 
-u：添加改变了和现有的文件到已经存在的压缩文件； 
-j：支持bzip2解压文件； 
-v：显示操作过程； 
-l：文件系统边界设置； 
-k：保留原有文件不覆盖； 
-m：保留文件不被覆盖； 
-w：确认压缩文件的正确性； 
-p或--same-permissions：用原来的文件权限还原文件； 
-P或--absolute-names：文件名使用绝对名称，不移除文件名称前的“/”号； 
-N <日期格式> 或 --newer=<日期时间>：只将较指定日期更新的文件保存到备份文件里； 
--exclude=<范本样式>：排除符合范本样式的文件。
```
##### tar可调用压缩解压命令
更多参数和压缩解压命令[每天一个linux命令（28）：tar命令](http://www.cnblogs.com/peida/archive/2012/11/30/2795656.html)

#### split 分割大文件
```
split -b 300m (拆包尺寸)  MoS2_T4_O0.25_p2.tar.gz (源文件) MoS2_T4_O0.25_p2.tar.gz_ (拆包后的prefix)
MoS2_T4_O0.25_p2.tar.gz_aa
MoS2_T4_O0.25_p2.tar.gz_ab
MoS2_T4_O0.25_p2.tar.gz_ac
MoS2_T4_O0.25_p2.tar.gz_ad

#-d使用数字后缀
split -b 300m  -d  MoS2_T4_O0.25_p2.tar.gz MoS2_T4_O0.25_p2.tar.gz_
MoS2_T4_O0.25_p2.tar.gz_00
MoS2_T4_O0.25_p2.tar.gz_01
MoS2_T4_O0.25_p2.tar.gz_02
MoS2_T4_O0.25_p2.tar.gz_03

#-aN 后缀长度为N
split -b 300m  -d -a1  MoS2_T4_O0.25_p2.tar.gz MoS2_T4_O0.25_p2.tar.gz_
MoS2_T4_O0.25_p2.tar.gz_0
MoS2_T4_O0.25_p2.tar.gz_1
MoS2_T4_O0.25_p2.tar.gz_2
MoS2_T4_O0.25_p2.tar.gz_3
```
分割后恢复
```
cat MoS2_T4_O0.25_p2.tar.gz_* > MoS2_T4_O0.25_p2.tar.gz
tar xzvf 
cat MoS2_T4_O0.25_p2.tar.gz_* | tar xzv #没有f
```


### 空间占用
#### df [选项] [文件]
查看磁盘使用和剩余
```
df
```
查看磁盘使用和剩余
```
df -h
```
以K,M,G等易于识别的单位显示磁盘使用和剩余
#### du [选项] [文件]
查看文件(夹)大小
```
du
```
查看文件夹大小,文件夹会一直显示文件夹内的文件(夹)，查看文件du 文件名
```
du -h
```
以K,M,G等易于识别的单位显示文件夹大小，查看文件 du -h 文件名
### 改权限，所有者
![](http://upload-images.jianshu.io/upload_images/4575564-e202a67a455af2e5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#### chown [选项]... [所有者][:[组]] 文件...
```
chown 用户名文件
```
更改文件所属用户
```
chown 用户名:用户组 文件
```
更改文件所属用户和用户组
#### chgrp [选项] [组] [文件]
```
chgrp 用户组 文件
```
更改文件的用户组
#### chmod
8进制 读r4 写w2 执行x1
拥有读r和写w权限则权限设置为4+2=6
```
chmod 762 文件
```
设置文件的所有者，所有者所在用户组其他成员，其他成员权限分别为7，6，2
### 进入单用户模式
参考<br>
[ubuntu 通过grub进入单用户root模式，已进行密码的修改](http://www.tk4479.net/hero9881010love/article/details/44202137)
<br>在安装配置的过程中，或者在添加开机启功项时，可能错误配置导致无法开机，可以进入单用户模式改回配置，或者重新设置密码等选项<br>
- 开机进入GRUB
- 选择Advanced options for Ubuntu
- 选中recovery mode
- 按e进入编辑状态
- 将**linux开头**那行的"ro recovery nomodeset"改为 “rw single init=/bin/bash”
<br>(注意：ro 是只读模式，rw是读写模式。)
- 按Ctrl + x, 进入单用户模式


### 网络
#### ifconfig [网络设备] [参数]
>用ifconfig命令配置的网卡信息，在网卡重启后机器重启后，配置就不存在。要想将上述的配置信息永远的存的电脑里，那就要修改网卡的配置文件了。
```
ifconfig
```
查看激活的网卡连接情况

![](http://upload-images.jianshu.io/upload_images/4575564-882141bc64f71d3f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

属性|值
-|-
HWaddr|mac地址
inet|ipv4地址
inet6|ipv6地址
Bcast|网关
Mask|子网掩码
UP|代表网卡开启状态
RUNNING|代表网卡的网线被接上
MULTICAST|支持组播
MTU:1500|最大传输单元:1500字节
RX|收到的数据包，可根据后面的丢包等情况判断网络
TX|发送的数据包

```
ifconfig lo down
```
关闭lo网卡，ifconfig后不再显示lo网卡
```
ifconfig lo up
```
开启lo网卡
```
ifconfig eth0 add 192.168.1.2 
```
给eth0添加ip 192.168.1.2,发现增加了一个网卡eth0:0

`ifconfig eth0 del 192.168.1.2` 删除ip命令在ubuntu上无效？？

```
ifconfig eth0 hw ether 52:54:00:5c:f4:9a
```
**修改**mac地址
```
ifconfig eth0 10.105.10.195 netmask 255.255.192.0 broadcast 10.105.63.255
```
**修改** ip地址 掩码 广播地址
#### 永久更改ip/dhcp,mac地址
```
vi /etc/network/interfaces
```
dhcp
```
auto eth0
iface eth0 inet dhcp
```
固定ip
```
auto eth0
iface eth0 inet static
address 10.105.10.194
netmask 255.255.192.0
gateway 10.105.0.1
```
添加ip地址
在该文件中添加如下的行
```
auto eth0:1
iface eth0:1 inet static
address 192.168.1.60
netmask 255.255.255.0
network x.x.x.x
broadcast x.x.x.x
gateway x.x.x.x
```
固定mac地址
```
hw ether 66:42:9e:48:72:xx
```
重启生效
`/etc/init.d/networking restart`
#### 更改主机名
```
/bin/hostname 
```
显示主机名
```
/bin/hostname newname
```
更改主机名
#### 更改dns
```
vi /etc/resolv.conf
```
添加`nameserver DNS的ip地址`
其他参数教程中的参数表达意思我还不理解，展示不记录

#### 无线网配置
参考
<br>[ubuntu下命令行连接wifi](http://blog.csdn.net/gujing001/article/details/8309992)
<br>[在命令行中管理 Wifi 连接](https://linux.cn/article-4015-1.html)
<br>查看无线网卡名称
```
iwconfig
```
例如我的无线网卡名是`wlp3s0`，下面出现该名指代无线网卡名称
<br>开启服务`sudo ip link set wlp3s0 up`或`sudo ifconfig wlp3s0 up`
<br>搜索无线网` sudo iwlist wlp3s0 scan`
<br>连接无密码的无线网 `sudo iwconfig wlp3s0 essid 网络SSID`或`sudo iw dev wlp3s0 connect 网络SSID`
<br>**连接无线网后，需启动dhcp才能获得ip**
<br>通过dhcp获取IP　`sudo dhclient wlp3s0`
<br>连接上网络后，可以下载`wpasupplicant`认证wpa或wpa2协议的无线了`sudo apt install wpasupplicant`
- 新建`/etc/wpa_supplicant/wpa_supplicant.conf`文件，填入<br>
```
network={
ssid="网络SSID"
psk="密码"
priority=1
}
```
- 启动wifi<br>
```
sudo wpa_supplicant -i wlp3s0 -c /etc/wpa_supplicant/wpa_supplicant.conf
```
- 获取ip<br>
```
sudo dhclient wlp3s0
```
- 设置开机自动连wifi<br>
修改`/etc/rc.local`填入
```
wpa_supplicant -i wlp3s0 -c /etc/wpa_supplicant/wpa_supplicant.conf &
dhclient wlp3s0
```


### netstat
查看与IP、TCP、UDP和ICMP协议相关的统计数据
```
netstat
```
查看建立的连接
![](http://upload-images.jianshu.io/upload_images/4575564-907c67110b62fbdd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

其中local Address 中有10.105.10.194:ssh，ssh就代表了ssh默认端口号
```
netstat -a
```
列出所有端口包括监听端口，如图listen

![](http://upload-images.jianshu.io/upload_images/4575564-d4975672965a6cae.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### ln [参数][源文件或目录][目标文件或目录]

**目录为绝对路径**

>**软连接和硬链接**
软链接：
1.软链接，以路径的形式存在。类似于Windows操作系统中的**快捷方式**
2.软链接可以跨文件系统 ，硬链接不可以
3.软链接可以对一个不存在的文件名进行链接
4.软链接可以对**目录**进行链接
硬链接:
1.硬链接，以**文件副本**的形式存在。但不占用实际空间。
2.**不允许给目录创建硬链接**
3.硬链接只有在同一个文件系统中才能创建

```
root@VM-10-194-ubuntu:/tmp# ln -s /var/www/html/index.html ruan
root@VM-10-194-ubuntu:/tmp# ln  /var/www/html/index.html ying
root@VM-10-194-ubuntu:/tmp# du -h *
0	ruan
12K	ying
root@VM-10-194-ubuntu:/tmp# ls -l
total 12
lrwxrwxrwx 1 root root    24 Sep 11 20:14 ruan -> /var/www/html/index.html
-rw-r--r-- 2 root root 11321 Sep  3 21:18 ying
```
对/var/www/html/index.html文件分别创建软连接ruan，硬链接ying，并查看大小，属性,对于软连接/var/www/html/index.html换为**绝对目录**也可以
可看到:
软连接是快捷方式，不占大小，就是一个可以修改的快捷方式，指向谁都可以，即使对方不存在，所以搭建网页时，若使用软连接 `http://domain../软连接` 后面不需要再加/**??**
硬链接是副本，有大小，显示的也是源文件的权限信息（副本必然一样），既然是副本了，要求同一文件系统没毛病

对连接文件进行的修改和原文件是同步的
### wget [参数] [URL地址]
>wget可以在用户退出系统的之后在后台执行
当网络的原因下载失败，wget会不断的尝试，直到整个文件下载完毕。如果是服务器打断下载过程，它会再次联到服务器上从停止的地方继续下载
```
wget ftp://f.test.cn:17828/download/kaying%20tools.exe
```
下载文件
```
wget --ftp-user=USERNAME --ftp-password=PASSWORD url
```
ftp账户密码
```
wget -b http://test.com/index.html
```
在后台下载http://test.com/index.html文件
```
wget -c ftp://f.test.cn:17828/download/kaying%20tools.exe
```
下载中断后，续传
```
wget -O test  ftp://f.test.cn:17828/download/kaying%20tools.exe
```
下载并重命名为test
```
wget --user-agent="Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US) AppleWebKit/534.16 (KHTML, like Gecko) Chrome/10.0.648.204 Safari/534.16" ftp://f.test.cn:17828/download/kaying%20tools.exe
```
伪装代理user-agent下载
>使用wget –mirror镜像网站
命令：`wget --mirror -p --convert-links -P ./LOCAL URL`
说明：
下载整个网站到本地。
--miror:开户镜像下载
-p:下载所有为了html页面显示正常的文件
–convert-links:下载后，转换成本地的链接
-P ./LOCAL：保存所有文件和目录到本地指定目录

忽视robots加上`-e robots=off`参数
```
wget -r -e robots=off http://www.xxx.com/test/
```
-r 也可下载整站，-r表示递归<br>
**-np 递归下载时不搜索上层目录**

```
需要下载某个目录下面的所有文件。
命令如下
wget -c -r -np -k -L -p http://docs.openstack.org/liberty/install-guide-rdo/

在下载时。有用到外部域名的图片或连接。如果需要同时下载就要用-H参数。
wget -np -nH -r –span-hosts www.xianren.org/pub/path/
-c 断点续传
-r 递归下载，下载指定网页某一目录下（包括子目录）的所有文件
-nd 递归下载时不创建一层一层的目录，把所有的文件下载到当前目录
-np 递归下载时不搜索上层目录，如wget -c -r www.xianren.org/pub/path/
没有加参数-np，就会同时下载path的上一级目录pub下的其它文件
-k 将绝对链接转为相对链接，下载整个站点后脱机浏览网页，最好加上这个参数
-L 递归时不进入其它主机，如wget -c -r www.xianren.org/
如果网站内有一个这样的链接：
www.xianren.org，不加参数-L，就会像大火烧山一样，会递归下载www.xianren.org网站
-p 下载网页所需的所有文件，如图片等
-A 指定要下载的文件样式列表，多个样式用逗号分隔
-i 后面跟一个文件，文件内指明要下载的URL
--------------------- 
原文：https://blog.csdn.net/zelinhehe/article/details/53508845 
```

下载指定类型的文件
```
wget  -r -np -P ./pdf -A pdf  www.iiserpune.ac.in/~smr2626/talks-presentations.html
```

### 安装卸载软件
#### dpkg
```
dpkg -L 安装包名 | more
```
可以查看，安装后添加了哪些目录
这个more用的很好，
```
命令 --help | more
```
也可以少看命令
#### apt-get
彻底删除软件及配置
```
apt-get remove --purge 软件名称  
```
适合修改vsftpd软件配置文件后，用apt-get remove vsftpd卸载不干净，重装配置文件不变

## 虚拟内存
参考[宁哥的小站-Linux下如何添加虚拟内存](http://www.lining0806.com/linux%E4%B8%8B%E5%A6%82%E4%BD%95%E6%B7%BB%E5%8A%A0%E8%99%9A%E6%8B%9F%E5%86%85%E5%AD%98/)
查看内存
```
free -h
```
添加虚拟内存文件
```
dd if=/dev/zero of=/mnt/swapfile bs=1M count=2048
```

>其中，if表示input_file输入文件，of表示output_file输出文件，bs表示block_size块大小，count表示计数。这里，采用了数据块大小为1M，数据块数目为2048，这样分配的空间就是2G大小。

格式化交换文件：
```
mkswap /mnt/swapfile
```
挂载交换文件：
```
swapon /mnt/swapfile
```
开机挂载
在`/etc/fstab`文件中加入
```
/mnt/swapfile swap swap defaults 0 0
```

## 添加PATH
编译完软件后,如果不是安装到系统PATH路径，则需要将安装路径添加到系统的PATH路径<br>
执行命令，报错`xxxx : command not found`,可能没有安装相关软件，或者PATH中不包含该命令<br>

### 仅此次登陆生效
```
source 包含路径的文件
```
文件的内容如下面的`/etc/profile`
`exit`退出后失效
### 永久生效
修改`/etc/profile`(所有用户)或者`~/.bashrc`(单个用户)
<br>加入
```
export PATH=目录:$PATH
```
说明:
- `/etc/profile`对所有用户，登陆时会读取里面的PATH
- `~/.bashrc`,单个用户的PATH登陆时读取自己home目录下面的`.bashrc`文件
- 修改后`exit`,重新登陆，修改内容生效
- 立即生效，执行`source 文件名`，**仅对执行该命令的用户有效**

**`/etc/profile`只对通过shell登陆的账户有效,`sudo su`获得的root权限不会加载`/etc/profile`**，使用 `su -`或`su username`
```
[cndaqiang@master  ]$ sudo su
[sudo] password for cndaqiang: 
[root@master  ]# echo $TORQUE_HOME

[root@master  ]# su -
Last login: Fri Nov  6 11:22:39 CST 2020 on pts/2
[root@master ~]# echo $TORQUE_HOME
/opt/CC19/torque6
```
### sudo的PATH
有时执行`sudo `时提示`xxxx : command not found`，但是却有该命令,原来，sudo的PATH路径不是普通用户或root的路径，这时可以`sudo su`后执行，或更改sudo的PATH<br>
```
sudo visudo
```
修改添加此行内容
```
Defaults        secure_path=
```
看来我以后，还是用`sudo su`吧

## 添加其他变量
仅在本shell中生效
```
变量=值
```
在本shell及子shell中生效:如编译、计算调用一些库和程序时
```
export 变量=值
```
执行完会影响父shell
```
source 文件名/指令
```
`source 文件名`表示在当前shell中执行文件中的指令，`./文件名`表示在子shell中执行
## 用户管理
参考
<br>[一天一点linux(18):adduser和useradd的区别](https://segmentfault.com/a/1190000007316406)
<br>[linux用户管理（1）----创建用户（adduser和useradd）和删除用户（userdel）](http://blog.csdn.net/beitiandijun/article/details/41678251)

### 添加用户
- `adduser username`
<br>会自动为创建的用户指定主目录、系统shell版本，会在创建时输入用户密码。
<br>创建密码`passwd username`
- `useradd username`
<br>需要使用参数选项指定上述基本设置，如果不使用任何参数，则创建的用户无密码、无主目录、没有指定shell版本

## 切换用户
```
su username
```

### 删除用户
```
userdel -r mongo
```
>-r参数删除用户mongo的同时，将其宿主目录和系统内与其相关的内容删除

## 硬盘挂载相关
参考[「咸鱼干嘛呢」](https://blog.csdn.net/qq_37227125/article/details/94882056)

### 弹出驱动器

```
udisksctl unmount -b /dev/sdc1					//卸载挂载点。相当与(umount /devsdc1)
udisksctl power-off -b /dev/sdc1				//安全关闭驱动器
```

## 一些好玩的命令
### sleep
```
#sleep命令常用于在shell脚本中延迟时间
#延迟n秒
sleep <n>
sleep <n>s
#延迟<n>分钟
sleep <n>m
#延迟<n>小时
sleep <n>h
#延迟<n>天
sleep <n>d
```
### scp
参考[利用scp 远程上传下载文件/文件夹](http://www.cnblogs.com/no7dw/archive/2012/07/07/2580307.html)
```
#从服务器下载文件
scp username@servername:/path/filename /tmp/local_destination
#上传本地文件到服务器
scp /path/local_filename username@servername:/path  
#从服务器下载整个目录
scp -r username@servername:remote_dir/ /tmp/local_dir 
#上传目录到服务器
scp  -r /tmp/local_dir username@servername:remote_dir
```
服务器地址为ipv6地址时,servername用`[]`括起来，如
```
[xxxx:dc01:xxxx:xxx:xxxx:3f37:75fd:788a]
```
使用非22端口时，在scp和文件**之间**加入`-P 端口号`,如
```
scp -P 1234 /path/local_filename username@servername:/path  
```

`:`后面不输入地址就默认是家目录
```
#复制到home目录
scp -r CaB2F8_107953_moxel0.001_Fren9eV chendq@node8:
#复制到home目录下的work目录
scp -r CaB2F8_107953_moxel0.001_Fren9eV chendq@node8:./work
```

### 短时间内设置语言为英文
装了centos,系统默认中文,安装软件报错不好搜索,短期设置为英文
```
export LANG=en_US.UTF-8
```

### 产生等差数列
```
seq 初值 步长 终值
```

### 查看cpu温度
使用笔记本计算时，温度感人<br>
**GUI**
ubuntu可以直接在商店中安装temperature，图形化显示<br>
安装后需运行`sudo snap connect sensors-unity:hardware-observe :hardware-observe`才能正常检测(命令参考软件安装界面的Note,如无效，请看最新的Note)
<br>**命令模式**
```
sudo apt-get install lm-sensors
sudo sensors-detect
#一路YES
sudo service kmod start
sensors
```
centos命令行用yum同理

### 查看cpu信息
```
cat /proc/cpuinfo
```
实时查看cpu运行频率
```
watch -n 1 "cat /proc/cpuinfo | grep MHz"
```
### 限制CPU频率
参考[Linux限制cpu睿频&限制频率](https://www.jianshu.com/p/acc0f11be8cf)
```
1.关闭睿频
echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
2.限制CPU最大频率到50%
echo "50" | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct

两个办法都可以，方法2更灵活，全程可以通过下面的命令实时查看：
watch -n 0 "cat /proc/cpuinfo | grep -i mhz"
```
实际频率并不能达到最大睿频，如设置频率在86%-100%，实际计算频率一样

### 查看用户登陆历史
```
who /var/log/wtmp
cndaqiang pts/0        2019-10-18 19:15 (192.168.1.9)
cndaqiang pts/0        2019-10-18 23:11 (192.168.1.9)
cndaqiang pts/0        2019-10-25 23:30 (192.168.1.5)
cndaqiang pts/1        2019-10-26 09:06 (192.168.1.222)
cndaqiang pts/0        2019-10-26 22:09 (192.168.1.24)
cndaqiang pts/0        2019-10-28 17:04 (192.168.1.24)
cndaqiang pts/1        2019-10-28 17:21 (192.168.1.24)
cndaqiang pts/1        2019-10-28 17:27 (192.168.1.24)
cndaqiang pts/1        2019-10-28 18:02 (192.168.1.24)
cndaqiang pts/1        2019-10-28 18:04 (192.168.1.24)
```

### 踢出用户
上次正在计算，断网了，程序还在后台计算
```
[cndaqiang@mom ~]$ who
cndaqiang pts/0        2018-10-04 15:45 (win10.lan)
cndaqiang pts/3        2018-10-04 15:48 (win10.lan)
cndaqiang pts/4        2018-10-04 15:53 (win10.lan)
[cndaqiang@mom ~]$ pkill -KILL -t pts/0
```
### 同时输出结果到屏幕和文件
参考[linux命令tee：将信息同时输出到屏幕和文件](http://blog.csdn.net/dazhi_100/article/details/45022253)
tee<br>
实例
```
ls | tee out.txt
```

### 扫描局域网的ip和mac地址
```
sudo nmap -sP -PI -PT -oN ipandmaclist.txt 10.127.1.0/24
```
### 断开ssh后，保持程序运行
参考[Linux 技巧：让进程在后台可靠运行的几种方法](https://www.ibm.com/developerworks/cn/linux/l-cn-nohup/index.html)<br>
1. 在程序执行前，使用nohup
```
nohup 命令 &
```
2. setsid<br>
在使用ssh开socks隧道时，希望在后台运行，nohup,(命令 &)，screen，disown等无法使用，使用setsid可以<br>
就可以使用ipv6加服务器，免费使用网络了
```
setsid ssh -D 192.168.1.178:5678 -p 1234 username@ipv6128.qiang
```
免密码登陆ssh，还要将客户端的`~/.ssh/id_rsa.pub`(使用`ssh-keygen`生成)里的内容，追加到服务器的`~/.ssh/authorized_keys`(如果没有就新建，权限400或600)里面<br>
**如果无意把自己的家目录权限设为了777,也是不可以用的**
当然，对于ssh的后台，这条命令更好用
```
ssh  -f -N -D 192.168.1.178:5678 -p 1234 username@ipv6128.qiang
```
3. 如果程序已经运行了，使用disown
```
#ctrl+z后台
^Z
[3]+  Stopped                 runvasp 10
#bg %job号，如本例为3,也可用jobs命令查看
#使暂停的后台job运行
[cndaqiang@mom 3]$ bg %3
[3]+ runvasp 10 &
RMM:   7    -0.688651957131E+02    0.23242E-04   -0.10489E-04  6514   0.318E-02    0.133E-02
#让job忽略HUP信号，断开ssh后，仍能运行
[cndaqiang@mom 3]$ disown -h %3
```

### ssh相关

使用socks代理连接服务器
```
ssh -o "ProxyCommand nc -X 5 -x 127.0.0.1:1200 %h %p" cndaqiang@mom
```

### 等待 
```
sleep .5 # Waits 0.5 second.
sleep 5  # Waits 5 seconds.
sleep 5s # Waits 5 seconds.
sleep 5m # Waits 5 minutes.
sleep 5h # Waits 5 hours.
sleep 5d # Waits 5 days.
```

### 报错
#### no matching key exchange method found
连接openwrt时报错
```
(python37) cndaqiang@mac ~$ ssh root@192.168.10.1
Unable to negotiate with 192.168.10.1 port 22: no matching key exchange method found. Their offer: diffie-hellman-group14-sha1,diffie-hellman-group1-sha1,kexguess2@matt.ucc.asn.au
```
解决
```
ssh root@192.168.10.1   -oKexAlgorithms=+diffie-hellman-group1-sha1
```

### 备份磁盘
```
dd if=/dev/sdb of=mbr.bin
另开窗口，查看进度
watch -n 5 killall -USR1 dd
```
### 克隆磁盘
```
dd if=/dev/sdb of=/dev/sdc
dd if=/dev/sdb3 of=/dev/sdc3
```

### 括号的作用
[shell中各种括号的作用()、(())、[]、[[]]、{}](https://blog.csdn.net/taiyang1987912/article/details/39551385)<br>
`(command)`新开subshell中执行命令，变量继承，变量不返回
```
(python27) ~/code/qe-6.4.1 $ a=hello
(python27) ~/code/qe-6.4.1 $ (a=b; echo $a)
b
(python27) ~/code/qe-6.4.1 $ echo $a
hello
```


### 判断文件(夹)存在，变量相等
[emanlee shell bash判断文件或文件夹是否存在](https://www.cnblogs.com/emanlee/p/3583769.html)<br>

**`-x`参数判断 $folder 是否存在并且是否具有可执行权限**
```
if [ ! -x "$folder"]; then
  mkdir "$folder"
fi
```
**`-d` 参数判断 $folder 是否存在**
```
if [ ! -d "$folder"]; then
  mkdir "$folder"
fi
```

**` -f` 参数判断 $file 是否存在**
```
if [ ! -f "$file" ]; then
  touch "$file"
fi
```

**`-n`判断一个变量是否有值**
```
if [ ! -n "$var" ]; then
  echo "$var is empty"
  exit 0
fi
```

**判断两个变量是否相等**
```
if [ "$var1" = "$var2" ]; then  #这里一个等号两个等号都可以
  echo '$var1 eq $var2'
else
  echo '$var1 not eq $var2'
fi
```

### [挖坑]diff比较文件差异
貌似diff可以区分二进制文件的不同
```
cndaqiang@girl:~/work/input_0$ diff siesta1.RHO TDStep/siesta1.RHO 
cndaqiang@girl:~/work/input_0$ diff siesta1.RHO TDStep/siesta2.RHO 
Binary files siesta1.RHO and TDStep/siesta2.RHO differ
```

### 显示进度条的复制 `alias cp="rsync -avPh"`

```bash
rsync -avPh  Accelrys_Materials_Studio_8.0_Win.iso  /home/data/sf10nas/
```

### 查看系统重启运行时间
```bash
cndaqiang@mboy:~$ who -b
         system boot  2020-10-20 09:00
cndaqiang@mboy:~$ who -r
         run-level 5  2020-10-20 09:00
```
### 查看发行版,内核,位数
```
cndaqiang@mboy:~$ cat /etc/issue
Linux Mint 19 Tara \n \l

cndaqiang@mboy:~$ cat /proc/version
Linux version 4.15.0-20-generic (buildd@lgw01-amd64-039) (gcc version 7.3.0 (Ubuntu 7.3.0-16ubuntu3)) #21-Ubuntu SMP Tue Apr 24 06:16:15 UTC 2018

cndaqiang@mboy:~$ getconf LONG_BIT
64
```


### montage 合并，拆解图片
合并图片
```
montage PDOS_woU.png PDOS_aU.png -tile 2x1  -geometry 500x300  out.png
montage PDOS_woU.png PDOS_aU.png (各个输入图片) -tile 2x1(-tile 列数x行数)  -geometry 500x300(-geometry 设置输入图片组成整体时的分辨率)  out.png(输出图片)
```

### 获取上层目录名dirname
找到相应程序的include目录
```bash
(python37) cndaqiang@mac ~$ dirname /tmp
/
(python37) cndaqiang@mac ~$ dirname $HOME
/Users
#include目录
ls $(dirname  $(which mpif90))/../include
```
### 获得文件名

```bash
(python37) cndaqiang@mommint:~$ basename $HOME
cndaqiang
```

## 参考
[peida-博客-每天一个linux命令目录](http://www.cnblogs.com/peida/)

[Ubuntu命令行修改网络配置方法](http://forum.ubuntu.org.cn/viewtopic.php?f=73&t=190174&sid=6019f19515906b2b0219f8cee52bbcdb)

[wget命令下载整站，并忽略robots.txt文件](https://www.leocode.net/article/index/17.html)

[Ubuntu终端彻底删除软件](http://www.linuxidc.com/Linux/2012-07/65455.htm)

[tar命令](http://man.linuxde.net/tar)

[Linux查看系统开机时间](https://developer.aliyun.com/article/34206)

\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
