{==+==}
Var return type
---------------
{==+==}
Var 返回类型
------------------------
{==+==}

{==+==}
A proc, converter, or iterator may return a `var` type which means that the
returned value is an l-value and can be modified by the caller:
{==+==}
过程、转换器或者迭代器可以返回 `var` 类型，表示返回的是一个左值，调用者可以修改它:
{==+==}

{==+==}
  ```nim
  var g = 0

  proc writeAccessToG(): var int =
    result = g

  writeAccessToG() = 6
  assert g == 6
  ```
{==+==}
  ```nim
  var g = 0

  proc writeAccessToG(): var int =
    result = g

  writeAccessToG() = 6
  assert g == 6
  ```
{==+==}

{==+==}
It is a static error if the implicitly introduced pointer could be
used to access a location beyond its lifetime:
{==+==}
如果利用隐式创建的指向某东西的指针有可能这个东西的生存期之外继续访问它，那末编译器会报告静态错误:
{==+==}

{==+==}
  ```nim
  proc writeAccessToG(): var int =
    var g = 0
    result = g # Error!
  ```
{==+==}
  ```nim
  proc writeAccessToG(): var int =
    var g = 0
    result = g # 错误!
  ```
{==+==}

{==+==}
For iterators, a component of a tuple return type can have a `var` type too:
{==+==}
当迭代器返回元组时，元组的元素也可以是 `var` 类型:
{==+==}

{==+==}
  ```nim
  iterator mpairs(a: var seq[string]): tuple[key: int, val: var string] =
    for i in 0..a.high:
      yield (i, a[i])
  ```
{==+==}
  ```nim
  iterator mpairs(a: var seq[string]): tuple[key: int, val: var string] =
    for i in 0..a.high:
      yield (i, a[i])
  ```
{==+==}

{==+==}
In the standard library every name of a routine that returns a `var` type
starts with the prefix `m` per convention.
{==+==}
在标准库中，所有返回 `var` 类型的例程，都遵循以 `m` 为前缀的命名规范。
{==+==}

{==+==}
.. include:: manual/var_t_return.md
{==+==}
.. include:: manual/var_t_return.md
{==+==}

{==+==}
### Future directions
{==+==}
### 未来的方向
{==+==}

{==+==}
Later versions of Nim can be more precise about the borrowing rule with
a syntax like:
{==+==}
新版本的 Nim 借用规则将更加准确，比如使用这样的语法:
{==+==}

{==+==}
  ```nim
  proc foo(other: Y; container: var X): var T from container
  ```
{==+==}
  ```nim
  proc foo(other: Y; container: var X): var T from container
  ```
{==+==}

{==+==}
Here `var T from container` explicitly exposes that the
location is derived from the second parameter (called
'container' in this case). The syntax `var T from p` specifies a type
`varTy[T, 2]` which is incompatible with `varTy[T, 1]`.
{==+==}
这里的 `var T from contaner` 显式指定了返回值的地址必须源自第二个参数(本例的 'container')。
`var T from p` 语句指定了类型 `varTy[T, 2]`，与 `varTy[T, 1]` 类型不兼容。
{==+==}

{==+==}
NRVO
----
{==+==}
具名返回值优化 (NRVO)
------------------------------------------
{==+==}

{==+==}
**Note**: This section describes the current implementation. This part
of the language specification will be changed.
See https://github.com/nim-lang/RFCs/issues/230 for more information.
{==+==}
**注意**: 本节文档仅描述当前的实现。这部分语言规范将会有变动。
详情请查看链接 https://github.com/nim-lang/RFCs/issues/230 。
{==+==}

{==+==}
The return value is represented inside the body of a routine as the special
`result`:idx: variable. This allows for a mechanism much like C++'s
"named return value optimization" (`NRVO`:idx:). NRVO means that the stores
to `result` inside `p` directly affect the destination `dest`
in `let/var dest = p(args)` (definition of `dest`) and also in `dest = p(args)`
(assignment to `dest`). This is achieved by rewriting `dest = p(args)`
to `p'(args, dest)` where `p'` is a variation of `p` that returns `void` and
receives a hidden mutable parameter representing `result`.
{==+==}
在例程内部返回值以特殊的 `result`:idx: 变量出现。这为实现与 C++ 的 "具名返回值优化" (`NRVO`:idx:) 类似的机制创造了条件。
NRVO 指的是 `p` 内对 `result` 的操作会直接影响 `let/var dest = p(args)` (定义 `dest`) 或 `dest = p(args)` (给 `dest` 赋值) 中的目标 `dest` 。
这是通过将 `dest = p(args)` 重写为 `p'(args, dest)` 来实现的，其中 `p'` 是 `p` 的变体，它返回 `void` 并且接收一个与 `result` 对应的可变参数。
{==+==}

{==+==}
Informally:
{==+==}
不太正式的示例:
{==+==}

{==+==}
  ```nim
  proc p(): BigT = ...

  var x = p()
  x = p()

  # is roughly turned into:

  proc p(result: var BigT) = ...

  var x; p(x)
  p(x)
  ```
{==+==}
  ```nim
  proc p(): BigT = ...

  var x = p()
  x = p()

  # 上面这段代码大体上会被翻译为如下代码

  proc p(result: var BigT) = ...

  var x; p(x)
  p(x)
  ```
{==+==}

{==+==}
Let `T`'s be `p`'s return type. NRVO applies for `T`
if `sizeof(T) >= N` (where `N` is implementation dependent),
in other words, it applies for "big" structures.
{==+==}
假设 `p` 的返回值类型为 `T`。
当 `sizeof(T) >= N` (`N` 依赖于具体实现) 时，编译器就会使用 NRVO。
换句话说，NRVO 适用于 "较大" 的结构体。
{==+==}

{==+==}
If `p` can raise an exception, NRVO applies regardless. This can produce
observable differences in behavior:
{==+==}
即使 `p` 可能抛出异常，也会使用 NRVO。这时，可观察到 NRVO 带来的不同行为:
{==+==}

{==+==}
  ```nim
  type
    BigT = array[16, int]

  proc p(raiseAt: int): BigT =
    for i in 0..high(result):
      if i == raiseAt: raise newException(ValueError, "interception")
      result[i] = i

  proc main =
    var x: BigT
    try:
      x = p(8)
    except ValueError:
      doAssert x == [0, 1, 2, 3, 4, 5, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0]

  main()
  ```
{==+==}
  ```nim
  type
    BigT = array[16, int]

  proc p(raiseAt: int): BigT =
    for i in 0..high(result):
      if i == raiseAt: raise newException(ValueError, "interception")
      result[i] = i

  proc main =
    var x: BigT
    try:
      x = p(8)
    except ValueError:
      doAssert x == [0, 1, 2, 3, 4, 5, 6, 7, 0, 0, 0, 0, 0, 0, 0, 0]

  main()
  ```
{==+==}

{==+==}
The compiler can produce a warning in these cases, however this behavior is
turned off by default. It can be enabled for a section of code via the
`warning[ObservableStores]` and `push`/`pop` pragmas. Take the above code
as an example:

  ```nim
  {.push warning[ObservableStores]: on.}
  main()
  {.pop.}
  ```
{==+==}
编译器能够检测这些情况并发出警告，但是这个行为默认是关闭的。通过 `warning[ObservableStores]` 以及 `push`/`pop`
编译指示可以为一段代码打开这个警告。以上面的代码为例：

  ```nim
  {.push warning[ObservableStores]: on.}
  main()
  {.pop.}
  ```
{==+==}

{==+==}
Overloading of the subscript operator
-------------------------------------
{==+==}
重载下标运算符
----------------------------
{==+==}

{==+==}
The `[]` subscript operator for arrays/openarrays/sequences can be overloaded.
{==+==}
数组/开放数组/序列的 `[]` 下标运算符可以被重载。
{==+==}

{==+==}
Methods
=============
{==+==}
方法
========
{==+==}

