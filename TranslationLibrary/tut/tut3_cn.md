{==+==}
=======================
Nim Tutorial (Part III)
=======================
{==+==}
==============================
Nim 教程 (第 III 部分)
==============================
{==+==}

{==+==}
:Author: Arne Döring
:Version: |nimversion|
{==+==}
:Author: Arne Döring
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
>  "With Great Power Comes Great Responsibility." -- Spider Man's Uncle
{==+==}
>  "With Great Power Comes Great Responsibility." -- Spider Man's Uncle
{==+==}

{==+==}
This document is a tutorial about Nim's macro system.
A macro is a function that is executed at compile-time and transforms
a Nim syntax tree into a different tree.
{==+==}
本文档是 Nim 宏系统的教程。宏是在编译时执行并将 Nim 语法树转换为不同树的函数。
{==+==}

{==+==}
Examples of things that can be implemented in macros:
{==+==}
可通过宏实现的例子:
{==+==}

{==+==}
* An assert macro that prints both sides of a comparison operator, if
  the assertion fails. `myAssert(a == b)` is converted to
  `if a != b: quit($a " != " $b)`
{==+==}
* 如果断言失败，则打印比较运算符两侧内容的断言宏。
  `myAssert(a == b)` 被转换为 `if a != b: quit($a " != " $b)`
{==+==}

{==+==}
* A debug macro that prints the value and the name of the symbol.
  `myDebugEcho(a)` is converted to `echo "a: ", a`
{==+==}
* 打印符号的值和名称的调试宏。`myDebugEcho(a)` 被转换为 `echo "a: ", a`
{==+==}

{==+==}
* Symbolic differentiation of an expression.
  `diff(a*pow(x,3) + b*pow(x,2) + c*x + d, x)` is converted to
  `3*a*pow(x,2) + 2*b*x + c`
{==+==}
* 表达式的符号微分。
  `diff(a*pow(x,3) + b*pow(x,2) + c*x + d, x)` 被转换为 `3*a*pow(x,2) + 2*b*x + c`
{==+==}


{==+==}
Macro Arguments
---------------
{==+==}
宏参数
---------------
{==+==}

{==+==}
The types of macro arguments have two faces. One face is used for
the overload resolution and the other face is used within the macro
body. For example, if `macro foo(arg: int)` is called in an
expression `foo(x)`, `x` has to be of a type compatible to int, but
*within* the macro's body `arg` has the type `NimNode`, not `int`!
Why it is done this way will become obvious later, when we have seen
concrete examples.
{==+==}
宏参数的类型有两个方面。一面用于重载解决方案，另一面用于宏内。例如，如果
`macro foo(arg: int)` 在表达式 `foo(x)` 中被调用，`x` 必须是与
int 兼容的类型，但*在宏内* `arg` 类型为 `NimNode`，而非 `int`!
为何如此? 当我们看到具体例子时就明了了。
{==+==}

{==+==}
There are two ways to pass arguments to a macro, an argument can be
either `typed` or `untyped`.
{==+==}
有两种方法可以给宏传参，参数可以是 `typed` 或 `untyped`。
{==+==}


{==+==}
Untyped Arguments
-----------------
{==+==}
无类型参数
--------------------
{==+==}

{==+==}
Untyped macro arguments are passed to the macro before they are
semantically checked. This means the syntax tree that is passed down
to the macro does not need to make sense for Nim yet, the only
limitation is that it needs to be parsable. Usually, the macro does
not check the argument either but uses it in the transformation's
result somehow. The result of a macro expansion is always checked
by the compiler, so apart from weird error messages, nothing bad
can happen.
{==+==}
无类型的宏参数将在语义检查前传给宏。这表示传给宏的语法树 Nim 尚不需要理解，
唯一的限制是它必须是可解析的。通常，宏也不检查参数，而以某种方式在转换结果中使用它。
编译器会检查宏展开的结果，所以除了奇怪的错误消息之外，不会发生任何坏事。
{==+==}

{==+==}
The downside for an `untyped` argument is that these do not play
well with Nim's overloading resolution.
{==+==}
`untyped` 参数的缺点是其对重载解析不利。
{==+==}

