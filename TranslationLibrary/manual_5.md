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
过程，转换器或者迭代器可能会返回 `var` 类型，它意味着返回值是一个左值并且可以被调用者修改:
{==+==}

{-----}
  ```nim
  var g = 0

  proc writeAccessToG(): var int =
    result = g

  writeAccessToG() = 6
  assert g == 6
  ```
{-----}

{==+==}
It is a static error if the implicitly introduced pointer could be
used to access a location beyond its lifetime:
{==+==}
如果隐式创建的指针指向的内存地址有被回收的可能，则会导致静态错误:
{==+==}

{-----}
  ```nim
  proc writeAccessToG(): var int =
    var g = 0
    result = g # Error!
  ```
{-----}

{==+==}
For iterators, a component of a tuple return type can have a `var` type too:
{==+==}
对于迭代器来说，当元组作为返回值时，元组的元素也可以是 `var` 类型:
{==+==}

{-----}
  ```nim
  iterator mpairs(a: var seq[string]): tuple[key: int, val: var string] =
    for i in 0..a.high:
      yield (i, a[i])
  ```
{-----}

{==+==}
In the standard library every name of a routine that returns a `var` type
starts with the prefix `m` per convention.
{==+==}
在标准库中，所有返回 `var` 类型的例程，都遵循以 `m` 为前缀的命名规范。
{==+==}

{-----}
.. include:: manual/var_t_return.md
{-----}

{==+==}
### Future directions
{==+==}
### 将来的改进方向
{==+==}

{==+==}
Later versions of Nim can be more precise about the borrowing rule with
a syntax like:
{==+==}
未来的Nim在借用规则上将会更加准确，比如下面的语句
{==+==}

{-----}
  ```nim
  proc foo(other: Y; container: var X): var T from container
  ```
{-----}

{==+==}
Here `var T from container` explicitly exposes that the
location is derived from the second parameter (called
'container' in this case). The syntax `var T from p` specifies a type
`varTy[T, 2]` which is incompatible with `varTy[T, 1]`.
{==+==}
`var T from contaner` 显式指定了返回值的地址必须源自第二个参数(本例中称为 'contaner' )。
`var T from p` 语句指定了类型 `varTy[T, 2]` ，它不能与 `varTy[T, 1]` 类型兼容。
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
**注意**: 本节文档仅描述当前版本的代码实现。这部分语言规范将会有变动。
详情请查看链接 https://github.com/nim-lang/RFCs/issues/230
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
返回值以例程的特殊变量 `result` :idx: 出现。这便为实现类似C++的"具名返回值优化" (`NRVO`:idx:) 机制创造了条件。
NRVO 指的是对 `p` 内部 `result` 的操作会直接影响 `let/var dest = p(args)` (`dest` 的定义) 与 `dest = p(args)` (`dest` 的赋值) 中的目标 `dest` 。这是通过将 `dest = p(args)` 重写为 `p'(args, dest)` 来实现的，其中 `p'` 是 `p` 的变体，它返回 `void` 并且接收一个 `result` 的可变参数。
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
让 `T`作为 `p` 的返回值。
当 `sizeof(T) >= N` (`N` 的值依赖于具体实现) 时，NRVO 会将返回值申请为 `T` 。
换句话说，它会将返回值申请为 "较大" 的结构体。
{==+==}

{==+==}
If `p` can raise an exception, NRVO applies regardless. This can produce
observable differences in behavior:
{==+==}
若 `p` 会抛出异常，NRVO仍会应用。这种情况下，不同的行为可能会导致很大的差别。
{==+==}

{-----}
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
{-----}

{==+==}
However, the current implementation produces a warning in these cases.
There are different ways to deal with this warning:
{==+==}
然而，在这种情况下，当前版本的实现会提出警告。
有多种方法处理这种警告:
{==+==}

{==+==}
1. Disable the warning via `{.push warning[ObservableStores]: off.}` ... `{.pop.}`.
   Then one may need to ensure that `p` only raises *before* any stores to `result`
   happen.
{==+==}
1. 通过 `{.push warning[ObservableStores]: off.}` ... `{.pop.}` 禁用警告。
   则开发者需要确保 `p` 仅在任何 `result` 的操作之前抛出异常。
{==+==}