{==+==}
Procedures always use static dispatch. Methods use dynamic
dispatch. For dynamic dispatch to work on an object it should be a reference
type.
{==+==}
过程总是静态派发，而方法则使用动态派发。为了将动态派发用于对象，对象必须是引用类型。
{==+==}

{==+==}
  ```nim
  type
    Expression = ref object of RootObj ## abstract base class for an expression
    Literal = ref object of Expression
      x: int
    PlusExpr = ref object of Expression
      a, b: Expression

  method eval(e: Expression): int {.base.} =
    # override this base method
    raise newException(CatchableError, "Method without implementation override")

  method eval(e: Literal): int = return e.x

  method eval(e: PlusExpr): int =
    # watch out: relies on dynamic binding
    result = eval(e.a) + eval(e.b)

  proc newLit(x: int): Literal =
    new(result)
    result.x = x

  proc newPlus(a, b: Expression): PlusExpr =
    new(result)
    result.a = a
    result.b = b

  echo eval(newPlus(newPlus(newLit(1), newLit(2)), newLit(4)))
  ```
{==+==}
  ```nim
  type
    Expression = ref object of RootObj ## 表达式的抽象基类
    Literal = ref object of Expression
      x: int
    PlusExpr = ref object of Expression
      a, b: Expression

  method eval(e: Expression): int {.base.} =
    # 一定要重写这个基方法
    raise newException(CatchableError, "未重写基方法")

  method eval(e: Literal): int = return e.x

  method eval(e: PlusExpr): int =
    # 注意: 这里依赖于动态绑定
    result = eval(e.a) + eval(e.b)

  proc newLit(x: int): Literal =
    new(result)
    result.x = x

  proc newPlus(a, b: Expression): PlusExpr =
    new(result)
    result.a = a
    result.b = b

  echo eval(newPlus(newPlus(newLit(1), newLit(2)), newLit(4)))
  ```
{==+==}

{==+==}
In the example the constructors `newLit` and `newPlus` are procs
because they should use static binding, but `eval` is a method because it
requires dynamic binding.
{==+==}
在这个例子中，构造函数 `newLit` 和 `newPlus` 都是过程，因为它们都使用静态方法匹配，但是 `eval` 是方法因为需要动态绑定。
{==+==}

{==+==}
As can be seen in the example, base methods have to be annotated with
the `base`:idx: pragma. The `base` pragma also acts as a reminder for the
programmer that a base method `m` is used as the foundation to determine all
the effects that a call to `m` might cause.
{==+==}
正如这个例子所示，基方法必须使用 `base`:idx: 编译指示修饰。`base` 编译指示对于开发者来说也是一种提醒: 这个基方法 `m` 是推断方法 `m`
所能产生的所有效果的一个基础。
{==+==}


{==+==}
**Note**: Compile-time execution is not (yet) supported for methods.
{==+==}
**注意**: 目前还不支持方法的编译期执行。
{==+==}

{==+==}
**Note**: Starting from Nim 0.20, generic methods are deprecated.
{==+==}
**注意**: 从 Nim 0.20 开始，泛型方法已被弃用。
{==+==}

{==+==}
Multi-methods
--------------
{==+==}
多重方法 (Multi-methods)
----------------------------------------
{==+==}

{==+==}
**Note:** Starting from Nim 0.20, to use multi-methods one must explicitly pass
`--multimethods:on`:option: when compiling.
{==+==}
**Note** 从 Nim 0.20 开始，要启用多重方法，开发者必须在编译时显式添加 `--multimethods:on`:option: 参数。
{==+==}

{==+==}
In a multi-method, all parameters that have an object type are used for the
dispatching:
{==+==}
在多重方法中，所有对象类型的参数都会用于方法派发:
{==+==}

{==+==}
  ```nim  test = "nim c --multiMethods:on $1"
  type
    Thing = ref object of RootObj
    Unit = ref object of Thing
      x: int

  method collide(a, b: Thing) {.inline.} =
    quit "to override!"

  method collide(a: Thing, b: Unit) {.base, inline.} =
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

  method collide(a, b: Thing) {.base, inline.} =
    quit "别忘了重写!"

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
Inhibit dynamic method resolution via procCall
-----------------------------------------------
{==+==}
通过 proCall 防止动态方法解析
----------------------------------------------------------
{==+==}

{==+==}
Dynamic method resolution can be inhibited via the builtin `system.procCall`:idx:.
This is somewhat comparable to the `super`:idx: keyword that traditional OOP
languages offer.
{==+==}
通过调用内置的 `system.procCall`:idx: 可以防止动态方法解析。
某种程度上它与传统面向对象语言提供的 `super`:idx: 关键字类似。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    Thing = ref object of RootObj
    Unit = ref object of Thing
      x: int

  method m(a: Thing) {.base.} =
    echo "base"

  method m(a: Unit) =
    # Call the base method:
    procCall m(Thing(a))
    echo "1"
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    Thing = ref object of RootObj
    Unit = ref object of Thing
      x: int

  method m(a: Thing) {.base.} =
    echo "base"

  method m(a: Unit) =
    # 调用基方法:
    procCall m(Thing(a))
    echo "1"
  ```
{==+==}


{==+==}
Iterators and the for statement
===============================
{==+==}
迭代器与 for 循环语句
==========================================
{==+==}

{==+==}
The `for`:idx: statement is an abstract mechanism to iterate over the elements
of a container. It relies on an `iterator`:idx: to do so. Like `while`
statements, `for` statements open an `implicit block`:idx: so that they
can be left with a `break` statement.
{==+==}
`for`:idx 语句是一种迭代容器中元素的抽象机制。它依赖于 `iterator`:idx: "迭代器"来实现。与 `while` 语句类似，`for` 语句也开启了一个 `implicit block`:idx: "隐式代码块"，也就可以使用 `break` 语句。
{==+==}

{==+==}
The `for` loop declares iteration variables - their scope reaches until the
end of the loop body. The iteration variables' types are inferred by the
return type of the iterator.
{==+==}
`for` 循环声明了迭代变量 - 它们的生命周期持续到循环体的结束。迭代变量的类型根据迭代器的返回值类型推断。
{==+==}

{==+==}
An iterator is similar to a procedure, except that it can be called in the
context of a `for` loop. Iterators provide a way to specify the iteration over
an abstract type. The `yield` statement in the called iterator plays a key
role in the execution of a `for` loop. Whenever a `yield` statement is
reached, the data is bound to the `for` loop variables and control continues
in the body of the `for` loop. The iterator's local variables and execution
state are automatically saved between calls. Example:
{==+==}
迭代器与过程类似，不过迭代器只能在 `for` 循环的上下文中调用。迭代器提供了一种遍历抽象类型的方法。
迭代器里的 `yield` 语句对于 `for` 循环的执行至关重要。当程序执行到 `yield` 语句时，数据会绑定
到 `for` 循环变量，同时控制权也移交到循环体并继续执行。迭代器的局部变量和执行状态在多次调用期间会自动保存。
例如:
{==+==}

{==+==}
  ```nim
  # this definition exists in the system module
  iterator items*(a: string): char {.inline.} =
    var i = 0
    while i < len(a):
      yield a[i]
      inc(i)

  for ch in items("hello world"): # `ch` is an iteration variable
    echo ch
  ```
{==+==}
  ```nim
  # system 模块中存在如下定义
  iterator items*(a: string): char {.inline.} =
    var i = 0
    while i < len(a):
      yield a[i]
      inc(i)

  for ch in items("hello world"): # `ch` 是迭代器变量
    echo ch
  ```
{==+==}

{==+==}
The compiler generates code as if the programmer had written this:
{==+==}
编译器会生成如下代码，就像是开发者写的一样:
{==+==}

{==+==}
  ```nim
  var i = 0
  while i < len(a):
    var ch = a[i]
    echo ch
    inc(i)
  ```
{==+==}
  ```nim
  var i = 0
  while i < len(a):
    var ch = a[i]
    echo ch
    inc(i)
  ```
{==+==}