{==+==}
The upside for untyped arguments is that the syntax tree is
quite predictable and less complex compared to its `typed`
counterpart.
{==+==}
无类型实参的优点是语法树可预知，其也比 `typed` 简单。
{==+==}


{==+==}
Typed Arguments
---------------
{==+==}
类型化参数
--------------------
{==+==}

{==+==}
For typed arguments, the semantic checker runs on the argument and
does transformations on it, before it is passed to the macro. Here
identifier nodes are resolved as symbols, implicit type
conversions are visible in the tree as calls, templates are
expanded, and probably most importantly, nodes have type information.
Typed arguments can have the type `typed` in the arguments list.
But all other types, such as `int`, `float` or `MyObjectType`
are typed arguments as well, and they are passed to the macro as a
syntax tree.
{==+==}
对于类型化参数，语义检查器会在其传递给宏之前进行语义检查与变换。
这里标识符节点解析成符号，树中的隐式类型转换被看作调用，模板被展开，
最重要的是节点有类型信息。类型化实参的实参列表可以有 `typed` 类型。
但是其他所有类型，如 `int`, `float` 及 `MyObjectType` 也是
类型化实参，它们作为一个语法树传递给宏。
{==+==}


{==+==}
Static Arguments
----------------
{==+==}
静态参数
----------------
{==+==}

{==+==}
Static arguments are a way to pass values as values and not as syntax
tree nodes to a macro. For example for `macro foo(arg: static[int])`
in the expression `foo(x)`, `x` needs to be an integer constant,
but in the macro body `arg` is just like a normal parameter of type
`int`.
{==+==}
静态参数是一种将值作为值而不是作为语法树节点传递给宏的方法。
例如对于表达式 `foo(x)` 中的 `macro foo(arg: static[int])`，
`x` 需要是一个整型常量，但在宏体中 `arg` 就像一个普通的 `int`
类型参数。
{==+==}

{==+==}
  ```nim
  import std/macros

  macro myMacro(arg: static[int]): untyped =
    echo arg # just an int (7), not `NimNode`

  myMacro(1 + 2 * 3)
  ```
{==+==}
  ```nim
  import std/macros

  macro myMacro(arg: static[int]): untyped =
    echo arg # just an int (7), not `NimNode`

  myMacro(1 + 2 * 3)
  ```
{==+==}


{==+==}
Code Blocks as Arguments
------------------------
{==+==}
代码块作为参数
------------------------------
{==+==}

{==+==}
It is possible to pass the last argument of a call expression in a
separate code block with indentation. For example, the following code
example is a valid (but not a recommended) way to call `echo`:
{==+==}
可以在带有缩进的单独代码块中传递调用表达式的最后一个参数。
例如，以下代码示例是调用 `echo` 的有效(但不推荐)方式:
{==+==}

{==+==}
  ```nim
  echo "Hello ":
    let a = "Wor"
    let b = "ld!"
    a & b
  ```
{==+==}
  ```nim
  echo "Hello ":
    let a = "Wor"
    let b = "ld!"
    a & b
  ```
{==+==}

{==+==}
For macros this way of calling is very useful; syntax trees of arbitrary
complexity can be passed to macros with this notation.
{==+==}
对于宏，这种调用方式非常有用; 可以使用这种表示法将任意复杂的语法树传递给宏。
{==+==}


{==+==}
The Syntax Tree
---------------
{==+==}
语法树
---------------
{==+==}