{==+==}
2. One can use a temporary helper variable, for example instead of `x = p(8)`
   use `let tmp = p(8); x = tmp`.
{==+==}
2. 开发者可以使用一个临时的帮助变量，比如在 `x = p(8)` 内部使用 `let tmp = p(8); x = tmp` 。
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
数组/可变参数/序列的 `[]` 下标运算符可以被重载。
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
过程总是使用静态方法匹配。方法使用动态方法匹配。用于动态匹配的对象应该是引用类型。
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
    # 重写基方法
    raise newException(CatchableError, "Method without implementation override")

  method eval(e: Literal): int = return e.x

  method eval(e: PlusExpr): int =
    # 请注意:语句的执行依赖于动态方法匹配
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
在这个例子中，构造器 `newLit` 和 `newPlus` 都是过程因为它们都使用静态方法匹配，但是 `eval` 是一个方法因为它需要动态方法匹配。
{==+==}

{==+==}
As can be seen in the example, base methods have to be annotated with
the `base`:idx: pragma. The `base` pragma also acts as a reminder for the
programmer that a base method `m` is used as the foundation to determine all
the effects that a call to `m` might cause.
{==+==}
从这个例子可以看出，基方法必须使用 `base`:idx: 编译指示修饰。对于开发者来说，`base` 编译指示也是一个提示，它提示 `m` 是任何调用结果的推断基础。
{==+==}


{==+==}
**Note**: Compile-time execution is not (yet) supported for methods.
{==+==}
**注意**: 目前还不支持方法的编译期执行。
{==+==}

{==+==}
**Note**: Starting from Nim 0.20, generic methods are deprecated.
{==+==}
**注意**: 从Nim 0.20开始，泛型方法已被弃用。
{==+==}

{==+==}
Multi-methods
--------------
{==+==}
多版本方法(方法重写)
----------------------------------------
{==+==}

{==+==}
**Note:** Starting from Nim 0.20, to use multi-methods one must explicitly pass
`--multimethods:on`:option: when compiling.
{==+==}
**Note** 从Nim 0.20 开始，要启用多版本方法，开发者必须在编译时显式添加 `--multimethods:on`:option: 参数。
{==+==}

{==+==}
In a multi-method, all parameters that have an object type are used for the
dispatching:
{==+==}
在多版本方法中，所有对象类型的参数都会用于方法匹配: 
{==+==}

{-----}
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
{-----}

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
`for`:idx 语句是一种迭代容器中元素的抽象机制。它依赖于 `iterator`:idx: "迭代器"来实现。与 `while` 语句类似，`for` 语句打开了一个 `implicit block`:idx: "隐式代码块"，这样可以与 `break` 语句搭配。
{==+==}