{==+==}
If the iterator yields a tuple, there can be as many iteration variables
as there are components in the tuple. The i'th iteration variable's type is
the type of the i'th component. In other words, implicit tuple unpacking in a
for loop context is supported.
{==+==}
如果迭代器的 `yield` 语句产生的是元组，那么可以有多个循环变量，个数等于元组的元素数。
第 i 次循环变量的类型就是元组第 i 个元素的类型。换句话说，循环上下文支持隐式元组拆包。
{==+==}

{==+==}
Implicit items/pairs invocations
--------------------------------
{==+==}
隐式 items/pairs 调用
------------------------------------------
{==+==}

{==+==}
If the for loop expression `e` does not denote an iterator and the for loop
has exactly 1 variable, the for loop expression is rewritten to `items(e)`;
i.e. an `items` iterator is implicitly invoked:
{==+==}
如果循环表达式 `e` 不是迭代器并且 for 循环只有一个循环变量，则循环表达式会被重写为 `items(e)`；
即隐式调用 `items` 迭代器:
{==+==}

{==+==}
  ```nim
  for x in [1,2,3]: echo x
  ```
{==+==}
  ```nim
  for x in [1,2,3]: echo x
  ```
{==+==}

{==+==}
If the for loop has exactly 2 variables, a `pairs` iterator is implicitly
invoked.
{==+==}
如果循环恰好有两个循环变量，则隐式调用 `pairs` 迭代器。
{==+==}

{==+==}
Symbol lookup of the identifiers `items`/`pairs` is performed after
the rewriting step, so that all overloads of `items`/`pairs` are taken
into account.
{==+==}
`items`/`pairs` 标识符的符号查找在编译器重写之后执行，所以 `items`/`pairs` 的所有重载都能生效。
{==+==}


{==+==}
First-class iterators
---------------------
{==+==}
一等迭代器
------------------------
{==+==}

{==+==}
There are 2 kinds of iterators in Nim: *inline* and *closure* iterators.
An `inline iterator`:idx: is an iterator that's always inlined by the compiler
leading to zero overhead for the abstraction, but may result in a heavy
increase in code size.
{==+==}
Nim 中有两种迭代器: *inline* (内联)和 *closure* (闭包)迭代器。
`inline iterator`:idx: "内联迭代器" 总是被编译器内联优化，
这种抽象也就不会带来任何额外开销(零成本抽象)，但可能代码体积可能大大增加。
{==+==}

{==+==}
Caution: the body of a for loop over an inline iterator is inlined into
each `yield` statement appearing in the iterator code,
so ideally the code should be refactored to contain a single yield when possible
to avoid code bloat.
{==+==}
请警惕:  在使用内联迭代器时，循环体会被内联进循环中所有的 `yield` 语句里，所以理想情况是合理地重构迭代器代码使它只包含一条 yield 语句，以免代码体积膨胀。
{==+==}

{==+==}
Inline iterators are second class citizens;
They can be passed as parameters only to other inlining code facilities like
templates, macros, and other inline iterators.
{==+==}
内联迭代器是二等公民；它们只能作为参数传递给其他内联代码工具，如模板、宏和其他内联迭代器。
{==+==}

{==+==}
In contrast to that, a `closure iterator`:idx: can be passed around more freely:
{==+==}
相反，`closure iterator`:idx: "闭包迭代器" 可以更自由地传递:
{==+==}

{==+==}
  ```nim
  iterator count0(): int {.closure.} =
    yield 0

  iterator count2(): int {.closure.} =
    var x = 1
    yield x
    inc x
    yield x

  proc invoke(iter: iterator(): int {.closure.}) =
    for x in iter(): echo x

  invoke(count0)
  invoke(count2)
  ```
{==+==}
  ```nim
  iterator count0(): int {.closure.} =
    yield 0

  iterator count2(): int {.closure.} =
    var x = 1
    yield x
    inc x
    yield x

  proc invoke(iter: iterator(): int {.closure.}) =
    for x in iter(): echo x

  invoke(count0)
  invoke(count2)
  ```
{==+==}

{==+==}
Closure iterators and inline iterators have some restrictions:
{==+==}
闭包迭代器和内联迭代器都有一些限制:
{==+==}

{==+==}
1. For now, a closure iterator cannot be executed at compile time.
2. `return` is allowed in a closure iterator but not in an inline iterator
   (but rarely useful) and ends the iteration.
3. Inline iterators cannot be recursive.
4. Neither inline nor closure iterators have the special `result` variable.
5. Closure iterators are not supported by the JS backend.
{==+==}
1. 目前，闭包迭代器不能在编译期执行。
2. 闭包迭代器可使用 `return` 语句结束循环，但内联迭代器(虽然基本没什么用)不允许使用。
3. 内联迭代器不能递归。
4. 内联迭代器与闭包迭代器都没有特殊的 `result` 变量。
5. JS 后端不支持闭包迭代器。
{==+==}

{==+==}
Iterators that are neither marked `{.closure.}` nor `{.inline.}` explicitly
default to being inline, but this may change in future versions of the
implementation.
{==+==}
如果既不用 `{.closure.}` 也不用 `{.inline.}` 显式标记迭代器，则默认为内联迭代器。但是将来的版本可能会改动。
{==+==}

{==+==}
The `iterator` type is always of the calling convention `closure`
implicitly; the following example shows how to use iterators to implement
a `collaborative tasking`:idx: system:
{==+==}
`iterator` 类型总是约定隐式使用 `closure` 调用规范；下面的例子展示了如何使用迭代器实现一个 `collaborative tasking`:idx:
"协作任务" 系统:
{==+==}

{==+==}
  ```nim
  # simple tasking:
  type
    Task = iterator (ticker: int)

  iterator a1(ticker: int) {.closure.} =
    echo "a1: A"
    yield
    echo "a1: B"
    yield
    echo "a1: C"
    yield
    echo "a1: D"

  iterator a2(ticker: int) {.closure.} =
    echo "a2: A"
    yield
    echo "a2: B"
    yield
    echo "a2: C"

  proc runTasks(t: varargs[Task]) =
    var ticker = 0
    while true:
      let x = t[ticker mod t.len]
      if finished(x): break
      x(ticker)
      inc ticker

  runTasks(a1, a2)
  ```
{==+==}
  ```nim
  # simple tasking:
  type
    Task = iterator (ticker: int)

  iterator a1(ticker: int) {.closure.} =
    echo "a1: A"
    yield
    echo "a1: B"
    yield
    echo "a1: C"
    yield
    echo "a1: D"

  iterator a2(ticker: int) {.closure.} =
    echo "a2: A"
    yield
    echo "a2: B"
    yield
    echo "a2: C"

  proc runTasks(t: varargs[Task]) =
    var ticker = 0
    while true:
      let x = t[ticker mod t.len]
      if finished(x): break
      x(ticker)
      inc ticker

  runTasks(a1, a2)
  ```
{==+==}

{==+==}
The builtin `system.finished` can be used to determine if an iterator has
finished its operation; no exception is raised on an attempt to invoke an
iterator that has already finished its work.
{==+==}
可以使用内置的 `system.finished` 判断迭代器是否结束；如果迭代器已经结束，再次调用也不会抛出异常。
{==+==}

{==+==}
Note that `system.finished` is error-prone to use because it only returns
`true` one iteration after the iterator has finished:
{==+==}
请注意 `system.finished` 容易用错，因为它只在迭代器最后一次循环完成后的下一次迭代才返回 `true`:
{==+==}