{==+==}
In order to build a Nim syntax tree one needs to know how Nim source
code is represented as a syntax tree, and how such a tree needs to
look like so that the Nim compiler will understand it. The nodes of the
Nim syntax tree are documented in the [macros](macros.html) module.
But a more interactive way to explore the Nim
syntax tree is with `macros.treeRepr`, it converts a syntax tree
into a multi-line string for printing on the console. It can be used
to explore how the argument expressions are represented in tree form
and for debug printing of generated syntax tree. `dumpTree` is a
predefined macro that just prints its argument in a tree representation,
but does nothing else. Here is an example of such a tree representation:
{==+==}
为了构建 Nim 语法树，需要知道 Nim 源代码是如何表示为语法树，以及这种树的外观如何，
以便 Nim 编译器能够理解它。Nim 语法树的节点记录在 [macros](macros.html) 模块中。
但是探索 Nim 语法树的一种更具交互性的方法是使用 `macros.treeRepr`，
它将语法树转换为多行字符串以在控制台上打印。它可用于探索参数表达式如何以树形式表示以及
用于调试打印生成的语法树。`dumpTree` 是一个预定义的宏，它只是以树表示形式打印其参数，
但不执行其他任何操作。这是这种树表示的示例:
{==+==}

{==+==}
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
{==+==}
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
{==+==}


{==+==}
Custom Semantic Checking
------------------------
{==+==}
自定义语义检查
----------------------------
{==+==}

{==+==}
The first thing that a macro should do with its arguments is to check
if the argument is in the correct form. Not every type of wrong input
needs to be caught here, but anything that could cause a crash during
macro evaluation should be caught and create a nice error message.
`macros.expectKind` and `macros.expectLen` are a good start. If
the checks need to be more complex, arbitrary error messages can
be created with the `macros.error` proc.
{==+==}
宏应该对其参数做的第一件事是检查参数的形式是否正确。不是所有类型的错误输入都需要在这里捕获，
但是任何可能在宏评估期间导致崩溃的东西都应该被捕获并产生一个直观的错误消息。
`macros.expectKind` 和 `macros.expectLen` 是一个好的开始。
如果检查需要更复杂，可以使用 `macros.error` proc 创建任意错误消息。
{==+==}

{==+==}
  ```nim
  macro myAssert(arg: untyped): untyped =
    arg.expectKind nnkInfix
  ```
{==+==}
  ```nim
  macro myAssert(arg: untyped): untyped =
    arg.expectKind nnkInfix
  ```
{==+==}


{==+==}
Generating Code
---------------
{==+==}
代码生成
--------------------
{==+==}

{==+==}
There are two ways to generate the code. Either by creating the syntax
tree with expressions that contain a lot of calls to `newTree` and
`newLit`, or with `quote do:` expressions. The first option offers
the best low-level control for the syntax tree generation, but the
second option is much less verbose. If you choose to create the syntax
tree with calls to `newTree` and `newLit` the macro
`macros.dumpAstGen` can help you with the verbosity.
{==+==}
有两种方法可以生成代码。通过使用包含大量调用 `newTree` 和 `newLit` 
的表达式创建语法树，或者使用 `quote do:` 表达式。第一个选项为语法树生成
提供了最佳的低级控制，但第二个选项不那么冗长。如果您选择通过调用 `newTree`
和 `newLit` 来创建语法树，宏 `macros.dumpAstGen` 可以帮助您避免冗长。
{==+==}

{==+==}
`quote do:` allows you to write the code that you want to generate literally.
Backticks are used to insert code from `NimNode` symbols into the
generated expression.
{==+==}
`quote do:` 允许您编写您想要生成的代码。反引号用于将来自 `NimNode` 符号的代码插入到生成的表达式中。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/macros
  macro a(i) = quote do:
    let `i` = 0

  a b
  doAssert b == 0
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/macros
  macro a(i) = quote do:
    let `i` = 0

  a b
  doAssert b == 0
  ```
{==+==}

{==+==}
A custom prefix operator can be defined whenever backticks are needed.
{==+==}
每当需要反引号时，都可以定义自定义前缀运算符。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/macros
  macro a(i) = quote("@") do:
    assert @i == 0

  let b = 0
  a b
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/macros
  macro a(i) = quote("@") do:
    assert @i == 0

  let b = 0
  a b
  ```
{==+==}