{==+==}
The `for` loop declares iteration variables - their scope reaches until the
end of the loop body. The iteration variables' types are inferred by the
return type of the iterator.
{==+==}
`for` 循环声明了迭代器变量 - 它们的生命周期持续到循环体的结束。迭代器的类型是由迭代器的返回值类型推断的。
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
迭代器与过程类似，除了迭代器只在 `for` 循环的上下文中调用。迭代器提供了一种特殊的使用抽象类型的迭代方式。在 `for` 循环的执行过程中， `yield` 语句对迭代器的调用起到关键性的作用。当程序执行到 `yield` 语句时，数据会与 `for` 循环的当前变量绑定但循环体继续执行。迭代器的局部变量和执行语句会在循环之间自动保存。实例如下:
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
  # 系统模块中存在如下定义
  iterator items*(a: string): char {.inline.} =
    var i = 0
    while i < len(a):
      yield a[i]
      inc(i)

  for ch in items("hello world"): # `ch` 是一个迭代器变量
    echo ch
  ```
{==+==}

{==+==}
The compiler generates code as if the programmer had written this:
{==+==}
编译器会生成如下代码，就像是开发者写的代码一样:
{==+==}

{-----}
  ```nim
  var i = 0
  while i < len(a):
    var ch = a[i]
    echo ch
    inc(i)
  ```
{-----}

{==+==}
If the iterator yields a tuple, there can be as many iteration variables
as there are components in the tuple. The i'th iteration variable's type is
the type of the i'th component. In other words, implicit tuple unpacking in a
for loop context is supported.
{==+==}
如果迭代器遍历一个元组，则元组的元素便是迭代器的变量。第 i 次迭代的变量类型是元组第 i 个元素的类型。换句话说，循环上下文支持隐式元组拆包。
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
如果循环表达式 `e` 不显式指定使用迭代器并且循环只迭代一个变量，则循环表达式会被重写为 `items(e)` ；
即 `items` 迭代器会被隐式调用:
{==+==}

{-----}
  ```nim
  for x in [1,2,3]: echo x
  ```
{-----}

{==+==}
If the for loop has exactly 2 variables, a `pairs` iterator is implicitly
invoked.
{==+==}
如果循环恰迭代两个变量，则 `pairs` 迭代器会被隐式调用。
{==+==}

{==+==}
Symbol lookup of the identifiers `items`/`pairs` is performed after
the rewriting step, so that all overloads of `items`/`pairs` are taken
into account.
{==+==}
`items`/`pairs` 标识符的符号查找在编译器重写之后执行，所以 `items`/`pairs` 的重载可以生效。
{==+==}


{==+==}
First-class iterators
---------------------
{==+==}
第一类迭代器
------------------------
{==+==}

{==+==}
There are 2 kinds of iterators in Nim: *inline* and *closure* iterators.
An `inline iterator`:idx: is an iterator that's always inlined by the compiler
leading to zero overhead for the abstraction, but may result in a heavy
increase in code size.
{==+==}
Nim 中有两种迭代器: *inline* (内联)和 *closure* (闭包)迭代器。
`inline iterator`:idx: "内联迭代器"指总是被编译器内联优化的迭代器，实现零成本抽象(在运行时解释抽象的同时不需要付出额外的代价)，但可能会导致代码体积大大增加。
{==+==}

{==+==}
Caution: the body of a for loop over an inline iterator is inlined into
each `yield` statement appearing in the iterator code,
so ideally the code should be refactored to contain a single yield when possible
to avoid code bloat.
{==+==}
请警惕: 在使用内联迭代器时，循环体会被内联进循环中所有的 `yield` 语句里，所以在使用内联迭代器时，开发者应该尽量只使用一个 yield 语句以避免代码体积膨胀。
{==+==}

{==+==}
Inline iterators are second class citizens;
They can be passed as parameters only to other inlining code facilities like
templates, macros, and other inline iterators.
{==+==}
内联迭代器是二等公民; 它们只能作为参数传递给其他内联代码工具，如模板、宏和其他内联迭代器。
{==+==}

{==+==}
In contrast to that, a `closure iterator`:idx: can be passed around more freely:
{==+==}
相反， `closure iterator`:idx: "闭包迭代器"则可以更自由传递:
{==+==}

{-----}
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
{-----}

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
2. 闭包迭代器允许使用 `return` 语句并结束循环，但内联迭代器不行(这并不常用与内联迭代器)。
3. 内联迭代器不能用于递归。
4. 内联迭代器与闭包迭代器都没有特殊的 `result` 变量。
5. JS 后端不支持闭包迭代器。
{==+==}

{==+==}
Iterators that are neither marked `{.closure.}` nor `{.inline.}` explicitly
default to being inline, but this may change in future versions of the
implementation.
{==+==}
如果不使用 `{.closure.}` 或 `{.inline.}` 显式标记迭代器，则默认为内联迭代器。但是将来的版本可能会改动。
{==+==}

{==+==}
The `iterator` type is always of the calling convention `closure`
implicitly; the following example shows how to use iterators to implement
a `collaborative tasking`:idx: system:
{==+==}
`iterator` 类型通常约定隐式使用 `closure` 闭包迭代器; 下面的例子展示了如何实现一个 `collaborative tasking`:idx: "协作任务"系统:
{==+==}

{-----}
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
{-----}

{==+==}
The builtin `system.finished` can be used to determine if an iterator has
finished its operation; no exception is raised on an attempt to invoke an
iterator that has already finished its work.
{==+==}
内置的 `system.finished` 可以用来推断迭代器是否已经完成了它的操作; 如果迭代器已经完成了工作，再调用 `system.finished` 也不会抛出异常。
{==+==}

{==+==}
Note that `system.finished` is error-prone to use because it only returns
`true` one iteration after the iterator has finished:
{==+==}
请注意 `system.finished` 容易引发错误，因为它只在迭代器最后一次循环完成后的下一次迭代才会返回 `true` :
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

  var c = mycount # 初始化迭代器
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
想得到正确的结果，应该想下面的代码一样调用迭代器:
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
  var c = mycount # 初始化迭代器
  while true:
    let value = c(1, 3)
    if finished(c): break # 丢弃返回值!
    echo value
  ```
{==+==}

