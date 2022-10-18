{==+==}
======================
Nim Tutorial (Part II)
======================
{==+==}
==============================
Nim 教程 (第 II 部分)
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
> "Repetition renders the ridiculous reasonable." -- Norman Wildberger
{==+==}
> "Repetition renders the ridiculous reasonable." -- Norman Wildberger
{==+==}

{==+==}
This document is a tutorial for the advanced constructs of the *Nim*
programming language. **Note that this document is somewhat obsolete as the**
[manual](manual.html) **contains many more examples of the advanced language
features.**
{==+==}
本文档是*Nim* 编程语言的高级结构的教程。**请注意，此文档有些过时，因为** [manual](manual.html)
**包含更多高级语言功能的示例。**
{==+==}


{==+==}
Pragmas
=======
{==+==}
编译指示
================
{==+==}

{==+==}
Pragmas are Nim's method to give the compiler additional information/
commands without introducing a massive number of new keywords. Pragmas are
enclosed in the special `{.` and `.}` curly dot brackets. This tutorial
does not cover pragmas. See the [manual](manual.html#pragmas) or [user guide](
nimc.html#additional-features) for a description of the available
pragmas.
{==+==}
Pragmas 是 Nim 为编译器提供额外信息/命令而不引入大量新关键字的方法。
Pragma 包含在特殊的 `{.` 和 `.}` 大括号中。 本教程不包括 pragma。
请参阅 [manual](manual.html#pragmas) 或 [user guide](nimc.html#additional-features)
了解可用 pragma 的说明。
{==+==}


{==+==}
Object Oriented Programming
===========================
{==+==}
面向对象编程
===========================
{==+==}

{==+==}
While Nim's support for object oriented programming (OOP) is minimalistic,
powerful OOP techniques can be used. OOP is seen as *one* way to design a
program, not *the only* way. Often a procedural approach leads to simpler
and more efficient code. In particular, preferring composition over inheritance
is often the better design.
{==+==}
虽然 Nim 对面向对象编程 (OOP) 的支持很简单，但可以使用强大的 OOP 技术。
OOP 被视为设计程序的*一种*方式，而不是*唯一*方式。 通常，过程方法会导致更简单和更有效的代码。
特别是，优先组合而不是继承通常是更好的设计。
{==+==}


{==+==}
Inheritance
-----------
{==+==}
继承
-----------
{==+==}

{==+==}
Inheritance in Nim is entirely optional. To enable inheritance with
runtime type information the object needs to inherit from
`RootObj`.  This can be done directly, or indirectly by
inheriting from an object that inherits from `RootObj`.  Usually
types with inheritance are also marked as `ref` types even though
this isn't strictly enforced. To check at runtime if an object is of a certain
type, the `of` operator can be used.
{==+==}
Nim 中的继承是完全可选的。要使用运行时类型信息启用继承，对象需要从 RootObj 继承。
这可以直接或间接地通过从继承自 RootObj 的对象继承来完成。通常具有继承的类型也被标记为 `ref` 类型，
即使这不是严格执行的。要在运行时检查对象是否属于某种类型，可以使用 `of` 运算符。
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
Inheritance is done with the `object of` syntax. Multiple inheritance is
currently not supported. If an object type has no suitable ancestor, `RootObj`
can be used as its ancestor, but this is only a convention. Objects that have
no ancestor are implicitly `final`. You can use the `inheritable` pragma
to introduce new object roots apart from `system.RootObj`. (This is used
in the GTK wrapper for instance.)
{==+==}
继承是使用 `object of` 语法完成的。当前不支持多重继承。如果一个对象类型没有合适的祖先，
`RootObj` 可以用作它的祖先，但这只是一个约定。没有祖先的对象是隐含的`final`。
您可以使用 `inheritable` pragma 来引入除 `system.RootObj` 之外的新对象根。
(例如，这在 GTK 包装器中使用)
{==+==}

{==+==}
Ref objects should be used whenever inheritance is used. It isn't strictly
necessary, but with non-ref objects, assignments such as `let person: Person =
Student(id: 123)` will truncate subclass fields.
{==+==}
每当使用继承时，都应该使用 Ref 对象。这不是绝对必要的，但是对于非 ref 对象，诸如
`let person: Person = Student(id: 123)` 之类的赋值将截断子类字段。
{==+==}

{==+==}
**Note**: Composition (*has-a* relation) is often preferable to inheritance
(*is-a* relation) for simple code reuse. Since objects are value types in
Nim, composition is as efficient as inheritance.
{==+==}
**注意**: 对于简单的代码重用，组合(*has-a* 关系)通常优于继承(*is-a* 关系)。
由于对象是 Nim 中的值类型，因此组合与继承一样有效。
{==+==}


{==+==}
Mutually recursive types
------------------------
{==+==}
相互递归类型
------------------------
{==+==}

{==+==}
Objects, tuples and references can model quite complex data structures which
depend on each other; they are *mutually recursive*. In Nim
these types can only be declared within a single type section. (Anything else
would require arbitrary symbol lookahead which slows down compilation.)
{==+==}
对象、元组和引用可以对相互依赖的相当复杂的数据结构进行建模; 它们是*相互递归的*。
在 Nim 中，这些类型只能在单个类型部分中声明。(其他任何事情都需要任意符号前瞻，这会减慢编译速度)
{==+==}

{==+==}
Example:
{==+==}
例:
{==+==}

{==+==}
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
{==+==}
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
{==+==}


{==+==}
Type conversions
----------------
Nim distinguishes between `type casts`:idx: and `type conversions`:idx:.
Casts are done with the `cast` operator and force the compiler to
interpret a bit pattern to be of another type.
{==+==}
类型转换
----------------
Nim 区分 `type cast`:idx: 和 `type conversions`:idx:。
强制转换使用 `cast` 运算符完成，并强制编译器将位模式解释为另一种类型。
{==+==}

{==+==}
Type conversions are a much more polite way to convert a type into another:
They preserve the abstract *value*, not necessarily the *bit-pattern*. If a
type conversion is not possible, the compiler complains or an exception is
raised.
{==+==}
类型转换是将一种类型转换为另一种类型的一种更为礼貌的方式: 它们保留抽象的 *value*，
不一定是 *bit-pattern*。如果无法进行类型转换，编译器会抱怨或引发异常。
{==+==}

{==+==}
The syntax for type conversions is `destination_type(expression_to_convert)`
(like an ordinary call):
{==+==}
类型转换的语法是 `destination_type(expression_to_convert)` (就像一个普通的调用):
{==+==}

{==+==}
  ```nim
  proc getID(x: Person): int =
    Student(x).id
  ```
{==+==}
  ```nim
  proc getID(x: Person): int =
    Student(x).id
  ```
{==+==}

{==+==}
The `InvalidObjectConversionDefect` exception is raised if `x` is not a
`Student`.
{==+==}
如果 `x` 不是 `Student`，则会引发 `InvalidObjectConversionDefect` 异常。
{==+==}


{==+==}
Object variants
---------------
Often an object hierarchy is overkill in certain situations where simple
variant types are needed.
{==+==}
对象变体
---------------
在某些需要简单变体类型的情况下，对象层次结构通常是多余的。
{==+==}

{==+==}
An example:
{==+==}
一个例子:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
As can been seen from the example, an advantage to an object hierarchy is that
no conversion between different object types is needed. Yet, access to invalid
object fields raises an exception.
{==+==}
从示例中可以看出，对象层次结构的一个优点是不需要在不同对象类型之间进行转换。
然而，对无效对象字段的访问会引发异常。
{==+==}


{==+==}
Method call syntax
------------------
{==+==}
方法调用语法
------------------------
{==+==}

{==+==}
There is a syntactic sugar for calling routines:
The syntax `obj.methodName(args)` can be used
instead of `methodName(obj, args)`.
If there are no remaining arguments, the parentheses can be omitted:
`obj.len` (instead of `len(obj)`).
{==+==}
调用例程有一个语法糖：可以使用语法 `obj.methodName(args)`
代替 `methodName(obj, args)`。如果没有剩余参数，可以省略括号:
`obj.len` (而不是`len(obj)`)。
{==+==}

{==+==}
This method call syntax is not restricted to objects, it can be used
for any type:
{==+==}
此方法调用语法不限于对象，它可以用于任何类型:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/strutils

  echo "abc".len # is the same as echo len("abc")
  echo "abc".toUpperAscii()
  echo({'a', 'b', 'c'}.card)
  stdout.writeLine("Hallo") # the same as writeLine(stdout, "Hallo")
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/strutils

  echo "abc".len # is the same as echo len("abc")
  echo "abc".toUpperAscii()
  echo({'a', 'b', 'c'}.card)
  stdout.writeLine("Hallo") # the same as writeLine(stdout, "Hallo")
  ```
{==+==}

{==+==}
(Another way to look at the method call syntax is that it provides the missing
postfix notation.)
{==+==}
(查看方法调用语法的另一种方式是它提供了缺少的后缀符号)
{==+==}

{==+==}
So "pure object oriented" code is easy to write:
{==+==}
所以 "纯面向对象" 的代码很容易编写:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/[strutils, sequtils]

  stdout.writeLine("Give a list of numbers (separated by spaces): ")
  stdout.write(stdin.readLine.splitWhitespace.map(parseInt).max.`$`)
  stdout.writeLine(" is the maximum!")
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/[strutils, sequtils]

  stdout.writeLine("Give a list of numbers (separated by spaces): ")
  stdout.write(stdin.readLine.splitWhitespace.map(parseInt).max.`$`)
  stdout.writeLine(" is the maximum!")
  ```
{==+==}


{==+==}
Properties
----------
As the above example shows, Nim has no need for *get-properties*:
Ordinary get-procedures that are called with the *method call syntax* achieve
the same. But setting a value is different; for this a special setter syntax
is needed:
{==+==}
特性
----------
如上例所示，Nim 不需要 *get-properties*：使用 *method call syntax*
调用的普通 get-procedures 实现相同。但是设置一个值是不同的; 为此，需要特殊的 setter 语法:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
(The example also shows `inline` procedures.)
{==+==}
（该示例还显示了 `inline` 过程)
{==+==}


{==+==}
The `[]` array access operator can be overloaded to provide
`array properties`:idx:\ :
{==+==}
`[]` 数组访问运算符可以重载以提供 `array properties`:idx:\ ：
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
The example is silly, since a vector is better modelled by a tuple which
already provides `v[]` access.
{==+==}
这个例子很愚蠢，因为向量最好由一个已经提供 `v[]` 访问的元组来建模。
{==+==}


{==+==}
Dynamic dispatch
----------------
{==+==}
动态分发
----------------
{==+==}

{==+==}
Procedures always use static dispatch. For dynamic dispatch replace the
`proc` keyword by `method`:
{==+==}
过程总是使用静态调度。对于动态调度，用 `method` 替换 `proc` 关键字:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
Note that in the example the constructors `newLit` and `newPlus` are procs
because it makes more sense for them to use static binding, but `eval` is a
method because it requires dynamic binding.
{==+==}
请注意，在示例中，构造函数 `newLit` 和 `newPlus` 是 procs，
因为它们使用静态绑定更有意义，但 `eval` 是一种方法，因为它需要动态绑定。
{==+==}

{==+==}
**Note:** Starting from Nim 0.20, to use multi-methods one must explicitly pass
``--multimethods:on`` when compiling.
{==+==}
**注意：** 从 Nim 0.20 开始，要使用多方法，必须在编译时显式传递 ``--multimethods:on``。
{==+==}

{==+==}
In a multi-method all parameters that have an object type are used for the
dispatching:
{==+==}
在多方法中，所有具有对象类型的参数都用于调度:
{==+==}

{==+==}
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
{==+==}
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
{==+==}


{==+==}
As the example demonstrates, invocation of a multi-method cannot be ambiguous:
Collide 2 is preferred over collide 1 because the resolution works from left to
right. Thus `Unit, Thing` is preferred over `Thing, Unit`.
{==+==}
如示例所示，多方法的调用不能模棱两可：碰撞 2 优于碰撞 1，因为分辨率从左到右起作用。
因此，`Unit, Thing` 优于 `Thing, Unit`。
{==+==}

{==+==}
**Performance note**: Nim does not produce a virtual method table, but
generates dispatch trees. This avoids the expensive indirect branch for method
calls and enables inlining. However, other optimizations like compile time
evaluation or dead code elimination do not work with methods.
{==+==}
**性能说明**：Nim 不生成虚拟方法表，而是生成调度树。这避免了方法调用昂贵的间接分支并启用内联。
但是，编译时评估或死代码消除等其他优化不适用于方法。
{==+==}


{==+==}
Exceptions
==========
{==+==}
异常
==========
{==+==}

{==+==}
In Nim exceptions are objects. By convention, exception types are
suffixed with 'Error'. The [system](system.html) module defines an
exception hierarchy that you might want to stick to. Exceptions derive from
`system.Exception`, which provides the common interface.
{==+==}
在 Nim 中，例外是对象。按照惯例，异常类型以 'Error' 为后缀。
[system](system.html) 模块定义了您可能想要坚持的异常层次结构。
异常从提供公共接口的`system.Exception`派生。
{==+==}

{==+==}
Exceptions have to be allocated on the heap because their lifetime is unknown.
The compiler will prevent you from raising an exception created on the stack.
All raised exceptions should at least specify the reason for being raised in
the `msg` field.
{==+==}
异常必须在堆上分配，因为它们的生命周期是未知的。编译器将阻止您引发在堆栈上创建的异常。
所有引发的异常至少应在 `msg` 字段中指定引发的原因。
{==+==}

{==+==}
A convention is that exceptions should be raised in *exceptional* cases,
they should not be used as an alternative method of control flow.
{==+==}
约定是在 *exceptional* 情况下应该引发异常，它们不应该用作控制流的替代方法。
{==+==}

{==+==}
Raise statement
---------------
Raising an exception is done with the `raise` statement:
{==+==}
Raise 语句
---------------
引发异常是通过 `raise` 语句完成的:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var
    e: ref OSError
  new(e)
  e.msg = "the request to the OS failed"
  raise e
  ```
{==+==}
  ```nim  test = "nim c $1"
  var
    e: ref OSError
  new(e)
  e.msg = "the request to the OS failed"
  raise e
  ```
{==+==}

{==+==}
If the `raise` keyword is not followed by an expression, the last exception
is *re-raised*. For the purpose of avoiding repeating this common code pattern,
the template `newException` in the `system` module can be used:
{==+==}
如果 `raise` 关键字后面没有跟表达式，最后一个例外是 *re-raised*。
为了避免重复这种常见的代码模式，可以使用 `system` 模块中的模板 `newException`:
{==+==}

{==+==}
  ```nim
  raise newException(OSError, "the request to the OS failed")
  ```
{==+==}
  ```nim
  raise newException(OSError, "the request to the OS failed")
  ```
{==+==}


{==+==}
Try statement
-------------
{==+==}
Try 语句
-------------
{==+==}

{==+==}
The `try` statement handles exceptions:
{==+==}
`try` 语句处理异常:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
The statements after the `try` are executed unless an exception is
raised. Then the appropriate `except` part is executed.
{==+==}
除非引发异常，否则将执行 `try` 之后的语句。然后执行适当的 `except` 部分。
{==+==}

{==+==}
The empty `except` part is executed if there is an exception that is
not explicitly listed. It is similar to an `else` part in `if`
statements.
{==+==}
如果存在未明确列出的异常，则执行空的 `except` 部分。它类似于 `if` 语句中的 `else` 部分。
{==+==}

{==+==}
If there is a `finally` part, it is always executed after the
exception handlers.
{==+==}
如果有 `finally` 部分，它总是在异常处理程序之后执行。
{==+==}

{==+==}
The exception is *consumed* in an `except` part. If an exception is not
handled, it is propagated through the call stack. This means that often
the rest of the procedure - that is not within a `finally` clause -
is not executed (if an exception occurs).
{==+==}
例外是 *consumed* 在 `except` 部分。如果未处理异常，则通过调用堆栈传播异常。
这意味着程序的其余部分——不在 `finally` 子句中——通常不会被执行(如果发生异常)。
{==+==}

{==+==}
If you need to *access* the actual exception object or message inside an
`except` branch you can use the [getCurrentException()](
system.html#getCurrentException) and [getCurrentExceptionMsg()](
system.html#getCurrentExceptionMsg) procs from the [system](system.html)
module. Example:
{==+==}
如果您需要*访问* `except` 分支中的实际异常对象或消息，您可以使用
[getCurrentException()](system.html#getCurrentException) 和
[getCurrentExceptionMsg()](system.html#getCurrentExceptionMsg) procs 从
[系统]（system.html）模块。例子:
{==+==}

{==+==}
  ```nim
  try:
    doSomethingHere()
  except:
    let
      e = getCurrentException()
      msg = getCurrentExceptionMsg()
    echo "Got exception ", repr(e), " with message ", msg
  ```
{==+==}
  ```nim
  try:
    doSomethingHere()
  except:
    let
      e = getCurrentException()
      msg = getCurrentExceptionMsg()
    echo "Got exception ", repr(e), " with message ", msg
  ```
{==+==}


{==+==}
Annotating procs with raised exceptions
---------------------------------------
{==+==}
用引发的异常注释过程
---------------------------------------
{==+==}

{==+==}
Through the use of the optional `{.raises.}` pragma you can specify that a
proc is meant to raise a specific set of exceptions, or none at all. If the
`{.raises.}` pragma is used, the compiler will verify that this is true. For
instance, if you specify that a proc raises `IOError`, and at some point it
(or one of the procs it calls) starts raising a new exception the compiler will
prevent that proc from compiling. Usage example:
{==+==}
通过使用可选的 `{.raises.}` pragma，您可以指定 proc 旨在引发一组特定的异常，或者根本不引发异常。
如果使用了 `{.raises.}` pragma，编译器将验证这是真的。例如，如果您指定 proc 引发 `IOError`，
并且在某个时候它(或它调用的其中一个 proc)开始引发新异常，则编译器将阻止该 proc 编译。使用示例:
{==+==}

{==+==}
  ```nim
  proc complexProc() {.raises: [IOError, ArithmeticDefect].} =
    ...

  proc simpleProc() {.raises: [].} =
    ...
  ```
{==+==}
  ```nim
  proc complexProc() {.raises: [IOError, ArithmeticDefect].} =
    ...

  proc simpleProc() {.raises: [].} =
    ...
  ```
{==+==}

{==+==}
Once you have code like this in place, if the list of raised exception changes
the compiler will stop with an error specifying the line of the proc which
stopped validating the pragma and the raised exception not being caught, along
with the file and line where the uncaught exception is being raised, which may
help you locate the offending code which has changed.
{==+==}
一旦你有了这样的代码，如果引发的异常列表发生更改，编译器将停止并显示一个错误，指定停止验证编译指示
的 proc 行和未捕获引发的异常，以及文件和行所在的位置引发了未捕获的异常，这可以帮助您找到已更改的违规代码。
{==+==}

{==+==}
If you want to add the `{.raises.}` pragma to existing code, the compiler can
also help you. You can add the `{.effects.}` pragma statement to your proc and
the compiler will output all inferred effects up to that point (exception
tracking is part of Nim's effect system). Another more roundabout way to
find out the list of exceptions raised by a proc is to use the Nim ``doc``
command which generates documentation for a whole module and decorates all
procs with the list of raised exceptions. You can read more about Nim's
[effect system and related pragmas in the manual](manual.html#effect-system).
{==+==}
如果您想将 `{.raises.}` 杂注添加到现有代码中，编译器也可以帮助您。
您可以将 `{.effects.}` pragma 语句添加到您的 proc 中，编译器将输出到该点的所有推断效果
(异常跟踪是 Nim 效果系统的一部分)。另一种查找 proc 引发的异常列表的更为迂回的方法是使用
Nim ``doc`` 命令，该命令为整个模块生成文档，并用引发的异常列表装饰所有 proc。
您可以阅读更多关于 Nim 的 [效果系统和手册中的相关 pragma](manual.html#effect-system)。
{==+==}


{==+==}
Generics
========
{==+==}
泛型
========
{==+==}

{==+==}
Generics are Nim's means to parametrize procs, iterators or types
with `type parameters`:idx:. Generic parameters are written within square
brackets, for example `Foo[T]`. They are most useful for efficient type safe
containers:
{==+==}
泛型是 Nim 使用 `type parameters`:idx: 参数化过程、迭代器或类型的方法。
通用参数写在方括号内，例如 `Foo[T]`。 它们对于高效的类型安全容器最有用:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
The example shows a generic binary tree. Depending on context, the brackets are
used either to introduce type parameters or to instantiate a generic proc,
iterator or type. As the example shows, generics work with overloading: the
best match of `add` is used. The built-in `add` procedure for sequences
is not hidden and is used in the `preorder` iterator.
{==+==}
该示例显示了一个通用二叉树。根据上下文，方括号用于引入类型参数或实例化泛型 proc、迭代器或类型。
如示例所示，泛型适用于重载：使用 `add` 的最佳匹配。序列的内置 `add` 过程不是隐藏的，
并且在 `preorder` 迭代器中使用。
{==+==}

{==+==}
There is a special `[:T]` syntax when using generics with the method call syntax:
{==+==}
在方法调用语法中使用泛型时有一个特殊的 `[:T]` 语法：
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc foo[T](i: T) =
    discard

  var i: int

  # i.foo[int]() # Error: expression 'foo(i)' has no type (or is ambiguous)

  i.foo[:int]() # Success
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc foo[T](i: T) =
    discard

  var i: int

  # i.foo[int]() # Error: expression 'foo(i)' has no type (or is ambiguous)

  i.foo[:int]() # Success
  ```
{==+==}


{==+==}
Templates
=========
{==+==}
模板
=========
{==+==}

{==+==}
Templates are a simple substitution mechanism that operates on Nim's
abstract syntax trees. Templates are processed in the semantic pass of the
compiler. They integrate well with the rest of the language and share none
of C's preprocessor macros flaws.
{==+==}
模板是一种在 Nim 的抽象语法树上运行的简单替换机制。模板在编译器的语义传递中处理。
它们与语言的其余部分很好地集成，并且没有 C 的预处理器宏缺陷。
{==+==}

{==+==}
To *invoke* a template, call it like a procedure.
{==+==}
要*调用*模板，请像调用过程一样调用它。
{==+==}

{==+==}
Example:
{==+==}
例:
{==+==}

{==+==}
  ```nim
  template `!=` (a, b: untyped): untyped =
    # this definition exists in the System module
    not (a == b)

  assert(5 != 6) # the compiler rewrites that to: assert(not (5 == 6))
  ```
{==+==}
  ```nim
  template `!=` (a, b: untyped): untyped =
    # this definition exists in the System module
    not (a == b)

  assert(5 != 6) # the compiler rewrites that to: assert(not (5 == 6))
  ```
{==+==}

{==+==}
The `!=`, `>`, `>=`, `in`, `notin`, `isnot` operators are in fact
templates: this has the benefit that if you overload the `==` operator,
the `!=` operator is available automatically and does the right thing. (Except
for IEEE floating point numbers - NaN breaks basic boolean logic.)
{==+==}
`!=`、`>`、`>=`、`in`、`notin`、`isnot` 运算符实际上是模板: 这样做的好处是，
如果重载 `==` 运算符，`! =` 运算符自动可用并且做正确的事情。
(除了 IEEE 浮点数 - NaN 破坏了基本的布尔逻辑)
{==+==}

{==+==}
`a > b` is transformed into `b < a`.
`a in b` is transformed into `contains(b, a)`.
`notin` and `isnot` have the obvious meanings.
{==+==}
`a > b` 被转换为 `b < a`。 `a in b` 被转换为 `contains(b, a)`。
`notin` 和 `isnot` 有明显的含义。
{==+==}

{==+==}
Templates are especially useful for lazy evaluation purposes. Consider a
simple proc for logging:
{==+==}
模板对于惰性求值特别有用。考虑一个简单的日志记录过程：
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  const
    debug = true

  proc log(msg: string) {.inline.} =
    if debug: stdout.writeLine(msg)

  var
    x = 4
  log("x has the value: " & $x)
  ```
{==+==}
  ```nim  test = "nim c $1"
  const
    debug = true

  proc log(msg: string) {.inline.} =
    if debug: stdout.writeLine(msg)

  var
    x = 4
  log("x has the value: " & $x)
  ```
{==+==}

{==+==}
This code has a shortcoming: if `debug` is set to false someday, the quite
expensive `$` and `&` operations are still performed! (The argument
evaluation for procedures is *eager*).
{==+==}
这段代码有个缺点: 如果哪天将`debug`设置为false，还是会执行相当昂贵的`$`和`&`操作!
(过程的参数评估是 *eager*)。
{==+==}

{==+==}
Turning the `log` proc into a template solves this problem:
{==+==}
将 `log` 过程转换为模板可以解决这个问题:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  const
    debug = true

  template log(msg: string) =
    if debug: stdout.writeLine(msg)

  var
    x = 4
  log("x has the value: " & $x)
  ```
{==+==}
  ```nim  test = "nim c $1"
  const
    debug = true

  template log(msg: string) =
    if debug: stdout.writeLine(msg)

  var
    x = 4
  log("x has the value: " & $x)
  ```
{==+==}

{==+==}
The parameters' types can be ordinary types or the meta types `untyped`,
`typed`, or `type`. `type` suggests that only a type symbol may be given
as an argument, and `untyped` means symbol lookups and type resolution is not
performed before the expression is passed to the template.
{==+==}
参数的类型可以是普通类型或元类型 `untyped`、`typed` 或 `type`。`type` 表示只能将类型符号
作为参数给出，而 `untyped` 表示在将表达式传递给模板之前不执行符号查找和类型解析。
{==+==}

{==+==}
If the template has no explicit return type,
`void` is used for consistency with procs and methods.
{==+==}
如果模板没有明确的返回类型，则使用 `void` 与 procs 和方法保持一致。
{==+==}

{==+==}
To pass a block of statements to a template, use `untyped` for the last parameter:
{==+==}
要将语句块传递给模板，请对最后一个参数使用 `untyped`:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
In the example the two `writeLine` statements are bound to the `body`
parameter. The `withFile` template contains boilerplate code and helps to
avoid a common bug: to forget to close the file. Note how the
`let fn = filename` statement ensures that `filename` is evaluated only
once.
{==+==}
在示例中，两个 `writeLine` 语句绑定到 `body` 参数。`withFile` 模板包含样板代码，
有助于避免一个常见的错误: 忘记关闭文件。注意 `let fn = filename` 语句如何确保
`filename` 只计算一次。
{==+==}

{==+==}
Example: Lifting Procs
----------------------
{==+==}
例: 提升过程
----------------------
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
Compilation to JavaScript
=========================
{==+==}
编译成 JavaScript
=========================
{==+==}

{==+==}
Nim code can be compiled to JavaScript. However in order to write
JavaScript-compatible code you should remember the following:
- `addr` and `ptr` have slightly different semantic meaning in JavaScript.
  It is recommended to avoid those if you're not sure how they are translated
  to JavaScript.
- `cast[T](x)` in JavaScript is translated to `(x)`, except for casting
  between signed/unsigned ints, in which case it behaves as static cast in
  C language.
- `cstring` in JavaScript means JavaScript string. It is a good practice to
  use `cstring` only when it is semantically appropriate. E.g. don't use
  `cstring` as a binary data buffer.
{==+==}
Nim 代码可以编译为 JavaScript。 但是为了写
您应该记住以下与 JavaScript 兼容的代码：
- `addr` 和 `ptr` 在 JavaScript 中的语义略有不同。如果您不确定它们是如何转换为 JavaScript 的，
  建议您避免使用它们。
- JavaScript 中的 `cast[T](x)` 被翻译为 `(x)`，除了有符号/无符号整数之间的转换，在这种情况下，
  它的行为类似于 C 语言中的静态转换。
- JavaScript 中的 `cstring` 表示 JavaScript 字符串。 仅在语义合适时才使用 `cstring` 
  是一种很好的做法。 例如。 不要使用 `cstring` 作为二进制数据缓冲区。
{==+==}


{==+==}
Part 3
======
{==+==}
第 3 部分
==============
{==+==}

{==+==}
The next part is entirely about metaprogramming via macros: [Part III](tut3.html).
{==+==}
下部分: [第 III 部分](tut3.html).
{==+==}
