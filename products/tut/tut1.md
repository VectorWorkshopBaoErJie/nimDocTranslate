==============================
Nim 教程 (第 I 部分)
==============================

:Author: Andreas Rumpf
:Version: |nimversion|

.. default-role:: code
.. include:: rstcommon.rst
.. contents::

引言
============

>  "Der Mensch ist doch ein Augentier -- Schöne Dinge wünsch' ich mir."


本文是 *Nim* 编程语言教程。

本教程假定你熟悉基本的编程概念，如变量、类型及语句。

此处还有其他几份资料可供以学习 Nim:

* [Nim 基础教程](https://narimiran.github.io/nim-basics/) - 对上述概念的
  简单介绍
* [五分钟速通 Nim](https://learnxinyminutes.com/docs/nim/) - 对 Nim 的五分钟
  快速介绍
* [Nim 手册](manual.html) - 更多语言高级特性的例子

此教程中的所有代码样例，包括其余 Nim 文档中的，均遵循[Nim 代码风格指南](nep1.html)。


第一个程序
=================

我们将以一个修改过的 "hello world" 程序开启旅途。

  ```Nim  test = "nim c $1"
  # This is a comment
  echo "What's your name? "
  var name: string = readLine(stdin)
  echo "Hi, ", name, "!"
  ```


将代码保存在文件"greetings.nim"中。现在编译运行它::

  nim compile --run greetings.nim

通过 ``--run`` [开关](nimc.html#compiler-usage-commandminusline-switches)，Nim 
将在编译完成后自动执行该文件。你可以使用在文件名后面追加的方式来为程序提供命令行参数::

  nim compile --run greetings.nim arg1 arg2

常用指令和开关有简写，所以你也可以用::

  nim c -r greetings.nim

这是 **调试版本**。
为编译成发行版需用::

  nim c -d:release greetings.nim

默认情况下，为了让你调试时更轻松，Nim 编译器会产生大量的运行时检查。
通过 ``-d:release``，一些检查会被[关闭，优化将被打开](
nimc.html#compiler-usage-compileminustime-symbols)。

为了基准测试或能投产的代码，请使用 ``-d:release`` 开关。
为了与像 C 一样的不安全语言做性能上的比较，请使用 ``-d:danger`` 开关来获得有意义，
可比较的结果。否则，Nim 可能会因为一些在 C 中 **甚至不可行的** 检查而显得低能。

尽管程序做了什么应该已经十分明显了，但我还是要解释这种语法: 没有缩进的语句将在程序开始的时候被
执行。缩进是 Nim 用于给语句分组的一种方式。缩进只能由空格符来完成，制表符是不被允许的。

字符串字面量会被双引号括起来。`var` 语句声明了一个名称为 `name`，类型为 `string`，
值为 [readLine](syncio.html#readLine,File) 过程的返回值的变量。由于编译器知道
[readLine](syncio.html#readLine,File)返回一个字符串，你可以在声明中省略类型
(这被称作 `local type inference`:idx:)。所以下面这样也能正常工作:

  ```Nim  test = "nim c $1"
  var name = readLine(stdin)
  ```

注意这基本是 Nim 中唯一存在的类型推断的形式: 这是简洁和可读性之间的一个很好的折中。

"hello world" 程序包含一些编译器已知的标识符: `echo`, [readLine](syncio.html#readLine,File) 等。
这些内置的标识符声明在被其他模块隐式导入的 [system](system.html) 模块中。


词法元素
=================

让我们来仔细地看一下 Nim 的词法元素: 就像其他编程语言, Nim 由 (字符串) 字词，
标识符，关键字，注释，运算符和其他标点符号构成。


字符串和字符字面量
---------------------------------------

字符串字面量被双引号括起来; 字符在单引号中。特殊字符可被 ``\`` 转义: 
``\n`` 表示新的一行, ``\t`` 表示制表符，等等。同样，也有*原始*字符串字面量:

  ```Nim
  r"C:\program files\nim"
  ```

在原始字面量中，反斜杠不是转义字符。

第三种，也是最后一种书写字符串字面量的方法是通过*长字符串字面量*。
它们通过三对双引号写出: `""" ... """`; 它们可以跨越多行且 ``\`` 也不是
转义字符。例如，它们在嵌入 HTML 代码的时候非常有用。


注释
--------

注释以哈希字符 `#` 开头，出现在除字符串或字符字面量以外的任何地方。
文档注释以 `##` 开头:

  ```nim  test = "nim c $1"
  # A comment.

  var myVariable: int ## a documentation comment
  ```


文档注释是 tokens; 因为它们属于语法树，所以它们只被允许出现在输入文件的特定地方!
此功能支持更简单的文档生成器。

多行注释以 `#[` 开头并以 `#]` 结尾。多行注释也允许嵌套。

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


数字
--------

数字字面量的书写和其他大多数语言一样。下划线，作为一种特殊的转折，被允许用以提高
可读性: `1_000_000` (一百万)。包含小数点的 (或 'e' 或 'E') 是浮点数字面量:
`1.0e9` (一亿)。十六进制的字面量以 `0x` 开头，二进制的字面量以 `0b` 开头，
而八进制字面量以 `0o` 开头。只以一个零开头不会产生一个八进制数。


var 语句
=================
var 语句声明一个新的局部或全局变量:

  ```nim
  var x, y: int # declares x and y to have the type `int`
  ```

可以在关键字 `var` 后用缩进列出一整个部分的变量:

  ```nim  test = "nim c $1"
  var
    x, y: int
    # a comment can occur here too
    a, b, c: string
  ```


常量
=========

常量是绑定了值的符号。常量的值不能改变。编译器必须能够在编译时计算常量表达式的值:

  ```nim  test = "nim c $1"
  const x = "abc" # the constant x contains the string "abc"
  ```

可以在关键字 `const` 后用缩进列出一整个部分的常量:

  ```nim  test = "nim c $1"
  const
    x = 1
    # a comment can occur here too
    y = 2
    z = y + 5 # computations are possible
  ```


let 语句
======================
`let` 语句像 `var` 语句一样发挥作用，但其声明的符号是*一次性赋值*的变量:
初始化后它们的值不能被改变:

  ```nim
  let x = "abc" # introduces a new variable `x` and binds a value to it
  x = "xyz"     # Illegal: assignment to `x`
  ```

`let` 和 `const` 之间的不同: `let` 引入了一个不能被重新赋值的变量，
`const` 意味着"强制编译时评估并把它放到数据段":

  ```nim
  const input = readLine(stdin) # Error: constant expression expected
  ```

  ```nim  test = "nim c $1"
  let input = readLine(stdin)   # works
  ```


赋值语句
========================

赋值语句将一个新值赋到一个变量，或更一般的，分配到一个存储位置:

  ```nim
  var x = "abc" # introduces a new variable `x` and assigns a value to it
  x = "xyz"     # assigns a new value to `x`
  ```

`=` 是*赋值运算符*。赋值运算符是可以被重载的。你可以通过
单个赋值运算符来声明多个变量，而所有变量将拥有同样的值。

  ```nim  test = "nim c $1"
  var x, y = 3  # assigns 3 to the variables `x` and `y`
  echo "x ", x  # outputs "x 3"
  echo "y ", y  # outputs "y 3"
  x = 42        # changes `x` to 42 without changing `y`
  echo "x ", x  # outputs "x 42"
  echo "y ", y  # outputs "y 3"
  ```


控制流语句
=======================

欢迎程序由 3 条依次执行的语句组成。
只有最原始的程序才能解决这个问题: 分支和循环也是需要的。


If 语句
-----------------

if 语句是在控制流创建分支的一种方式:

  ```nim  test = "nim c $1"
  let name = readLine(stdin)
  if name == "":
    echo "Poor soul, you lost your name?"
  elif name == "name":
    echo "Very funny, your name is name."
  else:
    echo "Hi, ", name, "!"
  ```

这里可以有零个或更多 `elif` 分支，而 `else` 分支是可选的。
`elif` 关键字比 `else if` 短，且有助于避免过度缩进。
(`""` 是空字符串。它不包含字符。)


Case 语句
--------------

另一种创建分支的方式是通过 case 语句提供的。一个 case 语句运行多个分支:

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

可以看出，对于 `of` 分支，可以用逗号分隔值。

case 语句可以处理整数，其他序数类型，以及字符串。
(什么是序数类型马上解释。)
整数和其他序数类型的值区间也是可以的:

  ```nim
  # this statement will be explained later:
  from std/strutils import parseInt

  echo "A number please: "
  let n = parseInt(readLine(stdin))
  case n
  of 0..2, 4..7: echo "The number is in the set: {0, 1, 2, 4, 5, 6, 7}"
  of 3, 8: echo "The number is 3 or 8"
  ```

然而，上面的代码**不能编译**: 因为你需要考虑 `n` 可能取到的所有值，但代码只处理了 `0..8`。
因为列出所有值并不十分现实(尽管多亏了范围表达式这有可能实现)，我们通过告诉编译器所有其他值
不做任何事来处理这个情况:

  ```nim
  ...
  case n
  of 0..2, 4..7: echo "The number is in the set: {0, 1, 2, 4, 5, 6, 7}"
  of 3, 8: echo "The number is 3 or 8"
  else: discard
  ```

空[discard 语句]是一个*不做任何事*的语句。编译器知道含有 else 部分的 case 表达式
不会失败因此错误消失了。注意，处理所有字符串值是不可能的: 这也是为什么字符串的 case 语句
总是需要一个 `else` 分支。

通常，case 语句对于处理范围类型和枚举非常有用，因为编译器会检查你是否考虑了所有可能的值。


While 语句
---------------

while 语句是一个简单的循环结构:

  ```nim  test = "nim c $1"
  echo "What's your name? "
  var name = readLine(stdin)
  while name == "":
    echo "Please tell me your name: "
    name = readLine(stdin) # no `var`, because we do not declare a new variable here
  ```

在这个例子中，只要用户什么都不输入(只敲回车键), while 循环就会一直询问用户的名字。


For 语句
-------------

`for` 语句是一个循环遍历*迭代器*提供元素的结构。该示例使用内置的 [countup](
system.html#countup.i,T,T,Positive) 迭代器:

  ```nim  test = "nim c $1"
  echo "Counting to ten: "
  for i in countup(1, 10):
    echo i
  # --> Outputs 1 2 3 4 5 6 7 8 9 10 on different lines
  ```

变量 `i` 由 `for` 循环隐式声明且类型为 `int`，因为这就是 [countup](
system.html#countup.i,T,T,Positive) 返回的类型。`i` 遍历 1, 2, .., 10。
每个值都被 `echo`-ed. 这段代码等效于:

  ```nim
  echo "Counting to 10: "
  var i = 1
  while i <= 10:
    echo i
    inc i # increment i by 1
  # --> Outputs 1 2 3 4 5 6 7 8 9 10 on different lines
  ```

因为计数在程序中使用的很频繁，Nim 也提供了 [..](
system.html#...i,T,T) 迭代器来做相同的事情:

  ```nim
  for i in 1 .. 10:
    ...
  ```

实现倒计数也容易(但不太需要):

  ```nim
  echo "Counting down from 10 to 1: "
  for i in countdown(10, 1):
    echo i
  # --> Outputs 10 9 8 7 6 5 4 3 2 1 on different lines
  ```

从零开始的计数有两种简写 `..<` 和 `.. ^1`
([后向索引运算符](system.html#^.t%2Cint))，来简化数到
比最高下标少一:

  ```nim
  for i in 0 ..< 10:
    ...  # the same as 0 .. 9
  ```

或者

  ```nim
  var s = "some string"
  for i in 0 ..< s.len:
    ...
  ```

或者

  ```nim
  var s = "some string"
  for idx, c in s[0 .. ^1]:
    ... # ^1 is the last element, ^2 would be one before it, and so on
  ```

其他有助力于集合(比如数组和切片)的迭代器是
* `items` 和 `mitems`， 他们分别提供不可变和可变元素，而
* `pairs` 和 `mpairs` 提供了配对的元素和它们下标(分别为不可变和可变)

  ```nim  test = "nim c $1"
  for index, item in ["a","b"].pairs:
    echo item, " at index ", index
  # => a at index 0
  # => b at index 1
  ```

作用域和 block 语句
------------------------------------------------

控制流语句有一个未显露的特性: 他们打开了一个新的作用域。
这意味着接下来的例子中，`x` 在循环外不可访问:

  ```nim  test = "nim c $1"  status = 1
  while false:
    var x = "hi"
  echo x # does not work
  ```

while (for) 语句引入了一个隐式的块。变量只有在它们被声明的块中可见。
`block` 语句可以显式地打开一个新的块:

  ```nim  test = "nim c $1"  status = 1
  block myblock:
    var x = "hi"
  echo x # does not work either
  ```

块的*标签*(在这个例子中是 `myblock`)是可选的。


Break 语句
--------------------

使用 `break` 语句可以提早离开一个块。break 语句可以离开 `while`, `for` 或一个 `block` 语句。
除非给出块的标签，否则它会离开最里面的结构:

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


Continue 语句
-----------------------

类似其他许多编程语言，一个 `continue` 语句会立即开启下一轮迭代:

  ```nim  test = "nim c $1"
  for i in 1 .. 5:
    if i <= 3: continue
    echo i # will only print 4 and 5
  ```


When 语句
------------------

例:

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

`when` 语句几乎和 `if` 语句相同，但在以下有所差异:

* 因为每种情况都会被编译器评估，所以其必须是个常量表达式。
* 分支中的语句不会开启新作用域。
* 编译器会检查语义并且*只*为第一个评估为 `true` 的情况生成代码。

与 C语言 中的 `#ifdef`:c: 相似，`when` 语句在编写针对特定平台的代码时十分有用。


语句和缩进
==========================

至此我们介绍了基本的控制流语句，现在让我们回到 Nim 的缩进规则。

在 Nim 中，*简单语句*与*复杂语句*有别。*简单语句*不能包含其他语句:
赋值、过程调用或 `return` 语句都是简单语句。*复杂的语句*如 `if`, 
`when`, `for`, `while` 可以包含其他语句。为避免歧义，复杂语句必须
始终缩进，但单个简单语句不用:

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


*表达式*是语句的一部分，通常会产生一个值。if 语句中的条件就是个例子。
表达式可以在某些位置包含缩进以提高可读性:

  ```nim
  if thisIsaLongCondition() and
      thisIsAnotherLongCondition(1,
         2, 3, 4):
    x = true
  ```

根据经验，允许在运算符、左括号和逗号之后表达式内缩进。

凭借括号和分号 `(;)`，你可使用只允许使用表达式的语句:

  ```nim  test = "nim c $1"
  # computes fac(4) at compile time:
  const fac4 = (var x = 1; for i in 1..4: x *= i; x)
  ```


过程
==========

要在示例中定义像 [echo](system.html#echo,varargs[typed,])
和 [readLine](syncio.html#readLine,File) 这样的新命令，需要*过程*的概念。 
你可能习惯在其他语言中将它们称为*方法*或*函数*，但 Nim 将
[区分这些概念](tut1.html#procedures-funcs-and-methods)。
在 Nim 中，新过程是使用 `proc` 关键字定义的:

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

这个例子展示了一个名为 `yes` 的过程，它询问用户一个 `question`，
若他们回答 "yes" (或类似的东西)，返回 true，若他们回答 "no"
(或类似的东西)，返回 false。 `return` 语句将立即离开过程(因此也离开了 while 循环)。
`(question: string): bool` 语法表明过程需要一个名为 `question` 的 `string` 类型的参数
并返回 `bool` 类型的值。`bool` 类型是内置的: `bool` 的唯一有效值是 `true` 和 `false`。
if 和 while 语句中的条件必须是 `bool` 类型。

一些术语: 在示例中，`question` 被称为(正式的)*参数*， `"Should I..."`
被称为传递给此参数的*实参*。


Result 变量
-------------------

有返回值过程有一个隐式声明，即代表返回值的 `result` 变量。没跟表达式的 `return` 语句
是 `return result` 简写。过程结尾退出时如果没有 `return` 语句，`result` 值将被自动返回。

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

`result` 变量已经在函数开头隐式声明，因此，例如，用 'var result' 再次声明会用同名的普通变量遮蔽它。
result 变量也已经使用类型的默认值进行了初始化。注意，引用数据类型在过程开始时将是 "nil"，因此可能需要手动初始化。

不使用 `return` 语句和不使用特殊变量 `result` 的过程将返回它最后一个表达式的值。
例如这个过程

  ```nim  test = "nim c $1"
  proc helloWorld(): string =
    "Hello, World!"
  ```

返回字符串 "Hello, World"。

参数
----------

参数在过程中是不可变的。默认情况下，他们的值不可改变，因为这允许编译器更高效地实现参数的传递。
如果在过程中需要一个可变的变量，它应该在过程中以 `var` 来声明。遮蔽参数名称是可能的，实际上
这是惯用法:

  ```nim  test = "nim c $1"
  proc printSeq(s: seq, nprinted: int = -1) =
    var nprinted = if nprinted == -1: s.len else: min(nprinted, s.len)
    for i in 0 ..< nprinted:
      echo s[i]
  ```

如果过程需要修改调用者的参数，可使用 `var` 参数:

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

在这个例子中，`res` 和 `remainder` 是 `var parameters`。
Var 参数可以被过程修改且该修改调用者可知。注意上面的例子最好用元组作为返回值而不是使用 var 参数。


Discard 语句
---------------------

调用仅需要其副作用而非返回值并忽略其返回值的过程，**必须**使用`discard`语句。
Nim 不允许默默地丢弃返回值:

  ```nim
  discard yes("May I ask a pointless question?")
  ```


如果调用的过程 / 迭代器通过 `discardable` 编译指示声明，返回值可以被隐式地忽略:

  ```nim  test = "nim c $1"
  proc p(x, y: int): int {.discardable.} =
    return x + y

  p(3, 4) # now valid
  ```


具名参数
----------------

通常一个过程有许多参数，但参数出现的顺序是不清楚的。尤其是在构建一个复杂数据类型时。
因此，传给过程的参数可以具名，由此参数属于哪个形参就清楚了:

  ```nim
  proc createWindow(x, y, width, height: int; title: string;
                    show: bool): Window =
     ...

  var w = createWindow(show = true, title = "My Application",
                       x = 0, y = 0, height = 600, width = 800)
  ```

注意我们使用具名参数调用 `createWindow`，参数的顺序不再重要。混合使用具名参数和按顺序的参数
也是可能的，但可读性很差。

  ```nim
  var w = createWindow(0, 0, title = "My Application",
                       height = 600, width = 800, true)
  ```

编译器检查每个形参是否只接收一个参数。


默认值
--------------

为了使 `createWindow` 过程更易用，应提供 `default values`;
如果调用者未指定这些参数，则用这些值作参数:

  ```nim
  proc createWindow(x = 0, y = 0, width = 500, height = 700,
                    title = "unknown",
                    show = true): Window =
     ...

  var w = createWindow(title = "My Application", height = 600, width = 800)
  ```

现在调用 `createWindow` 只需要设置与默认值不同的参数即可。

注意，类型推断适用于具有默认值的参数; 例如，不需要写 `title: string = "unknown"`。


过程重载
---------------------

Nim 提供了类似 C++ 的过程重载能力:

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

(注意在 Nim 中，`toString` 经常为 [$](dollars.html) 运算符)
编译器选择最合适的过程来处理 `toString` 调用。在此不讨论这种重载解析算法是如何工作的 -- 详情请见手册。
模棱两可的调用被报告为错误。


运算符
------------

Nim 标准库大量使用重载 - 原因之一是每个像 `+` 这样的运算符都只是一个重载的过程。
解析器允许你在*中缀符号* (`a + b`) 或 *前缀符号* (`+ a`) 中使用运算符。
一个中缀运算符通常接收两个参数，一个前缀运算符通常接收一个。
(后缀运算符是不可能的，因为这会模糊语义: `a @ @ b` 是指 `(a) @ (@b)`
还是 `(a@) @ (b)`? 这通常指 `(a) @ (@b)`，因为在 Nim 中没有后缀运算符。)

除了一些内置的关键字运算符，如 `and`, `or`, `not`,
运算符总是由这些字符组成:
`+  -  *  \  /  <  >  =  @  $  ~  &  %  !  ?  ^  .  |`

允许使用用户定义的运算符。没有什么能阻止你定义自己的 `@!?+~` 运算符，
但这样做可能会降低可读性。

运算符的优先级由其第一个字符确定。详情可以[在手册中找到](manual.html#syntax-precedence)。

要定义一个新的运算符，请将运算符括在反引号 "`" 中:

  ```nim
  proc `$` (x: myDataType): string = ...
  # now the $ operator also works with myDataType, overloading resolution
  # ensures that $ works for built-in types just like before
  ```

"`" 符号也可以像任何其他过程一样用于调用运算符:

  ```nim  test = "nim c $1"
  if `==`( `+`(3, 4), 7): echo "true"
  ```


前置声明
--------------------

每个变量、过程等都需要先声明才能使用。(这样做的原因是，在像 Nim 一样广泛支持元编程
的语言中避免这种需求并非易事)但是，对于相互递归的过程不能这样做:

  ```nim
  # forward declaration:
  proc even(n: int): bool
  ```

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

这里的 `odd` 依赖 `even`，反之亦然。因此，在完全定义之前，需要将 `even` 引入编译器。
这种前置声明的语法很简单: 只需省略 `=` 和过程的主体。 `assert` 只添加了边界条件，
稍后会在[模块]部分介绍。

后续版本会弱化对前置声明的要求。

该示例还表明，proc 的主体可以由单个表达式组成，然后隐式返回其值。


Funcs 和 方法
-------------------------

正如介绍中提到的，Nim 区分过程、函数和方法，后者分别由 `proc`、`func` 和 `method` 关键字定义。
在某些方面，Nim 的定义比其他语言更迂腐。

函数更接近于纯数学函数的概念，如果你曾进行过函数式编程，你可能对它很熟悉。
本质上，它们是设置了额外限制的过程: 它们不能访问全局状态(`const` 除外)且不能产生副作用。
`func` 关键字基本上是用 `{.noSideEffects.}` 标记的 `proc` 的别名。
然而，函数仍然可以更改它们被标记为 `var` 的可变参数，以及任何 `ref` 对象。

与过程不同，方法是动态分派的。这听起来有点复杂，但它是一个与继承和面向对象编程密切相关的概念。
如果你重载一个过程(两个具有相同名称但类型不同或具有不同参数集的过程称为重载)，则要使用的过程在编译时确定。
另一方面，方法依赖于从 `RootObj` 继承的对象。
这在[本教程的第二部分](tut2.html#object-orienting-programming-dynamic-dispatch) 中有更深入的介绍。


迭代器
=================

让我们回到简单的计数示例:

  ```nim  test = "nim c $1"
  echo "Counting to ten: "
  for i in countup(1, 10):
    echo i
  ```

[countup](system.html#countup.i,T,T,Positive) 过程可以写的支持循环吗?
让我们试试:

  ```nim
  proc countup(a, b: int): int =
    var res = a
    while res <= b:
      return res
      inc(res)
  ```

但是，这不起作用。问题是该过程不应只 `return`，而应该在迭代完成后返回并**继续**。
*返回并继续*的语句被称为 `yield`。现在剩下要做的就是用 `iterator` 替换 `proc` 关键字，
这就是我们的第一个迭代器:

  ```nim  test = "nim c $1"
  iterator countup(a, b: int): int =
    var res = a
    while res <= b:
      yield res
      inc(res)
  ```

迭代器看起来与过程非常相似，但有几个重要区别:

* 迭代器只能在 for 循环中调用。
* 迭代器不能含有 `return` 语句。(相应的，过程中不能有 `yield` 语句)
* 迭代器没有隐式的 `result` 变量。
* 迭代器不支持递归。
* 迭代器不能前置声明，因为编译器必须能够内联一个迭代器。(这个限制将在未来版本的编译器中移除)

但是，你也可以使用闭包迭代器来获得一组不同的限制。
详情请见 [first-class iterators](
manual.html#iterators-and-the-for-statement-firstminusclass-iterators)。
迭代器可具有与过程相同的名称和参数，因为本质上它们具有自己的命名空间。因此，
通常将迭代器包装在同名的过程中，这些过程会累积迭代器的结果并将其作为序列返回，
例如 [strutils 模块](strutils.html) 中的 `split`。


基本类型
================

本节详细介绍了基本的内置类型及它们的可用操作。

布尔
--------

Nim 的布尔类型称为 `bool`，由两个预定义值 `true` 和 `false` 组成。
`while`, `if`,`elif` 和 `when` 语句中的条件必须是布尔类型。

运算符 `not, and, or, xor, <, <=, >, >=, !=, ==` 是为 bool 类型定义的。
`and` 和 `or` 运算符执行短路评估。例如:

  ```nim
  while p != nil and p.name != "xyz":
    # p.name is not evaluated if p == nil
    p = p.next
  ```


字符
----------

*字符类型*称为 `char`。它的大小始终为一个字节，因此它不能表示大多数 UTF-8 字符，
但它*可以*表示 UTF-8 字符中一个组成字节。这样做是为了效率: 对于绝大多数用例，
产生的程序仍将正确处理 UTF-8，因为 UTF-8 是专门为此设计的。字符字面量用单引号括起来。

字符可以用 `==`、`<`、`<=`、`>`、`>=` 运算符进行比较。`$` 运算符将 `char`
转换为 `string`。字符不能与整数混合; 要获取 `char` 的序数值，请使用 `ord` 过程。
使用 `chr` 过程完成从整数到 `char` 的转换。


字符串
------------

字符串变量是**可变的**，所以追加字符串是可能的，并且相当高效。
字符串在 Nim 中既以零为结尾，也有长度字段。一个字符串的长度可通过内置的 `len` 过程来获取;
长度永远不会计算结尾零。对结尾零的访问是个错误，它的存在只是为了 Nim 的字符串能够被零拷贝地
转换成 `cstring`。

字符串的赋值运算符将复制字符串。你可以使用 `&` 运算符连接字符串或使用 `add` 追加字符串。

字符串使用其字典顺序进行比较。支持所有比较运算符。按照惯例，所有字符串都是 UTF-8 编码的，
但这不是强制的。例如，从二进制文件中读取字符串时，它们只是一个字节序列。
索引操作 `s[i]` 表示 `s` 的第 i 个 *char*，而不是第i个 *unichar*。

字符串变量被初始化为空字符串 `""`。


整数
--------

Nim 有以下内置的整数类型:
`int int8 int16 int32 int64 uint uint8 uint16 uint32 uint64`.

默认整数类型是 `int`。整数字面量可以用*类型后置*来指定非默认的整数类型:


  ```nim  test = "nim c $1"
  let
    x = 0     # x is of type `int`
    y = 0'i8  # y is of type `int8`
    z = 0'i32 # z is of type `int32`
    u = 0'u   # u is of type `uint`
  ```

大多数情况下，整数用于计数驻留在内存中的对象，因此 `int` 与指针具有相同的大小。

常用运算符 `+ - * div mod < <= == != > >=` 是为整数定义的。 `and or xor not` 
运算符也为整数定义并提供*按位*运算。 左移使用 `shl` 完成，右移使用 `shr` 操作符。
位移位运算符始终将其参数视为 *unsigned*。 对于`算术位移`:idx: 可以使用普通的乘法或除法。

无符号操作都会回绕; 它们不会导致溢出或下溢错误。

无损 `Automatic type conversion`:idx: 在使用不同类型的整数类型表达式中执行。
然而，如果类型转换会导致信息丢失，则会引发 `RangeDefect`:idx: (前提是在编译时无法检测到错误)。


浮点数
------------

Nim 内置浮点类型: `float float32 float64`。

默认的浮点类型是 `float`。在当前实现中，`float` 是64位的。

浮点字面值可以有一个*类型后缀*来指定一个非默认的浮点类型:

  ```nim  test = "nim c $1"
  var
    x = 0.0      # x is of type `float`
    y = 0.0'f32  # y is of type `float32`
    z = 0.0'f64  # z is of type `float64`
  ```

常见的运算符 `+ - * / < <= == != > >=` 已为浮点数定义，并遵循 IEEE-754 标准。

在具有不同浮点类型的表达式中将自动执行类型转换: 较小的类型会转换为较大的类型。
整数类型**不会**自动转换为浮点类型，反之亦然。进行这些转换可用 [toInt](system.html#toInt,float)
和 [toFloat](system.html#toFloat,int) 过程。


类型转换
----------------

数值类型之间的转换是通过将类型用作函数来执行的:

  ```nim  test = "nim c $1"
  var
    x: int32 = 1.int32   # same as calling int32(1)
    y: int8  = int8('a') # 'a' == 97'i8
    z: float = 2.5       # int(2.5) rounds down to 2
    sum: int = int(x) + int(y) + int(z) # sum == 100
  ```


内部类型表示
============================

如前所述，内置的 [$](dollars.html) (stringify) 运算符将任意基本类型转为字符串，
然后你可以使用 `echo` 过程将其打印到控制台。但是，除非你为高级类型和你的自定义类型
进行定义，否则后者将不能与 `$` 运算符一起使用。你可以在只想调试复杂类型的当前值，
而不想编写其 `$` 运算符时，使用 [repr](system.html#repr,T) 过程，
它适用于任何类型，甚至是带有周期的复杂数据图。以下示例表明，即使对于基本类型，
`$` 和 `repr` 输出之间也存在差异:

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


高阶类型
================

在 Nim 中，新的类型可以通过 `type` 语句来定义:

  ```nim  test = "nim c $1"
  type
    biggestInt = int64      # biggest integer type that is available
    biggestFloat = float64  # biggest float type that is available
  ```

枚举和对象类型只能在 `type` 语句中定义。


枚举
------------

枚举类型的变量只能分配到其中某种枚举值。这些值是一组有序符号。每个符号在内部映射到一个整数值。
第一个符号在运行时用 0 表示，第二个用 1 表示，以此类推。例如:

  ```nim  test = "nim c $1"
  type
    Direction = enum
      north, east, south, west

  var x = south     # `x` is of type `Direction`; its value is `south`
  echo x            # prints "south"
  ```

所有比较运算符都可以与枚举类型一起使用。

可以限定枚举的符号以避免歧义: `Direction.south`。

`$` 运算符可以将任何枚举值转换为其名称，而 `ord` 过程可以将其转换为其底层整数值。

为了更好地与其他编程语言交互，可以为枚举类型的符号分配一个明确的序数值。
但是，序数值必须升序排列。


序数类型
----------------

枚举、整数类型、`char` 和 `bool` (以及子范围)称为序数类型。
序数类型有很多特殊操作:


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


[inc](system.html#inc,T,int), [dec](system.html#dec,T,int), [succ](
system.html#succ,T,int) 以及 [pred](system.html#pred,T,int) 运算在引发
`RangeDefect` 或 `OverflowDefect`. 时会失败。(当代码在恰当的运行时检查
被打开时时编译)


子范围
------------

子范围类型是来自整数或枚举类型(基本类型)的值范围。例:

  ```nim  test = "nim c $1"
  type
    MySubrange = range[0..5]
  ```


`MySubrange` 是 `int` 的子范围，它只能保存值 0 到 5。
将任何其他值分配给 `MySubrange` 类型的变量是编译时或运行时错误。
允许从基本类型分配到其某一子范围类型(反之亦然)。

`system` 模块将重要的 [Natural](system.html#Natural) 类型定义为
`range[0..high(int)]` ([high](system.html#high,typedesc[T]) 返回 最大值)。
其他编程语言可能建议对自然数使用无符号整数。这通常是**不明智的**: 
你不希望仅仅因为数字不能为负数而用无符号(会产生回绕)运算。Nim 的 `Natural` 类型有助于避免这种常见的编程错误。


集合
--------

.. include:: sets_fragment.txt

数组
--------

一个数组是一个简单，有固定长度的容器。数组中的每个元素类型相同。
数组的下标可以是任何序数类型。

可使用 `[]` 构造数组:

  ```nim  test = "nim c $1"
  type
    IntArray = array[0..5, int] # an array that is indexed with 0..5
  var
    x: IntArray
  x = [1, 2, 3, 4, 5, 6]
  for i in low(x) .. high(x):
    echo x[i]
  ```

符号 `x[i]` 用于访问 `x` 的第 i 个元素。数组访问总是进行边界检查(在编译时或运行时)。
这些检查可以通过编译指示或使用 ``--bound_checks:off`` 命令行开关调用编译器来禁用。

数组是值类型，就像任何其他 Nim 类型一样。赋值运算符将复制整个数组的内容。

内置的 [len] 过程返回数组的长度。[low(a)] 返回数组 `a` 最小的有效下标，而 [high(a)]
返回最大有效下标。

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

其他语言中创建嵌套(多维)数组的语法是添加更多括号，因为通常每个维度的索引类型都被限制成
与其他维度相同。在 Nim 中，你可以有不同维度和不同的索引类型，因此嵌套语法略有不同。
在上一个示例，level 被定义为一个把另一个枚举当做索引的枚举数组，我们可以添加以下行来
添加一个 LightTower 类型，该类型细分为通过其整数索引访问其高度的 LevelSetting:

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

注意内置的 `len` 过程是如何仅返回数组第一维长度的。定义 `LightTower`
以更好地说明其嵌套性质的另一种方法是省略之前对 `LevelSetting` 类型的定义，
并直接将其嵌入作为第一个维度的类型:

  ```nim
  type
    LightTower = array[1..10, array[north..west, BlinkLights]]
  ```

数组从零开始是很常见的，因此有一种快捷语法可以指定从零到指定索引减一的范围：

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


序列
---------

序列类似于数组，但其长度是动态的，在运行时可能会发生变化(如字符串)。
由于序列大小可调，它们总是分配在堆上并受垃圾回收。

序列总是用从 0 开始的 `int` 进行索引。[len](system.html#len,seq[T]), [low](
system.html#low,openArray[T]) 和 [high]( system.html#high,openArray[T])
操作也可用于序列。符号 `x[i]` 可用于访问 `x` 的第 i 个元素。

序列可由数组构造器 `[]` 与数组到序列运算符 `@` 一起构造。
为序列分配空间的另一种方法是调用内置的 [newSeq](system.html#newSeq) 过程。

序列可被传递给一个开放数组参数。

例:

  ```nim  test = "nim c $1"
  var
    x: seq[int] # a reference to a sequence of integers
  x = @[1, 2, 3, 4, 5, 6] # the @ turns the array into a sequence allocated on the heap
  ```

序列变量可用 `@[]` 初始化。

当与序列一起使用时，`for` 语句可以与一个或两个变量一起使用。当你使用单变量形式时，
变量将保存序列提供的值。`for` 语句循环遍历的结果来自 [system](system.html) 模块的
[items()](iterators.html#items.i,seq[T]) 迭代器。但是如果使用双变量形式，
第一个变量将保存索引位置，第二个变量将保存值。这里的 `for` 语句循环遍历结果来自
[system](system.html) 模块的 [pairs()](iterators.html#pairs.i,seq[T]) 迭代器。
例子:

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


开放数组
----------------

**注意**: 开放数组只能被用于参数。

通常，固定大小的数组非常不灵活。程序应该能够处理不同大小的数组。 `openarray`:idx: 类型允许这样做。
开放数组总是用从位置 0 到 `int` 进行索引。[len](system.html#len,TOpenArray), [low](
system.html#low,openArray[T]) 和 [high](system. html#high,openArray[T]) 操作也可用于开放数组。
任何具有兼容基类型的数组都可以传递给开放数组参数，索引类型无关紧要。

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

开放数组类型不能嵌套: 不支持多维开放数组，因为这需求很少且不能有效完成。


可变参数
----------------

`varargs` 参数类似于开放数组参数。但它也是一种将可变数量的参数传递给过程的方法。
编译器自动将参数列表转换为数组:

  ```nim  test = "nim c $1"
  proc myWriteln(f: File, a: varargs[string]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, "abc", "def", "xyz")
  # is transformed by the compiler to:
  myWriteln(stdout, ["abc", "def", "xyz"])
  ```

仅当 varargs 参数是过程标头中的最后一个参数时才进行此转换。在这种情况下也可执行类型转换:

  ```nim  test = "nim c $1"
  proc myWriteln(f: File, a: varargs[string, `$`]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, 123, "abc", 4.0)
  # is transformed by the compiler to:
  myWriteln(stdout, [$123, $"abc", $4.0])
  ```

在此示例中，[$](dollars.html) 将应用于传递给参数 `a` 的任何参数。请注意，应用于字符串的 [$](dollars.html) 是 nop。


切片
--------

切片在语法上看起来类似子范围类型，但被使用在不同的上下文中。切片只是一个切片类型的对象，
它包含两个边界，`a` 和 `b`。切片本身并不是很有用，但其他集合类型定义了接受切片对象来定义范围的运算符。

  ```nim  test = "nim c $1"
  var
    a = "Nim is a programming language"
    b = "Slices are useless."

  echo a[7 .. 12] # --> 'a prog'
  b[11 .. ^2] = "useful"
  echo b # --> 'Slices are useful.'
  ```

在之前的示例中，切片用于修改字符串的一部分。切片的边界可以保存任何其类型支持的值，
但其实是过程使用了定义了可接受值的切片对象。

要理解指定字符串、数组、序列等索引的不同方法，必须记住 Nim 使用从零开始的索引。

所以字符串 `b` 的长度为 19, 指定索引的两种不同方法是

  ```nim
  "Slices are useless."
   |          |     |
   0         11    17   using indices
  ^19        ^8    ^2   using ^ syntax
  ```

这里 `b[0 .. ^1]` 与 `b[0 .. b.len-1]` 和 `b[0 ..< b.len]` 等价，同时可以看到，`^1` 
提供了一种表示  `b.len-1` 的速记方法。请见[向后索引运算符](system.html#^.t%2Cint)。

在上面的例子中，因为字符串以句点结尾，要获取字符串的 "useless" 部分并将其替换为 "useful"。

`b[11 .. ^2]` 是 "useless" 部分，而 `b[11 .. ^2] = "useful"` 用 "useful"
替换了 "useless" 部分，使结果变成 "Slices are useful."

注 1: 其他的方式为 `b[^8 .. ^2] = "useful"` 或写成 `b[11 .. b.len-2] = "useful"`
或 `b[11 ..< b.len-1] = "useful"`。

注 2: 由于 `^` 模板返回类型为 [distinct int](manual.html#types-distinct-type) 即 `BackwardsIndex`，
我们可以定义一个 `lastIndex` 常量 `const lastIndex = ^1`，同时在之后使用 `b[0 .. lastIndex]`。

对象
--------

将不同的值打包到具有名称的单个结构中的类型默认是对象类型。
对象是一种值类型，这意味着当一个对象被分配给一个新变量时，它的所有组件也会被复制。

每个对象类型 `Foo` 都有一个可以初始化所有字段的构造函数 `Foo(field: value, ...)`，
未指定的字段将采用其默认值。

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


对其定义所处的模块外可见的对象字段必须用 `*` 标记。

  ```nim  test = "nim c $1"
  type
    Person* = object # the type is visible from other modules
      name*: string  # the field of this type is visible from other modules
      age*: int
  ```

元组
--------

元组非常类似于你到目前为止从对象中所看到的内容。它们值类型，赋值运算符将拷贝它们的每一个部分。
然而，与对象类型不同的是，元组类型是以结构为类型的，这意味着如果不同的元组类型以相同的顺序指定相同类型和相同名称的字段，
那么它们是*等效的*。

构造函数 `()` 可用于构造元组。构造函数中字段的顺序必须与元组定义中的顺序相匹配。
但与对象不同的是，这里可能不会使用元组类型的名称。


与对象类型一样，符号 `t.field` 用于访问元组的字段。
另一个不可用于对象的符号 `t[i]`，可用来访问第 `i` 个字段。
这里 `i` 必须是一个常量整数。

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

虽然你在使用元组时不需要为其声明类型，但使用不同的字段名称创建的元组将被视为不同的对象，
尽管它们的字段具有相同的类型。

元组可以在变量赋值期间*解包*。 这可以很方便地将元组字段直接分配给单独的具命变量。
这方面的一个例子是 [os 模块](os.html) 中的 [splitFile](os.html#splitFile,string) 过程，
它同时返回路径的目录、名称和扩展名。为了使元组解包工作，你必须在要分配解包值的周围使用括号，
否则，你将为所有单个变量分配相同的值!例如:

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

for 循环也支持元组解包:

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

元组的字段始终是公开的，它们不需要显式标记为导出，这与对象类型中的字段不同。


引用和指针类型
----------------------------

引用(类似于其他编程语言中的指针)是一种引入多对一关系的方法。
这意味着不同的引用可以指向和修改内存中的相同位置。

Nim 区分 `traced`:idx: 和 `untraced`:idx: 引用。未跟踪的引用也称为*指针*。
跟踪的引用指向会被垃圾收集的堆中的对象，未跟踪的引用指向手动分配的对象或内存中其他地方的对象。
因此，未跟踪的引用是*不安全的*。但是，对于某些低级操作(如访问硬件)，未跟踪的引用是必要的。

跟踪引用使用 **ref** 关键字声明; 未跟踪的引用使用 **ptr** 关键字声明。

空的 `[]` 下标符号可用于*解除*一个引用，这意味着检索引用指向的实例。
`.` (访问元组 / 对象字段)和 `[]`(数组 / 字符串 / 序列索引)运算符对引用类型隐式解引用:

  ```nim  test = "nim c $1"
  type
    Node = ref object
      le, ri: Node
      data: int

  var n = Node(data: 9)
  echo n.data
  # no need to write n[].data; in fact n[].data is highly discouraged!
  ```

要分配一个新的跟踪对象，可以使用内置过程 `new`:

  ```nim
  var n: Node
  new(n)
  ```

可以用 `alloc`, `dealloc` 和 `realloc` 来处理不跟踪的内存。
[system](system.html) 模块中的文档包含更多细节。

如果一个引用*什么都没有*指向，其值为 `nil`。


程序类型
---------------

过程类型是指向过程的(些许抽象的)指针。过程类型变量的值允许为 `nil`。
Nim 使用过程类型来实现 `functional`:idx: 编程技术。

例:

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

过程类型的一个微妙问题是过程的调用约定会影响类型兼容性: 过程类型只有在它们具有相同的调用约定时才兼容。
[手册](manual.html#types-procedural-type) 中列出了不同的调用约定。

Distinct 类型
----------------

Distinct 类型允许创建"不隐式与其基本类型之间存在子类型关系"的新类型。
你必须**明确**定义 distinct 类型的所有行为。为减轻这个问题，distinct 类型及其基类型
之间可以相互转换。
[手册](manual.html#types-distinct-type) 中提供了示例。

模块
========

Nim 支持使用*模块*概念将程序拆分为多个部分。每个模块都在自己的文件中。
模块启用 `information hiding`:idx: 和 `separate compilation`:idx:。
一个模块可以通过使用 `import`:idx: 语句来访问另一个模块的符号。
只有标有星号 (`*`) 的顶级符号会被导出:

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

上面的模块导出了 `x` 和 `*`，但没有导出 `y`。

模块的顶级语句在程序开始时执行。例如，这可用于初始化复杂的数据结构。

每个模块都有一个特殊的魔术常量 `isMainModule`，如果该模块被当做主文件编译，则该常量为真。
如上例所示，这对于在模块中嵌入测试非常有用。

模块的符号*可以*使用 `module.symbol` 语法*限定*。如果一个符号是模棱两可的，
那它*必须*合规。当符号在两个(或多个)不同的模块中定义并且这两个模块都由第三个模块导入时，
该符号是模棱两可的:

  ```nim
  # Module A
  var x*: string
  ```

  ```nim
  # Module B
  var x*: int
  ```

  ```nim
  # Module C
  import A, B
  write(stdout, x) # error: x is ambiguous
  write(stdout, A.x) # okay: qualifier used

  var x = 4
  write(stdout, x) # not ambiguous: uses the module C's x
  ```


但这条规则不适用于过程或迭代器。这种情况适用重载规则:

  ```nim
  # Module A
  proc x*(a: int): string = $a
  ```

  ```nim
  # Module B
  proc x*(a: string): string = $a
  ```

  ```nim
  # Module C
  import A, B
  write(stdout, x(3))   # no error: A.x is called
  write(stdout, x(""))  # no error: B.x is called

  proc x*(a: int): string = discard
  write(stdout, x(3))   # ambiguous: which `x` is to call?
  ```


排除符号
-----------------

正常的 `import` 语句将引入所有导出的符号。
这些可用 `except` 标识符点名限制哪个符号应当被排除。

  ```nim
  import mymodule except y
  ```


From 语句
------------------

我们已经见识了简单的 `import` 语句，它只导入所有导出的符号。
若仅导入所列符号则可用 `from import` 语句代替:

  ```nim
  from mymodule import x, y, z
  ```

`from` 语句还可以强制对符号进行命名空间限定，从而使符号经过限定后可用。

  ```nim
  from mymodule import x, y, z

  x()           # use x without any qualification
  ```

  ```nim
  from mymodule import nil

  mymodule.x()  # must qualify x with the module name as prefix

  x()           # using x here without qualification is a compile error
  ```

通常模块名因方便描述而变得很长，因此你还可以定义一个较短的别名以在限定符号时使用。

  ```nim
  from mymodule as m import nil

  m.x()         # m is aliasing mymodule
  ```


Include 语句
----------------------

`include` 语句做的事情和导入一个模块有着基本的不同: `include` 仅包含进一个文件。
`include` 语句在将一个模块拆分成多个文件时有用:

  ```nim
  include fileA, fileB, fileC
  ```



第二部分
================

好了，现在我们完成了基础，让我们看看 Nim 除了为程序化编程提供良好语法外
还提供了什么: [第 II 部分](tut2.html)


.. _strutils: strutils.html
.. _system: system.html
