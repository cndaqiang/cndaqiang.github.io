---
layout: post
title:  "Fortran 学习笔记"
date:   2019-01-30 12:12:00 +0800
categories: Fortran
tags:  Fortran
author: cndaqiang
mathjax: true
---
* content
{:toc}

虽然整理成博客，很浪费时间，不过，每次忘记后，再捡起来，还要好久，还是继续把笔记整理成文章<br>
该文不完全，看siesta代码中遇到其他的语法再添进来<br>






## 参考
Fortran95程序设计【彭国伦】<br>
[《Fortran实用编程》系列视频教程 - Fortran Coder 研讨团队](http://v.fcode.cn/)<br>
[详论fortran格式化输出](http://blog.sciencenet.cn/blog-287062-269811.html)


## 注意
- **大坑,定义的变量在计算前要手动赋值初始化，重复掉用此函数，即使在定义变量时初始化，有时候变量里面也有值，累加大忌**
- **DO i=start,end循环结束后,i=end+1**

## 语法规则
代码结构<br>
语句 =>**程序单元(主程序program,子例程序subroutine,函数function )** => 模块（module） => 程序
### 语句规则和特点

|        |           固定格式           |           自由格式           |
| ----- |: -------------------------- :| :-------------------------- :|
| 英文   |         Fixed-format         |         Free-format          |
| 扩展名 |      `.for      .f   ... `     |    `.f90   .f95   .f03 ... `   |
| 语法   | F66、F77、F90、F95、F03、F08 | F66、F77、F90、F95、F03、F08 |
| 格式   |       代码从第7格开始        |             任意             |
| 续行   |    在第6格键入一个非0字符    | 上一行结束下一行开头加入   & |
| 行宽   |              72              |             132              |
| 注释   |    行首打  C 或    c 或 `* `   |      注释前打感叹号   !      |
| 说明   |        不推荐，已废止        |             推荐             |

- 不区分大小写，字符串的里的大小写区分(ASCII码不同)
- 语句结束时不用添加结束标志
- 编译器可取消行宽限制`gfortran -ffree-line-length-none` 
- 编译器向下兼容Fortran语法
- 数组下标从1开始
- **函数子例程序都是传址调用，不要随便修改传入变量**
- 程序单元内声明语句必须放在执行语句前
- 变量/数组的定义和调用直接用变量名
- 编译器默认根据拓展名判断语法格式![](/upload/2019/01/fortran.png)
- 将Module写成一个文件，调用时要加`USE ModuleName`
- 将subroutine写成一个文件，可以直接调用
- `real(dp)`中的`dp`必须是`parameter`类型，不然会报错

### 程序单元
程序单元可以写在不同的文件内进行编译，最后把分别编译的Obj链接成一个可执行文件与把他们写在一个文件里面编译等价
- 写在不同的文件内，可以提高编译速度，修改部分代码，仅需编译修改代码所在文件

主程序program，有且仅有一个，作为程序入口<br>
子例程序subroutine，没有返回值的函数

### 模块
一组程序单元及一组相关联的变量，可组成模块（module）



## 数据类型
默认ijklmn开头的变量为为整型，其他为实型，通过下面命令取消此默认规定
```
Implicit None 
```
### 变量定义
常用:**类型( 属性 ) , 形容词 , 形容词 ...  :: 变量名（数组外形）= 值 , 变量名2（数组外形）= 值**

**定义多个变量用`,`隔开，用空格不行**



### 类型

- 整型（Integer）
- 实型（Real）
- 复数Complex 类型（本质上是real）
- 字符型（Character）
- 派生（type）类型

例
```
Real(Kind=8) , parameter , private :: rVar = 20.0d0
Character(Len=32) , Intent( IN ) :: cStr(5,8)
Integer , save :: n = 30 , m = 40
Integer m
complex :: com
#如果( , )构造复数报错，可以使用cmplx(real,image)函数
yc(i)=cmplx(yr(i),yi(i)) 

```

### 属性

####  数值型kind
用于解决不同编译器默认表达范围不一致问题<br>
整形最大可表示i位示例
```
! k = Selected_Int_Kind( i )  可以用这个函数来选择能满足要求的Kind
! i 表示需要最大的十进制位数
! k 表示返回的能满足范围的最小的Kind值	
! Selected_Int_Kind( i )函数可以放在声明语句里
integer , parameter :: KI=selected_int_kind(10)
integer(kind=KI) :: i1 i2 i3
```
实数精度
```
! k = Selected_Real_Kind( r , p )  可以用这个函数来选择能满足要求的Kind
! r 表示需要最大的十进制位数 , p 表示最小的有效位数 p位*E^r
! k 表示返回的能满足范围的最小的Kind值
integer , parameter :: DP=selected_real_kind(r=50,p=14)
real(kind=DP) :: r1 r2
```
复数精度
```
双精准度 - 使用两个双精准浮点数 
complex(kind=8) a ! F90新增作法 
complex(8)      a ! 
COMPLEX*16      a ! F77传统作法
```

**在数值后面加kind数值，表明数值类型**，如siesta

```
! Initialize some variables(Double precision:dp=8)
      DUext = 0.0_dp
      Eharrs = 0.0_dp
      Eharrs1 = 0.0_dp
```
若一个函数要求输入双精度实数，要传递`xxx.xx_dp`给这个函数，否则会结果异常，如
```
dp=8
call Pdgemm("N","N",2,8,2,1.0_dp,A,1,1,DESCA,B,1,1,DESCB,0.0_dp,C,1,1,DESCC)
```
平方根函数要求`sqrt()`输入为实数或复数，因此`sqrt(2)`会报错，而`sqrt(2.0)`才是正确的
complex与实数kind一样

#### 字符型len
kind默认为1(ASCII码格式)，也可通过Selected_Char_Kind( 'ASCII' )确定<br>
len表示长度
```
character(len=32) :: str
```

###  形容词
parameter 常量

| 形容词    | 功能                                                     |
| --------- | -------------------------------------------------------- |
| parameter | 常量                                                     |
| save      | 函数内定义，当函数再次被调用时，使用上次该函数被调用的值 |



### 数值型

#### 赋值

```
complex :: com
com=(实部,虚部)
```

#### 运算

直接`+ - * \( )`

乘方`**`

取余`mod(x,y)`为x/y的余数，y!=0

<br>

#### 逻辑运算
参考[逻辑运算](http://micro.ustc.edu.cn/Fortran/ZJDing/Sec2-2.htm)

##### 关系运算


|关系运算符英文|符号 |英语含义 | 中文含义 |
|----|----|----|----|
| .GT. | `>` | Greater Than | ＞ (大于) |
| .GE. | `>=` | Greater than or Equal to | ≥ (大于或等于) |
| .LT. | `<` | Less Than | ＜ (小于) |
| .LE. | `<=` | Less than or Equal to | ≤ (小于或等于) |
| .EQ. | `==` | EQual to | ＝ (等于) |
| .NE. | `/=` | Not Equal to | ≠ (不等于) |

**符号和英文都可以写**

##### 逻辑运算


|关系运算符 | 含义 |逻辑运算例 | 例子含义 |
|----|----|----|----|
| .AND. | 逻辑与 | A.AND.B |    A，B为真时，则A.AND.B为真 |
| .OR. | 逻辑或 | A.OR.B |    A，B之一为真，则A.OR.B为真 |
| .NOT. | 逻辑非 | .NOT.A |    A为真，则.NOT.A为假 |
| .EQV. | 逻辑等价 | A.EQV.B |    A和B值为同一逻辑常量时，A.EQV.B为真 |
| .NEQV. | 逻辑不等价 | A.NEQV.B |    A和B的值为不同的逻辑常量，则A.NEQV.B为真 |


**注意不要将.AND.与.EQV.混淆：A.AND.B是当A和B均为真时才为真；A.EQV.B是当A和B均为真或均为假时为真。**



### 字符串
声明
```
character(len=字符串长度) :: str
```
赋值与调用，**下标从1开始**
```
character(len=7) ::str
str="hello!!"
!gfortran 对这种写法报错 str(2)="12345"
!str(n:m)即可用于赋值，也可用来掉用
!str等价str(1:len(str))
!str(n:)等价str(n:len(str))
str(2:3)="tr"
write(*,*) str(3:3)
```
字符串函数

| 函数           | 功能                                                         |
| -------------- | ------------------------------------------------------------ |
| CHAR(num)      | 返回数值num对应的ASCII码字符                                 |
| ICHAR(char)    | 字符转数字                                                   |
| LEN(str)       | 字符串长度                                                   |
| LEN_TRIM(str)  | 去除字符串尾部的空格的字符串长度(实际长度，例如后面几个没赋值) |
| INDEX(str,key) | str中第一次出现字符串key的位置<br>可用于文件读取时，由某个数据的前后索引，确定数据的下标 |
| TRIM(str)      | 清除str尾部的空格后的字符串                                  |
| str1 // str2   | 连接字符串                                       |
| adjustl(str)   | 清除st前的空格后，就是左移，并在后面补空格                                |
| adjustr(str)   | 清除st后的空格后，就是右移，并在前面补空格                                |
| trim(adjustl(syslab))  | 组合用提取字符串部分                               |

示例
```
    syslab="  ---abc==="
    write(*,*) "adjustl"//adjustl(syslab)//"end"
    write(*,*) "adjustr"//adjustr(syslab)//"end"
    write(*,*) "trim"//trim(syslab)//"end"
    write(*,*) "trim(adjustl)"//trim(adjustl(syslab))//"end"
```
结果
```
 #     |<                            >!
 adjustl---abc===                     end
 adjustr                     ---abc===end
 trim  ---abc===end
 trim(adjustl)---abc===end
```
INDEX示例
```
str="hello,world"
WRITE(*,*) INDEX(str,"llo") !返回结果为3,即str中第3个元素及之后是llo
```



### 数组

#### 定义

```
类型,形容词 :: 数组名(n1,n2,n3...维度)
类型,形容词 :: 数组名(n0:n1,m0:m1,...) 也可以，n0,m0也可从负数开始
```

**动态数组**

加上`allocatable`形容词

```
类型,allocatable,其他形容词 :: 数组名(:,:,:....) !用:
!分配大小
allocate(array(N))
!释放空间
deallocate(array)
```

**ALLOCATE分配的数据边界可以是正数，负数，０**<br>
参考[数组赋值与运算](http://micro.ustc.edu.cn/Fortran/ZJDing/Sec5-2.htm)<br>
可用在倒格失的定义当中如qe的`FFTXlib/stick_base.f90`文件
```
ALLOCATE(array(lb:ub))
```
示例
```
ALLOCATE(b(-4:4))
DO i = -4,4
b(i) = i
ENDDO
WRITE(*,*) "b(-2:0)",b(-2:0)
```
输出
```
b(-2:0)          -2          -1           0
```

内存中的存储顺序为array(1,1,1)->array(2,1,1)->array(3,1,1)->array(1,2,1)<br>
所以`do r=1,n1 sum=sum+array(r,1,1) `比`do r=1,n1 sum=sum+array(1,1,r) `的语法就是最快的<br>
同理，不建议高维数组



#### 赋值

**`data`只能用来赋初值，已赋值后，调用无效**

**`data`的顺序**
```
  data((A(i,j),i=1,2),j=1,3) /1,2,3,4,5,6/
A=  
   1.00000000       3.00000000       5.00000000
   2.00000000       4.00000000       6.00000000
integer :: array(5),A(2,3)
!使用data赋值，后面的值要和前面的一一对应
array(1)=1
array(2:5)=3
data array /1,2,3,4,5/
data array /5*5/   !*表重复 /5,5,5,5,5/
data((A(i,j),i=1,2),j=1,3) /1,2,3,4,5,6/
！(f(I),i=1,5)就代表一组循环,i从1到5，输出f(i)，例如
A=(/(I*I,I=1,6)/)
```

#### 调用

```
!可直接进行调用或赋值
array(n,m)
array(n,:)
array(:)
A(:,:)
```

`array(:,n)`与`array(n,:)`都视为一行矩阵，可以互相赋值，即列和行可以互相赋值

#### 运算

`+-*/function()` 都是对应元素操作，不是数学矩阵操作

`> <`返回逻辑值，也是对应元素比较

**可以 `b=2*a`等价于`b(i)=2*a(i)`，加减乘除都行**

**也可以`a*b`不过是matlab中的点乘**

#### 数组查询
**维度查询**<br>
[2.1.15 数组查询函数](https://docs.oracle.com/cd/E19205-01/820-1202/aetke/index.html)
<br>[default return value of ubound and lbound](http://gcc.1065356.n8.nabble.com/default-return-value-of-ubound-and-lbound-td750059.html)

| 通用内函数名               | 说明             |
| -------------------------- | ---------------- |
| **ALLOCATED (ARRAY)**      | 数组分配状态     |
| **LBOUND (ARRAY [, DIM])** | 数组的维数下界,就是1   |
| **SHAPE (SOURCE)**         | 数组或标量的形式 |
| **SIZE (ARRAY [, DIM])**   | 数组中的元素总数 |
| **UBOUND (ARRAY [, DIM])** | 数组的维数上界   |

注意LBOUND和UBOUND默认返回的都是一维数组,即使是一个元素也是数组,不能赋值给整形变量<br>
可以按照下面的方式提取维度

```
INTEGER     :: a(N),bound(1),i
bound=UBOUND(a)
i=bound(1)
i=UBOUND(a,1)
```

**最大值,最小值,及其位置**<br>
具体参数，参考下面的manual<br>
[MAXLOC](https://gcc.gnu.org/onlinedocs/gfortran/MAXLOC.html#MAXLOC)<br>
[MAXVAL](https://gcc.gnu.org/onlinedocs/gfortran/MAXVAL.html)
```
WRITE(*,"(A,I1,A,I4)") "max is a(",MAXLOC(a),"), which is",MAXVAL(a)
WRITE(*,"(A,I1,A,I4)") "min is a(",MINLOC(a),"), which is",MINVAL(a)
```
**用`ANY`判断数组元素**<br>
[ANY](https://gcc.gnu.org/onlinedocs/gcc-6.1.0/gfortran/ANY.html)

```
RESULT = ANY(MASK [, DIM])
ANY( (/.true., .false., .true./) )
```

可以返回是否有成立值，应该不仅可以用来判断整数，逻辑数组都可以，如

```
IF( ANY( a .EQ. 0 ) ) WRITE(*,*) "At least one 0 in a"
IF( .NOT. ANY( a > 90 ) ) WRITE(*,*) "No one > 90 in a"
```

### 结构体 TYPE

#### 定义

结构体，type内只有变量<br>type内含有方法(函数)时，就是类了->面向对象编程了<br>

定义结构体类型

```fortran
TYPE ,形容词 :: 结构体名
变量表(声明语句)
END TYPE
```

将结构体实体化，也可实体化为数组

```
TYPE(结构体名) :: 变量名
```

示例

```
      type :: student
              character :: nickname,address
              integer :: num,score
      end type
    
      type(student) :: xiaoming
```

#### 调用

```
结构体名%成员名 ！优先使用
结构体名.成员名 !gfortran好像不支持
xiaoming%nickname
xiaoming.num
```

#### 赋值

```
TYPE(student)::xiaoming=student (“xiaoming","china",1,90), S2, S3
xiaoming.score=95
```

### 类

类是在结构体的基础上，面向对象的拓展

### 指针
- 指针`POINTER`属性
- 被指针指向的变量`TARGET属性`

指向变量`p1=>t1`,检查是否指向TARGET变量`ASSOCIATED(POINTER,[TARGET])`,示例
```
PROGRAM pointer_
IMPLICIT NONE
INTEGER,POINTER :: p1
INTEGER,TARGET :: i1,i2
!
NULLIFY(p1)
i1=1; i2=2
p1=>i1 ; WRITE(*,*) p1,ASSOCIATED(p1),ASSOCIATED(p1,i1),ASSOCIATED(p1,i2)
p1=>i1 ; WRITE(*,*) p1,ASSOCIATED(p1),ASSOCIATED(p1,i1),ASSOCIATED(p1,i2)
NULLIFY(p1) ; WRITE(*,*) p1,ASSOCIATED(p1),ASSOCIATED(p1,i1),ASSOCIATED(p1,i2)
END PROGRAM
```
运行
```
cndaqiang@girl:~/code/test$ gfortran point.f90 ; ./a.out 
           1 T T F
           1 T T F
           0 F F F
```
### 数据类型转换

```
!1，数字转字符
write(str1,"(i4.4)") num ! 如有需要，不足四位前面补零
print*,str1
!2，字符转数字
read(str1,"(i2)") num
print*,str1
```





## 流程控制 IF SELECT
### IF
单行版
```
IF(条件) 执行语句
```
多行版
```
IF (条件) THEN
执行语句
ELSE IF (条件) THEN
执行语句
ELSE IF (条件) THEN
执行语句
ELSE
执行语句
END IF
!ELSE IF与ELSE可不写
```

### SELECT
```
SELECT case (表达式)
case(A)
执行语句
case(B)
执行语句
END SELECT
!好像表达式结果只能为整数或字符串，A,B...也要对应
```

## 循环
###  CYCLE 进入下一循环
###  EXIT 结束循环
### DO
```
DO i=start,end [,step]
!步长step默认为1，可设置为正,负
！不写i=1,end 无穷循环
执行语句
END DO
```
**结束后i=end+1**

### DO WHILE()
```
DO WHILE(条件)
执行语句
END DO
```
### FORALL屏蔽赋值
[数组赋值与运算](http://micro.ustc.edu.cn/Fortran/ZJDing/Sec5-2.htm)<br>
>FORALL是F95的新增功能。它是数组屏蔽赋值（WHERE语句和构造）功能的一对一元素的推广，其方式有FORALL语句和FORALL构造。
><br>FORALL语句的一般形式为：`FORALL(循环三元下标[,循环三元下标]…[,屏蔽表达式]) 赋值语句`
><br>FORALL构造的一般形式为：
```
[构造名:] FORALL(循环三元下标[,循环三元下标]…[,屏蔽表达式])
[块]
END FORALL [构造名]
```
>屏蔽表达式是数组逻辑表达式，缺省值为.TRUE.。块是赋值语句，或为WHERE语句或构造，或为FORALL语句或构造。
><br>循环三元下标的形式为：循环变量=下界:上界[:步长]。循环变量是整型的。步长不能为0，缺省值为1。


示例
```fortran
PROGRAM forallT
INTEGER :: a(10),b(10)
INTEGER :: i
DO i=1,10
    a(i) = i
ENDDO
b=0
FORALL(i=1:10,a(i)>5) b(i)=6
WRITE(*,*) b
END PROGRAM
```
执行
```
cndaqiang@girl:~/code/test$ gfortran forall.f90 ; ./a.out 
           0           0           0           0           0
           6           6           6           6           6
```

## WHERE
可以找到数组中符合条件的项，然后操作另一数组中相同的项,如
```fortran
PROGRAM whereT
INTEGER :: a(10),b(10)
INTEGER :: i
DO i=1,10
    a(i) = i
ENDDO
b=0
WHERE(a>5)
    b=6
ELSEWHERE(a>3)
    b=4
ELSEWHERE
    b=1
ENDWHERE
WRITE(*,*) b
WHERE(a>5) a=0
WRITE(*,*) a
END PROGRAM
```
执行
```
cndaqiang@girl:~/code/test$ gfortran where.f90 ; ./a.out 
           1           1           1           4           4
           6           6           6           6           6
           1           2           3           4           5
           0           0           0           0           0
```




## 格式化输入输出

### READ(unit=设备号/字符串名称,fmt=格式或行号) 格式化输入
读取一行数据，且存到矩阵
```
     read(unit,*) ika, ((eig(ib,is), ib = 1, nband), is = 1, nspin)
                        #此处先进行ib循环，再进行is循环
```

### WRITE(unit=设备号/字符串名称,fmt=格式) 格式化输出

- 默认设备是键盘，用`5`或`*`表示,还可以是外部文件（open文件时指定设备号）
- 输入输出为字符串时，等价于将字符串视为文件，称为内部文件<br>实现整数/实数<=>字符串
- 格式适合一次控制，`"格式内容"`
- 行号可以在很多次输出都采用统一格式时，减少书写量
- `READ(设备号,格式行号)`也可以
- `READ(*,*)`  `*`分别表示默认键盘和不指定格式
- `READ(*,*) a,b,c` 一次读取多个数据赋值给a,b,c

### 格式化输出控制

| 格式       | 含义                                                         |
| ---------- | ------------------------------------------------------------ |
| `Iw[.m]`   | 以w个字符的宽度来输出整数[至少输出m个数]，宽度不够补空格，以下同理 |
| `Fw.d`     | 以w个字符文本框来输出浮点数，小数部分占d个字符宽，           |
| `Ew.d[Ee]` | 用科学计数法，以w个字符宽来输出浮点数，小数部分占d个字符宽，[指数部分最少输出e个数字] |
| `Dw.d`     | 使用方法同Ew.d，差别在于输出时用来代表指数的字母由E换成D     |
| `Aw`       | 以w个字符宽来输出字符串                                      |
| `nX`       | 输出位置向右移动n位。`write(*,"(5X,I3)") 100 `; 将先填5个空格，再输出整数。 |
| `Lw`       | 以w个字符宽来输出T或F的真假值。`write(*,"(L4)") .true. `;程序会输出3个空格和一个T |
| `/` 换行输出 | `write(*,"(I3//3)") 10,10` 程序会得出4行，中间两行空格是从除号`/`得到的。 |
| `Tc` | 把输出的位置移动到本行的第c个字节 |
| `TLn` | 输出位置向左相对移动n个字节。 |
| `TRn` | 输出位置向右相对移动n个字节。 |
| `SP、SS` | 加了SP后，输出数字时如数值为正则加上`+`，SS则是用来取消SP的功能。   如 `write(*,"(SP , I5 , I5 , SS , I5)") 5 , 5 , 5` 输出：`+5   +5   5` |

示例

```
     write(*,100) 5
100  format(I5)
     write(*,"(spi5/ssf10.2)") 34 , 23.456
```
结果
```
    5
  +34
     23.46
```

默认WRITE后会换行，**设置`advance="no"`取消换行**，如<br>
**注意:[ifort有bug](https://community.intel.com/t5/Intel-Fortran-Compiler/Writing-to-standard-output-with-advance-no/m-p/1145261/highlight/true?profile.language=zh-TW),还要再加上一个FLUSH,不然也会出现随机换行事件**
```
WRITE(funit,9035,advance="no") 
FLUSH(funit) #ifort要用这个确保不会换行
```
### `FMT=*` 读写
- `WRITE(unit,FMT=*) var`时, 会根据`var`的内容进行写,有些编译器(ifort)会写成多行,gfortran一般写成一行<br>
如果写到了第`n`行, 再次调用`WRITE`时, 从`n+1`行开始写
- `READ(unit,FMT=*) var`时, 会根据`var`的内容进行读, 如果当前行的数据不够, 会读取下面几行<br>
如果读到了第`n`行, 再次调用`READ`时,从`n+1`行开始读      

**针对这些特点, 我们读写的数据如果不是给人看的, 按照数组下标,或者直接将一个数组`WRITE(unit,FMT=*)`即可, 而且不同编译器之间都可以互相读写**<br>
给人看的时候才要考虑格式化输出


## 函数

- 函数与主程序program并列
- 主程序和函数无先后次序
- function 与subroutine除了返回值，和声明方式，没有区别
- 函数都是传址调用

### function

#### 定义

```
[形容词][,返回类型] function 名称([虚参列表])
	[虚参声明]
	[局部变量定义]
	执行语句
	名称=返回值
	[return]
End [function [名称]]
```

#### 使用

用前要声明

- `external`
- `interface`
- `contains`包含在程序单元内
- 用`module`引入

```
返回变量=名称([实参列表])
```
调用外部函数function,要在变量定义区指明，子程序subroutine不用
```
CHARACTER(len=6), EXTERNAL :: int_to_char
```
不然会
```
Error: Function ‘int_to_char’ at (1) has no IMPLICIT type
td_analysis.f90:90:89:

```

### subroutine

#### 定义
```
[形容词] subroutine 名称([虚参列表])
	[虚参声明][局部变量定义]
	执行语句
	名称=返回值
	[return]
End [subroutine [名称]]
```
#### 使用

直接`call`

```
call 名称([实参列表])
```

### 使用前的声明

使用function前用`external`声明，或使用`interface`声明

```
program externalOrinterface
      implicit none
      real :: x,y
      real ,external :: fun !函数要声明
      x=1.0
      y=fun(x)
      write(*,*) y
      call sub(x)
end program externalOrinterface

real function fun(x)
      real :: x
      fun=x*x+1.0
end function fun

subroutine sub(x)
        real :: x,y
        y=x*x+1.0
        write(*,*) y
end subroutine sub
```

#### interface

fun也可使用`interface` 代替`external`，有些特殊用法需要用interface声明

````
      interface 
             real function  fun(x)
                     real :: x
             end function fun
      end interface
````

使用以下用法时，必须使用 interface：

• 函数返回值是数组、指针

• 参数为假定形状数组

• 参数具有 intent、value 属性

• 参数有可选参数、改变参数顺序

以下用法时，虽然不强制要求，但也推荐使用 interface

• 函数名作为虚参和虚参

实际上，我们建议在任何函数调用时，都使用接口！ 


**每个程序单元调用其他函数时都要interface，用module可以减少书写那么多interface**


**interface同名函数重构**<br>
使用`interface `和`module procedure` 定义同名函数，会根据函数输入变量类型自动匹配
```
(python27) ~/code/TDQE/Fortran/module_interface $ cat main.f90 
program main
    use m_interface
    integer :: aa(5),bb(5)
    aa=1
    bb=2
    call my_sum(aa(1),bb(1))
    call my_sum(aa,bb)
end program(python27) ~/code/TDQE/Fortran/module_interface $ cat module.f90 
module m_interface
    interface my_sum
     module procedure my_sum_integer
     module procedure my_sum_array
    end interface
contains
    subroutine my_sum_integer(a,b)
        INTEGER :: a,b
        write(*,*) "my_sum_integer:",a+b
    end subroutine
    subroutine my_sum_array(a,b)
        INTEGER ::a(:),b(:)
        write(*,*) "my_sum_array",a+b
    end subroutine
end module
```
编译
```
mpif90 -c -g -O2 -ffree-line-length-none     module.f90
mpif90 -c -g -O2 -ffree-line-length-none     main.f90
mpif90  -g -O2 -ffree-line-length-none  -o interface  main.o module.o
./interface
 my_sum_integer:           3
 my_sum_array           3           3           3           3           3
```


#### contains

在程序单元(主程序，function，subroutine)内使用`contains`，contains后面跟的函数，仅可以被此程序单元调用，**且不用声明**

`module`内部的函数也用`contains`，`use module_name`后，可以调用

`contains`后面的函数可以直接调用程序单元和`module`里的变量

```
real function fun(x)
      implicit none
      real ::x,y
      y=23.0
      fun=x*3.0
      fun=two(fun)
contains      !使用contains
      real function two(x)
        real ::x
        two=x*2.0+y !可以直接调用程序单元或module里的变量
    end function two
end function fun 
```

#### module 内部函数互相调用不用声明

### 参数传递：在函数内解释参数

#### 传递字符串

**声明时`len=*`**，siesta得代码中常见

```
program strsub
      implicit none
      character(len=20)::str
      str="hello,world!"
      call sub(str)
      contains
              subroutine sub(strr)
                      implicit none
                      character(len=*) :: strr
                      write(*,*) trim(strr)
              end subroutine sub
end program strsub
```




#### 传递数组-数组地址维度大小都会传过来

推荐方式

```
program pro
      implicit none
      real :: array(10),total
      integer I
      array=(/(I,I=1,10)/)
      total=sum(array(2:3))
      write(*,*) total
end program pro

real  function sum(a)
     real::a(:)   !多维时a(:,:)，传入参数的下标变为1,2,3...,size(a,dim=n)，上限自动计算，下线也可指定
     !real::a(n)取出传过来的数组的前n个元素作为一个数组
     integer :: i
     sum=0
     do i=1,size(a,dim=1)
      sum=sum+a(i)
     end do
end function sum
```

也可以把数组维度作为参数传入

**也有用`real :: a(*)`，老程序中有，会将输入数组变为1维,适合于不同维度的矩阵运算**，如不同维度矩阵相加

```
module m_matradd
    implicit none
    contains
    subroutine matradd(m,n,A,B,C,lds)
    implicit none
    integer :: m,n,i,j,lds
    real:: A(*),B(*),C(*)

    !其实fortran直接 C=A+B 就可以
    !C(1:m*n)=A(1:m*n)+B(1:m*n)
    DO j=0,n-1
        DO i=1,m
            C(i+j*lds)=A(i+j*lds)+B(i+j*lds)
        end DO
    end DO
    end subroutine matradd
end module m_matrad
```



#### 传递结构体-用module

主程序和子程序需使用同一个结构体定义，使用module

**modele里面`include `mpif.h`后，调用该module的程序不用include了**
**module里面`inplicit none`后，对调用该module的程序无影响**

```
module typedef
      implicit none
      type :: student
              character(len=10) :: nickname
              integer :: num,score
      end type
end module typedef

program cndaqiang
      use typedef
!use module名 要在其他语句之前
      implicit none
      type(student)::xiaoming
      xiaoming%nickname="xiaoming"
      xiaoming%num=1
      xiaoming%score=95
      call sub(xiaoming)
end program

subroutine sub(who)
        use typedef
        implicit none
        type(student)::who
        write(*,*) who%nickname(:),who%num
end subroutine

```

#### 传递函数

在函数体内用`interface`声明传入参数的类型

```
module mod_fun
    !real :: x,y
contains
real function fun(test,x)
      implicit none
      interface !函数作为参数时，要用interface声明(解释)函数类型
      real function test(x)
      real ::x
      end function
      end interface
      real :: x
      fun=test(x)+x
end function fun      

real function test(x)
      implicit none
      real :: x
      test=x*x+x
end function test

end module mod_fun

program inter
    use mod_fun   !使用module导入的函数，不用声明
    implicit none
    real :: x,y
    x=3.0
    y=fun(test,x)
    write(*,*) y
end program inter
```



### 特殊用法

#### save属性

函数执行完后，空间不释放，下次执行该函数时作为初值

```
Integer , save :: var
Integer :: var = 0  !// 虽然没有书写 save ，但定义时初始化值，有具有 save 属性
```

#### 虚参的 Intent 属性（需要 Interface）

明确指定虚参的目的：输入参数、输出参数、中性参数

```
!//输入参数，在子程序内部不允许改变  
Integer , Intent( IN ) :: input_arg   
!//输出参数，子程序返回前必须改变（对应实参不能是常数，也不能是表达式）
Integer , Intent( OUT ) :: output_arg 
!//中性参数
Integer , Intent( INOUT ) :: neuter_arg
Integer :: neuter_arg !// 未指定 Intent 则为中性
请注意：Intent 的检查是在编译时进行，而非运行时检查
建议对每一个虚参都指定 Intent 属性！
```

#### 虚参的 value 属性（**需要 Interface**）
指定该参数为传值参数，而非传址参数。

```
!//传值参数，只能作为输入参数。改变后不影响实参。  
Integer , value :: by_value_arg

请注意：除混编之外，一般不使用 value 属性
```

#### 可选参数optional（**需要 Interface**）

虚参可传可不传

```
program op
      call opop(1)
      call opop()

contains
subroutine opop(a)
      integer,optional ::a   !a为可选参数
      if (present(a)) then
              write(*,*) "a=",a
      else
              write(*,*) "none"
      end if
end subroutine opop

end program op
```

#### 更改参数顺序（需要 Interface）

更改参数顺序：即，函数的实参、虚参可以不按照顺序对应。

```
call writeresult( Data = var , file = "res.txt" , size = 1000 ) 
call writeresult( var , 1000 , "res.txt") 
```

#### result 指定返回值变量

````
real function jifen(fun,down,up,step) result(y)
````

函数体内不能再次声明y(已经在定义时生命力)



#### pure 并行有关，暂略



## 数据共享

### 函数的传址调用

### common-不推荐-略

在程序单元内，用`common 变量列表`

变量名不必一致，按顺序排列

就是划了一块公共的内存区域，不同的程序单元内按顺序读取

### module 见下

## module：数据/函数(过程)共享

- module 中可以定义若干变量、若干函数
- 子程序可以使用module内的变量，子程序内部局部变量互相隔离
- module内部程序可以互相调用，不用interface
- 所有 use 了这个 module 的程序单元，可以自由使用 public 的变量和函数、只读的使用 protected 的变量<br>private 的变量和函数，仅供 module 内部使用
- **先将module所在的文件，编译成对象文件`xxx.o`和模块描述文件`模块名.mod`，在将对象`xxx.o`和主程序连接**

### 定义

**`module`内部不能有执行语句**，初值可在定义时赋予

```
module 名称
implicit none
变量声明
!不能写任何执行语句
contains
函数定义
end module 名称
```

### 使用

```
use module名称
!也可以使用module了内的某些，如下
use smartHome, only : tv , pc
!ONLY:使用名=>module中的名字
use smartHome, only : screen => tv , b ！使用并重命名
```

**module内也可以use其他module，实现继承**



### 权限形容词，在`contains`前写

|           | 变量                    | 子程序          |
| --------- | ----------------------- | --------------- |
| public    | 外部可以读取   可以修改 | 外部可以   调用 |
| protected | 外部只能读取   不能修改 | --              |
| private   | 外部无法访问            | 外部无法调用    |

默认全是`public`，更改默认为`Private`，在`implict none`和声明语句之间加一行`Private`默认全私有，**警告：全局private时，子程序要使用public声明才能被调用，如下**

例

```
module m_init
      private
      public :: init1,init2
      contains
              subroutine init1()
                      write(*,*) "init1 begin"
              end subroutine init1
              subroutine init2()
                      write(*,*) "init2 gegin"
              end subroutine init2
end module m_init
```





## 文件读写

- Open  打开文件
- Write  写入
- Read  读取
- Close  关闭文件

### open(通道号,file="文件名")

```
Open( 子句 = 值 , 子句 = 值 , 子句 = 值 )
！它有二十多个子句，每一个都有各自的作用
!真正有必要的，只有两个：
Open( Unit = 通道号 , File = "文件名" )
Open( 通道号 , File = "文件名" )
!文件通道号，由程序员给定，一般用大于10的数字。
!10以下的数字由不同编译器预留（一些编译器用5，6表示标准输入输出）
!在 OPEN 语句中指定 STATUS=’SCRATCH’ 会打开一个名称形式为 tmp.FAAAxnnnnn 的文件，其中 nnnnn 用当前进程 ID 替换，AAA 是一个包含三个字符的字符串，x 是一个字母；AAA 和 x 可确保文件名唯一
!该文件在程序终止或执行 CLOSE 语句时被删除,如
open (is1,               form='formatted',status='scratch')

```

### read

```
read(通道号,格式) 变量列表
read(字符串,格式) 变量列表 ！可将一行数据用字符纯的方式读入后，在处理字符串内的数据
```



|          | 文本文件   （有格式文件）                | 二进制文件   （无格式文件）                                |
| -------- | ---------------------------------------- | ---------------------------------------------------------- |
| 顺序读取 | **顺序读取有格式文件   （用得最多）   ** | 顺序读取无格式文件   (在记录前后各增加4字节，表示记录长度) |
| 直接读取 | 直接读取有格式文件   （要求每行一样长）  | **直接读取无格式文件   （用得较多）**                      |
| 直接读取 | 直接读取有格式文件   （要求每行一样长）  | 直接读取无格式文件   （用得较多）                          |



#### 顺序读写有格式文件（文本文件）

 **星号，表示表控格式（list-direct），既让变量列表自动控制格式，空格和逗号分隔数据**

也可以使用其他格式，多用`*`

如果不特殊指定格式，那么每个read 语句读取整的 N 行，即读取了3行中间，下次直接从第四行开始读

**推荐：一次只读取一行**，

不写参量列表，也会读取，可用于跳过一行

赋给无用变量，可用于跳过某一列

**可以读到字符串型中，再从字符串中读取**

如,file.txt

```
11 12 13
21 22 23
31 32 33
```

程序

```
program re
      implicit none
      real :: a,b,c,d,e,f
      integer :: i
      i=20
      open(i,file="file.txt")
      read(i,*) a,b,c,d !读到了1行多（即，第二行）
      read(i,*) e,f     !下一次从第三行读取
      write(*,*) a,b,c,d
      write(*,*) e,f
      close(i)
end program re      
```

结果

```
   11.0000000       12.0000000       13.0000000       21.0000000
   31.0000000       32.0000000
```

#### 直接读写有格式文件（文本文件）

**需固定长度**

```
open(unit=通道号,form="formatted"，access="Direct",RecL=64)	
```

- form="formatted"：指定它是有格式文件（文本文件）<br>  在顺序读取时，它是默认值，因此可以不指定

- access="Direct"：指定它是直接读取方式<br>顺序读取时，可以指定'SEQUENTIAL'，它是默认值，因此可以不指定

- RecL=64：指定记录长度（Record Length）是 64（字节）<br> 仅在直接读取时指定。



#### 顺序读写无格式文件（二进制文件）

```
      open(unit=i,file="file.bin",form="unformatted")
      write(i) a,str 
```

**因为是无格式，read和write里面只有unit，没有格式控制**

Fortran顺序写入无格式文件，以记录为基本单元，读写过程分若干笔记录：

每次一笔记录，在记录前后各多出4个字节，用来记录本次写入的长度。

顺序读取时，通过这4个字节知悉当前记录的长度，按照长度读取数据，再与最后的4个字节进行校对

示例
```
program re
      implicit none
      integer :: a,b,i
      character(len=5) :: str
      a=1
      b=2
      str="hello"
      i=20
      open(unit=i,file="file.bin",form="unformatted")
      write(i) a,str !4+5=9个数据
      write(i) b
      close(i)
      a=0
      b=0
      str="00000"
      open(unit=i,file="file.bin",form="unformatted")
      read(i) a,str  !读的时候，也要按相应数据长度
      read(i) b
      close(i)
      write(*,*) a,str,b
end program re

```

对应的二进制文件

![](/uploads/2019/01/file.jpg)

并行读写示例(用来读写波函数)
[parallel.read.write.f90.tar.gz](/web/file/2020/parallel.read.write.f90.tar.gz)

#### 直接读写无格式文件（二进制文件）

```
      open(unit=i,file="file.bin",form="unformatted",access="direct",recl=10)
      write(i,rec=1) a,str
```

- `recl`指定数据记录长度
- 随便跳转到任何整记录读写，也可以一边读一边写
- 写入记录不够时，会用0填满后面的（即使之前里面非空）
- 读取时，不一定按照写入时候的顺序，一个数据长度，爱咋读咋读


![](/uploads/2019/01/file2.jpg)

#### 流文件读写无格式文件（二进制文件）

**按照给定参数，决定读取长度**

```
open(unit=i,file="file.bin",form="unformatted",access="stream")
write(i) a,str
      
read(i,pos=5) !跳到第5个字节处开始读
inquire(i,pos=b)  !将当前位置返回到b
```

![](/uploads/2019/01/file3.jpg)

也可用于读入顺序读写的文件，无非就是在变量列表两边各添加一个n(4字节变量/整型)

#### 内部文件

就是直接读取字符串文件，把字符串当成有格式文件的一行，一次写入就写满一行，不足数据用空格补全

同样也可以读，实现字符串和数值的互转

结合字符串，格式化读写的相关操作

**可用于先将用户输入数据读入字符串，在判断字符串里的内容是否符合规则：整/实数，避免输入不符造成程序终止**

示例

```
program str
      implicit none
      integer::filenum(5)
      integer::i,uid
      character(len=10) :: filename
      data filenum /1,12,123,1234,12345/
      uid=20
      do i=1,5
      write(filename,"(i6.5a4)") filenum(i),".txt" !把str当成文件来读写
      open(uid,file=filename)
      write(uid,*) filenum(i)
      close(uid)
      end do
end program str
```

生成

```
' 00001.txt'  ' 00012.txt'  ' 00123.txt'  ' 01234.txt'  ' 12345.txt'
```

示例

```
program now1
      implicit none
      character(len=255)  :: now,r
      integer::hh,mm,ss
      call date_and_time(time=now)   !获取系统时间函数
      read(now,"(i2i2i2)") hh,mm,ss
      write(*,"(a8,i2,a1,i2,a1,i2)") "now is: ",hh,":",mm,":",ss
end program now1
```

结果

```
now is: 11:52:26
```

#### read读写错误/结束时操作
**Fortran的一行定义为: 有字母数字的意义行**
<br>多行的空白,逗号等会被忽略，不算行，会被跳过,不算读取位置
<br>如果两行之间有很多回车空白，Fortran会直接跳过这些内容进行读取
<br>Fortran中的结束行定义为:没有内容,或后面只有空格回车等无意义内容
<br>**若读到end,就肯定没有读到任何数据**

读取文件，自动判断结尾或读取错误之后的数组赋值为0,示例：<br>
可用于从文件中读取电场
```
PROGRAM readdata
IMPLICIT NONE
INTEGER,PARAMETER   :: N=5
INTEGER     :: a(N)
a=100
CALL readarray(a,N,"data")
WRITE(*,*) "a:",a

CONTAINS
    SUBROUTINE readarray(a,N_,file)
    IMPLICIT NONE
    INTEGER :: N_,a(N_)
    CHARACTER(*)  :: file
    !Local
    INTEGER :: unit_io=666,N,i
    N=MIN(N_,UBOUND(a,1))

    OPEN(unit=unit_io,file=TRIM(file))
    DO i=1,N
    READ(unit_io,*,ERR=10,END=20) a(i)
    goto 30
    !读取错误执行goto 10
    !读取结束goto 20
    !正常读取goto 30,在此处直接写CYCLE也可以
    !结束行是没有内容的
    !Fortran的一行定义为: 有字母数字的意义行
    !多行的空白,逗号等会被忽略，不算行，不算读取位置
    !即　如果两行之间有很多回车空白，Fortran会直接跳过这些内容进行读取
    !即　Fortran中的结束行定义为:没有内容,或后面只有空格回车等无意义内容
    !即　若读到end, 就肯定没有读到任何数据,a(i)不会被改变
    10 WRITE(*,*) "ERR at:",i,"line" 
    goto 25
    20 WRITE(*,*) "END at:",i,"line" 
25    a(i:N)=0
    EXIT

    30 CYCLE
    ENDDO
    END SUBROUTINE readarray
END PROGRAM
```
运行
```
cndaqiang@girl:~/code/test$ cat data ; echo "+++"; gfortran read.f90 ; ./a.out 
1
2
  

5

+++
 END at:           4 line
 a:           1           2           5           0           0
```


#### 禁止标准输出/或者重定向标准输出到制定文件
默认
标准输出： 屏幕/控制台  /dev/fd/1
标准错误输出： 屏幕/控制台  /dev/fd/1
标准输入： /dev/fd/0

禁止输出，如fortran中将stdout指向/dev/null
```
./environment.f90:116:          OPEN ( unit = stdout, file='/dev/null', status='unknown' )
```
改变输出
```
         stdout_file = cla_get_output()
         if ( stdout_file /= ' ' ) then
            close(unit=6)
            open(unit=6,file=trim(stdout_file),form="formatted",
     &           position="rewind", action="write",status="unknown")
         end if
```

### 利用NAMELIST复制变量
参考自[quantum-espresso](https://www.quantum-espresso.org/)<br>
**注意输入文件的NAMELIST最后要有一个空行，!开头的行也行，不然会报错**
```
(python27) ~/code/TDQE/Fortran $ cat namelist.f90 
program namelist
INTEGER	:: a,b,c
NAMELIST  /NAME/ a,b
NAMELIST  /YES/ c
a=0
b=0
c=0
READ(*,NAME)
READ(*,YES)
write(*,*) a,b,c
END program namelist
(python27) ~/code/TDQE/Fortran $ cat data 
&NAME
	a=10
	b=9
/
&YES
	c=1
/
#注意输入文件最后要有一个空行，!开头的行也行，不然会报错
(python27) ~/code/TDQE/Fortran $ gfortran namelist.f90 
(python27) ~/code/TDQE/Fortran $ ./a.out < data 
          10           9           1
```

### BACKSPCE 回到上一行/位置<br>ENDFILE 删除下面所有行
[fortran文件操作之'append'; 'backspace'; 'endfile';](https://blog.csdn.net/chd_lkl/article/details/84891616)<br>
代码
```
PROGRAM file
IMPLICIT NONE
INTEGER :: i,unit_io
unit_io=666
OPEN(unit=unit_io,file="data")
!读入当前行,并把位置下移一行
READ(unit_io,*) i
WRITE(*,*) i
!回到上一行
BACKSPACE(unit_io)
!
READ(unit_io,*) i
WRITE(*,*) i

ENDFILE(unit_io) !清除当前位置到最后的所有行,此处为>2行的所有数据
CLOSE(unit_io)

END PROGRAM
```
执行,可以看到BACKSPACE的回退,和ENDFILE的删除操作
```
cndaqiang@girl:~/code/test$ cat data ; echo "++++" ; gfortran file.f90 ; ./a.out ;echo "---"; cat data 
1
2
3
4
++++
           1
           1
---
1
2
```











## 有趣的命令

### 调用系统shell命令

[9.264 `SYSTEM` — Execute a shell command](https://gcc.gnu.org/onlinedocs/gfortran/SYSTEM.html)

```
system("command"[,]状态)
```

command为字符型变量，状态为整形，执行正常，状态变量被赋予0

执行后，命令结果被输出到屏幕

例

```
call system("date",hh)
```



### 时间命令

[9.82 `DATE_AND_TIME` — Date and time subroutine](https://gcc.gnu.org/onlinedocs/gfortran/DATE_005fAND_005fTIME.html)

`DATE_AND_TIME(DATE, TIME, ZONE, VALUES)` gets the corresponding date and time information from the real-time system clock. 

- DATE is`INTENT(OUT)` and has form ccyymmdd.
-  TIME is `INTENT(OUT)` and has form hhmmss.sss. 
- ZONE is `INTENT(OUT)` and has form (+-)hhmm, representing the difference with respect to Coordinated Universal Time (UTC). 
- VALUE 参考上面给的参考链接，此处略

程序计时示例
```
    INTEGER :: starttime,endtime
    call SYSTEM_CLOCK(starttime)
    代码部分
    call SYSTEM_CLOCK(endtime)
    walltime=(endtime-starttime)/1000
```

其他时间[CPU_TIME](https://gcc.gnu.org/onlinedocs/gfortran/CPU_005fTIME.html#CPU_005fTIME)与[SYSTEM_CLOCK](https://gcc.gnu.org/onlinedocs/gfortran/SYSTEM_005fCLOCK.html#SYSTEM_005fCLOCK)

### 暂停一段时间再执行

```
call sleep(n) !暂停n秒
```
### 读入命令行参数

```
在Fortran中主函数是没有参数的，所以要获取命令行参数需要额外调用其他的函数。
agrc=iargc()：
返回命令行参数的个数

call getarg(i,buffer)：
读取命令行的第i个参数，并将其存储到buffer中，其中命令本身是第0个参数

对于Fortran2003及其之后，使用GET_COMMAND_ARGUMENT来获取参数
```

### 更改默认的标准输出位置
使得只有Ionode输出
```
OPEN ( unit = stdout, file='/dev/null', status='unknown' )
```

### get_environment_variable读取系统/shell的环境变量
[Fortran get_environment_variable intrinsic returns nothing](https://stackoverflow.com/questions/10075225/fortran-get-environment-variable-intrinsic-returns-nothing)<br>
示例
```
program main
  implicit none
  character(len=10) :: time

  call get_environment_variable("t", time)
  write(6,*) time
end program main
```
在shell中设置
```
export t=2010010100
```

### Fortran内置函数

通用内函数名 | 说明
-- | --
ABS (A) | 绝对值
AIMAG (Z) | 复数的虚部
AINT (A [, KIND]) | 整数截尾
ANINT (A [, KIND]) | 最近的整数
CEILING (A [, KIND]) | 大于或等于数值的最小整数
CMPLX (X [, Y, KIND]) | 转换为复数类型
CONJG (Z) | 共轭复数
DBLE (A) | 转换为双精度实数类型
DIM (X, Y) | 正偏差
DPROD (X, Y) | 双精度实数乘积
FLOOR (A [, KIND]) | 小于或等于数值的最大整数
INT (A [, KIND]) | 转换为整数类型
MAX (A1, A2 [, A3,...]) | 最大值
MIN (A1, A2 [, A3,...]) | 最小值
MOD (A, P) | 余数函数
MODULO (A, P) | 模数函数
NINT (A [, KIND]) | 最近的整数
REAL (A [, KIND]) | 转换为实数类型
SIGN (A, B) | 符号传输,i.e. ABS(A)*sign(B)<br>注意A,B的类型要一致<br>`sign(-10.0,1.0)==10.0; sign(10,-1)==-10`

\n
\n
------
本文首发于[我的博客@cndaqiang](https://cndaqiang.github.io/).<br>
允许注明来源转发.<br>
强烈谴责大专栏等肆意转发全网技术博客不注明来源,还请求打赏的无耻行为.
