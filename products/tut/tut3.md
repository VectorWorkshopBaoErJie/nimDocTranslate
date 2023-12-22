==============================
Nim 教程 (第 III 部分)
==============================

:Author: Arne Döring
:Version: |nimversion|

.. default-role:: code
.. include:: rstcommon.rst
.. contents::


引言
============

>  "With Great Power Comes Great Responsibility." -- Spider Man's Uncle

本文档是 Nim 宏系统的教程。宏是在编译时执行并将 Nim 语法树转换成一个不同树的函数。

可用宏实现的例子:

* 如果断言失败，则打印比较运算符两侧内容的断言宏。
  `myAssert(a == b)` 被转换为 `if a != b: quit($a " != " $b)`

* 打印符号的值和名称的调试宏。`myDebugEcho(a)` 被转换为 `echo "a: ", a`

* 表达式的微分。
  `diff(a*pow(x,3) + b*pow(x,2) + c*x + d, x)` 被转换为 `3*a*pow(x,2) + 2*b*x + c`


宏实参
---------------

宏的实参具有两面性。一面用于重载解析，另一面用于宏内。例如，如果
`macro foo(arg: int)` 在表达式 `foo(x)` 中被调用，`x` 必须是与
int 兼容的类型，但在宏*内* `arg` 的类型是 `NimNode`，而非 `int`!
这么做的原因当我们见到具体的例子时就明了了。

有两种方法可以给宏传参，实参必须是 `typed` 或 `untyped` 其中一种。


无类型实参
--------------------

无类型的宏实参将在语义检查前传给宏。这表示传给宏的语法树 Nim 尚不需要理解，
唯一的限制是它必须是可解析的。通常，宏不检查实参，而以某种方式在转换结果中使用它。
编译器会检查宏展开的结果，所以除了奇怪的错误消息之外，不会发生任何坏事。

`untyped` 实参的缺点是其对重载解析不利。

无类型实参的优点是语法树可预知，也比 `typed` 简单。


类型化实参
--------------------

对于类型化实参，语义检查器会在将其传给宏之前进行语义检查与变换。
这里标识符节点解析成符号，树中的隐式类型转换被看作调用，模板被展开，
最重要的是节点有类型信息。类型化实参的实参列表可有 `typed` 类型。
但是其他所有类型，如 `int`, `float` 及 `MyObjectType` 也是
类型化实参，它们作为一个语法树传递给宏。


静态实参
----------------

静态实参是一种将值作为值而不是作为语法树节点传递给宏的方法。
如对于表达式 `foo(x)` 中的 `macro foo(arg: static[int])`，
`x` 需要是一个整型常量，但在宏体中 `arg` 就像一个普通的 `int`
类型参数。

  ```nim
  import std/macros

  macro myMacro(arg: static[int]): untyped =
    echo arg # just an int (7), not `NimNode`

  myMacro(1 + 2 * 3)
  ```


代码块作为实参
------------------------------

可在带有缩进的单独代码块中传递调用表达式的最后一个参数。
例如，以下代码示例是调用 `echo` 的一个有效(但不推荐)的方式:

  ```nim
  echo "Hello ":
    let a = "Wor"
    let b = "ld!"
    a & b
  ```

对于宏来说，这种调用方式非常有用; 可用这种表示法将任意复杂的语法树传递给宏。


语法树
---------------

为了构建 Nim 语法树，我们需要知道如何用语法树表示 Nim 源码，
以及能被 Nim 编译器理解的树看起来是什么样子的。Nim 语法树的节点记录在
[macros](macros.html) 模块中。但一种更具交互性的探索 Nim 语法树的方法
是使用 `macros.treeRepr`，它将语法树转换为多行字符串以在控制台上打印。
它可用于探索实参表达式如何以树形式表示，以及生成语法树的调试打印。
`dumpTree` 是一个预定义的宏，它只是以树表示形式打印其实参，不执行其他任何操作。
树表示的示例:

  ```nim
  dumpTree:
    var mt: MyType = MyType(a:123.456, b:"abcdef")

  # output:
  #   StmtList
  #     VarSection
  #       IdentDefs
  #         Ident "mt"
  #         Ident "MyType"
  #         ObjConstr
  #           Ident "MyType"
  #           ExprColonExpr
  #             Ident "a"
  #             FloatLit 123.456
  #           ExprColonExpr
  #             Ident "b"
  #             StrLit "abcdef"
  ```


自定义语义检查
----------------------------

宏对其实参做的第一件事应是检查其形式是否正确。不是每种错误输入的类型都需要在这里捕获，
但是任何可能在宏评估期间导致崩溃的东西都应被捕获并产生一个直观的错误消息。
`macros.expectKind` 和 `macros.expectLen` 是一个好的开始。如果检查需要更复杂，
可用 `macros.error` proc 创建任意错误消息。

  ```nim
  macro myAssert(arg: untyped): untyped =
    arg.expectKind nnkInfix
  ```


代码生成
--------------------

有两种生成代码的方式。通过用含大量 `newTree` 和 `newLit` 调用的表达式创建语法树，
或用 `quote do:` 表达式。第一种选项为语法树生成提供了最佳的低级控制，但第二种选项会简洁很多。
若你选择通过调用 `newTree` 和 `newLit` 来创建语法树，`macros.dumpAstGen` 宏可帮助你避免冗长。

