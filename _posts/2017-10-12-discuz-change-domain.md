---
layout: post
title:  "discuz更换域名"
date:   2017-10-12 12:00:00 +0800
categories: web
tags: web discuz 
author: cndaqiang
mathjax: true
---
* content
{:toc}

网站进行了搬家，想试试更换域名，目前更换后，没发现什么问题，但是还有个疑问







网站进行了搬家，想试试更换域名

## 环境
discuz x3.1
## 参考
[discuz! X3 更改域名全程记录 （修改域名的方法）](http://www.discuz.net/thread-3528253-1-1.html)
## 操作
### 修改discuz配置文件
#### cookies，后台sql
把`config/config_global.php`  和 `config_global_default.php` 中的内容相应都修改
```
$_config['cookie']['cookiedomain'] = '.new.com';

$_config['admincp']['runquery']                        = 1;                // 是否允许后台运行 SQL 语句 1=是 0=否[安全]
```
发现之前的论坛内容中`$_config['cookie']['cookiedomain'] =`值为空，所以没有更改
#### ucenter访问地址
修改`config/config_ucenter.php`内域名为新域名
使用`http://新域名/admin.php` 登录后台管理面板
>以下内容和数据库有重复，可在最后更新
>
>1.后台==>全局==>站点信息==>网站url
>
2.后台==>全局==>域名设置==>应用域名==>论坛和根域名设置手机版访问设置：--- 手机发帖来源自定义:
>
>3.后台==>界面==>导航==>链接里面使用了绝对地址需要修改为新域名
>
>4.后台==>运营==>关联连接，没有设置就不用修改，在这里主要涉及优化  （站点宣传广告、友情链接）
>
>5.后台==>云平台==>同步站点信息   后台—工具—去平台诊断工具 （可能要手动设置IP）
>
>6.后台==>站长==>ucernter设置==>ucenter访问地址[灰色无法修改，通过编辑`config/config_ucenter.php`修改]
>
>7.ucenter==>应用管理==>应用的主urlBBS导航---顶部、底部  （版规网址要更新），论坛格子广告，贴间广告，列表广告全部要更新。

### 数据库修改
搜索数据库中涉及到的旧域名内容，使用sql命令替换
#### 搜索
phpmyadmin登录后搜索`netstu.net`，找到对应的表，字段
#### 修改
修改方法一:在网站后台>站长>数据库>升级>执行sql替换命令

修改方法二:phpmyadmin网页>选中要修改数据库>sql>输入sql替换命令
sql替换命令
```
UPDATE 表名 SET 字段=REPLACE(字段,'旧内容','新内容');
```
然后更新缓存
#### 遇到的问题，一次全替换不可以，需要分部分替换，更新缓存，再替换，再更新

**必须执行完一段sql，更新，再执行另一端**


---------
下面是一次实际操作
##### [失败] 下载数据库后，编辑器搜索netstu.net全部替换cndaqiang.online
不应该全部替换netstu.net后，更新缓存就解决了吗？
可是这样，主页直接就残缺，显示不正常了，猜测是主页模板有问题
##### [失败] sql中一次输入全部sql替换命令
主页同样残缺，显示不正常了
##### [目前正常] 修改一部分sql，更新缓存，再修改部分sql，更新缓存

------
无关紧要的先更新

----

```
UPDATE pre_common_pluginvar SET value=REPLACE(value,'old.com','new.com');

UPDATE pre_common_member_field_home SET blockposition=REPLACE(blockposition,'old.com','new.com');

UPDATE pre_ucenter_notelist SET postdata=REPLACE(postdata,'old.com','new.com');
UPDATE pre_forum_post SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_common_nav SET url=REPLACE(url,'old.com','new.com');

UPDATE pre_common_setting SET svalue=REPLACE(svalue,'old.com','new.com');

UPDATE pre_ucenter_applications SET url=REPLACE(url,'old.com','new.com');

UPDATE pre_ucenter_pm_messages_0 SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_ucenter_pm_messages_1 SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_ucenter_pm_messages_2 SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_ucenter_pm_messages_3 SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_ucenter_pm_messages_4 SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_ucenter_pm_messages_5 SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_ucenter_pm_messages_6 SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_ucenter_pm_messages_7 SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_ucenter_pm_messages_8 SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_ucenter_pm_messages_9 SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_ucenter_pm_lists SET subject=REPLACE(subject,'old.com','new.com');
```
网站后台>工具>更新缓存

------
2 模块更新
这部分对应论坛首页，校区公共通知等模块

------
```
UPDATE pre_common_block SET summary=REPLACE(summary,'old.com','new.com');
UPDATE pre_common_block SET param=REPLACE(param,'old.com','new.com');
```
-----
网站后台>工具>更新缓存

-----
3 模块？
该部分需在之前的sql命令执行后再执行，不然论坛主页就乱了，替换回来也无法修复

-----
```
UPDATE pre_common_syscache SET data=REPLACE(data,'old.com','new.com');
```
-----
网站后台>工具>更新缓存

----
4 缓存

----
```
UPDATE pre_common_block_item SET fields=REPLACE(fields,'old.com','new.com');
```
-----
网站后台>工具>更新缓存
执行之后，论坛主页很多内容不显示了，等待10分钟，刷新出板块，60分刷出排行榜，应该属于刷新时间

-----

**等论坛正常后再进行之后的替换**

5 之后，又搜索数据库进行的更新

-----
```
UPDATE pre_common_advertisement SET code=REPLACE(code,'old.com','new.com');

UPDATE pre_common_member_field_forum SET sightml=REPLACE(sightml,'old.com','new.com');

UPDATE pre_common_member_field_home SET spacecss=REPLACE(spacecss,'old.com','new.com');

UPDATE pre_forum_optionvalue1 SET description=REPLACE(description,'old.com','new.com');

UPDATE pre_common_advertisement SET parameters=REPLACE(parameters,'old.com','new.com');

UPDATE pre_forum_optionvalue1 SET jjff=REPLACE(jjff,'old.com','new.com');

UPDATE pre_forum_postcache SET comment=REPLACE(comment,'old.com','new.com');
UPDATE pre_forum_typeoptionvar SET value=REPLACE(value,'old.com','new.com');

UPDATE pre_home_blogfield SET message=REPLACE(message,'old.com','new.com');

UPDATE pre_home_comment SET message=REPLACE(message,'old.com','new.com');
```
### 不知道为什么，要按照顺序执行sql？



## 其他问题
>其他人的问题
后台登陆不了，被自动退出请把`config/config_global.php`中的`$_config['admincp']['checkip'] = 1;`修改为`$_config['admincp']['checkip'] = 0;`




------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