{==+==}
  ```nim
  iterator mycount(a, b: int): int {.closure.} =
    var x = a
    while x <= b:
      yield x
      inc x

  var c = mycount # instantiate the iterator
  while not finished(c):
    echo c(1, 3)

  # Produces
  1
  2
  3
  0
  ```
{==+==}
  ```nim
  iterator mycount(a, b: int): int {.closure.} =
    var x = a
    while x <= b:
      yield x
      inc x

  var c = mycount # 实例化迭代器
  while not finished(c):
    echo c(1, 3)

  # 输出
  1
  2
  3
  0
  ```
{==+==}

{==+==}
Instead, this code has to be used:
{==+==}
所以这段代码应该这么写:
{==+==}

{==+==}
  ```nim
  var c = mycount # instantiate the iterator
  while true:
    let value = c(1, 3)
    if finished(c): break # and discard 'value'!
    echo value
  ```
{==+==}
  ```nim
  var c = mycount # 实现化迭代器
  while true:
    let value = c(1, 3)
    if finished(c): break # 丢弃这次的返回值!
    echo value
  ```
{==+==}

{==+==}
It helps to think that the iterator actually returns a
pair `(value, done)` and `finished` is used to access the hidden `done`
field.
{==+==}
为了便于理解，可以这样认为，迭代器实际上返回了键值对 `(value, done)`，而 `finished` 的作用就是访问隐藏的 `done` 字段。
{==+==}

{==+==}
Closure iterators are *resumable functions* and so one has to provide the
arguments to every call. To get around this limitation one can capture
parameters of an outer factory proc:
{==+==}
闭包迭代器是 *可恢复函数* ，因此每次调用必须提供参数。如果需要绕过这个限制，可以通过工厂过程构造闭包迭代器，并在构造的时候捕获参数:
{==+==}

{==+==}
  ```nim
  proc mycount(a, b: int): iterator (): int =
    result = iterator (): int =
      var x = a
      while x <= b:
        yield x
        inc x

  let foo = mycount(1, 4)

  for f in foo():
    echo f
  ```
{==+==}
  ```nim
  proc mycount(a, b: int): iterator (): int =
    result = iterator (): int =
      var x = a
      while x <= b:
        yield x
        inc x

  let foo = mycount(1, 4)

  for f in foo():
    echo f
  ```
{==+==}

{==+==}
The call can be made more like an inline iterator with a for loop macro:
{==+==}
借助 for 循环宏可以把这个函数调用变得像是在使用内联迭代器:
{==+==}

{==+==}
  ```nim
  import std/macros
  macro toItr(x: ForLoopStmt): untyped =
    let expr = x[0]
    let call = x[1][1] # Get foo out of toItr(foo)
    let body = x[2]
    result = quote do:
      block:
        let itr = `call`
        for `expr` in itr():
            `body`

  for f in toItr(mycount(1, 4)): # using early `proc mycount`
    echo f
  ```
{==+==}
  ```nim
  import std/macros
  macro toItr(x: ForLoopStmt): untyped =
    let expr = x[0]
    let call = x[1][1] # 把 foo 拿从 toItr(foo) 里出来
    let body = x[2]
    result = quote do:
      block:
        let itr = `call`
        for `expr` in itr():
            `body`

  for f in toItr(mycount(1, 4)): # 使用上文的 `proc mycount`
    echo f
  ```
{==+==}

{==+==}
Because of full backend function call apparatus involvement, closure iterator
invocation is typically higher cost than inline iterators. Adornment by
a macro wrapper at the call site like this is a possibly useful reminder.
{==+==}
因为闭包迭代器需要以完整的函数调用机制作为支撑，所以代价比调用内联迭代器更高。像这样在使用闭包迭代器的地方用宏装饰一下，或许是一种有益的提醒。
{==+==}

{==+==}
The factory `proc`, as an ordinary procedure, can be recursive. The
above macro allows such recursion to look much like a recursive iterator
would. For example:
{==+==}
工厂过程 `proc` 同普通的过程一样也可以递归。利用上面的宏可让这种过程的递归看起来像是递归迭代器在递归。比如:
{==+==}

{==+==}
  ```nim
  proc recCountDown(n: int): iterator(): int =
    result = iterator(): int =
      if n > 0:
        yield n
        for e in toItr(recCountDown(n - 1)):
          yield e

  for i in toItr(recCountDown(6)): # Emits: 6 5 4 3 2 1
    echo i
  ```
{==+==}
  ```nim
  proc recCountDown(n: int): iterator(): int =
    result = iterator(): int =
      if n > 0:
        yield n
        for e in toItr(recCountDown(n - 1)):
          yield e

  for i in toItr(recCountDown(6)): # 输出: 6 5 4 3 2 1
    echo i
  ```
{==+==}


{==+==}
See also see `iterable <#overloading-resolution-iterable>`_ for passing iterators to templates and macros.
{==+==}
关于如何给模板和宏传递迭代器，可以看这一节 `迭代器 <#overloading-resolution-iterable>`_ 。
{==+==}

{==+==}
Converters
==========
{==+==}
转换器
============
{==+==}

{==+==}
A converter is like an ordinary proc except that it enhances
the "implicitly convertible" type relation (see `Convertible relation
<#type-relations-convertible-relation>`_):
{==+==}
转换器就像普通的过程，只不过它增强了"隐式可转换"类型关系 (参见 `Convertible relation <#type-relations-convertible-relation>`_ ):
{==+==}

{==+==}
  ```nim
  # bad style ahead: Nim is not C.
  converter toBool(x: int): bool = x != 0

  if 4:
    echo "compiles"
  ```
{==+==}
  ```nim
  # 前方代码风格不好: Nim 不是 C。
  converter toBool(x: int): bool = x != 0

  if 4:
    echo "compiles"
  ```
{==+==}


{==+==}
A converter can also be explicitly invoked for improved readability. Note that
implicit converter chaining is not supported: If there is a converter from
type A to type B and from type B to type C, the implicit conversion from A to C
is not provided.
{==+==}
开发者可以显式调用转换器以提高代码的可读性。
请注意编译不支持隐式转换器的链式调用: 假设存在 A 类型到 B 类型和 B 类型到 C 类型的转换器，Nim 不提供从 A 转换为 C 类型的隐式转换。
{==+==}


{==+==}
Type sections
=============
{==+==}
Type 段
==============
{==+==}

{==+==}
Example:
{==+==}
例子:
{==+==}

{==+==}
  ```nim
  type # example demonstrating mutually recursive types
    Node = ref object  # an object managed by the garbage collector (ref)
      le, ri: Node     # left and right subtrees
      sym: ref Sym     # leaves contain a reference to a Sym

    Sym = object       # a symbol
      name: string     # the symbol's name
      line: int        # the line the symbol was declared in
      code: Node       # the symbol's abstract syntax tree
  ```
{==+==}
  ```nim
  type # 展示相互递归类型的例子
    Node = ref object  # 由垃圾收集器管理的对象(ref)
      le, ri: Node     # 左子树和右子树
      sym: ref Sym     # 叶子包含对 Sym 的引用

    Sym = object       # 符号
      name: string     # 符号的名称
      line: int        # 符号声明的行数
      code: Node       # 符号的抽象语法树
  ```
{==+==}

{==+==}
A type section begins with the `type` keyword. It contains multiple
type definitions. A type definition binds a type to a name. Type definitions
can be recursive or even mutually recursive. Mutually recursive types are only
possible within a single `type` section. Nominal types like `objects`
or `enums` can only be defined in a `type` section.
{==+==}
类型段由 `type` 关键字开启。它包含多个类型定义。类型定义是给类型绑定一个名称。类型定义可以是递归的甚至是相互递归的。相互递归类型只能在同一个 `type` 段中出现。
像 `objects` 或者 `enums` 这样的名义类型仅能在 `type` 段中定义。
{==+==}



{==+==}
Exception handling
==================
{==+==}
异常处理
================
{==+==}

{==+==}
Try statement
-------------
{==+==}
Try 语句
----------------
{==+==}

{==+==}
Example:
{==+==}
例子:
{==+==}