{==+==}
It helps to think that the iterator actually returns a
pair `(value, done)` and `finished` is used to access the hidden `done`
field.
{==+==}
您可以这样认为迭代器实际上返回键值对 `(value, done)` ，并且 `finished` 访问了隐藏的 `done` 字段。
{==+==}

{==+==}
Closure iterators are *resumable functions* and so one has to provide the
arguments to every call. To get around this limitation one can capture
parameters of an outer factory proc:
{==+==}
闭包迭代器是 *可恢复函数* ，因此每次调用必须提供参数。 可以给迭代器套一层“工厂”过程，通过捕获外部“工厂”过程的参数来绕过这个限制:
{==+==}

{-----}
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
{-----}

{==+==}
The call can be made more like an inline iterator with a for loop macro:
{==+==}
这个过程可以变成内联迭代器，用于for循环的宏:
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
    let call = x[1][1] # 将 foo 带出 toItr(foo)
    let body = x[2]
    result = quote do:
      block:
        let itr = `call`
        for `expr` in itr():
            `body`

  for f in toItr(mycount(1, 4)): # 使用上文的过程 `proc mycount`
    echo f
  ```
{==+==}

{==+==}
Because of full backend function call apparatus involvement, closure iterator
invocation is typically higher cost than inline iterators. Adornment by
a macro wrapper at the call site like this is a possibly useful reminder.
{==+==}
因为调用闭包迭代器需要所有后端函数调用的参与，所以代价比调用内联迭代器更高。宏装饰器在调用处的包装是有用的提醒。
{==+==}

{==+==}
The factory `proc`, as an ordinary procedure, can be recursive. The
above macro allows such recursion to look much like a recursive iterator
would. For example:
{==+==}
作为一个普通的过程，工厂过程 `proc` 可以递归。上文中的宏可以用更像迭代器递归的语法重写。比如:
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
关于如果给模板和宏传递迭代器，可以看这一节 `迭代器 <#overloading-resolution-iterable>`_ 。
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
转换器就像普通的过程，只不过它增强了“隐式可转换”类型关系 (参见`转换关系 <#type-relations-convertible-relation>`_ )
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
  # 不推荐的代码风格:不推荐用 C 语言的风格编写 Nim 代码。
  converter toBool(x: int): bool = x != 0

  if 4:
    echo "compiles"
  ```
{==+==}


{==+==}
A converter can also be explicitly invoked for improved readability. Note that
implicit converter chaining is not supported: If there is a converter from
type A to type B and from type B to type C the implicit conversion from A to C
is not provided.
{==+==}
开发者可以显式调用转换器以提高代码的可读性。
请注意隐式转换器不支持自动的链式调用: 如果存在 A 类型到 B 类型的转换器和 B 类型到 C 类型的转换器，Nim 不提供从 A 转换为 C 类型的隐式转换。
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

    Sym = object       # 一个对象
      name: string     # 对象的名称
      line: int        # 对象声明的行数
      code: Node       # 对象的抽象语法树
  ```
{==+==}

