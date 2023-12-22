==============================
Nim 教程 (第 II 部分)
==============================

:Author: Andreas Rumpf
:Version: |nimversion|

.. default-role:: code
.. include:: rstcommon.rst
.. contents::


引言
============

> "Repetition renders the ridiculous reasonable." -- Norman Wildberger

本文档是有关 *Nim* 编程语言高级部分的教程。**请注意，此文档有些过时，但**
[手册](manual.html) **中包含更多高级语言功能的示例。**


编译指示
================

编译指示是 Nim 为编译器提供额外信息 / 命令而不引入大量新关键字的方法。
编译指示包含在特殊的 `{.` 和 `.}` 大括号中。本教程不涉及编译指示的内容。
详情请参阅 [手册](manual.html#pragmas) 或 [用户指导](
nimc.html#additional-features) 以了解可用的编译指示。


面向对象编程
===========================

虽然 Nim 对面向对象编程 (OOP) 的支持很简单，但你仍可使用强大的 OOP 技术。
OOP 被视为设计程序的*一种*方式，而非*唯一*方式。通常，使用过程能写出更简单有效的代码。
尤其是在设计上，首选组合比继承更好。


继承
-----------

Nim 中的继承完全是可选的。要使用继承并启用运行时类型信息，对象需从 `RootObj` 继承。
这可以通过直接继承或间接地继承继承了 `RootObj` 的对象来完成。尽管将使用了继承的类型
标记为 `ref` 不是强制的，但这是惯用法。要在运行时检查对象是否属于某种类型，可用 `of` 运算符。

  ```nim  test = "nim c $1"
  type
    Person = ref object of RootObj
      name*: string  # the * means that `name` is accessible from other modules
      age: int       # no * means that the field is hidden from other modules

    Student = ref object of Person # Student inherits from Person
      id: int                      # with an id field

  var
    student: Student
    person: Person
  assert(student of Student) # is true
  # object construction:
  student = Student(name: "Anton", age: 5, id: 2)
  echo student[]
  ```

继承是使用 `object of` 语法完成的。当前不支持多重继承。如果一个对象类型没有合适的父类，
可以选择 `RootObj` 作为它的父类，但这只是一个约定。没有父类的对象被隐式设置为 `final`。
你可用 `inheritable` 编译指示来引入除 `system.RootObj` 之外的新对象根。
(例如，这在 GTK 包装器中使用)

每当使用继承时，都应该使用 Ref 对象。这不是绝对必要的，但是对于非 ref 对象，诸如
`let person: Person = Student(id: 123)` 之类的赋值将截断子类字段。

**注意**: 对于简单的代码重用，组合(*has-a* 关系)通常优于继承(*is-a* 关系)。
由于对象在 Nim 中是值类型，因此组合与继承一样高效。


相互递归类型
------------------------

对象、元组和引用可以模拟相互依赖的非常复杂的数据结构;
在一个声明块中声明的类型是*相互递归*可知的。(其他类型都需要提前声明相应符号，这将减慢编译速度)

例:

  ```nim  test = "nim c $1"
  type
    Node = ref object  # a reference to an object with the following field:
      le, ri: Node     # left and right subtrees
      sym: ref Sym     # leaves contain a reference to a Sym

    Sym = object       # a symbol
      name: string     # the symbol's name
      line: int        # the line the symbol was declared in
      code: Node       # the symbol's abstract syntax tree
  ```


类型转换
----------------
Nim 区分 `type cast`:idx: 和 `type conversions`:idx:。
`cast` 运算符可用于类型强转，强制编译器将一种类型的位格式强转为另一种类型。

类型转换是将一种类型转换为另一种类型的一种更友好的方式: 它们保留抽象的*值*，
且不一定按照*位模式*转换。如果无法进行转换，编译器会报错或引发异常。

类型转换的语法是 `destination_type(expression_to_convert)` (类似普通的调用):

  ```nim
  proc getID(x: Person): int =
    Student(x).id
  ```

如果 `x` 不是 `Student`，则会引发 `InvalidObjectConversionDefect` 异常。


对象变体
---------------
使用鉴别器来处理简单的对象变体是极其高效的。

例:

  ```nim  test = "nim c $1"
  # This is an example how an abstract syntax tree could be modelled in Nim
  type
    NodeKind = enum  # the different node types
      nkInt,          # a leaf with an integer value
      nkFloat,        # a leaf with a float value
      nkString,       # a leaf with a string value
      nkAdd,          # an addition
      nkSub,          # a subtraction
      nkIf            # an if statement
    Node = ref object
      case kind: NodeKind  # the `kind` field is the discriminator
      of nkInt: intVal: int
      of nkFloat: floatVal: float
      of nkString: strVal: string
      of nkAdd, nkSub:
        leftOp, rightOp: Node
      of nkIf:
        condition, thenPart, elsePart: Node

  var n = Node(kind: nkFloat, floatVal: 1.0)
  # the following statement raises an `FieldDefect` exception, because
  # n.kind's value does not fit:
  n.strVal = ""
  ```

从示例中可以看出，使用鉴别器处理异构对象的一个优点是无需在不同对象类型之间进行转换。
然而，对无效对象字段的访问会引发异常。


方法调用语法
------------------------

调用例程有一个语法糖: 可用 `obj.methodName(args)` 语法
代替 `methodName(obj, args)`。如果没有其他参数，可省略括号:
`obj.len` (而非 `len(obj)`)。

这种方法调用语法不限于对象，它可用于任何类型:

  ```nim  test = "nim c $1"
  import std/strutils

  echo "abc".len # is the same as echo len("abc")
  echo "abc".toUpperAscii()
  echo({'a', 'b', 'c'}.card)
  stdout.writeLine("Hallo") # the same as writeLine(stdout, "Hallo")
  ```

(从另一个角度来看，方法调用的语法，提供了语义上缺省的后缀)

所以"纯面向对象"的代码很容易编写:

  ```nim  test = "nim c $1"
  import std/[strutils, sequtils]

  stdout.writeLine("Give a list of numbers (separated by spaces): ")
  stdout.write(stdin.readLine.splitWhitespace.map(parseInt).max.`$`)
  stdout.writeLine(" is the maximum!")
  ```


属性
----------
如上例所示，Nim 不需要 *get-properties*: 使用*方法调用语法*调用的普通 get-procedures
与前者实现相同。但设置一个值的情况并不是这样; 为此，需要特殊的 setter 语法:

  ```nim  test = "nim c $1"
  type
    Socket* = ref object of RootObj
      h: int # cannot be accessed from the outside of the module due to missing star

  proc `host=`*(s: var Socket, value: int) {.inline.} =
    ## setter of host address
    s.h = value

  proc host*(s: Socket): int {.inline.} =
    ## getter of host address
    s.h

  var s: Socket
  new s
  s.host = 34  # same as `host=`(s, 34)
  ```

(该示例还显示了 `inline` 过程)


数组访问运算符 `[]` 可被重载以提供 `array properties`:idx:\ :

  ```nim  test = "nim c $1"
  type
    Vector* = object
      x, y, z: float

  proc `[]=`* (v: var Vector, i: int, value: float) =
    # setter
    case i
    of 0: v.x = value
    of 1: v.y = value
    of 2: v.z = value
    else: assert(false)

  proc `[]`* (v: Vector, i: int): float =
    # getter
    case i
    of 0: result = v.x
    of 1: result = v.y
    of 2: result = v.z
    else: assert(false)
  ```

这个例子很蠢，因为向量最好由一个提供了 `v[]` 访问方式的元组来构建。


动态分发
----------------

过程总是使用静态分发。对于动态分发，应用 `method` 替换 `proc` 关键字:

  ```nim  test = "nim c $1"
  type
    Expression = ref object of RootObj ## abstract base class for an expression
    Literal = ref object of Expression
      x: int
    PlusExpr = ref object of Expression
      a, b: Expression

  # watch out: 'eval' relies on dynamic binding
  method eval(e: Expression): int {.base.} =
    # override this base method
    quit "to override!"

  method eval(e: Literal): int = e.x
  method eval(e: PlusExpr): int = eval(e.a) + eval(e.b)

  proc newLit(x: int): Literal = Literal(x: x)
  proc newPlus(a, b: Expression): PlusExpr = PlusExpr(a: a, b: b)

  echo eval(newPlus(newPlus(newLit(1), newLit(2)), newLit(4)))
  ```

请注意，在示例中，构造函数 `newLit` 和 `newPlus` 是过程，
因为它们使用静态绑定更有意义，但 `eval` 是一种方法，因为它需要动态绑定。

**注意:** 从 Nim 0.20 开始，要使用 multi-methods，必须在编译时显式传递 ``--multimethods:on``。

在 multi-methods 中，所有具有对象类型的参数都将用于分发:

  ```nim  test = "nim c --multiMethods:on $1"
  type
    Thing = ref object of RootObj
    Unit = ref object of Thing
      x: int

  method collide(a, b: Thing) {.inline.} =
    quit "to override!"

  method collide(a: Thing, b: Unit) {.inline.} =
    echo "1"

  method collide(a: Unit, b: Thing) {.inline.} =
    echo "2"

  var a, b: Unit
  new a
  new b
  collide(a, b) # output: 2
  ```


如示例所示，对 multi-method 的调用不能模棱两可: collide 2 优于 collide 1，
因为解析深度从左到右降低。因此，`Unit, Thing` 优于 `Thing, Unit`。

**性能说明**: Nim 不生成虚拟方法表，而是生成调度树。这避免了方法调用昂贵的间接分支并支持内联。
但是，编译时评估以及死代码消除等其他优化将不适用于方法。


异常
==========

在 Nim 中，异常是对象。按照惯例，异常类型以 'Error' 为后缀。
[system](system.html) 模块定义了你可能想要依照的异常层次结构。
异常从提供了公共接口的`system.Exception`派生。

异常必须在堆上分配，因为它们的生命周期是未知的。编译器将阻止你引发在栈上创建的异常。
所有引发的异常至少应在 `msg` 字段中指定引发的原因。

异常应在*发生异常*的情况下引发，它们不应用作控制流的替代方法。

Raise 语句
---------------
引发异常是通过 `raise` 语句完成的:

  ```nim  test = "nim c $1"
  var
    e: ref OSError
  new(e)
  e.msg = "the request to the OS failed"
  raise e
  ```

如果 `raise` 关键字后面没有跟表达式，最后一个异常将被*再次引发*。
为避免重复这种常见的代码模式，可用 `system` 模块中的模板 `newException`:

  ```nim
  raise newException(OSError, "the request to the OS failed")
  ```


Try 语句
-------------

`try` 语句处理异常:

  ```nim  test = "nim c $1"
  from std/strutils import parseInt

  # read the first two lines of a text file that should contain numbers
  # and tries to add them
  var
    f: File
  if open(f, "numbers.txt"):
    try:
      let a = readLine(f)
      let b = readLine(f)
      echo "sum: ", parseInt(a) + parseInt(b)
    except OverflowDefect:
      echo "overflow!"
    except ValueError:
      echo "could not convert string to integer"
    except IOError:
      echo "IO error!"
    except:
      echo "Unknown exception!"
      # reraise the unknown exception:
      raise
    finally:
      close(f)
  ```

除非有异常被引发，否则将执行 `try` 之后的语句。然后执行之后可能达到的 `except` 部分。

如果存在未明确列出的异常，则执行空的 `except` 部分。它类似于 `if` 语句中的 `else`。

若有 `finally` 部分，它总是在异常处理之后执行。

异常在 `except` 部分被*消费*。如果异常未被处理，则其通过调用堆栈传播。
这意味着如果发生异常，程序的其余部分——不在 `finally` 子句中——通常不会被执行。

如果你需要*访问* `except` 分支中的实际异常对象或消息，你可以使用[系统](system.html）模块中的
[getCurrentException()](system.html#getCurrentException) 和 [getCurrentExceptionMsg()](
  system.html#getCurrentExceptionMsg) 过程。例如:

  ```nim
  try:
    doSomethingHere()
  except:
    let
      e = getCurrentException()
      msg = getCurrentExceptionMsg()
    echo "Got exception ", repr(e), " with message ", msg
  ```


用 raised exceptions 注解过程
-----------------------------------------------

通过使用可选的 `{.raises.}` 编译指示，你可指定过程旨在引发一组特定的异常，或者根本不引发异常。
如果使用了 `{.raises.}` 编译指示，编译器将验证这是否为真。例如，如果你指定过程会引发 `IOError`，
并且在某个时候它(或它调用的其中一个过程)开始引发新异常，则编译器将阻止该过程编译。使用示例:

  ```nim
  proc complexProc() {.raises: [IOError, ArithmeticDefect].} =
    ...

  proc simpleProc() {.raises: [].} =
    ...
  ```

一旦你有了这样的代码，如果引发的异常列表发生更改，编译器将停止并显示一个错误，指定停止验证编译指示
的过程行和未捕获的可引发的异常，以及未捕获的已引发异常所在的文件和行，这可帮助你找到已更改的违规代码。

如果你想将 `{.raises.}` 编译指示添加到现有代码中，编译器也可助你一臂之力。
将 `{.effects.}` 编译指示语句添加到你的过程中，编译器将把所有的推断效果输出到该点
(异常跟踪是 Nim effect 系统的一部分)。另一种查找过程引发的异常列表的更为隐晦的方法是使用
Nim ``doc`` 命令，该命令为整个模块生成文档，并用异常引发列表装饰所有过程。
你可[在手册中阅读更多关于 Nim 的 effect 系统和相关编译指示的信息](manual.html#effect-system)。


泛型
========

泛型是 Nim 使用 `type parameters`:idx: 参数化过程、迭代器或类型的方法。
泛型参数写在方括号内，例如 `Foo[T]`。它们对高效的类型安全容器最有用:

  ```nim  test = "nim c $1"
  type
    BinaryTree*[T] = ref object # BinaryTree is a generic type with
                                # generic param `T`
      le, ri: BinaryTree[T]     # left and right subtrees; may be nil
      data: T                   # the data stored in a node

  proc newNode*[T](data: T): BinaryTree[T] =
    # constructor for a node
    new(result)
    result.data = data

  proc add*[T](root: var BinaryTree[T], n: BinaryTree[T]) =
    # insert a node into the tree
    if root == nil:
      root = n
    else:
      var it = root
      while it != nil:
        # compare the data items; uses the generic `cmp` proc
        # that works for any type that has a `==` and `<` operator
        var c = cmp(it.data, n.data)
        if c < 0:
          if it.le == nil:
            it.le = n
            return
          it = it.le
        else:
          if it.ri == nil:
            it.ri = n
            return
          it = it.ri

  proc add*[T](root: var BinaryTree[T], data: T) =
    # convenience proc:
    add(root, newNode(data))

  iterator preorder*[T](root: BinaryTree[T]): T =
    # Preorder traversal of a binary tree.
    # This uses an explicit stack (which is more efficient than
    # a recursive iterator factory).
    var stack: seq[BinaryTree[T]] = @[root]
    while stack.len > 0:
      var n = stack.pop()
      while n != nil:
        yield n.data
        add(stack, n.ri)  # push right subtree onto the stack
        n = n.le          # and follow the left pointer

  var
    root: BinaryTree[string] # instantiate a BinaryTree with `string`
  add(root, newNode("hello")) # instantiates `newNode` and `add`
  add(root, "world")          # instantiates the second `add` proc
  for str in preorder(root):
    stdout.writeLine(str)
  ```

该例展示了一个泛型二叉树。根据上下文，方括号可用于引入类型参数或实例化泛型过程、迭代器或类型。
如示例所示，泛型支持重载: 使用 `add` 的最佳匹配。序列的内置 `add` 过程不是隐藏的，
并且在 `preorder` 迭代器中使用。

在方法调用语法中使用泛型时有一个特殊的 `[:T]` 语法:

  ```nim  test = "nim c $1"
  proc foo[T](i: T) =
    discard

  var i: int

  # i.foo[int]() # Error: expression 'foo(i)' has no type (or is ambiguous)

  i.foo[:int]() # Success
  ```


模板
=========

模板是一种在 Nim 抽象语法树上执行的简单替换机制。模板在编译器的语义传递中处理。
它们与语言的其余部分很好地集成，且没有 C 的预处理器宏的缺陷。

要*调用*模板，请像调用过程一样调用它。

例:

  ```nim
  template `!=` (a, b: untyped): untyped =
    # this definition exists in the System module
    not (a == b)

  assert(5 != 6) # the compiler rewrites that to: assert(not (5 == 6))
  ```

`!=`、`>`、`>=`、`in`、`notin`、`isnot` 运算符实际上是模板: 这样做的好处是，
如果重载了 `==` 运算符，`!=` 运算符将自动可用并且正确运作。
(除了 IEEE 浮点数 —— NaN 破坏了基本的布尔逻辑)

`a > b` 被转换为 `b < a`。
`a in b` 被转换为 `contains(b, a)`。
`notin` 和 `isnot` 语义显然。

模板对于惰性求值特别有用。考虑一个简单处理日志的过程:

  ```nim  test = "nim c $1"
  const
    debug = true

  proc log(msg: string) {.inline.} =
    if debug: stdout.writeLine(msg)

  var
    x = 4
  log("x has the value: " & $x)
  ```

这段代码有个缺点: 如果哪天将 `debug` 设为 false，那么仍会执行相当昂贵的 `$` 和 `&` 操作!
(对过程的参数评估总是*即刻执行*的)。

将 `log` 过程转换为模板可以解决这个问题:

  ```nim  test = "nim c $1"
  const
    debug = true

  template log(msg: string) =
    if debug: stdout.writeLine(msg)

  var
    x = 4
  log("x has the value: " & $x)
  ```

参数的类型可以是普通类型或元类型 `untyped`, `typed` 或 `type`。 `type` 表示只能将类型符号
作为参数给出，而 `untyped` 表示在将表达式传递给模板之前不执行符号查找和类型解析。

如果模板没有明确的返回类型，它将使用 `void` 以与过程和方法保持一致。

要将语句块传递给模板，请将最后一个参数设为 `untyped`:

  ```nim  test = "nim c $1"
  template withFile(f: untyped, filename: string, mode: FileMode,
                    body: untyped) =
    let fn = filename
    var f: File
    if open(f, fn, mode):
      try:
        body
      finally:
        close(f)
    else:
      quit("cannot open: " & fn)

  withFile(txt, "ttempl3.txt", fmWrite):
    txt.writeLine("line 1")
    txt.writeLine("line 2")
  ```

在这个示例中，有两个 `writeLine` 语句绑定到 `body` 参数。`withFile` 模板包含样板代码，
这有助于避免一个常见的错误: 忘记关闭文件。注意 `let fn = filename` 语句是如何确保
`filename` 只评估一次的。

例: 提升过程
----------------------

  `````nim  test = "nim c $1"
  import std/math

  template liftScalarProc(fname) =
    ## Lift a proc taking one scalar parameter and returning a
    ## scalar value (eg `proc sssss[T](x: T): float`),
    ## to provide templated procs that can handle a single
    ## parameter of seq[T] or nested seq[seq[]] or the same type
    ##
    ##   ```Nim
    ##   liftScalarProc(abs)
    ##   # now abs(@[@[1,-2], @[-2,-3]]) == @[@[1,2], @[2,3]]
    ##   ```
    proc fname[T](x: openarray[T]): auto =
      var temp: T
      type outType = typeof(fname(temp))
      result = newSeq[outType](x.len)
      for i in 0..<x.len:
        result[i] = fname(x[i])

  liftScalarProc(sqrt)   # make sqrt() work for sequences
  echo sqrt(@[4.0, 16.0, 25.0, 36.0])   # => @[2.0, 4.0, 5.0, 6.0]
  `````

编译成 JavaScript
=========================

Nim 代码可编译成 JavaScript。但为了写出与 JavaScript 兼容的代码，你应遵循一下几条:
- `addr` 和 `ptr` 在 JavaScript 中的语义略有不同。如果你不确定它们是如何转换为 JavaScript 的，
  建议你避免使用它们。
- JavaScript 中的 `cast[T](x)` 被翻译为 `(x)`，除了有符号 / 无符号整数之间的转换。在这种情况下，
  它的行为类似于 C 语言中的静态转换。
- JavaScript 中的 `cstring` 表示 JavaScript 字符串。一种好的做法是在仅在语义合适时才使用 `cstring` 
  例如，不要使用 `cstring` 作为二进制数据缓冲区。


第 3 部分
==============

下部分将用整章讲述基于宏的元编程: [第 III 部分](tut3.html).
