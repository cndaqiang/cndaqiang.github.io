---
layout: post
title:  "python杂七杂八放着里"
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
```
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