{==+==}
A type section begins with the `type` keyword. It contains multiple
type definitions. A type definition binds a type to a name. Type definitions
can be recursive or even mutually recursive. Mutually recursive types are only
possible within a single `type` section. Nominal types like `objects`
or `enums` can only be defined in a `type` section.
{==+==}
类型段由 `type` 关键字开启。它包含多个类型定义。类型定义给类型绑定一个名称。类型定义可以是递归的甚至是相互递归的。相互递归类型只能在单层 `type` 段中出现。
像 `objects` 或者 `enums` 这样的标称类型仅能在 `type` 段中定义。
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


{==+==}
The statements after the `try` are executed in sequential order unless
an exception `e` is raised. If the exception type of `e` matches any
listed in an `except` clause, the corresponding statements are executed.
The statements following the `except` clauses are called
`exception handlers`:idx:.
{==+==}
除非有异常 `e` 抛出，否则 `try` 之后的语句顺序执行。如果 `e` 的异常类型能够匹配 `except` 子句列出的异常类型，则执行对应的代码。 `except` 子句之后的代码被称为 `exception handlers`:idx: "异常处理器"。
{==+==}

{==+==}
The empty `except`:idx: clause is executed if there is an exception that is
not listed otherwise. It is similar to an `else` clause in `if` statements.
{==+==}
如果程序抛出了未列出的异常，则将执行空的 `except`:idx: 子句。就像 `if` 语句的 `else` 子句。
{==+==}

{==+==}
If there is a `finally`:idx: clause, it is always executed after the
exception handlers.
{==+==}
`finally`:idx 子句总会在异常处理程序之后执行，如果存在 `finally` 子句的话。
{==+==}

{==+==}
The exception is *consumed* in an exception handler. However, an
exception handler may raise another exception. If the exception is not
handled, it is propagated through the call stack. This means that often
the rest of the procedure - that is not within a `finally` clause -
is not executed (if an exception occurs).
{==+==}
异常在异常处理器中 *处理* 。然而异常处理器也可能抛出异常。如果没有处理这样的异常，则它会通过调用栈传递出去。所以当这种情况发生时，剩下的代码将不会被执行( `finally` 子句的代码依旧会执行)。
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
try 也可以用作表达式; `try` 部分的类型需要兼容 `except` 部分的类型，但是 `finally` 部分只能是 `void` :
{==+==}

{-----}
  ```nim
  from std/strutils import parseInt

  let x = try: parseInt("133a")
          except: -1
          finally: echo "hi"
  ```
{-----}


{==+==}
To prevent confusing code there is a parsing limitation; if the `try`
follows a `(` it has to be written as a one liner:
{==+==}
为了防止令人迷惑的代码，有一个解析限制: 如果 `try` 语句在 `(` 之后，则表达式必须写成一行:
{==+==}

{-----}
  ```nim
  let x = (try: parseInt("133a") except: -1)
  ```
{-----}


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
在 `except` 子句中，可能需要使用下面的语法访问当前抛出的异常:
{==+==}

{-----}
  ```nim
  try:
    # ...
  except IOError as e:
    # Now use "e"
    echo "I/O error: " & e.msg
  ```
{-----}

{==+==}
Alternatively, it is possible to use `getCurrentException` to retrieve the
exception that has been raised:
{==+==}
或者，使用 `getCurrentException` 也可以获取当前抛出的异常。
{==+==}

{-----}
  ```nim
  try:
    # ...
  except IOError:
    let e = getCurrentException()
    # Now use "e"
  ```
{-----}

{==+==}
Note that `getCurrentException` always returns a `ref Exception`
type. If a variable of the proper type is needed (in the example
above, `IOError`), one must convert it explicitly:
{==+==}
注意， `getCurrentException` 总是返回 `ref Exception` 类型。如果需要使用具体类型(比如上面例子中的 `IOError`)的变量，则需要显式转换:
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
但是，这样的情况很少发生。常见的使用场景是从 `e` 中提取异常信息，对于这种场景，使用 `getCurrentExceptionMsg` 已经足够了:
{==+==}

{-----}
  ```nim
  try:
    # ...
  except:
    echo getCurrentExceptionMsg()
  ```
{-----}

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
您可以创建自定义异常。自定义异常就是自定义类性:
{==+==}