`quote do:` 允许你直接编写想要生成的代码。反引号用于将来自 `NimNode` 符号的代码插入到生成的表达式中。

  ```nim  test = "nim c $1"
  import std/macros
  macro a(i) = quote do:
    let `i` = 0

  a b
  doAssert b == 0
  ```

可以在任何需要反引号的时候，使用自定义前缀。

  ```nim  test = "nim c $1"
  import std/macros
  macro a(i) = quote("@") do:
    assert @i == 0

  let b = 0
  a b
  ```

想让注入宏的符号解析成作用域中的左值时需再用反引号括起。

  ```nim  test = "nim c $1"
  import std/macros
  macro a(i) = quote("@") do:
    let `@i` = 0

  a b
  doAssert b == 0
  ```

请确保只将 `NimNode` 类型的符号注入到生成的语法树中。你可以使用 `newLit` 
将任意值转换为 `NimNode` 类型的表达式树，以便安全地注入到树中。


  ```nim  test = "nim c $1"
  import std/macros

  type
    MyType = object
      a: float
      b: string

  macro myMacro(arg: untyped): untyped =
    var mt: MyType = MyType(a:123.456, b:"abcdef")

    # ...

    let mtLit = newLit(mt)

    result = quote do:
      echo `arg`
      echo `mtLit`

  myMacro("Hallo")
  ```

调用 `myMacro` 将生成以下代码:

  ```nim
  echo "Hallo"
  echo MyType(a: 123.456'f64, b: "abcdef")
  ```


构建你的第一个宏
--------------------------------

作为编写宏的起点，我们现在将展示如何实现前面提到的 `myAssert` 宏。
首先要做的是构建一个使用宏的简单示例，接着打印实参。由此，可了解到正确的
实参该为什么样子。

  ```nim  test = "nim c $1"
  import std/macros

  macro myAssert(arg: untyped): untyped =
    echo arg.treeRepr

  let a = 1
  let b = 2

  myAssert(a != b)
  ```

  ```
  Infix
    Ident "!="
    Ident "a"
    Ident "b"
  ```


从输出中可以看出，参数是一个中缀运算符(节点类型为 "Infix")，
并且有两个位于索引 1 和 2 的操作数。有了这些信息，就可编写真正的宏了。

  ```nim  test = "nim c $1"
  import std/macros

  macro myAssert(arg: untyped): untyped =
    # all node kind identifiers are prefixed with "nnk"
    arg.expectKind nnkInfix
    arg.expectLen 3
    # operator as string literal
    let op  = newLit(" " & arg[0].repr & " ")
    let lhs = arg[1]
    let rhs = arg[2]

    result = quote do:
      if not `arg`:
        raise newException(AssertionDefect,$`lhs` & `op` & $`rhs`)

  let a = 1
  let b = 2

  myAssert(a != b)
  myAssert(a == b)
  ```


这是将生成的代码。要调试宏实际生成的内容，可以在宏的最后一行使用 `echo result.repr` 语句。
它也是用于获取此输出的语句。

  ```nim
  if not (a != b):
    raise newException(AssertionDefect, $a & " != " & $b)
  ```

能力越大，责任越大
------------------------------------

宏非常强大。一个好的建议是尽可能少地使用它们，但在必要时尽可能多地使用它们。
宏可以改变表达式的语义，但这对不知道宏做什么的人难以理解来说。因此，当宏非必要
且可以使用模板和泛型实现相同逻辑时，最好不要用宏。而用宏处理某事时，宏最好有
一个写得很好的文档。对所有声称自己的代码可以不言自明的人来说: 当涉及宏时，
实现对于文档来说是不够的。

限制
-----------

由于宏是在 NimVM 的编译器中评估的，因此宏具有 NimVM 的所有限制。
它们必须在纯 Nim 代码中实现。宏可以在 shell 上启动外部进程，但不能调用 C 函数，
除了那些被编译器内置的。


更多示例
================

本教程只讲解了宏系统的基础知识。下面一些宏可以启发你用宏都能做什么。


Strformat
---------

Nim 标准库中，`strformat` 库提供了一个在编译时解析字符串文字的宏。通常不建议
像这样在宏中解析字符串。解析出来的 AST 不能有类型信息，且在 VM 上实现的解析一般
不会很快。在 AST 节点上工作几乎总是推荐的方式。但是对于一个比 `assert` 宏稍微
复杂的宏的实际用例来说，`strformat` 仍是一个很好的例子。

[Strformat](https://github.com/nim-lang/Nim/blob/5845716df8c96157a047c2bd6bcdd795a7a2b9b1/lib/pure/strformat.nim#L280)

Ast Pattern Matching
--------------------

Ast Pattern Matching 是一个宏库，可帮助编写复杂的宏。
这可看作是如何使用新语义重新利用 Nim 语法树的一个很好的例子。

[Ast Pattern Matching](https://github.com/krux02/ast-pattern-matching)

OpenGL 沙盒
------------------

此项目有一个完全用宏编写的 Nim 到 GLSL 的编译器。它通过递归扫描所有使用的函数符号来编译它们，
以便可以在 GPU 上执行交叉库函数。

[OpenGL 沙盒](https://github.com/krux02/opengl-sandbox)
