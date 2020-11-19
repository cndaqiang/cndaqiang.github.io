此项目fork自[gaohaoyang.github.io](https://github.com/Gaohaoyang/gaohaoyang.github.io),原项目[README-zh-cn.md](https://github.com/cndaqiang/cndaqiang.github.io/blob/master/README-zh-cn.bak.md)
 
# 本地搭建过程
此操作只是为了能够本地预览博客效果，GitHub-page上已有环境

## 重新安装gem环境,采用bunlde配置环境

### rvm安装
```
sudo apt install gnupg #linux
brew install gnupg #mac
#下面非root
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable
\curl -sSL https://get.rvm.io | bash -s stable --rails
```
mac会提示缺少的程序，并自动进行编译安装
```
#mac/Linux
#source /Users/cndaqiang/.rvm/scripts/rvm
rvm install "ruby-2.7.0"
rvm install "ruby-2.7.0"
rvm use "ruby-2.7.0" --default 
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
'https://mirrors.tuna.tsinghua.edu.cn/rubygems/'
退出root模式
exit
#bunder源
bundle config mirror.https://rubygems.org https://mirrors.tuna.tsinghua.edu.cn/rubygems
#在blog目录
cndaqiang@girl:~/code/cndaqiang.github.io$ vi Gemfile
```
Gemfile内容
```
source 'https://mirrors.tuna.tsinghua.edu.cn/rubygems'
gem 'github-pages'
```
继续安装
```
cndaqiang@girl:~/code/cndaqiang.github.io$ bundle install
Fetching source index from https://mirrors.tuna.tsinghua.edu.cn/rubygems/
#期间会要求输入密码
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
/page 导航栏指向的界面
	
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

## 博客更新 2020-03-26
### 广告模块
谷歌广告收入达到$10,需要添加收款地址设置PIN否则停止展示广告，等待验证中

### 测试广告商
审核中： http://union.2345.com/union_e2345.php

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
## 博客更新　2020-05-10
全面迁移gitee, Now only for me.<br>
使用web分支作为所有内容，master分支为公开内容.


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

## 博客更新 2020-05-02使用cloudflare免费加速
见[使用cloudflare加速博客访问/免费搭建谷歌镜像](https://cndaqiang.github.io/2020/05/02/cloudflare/)