{==+==}
  ```nim
  # read the first two lines of a text file that should contain numbers
  # and tries to add them
  var
    f: File
  if open(f, "numbers.txt"):
    try:
      var a = readLine(f)
      var b = readLine(f)
      echo "sum: " & $(parseInt(a) + parseInt(b))
    except OverflowDefect:
      echo "overflow!"
    except ValueError, IOError:
      echo "catch multiple exceptions!"
    except:
      echo "Unknown exception!"
    finally:
      close(f)
  ```
{==+==}
  ```nim
  # 从文本文件的前两行中读取数字
  # 并尝试把数字加起来
  var
    f: File
  if open(f, "numbers.txt"):
    try:
      var a = readLine(f)
      var b = readLine(f)
      echo "两数之和: " & $(parseInt(a) + parseInt(b))
    except OverflowDefect:
      echo "溢出!"
    except ValueError, IOError:
      echo "捕获多个异常!"
    except:
      echo "未知异常!"
    finally:
      close(f)
  ```
{==+==}


{==+==}
The statements after the `try` are executed in sequential order unless
an exception `e` is raised. If the exception type of `e` matches any
listed in an `except` clause, the corresponding statements are executed.
The statements following the `except` clauses are called
`exception handlers`:idx:.
{==+==}
`try` 之后的语句顺序执行，直到有异常 `e` 抛出。如果 `e` 的异常类型能够匹配 `except` 子句列出的异常类型，则执行对应的代码。 `except` 子句之后的代码被称为 `exception handlers`:idx: "异常处理程序"。
{==+==}

{==+==}
The empty `except`:idx: clause is executed if there is an exception that is
not listed otherwise. It is similar to an `else` clause in `if` statements.
{==+==}
如果程序抛出了未列出的异常，则执行空的 `except`:idx: 子句，类似于 `if` 语句的 `else` 子句。
{==+==}

{==+==}
If there is a `finally`:idx: clause, it is always executed after the
exception handlers.
{==+==}
如果存在 `finally` 子句，那么 `finally`:idx 子句总会在异常处理程序之后得以执行。
{==+==}

{==+==}
The exception is *consumed* in an exception handler. However, an
exception handler may raise another exception. If the exception is not
handled, it is propagated through the call stack. This means that often
the rest of the procedure - that is not within a `finally` clause -
is not executed (if an exception occurs).
{==+==}
异常处理程序会 *吃掉* 异常。然而异常处理程序也可能抛出新的异常。如果没有处理这个异常，则会通过调用栈传递出去。这种情况往往意味着，所在过程剩下的那些不属于 `finally` 子句的代码不被执行。
{==+==}


{==+==}
Try expression
--------------
{==+==}
Try 表达式
--------------------
{==+==}

{==+==}
Try can also be used as an expression; the type of the `try` branch then
needs to fit the types of `except` branches, but the type of the `finally`
branch always has to be `void`:
{==+==}
try 也可以用作表达式；`try` 分支的类型与 `except` 分支相兼容，而 `finally` 分支的类型必须是 `void`:
{==+==}

{==+==}
  ```nim
  from std/strutils import parseInt

  let x = try: parseInt("133a")
          except: -1
          finally: echo "hi"
  ```
{==+==}
  ```nim
  from std/strutils import parseInt

  let x = try: parseInt("133a")
          except: -1
          finally: echo "hi"
  ```
{==+==}

{==+==}
To prevent confusing code there is a parsing limitation; if the `try`
follows a `(` it has to be written as a one liner:
{==+==}
为了防止写出令人迷惑的代码，解析时做了限制: 如果 `try` 语句在 `(` 之后，则必须写成一行:
{==+==}

{==+==}
  ```nim
  let x = (try: parseInt("133a") except: -1)
  ```
{==+==}
  ```nim
  let x = (try: parseInt("133a") except: -1)
  ```
{==+==}

{==+==}
Except clauses
--------------
{==+==}
Except 子句
----------------------
{==+==}

{==+==}
Within an `except` clause it is possible to access the current exception
using the following syntax:
{==+==}
在 `except` 子句中，可使用下面的语法访问当前抛出的异常:
{==+==}

{==+==}
  ```nim
  try:
    # ...
  except IOError as e:
    # Now use "e"
    echo "I/O error: " & e.msg
  ```
{==+==}
  ```nim
  try:
    # ...
  except IOError as e:
    # 现在可以使用 "e"
    echo "I/O error: " & e.msg
  ```
{==+==}

{==+==}
Alternatively, it is possible to use `getCurrentException` to retrieve the
exception that has been raised:
{==+==}
或者使用 `getCurrentException` 获取当前抛出的异常。
{==+==}

{==+==}
  ```nim
  try:
    # ...
  except IOError:
    let e = getCurrentException()
    # Now use "e"
  ```
{==+==}
  ```nim
  try:
    # ...
  except IOError:
    let e = getCurrentException()
    # 现在可以使用 "e"
  ```
{==+==}

{==+==}
Note that `getCurrentException` always returns a `ref Exception`
type. If a variable of the proper type is needed (in the example
above, `IOError`), one must convert it explicitly:
{==+==}
注意，`getCurrentException` 总是返回 `ref Exception` 类型。如果需要使用具体类型(比如上面例子中的 `IOError`)的变量，则需要显式转换:
{==+==}

{==+==}
  ```nim
  try:
    # ...
  except IOError:
    let e = (ref IOError)(getCurrentException())
    # "e" is now of the proper type
  ```
{==+==}
  ```nim
  try:
    # ...
  except IOError:
    let e = (ref IOError)(getCurrentException())
    # 现在 "e" 是具体的异常类型了
  ```
{==+==}

{==+==}
However, this is seldom needed. The most common case is to extract an
error message from `e`, and for such situations, it is enough to use
`getCurrentExceptionMsg`:
{==+==}
但是这种需求很少见。最常见的使用场景是从 `e` 中提取错误信息，使用 `getCurrentExceptionMsg` 已经足够了:
{==+==}

{==+==}
  ```nim
  try:
    # ...
  except:
    echo getCurrentExceptionMsg()
  ```
{==+==}
  ```nim
  try:
    # ...
  except:
    echo getCurrentExceptionMsg()
  ```
{==+==}

{==+==}
Custom exceptions
-----------------
{==+==}
自定义异常
--------------------
{==+==}

{==+==}
It is possible to create custom exceptions. A custom exception is a custom type:
{==+==}
可以创建自定义异常。自定义异常是一种自定义类型:
{==+==}

{==+==}
  ```nim
  type
    LoadError* = object of Exception
  ```
{==+==}
  ```nim
  type
    LoadError* = object of Exception
  ```
{==+==}

{==+==}
Ending the custom exception's name with `Error` is recommended.
{==+==}
自定义异常的名称建议以 `Error` 结尾。
{==+==}

{==+==}
Custom exceptions can be raised just like any other exception, e.g.:
{==+==}
自定义异常可以像其他异常一样抛出，例如:
{==+==}

{==+==}
  ```nim
  raise newException(LoadError, "Failed to load data")
  ```
{==+==}
  ```nim
  raise newException(LoadError, "Failed to load data")
  ```
{==+==}

{==+==}
Defer statement
---------------
{==+==}
Defer 语句
--------------------
{==+==}

{==+==}
Instead of a `try finally` statement a `defer` statement can be used, which
avoids lexical nesting and offers more flexibility in terms of scoping as shown
below.
{==+==}
使用 `defer` 语句代替 `try finally` 语句可以避免代码的复杂嵌套，从作用域的角度看也更加灵活。下面给了例子。
{==+==}

{==+==}
Any statements following the `defer`will be considered
to be in an implicit try block in the current block:
{==+==}
`defer` 之后的任何语句都被视为处于当前代码块的隐式 try 块中:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc main =
    var f = open("numbers.txt", fmWrite)
    defer: close(f)
    f.write "abc"
    f.write "def"
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc main =
    var f = open("numbers.txt", fmWrite)
    defer: close(f)
    f.write "abc"
    f.write "def"
  ```
{==+==}

{==+==}
Is rewritten to:
{==+==}
重写为:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc main =
    var f = open("numbers.txt")
    try:
      f.write "abc"
      f.write "def"
    finally:
      close(f)
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc main =
    var f = open("numbers.txt")
    try:
      f.write "abc"
      f.write "def"
    finally:
      close(f)
  ```
{==+==}


