---
layout: post
title:  "python: 格式化输入输出、文件操作"
date:   2017-10-01 12:00:00 +0800
categories: Python
tags: python 
author: cndaqiang
mathjax: true
---
* content
{:toc}




# 一些函数

## print
### 输出字符串，列表等
```python
print('hello')
print(str1,str2,str3)  #连接输出，中间以空格隔开
print(list)
```
print每执行一次，输出后最后默认加一个回车，可以print(str1,edn='结束内容')，指定输出后的内容
```python
>>> print('a');print('b')
a
b 
>>> print('a',end='');print('b')
ab
>>> print('a',end=' ');print('b')
a b
```

### 格式化输出
- %s --- 字符串
- %d --- dec十进制
- %x --- hex 十六进制
- %d --- dec 十进制
- %o --- oct 八进制
- %f --- 浮点数
- %m.nf --- 整数部分m个，不够补空格，小数部分n个

**更多格式先略**
```python
>>> print('%x' %23)
17
>>> str='hello,%d,%x,%o' %(45,45,45)
>>> print(str)
hello,45,2d,55
```
## format
Python2.6 开始，新增了一种格式化字符串的函数 str.format()<br>
基本语法是通过`{}`和`:`来代替以前的%<br>
用于`print(str.format())`格式化输出很好
<br>以下语法摘自参考[菜鸟教程](http://www.runoob.com)

```python
>>>"{} {}".format("hello", "world")    # 不设置指定位置，按默认顺序
'hello world'
 
>>> "{0} {1}".format("hello", "world")  # 设置指定位置
'hello world'
 
>>> "{1} {0} {1}".format("hello", "world")  # 设置指定位置
'world hello world'
```

也可设置参数

```python
print("网站名：{name}, 地址 {url}".format(name="菜鸟教程", url="www.runoob.com"))
 
# 通过字典设置参数
site = {"name": "菜鸟教程", "url": "www.runoob.com"}
print("网站名：{name}, 地址 {url}".format(**site))
 
# 通过列表索引设置参数
my_list = ['菜鸟教程', 'www.runoob.com']
print("网站名：{0[0]}, 地址 {0[1]}".format(my_list))  # "0" 是必须的
```

数字格式<br>
![](/uploads/2018/02/pasted_image001.png)
进制<br>
![](/uploads/2018/02/pasted_image002.png)


<br><br><br><br>

# 文件操作
## 文件读写

推荐使用with打开,这样在遇到文件读写IOError时会自动调用f.close(),保证文件正常关闭

```python
with open(文件名,模式) as f:
	print(f.read())
```
### 打开文件
```python
open(文件名,模式)
#如
f=open('../test.txt','w')
```
- 文件名使用字符串，支持绝对路径相对路径
- 模式(引自传智播客)
<table>
<thead>
<tr>
<th style="text-align:center">访问模式</th>
<th style="text-align:left">说明</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:center">r</td>
<td style="text-align:left">以只读方式打开文件。文件的指针将会放在文件的开头。这是默认模式。</td>
</tr>
<tr>
<td style="text-align:center">w</td>
<td style="text-align:left">打开一个文件只用于写入。如果该文件已存在则将其<b>覆盖</b>。如果该文件不存在，创建新文件。</td>
</tr>
<tr>
<td style="text-align:center">a</td>
<td style="text-align:left">打开一个文件用于追加。如果该文件已存在，文件指针将会放在文件的结尾。也就是说，新的内容将会被写入到已有内容之后。如果该文件不存在，创建新文件进行写入。</td>
</tr>
<tr>
<td style="text-align:center">---</td>
<td style="text-align:left">-----------</td>
</tr>
<tr>
<td style="text-align:center">rb</td>
<td style="text-align:left">以二进制格式打开一个文件用于只读。文件指针将会放在文件的开头。这是默认模式。</td>
</tr>
<tr>
<td style="text-align:center">wb</td>
<td style="text-align:left">以二进制格式打开一个文件只用于写入。如果该文件已存在则将其覆盖。如果该文件不存在，创建新文件。</td>
</tr>
<tr>
<td style="text-align:center">ab</td>
<td style="text-align:left">以二进制格式打开一个文件用于追加。如果该文件已存在，文件指针将会放在文件的结尾。也就是说，新的内容将会被写入到已有内容之后。如果该文件不存在，创建新文件进行写入。</td>
</tr>
<tr>
<td style="text-align:center">---</td>
<td style="text-align:left">-----------</td>
</tr>
<tr>
<td style="text-align:center">r+</td>
<td style="text-align:left">打开一个文件用于读写。文件指针将会放在文件的开头。</td>
</tr>
<tr>
<td style="text-align:center">w+</td>
<td style="text-align:left">打开一个文件用于读写。如果该文件已存在则将其覆盖。如果该文件不存在，创建新文件。</td>
</tr>
<tr>
<td style="text-align:center">a+</td>
<td style="text-align:left">打开一个文件用于读写。如果该文件已存在，文件指针将会放在文件的结尾。文件打开时会是追加模式。如果该文件不存在，创建新文件用于读写。</td>
</tr>
<tr>
<td style="text-align:center">---</td>
<td style="text-align:left">-----------</td>
</tr>
<tr>
<td style="text-align:center">rb+</td>
<td style="text-align:left">以二进制格式打开一个文件用于读写。文件指针将会放在文件的开头。</td>
</tr>
<tr>
<td style="text-align:center">wb+</td>
<td style="text-align:left">以二进制格式打开一个文件用于读写。如果该文件已存在则将其覆盖。如果该文件不存在，创建新文件。</td>
</tr>
<tr>
<td style="text-align:center">ab+</td>
<td style="text-align:left">以二进制格式打开一个文件用于追加。如果该文件已存在，文件指针将会放在文件的结尾。如果该文件不存在，创建新文件用于读写。</td>
</tr>
</tbody>
</table>

### 关闭文件
```
f.close()
```
### 写入数据
写入后文件中的光标自动移位
```
f = open('test.txt', 'w')
f.write('hello world, i am here!')
f.close()
```
### 读取数据
读取后文件中的光标自动移位
- read(N) 读取N个字符，无N读取所有
- readlines() **一次性读取，每行为一个字符串组成list**
- readline() 读取一行，返回字符串
```
f = open('test.txt', 'r')
con=f.read()
f.close()
```
大文件时，逐行读取然后复制写入
### 读写位置
- tell()
- seek(offset,from)
<br>seek偏移量
<br>from:起始位置:0文件开头１当前位置２文件末尾
```
#统计行数，并移至开头
f=open(inputfile)
rownum=len(f.readlines())
ierror=f.seek(0,0)
```

### 示例
```python
with open(inputfile,'r') as f:
    for i in np.arange(4): f.readline() #跳过前4行
    #读入剩下所有数据
    data=[ [ float(i) for i in line.split() ] for line in f.readlines() ] 
    data=np.array(data)
spectrum=data[:,[0,2,3,4]] #提取一些数据
```




### 判断文件是否读至结尾
[python中判断readline读到文件末尾](https://www.cnblogs.com/summerkiki/p/4472043.html)
```
    line=f.readline()
    if not line:      #等价于if line == "":
        break
```

## os模块
### 文件重命名删除
```python
import os
os.rename("old_name","new_name")
os.remove("name")
os.mkdir("目录名")
os.getcwd() #获取当前路径
os.chdir("路径")
os.listdir("路径")　#ls
os.rmdir("目录名")　#rmdir
os.path.exists("文件/目录") #检查文件/目录是否存在
os.path.isfile("文件") #检查文件是否存在
```
### 执行系统命令
```python
>>> b=os.system("grep a_1 "+inputfile)
                    a_1    11.999994   0.000000   0.000000
>>> b
0
>>> b=os.popen("grep a_1 "+inputfile)
>>> b.readlines()
['                    a_1    11.999994   0.000000   0.000000\n']
```
## 报错
### 文件中有特殊的字符,删除
```
UnicodeDecodeError: 'utf-8' codec can't decode byte 0xa6 in position 595: invalid start byte
```
特殊字符
```
!¦¤t=t2?t1 for the calculation of Uk(t2,t1) in tddft, 1 a.u.=0.048378 fs
```\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
