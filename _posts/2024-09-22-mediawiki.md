---
layout: post
title:  "群晖的MediaWiki崩溃后的救援记录"
date:   2024-09-22 20:20:00 +0800
categories: MediaWiki
tags: MediaWiki
author: cndaqiang
mathjax: true
---
* content
{:toc}











## 操作流程
### 导出数据
* 下载网站数据`/web/web_packages/mediawiki`
* 使用phpmyadmin 导出数据库

### 恢复环境搭建
* 因为MediaWiki-1.35依赖>php3, 所以安装ubuntu 20.04
* 安装apache,php,mysql,phpmyadmin

### 恢复
* 导入数据库, 并添加数据库访问账户,见`mediawiki/LocalSettings.php`
* 把`mediawiki`复制到`/var/www/html/mediawiki`
* 开始调试

### 调试报错
* 打开`http://ubuntu的ip/mediawiki`，会报下面的错误
* **与其一个个插件的解决报错，完全可以屏蔽所有插件**

```
MediaWiki internal error.

Original exception: [66a872b146de68f70641caa8] /mediawiki/ Wikimedia\Rdbms\DBConnectionError from line 1420 of /var/www/html/mediawiki/includes/libs/rdbms/loadbalancer/LoadBalancer.php: Cannot access the database: Unknown error (localhost:/run/mysqld/mysqld10.sock)
Backtrace:
#0 /var/www/html/mediawiki/includes/libs/rdbms/loadbalancer/LoadBalancer.php(934): Wikimedia\Rdbms\LoadBalancer->reportConnectionError()
#1 /var/www/html/mediawiki/includes/libs/rdbms/loadbalancer/LoadBalancer.php(901): Wikimedia\Rdbms\LoadBalancer->getServerConnection()
#2 /var/www/html/mediawiki/includes/libs/rdbms/loadbalancer/LoadBalancer.php(1046): Wikimedia\Rdbms\LoadBalancer->getConnection()
#3 /var/www/html/mediawiki/includes/GlobalFunctions.php(2463): Wikimedia\Rdbms\LoadBalancer->getMaintenanceConnectionRef()
#4 /var/www/html/mediawiki/includes/cache/localisation/LCStoreDB.php(56): wfGetDB()
#5 /var/www/html/mediawiki/includes/cache/localisation/LocalisationCache.php(449): LCStoreDB->get()
#6 /var/www/html/mediawiki/includes/cache/localisation/LocalisationCache.php(495): LocalisationCache->isExpired()
#7 /var/www/html/mediawiki/includes/cache/localisation/LocalisationCache.php(371): LocalisationCache->initLanguage()
#8 /var/www/html/mediawiki/includes/cache/localisation/LocalisationCache.php(312): LocalisationCache->loadItem()
#9 /var/www/html/mediawiki/includes/language/LanguageFallback.php(106): LocalisationCache->getItem()
#10 /var/www/html/mediawiki/includes/language/LanguageFactory.php(175): MediaWiki\Languages\LanguageFallback->getAll()
#11 /var/www/html/mediawiki/includes/language/LanguageFactory.php(121): MediaWiki\Languages\LanguageFactory->newFromCode()
#12 /var/www/html/mediawiki/includes/ServiceWiring.php(241): MediaWiki\Languages\LanguageFactory->getLanguage()
#13 /var/www/html/mediawiki/vendor/wikimedia/services/src/ServiceContainer.php(447): Wikimedia\Services\ServiceContainer->{closure}()
#14 /var/www/html/mediawiki/vendor/wikimedia/services/src/ServiceContainer.php(416): Wikimedia\Services\ServiceContainer->createService()
#15 /var/www/html/mediawiki/includes/MediaWikiServices.php(623): Wikimedia\Services\ServiceContainer->getService()
#16 /var/www/html/mediawiki/includes/Setup.php(700): MediaWiki\MediaWikiServices->getContentLanguage()
#17 /var/www/html/mediawiki/includes/WebStart.php(89): require_once(string)
#18 /var/www/html/mediawiki/index.php(44): require(string)
#19 {main}
```


### 修复手段:直接最小化安装之后复制最小化配置文件
```
root@ubuntu2004:mv mediawiki mediawiki.bak
root@ubuntu2004:/var/www/html# unzip -x /home/cndaqiang/mediawiki-core-1.35.2.zip
root@ubuntu2004:mv mediawiki-1.35.2 mediawiki
```
然后从`http://ubuntu的ip/mediawiki`，完成mediawiki的安装，并设置与之前mediawiki相同的网站名、数据库信息
```
root@ubuntu2004:mv mediawiki mediawiki-1.35.2
root@ubuntu2004:mv mediawiki.bak mediawiki
root@ubuntu2004:cp mediawiki/LocalSettings.php mediawiki/LocalSettings.php.bak
root@ubuntu2004:cp mediawiki-1.35.2/LocalSettings.php mediawiki/LocalSettings.php
```
再从网页访问`http://ubuntu的ip/mediawiki`就可以看到以前的数据了

可以继续搬运`mediawiki/LocalSettings.php.bak`中的配置信息到`mediawiki/LocalSettings.php`, 让外观、插件等逐渐恢复


### 我的`LocalSettings.php`主要修改

```
$wgScriptPath = "/mediawiki";
$wgServer = "http://10.9.9.107";

## Database settings
$wgDBtype = "mysql";
$wgDBserver = "localhost";
$wgDBname = "wikisqlname";
$wgDBuser = "wikisqluser";
$wgDBpassword = "wikisqlpass";

$wgVirtualRestConfig['modules']['parsoid'] = array(
	'url' => 'http://10.9.9.107/mediawiki',
);
```

## 迁移回群晖
* 建立一个**基于端口**的虚拟主机，例如端口820, html服务选择**apache**, php选择7.3以上
* 上传`mediawiki`到群晖
* 修改`LocalSettings.php`

```
$wgScriptPath = "/";
$wgServer = "http://群晖ip:820";
'url' => 'http://群晖ip:820',
```

## 强制改密码
```
root@ubuntu2004:/var/www/html/mediawiki/maintenance# php changePassword.php --user=root --password='我是密码'
```
然后从数据库的user表找到响应的用户名，下载他们的密码二进制文件user_password, 上传到群晖的数据库，就可以快速改群晖上面的账户密码了




------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
