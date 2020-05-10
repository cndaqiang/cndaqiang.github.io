---
layout: post
title:  "vim配置和使用"
date:   2018-02-12 12:06:00 +0800
categories: Linux
tags: vim YouCompleteMe
author: cndaqiang
mathjax: true
---
* content
{:toc}
此文记录我对vim的配置和使用的一些插件
<br>基于vim插件管理程序[vim插件管理Vundle](/2018/02/11/vim-plugin/)




# vim设置
- 可以在使用vim时通过命令模式执行命令,仅此次生效
- 也可以将命令保存到`~/.vimrc`每次打开vim自动生效

### 关闭缩进
参考[解决vi/vim中粘贴会在行首多很多缩进和空格的问题](http://www.cnblogs.com/end/archive/2012/06/01/2531142.html)
<br>缩进在写代码时很有用，但有时候复制网上代码时，缩进会造成过多的空格和字符不美观
<br>建议仅在复制前执行关闭缩进命令
关闭缩进
```
:set paste
```
恢复缩进
```
:set nopaste
```
### 针对文件`au`
```
au BufNewFile,BufRead *.py
\ set tabstop=4     "tab键换成4个空格
\"\后跟命令，进针对au制定的文件
```
### 支持UTF-8编码
```
set encoding=utf-8
```
<br><br><br><br>
# 插件
## YouCompleteMe补全插件
参考[安装YouCompleteMe插件-非C系列](https://www.jianshu.com/p/f15018e5fafe)<br>
项目地址[Valloric/YouCompleteMe](https://github.com/Valloric/YouCompleteMe)<br>
里面的README.md已经说的很详细了，简单记录ubuntu16.04针对python代码补全的安装过程
<br>其他更多内容参考[Valloric/YouCompleteMe](https://github.com/Valloric/YouCompleteMe)
```
sudo apt update
sudo apt install build-essential cmake
sudo apt install python-dev python3-dev
# 下载源码 
git clone https://github.com/Valloric/YouCompleteMe.git ~/.vim/bundle/YouCompleteMe
cd ~/.vim/bundle/YouCompleteMe
git submodule update --init --recursive
./install.py
```
编译完成后，修改`~/.vimrc`添加插件
```
Plugin 'Valloric/YouCompleteMe'
```
安装插件`:PluginInstall`
然后测试`vi test.py`
<br>输入以下内容，会出现自动补全的代码
```
import os
os.
```
更多配置，添加下列内容到`~/.vimrc`
```
"默认配置文件路径"
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/YouCompleteMe/cpp/ycm/.ycm_extra_conf.py'
"打开vim时不再询问是否加载ycm_extra_conf.py配置"
let g:ycm_confirm_extra_conf=0
set completeopt=longest,menu
"python解释器路径"
let g:ycm_path_to_python_interpreter='/usr/bin/python'
"是否开启语义补全"
let g:ycm_seed_identifiers_with_syntax=1
"是否在注释中也开启补全"
let g:ycm_complete_in_comments=1
let g:ycm_collect_identifiers_from_comments_and_strings = 0
"开始补全的字符数"
let g:ycm_min_num_of_chars_for_completion=2
"补全后自动关机预览窗口"
let g:ycm_autoclose_preview_window_after_completion=1
" 禁止缓存匹配项,每次都重新生成匹配项"
let g:ycm_cache_omnifunc=0
"字符串中也开启补全"
let g:ycm_complete_in_strings = 1
"离开插入模式后自动关闭预览窗口"
autocmd InsertLeave * if pumvisible() == 0|pclose|endif
"上下左右键行为"
inoremap <expr> <Down>     pumvisible() ? '\<C-n>' : '\<Down>'
inoremap <expr> <Up>       pumvisible() ? '\<C-p>' : '\<Up>'
inoremap <expr> <PageDown> pumvisible() ? '\<PageDown>\<C-p>\<C-n>' : '\<PageDown>'
inoremap <expr> <PageUp>   pumvisible() ? '\<PageUp>\<C-p>\<C-n>' : '\<PageUp>'
```



