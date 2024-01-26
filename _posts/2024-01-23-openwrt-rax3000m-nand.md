---
layout: post
title:  "OpenWRT编译配置:以CMCC RAX3000M为例"
date:   2024-01-23 12:06:00 +0800
categories: OpenWRT
tags: OpenWRT
author: cndaqiang
mathjax: true
---
* content
{:toc}







## 备注
- 设备CMCC RAX3000M
- 编译系统: Ubuntu 22.04, Passwd:123456
- 注1: Ubuntu版本较低(20.04)会和OpenWRT开发者的环境出现差异,无法编译新版本.
- 注2: 编译固件+常用包需要空间`>35G`, 虚拟机需要给足够空间
- 每次编译后显示的内核版本以及依赖内核版本号的关系会变
- 有些包更新系统后可以保留配置,有些还是不行,比如`/etc/opkg/distfeeds.conf`都不能保存
- - 可以在`/luci/admin/system/flash`里面配置好[备份的目录](./#设置备份文件列表),如我自己写的脚本`/etc/cndaqiang`
- 新装的系统如果各种异常,重置配置
- **感谢互联网、GPT,有些教程参考了,但是没有及时把链接复制到本文进行致谢,在此统一致谢**

## 编译固件方法
- 不仅是`./scripts/feeds`需要科学上网环境
- 编译过程中有些包如`frp`也会联网下载,使用全局代理或者`proxychains`方法
- 参考[immortalwrt](https://github.com/immortalwrt/immortalwrt/tree/openwrt-23.05)
- **`*`代表编入固件,`M`表示编译成模块或者IPK包,`空`不编译**

```bash
sudo bash -c 'bash <(curl -s https://build-scripts.immortalwrt.eu.org/init_build_environment.sh)'
git clone -b openwrt-23.05 --single-branch --filter=blob:none https://github.com/immortalwrt/immortalwrt
cd immortalwrt 
./scripts/feeds update -a
./scripts/feeds install -a
make menuconfig
make
```

proxychains编译示例(并不稳定)

```
apt install proxychains
vi /etc/proxychains.conf
#替换代理为 socks5 192.168.192.204 10092
proxychains make -j1 V=s
```

## 编译生成的固件和ipk文件列表
```
cndaqiang@cndaqiang:~/immortalwrt$ tree bin
bin
├── packages
│   └── aarch64_cortex-a53
│       ├── 这里都是一些常规的包,后期用opkg从公共仓库也可以安装
│       ├── base
│       │   ├── XXXXXX.ipk
│       │   ├── XXXXXX_aarch64_cortex-a53.ipk.ipk
│       │   ├── index.json
│       │   ├── Packages文件是用来建立ipk的仓库用,有这个文件就可以作为固件仓库使用
│       │   ├── Packages
│       │   ├── Packages.gz
│       │   ├── Packages.manifest
│       │   ├── Packages.sig
│       ├── luci
│       │   ├── 同上
│       ├── packages
│       │   ├── 同上
│       ├── routing
│       │   ├── 同上
│       └── telephony
│           └── 同上
└── targets
    └── mediatek
        └── filogic
            ├── config.buildinfo
            ├── feeds.buildinfo
            ├── 这里是打包的固件
            ├── immortalwrt-mediatek-filogic-cmcc_rax3000m-nand-ubootmod-initramfs-kernel.bin
            ├── immortalwrt-mediatek-filogic-cmcc_rax3000m-nand-ubootmod.manifest
            ├── immortalwrt-mediatek-filogic-cmcc_rax3000m-nand-ubootmod-squashfs-factory.bin
            ├── factory.bin U-Boot直接上传这一个
            ├── immortalwrt-mediatek-filogic-cmcc_rax3000m-nand-ubootmod-squashfs-sysupgrade.bin 
            ├── sysupgrade.binOpenWRT后台上传这个更新，不同的OpenWRT系统会提示警告,我在换固件警告时还是采用U-Boot上传factory版本,仅在更新自己固件时采用sysupgrade.bin
            ├── 有时候刷的factory.bin有各种异常问题,再更新一个sysupgrade.bin,并不保存配置,很多问题就消失了
            ├── packages
            │   ├── 一些额外的包,如kmod,和内核md5有关,后期如果内核版本不一样，需要重新打包或者从这里编译
            │   ├── 同上base
            ├── profiles.json
            ├── sha256sums
            └── version.buildinfo
```

## 创建个人固件仓库
### 搭建http版仓库
- 把`/home/cndaqiang/immortalwrt/bin/`复制到`www`目录即可

### 本地文件版仓库
#编译服务器推送仓库到路由器
```
rsync -avu /home/cndaqiang/immortalwrt/bin/ root@192.168.12.1:/home/NFS/immortalwrt-23.05/
#路由器需要opkg install rsync
```
#修改仓库配置
```
mv /etc/opkg/distfeeds.conf /etc/opkg/distfeeds.conf.bak
echo "
src/gz cndaqianglocal_base       file:///home/NFS/immortalwrt-23.05/packages/aarch64_cortex-a53/base
src/gz cndaqianglocal_luci       file:///home/NFS/immortalwrt-23.05/packages/aarch64_cortex-a53/luci
src/gz cndaqianglocal_packages   file:///home/NFS/immortalwrt-23.05/packages/aarch64_cortex-a53/packages
src/gz cndaqianglocal_routing    file:///home/NFS/immortalwrt-23.05/packages/aarch64_cortex-a53/routing
src/gz cndaqianglocal_telephony  file:///home/NFS/immortalwrt-23.05/packages/aarch64_cortex-a53/telephony
src/gz cndaqianglocal_targets    file:///home/NFS/immortalwrt-23.05/targets/mediatek/filogic/packages
" > /etc/opkg/distfeeds.conf
```


使用个人固件示例
```
root@CRouter:/etc/cndaqiang/clash/subconverter# opkg install htop
Installing htop (3.3.0-1) to root...
Downloading file:///home/NFS/immortalwrt-23.05/packages/aarch64_cortex-a53/packages/htop_3.3.0-1_aarch64_cortex-a53.ipk
Configuring htop.
```

## 修改编译输出的内核版本
- 从而保证自己不同时期编译的内核版本是相同的,以方便更新一些依赖内核的包
- 另外让版本显示和官方的仓库一样,也方便联网安装
- https://blog.csdn.net/bjr2016/article/details/107776801
- 因为我都是自己编译的ipk,没有冲突的问题,万一将来不想编译某个软件,就想利用官方仓库,提前避免冲突

查看官方的仓库`https://mirrors.vsean.net/openwrt/releases/23.05-SNAPSHOT/targets/sunxi/cortexa53/kmods/`确定内核md5得到`5.15.146-1-24c201741aa3cde887b045d07c2eabc1/`
查看已经编译的md5
```
cndaqiang@cndaqiang:~/immortalwrt$ cat ./build_dir/target-aarch64_cortex-a53_musl/linux-mediatek_filogic/linux-5.15.146/.vermagic
ca77fd682e2cf88329a642815770f8a8
```

这样替换
```
vi include/kernel-defaults.mk
```
注意是`Tab`键+`echo ...`
```
        #grep '=[ym]' $(LINUX_DIR)/.config.set | LC_ALL=C sort | $(MKHASH) md5 > $(LINUX_DIR)/.vermagic
        echo 24c201741aa3cde887b045d07c2eabc1 > $(LINUX_DIR)/.vermagic
```

```
vi package/kernel/linux/Makefile
```

```
ifeq ($(DUMP),)
  #STAMP_BUILT:=$(STAMP_BUILT)_$(shell $(SCRIPT_DIR)/kconfig.pl $(LINUX_DIR)/.config | $(MKHASH) md5)
  STAMP_BUILT:=$(STAMP_BUILT)_24c201741aa3cde887b045d07c2eabc1
  -include $(LINUX_DIR)/.config
endif
```
再重新编译,需要清除一些与内核有关包
```
cndaqiang@cndaqiang:~/immortalwrt$ rm bin/targets/mediatek/filogic/packages/*
```

更新之后
```
root@CRouter:~# opkg info kernel | grep 'Version'
Version: 5.15.146-1-24c201741aa3cde887b045d07c2eabc1
```


## 编译固件时选择哪些安装包

### 查找特定包位置

- **`make menuconfig`后`/`搜索**
- **网页查找:** 搜索`openwrt package package_name`
- - 如通过`https://openwrt.org/packages/pkgdata/ip6tables-extra`页面为例,可以看到:`Categories:network---firewall`

### 我常编译的包的配置
```
Administration
├── htop
Base system
Customize busybox options
Shells
development
├── diffutils
Extra packages
├── ipv6helper
luci
│   └── Applications
│       ├── luci-app-fileassistant #在luci界面浏览编辑下载文件
│       ├── luci-app-ksmbd #smb共享
│       ├── luci-app-passwall
│       ├── luci-app-qbittorrent
│       ├── luci-app-ttyd #luci界面终端
│       ├── luci-app-zerotier
│   └── Themes
│       ├── luci-theme-argon
Network
│   └── File Transfer
│       ├── rsync
│       ├── rsyncd
│       ├── wget-ssl 不要开wget-nossl,不然默认用wget下载容易出错
│   └── Filesystem
│       ├── ksmbd-server 
│       ├── nfs-kernel-server 
│   └── Firewall
│       ├── ip6tables-extra
│       ├── ip6tables-mod-nat
│       ├── ip6tables-nft #旧版名为ip6table
│   └── Version Control Systems
│       ├── git #同步代码用
│   └── SSH
│       ├── openssh-client (不要编译,Dropbear有ssh的功能,安装后还要配置哪个ssh客户端负责git)
│       ├── openssh-server (不要编译,Dropbear有ssh的功能,两个会冲突,编译后开机也只能2选1 )
│       ├── openssh-sftp-server (SFTP服务,要编译)
│   └── Web Servers/Proxies
│       ├── clash
Utilities
│   └── Disc
│       ├── parted
│   └── Editors
│       ├── vim-full
│   └── shadow-utils #创建新用户用
│   └── lsof #查看端口,用于查看和clash端口冲突的程序
```


### 只编译特定包的一种方式
以`subconverter`为例
```
cndaqiang@cndaqiang:~/immortalwrt$ ls package/feeds/packages/subconverter/
files  Makefile  patches
cndaqiang@cndaqiang:~/immortalwrt$ make package/feeds/packages/subconverter/compile V=s
make[2]: Entering directory '/home/cndaqiang/immortalwrt/scripts/config'
make[2]: 'conf' is up to date.
```



## 新系统操作
- 设置密码`ssh`后`passwd`就好
- 如果不恢复其他备份, 恢复下`/etc/dropbear`服务器的key
- WAN口上网设置, dns, ipv6
- 修改lan网段
- 设置备份列表
- USB挂载
- 可以按照下面的方式配置`clash,nat6`,也可以直接上传之前备份文件解压缩的`/etc/cndaqiang`文件夹

## 升级系统
### 设置备份文件列表
`luci>系统>备份与升级>配置`
```
/etc/cndaqiang
/etc/rc.local
/etc/init.d/cndaqiang_clash
/etc/opkg/distfeeds.conf
/www/clash-dashboard #clash
/root #git, .ssh等
#nfs、zerotier的配置可以自动保存不用管
```

## 关于Dropbear
Openwrt默认不编译`openssh-server/client`,`Dropbear`提供`openssh-server/client`的服务
- Dropbear不支持SFTP,需要安装[openssh-sftp-server](https://openwrt.org/docs/guide-user/services/nas/sftp.server)
- key
- - 生成密钥对: `( dropbearkey -y -f id_dropbear 2>/dev/null || dropbearkey -t rsa -f id_dropbear ) | grep "^ssh-rsa " > id_dropbear.pub`
- - 密钥:`dropbearkey -t ed25519 -f ~/.ssh/id_dropbear`
- - 查看公钥:`dropbearkey -y -f ~/.ssh/id_dropbear`
>- - `Ed25519通常比RSA更短,更快,相对安全`
>- - 一般来说，如果性能和简洁性是关键因素，而且你不需要长密钥，那么Ed25519可能是一个更好的选择。如果你需要与现有系统或标准兼容，或者有特定的安全性需求，可能会选择RSA
- Openwrt 服务器的密钥保存在`/etc/dropbear/`,网页端配置的密钥登录也在该文件

## zerotier
- 开机后zerotier的启动速度较慢,耐心等待
- 防火墙的设置会导致无法访问zerotier
- `网络>防火墙>防火墙 - 区域设置>常规设置>入站数据>接受 才能正常使用` zerotier
- 走zerotier共享的NFS目录速度读写慢于直接读写的,后台发现zerotier的CPU占用率较高


## NFS

```
chmod 777 /home/NFS
vi /etc/exports
```
填入
```
/home/NFS  192.168.192.0/24(rw,no_subtree_check,all_squash,anonuid=0,anongid=0)
```
重启
```
/etc/init.d/nfsd restart
```

客户端
```
(base) cndaqiang@macmini ~$ showmount -e 192.168.192.101
Exports list on 192.168.192.101:
/home/NFS                           192.168.192.0/24
#
#
mom=192.168.192.101
sudo mount_nfs  -P -o nolocks,nosuid ${mom}:/home/NFS /Users/data
```

### 路由器上层访问
- 添加客户端ip到`exports`
- 路由器内部又不能用这个wan的ip访问,真是又怪了

#### rpc的111端口
- 目前发现只能通过端口转发的形式实现
- 端口转发`wan:111 => lan:111`

#### 2049端口、32777-32780端口
转发或者开启入站规则都可以,只要把`2049,32777-32780`转发或者入站了就行
- 可以使用端口转发`wan:port=>lan:paort`
- 也可以开启入站规则: 所有区域到此设备`port`

![](/uploads/2024/01/nfs_port.png)


## smb
ksmb的用户和登录账户是两套
```
ksmbd.adduser --add-user=cndaqiang
```
共享`/home/NFS/share`

## git
这里使用的是`dropbear`提供的ssh客户端,因此和普通linux上生成key的方式不同. 

初次使用时
```
cd .ssh
( dropbearkey -y -f id_dropbear 2>/dev/null || dropbearkey -t rsa -f id_dropbear ) | grep "^ssh-rsa " > id_dropbear.pub
```
把`id_dropbear.pub`放到gitee就可以了


## clash
- 因为是在路由器上,所以不仅满足了clash科学网站
- 在外面还可以走内网下载科学文献
- 默认`allow-lan: true`,虽然路由器下面可以用路由器的`wan ip`访问,路由器外面访问不了`wan ip`,放心


```
CLASHDIR=/etc/cndaqiang/clash
mylocalconfig=$CLASHDIR/mylocalconfig.yaml
mkdir -p $CLASHDIR
mkdir $CLASHDIR/bin
mkdir $CLASHDIR/log

########################## clash 的获取 ######################
##### 使用openclash提供的
#ln -s /etc/openclash/clash $CLASHDIR/bin/
##### 🌟🌟 从github下载
##### 从https://github.com/vernesong/OpenClash/tree/core下载
##### scp /Volumes/KPStoarge/ChromeDownload/clash-linux-arm64-2023.08.17-13-gdcc8d87.gz root@192.168.12.1:/home/NFS
##### 🌟🌟🌟🌟🌟编译固件时集成 Netwrok/Web Servers/Proxies/clash
##############################################################

########################## clash-dashboard 的获取 #############
##### 🌟🌟 从github下载
##### wget 'https://codeload.github.com/cndaqiang/clash-dashboard/zip/refs/heads/gh-pages'
##### 我已经提前下载好了
cd /home/NFS
unzip -x gh-pages
mv clash-dashboard-gh-pages /www/clash-dashboard
##### 访问地址 http://192.168.12.1/clash-dashboard
##############################################################

########################## subconverter 的获取 ################
##### subconverter 负责将clash订阅地址转成clash配置文件 ##########
##### 编译固件时集成,运行会出错,不推荐
##### cp -r /etc/subconverter $CLASHDIR/subconverter
##### 🌟🌟 从github下载
##### wget https://github.com/tindy2013/subconverter/releases/download/v0.8.1/subconverter_aarch64.tar.gz
##### 我已经提前下载好了
cd $CLASHDIR/
tar xzvf /home/NFS/subconverter_aarch64.tar.gz
##############################################################

########################## subconverter 的配置 ###################
cd $CLASHDIR/subconverter
#可以适当修改clash生成参数
vi base/all_base.tpl
mixed-port: N (注意:和N之前有空格)
#输入文件
cat > $CLASHDIR/subconverter/generate.ini <<EOF
[cndaqiang]
path=config.yml
target=clash
ver=4
url=http://dy.clashweb.site/api/v1/client/subscribe?token=cndaqiangstoken
EOF
#
##############################################################

#配置文件使用系统服务启动
cat >  $CLASHDIR/bin/restart-clash.sh <<EOF
#!/bin/bash

lsof -i :10092 | awk 'NR!=1 {print \$2}' | xargs kill
#
#新配置文件
rm -rf $CLASHDIR/subconverter/config.yml
cd $CLASHDIR/subconverter/
$CLASHDIR/subconverter/subconverter -g --artifact "cndaqiang"
if [ -f $CLASHDIR/subconverter/config.yml ]
then
        echo 下载$CLASHDIR/subconverter/config.yml成功
        cp $CLASHDIR/subconverter/config.yml $CLASHDIR/subconverter/config.yml.bak
else
        echo 下载失败，使用备份$CLASHDIRh/subconverter/config.yml.bak
        cp $CLASHDIR/subconverter/config.yml.bak $CLASHDIR/subconverter/config.yml
fi
#
#添加自定义的规则, 如libgen走代理
line=\$(grep -rn rules $CLASHDIR/subconverter/config.yml | awk  -F: '{ print \$1 }')
sed -i \${line}a'\ \ - DOMAIN-KEYWORD,libgen,♻️ 自动选择           ' $CLASHDIR/subconverter/config.yml
sed -i \${line}a'\ \ - DOMAIN-KEYWORD,sci-hub,♻️ 自动选择          ' $CLASHDIR/subconverter/config.yml      
sed -i \${line}a'\ \ - DOMAIN-KEYWORD,sciencedirect,🎯 全球直连   ' $CLASHDIR/subconverter/config.yml    
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,aps.org,🎯 全球直连          ' $CLASHDIR/subconverter/config.yml       
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,webofscience.com,🎯 全球直连 ' $CLASHDIR/subconverter/config.yml             
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,iop.org,🎯 全球直连          ' $CLASHDIR/subconverter/config.yml           
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,scitation.org,🎯 全球直连    ' $CLASHDIR/subconverter/config.yml                 
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,elsevier.com,🎯 全球直连     ' $CLASHDIR/subconverter/config.yml                
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,wiley.com,🎯 全球直连        ' $CLASHDIR/subconverter/config.yml             
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,acs.org,🎯 全球直连          ' $CLASHDIR/subconverter/config.yml           
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,nih.gov,🎯 全球直连          ' $CLASHDIR/subconverter/config.yml           
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,springer.com,🎯 全球直连     ' $CLASHDIR/subconverter/config.yml                
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,nature.com,🎯 全球直连       ' $CLASHDIR/subconverter/config.yml              
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,science.org,🎯 全球直连      ' $CLASHDIR/subconverter/config.yml               
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,jps.jp,🎯 全球直连           ' $CLASHDIR/subconverter/config.yml               
sed -i \${line}a'\ \ - DOMAIN-SUFFIX,xiaomi.eu,♻️ 自动选择         ' $CLASHDIR/subconverter/config.yml
#
#创建新策略组(自动筛选节点)
sourceFile=$CLASHDIR/subconverter/config.yml
includeFile=\${sourceFile}.chat.cndaqiang.in
echo "  - name: ChatGPT" > \$includeFile
hang0=\$(grep -n '自动选择' \$sourceFile | grep name | awk -F: '{ print \$1 }')
hang=\$((hang0+1))
sed -n "\${hang},\\\$p" \$sourceFile  | awk '/^[[:space:]]*-/ {exit} {print}' >> \$includeFile
#筛选节点
sed -n "\${hang},\\\$p" \$sourceFile  | awk '/name/ {exit} {print}' | grep -i GPT >> \$includeFile
#生成新的文件
awk -v line="\${hang0}" -v includeFile="\$includeFile" 'NR==line{system("cat " includeFile )} {print}' \$sourceFile > ${sourceFile}.tmp
mv ${sourceFile}.tmp \$sourceFile
rm \$includeFile
line=\$(grep -rn rules \$sourceFile | awk  -F: '{ print \$1 }')
GPT=\$(grep -i chatgpt \$sourceFile | grep name | head -1| sed 's/[,":{}]/ /g' | awk  '{ print \$3 }')
if [ \$GPT ]
then
sed -i \${line}a'\ \ - DOMAIN-KEYWORD,openai, ChatGPT           ' \$sourceFile
sed -i \${line}a'\ \ - DOMAIN-KEYWORD,perplexity, ChatGPT       ' \$sourceFile
fi
#

#
if [ ! -f $mylocalconfig ]; then touch $mylocalconfig;fi
diff $CLASHDIR/subconverter/config.yml $mylocalconfig
#如果两个文件不一致就生成备份旧文件并下载替换新的文件
if [ ! "\$?" == 0 ]
then
  cp  $CLASHDIR/subconverter/config.yml $mylocalconfig
fi
#
/usr/bin/clash -f $mylocalconfig | tee $CLASHDIR/log/clash.log

#$CLASHDIR/bin/clash -f $mylocalconfig | tee $CLASHDIR/log/clash.log
#$CLASHDIR/bin/clash -f $mylocalconfig > $CLASHDIR/log/clash.log 2>&1 &
EOF
chmod +x $CLASHDIR/bin/restart-clash.sh
```

```
cat >  $CLASHDIR/bin/stop-clash.sh <<EOF
#!/bin/bash
lsof -i :10092 | awk 'NR!=1 {print \$2}' | xargs kill
EOF
chmod +x $CLASHDIR/bin/stop-clash.sh
```

```
cat > $CLASHDIR/bin/cndaqiang_clash << EOF
#!/bin/sh /etc/rc.common

START=99
STOP=10

start() {
    echo "Starting My Clash Service"
    $CLASHDIR/bin/restart-clash.sh
    # 添加启动服务的命令
}

stop() {
    echo "Stopping My Clash Service"
    # 添加停止服务的命令
    $CLASHDIR/bin/stop-clash.sh
}

restart() {
    echo "Restarting My Clash Service"
    stop
    start
}

# 添加其他需要的函数

# 添加其他需要的逻辑

# Exit on unsupported action
run "$@"
EOF
#
chmod +x $CLASHDIR/bin/cndaqiang_clash
cp $CLASHDIR/bin/cndaqiang_clash /etc/init.d/
```


开机启动、每日重启
```
(/etc/init.d/cndaqiang_clash restart &)
0 1 * * * /etc/init.d/cndaqiang_clash restart
```

## ipv6
[Openwrt 纯ipv6环境管理和上网](https://www.cnblogs.com/cndaqiang/p/16632790.html)

```
(sleep 20; /etc/cndaqiang/nat6.sh &)
```

```
mkdir /etc/cndaqiang/
vi /etc/cndaqiang/nat6.sh
chmod +x /etc/cndaqiang/nat6.sh
```


```
#/bin/bash
#添加到开机启动就行
#需要kmod-ipt-nat6
# Wait until IPv6 route is up...                  .....................ipv6......
line=0
while [ $line -eq 0 ]
do
        sleep 5
        line=`route -A inet6 | grep ::/0 | awk 'END{print NR}'`
        #这个其实无效，就是为例检测ipv6是否正常
done
#添加默认路由
ip -6 route add default via `ip -6 route | grep "default from" | awk 'NR==1{print $5,$6,$7}'`
#如果有默认规则,则删除后重新添加
if [ $? -gt 0 ]
then
ip -6 route delet default
ip -6 route add default via `ip -6 route | grep "default from" | awk 'NR==1{print $5,$6,$7}'`
fi

#NAT转发
ip6tables -t nat -A POSTROUTING -o `ip -6 route | grep "default from" | awk 'NR==1{print $7}'` -j MASQUERADE
```


## PassWall
- 一般不使用,仅在需要全局环境编译软件时开启
- 默认开启访问控制,只允许特定设备访问
- 开启的socks也是可以局域网/zerotier的

![](/uploads/2024/01/passwall.png)

### 暂时不支持https类型的节点订阅，跳过此节点
是订阅链接的原因
- 不要复制原机场的clash订阅,复制V2-Ray订阅地址能解析


## 报错
### 脚本存在无法运行
```
root@ImmortalWrt:/etc/cndaqiang/clash# /etc/cndaqiang/clash/bin/restart-clash.sh
-ash: /etc/cndaqiang/clash/bin/restart-clash.sh: not found
```
因为脚本开头是用`bash运行的`,安装`bash`或者把开头调整为`ash`

### 重启后root密码无法登录
- 新系统,仅初始化修改root密码
- ssh 后 reboot 
- 重启后就无法登录了, 主机的key也变了

- **初步原因:`sshd`和`dropbear`两个服务冲突了**
- **方案1:关闭系统的`sshd`项目开机自启**
- **方案2:使用`sshd`**,自己修改`/etc/ssh/sshd_config`配置，自己提前放好`.ssh/authorized_keys`


### 固件签名错误: 删除签名文件后再同步
```
Downloading file:///home/NFS/immortalwrt-23.05/targets/mediatek/filogic/packages/Packages.sig
Signature check failed.
Remove wrong Signature file.
```
处理
```
for i in $(find /home/NFS/immortalwrt-23.05 | grep Packages.sig)
do
echo rm $i
done
```
再重新同步Packages




------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
