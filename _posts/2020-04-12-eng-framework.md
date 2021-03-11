---
layout: post
title:  "[开发中...]英语笔记: 语法框架"
date:   2020-04-12 23:30:00 +0800
categories: FuckEnglish
tags:  English
author: cndaqiang
mathjax: true
---
* content
{:toc}

又双叒叕要开始认真学英语. <br>
英语小白开始从程序的角度理解英语. 补充材料在仓库[EnglishTools@cndaqiang](https://gitee.com/cndaqiang/EnglishTools). <br>
**本人英语小白,仅供娱乐,请勿参考.**





## 致谢
想法和灵感来自十四年毫无进展的英语学习经历、辛苦教导我的亲爱的英语老师们、付钱但是没看一节课就结课了的钟平老师的逻辑英语、张道真的实用英语语法系列等. <br>
目前主要的参考材料:
- 张道真 实用英语语法 



## 总结(感觉)

- **英语表达的基本单元是句子**,就像一个可执行的subroutine,执行(call)后处理输入变量(单词,短语,从句)产生效果

- 有的subroutine是用来陈述事实,有的用来提出问题,这就是各个subtoutine的功能:**把输入变量按照顺序组合计算出相应的表达**

- **输入变量的类型主要有:单词及其有效的组合(短语,从句等)**

- 在subroutine排序的前提下,我们可以通过调节输入变量(如单词的不同形式),进一步微调表达的效果(如同一件事有不同的时态)

- 有很多人开发了可用的函数库(特殊用法), 了解这些库的规则, 才能读懂程序. 

**所以,我们要先建立其句子的构成方法,定义subroutine, 然后研究输入参数类型(单词及其有序组合)的取值范围,执行程序**


## 句子SUBROUTINE
```
SUBROUTINE sentence(word(1:n)单词,phrases(1:n)短语,clause(1:n)从句)
```
注:
- 0.基本规则:首字母大写
- 1.根据输入变量确定句子返回数组的元素:主,谓,宾, 定, 状, . . . 
- 2.按照功能对返回元素进行排序
- 3.输出

### 句子的功能:表达想法
完成某种功能, 需要的元素不同, 元素的顺序不同. 
- 同一种功能可以有多种排序
- 一种排序也可能对应多种功能
- 通常的排序和特殊的排序都存在

基本功能
- 陈述句statement:陈述事实<br>
最常用
- 问句Question:提出问题
- 祈使句Impretive:陈述事实
- 感叹句Excalamation:陈述事实


#### **陈述句statement:陈述事实**
#### **问句Question:提出问题**
#### **祈使句Impretive:陈述事实**
#### **感叹句Excalamation:陈述事实**


### 句子成分:基本元素
```
element(3,n[,l,m,s])
```
第一维度是必要成分
- `element(1,:)`:主语
- `element(2,:)`:谓语
- `element(3,:)`:宾语

第二维度是对上一维度的修饰,也可认为后面的维度和前面一起构成第一维度定义的元素, 如
- `element(1,1)`:名词;主语
- `element(1,2)`:adj;定语, 修饰主语`element(1,1)`

- `element(2,1)`:动词;谓语
- `element(2,2)`:adv;状语

<center>主要元素</center>

|元素 |定义 |
|--|--|
|**主语<br>Subject**| 句子的中心,**整句话微绕其展开**,动作的发起者. |
|**谓语<br>Predicate**| 主语的情况, 主语的动作(动词)或状态(系+谓)|
|**宾语<br>Object**|动作的承受者, 动作的结果 |
| | 下面的是上面元素的更低维度|
|**表语<br>Predicative**|**和系动词构成谓语**, 作为谓语的成分 |
|**定语<br>Attribute**|形容一个东西<br>修饰名词性词(名词,代词;主语/宾语) |
|**状语<br>Adverbial**|交代时间地点, 形容动作, 形容adj.<br>修饰非名词性词(adj,adv,vt,vi;定语,谓语, 表语) <br> She feels *very* happy. 修饰形容词  |
|**同位语<br>Appositive**|同一元素位置出现两个等价元素,如`主语`element(1,1)`由主语`element(1,1,1)`和其同位语`element(1,1, ２)`两个名词性东西构成<br>This is my sister *Mary*. |
|**插入语<br>Parenthesis**|被另一个句子插入,去除不影响之前的顺序.<br>Mary is a good girl,*they say*. |
|**呼语<br>Vocative**| 对人的称呼<br>Sit down,*Mary*.|


### 语序:对元素的排列
**最通常的**
`(状)`+`(定)主(定)`＋`谓(状)`+`(定)宾(定)`＋`(状)`


#### 主语&谓语
**常规的语序规则**
- **自然语序：主语在谓语前**
  - 大多数陈述句
  - 疑问词`who etc`做主语,主语在谓语前<br>
  *Who* put forward the propesal ?
  - 感叹句、陈述表疑问的句子etc,张.24.1.2
- **倒装语序**:谓语跑到主语前
  - 部分陈述句<br>
  There *comes* the bus.
  - 大部分疑问句<br>
  *Are* you going home for Christmas? be动词倒装<br>
  Where *can* I park the car ? 情态动词can 倒装
  - 更多,张24.2  

#### 宾语
**通常**
- `谓语+宾语`
- `谓语＋直接宾语+间接宾语`<br>
Show *us your papers*
- 疑问词构成的宾语在主语前<br>
*What* she said impressed me deeply.

**会有宾语提前的情况**

**也有把宾语置后的情况**

@张.24.3

#### 定语
adj放前面,adv放后面(注意这里的adv修饰的是名词性的东西, 不是构成状语)
- 单词构成定语时
  - 一般放在修饰词的前面
  - 副词放在被修饰词的后面<br>
  The situation *here* is highly explosive.

**放后面的**
- 定语从句放在被修饰的后面<br>
THe noise *he made* woke everybody up.

- 介词短语放后面<br>
She loccked to be a young woman *of twenty*.

- 分词短语和不定式放后面

**异常情况**
- 定语和修饰词分开

**定语的语序**:多个定语修饰同一个物体,定语内部有排序

#### 状语


**通常:状语在谓语的后面**
- `谓语+状语`
- `谓语+宾语+状语`
- `状语+过去分词ed`<br>
he was *rightly* punished.
- 若有时间地点,小单位在前

**特殊情况:句首情况**
- 状语放句首,表强调<br>
*After midnight*, the party broke up. 
- 疑问词的状语放句首<br>
  *In which year* were you born ?
- etc.张24.5.2

**特殊情况:主＋状+谓**
- 特殊副词可以放在主谓之间`主+状(adv)+谓`<br>
SHe *quickly* finished the letter.
- 短语或词组表示的状语可以放在主谓之间<br>


**状语从句**
- 通常放句子最后
- 有时放句子前,通常有**逗号**与主句隔开<br>
*However cold it is*, she always goes swimming.
- 少数情况可以`主+状语从句+谓语`<br>
This view, though understanding, is wrong.


### Beyond SUBRUOTINE

- **简单句:句子元素全部由单词或短语构成, 且仅有一套主谓结构**<br>
输入参数只能是基本变量的最常见SUBROUTINE<br>
We love our great motherland.

- **复合句:句子的基本元素被从句所替代**,主句有主谓, 从句中也可能有主谓<br>
SUBROUTINE的输入参数可能也是一个SUBROUTINE,如积分程序调用被积分函数<br>
Do you see *what I mean*?

- **并列句:多个互不依存可以独立存在的分句组成**,用连词或`,`隔开,分句是个完整的SUBROUTINE<br>
MPI并行程序,各自独立, 共同干活(表达意图)<br>
Honey is swet, but the bee stings.


## 之后应该会具体的看句子的基本元素以及元素的更基本单元单词. 
- 先调一些软柿子去捏,比如主语,形容词, 连词
- 不用按照顺序去看, 可以都粗略的看一看
- 最后看看难的
- 在阅读/题目中寻找语法



## 看视频学英语
- [@口语老炮儿马思瑞Chris](https://www.youtube.com/watch?v=-i90nkYc8I8)
看新的剧，选则现实的场景，架空的世界，历史情节，不适合<br>
选择一个角色的声音去适应模仿,语气,节奏,声音,发音不为更接近的人<br>
  - TV show: 奋斗
  - 摩登家庭
  -　老爸老妈的浪漫史
  -　艾伦秀,柯南，:美<>英:詹姆斯柯登，格拉汉姆诺顿秀
  -　神烦警探，实习医生风云，硅谷
  -------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
