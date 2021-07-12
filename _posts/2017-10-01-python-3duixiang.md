---
layout: post
title:  "python(三)对象"
date:   2017-09-29 12:00:00 +0800
categories: Python
tags: python 对象
author: cndaqiang
mathjax: true
---
* content
{:toc}






# 参考
[简明python教程](https://bop.molun.net/)

[Python3教程-菜鸟教程](http://www.runoob.com/python3/python3-tutorial.html)

[20170812PHP学习(一)基础语法](http://www.jianshu.com/p/877bcd4f6e0d)

[一篇文章让你彻底搞清楚Python中self的含义](http://www.cnblogs.com/jessonluo/p/4717140.html)

# 概念
关于对象的关系概念可以参考[20170812PHP学习(一)基础语法](http://www.jianshu.com/p/877bcd4f6e0d)中的部分，在学php时我已经对对象有些了解了，概念部分就随便参考了-.-
> 类和对象
类似c语言的结构体
- 类 是对象的格式(模板)，规定了具体哪些属性(变量)和方法(函数)
- 对象 类的具体化，基于类创建的一种类型
>
如果以汽车对比的话如图，不过我感觉学过c语言结构体的人马上就懂了
![](http://upload-images.jianshu.io/upload_images/4575564-07722278c0d02c25.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

向我们前面说的，定义list类型的对象，如`list0=[1,2,3]`可以使用`list0.append()`来使用类中方法(函数)

这里list就是类，list0就是对象，类中定义了方法(函数)属性(变量)，如append()就是一个方法
```
>>> list0=[1,2,3]
>>> list.append(4)
>>> list0.append(4)
>>> list0
[1, 2, 3, 4]
```
常用概念

>- 类(Class): 用来描述具有相同的属性和方法的对象的集合。它定义了该集合中每个对象所共有的属性和方法。对象是类的实例。
- 类变量：类变量在整个实例化的对象中是公用的。类变量定义在类中且在函数体之外。类变量通常不作为实例变量使用。**就是类里面定义的变量**
- 实例变量：定义在方法中的变量，只作用于当前实例的类。
- 方法：类中定义的函数。
- 数据成员：类变量或者实例变量用于处理类及其实例对象的相关的数据。
- 继承：即一个派生类（derived class）继承基类（base class）的字段和方法。继承也允许把一个派生类的对象作为一个基类对象对待。例如，有这样一个设计：一个Dog类型的对象派生自Animal类，这是模拟"是一个（is-a）"关系（例图，Dog是一个Animal）。
- 方法重写：如果从父类继承的方法(函数)不能满足子类的需求，可以对其进行改写，这个过程叫方法的覆盖（override），也称为方法的重写
- 实例化：创建一个类的实例，类的具体对象。**创建一个类的对象**
- 对象：通过类定义的数据结构实例。对象包括两个数据成员（类变量和实例变量）和方法

下面正式开始走心记笔记

# 类
## 定义
**注意缩进和冒号**
### 类的方法(函数)
在类地内部，使用 `def`关键字来定义一个方法，与一般函数定义不同，**类方法必须包含参数**,惯例第一个参数名为self, 也可自定义为其他，但一定要有，还是用惯例吧

以下内容默认第一个参数名为self，self 代表的是类的实例/对象,无参数定义`def fun():`时，使用`对象.fun()`，会将对象的性质传给fun的第一个参数self，函数无参时没法接收这个参数，报错
### 关于self

self只在定义函数时出现，**只在函数内部使用**，参数每个函数都可自定义，以下默认类内所有的方法第一个参数都为self

- 在类实例化生成对象时，self自动指向为对象的地址，self等价于对象名
- 可在方法内用`self.变量/函数`来调用对象中的其他变量/函数(私有或非私有)

类内未定义的变量，在函数内使用`self.变量名=值`定义的变量编译时可能不出错，后期不知道会不会出问题，别这样用

### 类的属性(变量)
正常
### 类的私有方法
`__private_method`：**两个下划线开头，声明该方法为私有方法**，只能在类的内部调用 ，不能在类的外部调用，
### 类的私有属性
`__private_attrs`：**两个下划线开头，声明该属性为私有**，不能在类地外部被使用或直接访问。
### 关于私有
**私有方法/属性与正常的方法和属性区别仅在于能使用的范围不同，命名方式的不同，在类内的调用方法一样**
私有的名称包括`__`
如：若定义方法的参数为`def fun(self)`则方法内使用`self.方法/属性名`调用方法/属性，方法/属性名为私有或共有的都可以

我之前学习的误区**self和私有非私有是没有联系的概念，self与私有与self与非私有的使用没有什么异同**


### 继承类的定义
基类/父类正常定义
子类定义
```
class 子类/派生类名(基类/父类1，基类/父类2，基类/父类3)
```
- 子类支持多继承，之多个父类之间用逗号隔开
- 子类中定义了和父类中相同的方法/属性为重写，调用子类时以子类中定义使用，对父类无影响，即方法重写
- 子类中未定义的方法/属性，从左向右在父类中检查
- 基类/父类1可为与子类需在同一作用域内的类，或为某一模块内的类`模块.类`

```
class 类名:
 变量=值
 def 方法/函数名():
  函数体
```

如,抛出异常的示例
```
#定义类ShortInputException，其父类为Exception
 class ShortInputException(Exception):
        '''你定义的异常类。'''
#初始化
        def __init__(self, length, atleast):
            Exception.__init__(self)
            self.length = length
            self.atleast = atleast
#之后的内容为抛出异常捕获异常的代码
    try:
        s = raw_input('请输入 --> ')

        if len(s) < 3:
            # raise引发一个你定义的异常
            raise ShortInputException(len(s), 3)

    except EOFError:
        print '/n你输入了一个结束标记EOF'
    except ShortInputException, x:#x这个变量被绑定到了错误的实例
        print('ShortInputException: 输入的长度是 %d,长度至少应是 %d'% (x.length, x.atleast))
    else:
        print '没有异常发生.'
```
## 使用
>类对象支持两种操作：属性引用和实例化。
- 属性引用使用和 Python 中所有的属性引用一样的标准语法：obj.name。
- 类对象创建后，类命名空间中所有的命名都是有效属性名
- **类和对象的私有方法和函数都不能在外部以xx.xx方式使用**

### 属性引用
```
>>> print(lei.a)
2
>>> lei.fun()
hello
```
### 实例化类-对象
```
>>> x=lei()
>>> x.fun()
hello
```
### self示例
```
class lei():
 __siyou=5
 def fun(sef):    #推荐self，使用自定义如sef也行，之后就使用sef.xxx调用
  print(sef.__siyou)
  print(sef)
 num=__siyou+1    #方法外调用私有，直接写私有名称
x=lei()
x.fun()
print(x.num)
```
运行
```
$ python3 self.py 
5
<__main__.lei object at 0x7fe8e909da90>     #可以看到self代表类lei的一个对象(object)，地址0x7fe8e909da90，
6
```


## 类的专有方法
```
__init__ : 构造函数，在生成对象时调用
__del__ : 析构函数，释放对象时使用
__repr__ : 打印，转换
__setitem__ : 按照索引赋值
__getitem__: 按照索引获取值
__len__: 获得长度
__cmp__: 比较运算
__call__: 函数调用
__add__: 加运算
__sub__: 减运算
__mul__: 乘运算
__div__: 除运算
__mod__: 求余运算
__pow__: 乘方
```
### 构造函数`__init__`
```
def __init__(self,其他参数逗号隔开):
 函数体
```
定义对象时括号内的参数，传递给`__init__(self,其他参数逗号隔开)`中self后面的参数
```
x=lei(参数用逗号隔开)
```
### 析构函数`__del__`
没有啥特殊的




------
>本博客所有文章除特别声明外，均采用 [CC BY-SA 4.0 协议](https://creativecommons.org/licenses/by-sa/4.0/deed.zh) ，转载请注明出处！
