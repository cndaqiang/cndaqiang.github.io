---
layout: post
title:  "Quantumult-X操作手册"
date:   2023-12-09 17:25:00 +0800
categories: Linux
tags: clash
author: cndaqiang
mathjax: true
---
* content
{:toc}







## 逻辑
规则和clash相似
- **策略是用于分类节点**的,比如把特定国家(正则)的节点筛选出来,选定的节点(PROXY),直连(DIRECT),拒绝(REJECT),也可以把其他策略选进来<br>
**策略需要配合分流使用**,例如**分流筛选出港台视频的网址**选择**筛选了港台节点的策略**<br>
在配置策略时可以选择多种节点、策略、PROXY和DIRECT,我们可以快速图形化切换
- **分流是用于分类网站的**,把特定网站挑选出来,配上合适的**策略**,让这些网站走这些策略里的节点<br>
筛选出广告的网址,然后reject
- **重写是替换访问的网址的**,比如把移动端网址替换成网页端,把vip认证的url换成其他url(这些url的返回值让APP通过vip判断)完成vip认证,也能实现广告拦截(把广告网址替换成无法访问、),以及解锁地区限制

### 使用示例
#### 根据网络环境手动选择节点方案
- 策略1: 分为直连和代理
- 分流: 苹果相关的网页选择策略1
- 当前网络能正常访问苹果服务时,策略1选择直连,否则策略1选择代理

示例
```
[policy]
static=🍎 苹果服务, direct, proxy, img-url= https://raw.githubusercontent.com/Koolson/Qure/master/IconSet/Apple.png
#规则分流远程订阅
[filter_remote]
https://raw.githubusercontent.com/DivineEngine/Profiles/master/Quantumult/Filter/Extra/Apple/Apple.list, tag= Apple服务, force-policy=🍎 苹果服务,enabled=true
```
![](/uploads/2023/12/apple.jpeg)

#### 挑选GPT节点配合分流
![](/uploads/2023/12/gpt.png)


#### 挑选特定新加坡节点适合看特定国家的内容
![](/uploads/2023/12/xinjiapo.jpeg)



## 配置文件
配置文件修改方案
- 一个总配置文件,直接修改(首页左下角/右下角都能进入修改入口)
- 顶部的节点、规则, 单击查看详情, <br>
长按展开具体配置,也可以在这里图形化添加修改配置,否启用某些节点/分流/重写配置
- 长按打开配置页面后,单击每一个配置是进行修改
- 修改入口太多,不做详细介绍,查语法添加规则,图形化点点点也可以
- 直接下载别人的配置文件,可以读一下,比如有作者注释了`#以下重写请自行添加，本重写引用不含...`,就要自己添加规则
- 以前的配置文件可能不行了,要找新的,取消勾选之前的配置,添加新的
- 下载的配置文件可能包含了同样的网址,手动排序调整优先级
- 配置的优先级虽然是先出现的优先级更好,但是当开启**其他设置>分流优化**时,会以精度优先,即下面的配置会使用全球加速的方式访问GPT,而不是自己配置的GPT策略,导致无法访问成功
```
host-keyword, openai.com, GPT
host-suffix, openai.com, 全球加速
```
其他
- 有的tiktok的重写规则一开反而无法访问tiktok,可能不兼容了.<br>
最后是下载修改版的tiktok,只做分流策略实现
- 一些破解vip规则,适合老版本APP,新版本APP无法使用不是自己配置的问题,使用i4或者其他途径下载低版本APP即可


### 分流规则
![](/uploads/2023/12/filter.png)

- (上图左),可以在配置文件中添加,在配置文件右上角可以直接跳转到`filter_`条目进行更改,示例

```
#规则分流远程订阅
[filter_remote]
https://raw.githubusercontent.com/DivineEngine/Profiles/master/Quantumult/Filter/Extra/Apple/Apple.list, tag= Apple服务, force-policy=🍎 苹果服务,enabled=true
https://raw.githubusercontent.com/DivineEngine/Profiles/master/Quantumult/Filter/Extra/ChinaIP.list, tag=🇨🇳️ 国内IP池, enabled=true
#本地分流规则(对于完全相同的某条规则，本地的将优先生效)
[filter_local]
#我写的特定网站(自定义的被墙网站)走proxy
host-keyword, raw.githubusercontent.com, proxy
host-suffix, limbopro.xyz, proxy 
```

- (上图中),也可以**长按分流规则**,添加`filter_remote`和额外的配置文件<br>
**如果直接下载/倒入别人的配置文件覆盖了本地的配置文件,会让配置文件中的节点,策略,分流规则都失效**,但是本会删除自己的配置文件,万一重置后可以在`filter_remote`中重新添加自己写过的配置文件
```
[filter_remote]
2A41DE9F46F0.snippet, tag=cndaqiang local, update-interval=172800, opt-parser=false, inserted-resource=true, enabled=true
```

- (上图右),**点击分流规则**查看分流信息


## 个人规则备份
### 分流规则
```
#下载github配置
host-keyword, raw.githubusercontent.com, 全球加速
#chatgpt
host-suffix, openai.com, GPT
```



------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