{-----}
  ```nim
  type
    LoadError* = object of Exception
  ```
{-----}

{==+==}
Ending the custom exception's name with `Error` is recommended.
{==+==}
自定义异常的名称建议以 `Error` 结尾。
{==+==}

{==+==}
Custom exceptions can be raised just like any other exception, e.g.:
{==+==}
自定义异常可以像其他异常一样抛出， 例如:
{==+==}

{-----}
  ```nim
  raise newException(LoadError, "Failed to load data")
  ```
{-----}

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
使用 `defer` 语句代替 `try finally` 语句可以避免代码的复杂嵌套，在下面的例子中，您也可以看到它提供更灵活的作用域。
{==+==}

{==+==}
Any statements following the `defer` in the current block will be considered
to be in an implicit try block:
{==+==}
当前代码块中， `defer` 之后的任何语句都将考虑包裹在隐式 try 块中:
{==+==}

{-----}
  ```nim  test = "nim c $1"
  proc main =
    var f = open("numbers.txt", fmWrite)
    defer: close(f)
    f.write "abc"
    f.write "def"
  ```
{-----}

{==+==}
Is rewritten to:
{==+==}
会被编译器重写为:
{==+==}

{-----}
  ```nim  test = "nim c $1"
  proc main =
    var f = open("numbers.txt")
    try:
      f.write "abc"
      f.write "def"
    finally:
      close(f)
  ```
{-----}

