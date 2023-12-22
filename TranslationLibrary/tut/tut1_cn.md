{==+==}
=====================
Nim Tutorial (Part I)
=====================
{==+==}
==============================
Nim 教程 (第 I 部分)
==============================
{==+==}

{==+==}
:Author: Andreas Rumpf
:Version: |nimversion|
{==+==}
:Author: Andreas Rumpf
:Version: |nimversion|
{==+==}

{==+==}
.. default-role:: code
.. include:: rstcommon.rst
.. contents::
{==+==}
.. default-role:: code
.. include:: rstcommon.rst
.. contents::
{==+==}

{==+==}
Introduction
============
{==+==}
引言
============
{==+==}

{==+==}
>  "Der Mensch ist doch ein Augentier -- Schöne Dinge wünsch' ich mir."
{==+==}
>  "Der Mensch ist doch ein Augentier -- Schöne Dinge wünsch' ich mir."
{==+==}


{==+==}
This document is a tutorial for the programming language *Nim*.
{==+==}
本文是 *Nim* 编程语言教程。
{==+==}

{==+==}
This tutorial assumes that you are familiar with basic programming concepts
like variables, types, or statements.
{==+==}
本教程假定你熟悉基本的编程概念，如变量、类型及语句。
{==+==}

{==+==}
Here are several other resources for learning Nim:
{==+==}
此处还提供有其他几份资料，以学习 Nim:
{==+==}