{==+==}
When `defer` is at the outermost scope of a template/macro, its scope extends
to the block where the template/macro is called from:
{==+==}
当 `defer` 位于模板/宏的最外层作用域时，它的作用域将延伸到调用模板/宏的那个代码块中:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  template safeOpenDefer(f, path) =
    var f = open(path, fmWrite)
    defer: close(f)

  template safeOpenFinally(f, path, body) =
    var f = open(path, fmWrite)
    try: body # without `defer`, `body` must be specified as parameter
    finally: close(f)

  block:
    safeOpenDefer(f, "/tmp/z01.txt")
    f.write "abc"
  block:
    safeOpenFinally(f, "/tmp/z01.txt"):
      f.write "abc" # adds a lexical scope
  block:
    var f = open("/tmp/z01.txt", fmWrite)
    try:
      f.write "abc" # adds a lexical scope
    finally: close(f)
  ```
{==+==}
  ```nim  test = "nim c $1"
  template safeOpenDefer(f, path) =
    var f = open(path, fmWrite)
    defer: close(f)

  template safeOpenFinally(f, path, body) =
    var f = open(path, fmWrite)
    try: body # 若不使用 `defer` ，`body` 必须指定为参数
    finally: close(f)

  block:
    safeOpenDefer(f, "/tmp/z01.txt")
    f.write "abc"
  block:
    safeOpenFinally(f, "/tmp/z01.txt"):
      f.write "abc" # 增加一级词法作用域
  block:
    var f = open("/tmp/z01.txt", fmWrite)
    try:
      f.write "abc" # 增加一级词法作用域
    finally: close(f)
  ```
{==+==}

{==+==}
Top-level `defer` statements are not supported
since it's unclear what such a statement should refer to.
{==+==}
Nim 不允许在最顶层使用 `defer` 语句，因为不确定这样的语句涉及哪些内容。
{==+==}


{==+==}
Raise statement
---------------
{==+==}
Raise 语句
--------------------
{==+==}

{==+==}
Example:
{==+==}
例子:
{==+==}

{==+==}
  ```nim
  raise newException(IOError, "IO failed")
  ```
{==+==}
  ```nim
  raise newException(IOError, "IO 失败")
  ```
{==+==}

{==+==}
Apart from built-in operations like array indexing, memory allocation, etc.
the `raise` statement is the only way to raise an exception.
{==+==}
除了数组索引，内存分配等内置操作之外， `raise` 语句是抛出异常的唯一方法。
{==+==}

{==+==}
.. XXX document this better!
{==+==}
.. XXX document this better!
{==+==}

{==+==}
If no exception name is given, the current exception is `re-raised`:idx:. The
`ReraiseDefect`:idx: exception is raised if there is no exception to
re-raise. It follows that the `raise` statement *always* raises an
exception.
{==+==}
如果没有给出异常的名称，则 `re-raised`:idx: "重新抛出" 当前异常。如果当前没有异常可以重新抛出，则会抛出 `ReraiseDefect`:idx: 异常。这遵循 `raise` 语句 *总是* 抛出异常的规则。
{==+==}


{==+==}
Exception hierarchy
-------------------
{==+==}
异常的层级
--------------------
{==+==}

{==+==}
The exception tree is defined in the `system <system.html>`_ module.
Every exception inherits from `system.Exception`. Exceptions that indicate
programming bugs inherit from `system.Defect` (which is a subtype of `Exception`)
and are strictly speaking not catchable as they can also be mapped to an operation
that terminates the whole process. If panics are turned into exceptions, these
exceptions inherit from `Defect`.
{==+==}
`system <system.html>`_ 模块定义了异常树。所有异常都继承自 `system.Exception` 。
表示编码错误的异常继承自 `system.Defect` (它是 `Exception` 的子类)，严格来说，这类异常无法捕获，因为它也可以映射成一个结束整个进程的操作。
如果将 panic 转换为异常，则这类异常就继承自 `Defect`。
{==+==}

{==+==}
Exceptions that indicate any other runtime error that can be caught inherit from
`system.CatchableError` (which is a subtype of `Exception`).
{==+==}
表示可捕获的其它运行时错误的异常从 `system.CatchableError`(它是 `Exception` 的子类) 继承。
{==+==}


{==+==}
Imported exceptions
-------------------
{==+==}
导入的异常
--------------------
{==+==}

{==+==}
It is possible to raise/catch imported C++ exceptions. Types imported using
`importcpp` can be raised or caught. Exceptions are raised by value and
caught by reference. Example:
{==+==}
导入的 C++ 异常也可以抛出和捕获。使用 `importcpp` 导入的类型可以抛出和捕获。异常通过值抛出，通过引用捕获。
例子如下:
{==+==}

{==+==}
  ```nim  test = "nim cpp -r $1"
  type
    CStdException {.importcpp: "std::exception", header: "<exception>", inheritable.} = object
      ## does not inherit from `RootObj`, so we use `inheritable` instead
    CRuntimeError {.requiresInit, importcpp: "std::runtime_error", header: "<stdexcept>".} = object of CStdException
      ## `CRuntimeError` has no default constructor => `requiresInit`
  proc what(s: CStdException): cstring {.importcpp: "((char *)#.what())".}
  proc initRuntimeError(a: cstring): CRuntimeError {.importcpp: "std::runtime_error(@)", constructor.}
  proc initStdException(): CStdException {.importcpp: "std::exception()", constructor.}

  proc fn() =
    let a = initRuntimeError("foo")
    doAssert $a.what == "foo"
    var b: cstring
    try: raise initRuntimeError("foo2")
    except CStdException as e:
      doAssert e is CStdException
      b = e.what()
    doAssert $b == "foo2"

    try: raise initStdException()
    except CStdException: discard

    try: raise initRuntimeError("foo3")
    except CRuntimeError as e:
      b = e.what()
    except CStdException:
      doAssert false
    doAssert $b == "foo3"

  fn()
  ```
{==+==}
  ```nim  test = "nim cpp -r $1"
  type
    CStdException {.importcpp: "std::exception", header: "<exception>", inheritable.} = object
      ## 异常不继承自 `RootObj`, 所以我们使用 `inheritable` 关键字
    CRuntimeError {.requiresInit, importcpp: "std::runtime_error", header: "<stdexcept>".} = object of CStdException
      ## `CRuntimeError` 没有默认构造器 => `requiresInit`
  proc what(s: CStdException): cstring {.importcpp: "((char *)#.what())".}
  proc initRuntimeError(a: cstring): CRuntimeError {.importcpp: "std::runtime_error(@)", constructor.}
  proc initStdException(): CStdException {.importcpp: "std::exception()", constructor.}

  proc fn() =
    let a = initRuntimeError("foo")
    doAssert $a.what == "foo"
    var b: cstring
    try: raise initRuntimeError("foo2")
    except CStdException as e:
      doAssert e is CStdException
      b = e.what()
    doAssert $b == "foo2"

    try: raise initStdException()
    except CStdException: discard

    try: raise initRuntimeError("foo3")
    except CRuntimeError as e:
      b = e.what()
    except CStdException:
      doAssert false
    doAssert $b == "foo3"

  fn()
  ```
{==+==}

{==+==}
**Note:** `getCurrentException()` and `getCurrentExceptionMsg()` are not available
for imported exceptions from C++. One needs to use the `except ImportedException as x:` syntax
and rely on functionality of the `x` object to get exception details.
{==+==}
**注意** `getCurrentException()` 和 `getCurrentExceptionMsg()` 不能用于从 C++ 导入的异常。开发者需要使用 `except ImportedException as x:` 语句并且依靠对象 `x` 本身的功能获取异常的具体信息。
{==+==}


{==+==}
Effect system
=============
{==+==}
Effect 系统
======================
{==+==}

{==+==}
**Note**: The rules for effect tracking changed with the release of version
1.6 of the Nim compiler. This section describes the new rules that are activated
via `--experimental:strictEffects`.
{==+==}
**注意**: Nim 1.6 版本编译器改动了 effect 追踪的规则。本小节介绍了通过 `--experimental:strictEffects` 选项启用的新规则。
{==+==}


{==+==}
Exception tracking
------------------
{==+==}
异常追踪
----------------
{==+==}

{==+==}
Nim supports exception tracking. The `raises`:idx: pragma can be used
to explicitly define which exceptions a proc/iterator/method/converter is
allowed to raise. The compiler verifies this:
{==+==}
Nim 支持异常追踪。 `raises`:idx: 编译指示可以显式定义过程/迭代器/方法/转换器所允许抛出的异常。编译期会加以验证:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc p(what: bool) {.raises: [IOError, OSError].} =
    if what: raise newException(IOError, "IO")
    else: raise newException(OSError, "OS")
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc p(what: bool) {.raises: [IOError, OSError].} =
    if what: raise newException(IOError, "IO")
    else: raise newException(OSError, "OS")
  ```
{==+==}

