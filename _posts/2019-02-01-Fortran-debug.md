---
layout: post
title:  "Fortran 的gdb命令行调试"
date:   2019-02-01 12:09:00 +0800
categories: Fortran
tags:  Fortran
author: cndaqiang
mathjax: true
---
* content
{:toc}


shell+gfortran





## 参考
[《Fortran实用编程》系列视频教程 - Fortran Coder 研讨团队](http://v.fcode.cn/)<br>

[使用 GDB 调试 Linux 软件](https://www.ibm.com/developerworks/cn/linux/sdk/gdb/index.html)



## 编译`-g`
```
gfortran -g xxx.f90 -o run.o
gdb run.o
```
进入调试状态

## gdb调试命令
`l`查看源码
```
Reading symbols from a.out...done.
(gdb) l
1       program str
2             implicit none
3             integer::filenum(5)
4             integer::i,uid
5             character(len=10) :: filename
6             data filenum /1,12,123,1234,12345/
7             uid=20
8             filename="qwertyuiop"
9             do i=1,5
10            write(filename,"(i6.5a4)") filenum(i),".txt"
(gdb)!回车查看下一页
```
`b 8`会`break 8`在第8行加断点

`'disable <breakpoint number>'、'enable <breakpoint number>' 或 'delete <breakpoint number>' `来禁用、启用和彻底删除断点

`r`或`run` 从头开始运行

`c`或`continue`继续执行

`n`或`next`单步调试

```
(gdb) next
10            write(filename,"(i6.5a4)") filenum(i),".txt"
(gdb) next
11            write(*,"(a10)") filename
```



`info locals`查看变量信息

`print 变量名`查看某一变量信息

```
(gdb) info locals
filename = ' 12345.txt'
filenum = (1, 12, 123, 1234, 12345)
i = 6
uid = 20
(gdb) print i
$4 = 6 !4是第四个变量
```

`set var bianliang=值`该变数值

```
(gdb) info locals
filename = ' 00001.txt'
filenum = (1, 12, 123, 1234, 12345)
i = 1
uid = 20
(gdb) set var filenum(1)=10
(gdb) info locals
filename = ' 00001.txt'
filenum = (10, 12, 123, 1234, 12345)
i = 1
uid = 20
```



`q`或`quit`退出






------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