{==+==}
The injected symbol needs accent quoted when it resolves to a symbol.
{==+==}
注入的符号在解析为符号时需要重音引用。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/macros
  macro a(i) = quote("@") do:
    let `@i` = 0

  a b
  doAssert b == 0
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/macros
  macro a(i) = quote("@") do:
    let `@i` = 0

  a b
  doAssert b == 0
  ```
{==+==}

{==+==}
Make sure to inject only symbols of type `NimNode` into the generated syntax
tree. You can use `newLit` to convert arbitrary values into
expressions trees of type `NimNode` so that it is safe to inject
them into the tree.
{==+==}
确保只将 `NimNode` 类型的符号注入到生成的语法树中。您可以使用 `newLit` 
将任意值转换为 `NimNode` 类型的表达式树，如此将它们注入树中是安全的。
{==+==}


{==+==}
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
{==+==}
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
{==+==}

{==+==}
The call to `myMacro` will generate the following code:
{==+==}
对 `myMacro` 的调用将生成以下代码:
{==+==}

{==+==}
  ```nim
  echo "Hallo"
  echo MyType(a: 123.456'f64, b: "abcdef")
  ```
{==+==}
  ```nim
  echo "Hallo"
  echo MyType(a: 123.456'f64, b: "abcdef")
  ```
{==+==}


{==+==}
Building Your First Macro
-------------------------
{==+==}
创建你的第一个宏
-------------------------
{==+==}

{==+==}
To give a starting point to writing macros we will show now how to
implement the `myAssert` macro mentioned earlier. The first thing to
do is to build a simple example of the macro usage, and then just
print the argument. This way it is possible to get an idea of what a
correct argument should look like.
{==+==}
作为编写宏的起点，我们现在将展示如何实现前面提到的"myAssert"宏。
首先要做的是构建一个宏用法的简单示例，然后打印参数。通过这种方式，
可以了解正确的论点应该是什么样子。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/macros

  macro myAssert(arg: untyped): untyped =
    echo arg.treeRepr

  let a = 1
  let b = 2

  myAssert(a != b)
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/macros

  macro myAssert(arg: untyped): untyped =
    echo arg.treeRepr

  let a = 1
  let b = 2

  myAssert(a != b)
  ```
{==+==}

{==+==}
  ```
  Infix
    Ident "!="
    Ident "a"
    Ident "b"
  ```
{==+==}
  ```
  Infix
    Ident "!="
    Ident "a"
    Ident "b"
  ```
{==+==}


{==+==}
From the output, it is possible to see that the argument is an infix
operator (node kind is "Infix"), as well as that the two operands are
at index 1 and 2. With this information, the actual macro can be
written.
{==+==}
从输出中可以看出，参数是一个中缀运算符(节点类型为"中缀")，
并且两个操作数位于索引 1 和 2。有了这些信息，就可以编写实际的宏了。
{==+==}

{==+==}
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
{==+==}
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
{==+==}


{==+==}
This is the code that will be generated. To debug what the macro
actually generated, the statement `echo result.repr` can be used, in
the last line of the macro. It is also the statement that has been
used to get this output.
{==+==}
这是将生成的代码。要调试宏实际生成的内容，可以在宏的最后一行使用语句 `echo result.repr`。
它也是用于获取此输出的语句。
{==+==}

{==+==}
  ```nim
  if not (a != b):
    raise newException(AssertionDefect, $a & " != " & $b)
  ```
{==+==}
  ```nim
  if not (a != b):
    raise newException(AssertionDefect, $a & " != " & $b)
  ```
{==+==}

{==+==}
With Power Comes Responsibility
-------------------------------
{==+==}
能力越大，责任越大
------------------------------------
{==+==}

{==+==}
Macros are very powerful. A piece of good advice is to use them as little as
possible, but as much as necessary. Macros can change the semantics of
expressions, making the code incomprehensible for anybody who does not
know exactly what the macro does with it. So whenever a macro is not
necessary and the same logic can be implemented using templates or
generics, it is probably better not to use a macro. And when a macro
is used for something, the macro should better have a well-written
documentation. For all the people who claim to write only perfectly
self-explanatory code: when it comes to macros, the implementation is
not enough for documentation.
{==+==}
宏非常强大。 一个好的建议是尽可能少地使用它们，但尽可能在必要时使用它们。
宏可以改变表达式的语义，使得代码对于不确切知道宏用它做什么的人来说是难以理解的。
因此，每当不需要宏并且可以使用模板或泛型实现相同的逻辑时，最好不要使用宏。
而当宏用于某事时，宏最好有一个写得很好的文档。对于所有声称只编写完全不言自明的代码的人来说:
当涉及到宏时，实现对于文档来说是不够的。
{==+==}

{==+==}
Limitations
-----------
{==+==}
限制
-----------
{==+==}

{==+==}
Since macros are evaluated in the compiler in the NimVM, macros share
all the limitations of the NimVM. They have to be implemented in pure Nim
code. Macros can start external processes on the shell, but they
cannot call C functions except those that are built in the
compiler.
{==+==}
由于宏是在 NimVM 的编译器中评估的，因此宏具有 NimVM 的所有限制。
它们必须在纯 Nim 代码中实现。宏可以在 shell 上启动外部进程，但它们不能调用 C 函数，
除了那些编译器内置的函数。
{==+==}


{==+==}
More Examples
=============
{==+==}
更多例子
================
{==+==}

{==+==}
This tutorial can only cover the basics of the macro system. There are
macros out there that could be an inspiration for you of what is
possible with it.
{==+==}
本教程只能涵盖宏系统的基础知识。那里有一些宏可以启发你用它做些什么。
{==+==}


{==+==}
Strformat
---------
{==+==}
Strformat
---------
{==+==}

{==+==}
In the Nim standard library, the `strformat` library provides a
macro that parses a string literal at compile time. Parsing a string
in a macro like here is generally not recommended. The parsed AST
cannot have type information, and parsing implemented on the VM is
generally not very fast. Working on AST nodes is almost always the
recommended way. But still `strformat` is a good example for a
practical use case for a macro that is slightly more complex than the
`assert` macro.
{==+==}
在 Nim 标准库中，`strformat` 库提供了一个在编译时解析字符串文字的宏。
通常不建议像这里那样在宏中解析字符串。解析出来的 AST 不能有类型信息，在 VM 
上实现的解析一般不会很快。在 AST 节点上工作几乎总是推荐的方式。
但是对于一个比 `assert` 宏稍微复杂的宏的实际用例来说，`strformat` 仍然是一个很好的例子。
{==+==}

{==+==}
[Strformat](https://github.com/nim-lang/Nim/blob/5845716df8c96157a047c2bd6bcdd795a7a2b9b1/lib/pure/strformat.nim#L280)
{==+==}
[Strformat](https://github.com/nim-lang/Nim/blob/5845716df8c96157a047c2bd6bcdd795a7a2b9b1/lib/pure/strformat.nim#L280)
{==+==}

{==+==}
Ast Pattern Matching
--------------------
{==+==}
Ast 模式匹配
--------------------
{==+==}

{==+==}
Ast Pattern Matching is a macro library to aid in writing complex
macros. This can be seen as a good example of how to repurpose the
Nim syntax tree with new semantics.
{==+==}
Ast Pattern Matching 是一个宏库，可帮助编写复杂的宏。
这可以看作是如何使用新语义重新利用 Nim 语法树的一个很好的例子。
{==+==}

{==+==}
[Ast Pattern Matching](https://github.com/krux02/ast-pattern-matching)
{==+==}
[Ast Pattern Matching](https://github.com/krux02/ast-pattern-matching)
{==+==}

{==+==}
OpenGL Sandbox
--------------
{==+==}
OpenGL 沙箱
------------------
{==+==}

{==+==}
This project has a working Nim to GLSL compiler written entirely in
macros. It scans recursively through all used function symbols to
compile them so that cross library functions can be executed on the GPU.
{==+==}
这个项目有一个完全用宏编写的 Nim 到 GLSL 编译器。它递归地扫描所有使用的函数符号以编译它们，
以便可以在 GPU 上执行跨库函数。
{==+==}

{==+==}
[OpenGL Sandbox](https://github.com/krux02/opengl-sandbox)
{==+==}
[OpenGL 沙箱](https://github.com/krux02/opengl-sandbox)
{==+==}
