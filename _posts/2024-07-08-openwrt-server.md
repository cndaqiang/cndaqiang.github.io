---
layout: post
title:  "OpenWRT个人服务器:以E20C为例"
date:   2024-07-08 09:53:00 +0800
categories: OpenWRT
tags: OpenWRT
author: cndaqiang
mathjax: true
---
* content
{:toc}











## 环境变量
`.bashrc`对root无效, 还是添加到`/etc/profile`

## git 服务
```
opkg install openssh-client git openssh-keygen
git config --global user.name 'cndaqiang' 
git config --global user.email 'chendq@aliyun.com'
ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub
```

## git page
```
docker run --name ubuntu_page -it -p 4000:4000 -v /mnt/mmc0-4/data:/data ubuntu:22.04
apt update
#ruby apt流程
按照官方安装
https://jekyllrb.com/docs/installation/ubuntu/
#echo "gem 'webrick'" >> Gemfile
rm Gemfile.lock 
bundle install
bundle exec jekyll s --host=0.0.0.0
```
计划任务
```
0 1 * * * /bin/bash /mnt/mmc0-4/data/git/blog.cndaqiang/push.sh
```

## NFS
```
opkg install nfs-kernel-server
#cat /etc/exports 
/mnt/mmc0-4/data/git  192.168.192.0/24(rw,no_subtree_check,all_squash,anonuid=0,anongid=0)
/etc/init.d/nfsd restart
````
计划任务
```
0 2 * * * /bin/bash /mnt/mmc0-4/data/git/MyTools/push.sh
```

## passwall
```
#下载解压，全部安装
passwall_packages_ipk_aarch64_cortex-a53.zip
#安装
luci-23.05_luci-app-passwall_4.77-6_all.ipk
luci-23.05_luci-i18n-passwall-zh-cn_git-24.152.54078-47d7784_all.ipk
```

## socks服务
```
opkg install v2ray-core
vi /etc/cndaqiang/v2ray.json
```
```
{
    "inbounds": [
      //可以配置多种协议
        {
            "port": 2090, // 服务器监听端口
            "protocol": "socks",
            "address" : "192.168.192.2"  //地址,可选
	},
        {
            "port": 2091, // 服务器监听端口,和socks使用相同端口,总是很卡
            "protocol": "http",
            "address" : "192.168.192.2" //地址,可选
	}
    ],
    "outbounds": [
      //出口选择freedom就行
        {
            "protocol": "freedom"
        }
    ]
}
```
开启启动脚本
```
(sleep 25; /usr/bin/v2ray  run -config  /etc/cndaqiang/v2ray.json &)
```



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