{==+==}
When `defer` is at the outermost scope of a template/macro, its scope extends
to the block where the template is called from:
{==+==}
当 `defer` 位于最外层的模板/宏的作用域中时，它的作用域将延伸到模板被调用的代码块中:
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
    try: body # 若没有 `defer` ， `body` 必须指定为参数
    finally: close(f)

  block:
    safeOpenDefer(f, "/tmp/z01.txt")
    f.write "abc"
  block:
    safeOpenFinally(f, "/tmp/z01.txt"):
      f.write "abc" # 增加了表达式的作用域
  block:
    var f = open("/tmp/z01.txt", fmWrite)
    try:
      f.write "abc" # 增加了表达式的作用域
    finally: close(f)
  ```
{==+==}

{==+==}
Top-level `defer` statements are not supported
since it's unclear what such a statement should refer to.
{==+==}
Nim 不支持最顶层(没有任何缩进的)的 `defer` 语句，因为无法判断它用于哪一段代码。
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

{-----}
  ```nim
  raise newException(IOError, "IO failed")
  ```
{-----}

{==+==}
Apart from built-in operations like array indexing, memory allocation, etc.
the `raise` statement is the only way to raise an exception.
{==+==}
除了数组索引，内存分配等内置操作之外， `raise` 语句是抛出异常的唯一方法。
{==+==}

{-----}
.. XXX document this better!
{-----}

{==+==}
If no exception name is given, the current exception is `re-raised`:idx:. The
`ReraiseDefect`:idx: exception is raised if there is no exception to
re-raise. It follows that the `raise` statement *always* raises an
exception.
{==+==}
如果没有给出异常的名称，则当前异常会 `re-raised`:idx: "重新抛出"。如果当前没有异常可以重新抛出，则会抛出 `ReraiseDefect`:idx: 异常。它遵循 `raise` 语句 *总是* 抛出异常的规则。
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
如果 panic 被转换为异常，则这类异常继承自 `Defect` 。
{==+==}

{==+==}
Exceptions that indicate any other runtime error that can be caught inherit from
`system.CatchableError` (which is a subtype of `Exception`).
{==+==}
表示可捕获的所有运行时错误的异常继承自 `system.CatchableError`(它是 `Exception` 的子类)。
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
      ## `CRuntimeError` 没有构造器 => `requiresInit`
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
**注意** `getCurrentException()` 和 `getCurrentExceptionMsg()` 不能从C++导入。开发者需要使用 `except ImportedException as x:` 语句并且需要依据对象 `x` 的功能获取异常的具体信息。
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
**注意** : Nim 1.6 版本编译器改动了 effect 跟踪的规则。本小节的中的新规则需要通过添加 `--experimental:strictEffects` 选项才能生效。
{==+==}


{==+==}
Exception tracking
------------------
{==+==}
异常跟踪
----------------
{==+==}

{==+==}
Nim supports exception tracking. The `raises`:idx: pragma can be used
to explicitly define which exceptions a proc/iterator/method/converter is
allowed to raise. The compiler verifies this:
{==+==}
Nim 支持异常跟踪。 `raises`:idx: 编译指示可以显式定义哪些异常可以由 过程/迭代器/方法/转换器 抛出。编译期会验证如下代码:
{==+==}

{-----}
  ```nim  test = "nim c $1"
  proc p(what: bool) {.raises: [IOError, OSError].} =
    if what: raise newException(IOError, "IO")
    else: raise newException(OSError, "OS")
  ```
{-----}

{==+==}
An empty `raises` list (`raises: []`) means that no exception may be raised:
{==+==}
空的 `raises` 列表(`raises: []`)意味着不允许抛出异常:
{==+==}

{-----}
  ```nim
  proc p(): bool {.raises: [].} =
    try:
      unsafeCall()
      result = true
    except:
      result = false
  ```
{-----}


{==+==}
A `raises` list can also be attached to a proc type. This affects type
compatibility:
{==+==}
`raises` 列表也可以附加到过程类型上。这会影响类型兼容性:
{==+==}

{-----}
  ```nim  test = "nim c $1"  status = 1
  type
    Callback = proc (s: string) {.raises: [IOError].}
  var
    c: Callback

  proc p(x: string) =
    raise newException(OSError, "OS")

  c = p # type error
  ```
{-----}


{==+==}
For a routine `p`, the compiler uses inference rules to determine the set of
possibly raised exceptions; the algorithm operates on `p`'s call graph:
{==+==}
对于例程 `p` 来说，编译器使用推断规则来判断可能引发的异常; 算法在 `p` 的调用图上运行:
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
   marked as `.effectsOf` is assumed to be called indirectly and thus
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
1. 通过某些过程类型 `T` 间接调用产生的异常会推断为 `system.Exception` (异常的基类)。若 `T` 拥有显式的 `raises` 列表，则返回具体异常类型。
   然而，如果是以 `f(...)` 的形式调用并且 `f` 是当前分析的例程的参数，则它会被标记 `.effectsOf: f` 并且忽略异常。
   乐观来说，这类调用一般认为没有任何 effect 。
   第二条规则对这种情况有所弥补。
2. 某些过程类型的表达式 `e` ，在调用中传递给标记为 `.effectsOf` 的参数会被看作间接调用，所以它的 `raises` 列表会加入到 `p` 的 `raises` 列表。
3. 所有对未知方法体(因为有些过程声明前置)的过程 `q` 的调用都会被看作抛出 `system.Exception` 异常除非 `q` 显式定义了 `raises` 列表。
   以 `importc` 结尾的过程，若没有显式声明 `raises` 列表，则默认被看作有 `.raises: []` 即空列表。
4. 若方法 `m` 没有显式声明 `raises` 列表，则调用方法 `m` 默认抛出 `system.Exception` 异常。
5. 对于其他的调用，Nim 可以分析推断出确定的 `raises` 列表。
6. Nim 会根据 `p` 的 `raise` 和 `try` 语句推断 `raises` 列表。
{==+==}


{==+==}
Exceptions inheriting from `system.Defect` are not tracked with
the `.raises: []` exception tracking mechanism. This is more consistent with the
built-in operations. The following code is valid:
{==+==}
继承自 `system.Defect` 的异常不会根据 `.raises: []` 异常跟踪机制跟踪。这跟内置的运算符保持一致。
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
同理，下面的代码 也是合理的:
{==+==}

{-----}
  ```nim
  proc mydiv(a, b): int {.raises: [].} =
    if b == 0: raise newException(DivByZeroDefect, "division by zero")
    else: result = a div b
  ```
{-----}


{==+==}
The reason for this is that `DivByZeroDefect` inherits from `Defect` and
with `--panics:on`:option: Defects become unrecoverable errors.
(Since version 1.4 of the language.)
{==+==}
因为 `DivByZeroDefect` 继承自 `Defect` 并且已添加 `--panics:on`:option: 选项，所以异常变成无法修复还原的错误。(自从 Nim 1.4 开始支持)
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
异常追踪(之前的小节)的第一条与第二条异常推断规则确保以下代码正常工作:
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
  proc weDontRaiseButMaybeTheCallback(callback: proc()) {.raises: [], effectsOf: callback.} =
    callback()

  proc doRaise() {.raises: [IOError].} =
    raise newException(IOError, "IO")

  proc use() {.raises: [].} =
    # 不会编译通过! 会抛出 IOError 错误!
    weDontRaiseButMaybeTheCallback(doRaise)
  ```
{==+==}