{==+==}
An empty `raises` list (`raises: []`) means that no exception may be raised:
{==+==}
空的 `raises` 列表(`raises: []`)表示不允许抛出异常:
{==+==}

{==+==}
  ```nim
  proc p(): bool {.raises: [].} =
    try:
      unsafeCall()
      result = true
    except:
      result = false
  ```
{==+==}
  ```nim
  proc p(): bool {.raises: [].} =
    try:
      unsafeCall()
      result = true
    except:
      result = false
  ```
{==+==}

{==+==}
A `raises` list can also be attached to a proc type. This affects type
compatibility:
{==+==}
`raises` 列表也可以附加到过程类型上。这会影响类型兼容性:
{==+==}

{==+==}
  ```nim  test = "nim c $1"  status = 1
  type
    Callback = proc (s: string) {.raises: [IOError].}
  var
    c: Callback

  proc p(x: string) =
    raise newException(OSError, "OS")

  c = p # type error
  ```
{==+==}
  ```nim  test = "nim c $1"  status = 1
  type
    Callback = proc (s: string) {.raises: [IOError].}
  var
    c: Callback

  proc p(x: string) =
    raise newException(OSError, "OS")

  c = p # type error
  ```
{==+==}

{==+==}
For a routine `p`, the compiler uses inference rules to determine the set of
possibly raised exceptions; the algorithm operates on `p`'s call graph:
{==+==}
对于例程 `p` 来说，编译器使用推断规则来判断可能引发的异常的集合; 算法在 `p` 的调用图上运行:
{==+==}

{==+==}
1. Every indirect call via some proc type `T` is assumed to
   raise `system.Exception` (the base type of the exception hierarchy) and
   thus any exception unless `T` has an explicit `raises` list.
   However, if the call is of the form `f(...)` where `f` is a parameter of
   the currently analyzed routine it is ignored that is marked as `.effectsOf: f`.
   The call is optimistically assumed to have no effect.
   Rule 2 compensates for this case.
2. Every expression `e` of some proc type within a call that is passed to parameter
   marked as `.effectsOf` of proc `p` is assumed to be called indirectly and thus
   its raises list is added to `p`'s raises list.
3. Every call to a proc `q` which has an unknown body (due to a forward
   declaration) is assumed to
   raise `system.Exception` unless `q` has an explicit `raises` list.
   Procs that are `importc`'ed are assumed to have `.raises: []`, unless explicitly
   declared otherwise.
4. Every call to a method `m` is assumed to
   raise `system.Exception` unless `m` has an explicit `raises` list.
5. For every other call, the analysis can determine an exact `raises` list.
6. For determining a `raises` list, the `raise` and `try` statements
   of `p` are taken into consideration.
{==+==}
1. 对过程类型 `T` 的每个间接调用都假定产生 `system.Exception` (所有异常的基类)，即任意异常都有可能，除非 `T` 拥有显式的 `raises` 列表。
   不过，如果是以 `f(...)` 的形式调用并且 `f` 是当前分析的例程的参数，而且并被标记 `.effectsOf: f`，那么忽略它。
   乐观地假定这类调用没有 effect。
   第二条规则对这种情况有所补充。
2. 当某过程类型的表达式 `e` 是作为过程 `p` 的标记为 `.effectsOf` 的参数传入的，对 `e` 的调用会被视为间接调用，它的 `raises` 列表会加入到 `p` 的 `raises` 列表。
3. 所有对方法体未知(因为声明前置)的过程 `q` 的调用都会被看作抛出 `system.Exception` 除非 `q` 显式定义了 `raises` 列表。
   `importc` 导入的过程，若没有显式声明 `raises` 列表，则默认视为 `.raises: []`。
4. 方法 `m` 每一次调用都假定会抛出 `system.Exception`，除非显式声明了 `raises` 列表。
5. 对于其他的调用，Nim 可以分析推断出确切的 `raises` 列表。
6. 推断 `p` 的 `raises` 列表时，Nim 会考虑它里面的 `raise` 和 `try` 语句。
{==+==}


{==+==}
Exceptions inheriting from `system.Defect` are not tracked with
the `.raises: []` exception tracking mechanism. This is more consistent with the
built-in operations. The following code is valid:
{==+==}
`.raises: []` 异常追踪机制不追踪继承自 `system.Defect` 的异常。这样更能跟内置运算符保持一致。
下面的代码是合法的:
{==+==}

{==+==}
  ```nim
  proc mydiv(a, b): int {.raises: [].} =
    a div b # can raise an DivByZeroDefect
  ```
{==+==}
  ```nim
  proc mydiv(a, b): int {.raises: [].} =
    a div b # 会抛出 DivByZeroDefect 异常
  ```
{==+==}

{==+==}
And so is:
{==+==}
同理，下面的代码也是合法的:
{==+==}

{==+==}
  ```nim
  proc mydiv(a, b): int {.raises: [].} =
    if b == 0: raise newException(DivByZeroDefect, "division by zero")
    else: result = a div b
  ```
{==+==}
  ```nim
  proc mydiv(a, b): int {.raises: [].} =
    if b == 0: raise newException(DivByZeroDefect, "除数为 0")
    else: result = a div b
  ```
{==+==}

{==+==}
The reason for this is that `DivByZeroDefect` inherits from `Defect` and
with `--panics:on`:option: Defects become unrecoverable errors.
(Since version 1.4 of the language.)
{==+==}
这是因为 `DivByZeroDefect` 继承自 `Defect`，再加上 `--panics:on`:option: 选项 Defect 异常就变成了不可修复性错误。(自从 Nim 1.4 开始)
{==+==}


{==+==}
EffectsOf annotation
--------------------
{==+==}
EffectsOf 编译指示
------------------------------------
{==+==}

{==+==}
Rules 1-2 of the exception tracking inference rules (see the previous section)
ensure the following works:
{==+==}
异常追踪推断规则(见之前的小节)的第一条与第二条确保可以获得下面的预期效果:
{==+==}

{==+==}
  ```nim
  proc weDontRaiseButMaybeTheCallback(callback: proc()) {.raises: [], effectsOf: callback.} =
    callback()

  proc doRaise() {.raises: [IOError].} =
    raise newException(IOError, "IO")

  proc use() {.raises: [].} =
    # doesn't compile! Can raise IOError!
    weDontRaiseButMaybeTheCallback(doRaise)
  ```
{==+==}
  ```nim
  proc 我们不抛异常但是回调可能抛(callback: proc()) {.raises: [], effectsOf: callback.} =
    callback()

  proc 抛异常() {.raises: [IOError].} =
    raise newException(IOError, "IO")

  proc use() {.raises: [].} =
    # 编译失败! 会抛出 IOError 错误!
    我们不抛异常但是回调可能抛(抛异常)
  ```
{==+==}