{==+==}
* [Nim Basics tutorial](https://narimiran.github.io/nim-basics/) - a gentle 
  introduction of the concepts mentioned above
* [Learn Nim in 5 minutes](https://learnxinyminutes.com/docs/nim/) - quick,
  five-minute introduction to Nim
* [The Nim manual](manual.html) - many more examples of the advanced language features
{==+==}
* [Nim 基础教程](https://narimiran.github.io/nim-basics/) - 对其本概念的简单介绍
* [五分钟速通 Nim](https://learnxinyminutes.com/docs/nim/) - 用“五分钟”介绍快速介绍 Nim
* [Nim 手册](manual.html) - 可查阅语言全面的特性
{==+==}

{==+==}
All code examples in this tutorial, as well as the ones found in the rest of
Nim's documentation, follow the [Nim style guide](nep1.html).
{==+==}
此教程中的所有代码样例，包括在其余 Nim 文档中的，均遵循[Nim 代码风格指南](nep1.html)。
{==+==}


{==+==}
The first program
=================
{==+==}
第一个程序
=================
{==+==}

{==+==}
We start the tour with a modified "hello world" program:
{==+==}
通过 "hello world" 程序开启旅途。
{==+==}

{==+==}
  ```Nim  test = "nim c $1"
  # This is a comment
  echo "What's your name? "
  var name: string = readLine(stdin)
  echo "Hi, ", name, "!"
  ```
{==+==}
  ```Nim  test = "nim c $1"
  # 这是一条注释
  echo "What's your name? "
  var name: string = readLine(stdin)
  echo "Hi, ", name, "!"
  ```
{==+==}


{==+==}
Save this code to the file "greetings.nim". Now compile and run it::

  nim compile --run greetings.nim
{==+==}
将代码保存在文件 "greetings.nim" 中。现在编译运行它::

  nim compile --run greetings.nim
{==+==}

{==+==}
With the ``--run`` [switch](nimc.html#compiler-usage-commandminusline-switches) Nim
executes the file automatically after compilation. You can give your program
command-line arguments by appending them after the filename::
{==+==}
通过 ``--run`` [开关](nimc.html#compiler-usage-commandminusline-switches)，Nim 
将在编译完成后自动执行该文件。你可以使用在文件名后面追加其他内容的方式来为程序提供命令行参数::
{==+==}

{==+==}
  nim compile --run greetings.nim arg1 arg2
{==+==}
  nim compile --run greetings.nim arg1 arg2
{==+==}

{==+==}
Commonly used commands and switches have abbreviations, so you can also use::
{==+==}
常用的指令和开关有简写，因此你也可以用::
{==+==}

{==+==}
  nim c -r greetings.nim
{==+==}
  nim c -r greetings.nim
{==+==}

{==+==}
This is a **debug version**.
To compile a release version use::
{==+==}
这是 **调试版本**。
用以下命令编译为发行版::
{==+==}

{==+==}
  nim c -d:release greetings.nim
{==+==}
  nim c -d:release greetings.nim
{==+==}

{==+==}
By default, the Nim compiler generates a large number of runtime checks
aiming for your debugging pleasure. With ``-d:release`` some checks are
[turned off and optimizations are turned on](
nimc.html#compiler-usage-compileminustime-symbols).
{==+==}
默认情况下，为方便你进行调试，Nim 编译器会进行大量的运行时检查。
通过使用 ``-d:release``，会关闭一些检查，[并打开优化](
nimc.html#compiler-usage-compileminustime-symbols)。
{==+==}

{==+==}
For benchmarking or production code, use the ``-d:release`` switch.
For comparing the performance with unsafe languages like C, use the ``-d:danger`` switch
in order to get meaningful, comparable results. Otherwise, Nim might be handicapped
by checks that are **not even available** for C.
{==+==}
为了进行基准测试或生成可用于生产环境的代码，请使用 ``-d:release`` 开关。
为了与像 C 等不安全的语言进行性能上的比较，请使用 ``-d:danger`` 开关，以获得有意义且可比较的结果。
否则，Nim 可能会因一些甚至在 C 中 **不可行的检查** 而显得低效。
{==+==}

{==+==}
Though it should be pretty obvious what the program does, I will explain the
syntax: statements which are not indented are executed when the program
starts. Indentation is Nim's way of grouping statements. Indentation is
done with spaces only, tabulators are not allowed.
{==+==}
尽管程序的行为十分明显，但还是有必要解释这种语法: 
程序将首先执行没有缩进的语句。
缩进是 Nim 用于分隔语句的一种方式。
缩进只能为空格符，而不能是制表符。
{==+==}

{==+==}
String literals are enclosed in double-quotes. The `var` statement declares
a new variable named `name` of type `string` with the value that is
returned by the [readLine](syncio.html#readLine,File) procedure. Since the
compiler knows that [readLine](syncio.html#readLine,File) returns a string,
you can leave out the type in the declaration (this is called `local type
inference`:idx:). So this will work too:
{==+==}
字符串字面量会被双引号括起来。`var` 语句声明了一个名为 `name` 类型为 `string` 的变量，
值为 [readLine](syncio.html#readLine,File) 过程的返回值。
由于编译器知晓[readLine](syncio.html#readLine,File)返回一个字符串，所以可以在声明中省略类型
(这被称作局部类型推断 `local type inference`:idx:) :
{==+==}

{==+==}
  ```Nim  test = "nim c $1"
  var name = readLine(stdin)
  ```
{==+==}
  ```Nim  test = "nim c $1"
  var name = readLine(stdin)
  ```
{==+==}

{==+==}
Note that this is basically the only form of type inference that exists in
Nim: it is a good compromise between brevity and readability.
{==+==}
注意：这基本上是 Nim 中唯一存在的类型推断的形式，是简洁性和可读性之间的折中。
{==+==}

{==+==}
The "hello world" program contains several identifiers that are already known
to the compiler: `echo`, [readLine](syncio.html#readLine,File), etc.
These built-ins are declared in the [system](system.html) module which is implicitly
imported by any other module.
{==+==}
"hello world" 程序包含一些编译器已知的标识符: `echo`, [readLine](syncio.html#readLine,File) 等。
这些内置的标识符被声明在 [system](system.html) 模快中，会被所有模块隐式导入。
{==+==}


{==+==}
Lexical elements
================
{==+==}
词法元素
=================
{==+==}

{==+==}
Let us look at Nim's lexical elements in more detail: like other
programming languages Nim consists of (string) literals, identifiers,
keywords, comments, operators, and other punctuation marks.
{==+==}
下面来详细了解 Nim 的词法元素:
像其他编程语言一样, Nim 的词法元素由字(字符串)、标识符、关键字、注释、运算符、其他标点符号组成。
{==+==}


{==+==}
String and character literals
-----------------------------
{==+==}
字符串和字符字面量
---------------------------------------
{==+==}

{==+==}
String literals are enclosed in double-quotes; character literals in single
quotes. Special characters are escaped with ``\``: ``\n`` means newline, ``\t``
means tabulator, etc. There are also *raw* string literals:
{==+==}
字符串字面量用双引号括起来，而字符则用单引号。特殊字符可被 ``\`` 转义: 
``\n`` 表示新的一行, ``\t`` 为制表符，等等。也有 *原始* 字符串字面量 :
{==+==}

{==+==}
  ```Nim
  r"C:\program files\nim"
  ```
{==+==}
  ```Nim
  r"C:\program files\nim"
  ```
{==+==}

{==+==}
In raw literals, the backslash is not an escape character.
{==+==}
在原始字面量中，反斜杠不再表示转义字符。
{==+==}

{==+==}
The third and last way to write string literals is *long-string literals*.
They are written with three quotes: `""" ... """`; they can span over
multiple lines and the ``\`` is not an escape character either. They are very
useful for embedding HTML code templates for example.
{==+==}
第三种，也是最后一种书写字符串字面量的方法是通过 *长字符串字面量* ，
通过三对双引号来标记: `""" ... """`，可跨越多行且 ``\`` 也不再表示转义字符。
在实践中，比如，在嵌入 HTML 代码时会非常有用。
{==+==}


{==+==}
Comments
--------
{==+==}
注释
--------
{==+==}

{==+==}
Comments start anywhere outside a string or character literal with the
hash character `#`. Documentation comments start with `##`:
{==+==}
注释以哈希字符 `#` 开头，能够出现在除字符串或字符字面量以外的任何地方。
文档注释以 `##` 开头:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  # A comment.

  var myVariable: int ## a documentation comment
  ```
{==+==}
  ```nim  test = "nim c $1"
  # 这是一条注释

  var myVariable: int ## 这是一条文档注释
  ```
{==+==}


{==+==}
Documentation comments are tokens; they are only allowed at certain places in
the input file as they belong to the syntax tree! This feature enables simpler
documentation generators.
{==+==}
文档注释是 Token ，属于语法树，因此只能出现在源文本的特定位置!
这一特性使文档生成器的实现变得简单。
{==+==}

{==+==}
Multiline comments are started with `#[` and terminated with `]#`.  Multiline
comments can also be nested.
{==+==}
多行注释以 `#[` 开头并以 `#]` 结尾。多行注释允许嵌套。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  #[
  You can have any Nim code text commented
  out inside this with no indentation restrictions.
        yes("May I ask a pointless question?")
    #[
       Note: these can be nested!!
    ]#
  ]#
  ```
{==+==}
  ```nim  test = "nim c $1"
  #[
    注释中忽略缩进限制
        yes("May I ask a pointless question?")
    #[
       注意: 此处可以嵌套!!
    ]#
  ]#
  ```
{==+==}


{==+==}
Numbers
-------
{==+==}
数字
--------
{==+==}

{==+==}
Numerical literals are written as in most other languages. As a special twist,
underscores are allowed for better readability: `1_000_000` (one million).
A number that contains a dot (or 'e' or 'E') is a floating-point literal:
`1.0e9` (one billion). Hexadecimal literals are prefixed with `0x`,
binary literals with `0b` and octal literals with `0o`. A leading zero
alone does not produce an octal.
{==+==}
数字字面量的书写和其他大多数语言一样。有所不同的是特，可用下划线分隔，以提高可读性，如: `1_000_000` (一百万) 。
包含小数点的数 (或 'e' 或 'E') 是浮点数字面量，如: `1.0e9` (一亿) 。
十六进制数的字面量以 `0x` 开头，二进制数的字面量以 `0b` 开头，
而八进制数字面量以 `0o` 开头。仅以零开头不会作为八进制数。
{==+==}


{==+==}
The var statement
=================
The var statement declares a new local or global variable:
{==+==}
var 语句
=================
var 语句声明新的局部或全局变量:
{==+==}

{==+==}
  ```nim
  var x, y: int # declares x and y to have the type `int`
  ```
{==+==}
  ```nim
  var x, y: int # 声明 `int` 类型的 x 和 y
  ```
{==+==}

{==+==}
Indentation can be used after the `var` keyword to list a whole section of
variables:
{==+==}
可在关键字 `var` 后用缩进来声明多个变量:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var
    x, y: int
    # a comment can occur here too
    a, b, c: string
  ```
{==+==}
  ```nim  test = "nim c $1"
  var
    x, y: int
    # 这里也可用注释
    a, b, c: string
  ```
{==+==}


{==+==}
Constants
=========
{==+==}
常量
=========
{==+==}

{==+==}
Constants are symbols which are bound to a value. The constant's value
cannot change. The compiler must be able to evaluate the expression in a
constant declaration at compile time:
{==+==}
常量是绑定了值的符号。常量的值不能改变。编译器必须能够在编译时计算常量表达式的值:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  const x = "abc" # the constant x contains the string "abc"
  ```
{==+==}
  ```nim  test = "nim c $1"
  const x = "abc" # 常量 x 包含了一个字符串 "abc"
  ```
{==+==}

{==+==}
Indentation can be used after the `const` keyword to list a whole section of
constants:
{==+==}
可以在关键字 `const` 后用缩进定义多个常量:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  const
    x = 1
    # a comment can occur here too
    y = 2
    z = y + 5 # computations are possible
  ```
{==+==}
  ```nim  test = "nim c $1"
  const
    x = 1
    # 这里可以使用注释
    y = 2
    z = y + 5 # 可使用表达式计算
  ```
{==+==}


{==+==}
The let statement
=================
The `let` statement works like the `var` statement but the declared
symbols are *single assignment* variables: After the initialization their
value cannot change:
{==+==}
let 语句
======================
`let` 语句和 `var` 语句都用来声明变量，但其 let 声明符号定义 *一次性赋值* 的变量:
一经初始化后，其值再不能改变:
{==+==}

{==+==}
  ```nim
  let x = "abc" # introduces a new variable `x` and binds a value to it
  x = "xyz"     # Illegal: assignment to `x`
  ```
{==+==}
  ```nim
  let x = "abc" # 声明新变量 `x` 并绑定值
  x = "xyz"     # 非法: 不可对 `x` 再赋值
  ```
{==+==}

{==+==}
The difference between `let` and `const` is: `let` introduces a variable
that can not be re-assigned, `const` means "enforce compile time evaluation
and put it into a data section":
{==+==}
`let` 和 `const` 之间的差异是: `let` 声明了一个不能被重新赋值的变量，
`const` 意味着 "强制编译时评估变量并将其放到数据段" :
{==+==}

{==+==}
  ```nim
  const input = readLine(stdin) # Error: constant expression expected
  ```
{==+==}
  ```nim
  const input = readLine(stdin) # 错误: 尝试给常量赋值
  ```
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  let input = readLine(stdin)   # works
  ```
{==+==}
  ```nim  test = "nim c $1"
  let input = readLine(stdin)   # 成功
  ```
{==+==}


{==+==}
The assignment statement
========================
{==+==}
赋值语句
========================
{==+==}

{==+==}
The assignment statement assigns a new value to a variable or more generally
to a storage location:
{==+==}
赋值语句会将一个的新值赋给变量，更常规来说，指变量赋值到一个新的内存地址:
{==+==}

{==+==}
  ```nim
  var x = "abc" # introduces a new variable `x` and assigns a value to it
  x = "xyz"     # assigns a new value to `x`
  ```
{==+==}
  ```nim
  var x = "abc" # 声明新变量 `x` 并为其绑定值
  x = "xyz"     # 给 `x` 赋一个新值
  ```
{==+==}

{==+==}
`=` is the *assignment operator*. The assignment operator can be
overloaded. You can declare multiple variables with a single assignment
statement and all the variables will have the same value:
{==+==}
`=` 是 *赋值运算符* 。赋值运算符是可被重载。
声明时，可以通过单个赋值运算符给多个变量赋值，则所有变量将拥有相同的值。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var x, y = 3  # assigns 3 to the variables `x` and `y`
  echo "x ", x  # outputs "x 3"
  echo "y ", y  # outputs "y 3"
  x = 42        # changes `x` to 42 without changing `y`
  echo "x ", x  # outputs "x 42"
  echo "y ", y  # outputs "y 3"
  ```
{==+==}
  ```nim  test = "nim c $1"
  var x, y = 3  # 将 3 赋给变量 `x` 和 `y`
  echo "x ", x  # 输出 "x 3"
  echo "y ", y  # 输出 "y 3"
  x = 42        # 将 `x` 改为 42, 不改变 `y`
  echo "x ", x  # 输出 "x 42"
  echo "y ", y  # 输出 "y 3"
  ```
{==+==}


{==+==}
Control flow statements
=======================
{==+==}
控制流语句
=======================
{==+==}

{==+==}
The greetings program consists of 3 statements that are executed sequentially.
Only the most primitive programs can get away with that: branching and looping
are needed too.
{==+==}
程序通常由依次执行的语句组成，但也需要分支与循环。
{==+==}


{==+==}
If statement
------------
{==+==}
If 语句
-----------------
{==+==}

{==+==}
The if statement is one way to branch the control flow:
{==+==}
if 语句是在控制流中创建分支的其中一种方式:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  let name = readLine(stdin)
  if name == "":
    echo "Poor soul, you lost your name?"
  elif name == "name":
    echo "Very funny, your name is name."
  else:
    echo "Hi, ", name, "!"
  ```
{==+==}
  ```nim  test = "nim c $1"
  let name = readLine(stdin)
  if name == "":
    echo "Poor soul, you lost your name?"
  elif name == "name":
    echo "Very funny, your name is name."
  else:
    echo "Hi, ", name, "!"
  ```
{==+==}

{==+==}
There can be zero or more `elif` parts, and the `else` part is optional.
The keyword `elif` is short for `else if`, and is useful to avoid
excessive indentation. (The `""` is the empty string. It contains no
characters.)
{==+==}
这里可以有零个或更多 `elif` 分支， `else` 分支可选。
`elif` 关键字比 `else if` 短，有助于避免过多缩进。
(`""` 是空字符串，不包含字符。)
{==+==}


{==+==}
Case statement
--------------
{==+==}
Case 语句
--------------
{==+==}

{==+==}
Another way to branch is provided by the case statement. A case statement allows
for multiple branches:
{==+==}
通过 case 语句也可创建分支。 case 语句允许有多个分支:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  let name = readLine(stdin)
  case name
  of "":
    echo "Poor soul, you lost your name?"
  of "name":
    echo "Very funny, your name is name."
  of "Dave", "Frank":
    echo "Cool name!"
  else:
    echo "Hi, ", name, "!"
  ```
{==+==}
  ```nim  test = "nim c $1"
  let name = readLine(stdin)
  case name
  of "":
    echo "Poor soul, you lost your name?"
  of "name":
    echo "Very funny, your name is name."
  of "Dave", "Frank":
    echo "Cool name!"
  else:
    echo "Hi, ", name, "!"
  ```
{==+==}

{==+==}
As it can be seen, for an `of` branch a comma-separated list of values is also
allowed.
{==+==}
可以看出，对于 `of` 分支，可以用逗号来分隔值。
{==+==}

{==+==}
The case statement can deal with integers, other ordinal types, and strings.
(What an ordinal type is will be explained soon.)
For integers or other ordinal types value ranges are also possible:
{==+==}
case 语句可以处理整数和其他序数类型，以及字符串。
(稍后会解释什么是序数类型)
也可以处理整数和其他序数类型值的范围:
{==+==}

{==+==}
  ```nim
  # this statement will be explained later:
  from std/strutils import parseInt

  echo "A number please: "
  let n = parseInt(readLine(stdin))
  case n
  of 0..2, 4..7: echo "The number is in the set: {0, 1, 2, 4, 5, 6, 7}"
  of 3, 8: echo "The number is 3 or 8"
  ```
{==+==}
  ```nim
  # 这条语句将在之后解释
  from std/strutils import parseInt

  echo "A number please: "
  let n = parseInt(readLine(stdin))
  case n
  of 0..2, 4..7: echo "The number is in the set: {0, 1, 2, 4, 5, 6, 7}"
  of 3, 8: echo "The number is 3 or 8"
  ```
{==+==}

{==+==}
However, the above code **does not compile**: the reason is that you have to cover
every value that `n` may contain, but the code only handles the values
`0..8`. Since it is not very practical to list every other possible integer
(though it is possible thanks to the range notation), we fix this by telling
the compiler that for every other value nothing should be done:
{==+==}
然而，上面的代码**不能编译**: 因为需要考虑 `n` 所有可能取到的值，但以上代码只处理 `0..8` 。
通常列出所有整数是不现实的(尽管范围表达式可以实现)，
这时，可以明确告知编译器忽略其他值:
{==+==}

{==+==}
  ```nim
  ...
  case n
  of 0..2, 4..7: echo "The number is in the set: {0, 1, 2, 4, 5, 6, 7}"
  of 3, 8: echo "The number is 3 or 8"
  else: discard
  ```
{==+==}
  ```nim
  ...
  case n
  of 0..2, 4..7: echo "The number is in the set: {0, 1, 2, 4, 5, 6, 7}"
  of 3, 8: echo "The number is 3 or 8"
  else: discard
  ```
{==+==}

{==+==}
The empty [discard statement] is a *do
nothing* statement. The compiler knows that a case statement with an else part
cannot fail and thus the error disappears. Note that it is impossible to cover
all possible string values: that is why string cases always need an `else`
branch.
{==+==}
空 [discard 语句] 是一个 *不做任何事* 的语句 。
编译器在评估 case 表达式 else 部分时不再失败，因此不再报错。
需注意的是，不可能处理字符串的所有值:
因此字符串值 case 语句总是需要 `else` 分支。
{==+==}

{==+==}
In general, the case statement is used for subrange types or enumerations where
it is of great help that the compiler checks that you covered any possible
value.
{==+==}
通常，case 语句用于处理范围类型和枚举，因为编译器会检查语句是否考虑了所有可能值。
{==+==}


{==+==}
While statement
---------------
{==+==}
While 语句
---------------
{==+==}

{==+==}
The while statement is a simple looping construct:
{==+==}
while 语句是简单的循环结构:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  echo "What's your name? "
  var name = readLine(stdin)
  while name == "":
    echo "Please tell me your name: "
    name = readLine(stdin) # no `var`, because we do not declare a new variable here
  ```
{==+==}
  ```nim  test = "nim c $1"
  echo "What's your name? "
  var name = readLine(stdin)
  while name == "":
    echo "Please tell me your name: "
    name = readLine(stdin) # 该语句无 `var` 关键字, 这里没有声明新变量
  ```
{==+==}

{==+==}
The example uses a while loop to keep asking the users for their name, as long
as the user types in nothing (only presses RETURN).
{==+==}
在这个例子中，只要用户什么都不输入(仅敲回车键), while 循环就会一直询问用户输入名字。
{==+==}


{==+==}
For statement
-------------
{==+==}
For 语句
-------------
{==+==}

{==+==}
The `for` statement is a construct to loop over any element an *iterator*
provides. The example uses the built-in [countup](
system.html#countup.i,T,T,Positive) iterator:
{==+==}
`for` 语句是遍历*迭代器*的返回值的语法结构。
该示例使用了语言内置的 [countup](system.html#countup.i,T,T,Positive) 迭代器:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  echo "Counting to ten: "
  for i in countup(1, 10):
    echo i
  # --> Outputs 1 2 3 4 5 6 7 8 9 10 on different lines
  ```
{==+==}
  ```nim  test = "nim c $1"
  echo "Counting to ten: "
  for i in countup(1, 10):
    echo i
  # --> 在不同行输出 1 2 3 4 5 6 7 8 9 10
  ```
{==+==}

{==+==}
The variable `i` is implicitly declared by the
`for` loop and has the type `int`, because that is what [countup](
system.html#countup.i,T,T,Positive) returns. `i` runs through the values
1, 2, .., 10. Each value is `echo`-ed. This code does the same:
{==+==}
变量 `i` 由 `for` 循环隐式声明且因 [countup](system.html#countup.i,T,T,Positive) 的原因，
 `i` 的类型会和前者返回值的类型 `int` 一样。
 `i` 会遍历 1, 2, .., 10 。每个值都回被 `echo`-ed 。
这段代码等效于:
{==+==}

{==+==}
  ```nim
  echo "Counting to 10: "
  var i = 1
  while i <= 10:
    echo i
    inc i # increment i by 1
  # --> Outputs 1 2 3 4 5 6 7 8 9 10 on different lines
  ```
{==+==}
  ```nim
  echo "Counting to 10: "
  var i = 1
  while i <= 10:
    echo i
    inc i # i 自增 1
  # --> 在不同行输出 1 2 3 4 5 6 7 8 9 10
  ```
{==+==}

{==+==}
Since counting up occurs so often in programs, Nim also has a [..](
system.html#...i,T,T) iterator that does the same:
{==+==}
因为计数在程序中使用很频繁，Nim 提供了 [..](system.html#...i,T,T) 迭代器语法，实现相同的事情:
{==+==}

{==+==}
  ```nim
  for i in 1 .. 10:
    ...
  ```
{==+==}
  ```nim
  for i in 1 .. 10:
    ...
  ```
{==+==}

{==+==}
Counting down can be achieved as easily (but is less often needed):
{==+==}
倒序计数也容易实现(但通常不太需要):
{==+==}

{==+==}
  ```nim
  echo "Counting down from 10 to 1: "
  for i in countdown(10, 1):
    echo i
  # --> Outputs 10 9 8 7 6 5 4 3 2 1 on different lines
  ```
{==+==}
  ```nim
  echo "Counting down from 10 to 1: "
  for i in countdown(10, 1):
    echo i
  # --> 在不同行输出 1 2 3 4 5 6 7 8 9 10
  ```
{==+==}

{==+==}
Zero-indexed counting has two shortcuts `..<` and `.. ^1`
([backward index operator](system.html#^.t%2Cint)) to simplify
counting to one less than the higher index:
{==+==}
从零开始的计数有两种简写 `..<` 和 `.. ^1`([后向索引运算符](system.html#^.t%2Cint))，
来简化计数到比最高值下标少一的情况:
{==+==}

{==+==}
  ```nim
  for i in 0 ..< 10:
    ...  # the same as 0 .. 9
  ```

or
{==+==}
  ```nim
  for i in 0 ..< 10:
    ...  # 这与 0 .. 9 等同
  ```

或者
{==+==}


{==+==}
  ```nim
  var s = "some string"
  for i in 0 ..< s.len:
    ...
  ```

or
{==+==}
  ```nim
  var s = "some string"
  for i in 0 ..< s.len:
    ...
  ```

或者
{==+==}

{==+==}
  ```nim
  var s = "some string"
  for idx, c in s[0 .. ^1]:
    ... # ^1 is the last element, ^2 would be one before it, and so on
  ```
{==+==}
  ```nim
  var s = "some string"
  for idx, c in s[0 .. ^1]:
    ... # ^1 表示最后一个元素, ^2 是倒数第二个, 以此类推
  ```
{==+==}

{==+==}
Other useful iterators for collections (like arrays and sequences) are
* `items` and `mitems`, which provides immutable and mutable elements respectively, and
* `pairs` and `mpairs` which provides the element and an index number (immutable and mutable respectively)
{==+==}
其他可让集合(比如数组和切片)的使用的更方便的迭代器是
* `items` 和 `mitems`， 他们分别提供不可变和可变元素，而
* `pairs` 和 `mpairs` 提供了配对的元素和它们下标(分别为不可变和可变)
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  for index, item in ["a","b"].pairs:
    echo item, " at index ", index
  # => a at index 0
  # => b at index 1
  ```
{==+==}
  ```nim  test = "nim c $1"
  for index, item in ["a","b"].pairs:
    echo item, " at index ", index
  # => a at index 0
  # => b at index 1
  ```
{==+==}

{==+==}
Scopes and the block statement
------------------------------
{==+==}
作用域和 block 语句
------------------------------------------------
{==+==}

{==+==}
Control flow statements have a feature not covered yet: they open a
new scope. This means that in the following example, `x` is not accessible
outside the loop:
{==+==}
控制流语句有一个未明确呈现的特性: 控制流语句会开启新的作用域。
这意味着下面的例子中 `x` 在循环外不可访问:
{==+==}

{==+==}
  ```nim  test = "nim c $1"  status = 1
  while false:
    var x = "hi"
  echo x # does not work
  ```
{==+==}
  ```nim  test = "nim c $1"  status = 1
  while false:
    var x = "hi"
  echo x # 此句报错
  ```
{==+==}

{==+==}
A while (for) statement introduces an implicit block. Identifiers
are only visible within the block they have been declared. The `block`
statement can be used to open a new block explicitly:
{==+==}
while (for) 语句引入了一个隐式的块。变量只在它们被声明的块中可见。
`block` 语句可以显式地打开一个新的块:
{==+==}

{==+==}
  ```nim  test = "nim c $1"  status = 1
  block myblock:
    var x = "hi"
  echo x # does not work either
  ```
{==+==}
  ```nim  test = "nim c $1"  status = 1
  block myblock:
    var x = "hi"
  echo x # 这里同样会报错
  ```
{==+==}

{==+==}
The block's *label* (`myblock` in the example) is optional.
{==+==}
块的 *标签* (在这个例子中是 `myblock` ) 是可选的。
{==+==}


{==+==}
Break statement
---------------
{==+==}
Break 语句
--------------------
{==+==}


{==+==}
A block can be left prematurely with a `break` statement. The break statement
can leave a `while`, `for`, or a `block` statement. It leaves the
innermost construct, unless a label of a block is given:
{==+==}
使用 `break` 语句可提前离开一个块。
break 语句可离开 `while` 、 `for` 、 `block` 语句。
在未给出块的标签时，会离开最内层的结构:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  block myblock:
    echo "entering block"
    while true:
      echo "looping"
      break # leaves the loop, but not the block
    echo "still in block"
  echo "outside the block"

  block myblock2:
    echo "entering block"
    while true:
      echo "looping"
      break myblock2 # leaves the block (and the loop)
    echo "still in block" # it won't be printed
  echo "outside the block"
  ```
{==+==}
  ```nim  test = "nim c $1"
  block myblock:
    echo "entering block"
    while true:
      echo "looping"
      break # 离开循环但不离开块
    echo "still in block"
  echo "outside the block"

  block myblock2:
    echo "entering block"
    while true:
      echo "looping"
      break myblock2 # 离开块(以及循环)
    echo "still in block" # 不会打印这句
  echo "outside the block"
  ```
{==+==}


{==+==}
Continue statement
------------------
{==+==}
Continue 语句
-----------------------
{==+==}

{==+==}
Like in many other programming languages, a `continue` statement starts
the next iteration immediately:
{==+==}
类似其他许多编程语言 `continue` 语句会立即开启下一轮迭代:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  for i in 1 .. 5:
    if i <= 3: continue
    echo i # will only print 4 and 5
  ```
{==+==}
  ```nim  test = "nim c $1"
  for i in 1 .. 5:
    if i <= 3: continue
    echo i # 将只打印 4 和 5
  ```
{==+==}


{==+==}
When statement
--------------
{==+==}
When 语句
------------------
{==+==}

{==+==}
Example:
{==+==}
例:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  when system.hostOS == "windows":
    echo "running on Windows!"
  elif system.hostOS == "linux":
    echo "running on Linux!"
  elif system.hostOS == "macosx":
    echo "running on Mac OS X!"
  else:
    echo "unknown operating system"
  ```
{==+==}
  ```nim  test = "nim c $1"
  when system.hostOS == "windows":
    echo "running on Windows!"
  elif system.hostOS == "linux":
    echo "running on Linux!"
  elif system.hostOS == "macosx":
    echo "running on Mac OS X!"
  else:
    echo "unknown operating system"
  ```
{==+==}

{==+==}
The `when` statement is almost identical to the `if` statement, but with these
differences:
{==+==}
`when` 语句几乎和 `if` 语句一样，但有以下不同:
{==+==}

{==+==}
* Each condition must be a constant expression since it is evaluated by the
  compiler.
* The statements within a branch do not open a new scope.
* The compiler checks the semantics and produces code *only* for the statements
  that belong to the first condition that evaluates to `true`.
{==+==}
* 每种情况都会被编译器评估，所以其必须是个常量表达式。
* 分支语句不会开启新作用域。
* 编译器会检查语义并且*只*为第一个被评估为 `true` 的情况生成代码。
{==+==}

{==+==}
The `when` statement is useful for writing platform-specific code, similar to
the `#ifdef`:c: construct in the C programming language.
{==+==}
与 C语言 中的 `#ifdef`:c: 相似，`when` 语句在编写针对特定平台的代码时十分有用。
{==+==}


{==+==}
Statements and indentation
==========================
{==+==}
语句和缩进
==========================
{==+==}

{==+==}
Now that we covered the basic control flow statements, let's return to Nim
indentation rules.
{==+==}
至此介绍了基本的控制流语句，再为回顾 Nim 的缩进规则。
{==+==}

{==+==}
In Nim, there is a distinction between *simple statements* and *complex
statements*. *Simple statements* cannot contain other statements:
Assignment, procedure calls, or the `return` statement are all simple
statements. *Complex statements* like `if`, `when`, `for`, `while` can
contain other statements. To avoid ambiguities, complex statements must always
be indented, but single simple statements do not:
{==+==}
在 Nim 中，*简单语句* 有别于 *复杂语句* 。 *简单语句* 不能包含其他语句:
赋值、过程调用或 `return` 语句都是简单语句。 
*复杂的语句* 如 `if` `when` `for` `while` 可以包含其他语句。
为避免歧义，复杂语句必须始终缩进，但单个简单语句不需要:
{==+==}

{==+==}
  ```nim
  # no indentation needed for single-assignment statement:
  if x: x = false

  # indentation needed for nested if statement:
  if x:
    if y:
      y = false
    else:
      y = true

  # indentation needed, because two statements follow the condition:
  if x:
    x = false
    y = false
  ```
{==+==}
  ```nim
  # 单一的赋值语句不需要缩进:
  if x: x = false

  # 嵌套的 if 语句需要缩进:
  if x:
    if y:
      y = false
    else:
      y = true

  # 在这种有两条语句紧随的情况下，需要缩进:
  if x:
    x = false
    y = false
  ```
{==+==}


{==+==}
*Expressions* are parts of a statement that usually result in a value. The
condition in an if statement is an example of an expression. Expressions can
contain indentation at certain places for better readability:
{==+==}
*表达式* 是语句的一部分，其通常会产生一个值。
if 语句中的条件就是个例子。
表达式可以在某些位置包含缩进以提高可读性:
{==+==}

{==+==}
  ```nim
  if thisIsaLongCondition() and
      thisIsAnotherLongCondition(1,
         2, 3, 4):
    x = true
  ```
{==+==}
  ```nim
  if thisIsaLongCondition() and
      thisIsAnotherLongCondition(1,
         2, 3, 4):
    x = true
  ```
{==+==}

{==+==}
As a rule of thumb, indentation within expressions is allowed after operators,
an open parenthesis and after commas.
{==+==}
通常，可以在表达式中运算符、左括号和逗号之后缩进。
{==+==}

{==+==}
With parenthesis and semicolons `(;)` you can use statements where only
an expression is allowed:
{==+==}
通过使用括号和分号 `(;)`，可在只允许使用表达式的地方使用语句:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  # computes fac(4) at compile time:
  const fac4 = (var x = 1; for i in 1..4: x *= i; x)
  ```
{==+==}
  ```nim  test = "nim c $1"
  # 在编译时计算 fac(4):
  const fac4 = (var x = 1; for i in 1..4: x *= i; x)
  ```
{==+==}


{==+==}
Procedures
==========
{==+==}
过程
==========
{==+==}

{==+==}
To define new commands like [echo](system.html#echo,varargs[typed,])
and [readLine](syncio.html#readLine,File) in the examples, the concept of a
*procedure* is needed. You might be used to them being called *methods* or
*functions* in other languages, but Nim
[differentiates these concepts](tut1.html#procedures-funcs-and-methods). In
Nim, new procedures are defined with the `proc` keyword:
{==+==}
为了在示例中定义像 [echo](system.html#echo,varargs[typed,])
和 [readLine](syncio.html#readLine,File) 这样的新命令，需要 *过程* 的概念。 
你可能习惯在其他语言中将它们称为 *方法* 或 *函数* ，
但 Nim 将 [这些这些概念进行了区分](tut1.html#procedures-funcs-and-methods) 。
在 Nim 中，使用 `proc` 关键字定义过程:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc yes(question: string): bool =
    echo question, " (y/n)"
    while true:
      case readLine(stdin)
      of "y", "Y", "yes", "Yes": return true
      of "n", "N", "no", "No": return false
      else: echo "Please be clear: yes or no"

  if yes("Should I delete all your important files?"):
    echo "I'm sorry Dave, I'm afraid I can't do that."
  else:
    echo "I think you know what the problem is just as well as I do."
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc yes(question: string): bool =
    echo question, " (y/n)"
    while true:
      case readLine(stdin)
      of "y", "Y", "yes", "Yes": return true
      of "n", "N", "no", "No": return false
      else: echo "Please be clear: yes or no"

  if yes("Should I delete all your important files?"):
    echo "I'm sorry Dave, I'm afraid I can't do that."
  else:
    echo "I think you know what the problem is just as well as I do."
  ```
{==+==}

{==+==}
This example shows a procedure named `yes` that asks the user a `question`
and returns true if they answered "yes" (or something similar) and returns
false if they answered "no" (or something similar). A `return` statement
leaves the procedure (and therefore the while loop) immediately. The
`(question: string): bool` syntax describes that the procedure expects a
parameter named `question` of type `string` and returns a value of type
`bool`. The `bool` type is built-in: the only valid values for `bool` are
`true` and `false`.
The conditions in if or while statements must be of type `bool`.
{==+==}
这个例子展示了一个名为 `yes` 的过程，它询问用户一个 `question` ，
若回答 "yes" (或类似的回答)，返回 true，若回答 "no" (或类似的回答)，则返回 false 。
`return` 语句将立即离开过程(也将离开 while 循环)。
`(question: string): bool` 语法表明，过程需要一个名为 `question` 的 `string` 类型的参数，并返回 `bool` 类型的值。
`bool` 类型是内置的: `bool` 的有效值只能是 `true` 和 `false`。
if 和 while 语句中的条件必须是 `bool` 类型。
{==+==}

{==+==}
Some terminology: in the example `question` is called a (formal) *parameter*,
`"Should I..."` is called an *argument* that is passed to this parameter.
{==+==}
一些术语: 在示例中，`question` 被称为 *参数* (形参)，
`"Should I..."` 被称为传递给此参数的 *实参* 。
{==+==}


{==+==}
Result variable
---------------
{==+==}
Result 变量
-------------------
{==+==}

{==+==}
A procedure that returns a value has an implicit `result` variable declared
that represents the return value. A `return` statement with no expression is
shorthand for `return result`. The `result` value is always returned
automatically at the end of a procedure if there is no `return` statement at
the exit.
{==+==}
有返回值的过程包含一个隐式声明，即代表返回值的 `result` 变量。
没有携带表达式的 `return` 语句是 `return result` 的简写。
过程结尾退出时若没有 `return` 语句，将自动返回 `result` 值。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc sumTillNegative(x: varargs[int]): int =
    for i in x:
      if i < 0:
        return
      result = result + i

  echo sumTillNegative() # echoes 0
  echo sumTillNegative(3, 4, 5) # echoes 12
  echo sumTillNegative(3, 4 , -1 , 6) # echoes 7
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc sumTillNegative(x: varargs[int]): int =
    for i in x:
      if i < 0:
        return
      result = result + i

  echo sumTillNegative() # 输出 0
  echo sumTillNegative(3, 4, 5) # 输出 12
  echo sumTillNegative(3, 4 , -1 , 6) # 输出 7
  ```
{==+==}

{==+==}
The `result` variable is already implicitly declared at the start of the
function, so declaring it again with 'var result', for example, would shadow it
with a normal variable of the same name. The result variable is also already
initialized with the type's default value. Note that referential data types will
be `nil` at the start of the procedure, and thus may require manual
initialization.
{==+==}
`result` 变量已经在函数开头隐式声明，因此，再次声明 'var result' 会用同名的普通变量遮蔽它。
result 变量也已初始化成其类型的默认值。注意，引用数据类型在过程开始时为 "nil" ，因此可能需要手动初始化。
{==+==}

{==+==}
A procedure that does not have any `return` statement and does not use the
special `result` variable returns the value of its last expression. For example,
this procedure
{==+==}
不使用 `return` 语句和不使用特殊变量 `result` 的过程将返回其最后一个表达式的值。
例如这个过程
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc helloWorld(): string =
    "Hello, World!"
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc helloWorld(): string =
    "Hello, World!"
  ```
{==+==}

{==+==}
returns the string "Hello, World!".
{==+==}
返回字符串 "Hello, World"。
{==+==}

{==+==}
Parameters
----------
{==+==}
参数
----------
{==+==}

{==+==}
Parameters are immutable in the procedure body. By default, their value cannot be
changed because this allows the compiler to implement parameter passing in the
most efficient way. If a mutable variable is needed inside the procedure, it has
to be declared with `var` in the procedure body. Shadowing the parameter name
is possible, and actually an idiom:
{==+==}
参数在过程中是不可变的。默认情况下，它们的值不可改变，因为这将允许编译器更高效地实现传参。
如果在过程中需要一个可变的变量，它应该在过程中以 `var` 来声明。遮蔽参数名称是可能的，实际上
有经验的人会这么做:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc printSeq(s: seq, nprinted: int = -1) =
    var nprinted = if nprinted == -1: s.len else: min(nprinted, s.len)
    for i in 0 ..< nprinted:
      echo s[i]
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc printSeq(s: seq, nprinted: int = -1) =
    var nprinted = if nprinted == -1: s.len else: min(nprinted, s.len)
    for i in 0 ..< nprinted:
      echo s[i]
  ```
{==+==}

{==+==}
If the procedure needs to modify the argument for the
caller, a `var` parameter can be used:
{==+==}
若过程需要修改调用者传入的参数，可以使用 `var` 参数:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc divmod(a, b: int; res, remainder: var int) =
    res = a div b        # integer division
    remainder = a mod b  # integer modulo operation

  var
    x, y: int
  divmod(8, 5, x, y) # modifies x and y
  echo x
  echo y
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc divmod(a, b: int; res, remainder: var int) =
    res = a div b        # 整数的整除
    remainder = a mod b  # 整数取模

  var
    x, y: int
  divmod(8, 5, x, y) # 对 x 和 y 取模
  echo x
  echo y
  ```
{==+==}

{==+==}
In the example, `res` and `remainder` are `var parameters`.
Var parameters can be modified by the procedure and the changes are
visible to the caller. Note that the above example would better make use of
a tuple as a return value instead of using var parameters.
{==+==}
在这个例子中，`res` 和 `remainder` 是 `var parameters`。
Var 参数可以被过程修改且该修改对调用者可知。注意上面的例子用元组作为
返回值而不是使用 var 参数会更好。
{==+==}


{==+==}
Discard statement
-----------------
{==+==}
Discard 语句
---------------------
{==+==}

{==+==}
To call a procedure that returns a value just for its side effects and ignoring
its return value, a `discard` statement **must** be used. Nim does not
allow silently throwing away a return value:
{==+==}
调用仅需其副作用而不需要其返回值并忽略其返回值的过程，**必须**使用`discard`语句。
Nim 不允许隐式丢弃返回值:
{==+==}

{==+==}
  ```nim
  discard yes("May I ask a pointless question?")
  ```
{==+==}
  ```nim
  discard yes("May I ask a pointless question?")
  ```
{==+==}


{==+==}
The return value can be ignored implicitly if the called proc/iterator has
been declared with the `discardable` pragma:
{==+==}
如果调用的过程 / 迭代器通过 `discardable` 编译指示声明，则其返回值可被隐式地忽略:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc p(x, y: int): int {.discardable.} =
    return x + y

  p(3, 4) # now valid
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc p(x, y: int): int {.discardable.} =
    return x + y

  p(3, 4) # 现在合法了
  ```
{==+==}


{==+==}
Named arguments
---------------
{==+==}
具名参数
----------------
{==+==}

{==+==}
Often a procedure has many parameters and it is not clear in which order the
parameters appear. This is especially true for procedures that construct a
complex data type. Therefore, the arguments to a procedure can be named, so
that it is clear which argument belongs to which parameter:
{==+==}
通常一个有许多参数的过程，其参数出现的顺序是不清楚的。尤其是在构建一个复杂数据类型时。
因此，传给过程的参数可以具名，这样该参数属于哪个形参就明了了:
{==+==}

{==+==}
  ```nim
  proc createWindow(x, y, width, height: int; title: string;
                    show: bool): Window =
     ...

  var w = createWindow(show = true, title = "My Application",
                       x = 0, y = 0, height = 600, width = 800)
  ```
{==+==}
  ```nim
  proc createWindow(x, y, width, height: int; title: string;
                    show: bool): Window =
     ...

  var w = createWindow(show = true, title = "My Application",
                       x = 0, y = 0, height = 600, width = 800)
  ```
{==+==}

{==+==}
Now that we use named arguments to call `createWindow` the argument order
does not matter anymore. Mixing named arguments with ordered arguments is
also possible, but not very readable:
{==+==}
注意我们使用具名参数调用 `createWindow`，参数的顺序不再重要。混合使用具名参数和遵循顺序的参数
也是可能的，但可读性很差。
{==+==}

{==+==}
  ```nim
  var w = createWindow(0, 0, title = "My Application",
                       height = 600, width = 800, true)
  ```
{==+==}
  ```nim
  var w = createWindow(0, 0, title = "My Application",
                       height = 600, width = 800, true)
  ```
{==+==}

{==+==}
The compiler checks that each parameter receives exactly one argument.
{==+==}
编译器检查每个形参是否只接收一个参数。
{==+==}


{==+==}
Default values
--------------
{==+==}
默认值
--------------
{==+==}

{==+==}
To make the `createWindow` proc easier to use it should provide `default
values`; these are values that are used as arguments if the caller does not
specify them:
{==+==}
为了使 `createWindow` 过程更易用，应提供 `default values`;
如果调用者未指定这些参数，则用这些值作参数:
{==+==}

{==+==}
  ```nim
  proc createWindow(x = 0, y = 0, width = 500, height = 700,
                    title = "unknown",
                    show = true): Window =
     ...

  var w = createWindow(title = "My Application", height = 600, width = 800)
  ```
{==+==}
  ```nim
  proc createWindow(x = 0, y = 0, width = 500, height = 700,
                    title = "unknown",
                    show = true): Window =
     ...

  var w = createWindow(title = "My Application", height = 600, width = 800)
  ```
{==+==}

{==+==}
Now the call to `createWindow` only needs to set the values that differ
from the defaults.
{==+==}
现在调用 `createWindow` 只需设置与默认值不同的参数即可。
{==+==}

{==+==}
Note that type inference works for parameters with default values; there is
no need to write `title: string = "unknown"`, for example.
{==+==}
注意，类型推断可用于赋予了默认值的参数; 比如，不需要这样写 `title: string = "unknown"`。
{==+==}


{==+==}
Overloaded procedures
---------------------
{==+==}
过程重载
---------------------
{==+==}

{==+==}
Nim provides the ability to overload procedures similar to C++:
{==+==}
Nim 提供了类似 C++ 的过程重载能力:
{==+==}

{==+==}
  ```nim
  proc toString(x: int): string =
    result =
      if x < 0: "negative"
      elif x > 0: "positive"
      else: "zero"

  proc toString(x: bool): string =
    result =
      if x: "yep"
      else: "nope"

  assert toString(13) == "positive" # calls the toString(x: int) proc
  assert toString(true) == "yep"    # calls the toString(x: bool) proc
  ```
{==+==}
  ```nim
  proc toString(x: int): string =
    result =
      if x < 0: "negative"
      elif x > 0: "positive"
      else: "zero"

  proc toString(x: bool): string =
    result =
      if x: "yep"
      else: "nope"

  assert toString(13) == "positive" # 调用 toString(x: int) 过程
  assert toString(true) == "yep"    # 调用 toString(x: bool) 过程
  ```
{==+==}

{==+==}
(Note that `toString` is usually the [$](dollars.html) operator in
Nim.) The compiler chooses the most appropriate proc for the `toString`
calls. How this overloading resolution algorithm works exactly is not
discussed here -- see the manual for details. Ambiguous calls are reported as errors.
{==+==}
(注意在 Nim 中，`toString` 通常以 [$](dollars.html) 运算符表示)
编译器会选择最合适的过程来处理 `toString` 调用。在此不讨论这种重载解析算法是如何工作的 -- 详情请见手册。
模棱两可的调用会被报告为错误。
{==+==}


{==+==}
Operators
---------
{==+==}
运算符
------------
{==+==}

{==+==}
The Nim standard library makes heavy use of overloading - one reason for this is that
each operator like `+` is just an overloaded proc. The parser lets you
use operators in *infix notation* (`a + b`) or *prefix notation* (`+ a`).
An infix operator always receives two arguments, a prefix operator always one.
(Postfix operators are not possible, because this would be ambiguous: does
`a @ @ b` mean `(a) @ (@b)` or `(a@) @ (b)`? It always means
`(a) @ (@b)`, because there are no postfix operators in Nim.)
{==+==}
Nim 标准库大量使用重载 - 原因之一是每个像 `+` 这样的运算符都只是一个重载的过程。
解析器允许你在*中缀符号* (`a + b`) 或 *前缀符号* (`+ a`) 中使用运算符。
一个中缀运算符通常接收两个参数，一个前缀运算符通常接收一个。
(后缀运算符是不可能的，因为这会模糊语义: `a @ @ b` 是指 `(a) @ (@b)`
还是 `(a@) @ (b)`? 这通常指 `(a) @ (@b)`，因为在 Nim 中没有后缀运算符。)
{==+==}

{==+==}
Apart from a few built-in keyword operators such as `and`, `or`, `not`,
operators always consist of these characters:
`+  -  *  \  /  <  >  =  @  $  ~  &  %  !  ?  ^  .  |`
{==+==}
除了一些内置的关键字运算符，如 `and`, `or`, `not`,
其他运算符总是由以下字符组成:
`+  -  *  \  /  <  >  =  @  $  ~  &  %  !  ?  ^  .  |`
{==+==}

{==+==}
User-defined operators are allowed. Nothing stops you from defining your own
`@!?+~` operator, but doing so may reduce readability.
{==+==}
可以使用用户自定义的运算符。没有什么能阻止你定义自己的 `@!?+~` 运算符，
但这样做可能会降低可读性。
{==+==}

{==+==}
The operator's precedence is determined by its first character. The details
can be [found in the manual](manual.html#syntax-precedence).
{==+==}
运算符的优先级由其第一个字符确定。详情可以[在手册中找到](manual.html#syntax-precedence)。
{==+==}

{==+==}
To define a new operator enclose the operator in backticks "`":
{==+==}
要定义一个新的运算符，请将运算符括在反引号 "`" 中:
{==+==}

{==+==}
  ```nim
  proc `$` (x: myDataType): string = ...
  # now the $ operator also works with myDataType, overloading resolution
  # ensures that $ works for built-in types just like before
  ```
{==+==}
  ```nim
  proc `$` (x: myDataType): string = ...
  # 注意，现在 $ 运算符也可作用于 myDataType，重载解析会
  # 保证 $ 也可以像以前一样作用于内置类型
  ```
{==+==}

{==+==}
The "`" notation can also be used to call an operator just like any other
procedure:
{==+==}
"`" 符号也可用于像任何其他过程一样调用运算符:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  if `==`( `+`(3, 4), 7): echo "true"
  ```
{==+==}
  ```nim  test = "nim c $1"
  if `==`( `+`(3, 4), 7): echo "true"
  ```
{==+==}


{==+==}
Forward declarations
--------------------
{==+==}
前置声明
--------------------
{==+==}

{==+==}
Every variable, procedure, etc. needs to be declared before it can be used.
(The reason for this is that it is non-trivial to avoid this need in a
language that supports metaprogramming as extensively as Nim does.)
However, this cannot be done for mutually recursive procedures:
{==+==}
每个变量、过程等都需要先声明才能使用。(这样做的原因是，在像 Nim 一样广泛支持元编程
的语言中避免这种需求并非易事)但是，对于相互递归的过程则不能这样做:
{==+==}

{==+==}
  ```nim
  # forward declaration:
  proc even(n: int): bool
  ```
{==+==}
  ```nim
  # 前置声明:
  proc even(n: int): bool
  ```
{==+==}

{==+==}
  ```nim
  proc odd(n: int): bool =
    assert(n >= 0) # makes sure we don't run into negative recursion
    if n == 0: false
    else:
      n == 1 or even(n-1)

  proc even(n: int): bool =
    assert(n >= 0) # makes sure we don't run into negative recursion
    if n == 1: false
    else:
      n == 0 or odd(n-1)
  ```
{==+==}
  ```nim
  proc odd(n: int): bool =
    assert(n >= 0) # 确保我们不会进入由负数导致的递归
    if n == 0: false
    else:
      n == 1 or even(n-1)

  proc even(n: int): bool =
    assert(n >= 0) # 确保我们不会进入由负数导致的递归
    if n == 1: false
    else:
      n == 0 or odd(n-1)
  ```
{==+==}

{==+==}
Here `odd` depends on `even` and vice versa. Thus `even` needs to be
introduced to the compiler before it is completely defined. The syntax for
such a forward declaration is simple: just omit the `=` and the
procedure's body. The `assert` just adds border conditions, and will be
covered later in [Modules] section.
{==+==}
这里的 `odd` 依赖 `even`，反之亦然。因此，在完全定义之前，需要将 `even` 引入编译器。
这种前置声明的语法很简单: 只需省略 `=` 和过程的主体。 `assert` 只是添加了边界条件，
稍后会在[模块]部分介绍。
{==+==}

{==+==}
Later versions of the language will weaken the requirements for forward
declarations.
{==+==}
后续版本会弱化对前置声明的要求。
{==+==}

{==+==}
The example also shows that a proc's body can consist of a single expression
whose value is then returned implicitly.
{==+==}
该示例还表明，proc 的主体可以由单个表达式组成，并隐式返回其值。
{==+==}


{==+==}
Funcs and methods
-----------------
{==+==}
Funcs 和 方法
-------------------------
{==+==}

{==+==}
As mentioned in the introduction, Nim differentiates between procedures,
functions, and methods, defined by the `proc`, `func`, and `method` keywords
respectively. In some ways, Nim is a bit more pedantic in its definitions than
other languages.
{==+==}
正如介绍中提到的，Nim 区分过程、函数和方法，后者分别由 `proc`、`func` 和 `method` 关键字定义。
在某些方面，Nim 的定义比其他语言更迂腐。
{==+==}

{==+==}
Functions are closer to the concept of a pure mathematical
function, which might be familiar to you if you've ever done functional
programming. Essentially they are procedures with additional limitations set on
them: they can't access global state (except `const`) and can't produce
side-effects. The `func` keyword is basically an alias for `proc` tagged
with `{.noSideEffects.}`. Functions can still change their mutable arguments
however, which are those marked as `var`, along with any `ref` objects.
{==+==}
函数更接近于纯数学函数的概念，如果你曾进行过函数式编程，你可能对它很熟悉。
本质上，它们是设置了额外限制的过程: 它们不能访问全局状态(`const` 除外)且不能产生副作用。
`func` 关键字基本上是用 `{.noSideEffects.}` 标记的 `proc` 的别名。
然而，函数仍然可以更改它们的被 `var` 标记的可变参数，以及任何 `ref` 对象。
{==+==}

{==+==}
Unlike procedures, methods are dynamically dispatched. This sounds a bit
complicated, but it is a concept closely related to inheritance and object-oriented
programming. If you overload a procedure (two procedures with the same name but
of different types or with different sets of arguments are said to be overloaded), the procedure to use is determined
at compile-time. Methods, on the other hand, depend on objects that inherit from
the `RootObj`. This is something that is covered in much greater depth in
the [second part of the tutorial](tut2.html#object-oriented-programming-dynamic-dispatch).
{==+==}
与过程不同，方法是动态分派的。这听起来有点复杂，但它是一个与继承和面向对象编程密切相关的概念。
如果你重载一个过程(两个具有相同名称但类型不同或具有不同参数集的过程称为重载)，则要使用的过程会在编译时确定。
另一方面，方法依赖于从 `RootObj` 继承的对象。
这在[本教程的第二部分](tut2.html#object-orienting-programming-dynamic-dispatch) 中会有更深入的介绍。
{==+==}


{==+==}
Iterators
=========
{==+==}
迭代器
=================
{==+==}

{==+==}
Let's return to the simple counting example:
{==+==}
让我们回到简单的计数示例:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  echo "Counting to ten: "
  for i in countup(1, 10):
    echo i
  ```
{==+==}
  ```nim  test = "nim c $1"
  echo "Counting to ten: "
  for i in countup(1, 10):
    echo i
  ```
{==+==}

{==+==}
Can a [countup](system.html#countup.i,T,T,Positive) proc be written that
supports this loop? Let's try:
{==+==}
[countup](system.html#countup.i,T,T,Positive) 过程可以写得支持这种循环吗?
让我们试试:
{==+==}

{==+==}
  ```nim
  proc countup(a, b: int): int =
    var res = a
    while res <= b:
      return res
      inc(res)
  ```
{==+==}
  ```nim
  proc countup(a, b: int): int =
    var res = a
    while res <= b:
      return res
      inc(res)
  ```
{==+==}

{==+==}
However, this does not work. The problem is that the procedure should not
only `return`, but return and **continue** after an iteration has
finished. This *return and continue* is called a `yield` statement. Now
the only thing left to do is to replace the `proc` keyword by `iterator`
and here it is -- our first iterator:
{==+==}
然而，这不起作用。问题是该过程不应只 `return`，而应该在迭代完成后返回并**继续**。
这种*返回并继续*的语句被称为一个 `yield`。现在剩下要做的就是用 `iterator` 替换 `proc` 关键字，
这就是我们的第一个迭代器:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  iterator countup(a, b: int): int =
    var res = a
    while res <= b:
      yield res
      inc(res)
  ```
{==+==}
  ```nim  test = "nim c $1"
  iterator countup(a, b: int): int =
    var res = a
    while res <= b:
      yield res
      inc(res)
  ```
{==+==}

{==+==}
Iterators look very similar to procedures, but there are several
important differences:
{==+==}
迭代器看起来与过程非常相似，但有几个重要区别:
{==+==}

{==+==}
* Iterators can only be called from for loops.
* Iterators cannot contain a `return` statement (and procs cannot contain a
  `yield` statement).
* Iterators have no implicit `result` variable.
* Iterators do not support recursion.
* Iterators cannot be forward declared, because the compiler must be able to inline an iterator.
  (This restriction will be gone in a future version of the compiler.)
{==+==}
* 迭代器只能在 for 循环中调用。
* 迭代器不能含有 `return` 语句。(相应的，过程中不能有 `yield` 语句)
* 迭代器没有隐式的 `result` 变量。
* 迭代器不支持递归。
* 迭代器不能前置声明，因为编译器必须能够内联一个迭代器。(这个限制将在未来版本的编译器中移除)
{==+==}

{==+==}
However, you can also use a closure iterator to get a different set of
restrictions. See [first-class iterators](
manual.html#iterators-and-the-for-statement-firstminusclass-iterators)
for details. Iterators can have the same name and parameters as a proc since
essentially they have their own namespaces. Therefore, it is common to
wrap iterators in procs of the same name which accumulate the result of the
iterator and return it as a sequence, like `split` from the [strutils module](
strutils.html).
{==+==}
但是，你也可以使用闭包迭代器来获得一组不同的限制。
详情请见 [first-class iterators](
manual.html#iterators-and-the-for-statement-firstminusclass-iterators)。
迭代器可具有与过程相同的名称和参数，因为本质上它们具有自己的命名空间。因此，
通常将迭代器包装在同名的过程中，这些过程会累积迭代器的结果并将其作为序列返回，
例如 [strutils 模块](strutils.html) 中的 `split`。
{==+==}


{==+==}
Basic types
===========
{==+==}
基本类型
================
{==+==}

{==+==}
This section deals with the basic built-in types and the operations
that are available for them in detail.
{==+==}
本节详细介绍了基本内置类型及它们的可用操作。
{==+==}

{==+==}
Booleans
--------
{==+==}
布尔
--------
{==+==}

{==+==}
Nim's boolean type is called `bool` and consists of the two
pre-defined values `true` and `false`. Conditions in `while`,
`if`, `elif`, and `when` statements must be of type bool.
{==+==}
Nim 的布尔类型称为 `bool`，由两个预定义值 `true` 和 `false` 组成。
`while`, `if`,`elif` 和 `when` 语句中的条件必须是布尔类型。
{==+==}

{==+==}
The operators `not, and, or, xor, <, <=, >, >=, !=, ==` are defined
for the bool type. The `and` and `or` operators perform short-circuit
evaluation. For example:
{==+==}
运算符 `not, and, or, xor, <, <=, >, >=, !=, ==` 是为 bool 类型定义的。
`and` 和 `or` 运算符会执行短路评估。例如:
{==+==}

{==+==}
  ```nim
  while p != nil and p.name != "xyz":
    # p.name is not evaluated if p == nil
    p = p.next
  ```
{==+==}
  ```nim
  while p != nil and p.name != "xyz":
    # 当 p == nil 时，p.name 不会被评估
    p = p.next
  ```
{==+==}


{==+==}
Characters
----------
{==+==}
字符
----------
{==+==}

{==+==}
The *character type* is called `char`. Its size is always one byte, so
it cannot represent most UTF-8 characters, but it *can* represent one of the bytes
that makes up a multibyte UTF-8 character.
The reason for this is efficiency: for the overwhelming majority of use-cases,
the resulting programs will still handle UTF-8 properly as UTF-8 was especially
designed for this.
Character literals are enclosed in single quotes.
{==+==}
*字符类型*被称作 `char`。其大小始终为一个字节，因此它不能够表示大多数 UTF-8 字符，
但它*可以*表示组成 UTF-8 字符中的一个字节。这样做是为了效率: 对于绝大多数用例，
产生的程序仍将正确处理 UTF-8，因为 UTF-8 是专门为此设计的。字符字面量用单引号括起来。
{==+==}

{==+==}
Chars can be compared with the `==`, `<`, `<=`, `>`, `>=` operators.
The `$` operator converts a `char` to a `string`. Chars cannot be mixed
with integers; to get the ordinal value of a `char` use the `ord` proc.
Converting from an integer to a `char` is done with the `chr` proc.
{==+==}
字符可以用 `==`、`<`、`<=`、`>`、`>=` 运算符进行比较。`$` 运算符将 `char`
转换为 `string`。字符不能与整数混合; 要获取 `char` 的序数值，请使用 `ord` 过程。
使用 `chr` 过程完成从整数到 `char` 的转换。
{==+==}


{==+==}
Strings
-------
{==+==}
字符串
------------
{==+==}

{==+==}
String variables are **mutable**, so appending to a string
is possible, and quite efficient. Strings in Nim are both zero-terminated and have a
length field. A string's length can be retrieved with the builtin `len`
procedure; the length never counts the terminating zero. Accessing the
terminating zero is an error, it only exists so that a Nim string can be converted
to a `cstring` without doing a copy.
{==+==}
字符串变量是**可变的**，所以追加字符串是可能的，并且相当高效。
Nim 中的字符串既以零为结尾，也包含长度字段。一个字符串的长度可通过内置的 `len` 过程来获取;
长度永远不会计算上结尾零。对结尾零的访问是个错误，它的存在只是为了 Nim 的字符串能够被零拷贝地
转换成 `cstring`。
{==+==}

{==+==}
The assignment operator for strings copies the string. You can use the `&`
operator to concatenate strings and `add` to append to a string.
{==+==}
字符串的赋值操作将复制字符串。你可以使用 `&` 运算符连接字符串或使用 `add` 追加字符串。
{==+==}

{==+==}
Strings are compared using their lexicographical order. All the comparison operators
are supported. By convention, all strings are UTF-8 encoded, but this is not
enforced. For example, when reading strings from binary files, they are merely
a sequence of bytes. The index operation `s[i]` means the i-th *char* of
`s`, not the i-th *unichar*.
{==+==}
字符串会使用其字典顺序进行比较且支持所有的比较运算符。按照惯例，所有字符串都是 UTF-8 编码的，
但这不是强制的。例如，从二进制文件中读取字符串时，它们仅仅只是一个字节序列。
索引操作 `s[i]` 表示获取 `s` 的第 i 个 *char*，而不是第i个 *unichar*。
{==+==}

{==+==}
A string variable is initialized with the empty string `""`.
{==+==}
字符串变量会被初始化为空字符串 `""`。
{==+==}


{==+==}
Integers
--------
{==+==}
整数
--------
{==+==}

{==+==}
Nim has these integer types built-in:
`int int8 int16 int32 int64 uint uint8 uint16 uint32 uint64`.
{==+==}
Nim 有以下内置的整数类型:
`int int8 int16 int32 int64 uint uint8 uint16 uint32 uint64`.
{==+==}

{==+==}
The default integer type is `int`. Integer literals can have a *type suffix*
to specify a non-default integer type:
{==+==}
默认整数类型是 `int`。整数字面量可以用*类型后置*来指定非默认的整数类型:
{==+==}


{==+==}
  ```nim  test = "nim c $1"
  let
    x = 0     # x is of type `int`
    y = 0'i8  # y is of type `int8`
    z = 0'i32 # z is of type `int32`
    u = 0'u   # u is of type `uint`
  ```
{==+==}
  ```nim  test = "nim c $1"
  let
    x = 0     # x 是 `int` 类型
    y = 0'i8  # y 是 `int8` 类型
    z = 0'i32 # z 是 `int32` 类型
    u = 0'u   # u 是 `uint` 类型
  ```
{==+==}

{==+==}
Most often integers are used for counting objects that reside in memory, so
`int` has the same size as a pointer.
{==+==}
大多数情况下，整数会被用于计数驻留在内存中的对象，因此 `int` 具有与指针相同的大小。
{==+==}

{==+==}
The common operators `+ - * div mod  <  <=  ==  !=  >  >=` are defined for
integers. The `and or xor not` operators are also defined for integers and
provide *bitwise* operations. Left bit shifting is done with the `shl`, right
shifting with the `shr` operator. Bit shifting operators always treat their
arguments as *unsigned*. For `arithmetic bit shifts`:idx: ordinary
multiplication or division can be used.
{==+==}
已为整数定义了常用的运算符 `+ - * div mod < <= == != > >=`。 `and or xor not` 
运算符也已为整数定义并提供*按位*运算。左移使用 `shl` 完成，右移使用 `shr` 运算符。
位移位运算符始终将其参数视为 *unsigned*。 对于`算术位移`:idx: 可以使用普通的乘法或除法。
{==+==}

{==+==}
Unsigned operations all wrap around; they cannot lead to over- or under-flow
errors.
{==+==}
无符号操作都会回绕; 它们不会导致溢出或下溢错误。
{==+==}

{==+==}
Lossless `Automatic type conversion`:idx: is performed in expressions where different
kinds of integer types are used. However, if the type conversion
would cause loss of information, the `RangeDefect`:idx: is raised (if the error
cannot be detected at compile time).
{==+==}
无损 `Automatic type conversion`:idx: 会在使用了不同类型的整数类型的表达式中执行。
然而，如果类型转换会导致信息丢失，则会引发 `RangeDefect`:idx: (前提是在编译时无法检测到该错误)。
{==+==}


{==+==}
Floats
------
{==+==}
浮点数
------------
{==+==}

{==+==}
Nim has these floating-point types built-in: `float float32 float64`.
{==+==}
Nim 有这些内置的浮点类型: `float float32 float64`。
{==+==}

{==+==}
The default float type is `float`. In the current implementation,
`float` is always 64-bits.
{==+==}
默认的浮点类型是 `float`。在当前实现中，`float` 是64位的。
{==+==}

{==+==}
Float literals can have a *type suffix* to specify a non-default float
type:
{==+==}
浮点字面值可以有一个*类型后缀*来指定一个非默认的浮点类型:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var
    x = 0.0      # x is of type `float`
    y = 0.0'f32  # y is of type `float32`
    z = 0.0'f64  # z is of type `float64`
  ```
{==+==}
  ```nim  test = "nim c $1"
  var
    x = 0.0      # x 是 `float` 类型
    y = 0.0'f32  # y 是 `float32` 类型
    z = 0.0'f64  # z 是 `float64` 类型
  ```
{==+==}

{==+==}
The common operators `+ - * /  <  <=  ==  !=  >  >=` are defined for
floats and follow the IEEE-754 standard.
{==+==}
常见的运算符 `+ - * / < <= == != > >=` 已为浮点数定义，并遵循 IEEE-754 标准。
{==+==}

{==+==}
Automatic type conversion in expressions with different kinds of floating-point types is performed: the smaller type is converted to the larger. Integer
types are **not** converted to floating-point types automatically, nor vice
versa. Use the [toInt](system.html#toInt,float) and
[toFloat](system.html#toFloat,int) procs for these conversions.
{==+==}
在具有不同浮点类型的表达式中将自动执行类型转换: 较小的类型会转换为较大的类型。
整数类型**不会**自动转换为浮点类型，反之亦然。为进行这些转换可用 [toInt](system.html#toInt,float)
和 [toFloat](system.html#toFloat,int) 过程。
{==+==}


{==+==}
Type Conversion
---------------
{==+==}
类型转换
----------------
{==+==}

{==+==}
Conversion between numerical types is performed by using the
type as a function:
{==+==}
数值类型之间的转换是通过将类型用作函数来执行的:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var
    x: int32 = 1.int32   # same as calling int32(1)
    y: int8  = int8('a') # 'a' == 97'i8
    z: float = 2.5       # int(2.5) rounds down to 2
    sum: int = int(x) + int(y) + int(z) # sum == 100
  ```
{==+==}
  ```nim  test = "nim c $1"
  var
    x: int32 = 1.int32   # 与调用 int32(1) 相同
    y: int8  = int8('a') # 'a' == 97'i8
    z: float = 2.5       # int(2.5) 将向下舍入到 2
    sum: int = int(x) + int(y) + int(z) # sum == 100
  ```
{==+==}


{==+==}
Internal type representation
============================
{==+==}
内部类型表示
============================
{==+==}

{==+==}
As mentioned earlier, the built-in [$](dollars.html) (stringify) operator
turns any basic type into a string, which you can then print to the console
using the `echo` proc. However, advanced types, and your own custom types,
won't work with the `$` operator until you define it for them.
Sometimes you just want to debug the current value of a complex type without
having to write its `$` operator.  You can use then the [repr](
system.html#repr,T) proc which works with any type and even complex data
graphs with cycles. The following example shows that even for basic types
there is a difference between the `$` and `repr` outputs:
{==+==}
如前所述，内置的 [$](dollars.html) (stringify) 运算符将任意基本类型转为字符串，
然后你可以使用 `echo` 过程将其打印到控制台。但是，除非你为高级类型和你的自定义类型
进行定义，否则后者将不能与 `$` 运算符一起使用。你可以在只想调试复杂类型的当前值，
而不想编写其 `$` 运算符时，使用 [repr](system.html#repr,T) 过程，
它适用于任何类型，甚至是带有周期的复杂数据图。以下示例表明，即使对于基本类型，
`$` 和 `repr` 输出之间也存在差异:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var
    myBool = true
    myCharacter = 'n'
    myString = "nim"
    myInteger = 42
    myFloat = 3.14
  echo myBool, ":", repr(myBool)
  # --> true:true
  echo myCharacter, ":", repr(myCharacter)
  # --> n:'n'
  echo myString, ":", repr(myString)
  # --> nim:0x10fa8c050"nim"
  echo myInteger, ":", repr(myInteger)
  # --> 42:42
  echo myFloat, ":", repr(myFloat)
  # --> 3.14:3.14
  ```
{==+==}
  ```nim  test = "nim c $1"
  var
    myBool = true
    myCharacter = 'n'
    myString = "nim"
    myInteger = 42
    myFloat = 3.14
  echo myBool, ":", repr(myBool)
  # --> true:true
  echo myCharacter, ":", repr(myCharacter)
  # --> n:'n'
  echo myString, ":", repr(myString)
  # --> nim:0x10fa8c050"nim"
  echo myInteger, ":", repr(myInteger)
  # --> 42:42
  echo myFloat, ":", repr(myFloat)
  # --> 3.14:3.14
  ```
{==+==}


{==+==}
Advanced types
==============
{==+==}
高阶类型
================
{==+==}

{==+==}
In Nim new types can be defined within a `type` statement:
{==+==}
在 Nim 中，新的类型可以通过 `type` 语句来定义:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    biggestInt = int64      # biggest integer type that is available
    biggestFloat = float64  # biggest float type that is available
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    biggestInt = int64      # 可允许的最大整数类型
    biggestFloat = float64  # 可允许的最大浮点数类型
  ```
{==+==}

{==+==}
Enumeration and object types may only be defined within a
`type` statement.
{==+==}
枚举和对象类型只能在 `type` 语句中定义。
{==+==}


{==+==}
Enumerations
------------
{==+==}
枚举
------------
{==+==}

{==+==}
A variable of an enumeration type can only be assigned one of the enumeration's specified values.
These values are a set of ordered symbols. Each symbol is mapped
to an integer value internally. The first symbol is represented
at runtime by 0, the second by 1, and so on. For example:
{==+==}
枚举类型的变量只能被赋予其的某种枚举值。这些值是一组有序符号。每个符号在内部映射到一个整数值。
第一个符号在运行时用 0 表示，第二个用 1 表示，以此类推。例如:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    Direction = enum
      north, east, south, west

  var x = south     # `x` is of type `Direction`; its value is `south`
  echo x            # prints "south"
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    Direction = enum
      north, east, south, west

  var x = south     # `x` 的类型是 `Direction`; 它的值是 `south`
  echo x            # 打印 "south"
  ```
{==+==}

{==+==}
All the comparison operators can be used with enumeration types.
{==+==}
所有比较运算符都可以与枚举类型一起使用。
{==+==}

{==+==}
An enumeration's symbol can be qualified to avoid ambiguities:
`Direction.south`.
{==+==}
可通过限定枚举的符号以避免歧义: `Direction.south`。
{==+==}

{==+==}
The `$` operator can convert any enumeration value to its name, and the `ord`
proc can convert it to its underlying integer value.
{==+==}
`$` 运算符可以将任何枚举值转换为其名称，而 `ord` 过程可以将其转换为其底层整数值。
{==+==}

{==+==}
For better interfacing to other programming languages, the symbols of enum
types can be assigned an explicit ordinal value. However, the ordinal values
must be in ascending order.
{==+==}
为了更好地与其他编程语言交互，可以为枚举类型的符号分配一个明确的序数值。
但是，序数值必须升序排列。
{==+==}


{==+==}
Ordinal types
-------------
{==+==}
序数类型
----------------
{==+==}

{==+==}
Enumerations, integer types, `char` and `bool` (and
subranges) are called ordinal types. Ordinal types have quite
a few special operations:
{==+==}
枚举、整数类型、`char` 和 `bool` (以及子范围)称为序数类型。
序数类型有很多独特操作:
{==+==}


{==+==}
=================     ========================================================
Operation             Comment
=================     ========================================================
`ord(x)`              returns the integer value that is used to
                      represent `x`'s value
`inc(x)`              increments `x` by one
`inc(x, n)`           increments `x` by `n`; `n` is an integer
`dec(x)`              decrements `x` by one
`dec(x, n)`           decrements `x` by `n`; `n` is an integer
`succ(x)`             returns the successor of `x`
`succ(x, n)`          returns the `n`'th successor of `x`
`pred(x)`             returns the predecessor of `x`
`pred(x, n)`          returns the `n`'th predecessor of `x`
=================     ========================================================
{==+==}
=================     ========================================================
操作                  说明
=================     ========================================================
`ord(x)`              返回用于表示 `x` 值的整数值
`inc(x)`              将 `x` 加一
`inc(x, n)`           将 `x` 增加 `n`; `n` 是一个整数
`dec(x)`              将 `x` 减一
`dec(x, n)`           将 `x` 递减 `n`; `n` 是一个整数
`succ(x)`             返回 `x` 的后继
`succ(x, n)`          返回 `x` 的第 `n` 个后继
`pred(x)`             返回 `x` 的前任
`pred(x, n)`          返回 `x` 的第 `n` 个前任
=================     ========================================================
{==+==}


{==+==}
The [inc](system.html#inc,T,int), [dec](system.html#dec,T,int), [succ](
system.html#succ,T,int) and [pred](system.html#pred,T,int) operations can
fail by raising an `RangeDefect` or `OverflowDefect`. (If the code has been
compiled with the proper runtime checks turned on.)
{==+==}
[inc](system.html#inc,T,int), [dec](system.html#dec,T,int), [succ](
system.html#succ,T,int) 以及 [pred](system.html#pred,T,int) 运算在引发
`RangeDefect` 或 `OverflowDefect`. 时会失败。(当代码在恰当的运行时检查
被打开时时编译)
{==+==}


{==+==}
Subranges
---------
{==+==}
子范围
------------
{==+==}

{==+==}
A subrange type is a range of values from an integer or enumeration type
(the base type). Example:
{==+==}
子范围类型是来自整数或枚举类型(基本类型)的值范围。例:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    MySubrange = range[0..5]
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    MySubrange = range[0..5]
  ```
{==+==}


{==+==}
`MySubrange` is a subrange of `int` which can only hold the values 0
to 5. Assigning any other value to a variable of type `MySubrange` is a
compile-time or runtime error. Assignments from the base type to one of its
subrange types (and vice versa) are allowed.
{==+==}
`MySubrange` 是 `int` 的子范围，它只能保存值 0 到 5。
将任何其他值分配给 `MySubrange` 类型的变量是一个编译时或运行时错误。
可将基本类型赋值给其某一子范围类型(反之亦然)。
{==+==}

{==+==}
The `system` module defines the important [Natural](system.html#Natural)
type as `range[0..high(int)]` ([high](system.html#high,typedesc[T]) returns
the maximal value). Other programming languages may suggest the use of unsigned
integers for natural numbers. This is often **unwise**: you don't want unsigned
arithmetic (which wraps around) just because the numbers cannot be negative.
Nim's `Natural` type helps to avoid this common programming error.
{==+==}
`system` 模块将重要的 [Natural](system.html#Natural) 类型定义为
`range[0..high(int)]` ([high](system.html#high,typedesc[T]) 返回 最大值)。
其他编程语言可能建议对自然数使用无符号整数。这通常是**不明智的**: 
你不希望仅仅因为数字不能为负数而用(会产生回绕的)无符号运算。Nim 的 `Natural` 类型有助于避免这种常见的编程错误。
{==+==}


{==+==}
Sets
----
{==+==}
集合
--------
{==+==}

{==+==}
.. include:: sets_fragment.txt
{==+==}
.. include:: sets_fragment.txt
{==+==}

{==+==}
Arrays
------
{==+==}
数组
--------
{==+==}

{==+==}
An array is a simple fixed-length container. Each element in
an array has the same type. The array's index type can be any ordinal type.
{==+==}
一个数组是一个简单，有固定长度的容器。数组中的每个元素类型相同。
数组的下标可以是任何序数类型。
{==+==}

{==+==}
Arrays can be constructed using `[]`:
{==+==}
可使用 `[]` 构造数组:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    IntArray = array[0..5, int] # an array that is indexed with 0..5
  var
    x: IntArray
  x = [1, 2, 3, 4, 5, 6]
  for i in low(x) .. high(x):
    echo x[i]
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    IntArray = array[0..5, int] # an array that is indexed with 0..5
  var
    x: IntArray
  x = [1, 2, 3, 4, 5, 6]
  for i in low(x) .. high(x):
    echo x[i]
  ```
{==+==}

{==+==}
The notation `x[i]` is used to access the i-th element of `x`.
Array access is always bounds checked (at compile-time or at runtime). These
checks can be disabled via pragmas or invoking the compiler with the
``--bound_checks:off`` command line switch.
{==+==}
符号 `x[i]` 用于访问 `x` 的第 i 个元素。访问数组总是会进行边界检查(在编译时或运行时)。
这些检查可通过编译指示或使用 ``--bound_checks:off`` 命令行开关唤起编译器来禁用。
{==+==}

{==+==}
Arrays are value types, like any other Nim type. The assignment operator
copies the whole array contents.
{==+==}
数组是值类型，就像任何其他 Nim 类型一样。赋值运算符将复制整个数组的内容。
{==+==}

{==+==}
The built-in [len](system.html#len,TOpenArray) proc returns the array's
length. [low(a)](system.html#low,openArray[T]) returns the lowest valid index
for the array `a` and [high(a)](system.html#high,openArray[T]) the highest
valid index.
{==+==}
内置的 [len] 过程会返回数组的长度。[low(a)] 返回数组 `a` 最小的有效下标，而 [high(a)]
返回最大有效下标。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    Direction = enum
      north, east, south, west
    BlinkLights = enum
      off, on, slowBlink, mediumBlink, fastBlink
    LevelSetting = array[north..west, BlinkLights]
  var
    level: LevelSetting
  level[north] = on
  level[south] = slowBlink
  level[east] = fastBlink
  echo level        # --> [on, fastBlink, slowBlink, off]
  echo low(level)   # --> north
  echo len(level)   # --> 4
  echo high(level)  # --> west
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    Direction = enum
      north, east, south, west
    BlinkLights = enum
      off, on, slowBlink, mediumBlink, fastBlink
    LevelSetting = array[north..west, BlinkLights]
  var
    level: LevelSetting
  level[north] = on
  level[south] = slowBlink
  level[east] = fastBlink
  echo level        # --> [on, fastBlink, slowBlink, off]
  echo low(level)   # --> north
  echo len(level)   # --> 4
  echo high(level)  # --> west
  ```
{==+==}

{==+==}
The syntax for nested arrays (multidimensional) in other languages is a matter
of appending more brackets because usually each dimension is restricted to the
same index type as the others. In Nim you can have different dimensions with
different index types, so the nesting syntax is slightly different. Building on
the previous example where a level is defined as an array of enums indexed by
yet another enum, we can add the following lines to add a light tower type
subdivided into height levels accessed through their integer index:
{==+==}
在其他语言中创建嵌套(多维)数组的语法是添加更多括号，因为通常每个维度的索引类型都被限制成
与其他维度相同。在 Nim 中，你可以有不同维度和不同的索引类型，因此嵌套语法略有不同。
在上一个示例，level 被定义为一个把另一个枚举当做索引的枚举数组，我们可以添加以下行来
添加一个 LightTower 类型，该类型细分为通过其整数索引访问其高度的 LevelSetting:
{==+==}

{==+==}
  ```nim
  type
    LightTower = array[1..10, LevelSetting]
  var
    tower: LightTower
  tower[1][north] = slowBlink
  tower[1][east] = mediumBlink
  echo len(tower)     # --> 10
  echo len(tower[1])  # --> 4
  echo tower          # --> [[slowBlink, mediumBlink, ...more output..
  # The following lines don't compile due to type mismatch errors
  #tower[north][east] = on
  #tower[0][1] = on
  ```
{==+==}
  ```nim
  type
    LightTower = array[1..10, LevelSetting]
  var
    tower: LightTower
  tower[1][north] = slowBlink
  tower[1][east] = mediumBlink
  echo len(tower)     # --> 10
  echo len(tower[1])  # --> 4
  echo tower          # --> [[slowBlink, mediumBlink, ...more output..
  # 下面这几行因为类型不匹配而不会被编译
  #tower[north][east] = on
  #tower[0][1] = on
  ```
{==+==}

{==+==}
Note how the built-in `len` proc returns only the array's first dimension
length.  Another way of defining the `LightTower` to better illustrate its
nested nature would be to omit the previous definition of the `LevelSetting`
type and instead write it embedded directly as the type of the first dimension:
{==+==}
注意内置的 `len` 过程是如何仅返回数组第一维长度的。定义 `LightTower`
以更好地说明其嵌套性质的另一种方法是省略之前对 `LevelSetting` 类型的定义，
并直接将其嵌入作为第一个维度的类型:
{==+==}

{==+==}
  ```nim
  type
    LightTower = array[1..10, array[north..west, BlinkLights]]
  ```
{==+==}
  ```nim
  type
    LightTower = array[1..10, array[north..west, BlinkLights]]
  ```
{==+==}

{==+==}
It is quite common to have arrays start at zero, so there's a shortcut syntax
to specify a range from zero to the specified index minus one:
{==+==}
数组从零开始是很常见的，因此有一种快捷语法可以指定从零到指定索引减一的范围：
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    IntArray = array[0..5, int] # an array that is indexed with 0..5
    QuickArray = array[6, int]  # an array that is indexed with 0..5
  var
    x: IntArray
    y: QuickArray
  x = [1, 2, 3, 4, 5, 6]
  y = x
  for i in low(x) .. high(x):
    echo x[i], y[i]
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    IntArray = array[0..5, int] # 一个下标范围为 0..5 的数组
    QuickArray = array[6, int]  # 一个下标范围为 0..5 的数组
  var
    x: IntArray
    y: QuickArray
  x = [1, 2, 3, 4, 5, 6]
  y = x
  for i in low(x) .. high(x):
    echo x[i], y[i]
  ```
{==+==}


{==+==}
Sequences
---------
{==+==}
序列
---------
{==+==}

{==+==}
Sequences are similar to arrays but of dynamic length which may change
during runtime (like strings). Since sequences are resizable they are always
allocated on the heap and garbage collected.
{==+==}
序列类似于数组，但其长度是动态的，在运行时可能会发生变化(如字符串)。
由于序列大小可调，它们总是分配在堆上并受垃圾回收。
{==+==}

{==+==}
Sequences are always indexed with an `int` starting at position 0.  The [len](
system.html#len,seq[T]), [low](system.html#low,openArray[T]) and [high](
system.html#high,openArray[T]) operations are available for sequences too.
The notation `x[i]` can be used to access the i-th element of `x`.
{==+==}
序列总是用从 0 开始的 `int` 进行索引。[len](system.html#len,seq[T]), [low](
system.html#low,openArray[T]) 和 [high]( system.html#high,openArray[T])
操作也可用于序列。符号 `x[i]` 可用于访问 `x` 的第 i 个元素。
{==+==}

{==+==}
Sequences can be constructed by the array constructor `[]` in conjunction
with the array to sequence operator `@`. Another way to allocate space for
a sequence is to call the built-in [newSeq](system.html#newSeq) procedure.
{==+==}
序列可用数组构造器 `[]` 和将数组转换到序列的运算符 `@` 来构造。
为序列分配空间的另一种方法是调用内置的 [newSeq](system.html#newSeq) 过程。
{==+==}

{==+==}
A sequence may be passed to an openarray parameter.
{==+==}
序列可被传递给一个开放数组参数。
{==+==}

{==+==}
Example:
{==+==}
例:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var
    x: seq[int] # a reference to a sequence of integers
  x = @[1, 2, 3, 4, 5, 6] # the @ turns the array into a sequence allocated on the heap
  ```
{==+==}
  ```nim  test = "nim c $1"
  var
    x: seq[int] # a reference to a sequence of integers
  x = @[1, 2, 3, 4, 5, 6] # @ 将数组转换成分配在堆上的序列
  ```
{==+==}

{==+==}
Sequence variables are initialized with `@[]`.
{==+==}
序列变量可用 `@[]` 初始化。
{==+==}

{==+==}
The `for` statement can be used with one or two variables when used with a
sequence. When you use the one variable form, the variable will hold the value
provided by the sequence. The `for` statement is looping over the results
from the [items()](iterators.html#items.i,seq[T]) iterator from the [system](
system.html) module.  But if you use the two-variable form, the first
variable will hold the index position and the second variable will hold the
value. Here the `for` statement is looping over the results from the
[pairs()](iterators.html#pairs.i,seq[T]) iterator from the [system](
system.html) module.  Examples:
{==+==}
当与序列一起使用时，`for` 语句可以承接一个或两个变量。当你使用单变量形式时，
变量将保存序列提供的值。`for` 语句循环遍历的结果来自 [system](system.html) 模块的
[items()](iterators.html#items.i,seq[T]) 迭代器。但是如果使用双变量形式，
第一个变量将保存索引位置，第二个变量将保存值。这里的 `for` 语句循环遍历结果来自
[system](system.html) 模块的 [pairs()](iterators.html#pairs.i,seq[T]) 迭代器。
例子:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  for value in @[3, 4, 5]:
    echo value
  # --> 3
  # --> 4
  # --> 5

  for i, value in @[3, 4, 5]:
    echo "index: ", $i, ", value:", $value
  # --> index: 0, value:3
  # --> index: 1, value:4
  # --> index: 2, value:5
  ```
{==+==}
  ```nim  test = "nim c $1"
  for value in @[3, 4, 5]:
    echo value
  # --> 3
  # --> 4
  # --> 5

  for i, value in @[3, 4, 5]:
    echo "index: ", $i, ", value:", $value
  # --> index: 0, value:3
  # --> index: 1, value:4
  # --> index: 2, value:5
  ```
{==+==}


{==+==}
Open arrays
-----------
{==+==}
开放数组
----------------
{==+==}

{==+==}
**Note**: Openarrays can only be used for parameters.
{==+==}
**注意**: 开放数组只能被用于形参。
{==+==}

{==+==}
Often fixed-size arrays turn out to be too inflexible; procedures should be
able to deal with arrays of different sizes. The `openarray`:idx: type allows
this. Openarrays are always indexed with an `int` starting at position 0.
The [len](system.html#len,TOpenArray), [low](system.html#low,openArray[T])
and [high](system.html#high,openArray[T]) operations are available for open
arrays too.  Any array with a compatible base type can be passed to an
openarray parameter, the index type does not matter.
{==+==}
通常，固定大小的数组非常不灵活。程序应该能够处理不同大小的数组。 `openarray`:idx: 类型允许这样做。
开放数组总是用从位置 0 到 `int` 进行索引。[len](system.html#len,TOpenArray), [low](
system.html#low,openArray[T]) 和 [high](system. html#high,openArray[T]) 操作也可用于开放数组。
任何具有兼容基类型的数组都可以传递给开放数组形参，索引的类型则无关紧要。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var
    fruits:   seq[string]       # reference to a sequence of strings that is initialized with '@[]'
    capitals: array[3, string]  # array of strings with a fixed size

  capitals = ["New York", "London", "Berlin"]   # array 'capitals' allows assignment of only three elements
  fruits.add("Banana")          # sequence 'fruits' is dynamically expandable during runtime
  fruits.add("Mango")

  proc openArraySize(oa: openArray[string]): int =
    oa.len

  assert openArraySize(fruits) == 2     # procedure accepts a sequence as parameter
  assert openArraySize(capitals) == 3   # but also an array type
  ```
{==+==}
  ```nim  test = "nim c $1"
  var
    fruits:   seq[string]       # 引用一个由 '@[]' 初始化的 string 的切片
    capitals: array[3, string]  # 拥有固定大小的 string 类型的数组

  capitals = ["New York", "London", "Berlin"]   # 数组 'capitals' 仅允许赋值三个元素
  fruits.add("Banana")          # 切片 'fruits' 可在运行时动态扩容
  fruits.add("Mango")

  proc openArraySize(oa: openArray[string]): int =
    oa.len

  assert openArraySize(fruits) == 2     # 过程接收一个切片作为参数
  assert openArraySize(capitals) == 3   # 但也可以是一个数组类型
  ```
{==+==}

{==+==}
The openarray type cannot be nested: multidimensional openarrays are not
supported because this is seldom needed and cannot be done efficiently.
{==+==}
开放数组类型不能嵌套: 不支持多维开放数组，因为这种需求不常见而且不能被高效实现。
{==+==}


{==+==}
Varargs
-------
{==+==}
可变参数
----------------
{==+==}

{==+==}
A `varargs` parameter is like an openarray parameter. However, it is
also a means to implement passing a variable number of
arguments to a procedure. The compiler converts the list of arguments
to an array automatically:
{==+==}
`varargs` 形参类似于开放数组形参。但它也是一种将可变数量的参数传递给过程的方法。
编译器会自动将参数列表转换为数组:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc myWriteln(f: File, a: varargs[string]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, "abc", "def", "xyz")
  # is transformed by the compiler to:
  myWriteln(stdout, ["abc", "def", "xyz"])
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc myWriteln(f: File, a: varargs[string]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, "abc", "def", "xyz")
  # 上面将被编译器转化成:
  myWriteln(stdout, ["abc", "def", "xyz"])
  ```
{==+==}

{==+==}
This transformation is only done if the varargs parameter is the
last parameter in the procedure header. It is also possible to perform
type conversions in this context:
{==+==}
仅当 varargs 参数是过程的最后一个入参时这种转换才会进行。在这种情况下也可执行类型转换:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc myWriteln(f: File, a: varargs[string, `$`]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, 123, "abc", 4.0)
  # is transformed by the compiler to:
  myWriteln(stdout, [$123, $"abc", $4.0])
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc myWriteln(f: File, a: varargs[string, `$`]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, 123, "abc", 4.0)
  # 上面将被编译器转化成:
  myWriteln(stdout, [$123, $"abc", $4.0])
  ```
{==+==}

{==+==}
In this example [$](dollars.html) is applied to any argument that is passed
to the parameter `a`. Note that [$](dollars.html) applied to strings is a
nop.
{==+==}
在此示例中，[$](dollars.html) 将作用于传递给形参 `a` 的所以参数。请注意，将 [$](dollars.html) 
作用于字符串是 nop。
{==+==}


{==+==}
Slices
------
{==+==}
切片
--------
{==+==}

{==+==}
Slices look similar to subranges types in syntax but are used in a different
context. A slice is just an object of type Slice which contains two bounds,
`a` and `b`. By itself a slice is not very useful, but other collection types
define operators which accept Slice objects to define ranges.
{==+==}
切片在语法上看起来与子范围类型相似，但被使用在不同的语境中。切片只是一个切片类型的对象，
它包含两个边界，`a` 和 `b`。当只有切片时，它并不十分有用，但其他集合类型定义了接受切片对象来定义范围的运算符。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var
    a = "Nim is a programming language"
    b = "Slices are useless."

  echo a[7 .. 12] # --> 'a prog'
  b[11 .. ^2] = "useful"
  echo b # --> 'Slices are useful.'
  ```
{==+==}
  ```nim  test = "nim c $1"
  var
    a = "Nim is a programming language"
    b = "Slices are useless."

  echo a[7 .. 12] # --> 'a prog'
  b[11 .. ^2] = "useful"
  echo b # --> 'Slices are useful.'
  ```
{==+==}

{==+==}
In the previous example slices are used to modify a part of a string. The
slice's bounds can hold any value supported by
their type, but it is the proc using the slice object which defines what values
are accepted.
{==+==}
在之前的示例中，切片用于修改字符串其中一部分。切片的边界可以保存任何其类型支持的值，
但这其实是能够接受该值的过程使用了切片对象。
{==+==}

{==+==}
To understand the different ways of specifying the indices of
strings, arrays, sequences, etc., it must be remembered that Nim uses
zero-based indices.
{==+==}
要理解指定字符串、数组、序列等索引的不同方法，必须记住 Nim 使用从零开始的索引。
{==+==}

{==+==}
So the string `b` is of length 19, and two different ways of specifying the
indices are
{==+==}
所以字符串 `b` 的长度为 19, 指定索引的两种不同方法是
{==+==}

{==+==}
  ```nim
  "Slices are useless."
   |          |     |
   0         11    17   using indices
  ^19        ^8    ^2   using ^ syntax
  ```
{==+==}
  ```nim
  "Slices are useless."
   |          |     |
   0         11    17   使用下标
  ^19        ^8    ^2   使用 ^ 语法
  ```
{==+==}

{==+==}
where `b[0 .. ^1]` is equivalent to `b[0 .. b.len-1]` and `b[0 ..< b.len]`, and it
can be seen that the `^1` provides a shorthand way of specifying the `b.len-1`. See
the [backwards index operator](system.html#^.t%2Cint).
{==+==}
这里 `b[0 .. ^1]` 与 `b[0 .. b.len-1]` 和 `b[0 ..< b.len]` 等价，同时可以看到，`^1` 
提供了一种表示  `b.len-1` 的速记方法。请见[向后索引运算符](system.html#^.t%2Cint)。
{==+==}

{==+==}
In the above example, because the string ends in a period, to get the portion of the
string that is "useless" and replace it with "useful".
{==+==}
在上面的例子中，因为字符串以句点结尾，要获取字符串的 "useless" 部分并将其替换为 "useful"。
{==+==}

{==+==}
`b[11 .. ^2]` is the portion "useless", and `b[11 .. ^2] = "useful"` replaces the
"useless" portion with "useful", giving the result "Slices are useful."
{==+==}
`b[11 .. ^2]` 是 "useless" 部分，而 `b[11 .. ^2] = "useful"` 用 "useful"
替换了 "useless" 部分，使结果变成 "Slices are useful."
{==+==}

{==+==}
Note 1: alternate ways of writing this are `b[^8 .. ^2] = "useful"` or
as `b[11 .. b.len-2] = "useful"` or as `b[11 ..< b.len-1] = "useful"`.
{==+==}
注 1: 其他的方式为 `b[^8 .. ^2] = "useful"` 或写成 `b[11 .. b.len-2] = "useful"`
或 `b[11 ..< b.len-1] = "useful"`。
{==+==}

{==+==}
Note 2: As the `^` template returns a [distinct int](manual.html#types-distinct-type)
of type `BackwardsIndex`, we can have a `lastIndex` constant defined as `const lastIndex = ^1`,
and later used as `b[0 .. lastIndex]`.
{==+==}
注 2: 由于 `^` 模板返回类型为 [distinct int](manual.html#types-distinct-type) 即 `BackwardsIndex`，
我们可以定义一个 `lastIndex` 常量 `const lastIndex = ^1`，同时在之后使用 `b[0 .. lastIndex]`。
{==+==}

{==+==}
Objects
-------
{==+==}
对象
--------
{==+==}

{==+==}
The default type to pack different values together in a single
structure with a name is the object type. An object is a value type,
which means that when an object is assigned to a new variable all its
components are copied as well.
{==+==}
将不同的值打包到具有名称的单个结构中的类型默认是对象类型。
对象是一种值类型，这意味着当一个对象被分配给一个新变量时，它的所有组件也会被复制。
{==+==}

{==+==}
Each object type `Foo` has a constructor `Foo(field: value, ...)`
where all of its fields can be initialized. Unspecified fields will
get their default value.
{==+==}
每个对象类型 `Foo` 都有一个可以初始化所有字段的构造函数 `Foo(field: value, ...)`，
未指定的字段将采用其默认值。
{==+==}

{==+==}
  ```nim
  type
    Person = object
      name: string
      age: int

  var person1 = Person(name: "Peter", age: 30)

  echo person1.name # "Peter"
  echo person1.age  # 30

  var person2 = person1 # copy of person 1

  person2.age += 14

  echo person1.age # 30
  echo person2.age # 44


  # the order may be changed
  let person3 = Person(age: 12, name: "Quentin")

  # not every member needs to be specified
  let person4 = Person(age: 3)
  # unspecified members will be initialized with their default
  # values. In this case it is the empty string.
  doAssert person4.name == ""
  ```
{==+==}
  ```nim
  type
    Person = object
      name: string
      age: int

  var person1 = Person(name: "Peter", age: 30)

  echo person1.name # "Peter"
  echo person1.age  # 30

  var person2 = person1 # 对 person 1 的拷贝

  person2.age += 14

  echo person1.age # 30
  echo person2.age # 44


  # 顺序可以改变
  let person3 = Person(age: 12, name: "Quentin")

  # 不需要指出所有字段
  let person4 = Person(age: 3)
  # 未指定的字段将被赋予其默认值。
  # 在下面这中情况，默认值是一个空字符串。
  doAssert person4.name == ""
  ```
{==+==}


{==+==}
Object fields that should be visible from outside the defining module have to
be marked with `*`.
{==+==}
对其定义所处的模块外可见的对象字段必须用 `*` 标记。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    Person* = object # the type is visible from other modules
      name*: string  # the field of this type is visible from other modules
      age*: int
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    Person* = object # 该类型对其他模块可见
      name*: string  # 该字段对其他模块可见
      age*: int
  ```
{==+==}

{==+==}
Tuples
------
{==+==}
元组
--------
{==+==}

{==+==}
Tuples are very much like what you have seen so far from objects. They
are value types where the assignment operator copies each component.
Unlike object types though, tuple types are structurally typed,
meaning different tuple-types are *equivalent* if they specify fields of
the same type and of the same name in the same order.
{==+==}
元组非常类似于你到目前为止从对象中所看到的内容。它们值类型，赋值运算符将拷贝它们的每一个部分。
然而，与对象类型不同的是，元组类型是以结构为类型的，这意味着如果不同的元组类型以相同的顺序指定相同类型和相同名称的字段，
那么它们是*等效的*。
{==+==}

{==+==}
The constructor `()` can be used to construct tuples. The order of the
fields in the constructor must match the order in the tuple's
definition. But unlike objects, a name for the tuple type may not be
used here.
{==+==}
构造函数 `()` 可用于构造元组。构造函数中字段的顺序必须与元组定义中的顺序相匹配。
但与对象不同的是，这里可能不会使用元组类型的名称。
{==+==}


{==+==}
Like the object type the notation `t.field` is used to access a
tuple's field. Another notation that is not available for objects is
`t[i]` to access the `i`'th field. Here `i` must be a constant
integer.
{==+==}
与对象类型一样，符号 `t.field` 用于访问元组的字段。
另一个不可用于对象的符号 `t[i]`，可用来访问第 `i` 个字段。
这里 `i` 必须是一个常量整数。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    # type representing a person:
    # A person consists of a name and an age.
    Person = tuple
      name: string
      age: int

    # Alternative syntax for an equivalent type.
    PersonX = tuple[name: string, age: int]

    # anonymous field syntax
    PersonY = (string, int)

  var
    person: Person
    personX: PersonX
    personY: PersonY

  person = (name: "Peter", age: 30)
  # Person and PersonX are equivalent
  personX = person

  # Create a tuple with anonymous fields:
  personY = ("Peter", 30)

  # A tuple with anonymous fields is compatible with a tuple that has
  # field names.
  person = personY
  personY = person

  # Usually used for short tuple initialization syntax
  person = ("Peter", 30)

  echo person.name # "Peter"
  echo person.age  # 30

  echo person[0] # "Peter"
  echo person[1] # 30

  # You don't need to declare tuples in a separate type section.
  var building: tuple[street: string, number: int]
  building = ("Rue del Percebe", 13)
  echo building.street

  # The following line does not compile, they are different tuples!
  #person = building
  # --> Error: type mismatch: got (tuple[street: string, number: int])
  #     but expected 'Person'
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    # 该类型代表一个人:
    # 一个人由姓名和年龄组成。
    Person = tuple
      name: string
      age: int

    # 另外一种可表示该类型的语法。
    PersonX = tuple[name: string, age: int]

    # 匿名字段语法
    PersonY = (string, int)

  var
    person: Person
    personX: PersonX
    personY: PersonY

  person = (name: "Peter", age: 30)
  # Person 和 PersonX 是相等的
  personX = person

  # 使用匿名字段创建一个新元组:
  personY = ("Peter", 30)

  # 由匿名字段构成的元组和由具名字段构成的元组是可比较的。
  person = personY
  personY = person

  # 通常用于短元组的初始化语法
  person = ("Peter", 30)

  echo person.name # "Peter"
  echo person.age  # 30

  echo person[0] # "Peter"
  echo person[1] # 30

  # 你无需在单独的类型段中声明元组。
  var building: tuple[street: string, number: int]
  building = ("Rue del Percebe", 13)
  echo building.street

  # 下面这行不会编译，因为它们是不同的元组!
  #person = building
  # --> Error: type mismatch: got (tuple[street: string, number: int])
  #     but expected 'Person'
  ```
{==+==}

{==+==}
Even though you don't need to declare a type for a tuple to use it, tuples
created with different field names will be considered different objects despite
having the same field types.
{==+==}
虽然你在使用元组时不需要为其声明类型，但使用不同的字段名称创建的元组将被视为不同的对象，
尽管它们的字段具有相同的类型。
{==+==}

{==+==}
Tuples can be *unpacked* during variable assignment. This can
be handy to assign directly the fields of the tuples to individually named
variables. An example of this is the [splitFile](os.html#splitFile,string)
proc from the [os module](os.html) which returns the directory, name, and
extension of a path at the same time. For tuple unpacking to work you must
use parentheses around the values you want to assign the unpacking to,
otherwise, you will be assigning the same value to all the individual
variables! For example:
{==+==}
元组可以在变量赋值期间*解包*。 这可以很方便地将元组字段直接分配给单独的具命变量。
这方面的一个例子是 [os 模块](os.html) 中的 [splitFile](os.html#splitFile,string) 过程，
它同时返回路径的目录、名称和扩展名。为了使元组解包工作，你必须在要分配解包值的周围使用括号，
否则，你将为所有单个变量分配相同的值!例如:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/os

  let
    path = "usr/local/nimc.html"
    (dir, name, ext) = splitFile(path)
    baddir, badname, badext = splitFile(path)
  echo dir      # outputs "usr/local"
  echo name     # outputs "nimc"
  echo ext      # outputs ".html"
  # All the following output the same line:
  # "(dir: usr/local, name: nimc, ext: .html)"
  echo baddir
  echo badname
  echo badext
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/os

  let
    path = "usr/local/nimc.html"
    (dir, name, ext) = splitFile(path)
    baddir, badname, badext = splitFile(path)
  echo dir      # outputs "usr/local"
  echo name     # outputs "nimc"
  echo ext      # outputs ".html"
  # 以下所有输出将打印下面这一行:
  # "(dir: usr/local, name: nimc, ext: .html)"
  echo baddir
  echo badname
  echo badext
  ```
{==+==}

{==+==}
Tuple unpacking is also supported in for-loops:
{==+==}
for 循环也支持元组解包:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  let a = [(10, 'a'), (20, 'b'), (30, 'c')]

  for (x, c) in a:
    echo x
  # This will output: 10; 20; 30

  # Accessing the index is also possible:
  for i, (x, c) in a:
    echo i, c
  # This will output: 0a; 1b; 2c
  ```
{==+==}
  ```nim  test = "nim c $1"
  let a = [(10, 'a'), (20, 'b'), (30, 'c')]

  for (x, c) in a:
    echo x
  # 这将输出: 10; 20; 30

  # Accessing the index is also possible:
  for i, (x, c) in a:
    echo i, c
  # 这将输出: 0a; 1b; 2c
  ```
{==+==}

{==+==}
Fields of tuples are always public, they don't need to be explicitly
marked to be exported, unlike for example fields in an object type.
{==+==}
元组的字段始终是公开的，它们不需要显式标记为导出，这与对象类型中的字段不同。
{==+==}


{==+==}
Reference and pointer types
---------------------------
{==+==}
引用和指针类型
----------------------------
{==+==}

{==+==}
References (similar to pointers in other programming languages) are a
way to introduce many-to-one relationships. This means different references can
point to and modify the same location in memory.
{==+==}
引用(类似于其他编程语言中的指针)是一种引入多对一关系的方法。
这意味着不同的引用可以指向和修改内存中的相同位置。
{==+==}

{==+==}
Nim distinguishes between `traced`:idx: and `untraced`:idx: references.
Untraced references are also called *pointers*. Traced references point to
objects in a garbage-collected heap, untraced references point to
manually allocated objects or objects elsewhere in memory. Thus,
untraced references are *unsafe*. However, for certain low-level operations
(e.g. accessing the hardware), untraced references are necessary.
{==+==}
Nim 区分 `traced`:idx: 和 `untraced`:idx: 引用。未跟踪的引用也称为*指针*。
跟踪的引用指向会被垃圾收集的堆中的对象，未跟踪的引用指向手动分配的对象或内存中其他地方的对象。
因此，未跟踪的引用是*不安全的*。但是，对于某些低级操作(如访问硬件)，未跟踪的引用是必要的。
{==+==}

{==+==}
Traced references are declared with the **ref** keyword; untraced references
are declared with the **ptr** keyword.
{==+==}
跟踪引用使用 **ref** 关键字声明; 未跟踪的引用使用 **ptr** 关键字声明。
{==+==}

{==+==}
The empty `[]` subscript notation can be used to *de-refer* a reference,
meaning to retrieve the item the reference points to. The `.` (access a
tuple/object field operator) and `[]` (array/string/sequence index operator)
operators perform implicit dereferencing operations for reference types:
{==+==}
空的 `[]` 下标符号可用于*解除*一个引用，这意味着检索引用指向的实例。
`.` (访问元组 / 对象字段)和 `[]`(数组 / 字符串 / 序列索引)运算符对引用类型隐式解引用:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    Node = ref object
      le, ri: Node
      data: int

  var n = Node(data: 9)
  echo n.data
  # no need to write n[].data; in fact n[].data is highly discouraged!
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    Node = ref object
      le, ri: Node
      data: int

  var n = Node(data: 9)
  echo n.data
  # 不需要去写 n[].data; 实际上写 n[].data 是极其不建议的!
  ```
{==+==}

{==+==}
To allocate a new traced object, the built-in procedure `new` can be used:
{==+==}
要分配一个新的跟踪对象，可以使用内置过程 `new`:
{==+==}

{==+==}
  ```nim
  var n: Node
  new(n)
  ```
{==+==}
  ```nim
  var n: Node
  new(n)
  ```
{==+==}

{==+==}
To deal with untraced memory, the procedures `alloc`, `dealloc` and
`realloc` can be used. The [system](system.html)
module's documentation contains further details.
{==+==}
可以用 `alloc`, `dealloc` 和 `realloc` 来处理不跟踪的内存。
[system](system.html) 模块中的文档包含更多细节。
{==+==}

{==+==}
If a reference points to *nothing*, it has the value `nil`.
{==+==}
如果一个引用*什么都没有*指向，其值为 `nil`。
{==+==}


{==+==}
Procedural type
---------------
{==+==}
程序类型
---------------
{==+==}

{==+==}
A procedural type is a (somewhat abstract) pointer to a procedure.
`nil` is an allowed value for a variable of a procedural type.
Nim uses procedural types to achieve `functional`:idx: programming
techniques.
{==+==}
过程类型是指向过程的(些许抽象的)指针。过程类型变量的值允许为 `nil`。
Nim 使用过程类型来实现 `functional`:idx: 编程技术。
{==+==}

{==+==}
Example:
{==+==}
例:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc greet(name: string): string =
    "Hello, " & name & "!"

  proc bye(name: string): string =
    "Goodbye, " & name & "."

  proc communicate(greeting: proc (x: string): string, name: string) =
    echo greeting(name)

  communicate(greet, "John")
  communicate(bye, "Mary")
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc greet(name: string): string =
    "Hello, " & name & "!"

  proc bye(name: string): string =
    "Goodbye, " & name & "."

  proc communicate(greeting: proc (x: string): string, name: string) =
    echo greeting(name)

  communicate(greet, "John")
  communicate(bye, "Mary")
  ```
{==+==}

{==+==}
A subtle issue with procedural types is that the calling convention of the
procedure influences the type compatibility: procedural types are only compatible
if they have the same calling convention. The different calling conventions are
listed in the [manual](manual.html#types-procedural-type).
{==+==}
过程类型的一个微妙问题是过程的调用约定会影响类型兼容性: 过程类型只有在它们具有相同的调用约定时才兼容。
[手册](manual.html#types-procedural-type) 中列出了不同的调用约定。
{==+==}

{==+==}
Distinct type
-------------
{==+==}
Distinct 类型
----------------
{==+==}

{==+==}
A Distinct type allows for the creation of a new type that "does not imply a
subtype relationship between it and its base type".
You must **explicitly** define all behavior for the distinct type.
To help with this, both the distinct type and its base type can cast from one
type to the other.
Examples are provided in the [manual](manual.html#types-distinct-type).
{==+==}
Distinct 类型允许创建"不隐式与其基本类型之间存在子类型关系"的新类型。
你必须**明确**定义 distinct 类型的所有行为。为减轻这个问题，distinct 类型及其基类型
之间可以相互转换。
[手册](manual.html#types-distinct-type) 中提供了示例。
{==+==}

{==+==}
Modules
=======
{==+==}
模块
========
{==+==}

{==+==}
Nim supports splitting a program into pieces with a *module* concept.
Each module is in its own file. Modules enable `information hiding`:idx: and
`separate compilation`:idx:. A module may gain access to the symbols of another
module by using the `import`:idx: statement. Only top-level symbols that are marked
with an asterisk (`*`) are exported:
{==+==}
Nim 支持使用*模块*概念将程序拆分为多个部分。每个模块都在自己的文件中。
模块启用 `information hiding`:idx: 和 `separate compilation`:idx:。
一个模块可以通过使用 `import`:idx: 语句来访问另一个模块的符号。
只有标有星号 (`*`) 的顶级符号会被导出:
{==+==}

{==+==}
  ```nim
  # Module A
  var
    x*, y: int

  proc `*` *(a, b: seq[int]): seq[int] =
    # allocate a new sequence:
    newSeq(result, len(a))
    # multiply two int sequences:
    for i in 0 ..< len(a): result[i] = a[i] * b[i]

  when isMainModule:
    # test the new `*` operator for sequences:
    assert(@[1, 2, 3] * @[1, 2, 3] == @[1, 4, 9])
  ```
{==+==}
  ```nim
  # 模块 A
  var
    x*, y: int

  proc `*` *(a, b: seq[int]): seq[int] =
    # 分配一个新切片:
    newSeq(result, len(a))
    # 两个 int 切片相乘:
    for i in 0 ..< len(a): result[i] = a[i] * b[i]

  when isMainModule:
    # 测试切片的新运算符 `*`:
    assert(@[1, 2, 3] * @[1, 2, 3] == @[1, 4, 9])
  ```
{==+==}

{==+==}
The above module exports `x` and `*`, but not `y`.
{==+==}
上面的模块导出了 `x` 和 `*`，但没有导出 `y`。
{==+==}

{==+==}
A module's top-level statements are executed at the start of the program.
This can be used to initialize complex data structures for example.
{==+==}
模块的顶级语句会在程序开始时执行。例如，这可用于初始化复杂的数据结构。
{==+==}

{==+==}
Each module has a special magic constant `isMainModule` that is true if the
module is compiled as the main file. This is very useful to embed tests within
the module as shown by the above example.
{==+==}
每个模块都有一个特殊的魔术常量 `isMainModule`，如果该模块被当做主文件编译，则该常量为真。
如上例所示，这对于在模块中嵌入测试非常有用。
{==+==}

{==+==}
A symbol of a module *can* be *qualified* with the `module.symbol` syntax. And if
a symbol is ambiguous, it *must* be qualified. A symbol is ambiguous
if it is defined in two (or more) different modules and both modules are
imported by a third one:
{==+==}
模块的符号*可以*使用 `module.symbol` 语法*限定*。如果一个符号是模棱两可的，
则它*必须*能被明确指出。当符号在两个(或多个)不同的模块中定义并且这两个模块都由第三个模块导入时，
该符号是模棱两可的:
{==+==}

{==+==}
  ```nim
  # Module A
  var x*: string
  ```
{==+==}
  ```nim
  # 模块 A
  var x*: string
  ```
{==+==}

{==+==}
  ```nim
  # Module B
  var x*: int
  ```
{==+==}
  ```nim
  # 模块 B
  var x*: int
  ```
{==+==}

{==+==}
  ```nim
  # Module C
  import A, B
  write(stdout, x) # error: x is ambiguous
  write(stdout, A.x) # okay: qualifier used

  var x = 4
  write(stdout, x) # not ambiguous: uses the module C's x
  ```
{==+==}
  ```nim
  # 模块 C
  import A, B
  write(stdout, x) # 错误: 不知道是哪个 x
  write(stdout, A.x) # 可以: 更明确地使用

  var x = 4
  write(stdout, x) # 无语义不清: 会使用模块 C 的 x
  ```
{==+==}


{==+==}
But this rule does not apply to procedures or iterators. Here the overloading
rules apply:
{==+==}
但这条规则不适用于过程或迭代器。这种情况适用于重载规则:
{==+==}

{==+==}
  ```nim
  # Module A
  proc x*(a: int): string = $a
  ```
{==+==}
  ```nim
  # 模块 A
  proc x*(a: int): string = $a
  ```
{==+==}

{==+==}
  ```nim
  # Module B
  proc x*(a: string): string = $a
  ```
{==+==}
  ```nim
  # 模块 B
  proc x*(a: string): string = $a
  ```
{==+==}

{==+==}
  ```nim
  # Module C
  import A, B
  write(stdout, x(3))   # no error: A.x is called
  write(stdout, x(""))  # no error: B.x is called

  proc x*(a: int): string = discard
  write(stdout, x(3))   # ambiguous: which `x` is to call?
  ```
{==+==}
  ```nim
  # 模块 C
  import A, B
  write(stdout, x(3))   # 没有错误: A.x 被调用
  write(stdout, x(""))  # 没有错误: B.x 被调用

  proc x*(a: int): string = discard
  write(stdout, x(3))   # 语义不清: 要调用哪个 `x` ?
  ```
{==+==}


{==+==}
Excluding symbols
-----------------
{==+==}
排除符号
-----------------
{==+==}

{==+==}
The normal `import` statement will bring in all exported symbols.
These can be limited by naming symbols that should be excluded using
the `except` qualifier.
{==+==}
一般的 `import` 语句将引入所有导出的符号。
导入的符号可再用 `except` 标识符排除。
{==+==}

{==+==}
  ```nim
  import mymodule except y
  ```
{==+==}
  ```nim
  import mymodule except y
  ```
{==+==}


{==+==}
From statement
--------------
{==+==}
From 语句
------------------
{==+==}

{==+==}
We have already seen the simple `import` statement that just imports all
exported symbols. An alternative that only imports listed symbols is the
`from import` statement:
{==+==}
我们已经见识了简单的 `import` 语句，它只导入所有导出的符号。
若仅想导入列出的符号则可用 `from import` 语句来代替:
{==+==}

{==+==}
  ```nim
  from mymodule import x, y, z
  ```
{==+==}
  ```nim
  from mymodule import x, y, z
  ```
{==+==}

{==+==}
The `from` statement can also force namespace qualification on
symbols, thereby making symbols available, but needing to be qualified
in order to be used.
{==+==}
`from` 语句还可以强制对符号进行命名空间限定，从而使符号必须经过限定后才可用。
{==+==}

{==+==}
  ```nim
  from mymodule import x, y, z

  x()           # use x without any qualification
  ```
{==+==}
  ```nim
  from mymodule import x, y, z

  x()           # 不指定模块名而直接使用 x
  ```
{==+==}

{==+==}
  ```nim
  from mymodule import nil

  mymodule.x()  # must qualify x with the module name as prefix

  x()           # using x here without qualification is a compile error
  ```
{==+==}
  ```nim
  from mymodule import nil

  mymodule.x()  # 必须通过将模块名作为前缀来明确指定 x

  x()           # 在这里不加限定地使用 x 是一个编译错误
  ```
{==+==}

{==+==}
Since module names are generally long to be descriptive, you can also
define a shorter alias to use when qualifying symbols.
{==+==}
模块名通常会为了便于描述而写得很长，因此你还可以定义一个较短的别名以在限定符号时使用。
{==+==}

{==+==}
  ```nim
  from mymodule as m import nil

  m.x()         # m is aliasing mymodule
  ```
{==+==}
  ```nim
  from mymodule as m import nil

  m.x()         # m 是 mymodule 的别名
  ```
{==+==}


{==+==}
Include statement
-----------------
{==+==}
Include 语句
----------------------
{==+==}

{==+==}
The `include` statement does something fundamentally different than
importing a module: it merely includes the contents of a file. The `include`
statement is useful to split up a large module into several files:
{==+==}
`include` 语句做的事情和导入一个模块有着基本的不同: `include` 仅包含进一个文件。
`include` 语句在将一个模块拆分成多个文件时很有用:
{==+==}

{==+==}
  ```nim
  include fileA, fileB, fileC
  ```
{==+==}
  ```nim
  include fileA, fileB, fileC
  ```
{==+==}



{==+==}
Part 2
======
{==+==}
第二部分
================
{==+==}

{==+==}
So, now that we are done with the basics, let's see what Nim offers apart
from a nice syntax for procedural programming: [Part II](tut2.html)
{==+==}
好了，现在我们完成了基础，让我们看看 Nim 除了为程序化编程提供良好语法外
还提供了什么: [第 II 部分](tut2.html)
{==+==}


{==+==}
.. _strutils: strutils.html
.. _system: system.html
{==+==}
.. _strutils: strutils.html
.. _system: system.html
{==+==}
