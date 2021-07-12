---
layout: post
title:  "Ubuntu 16.04 使用vsftpd搭建ftp服务器"
date:   2018-11-17 23:20:00 +0800
categories: Linux
tags:  ubuntu vsftpd ftp
author: cndaqiang
mathjax: true
---
* content
{:toc}

本文默认配置允许匿名只读访问一些目录，linux用户访问某些目录并隔离






## 参考
[How To Set Up vsftpd for a User's Directory on Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-vsftpd-for-a-user-s-directory-on-ubuntu-16-04)<br>
[openwrt vsftp 搭建ftp服务器](https://www.jianshu.com/p/7badab74a530)<br>
[Ubuntu使用vsftpd搭建ftp服务器](/2017/09/27/ubuntu-vsftps/)

## 安装
```
sudo apt-get update
sudo apt-get install vsftpd
```

## 防火墙
```
#设置规则
#20 21访问端口
sudo iptables -I INPUT -p tcp --dport 20 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 21 -j ACCEPT
#被动模式端口
sudo iptables -I INPUT -p tcp --dport 40000:50000 -j ACCEPT
#生效
iptables-save
#防火墙重启依然有效
sudo apt-get install iptables-persistent
sudo netfilter-persistent save
sudo netfilter-persistent reload
```
## 配置文件
```
#备份
sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.orig
#修改
sudo vi /etc/vsftpd.conf
```
允许匿名只读访问一些目录，linux用户访问某些用户并隔离
```
# Example config file /etc/vsftpd.conf
#
# The default compiled in settings are fairly paranoid. This sample file
# loosens things up a bit, to make the ftp daemon more usable.
# Please see vsftpd.conf.5 for all compiled in defaults.
#
# READ THIS: This example file is NOT an exhaustive list of vsftpd options.
# Please read the vsftpd.conf.5 manual page to get a full idea of vsftpd's
# capabilities.
#
#
# Run standalone?  vsftpd can run either from an inetd or as a standalone
# daemon started from an initscript.
listen=NO

#
# This directive enables listening on IPv6 sockets. By default, listening
# on the IPv6 "any" address (::) will accept connections from both IPv6
# and IPv4 clients. It is not necessary to listen on *both* IPv4 and IPv6
# sockets. If you want that (perhaps because you want to listen on specific
# addresses) then you must run two copies of vsftpd with two configuration
# files.
listen_ipv6=YES
#
# Allow anonymous FTP? (Disabled by default).
#匿名登录
anonymous_enable=YES
#
# Uncomment this to allow local users to log in.
#linux用户登录
local_enable=YES
#
# Uncomment this to enable any form of FTP write command.
#linux用户写入权限
write_enable=YES
#
# Default umask for local users is 077. You may wish to change this to 022,
# if your users expect that (022 is used by most other ftpd's)
local_umask=022
#
# Uncomment this to allow the anonymous FTP user to upload files. This only
# has an effect if the above global write enable is activated. Also, you will
# obviously need to create a directory writable by the FTP user.
#限制匿名用户权限
anon_upload_enable=NO
#
# Uncomment this if you want the anonymous FTP user to be able to create
# new directories.
anon_mkdir_write_enable=NO
#
# Activate directory messages - messages given to remote users when they
# go into a certain directory.
dirmessage_enable=YES
#
# If enabled, vsftpd will display directory listings with the time
# in  your  local  time  zone.  The default is to display GMT. The
# times returned by the MDTM FTP command are also affected by this
# option.
use_localtime=YES
#
# Activate logging of uploads/downloads.
xferlog_enable=YES
#
# Make sure PORT transfer connections originate from port 20 (ftp-data).
connect_from_port_20=YES
#
# If you want, you can arrange for uploaded anonymous files to be owned by
# a different user. Note! Using "root" for uploaded files is not
# recommended!
#更改上传之后的文件所属者
chown_uploads=YES
chown_username=root
#
# You may override where the log file goes if you like. The default is shown
# below.
#xferlog_file=/var/log/vsftpd.log
#
# If you want, you can have your log file in standard ftpd xferlog format.
# Note that the default log file location is /var/log/xferlog in this case.
#xferlog_std_format=YES
#
# You may change the default value for timing out an idle session.
#idle_session_timeout=600
#
# You may change the default value for timing out a data connection.
#data_connection_timeout=120
#
# It is recommended that you define on your system a unique user which the
# ftp server can use as a totally isolated and unprivileged user.
#nopriv_user=ftpsecure
#
# Enable this and the server will recognise asynchronous ABOR requests. Not
# recommended for security (the code is non-trivial). Not enabling it,
# however, may confuse older FTP clients.
#async_abor_enable=YES
#
# By default the server will pretend to allow ASCII mode but in fact ignore
# the request. Turn on the below options to have the server actually do ASCII
# mangling on files when in ASCII mode.
# Beware that on some FTP servers, ASCII support allows a denial of service
# attack (DoS) via the command "SIZE /big/file" in ASCII mode. vsftpd
# predicted this attack and has always been safe, reporting the size of the
# raw file.
# ASCII mangling is a horrible feature of the protocol.
#ascii_upload_enable=YES
#ascii_download_enable=YES
#
# You may fully customise the login banner string:
#ftpd_banner=Welcome to blah FTP service.
#
# You may specify a file of disallowed anonymous e-mail addresses. Apparently
# useful for combatting certain DoS attacks.
#deny_email_enable=YES
# (default follows)
#banned_email_file=/etc/vsftpd.banned_emails
#
# You may restrict local users to their home directories.  See the FAQ for
# the possible risks in this before using chroot_local_user or
# chroot_list_enable below.
#root dir
#匿名用户目录
anon_root=/home/data/1t3
chroot_local_user=YES
#linux用户
user_sub_token=$USER
#linux用户的默认目录
local_root=/home/$USER/ftp
#被动模式端口
pasv_min_port=40000
pasv_max_port=50000
#只允许一些用户(包括匿名用户)访问，用户名写在该文件夹内可访问，匿名用户名为anonymous
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
#
# You may specify an explicit list of local users to chroot() to their home
# directory. If chroot_local_user is YES, then this list becomes a list of
# users to NOT chroot().
# (Warning! chroot'ing can be very dangerous. If using chroot, make sure that
# the user does not have write access to the top level directory within the
# chroot)
#chroot_local_user=YES
#chroot_list_enable=YES
# (default follows)
#chroot_list_file=/etc/vsftpd.chroot_list
#
# You may activate the "-R" option to the builtin ls. This is disabled by
# default to avoid remote users being able to cause excessive I/O on large
# sites. However, some broken FTP clients such as "ncftp" and "mirror" assume
# the presence of the "-R" option, so there is a strong case for enabling it.
#ls_recurse_enable=YES
#
# Customization
#
# Some of vsftpd's settings don't fit the filesystem layout by
# default.
#
# This option should be the name of a directory which is empty.  Also, the
# directory should not be writable by the ftp user. This directory is used
# as a secure chroot() jail at times vsftpd does not require filesystem
# access.
secure_chroot_dir=/var/run/vsftpd/empty
#
# This string is the name of the PAM service vsftpd will use.
pam_service_name=vsftpd
#
# This option specifies the location of the RSA certificate to use for SSL
# encrypted connections.
rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
ssl_enable=NO

#
# Uncomment this to indicate that vsftpd use a utf8 filesystem.
#utf8_filesystem=YES
```
更多参数和配置，参考
[openwrt vsftp 搭建ftp服务器](https://www.jianshu.com/p/7badab74a530)<br>
[Ubuntu使用vsftpd搭建ftp服务器](/2017/09/27/ubuntu-vsftps/)


## 写入访问列表
修改`/etc/vsftpd.userlist`
例如
```
ftpboy
anonymous
```

## 设置目录权限
匿名目录权限
```
sudo chown root:nogroup /home/data/1t3
sudo chmod 557 /home/data/1t3
```
linux用户目录权限
```
sudo mkdir /home/ftpboy/ftp
sudo chown nobody:nogroup /home/ftpboy/ftp
sudo chmod a-w /home/ftpboy/ftp
```

## 重启vsftp
```
sudo systemctl restart vsftpd
```

访问`ftp://ip`
<hr>
## 其他
### 路由端口转发
路由器将外部端口，转发到ubuntu的21号端口即可



------
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