{==+==}
As can be seen from the example, a parameter of type `proc (...)` can be
annotated as `.effectsOf`. Such a parameter allows for effect polymorphism:
The proc `weDontRaiseButMaybeTheCallback` raises the exceptions
that `callback` raises.
{==+==}
如这个例子所示， `proc (...)` 类型的参数可以标记为 `.effectsOf` 。这样的参数带来了 effect 多态: 过程 `我们不抛异常但是回调可能抛` 可以抛出 `callback` 所抛出的异常。
{==+==}

{==+==}
So in many cases a callback does not cause the compiler to be overly
conservative in its effect analysis:
{==+==}
所以在很多情况下，回调并不会导致编译器在 effect 分析中过于保守:
{==+==}

{==+==}
  ```nim  test = "nim c $1"  status = 1
  {.push warningAsError[Effect]: on.}
  {.experimental: "strictEffects".}

  import algorithm

  type
    MyInt = distinct int

  var toSort = @[MyInt 1, MyInt 2, MyInt 3]

  proc cmpN(a, b: MyInt): int =
    cmp(a.int, b.int)

  proc harmless {.raises: [].} =
    toSort.sort cmpN

  proc cmpE(a, b: MyInt): int {.raises: [Exception].} =
    cmp(a.int, b.int)

  proc harmful {.raises: [].} =
    # does not compile, `sort` can now raise Exception
    toSort.sort cmpE
  ```
{==+==}
  ```nim  test = "nim c $1"  status = 1
  {.push warningAsError[Effect]: on.}
  {.experimental: "strictEffects".}

  import algorithm

  type
    MyInt = distinct int

  var toSort = @[MyInt 1, MyInt 2, MyInt 3]

  proc cmpN(a, b: MyInt): int =
    cmp(a.int, b.int)

  proc harmless {.raises: [].} =
    toSort.sort cmpN

  proc cmpE(a, b: MyInt): int {.raises: [Exception].} =
    cmp(a.int, b.int)

  proc harmful {.raises: [].} =
    # 不会通过编译， `sort` 现在会抛出异常
    toSort.sort cmpE
  ```
{==+==}



{==+==}
Tag tracking
------------
{==+==}
标签追踪
----------------
{==+==}

{==+==}
Exception tracking is part of Nim's `effect system`:idx:. Raising an exception
is an *effect*. Other effects can also be defined. A user defined effect is a
means to *tag* a routine and to perform checks against this tag:
{==+==}
异常追踪是 `effect system`:idx: "Effect 系统"的一部分。抛出异常是一个 *effect* 。当然可以定义其他 effect 。自定义 effect 是一种给例程打 *标签* 并做检查的方法:
{==+==}

{==+==}
  ```nim  test = "nim c --warningAsError:Effect:on $1"  status = 1
  type IO = object ## input/output effect
  proc readLine(): string {.tags: [IO].} = discard

  proc no_effects_please() {.tags: [].} =
    # the compiler prevents this:
    let x = readLine()
  ```
{==+==}
  ```nim  test = "nim c --warningAsError:Effect:on $1"  status = 1
  type IO = object ## 输入/输出 effect
  proc readLine(): string {.tags: [IO].} = discard

  proc no_effects_please() {.tags: [].} =
    # 编译器禁止这么做:
    let x = readLine()
  ```
{==+==}

{==+==}
A tag has to be a type name. A `tags` list - like a `raises` list - can
also be attached to a proc type. This affects type compatibility.
{==+==}
标签必须是类型名称。同 `raises` 列表一样，`tags` 列表也可以附加到过程类型上。这会影响类型的兼容性。
{==+==}

{==+==}
The inference for tag tracking is analogous to the inference for
exception tracking.
{==+==}
标签追踪的推断规则与异常追踪的推断规则类型类似。
{==+==}

{==+==}
There is also a way which can be used to forbid certain effects:
{==+==}
有一种禁止某些 effect 出现的方法:
{==+==}

{==+==}
.. code-block:: nim
    :test: "nim c --warningAsError:Effect:on $1"
    :status: 1

  type IO = object ## input/output effect
  proc readLine(): string {.tags: [IO].} = discard
  proc echoLine(): void = discard

  proc no_IO_please() {.forbids: [IO].} =
    # this is OK because it didn't define any tag:
    echoLine()
    # the compiler prevents this:
    let y = readLine()
{==+==}
.. code-block:: nim
    :test: "nim c --warningAsError:Effect:on $1"
    :status: 1

  type IO = object ## input/output effect
  proc readLine(): string {.tags: [IO].} = discard
  proc echoLine(): void = discard

  proc no_IO_please() {.forbids: [IO].} =
    # 这样写没问题，因为它没有定义任何 tag:
    echoLine()
    # 编译器不允许这么做:
    let y = readLine()
{==+==}

{==+==}
The `forbids` pragma defines a list of illegal effects - if any statement
invokes any of those effects, the compilation will fail.
Procedure types with any disallowed effect are the subtypes of equal
procedure types without such lists:
{==+==}
`forbids` 编译指示定义了一个被禁止的 effect 的列表 —— 如果任何语句具有这些 effect，则编译会失败。
带有 effect 禁止列表的过程类型是不带这种列表的过程类型的子类型:
{==+==}

{==+==}
.. code-block:: nim
  type MyEffect = object
  type ProcType1 = proc (i: int): void {.forbids: [MyEffect].}
  type ProcType2 = proc (i: int): void

  proc caller1(p: ProcType1): void = p(1)
  proc caller2(p: ProcType2): void = p(1)

  proc effectful(i: int): void {.tags: [MyEffect].} = echo $i
  proc effectless(i: int): void {.forbids: [MyEffect].} = echo $i

  proc toBeCalled1(i: int): void = effectful(i)
  proc toBeCalled2(i: int): void = effectless(i)

  ## this will fail because toBeCalled1 uses MyEffect which was forbidden by ProcType1:
  caller1(toBeCalled1)
  ## this is OK because both toBeCalled2 and ProcType1 have the same requirements:
  caller1(toBeCalled2)
  ## these are OK because ProcType2 doesn't have any effect requirement:
  caller2(toBeCalled1)
  caller2(toBeCalled2)
{==+==}
.. code-block:: nim
  type MyEffect = object
  type ProcType1 = proc (i: int): void {.forbids: [MyEffect].}
  type ProcType2 = proc (i: int): void

  proc caller1(p: ProcType1): void = p(1)
  proc caller2(p: ProcType2): void = p(1)

  proc effectful(i: int): void {.tags: [MyEffect].} = echo $i
  proc effectless(i: int): void {.forbids: [MyEffect].} = echo $i

  proc toBeCalled1(i: int): void = effectful(i)
  proc toBeCalled2(i: int): void = effectless(i)

  ## 编译失败，因为 toBeCalled1 使用了 ProcType1 禁止的 MyEffect:
  caller1(toBeCalled1)
  ## 编译通过，因为 toBeCalled2 和 ProcType1 的要求相同:
  caller1(toBeCalled2)
  ## 编译通过，因为 ProcType2 没有任何 effect 的要求:
  caller2(toBeCalled1)
  caller2(toBeCalled2)
{==+==}

{==+==}
`ProcType2` is a subtype of `ProcType1`. Unlike with the `tags` pragma, the parent context - the function which calls other functions with forbidden effects - doesn't inherit the forbidden list of effects.
{==+==}
`ProcType2` 是 `ProcType1` 的子类。`forbids` 编译指示跟 `tags` 编译指示不同，父级的上下文(父级调用了带有 effect 禁止列表的函数)并不继承所调函数的 effect 禁止列表。
{==+==}

