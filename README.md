此项目fork自[gaohaoyang.github.io](https://github.com/Gaohaoyang/gaohaoyang.github.io),原项目[README-zh-cn.md](https://github.com/cndaqiang/cndaqiang.github.io/blob/master/README-zh-cn.bak.md)
 
# 本地搭建过程
此操作只是为了能够本地预览博客效果，GitHub-page上已有环境

## 重新安装gem环境,采用bunlde配置环境
### 关系
- ruby: 语言,有不同版本
- RVM: 安装管理Ruby环境各类斯三方插件
- RubyGems
>RubyGems是一个方便而强大的Ruby程序包管理器（ package manager），类似RedHat的RPM.它将一个Ruby应用程序打包到一个gem里，作为一个安装单元。无需安装，最新的Ruby版本已经包含RubyGems了。
-Gem
>Gem是封装起来的Ruby应用程序或代码库。
>注：在终端使用的gem命令，是指通过RubyGems管理Gem包。

- Gemfile
>定义你的应用依赖哪些第三方包，bundle根据该配置去寻找这些包。


### Linux/Mac安装rvm
**Ubuntu卸载系统的Ruby,mac协助brew安装的Ruby,清除环境变量设置**,安装gpg公钥
```
sudo apt install gnupg #linux
brew install gnupg #mac
#下面非root
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
#如果报错,则换个服务器
cndaqiang@macmini blog.cndaqiang$ gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
gpg: 从公钥服务器接收失败：Server indicated a failure
cndaqiang@macmini blog.cndaqiang$ gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
gpg: 密钥 105BD0E739499BDB： 1 个重复签名被移除
gpg: /Users/cndaqiang/.gnupg/trustdb.gpg：建立了信任度数据库
gpg: 密钥 105BD0E739499BDB：公钥 “Piotr Kuczynski <piotr.kuczynski@gmail.com>” 已导入
gpg: 密钥 3804BB82D39DC0E3：公钥 “Michal Papis (RVM signing) <mpapis@gmail.com>” 已导入
gpg: 处理的总数：2
gpg:               已导入：2
```
安装rvm
```
curl -sSL https://get.rvm.io | bash -s stable
```
安装ruby2.7.0,mac会提示缺少的程序，并自动进行编译安装,编译失败根据configure结果修改即可
```
#mac/Linux
#需要登陆的shell,执行 /bin/bash --login
source /home/cndaqiang/.rvm/scripts/rvm
source /Users/cndaqiang/.rvm/scripts/rvm
rvm install "ruby-2.7.0" # 使用timemachine等当时迁移的mac系统，使用 rvm reinstall "ruby-2.7.0"
#ubuntu 
rvm pkg install openssl
rvm install "ruby-2.7.0" --with-openssl-dir=$HOME/.rvm/usr
rvm use "ruby-2.7.0" --default 
#rvm安装在用户目录,不粗要root
```


### gem 安装bunlder
```

#设置源
gem sources --add https://mirrors.tuna.tsinghua.edu.cn/rubygems/ --remove https://rubygems.org/
#更新
gem update
#安装bunder
gem install bundler
#bunder源
bundle config mirror.https://rubygems.org https://mirrors.tuna.tsinghua.edu.cn/rubygems
#还需要安装，不然安装jekyll会报错
gem install nokogiri -v '1.10.9' --source 'https://mirrors.tuna.tsinghua.edu.cn/rubygems/'

#bunder源
bundle config mirror.https://rubygems.org https://mirrors.tuna.tsinghua.edu.cn/rubygems
#在blog目录
cndaqiang@girl:~/code/cndaqiang.github.io$ vi Gemfile
```
**要更新一下Gemfile的时间戳**,其中内容为
```
source 'https://mirrors.tuna.tsinghua.edu.cn/rubygems'
gem 'github-pages'
```
`rm Gemfile.loc`, 继续安装
```
cndaqiang@girl:~/code/cndaqiang.github.io$ bundle install
Fetching source index from https://mirrors.tuna.tsinghua.edu.cn/rubygems/

```

## 运行
进入网站目录
```
jekyll s [--port 端口号(不设置默认端口4000)]
```
浏览器访问`http://127.0.0.1:4000`
局域网访问
```
jekyll s --host=0.0.0.0
```



# 此项目使用
## 目录结构
参考[目录结构](http://jekyllcn.com/docs/structure/)

主要结构
```
/_config.yml 网站主要配置
/page 导航栏指向的界面(只要按照下面的格式去创建文件,放在任意目录都是可以的)
	
     里面的文本内容的格式 
	 ---
     layout: default #会根据这个关键词跳用layouts里面的模版
     title: 标题 #显示在导航上的内容
     permalink: 链接 #页面的固定链接
     icon: 图标 #导航栏上的图标
     type: page #页面类型，选择page页面
---

/_inclouds 页脚footer，页头head，评论系统等html模块化元素，用于引用组成一个html网页
/_layouts  主要页面的html内容，引用_incloud,_post等文件内容组成网页
/_site 自已生成不需操作
/_post 博客文章内容
/web/Adsense 广告资源
```
## git clone已有博客页面

## 修改页面


修改，jekyll s 本地预览，git push推送

http://utf7.github.io/2016/09/30/setting-up-your-github-pages-site-locally-with-jekyll/

### 主要修改参考参考[README-zh-cn.md](https://github.com/cndaqiang/cndaqiang.github.io/blob/master/README-zh-cn.bak.md)
### 评论系统
参考[README-zh-cn.md](https://github.com/cndaqiang/cndaqiang.github.io/blob/master/README-zh-cn.bak.md)
#### 注
disqus的shortname，不是用户名，一个网站一个，setting里有
### 摘要预览
摘要由`_config.yml`中的`excerpt_separator: "摘要内容分隔符"`决定,此项目设置为`excerpt_separator: "\n\n\n\n"`即文章中连续四个回车前的内容显示在主页
#### 问题
windows下的换行是`^M\n`,windows版的GitBash好像提交代码时或自动修改为Unix的`\n`,但是之前在windows下的文件在linux下提交就不会了，所以，主页一整篇文章就是一个摘要
<br>比较好的解决方案是替换`_config.yml`中的`excerpt_separator: "摘要内容分隔符"`的`摘要内容分隔符`为非换行符，然后替换掉文章中的`摘要内容分隔符`<br>
也可以
```
sudo apt install dos2unix
dos2unix *.md
```

# 发布日期不能大于当前时间

# 添加页面底部联系方式的，图标
使用图标如简书 iconfont
参考http://www.jianshu.com/p/5d4a39cdf96d
在head.html添加 //at.alicdn.com/t/font_461356_6dhj8mgwisozjjor.css
在footer.html里修改
照着修改，在_config.yml   里添加用户名

# 博客设置

~~简书发布/保存成草稿~~
~~转发到github-page 解决图片缓存问题~~

## Font Awesome 图标使用方法
在`_includes/head.html`中加入
```
1、国内推荐 CDN：
<link rel="stylesheet" href="https://cdn.staticfile.org/font-awesome/4.7.0/css/font-awesome.css">
2、海外推荐 CDN
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
```
在需要图标的地方，比如`_includes/footer.html`中加入
```
<i class="fa fa-github" aria-hidden="true">
```
更多使用方法见[Font Awesome 图标](https://www.runoob.com/font-awesome/fontawesome-tutorial.html)<br>
可使用的图标有[fontawesome](http://fontawesome.dashgame.com/)


## 博客更新 2018-10-24
### 加入谷歌广告
处于好奇的目的，在网站上投放广告的目的，为了不影响阅读，放在了文章的最下面<br>
投放方式很简单<br>
在[GoogleAdsense](https://www.google.com/adsense)注册账户，大约一天后获得通过<br>
选择适当的广告类型，生产JavaScript脚本，复制粘贴到网页的相关内容处即可，也可以直接全局广告放入head元素内，谷歌会根据网页的内容，自动加入广告<br>
此次更新，在`index.html`的侧边栏，和`_layouts\post.html`的评论区后，加入广告
### 重写about页面
参考[towdium](https://www.towdium.me/about/#zh)，加入中英文介绍<br>
添加好友链接,增加了`_layouts/about.html`关于页模板

### 使用来必力评论系统
disqus国内被墙，改用来必力
在此页面[livere](https://www.livere.com/)安装<br>
获得id后填入`_config.yml`中的City_uid
### 修复网站footer的统计问题
修改中`_includes\footer.html`busuanzi的域名为`busuanzi.ibruce.info`
### git默认对文件名大小写不敏感，导致文件拓展名后，不同步，设置
```
git config core.ignorecase false
```
## 博客更新 2020-01-09
### 加入github start
添加到`_layout`里面的模板文件中，源码来自[github-buttons](https://github.com/mdo/github-buttons)
```
<iframe src="/html_script/github-btn.html?user=cndaqiang&repo=cndaqiang.github.io&type=star&count=true&size=large" frameborder="0" scrolling="0" width="160px" height="30px"></iframe>
<iframe src="/html_script/github-btn.html?user=cndaqiang&type=follow&count=true&size=large" frameborder="0" scrolling="0" width="220px" height="30px"></iframe>            
```
## 博客更新 2020-01-17
### 更多的使用Font Awesome 图标
把之前的github的star和follow替换为
```
            <div class="label-card">
                <a href="https://github.com/cndaqiang/cndaqiang.github.io" title="RSS"><i class="fa fa-thumbs-o-up" aria-hidden="true"></i>Star</a>
            </div>
```


## 博客更新 2020-04-X 添加图形化访问数据
添加到
```
_layouts/post.html
_layouts/about.html
```
源代码来自[revolvermaps](https://www.revolvermaps.com/?target=gallery)
```
         <!-- 其他div框放到这里 ，添加br 使不粘连--><br>
            <div class="side">
               <div>
                   <i class="fa fa-database"></i>
                  访客数据
               </div>
               <script type="text/javascript" src="//rf.revolvermaps.com/0/0/7.js?i=537vyn60ia7&amp;m=0&amp;c=007eff&amp;cr1=ff0000&amp;sx=0" async="async"></script>
            </div>
```
## 博客更新　2020-04-04全国性哀悼
### 网页黑白展示
添加到`_layouts/default.html`
```
<html style="filter:grayscale(100%);">
```
修改`无黑白0%-完全黑白100%`
### 修改header
`_includes/header.html`添加
```
        <a href= http://www.gov.cn/zhengce/content/2020-04/03/content_5498472.htm>
            <h1>深切哀悼</h1><b>抗击新冠肺炎疫情斗争牺牲烈士和逝世同胞</b>
        </a>
```
## 博客更新　2020-04-05添加gitee镜像
添加到`_includes/header.html`
```
        <a href="http://cndaqiang.gitee.io/{{ page.url }}">gitee:http://cndaqiang.gitee.io</a>,
        <a href="https://cndaqiang.github.io/{{ page.url }}">Github:https://cndaqiang.github.io/</a>.
```
## 博客更新 2020-04-18使用[Bundler](http://bundler.io/)配置环境
配置方法[使用Bunlder搭建Jekyll(Github-pages)服务](https://cndaqiang.github.io//2020/04/18/ruby/)
```
sudo gem install bundler
bundle install
bundle exec jekyll serve [-P port]
```

## 博客更新 2020-05-02使用cloudflare免费加速
见[使用cloudflare加速博客访问/免费搭建谷歌镜像](https://cndaqiang.github.io/2020/05/02/cloudflare/)



## 博客更新 2020-05-10
全面迁移gitee, Now only for me.<br>
使用web分支作为所有内容，master分支为公开内容.



## 博客更新 2021-04-26
通过修改`_config.yml`和相关页面, 本地搭建时关闭在线js, 如讨论,广告,联系方式等.

## 博客更新 2022-01-27
更换[Twikoo](https://twikoo.js.org/#%E7%89%B9%E8%89%B2)评论系统.
使用Vercel 部署部署,并添加前端代码到`_includes/comments.html`.在`_config.yml`中定义
```
twikooID: https://vercel-comment2-jhck1hsa5-cndaqiang.vercel.app/
```
生效

## 迁移到gitlab
**仓库名用cndaqiang.gitlab.io**

建立`.gitlab-ci.yml`, 里面的环境和本地搭建的环境一样,注意ruby用2.7.0
```
image: ruby:2.7.0

variables:
  JEKYLL_ENV: production
  LC_ALL: C.UTF-8

before_script:
  - gem install bundler
  - bundle install

test:
  stage: test
  script:
  - bundle exec jekyll build -d test
  artifacts:
    paths:
    - test
  except:
  - master

pages:
  stage: deploy
  script:
  - bundle exec jekyll build -d public
  artifacts:
    paths:
    - public
  only:
  - master
```
push后, 设置保存pages服务, 在CI里更新
![](https://cndaqiang.github.io/uploads/2021/06/gitlab.png)

后续push会自动在CI更新,如更新失败可去CI查看详情

### CSS
```
# html
<div id="cse" style="width: 100%;" class="xxx">Loading</div>
# css
#class -> .xxx
.xxx {
    
 }
# id -> #xxx
#xxx {
   
}
```


## 广告
- 谷歌广告收入达到$10,需要添加收款地址设置PIN否则停止展示广告，~~等待验证中~~,验证通过,恢复展示
- - 通用最好: [文章内嵌](https://www.cnblogs.com/cndaqiang/p/15229188.html)
- - 广告代码有一段通用代码,放在head内即可
- ~~审核中： http://union.2345.com/union_e2345.php~~
- 百度联盟不过审
- 通过图片和链接的方式给云服务器商推广,如腾讯和西部数码
```
     <a href="https://curl.qcloud.com/ph2YL72r" target=_blank><img src="/web/Adsense/tengxun.345x200.jpg" border=0></a>
```
- 阿里联盟只能手动选择商品,然后添加文案到网页,且商品有推广时限,也不定向,小流量不适合
- 京东联盟,大多数都是商品活动的固定链接. 自定义推广中橱窗推广是js脚本


## 博客部署到其他平台
### 部署博客到群晖NAS
jekyll启动后,打包`_site`目录,上传至群晖,新增虚拟主机,后端Apache,根目录即`_site`目录
### 文件
- `public.sh` 部署到`../cndaqiang` 用于发布到gitee.sh,要删除违规内容
- `public.sh github.cndaqiang` 部署到`../github.cndaqiang` 用于发布到github
- `public.west.sh` 发布到west虚拟空间,自动删除多媒体文件，替换相对链接为绝对链接
- `public.txt` `public.sh`会发布的文章
- `public.west.txt` `public.west.sh`会发布的文章
- `public.hexie.txt` `public.west.sh`要删除的违禁文章


## 网站地图的制作
- 修改博客的rss订阅,`cp feed.xml sitemap.xml`，修改链接`href="{{ "/sitemap.xml" `和去掉限制`limit:10`,会自动生成本网站的sitemap,也是, `https://cndaqiang.github.io/sitemap.xml`
- 使用第三方网站制作`https://www.xml-sitemaps.com/`