{==+==}
As can be seen from the example, a parameter of type `proc (...)` can be
annotated as `.effectsOf`. Such a parameter allows for effect polymorphism:
The proc `weDontRaiseButMaybeTheCallback` raises the exceptions
that `callback` raises.
{==+==}
从这个例子中可以看出， `proc (...)` 类型的参数可以标记为 `.effectsOf` 。这样的参数允许 effect 多态: 过程 `weDontRaiseButMaybeTheCallback` 可以抛出 `callback` 抛出的异常。
{==+==}

{==+==}
So in many cases a callback does not cause the compiler to be overly
conservative in its effect analysis:
{==+==}
所以在很多场景中，callback 并不会导致编译器在 effect 分析中过于保守:
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
Tag 跟踪
----------------
{==+==}

{==+==}
Exception tracking is part of Nim's `effect system`:idx:. Raising an exception
is an *effect*. Other effects can also be defined. A user defined effect is a
means to *tag* a routine and to perform checks against this tag:
{==+==}
异常追踪是 `effect system`:idx: "Effect 系统"的一部分。抛出异常是一个 *effect* 。当然可以定义其他 effect 。自定义 effect 是对例程打上 *tag* 和检查这个 tag 的一种方式:
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
    # 下面代码不能通过编译:
    let x = readLine()
  ```
{==+==}

{==+==}
A tag has to be a type name. A `tags` list - like a `raises` list - can
also be attached to a proc type. This affects type compatibility.
{==+==}
`tag` 必须是类型名。
就像 `raises` 列表， `tags` 列表也可以附加到过程类型上。这会影响类型的兼容性。
{==+==}

{==+==}
The inference for tag tracking is analogous to the inference for
exception tracking.
{==+==}
tag 跟踪的推断规则与异常追踪的推断规则类型。
{==+==}

{==+==}
There is also a way which can be used to forbid certain effects:
{==+==}
也有几种方式可以禁用某些 effect :
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
    # 但是编译器不允许这样写:
    let y = readLine()
{==+==}

{==+==}
The `forbids` pragma defines a list of illegal effects - if any statement
invokes any of those effects, the compilation will fail.
Procedure types with any disallowed effect are the subtypes of equal
procedure types without such lists:
{==+==}
`forbids` 编译指示定义了一个非法 effect 的列表。如果任何语句调用这些 effect ，则编译会失败。
带有非法 effect 的过程类型是原(没有非法 effect )过程类型的子类型:
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
  ## this is OK because both toBeCalled1 and ProcType1 have the same requirements:
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

  ## 这会编译失败因为 toBeCalled1 使用 ProcType1 禁用的 MyEffect :
  caller1(toBeCalled1)
  ## 这会编译通过因为 toBeCalled1 和 ProcType1 有相同的要求:
  caller1(toBeCalled2)
  ## 这会编译通过因为 ProcType2 没有任何 effect 的要求:
  caller2(toBeCalled1)
  caller2(toBeCalled2)
{==+==}

{==+==}
`ProcType2` is a subtype of `ProcType1`. Unlike with tags, the parent context - the function which calls other functions with forbidden effects - doesn't inherit the forbidden list of effects.
{==+==}
`ProcType2` 是 `ProcType1` 的子类。跟 tag 不同，父级的上下文(调用其他有禁用 effect 函数的函数)并不继承 effect 的禁用列表。
{==+==}

