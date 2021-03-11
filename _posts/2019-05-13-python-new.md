---
layout: post
title:  "python报错"
date:   2019-05-13 14:01:00 +0800
categories: Python
tags: python 
author: cndaqiang
mathjax: true
---
* content
{:toc}

放一些杂七杂八的用法









## 
### python enumerate用法总结
[python enumerate用法总结](https://blog.csdn.net/churximi/article/details/51648388)
```python
>>> for i,name in enumerate( ('x','y','z') ):
...  print i, name
...
0 x
1 y
2 z
```

## 问题
python脚本开头没写python运行,执行后，因`import`命令使鼠标变成十字<br>
参考[Ubuntu(Linux)下鼠标锁死变成十字](https://www.jianshu.com/p/4c25b864c516)

解决
```
(python37) cndaqiang@girl:~$ ps -e | grep import
21090 pts/1    00:00:00 import
(python37) cndaqiang@girl:~$ kill -9 21090
```


### `divide by zero encountered in double_scalars`
```
RuntimeWarning: divide by zero encountered in double_scalars
```
因为自己写自相关函数时，当`t=总步长-1`时,只有一个数据, 分母 $ \< x^2 \> - \< x \> ^2 == 0 $

### `if [ ] `用错判断符号
应该用`()`或不用
```python
>>> if [ 2 > 3 ]:
...  print("2>3")
...
2>3
```------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
