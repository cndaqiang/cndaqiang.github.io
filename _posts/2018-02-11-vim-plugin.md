---
layout: post
title:  "vim插件管理Vundle"
date:   2018-02-11 20:36:00 +0800
categories: Linux
tags: vim Vundle
author: cndaqiang
mathjax: true
---
* content
{:toc}
Vundle 是 Vim bundle 的简称,是一个 Vim 插件管理器.





## 参考
[Vundle使用教程](https://steemit.com/cn/@ety001/vundle)<br>
项目地址[Vundle.vim](https://github.com/VundleVim/Vundle.vim)

## 使用
这里已经说的很详细了[Vundle.vim/README_ZH_CN.md](https://github.com/VundleVim/Vundle.vim/blob/master/README_ZH_CN.md)<br>
简单记录一下

#### 1.安装Vundle
```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```
#### 2.配置插件
新建`~/.vimrc`,填入<br>
其中`"`开头为注释，里面对如何安装插件说的很详细
```
set nocompatible              " 去除VI一致性,必须
filetype off                  " 必须

" 设置包括vundle和初始化相关的runtime path
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" 另一种选择, 指定一个vundle安装插件的路径
"call vundle#begin('~/some/path/here')

" 让vundle管理插件版本,必须
Plugin 'VundleVim/Vundle.vim'

" 以下范例用来支持不同格式的插件安装.
" 请将安装插件的命令放在vundle#begin和vundle#end之间.


" Github上的插件
" 格式为 Plugin '用户名/插件仓库名'
Plugin 'tpope/vim-fugitive'


" 来自 http://vim-scripts.org/vim/scripts.html 的插件
" Plugin '插件名称' 实际上是 Plugin 'vim-scripts/插件仓库名' 只是此处的用户名可以省略
Plugin 'L9'


" 由Git支持但不再github上的插件仓库 Plugin 'git clone 后面的地址'
Plugin 'git://git.wincent.com/command-t.git'


" 本地的Git仓库(例如自己的插件) Plugin 'file:///+本地插件仓库绝对路径'
Plugin 'file:///home/gmarik/path/to/plugin'
" 插件在仓库的子目录中.
" 正确指定路径用以设置runtimepath. 以下范例插件在sparkup/vim目录下
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}


" 安装L9，如果已经安装过这个插件，可利用以下格式避免命名冲突
Plugin 'ascenator/L9', {'name': 'newL9'}

" 你的所有插件需要在下面这行之前
call vundle#end()            " 必须
filetype plugin indent on    " 必须 加载vim自带和插件相应的语法和文件类型相关脚本
" 忽视插件改变缩进,可以使用以下替代:
"filetype plugin on
"
" 简要帮助文档
" :PluginList       - 列出所有已配置的插件
" :PluginInstall    - 安装插件,追加 `!` 用以更新或使用 :PluginUpdate
" :PluginSearch foo - 搜索 foo ; 追加 `!` 清除本地缓存
" :PluginClean      - 清除未使用插件,需要确认; 追加 `!` 自动批准移除未使用插件
"
" 查阅 :h vundle 获取更多细节和wiki以及FAQ
" 将你自己对非插件片段放在这行之后
```
#### 3.生效配置插件
添加插件后，在vim界面执行`:PluginInstall`，会自动安装`~/vimrc`中`Plugin `后面配置的插件，安装完成后下面会显示done

#### 4.安装示例
安装vim的树形浏览器插件[nerdtree](https://github.com/scrooloose/nerdtree)<br>
插件地址https://github.com/scrooloose/nerdtree<br>
修改`~/.vimrc`，加入
```
Plugin 'scrooloose/nerdtree'
```
执行
```
:PluginInstall
```
![](/uploads/2018/02/PluginInstall.png)
安装完成后，可通过
```
:NERDTree
```
查看目录




------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
