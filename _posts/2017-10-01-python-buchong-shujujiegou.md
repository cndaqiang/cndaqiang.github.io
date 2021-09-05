---
layout: post
title:  "python(补充2)数据结构"
date:   2017-10-01 12:00:00 +0800
categories: Python
tags: python 
author: cndaqiang
mathjax: true
---
* content
{:toc}

主要针对python对象类型中的字符串str，列表list，元组tup，集合set，字典dir
补充的不全，有机会回来增加




## 参考
[Python3教程-数据结构| 菜鸟教程](http://www.runoob.com/python3/python3-data-structure.html)

回顾以下python(一)基本语法里面的内容

| 类型  |  有序 | 引用元素 `[]`  | 修改元素 |元素类型|定义示例| 备注 |
| ------------ | ------------ | ------------ | ------------ |
| 字符串string | √  | 索引下标  | ×  |字符（串）|`str0='string'` |   |
| 列表list  |  √ |  索引下标 |  √ |任意组合| `list0=[1,2,'3']`  |   |
|  元组tuple | √  | 索引下标  |  × |任意组合|`tup0=(1,2,'3')`|   |
| 集合set  |  × | 无  | 无 |不包含list，tuple，dict |`set0={1,2,'3'}`| {}用于定义空字典，set()为空集合  |
| 字典dict  |  × |  key | √  |任意组合|`dict0={1:1,'2':2,3:'3'}`|   |


### 关于list的一些用法

方法	|描述
--|--
list.append(x)	|把一个元素添加到列表的结尾，相当于 a[len(a):] = [x]。
list.extend(L)	|通过添加指定列表的所有元素来扩充列表，相当于 a[len(a):] = L。
list.insert(i, x)	|在指定位置插入一个元素。第一个参数是准备插入到其前面的那个元素的索引，例如 a.insert(0, x) 会插入到整个列表之前，而 a.insert(len(a), x) 相当于 a.append(x) 。
list.remove(x)	|删除列表中值为 x 的第一个元素。如果没有这样的元素，就会返回一个错误。
list.pop([i])	|从列表的指定位置删除元素，并将其返回。如果没有指定索引，a.pop()返回最后一个元素。元素随即从列表中被删除。（方法中 i 两边的方括号表示这个参数是可选的，而不是要求你输入一对方括号，你会经常在 Python 库参考手册中遇到这样的标记。）
list.clear()	|移除列表中的所有项，等于del a[:]。
list.index(x)	|返回列表中第一个值为 x 的元素的索引。如果没有匹配的元素就会返回一个错误。
list.count(x)	|返回 x 在列表中出现的次数。
list.sort()	|对列表中的元素进行排序。
list.reverse()	|倒排列表中的元素。
list.copy()	|返回列表的浅复制，等于a[:]

**上述用法可将列表用于堆栈或队列使用**

## 关于字典

字典对象中的item()方法可以输出字典中所有的key和value，如
```
>>> set0={'name':'ming','num':123456}
>>> set0.items()
dict_items([('name', 'ming'), ('num', 123456)])
>>> for k,v in set0.items():
...  print(k,v)
... 
name ming
num 123456
```





------
>本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
