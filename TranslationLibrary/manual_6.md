{==+==}
Side effects
------------
{==+==}
副作用
------------
{==+==}

{==+==}
The `noSideEffect` pragma is used to mark a proc/iterator that can have only
side effects through parameters. This means that the proc/iterator only changes locations that are
reachable from its parameters and the return value only depends on the
parameters. If none of its parameters have the type `var`, `ref`, `ptr`, `cstring`, or `proc`,
then no locations are modified.
{==+==}
`noSideEffect` 编译指示用于标记过程和迭代器，说明它们只能通过参数产生副作用。这意味着这个过程或迭代器只能修改参数所涉及的地址，而且返回值只依赖于参数。假如该过程或迭代器的参数中都不是 `var`、`ref`、 `ptr`、 `cstring` 或 `proc` 类型，则不会修改外部内容。
{==+==}

{==+==}
In other words, a routine has no side effects if it does not access a threadlocal
or global variable and it does not call any routine that has a side effect.
{==+==}
换句话说，如果一个例程既不访问本地线程变量或全局变量，也不调用其他带副作用的例程，则该例程是无副作用的。
{==+==}

{==+==}
It is a static error to mark a proc/iterator to have no side effect if the compiler cannot verify this.
{==+==}
如果给予一个过程或迭代器无副作用标记，而编译器却无法验证，将引发静态错误。
{==+==}

{==+==}
As a special semantic rule, the built-in `debugEcho
<system.html#debugEcho,varargs[typed,]>`_ pretends to be free of side effects
so that it can be used for debugging routines marked as `noSideEffect`.
{==+==}
有一个特殊的语义规则: 内置的 `debugEcho <system.html#debugEcho,varargs[typed,]>`_ 被视为无副作用的。因此，可以用它来调试标记为 `noSideEffect` 的例程。
{==+==}

{==+==}
`func` is syntactic sugar for a proc with no side effects:
{==+==}
`func` 是无副作用过程的语法糖:
{==+==}

{==+==}
  ```nim
  func `+` (x, y: int): int
  ```
{==+==}
  ```nim
  func `+` (x, y: int): int
  ```
{==+==}

{==+==}
To override the compiler's side effect analysis a `{.noSideEffect.}`
`cast` pragma block can be used:
{==+==}
`{.cast(noSideEffect).}` 编译指示可覆盖编译器的副作用分析:
{==+==}

{==+==}
  ```nim
  func f() =
    {.cast(noSideEffect).}:
      echo "test"
  ```
{==+==}
  ```nim
  func f() =
    {.cast(noSideEffect).}:
      echo "test"
  ```
{==+==}

{==+==}
**Side effects are usually inferred. The inference for side effects is
analogous to the inference for exception tracking.**
{==+==}
**副作用通常可被推断出来，与异常跟踪的推断类似。**
{==+==}

{==+==}
GC safety effect
----------------
{==+==}
GC 安全的作用
------------------------
{==+==}

{==+==}
We call a proc `p` `GC safe`:idx: when it doesn't access any global variable
that contains GC'ed memory (`string`, `seq`, `ref` or a closure) either
directly or indirectly through a call to a GC unsafe proc.
{==+==}
当过程 `p` 不访问任何使用了 GC 内存的全局变量( `string` 、`seq` 、`ref` 或一个闭包)时 —— 无论是直接访问还是通过调用不是 GC 安全的过程进行间接访问 —— 我们就称 `p` 是 `GC safe`:idx: "GC 安全" 的。
{==+==}

{==+==}
**The GC safety property is usually inferred. The inference for GC safety is
analogous to the inference for exception tracking.**
{==+==}
**是否 GC 安全通常可被推断出来，与异常跟踪的推断类似。**
{==+==}

{==+==}
The `gcsafe`:idx: annotation can be used to mark a proc to be gcsafe,
otherwise this property is inferred by the compiler. Note that `noSideEffect`
implies `gcsafe`.
{==+==}
`gcsafe`:idx: 注解可把过程标记为 GC 安全的，否则将由编译器推断是否是 GC 安全的。值得注意的是， `noSideEffect` 暗含着 `gcsafe` 。
{==+==}

{==+==}
Routines that are imported from C are always assumed to be `gcsafe`.
{==+==}
从 C 语言库导入的例程将总是被看作 `gcsafe`。
{==+==}

{==+==}
To override the compiler's gcsafety analysis a `{.cast(gcsafe).}` pragma block can
be used:
{==+==}
 `{.cast(gcsafe).}` 编译指示块可覆盖编译器的 GC 安全分析:
{==+==}

{==+==}
  ```nim
  var
    someGlobal: string = "some string here"
    perThread {.threadvar.}: string

  proc setPerThread() =
    {.cast(gcsafe).}:
      deepCopy(perThread, someGlobal)
  ```
{==+==}
  ```nim
  var
    someGlobal: string = "some string here"
    perThread {.threadvar.}: string

  proc setPerThread() =
    {.cast(gcsafe).}:
      deepCopy(perThread, someGlobal)
  ```
{==+==}

{==+==}
See also:
{==+==}
另请参阅:
{==+==}

{==+==}
- `Shared heap memory management <mm.html>`_.
{==+==}
- `Shared heap memory management <mm.html>`_ 。
{==+==}

{==+==}
Effects pragma
--------------
{==+==}
Effects 编译指示
------------------------
{==+==}

{==+==}
The `effects` pragma has been designed to assist the programmer with the
effects analysis. It is a statement that makes the compiler output all inferred
effects up to the `effects`'s position:
{==+==}
`effects` 编译指示用于协助程序员进行作用分析。这条语句可以使编译器输出直到 `effects` 处所有推断出的作用:
{==+==}

{==+==}
  ```nim
  proc p(what: bool) =
    if what:
      raise newException(IOError, "IO")
      {.effects.}
    else:
      raise newException(OSError, "OS")
  ```
{==+==}
  ```nim
  proc p(what: bool) =
    if what:
      raise newException(IOError, "IO")
      {.effects.}
    else:
      raise newException(OSError, "OS")
  ```
{==+==}

{==+==}
The compiler produces a hint message that `IOError` can be raised. `OSError`
is not listed as it cannot be raised in the branch the `effects` pragma
appears in.
{==+==}
编译器输出一条消息，提示可能抛出 `IOError`。`OSError` 不会出现在提示里，因为 `effects` 编译指示所在的分支不会抛出这个异常。
{==+==}

{==+==}
Generics
========
{==+==}
泛型
========
{==+==}

{==+==}
Generics are Nim's means to parametrize procs, iterators or types with
`type parameters`:idx:. Depending on the context, the brackets are used either to
introduce type parameters or to instantiate a generic proc, iterator, or type.
{==+==}
泛型是 Nim 通过 `type parameters`:idx: "类型参数" 把过程、迭代器或类型参数化的方法。在不同的上下文里，用方括号引入类型参数，或者实例化泛型过程、迭代器及类型。
{==+==}

{==+==}
The following example shows how a generic binary tree can be modeled:
{==+==}
以下例子展示了如何构建一个泛型二叉树:
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
    result = BinaryTree[T](le: nil, ri: nil, data: data)

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
    BinaryTree*[T] = ref object # 泛型二叉树类使用了泛型参数 'T'
      le, ri: BinaryTree[T]     # 左、右子树; 可能为空
      data: T                   # 节点里的数据

  proc newNode*[T](data: T): BinaryTree[T] =
    # 节点构造函数
    result = BinaryTree[T](le: nil, ri: nil, data: data)

  proc add*[T](root: var BinaryTree[T], n: BinaryTree[T]) =
    # 插入一个节点到树中
    if root == nil:
      root = n
    else:
      var it = root
      while it != nil:
        # 比较数据项; 使用泛型过程 `cmp`
        # 适用于任何拥有 `==` 和 `<` 操作符的类型
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
    # 方便使用的辅助过程:
    add(root, newNode(data))

  iterator preorder*[T](root: BinaryTree[T]): T =
    # 二叉树的前序遍历.
    # 显式地使用栈(比递归迭代器工厂更有效).
    var stack: seq[BinaryTree[T]] = @[root]
    while stack.len > 0:
      var n = stack.pop()
      while n != nil:
        yield n.data
        add(stack, n.ri)  # 将右子树入栈
        n = n.le          # 并遍历左子树

  var
    root: BinaryTree[string]  # 使用字符串实例化二叉树
  add(root, newNode("hello")) # 实例化 `newNode` 和 `add`
  add(root, "world")          # 实例化第二个 `add` 过程
  for str in preorder(root):
    stdout.writeLine(str)
  ```
{==+==}

{==+==}
The `T` is called a `generic type parameter`:idx: or
a `type variable`:idx:.
{==+==}
这里的 `T` 称为 `generic type parameter`:idx: "泛型类型参数"，或者 `type variable`:idx: "类型变量"。
{==+==}

{==+==}
Is operator
-----------
{==+==}
Is 运算符
----------------------
{==+==}

{==+==}
The `is` operator is evaluated during semantic analysis to check for type
equivalence. It is therefore very useful for type specialization within generic
code:
{==+==}
`is` 运算符用来在语义分析期间检查类型的等价性。在泛型代码中利用这个运算符编写类型相关的代码:
{==+==}

{==+==}
  ```nim
  type
    Table[Key, Value] = object
      keys: seq[Key]
      values: seq[Value]
      when not (Key is string): # empty value for strings used for optimization
        deletedKeys: seq[bool]
  ```
{==+==}
  ```nim
  type
    Table[Key, Value] = object
      keys: seq[Key]
      values: seq[Value]
      when not (Key is string): # 对于字符串类型做优化: 用空值代表已删除
        deletedKeys: seq[bool]
  ```
{==+==}

{==+==}
Type classes
------------
{==+==}
类型类
--------------
{==+==}

{==+==}
A type class is a special pseudo-type that can be used to match against
types in the context of overload resolution or the `is` operator.
Nim supports the following built-in type classes:
{==+==}
类型类是特殊的伪类型，可在重载解析或使用 `is` 运算符时针对性地匹配某些类型。Nim 支持以下内置类型类:
{==+==}

{==+==}
==================   ===================================================
type class           matches
==================   ===================================================
`object`             any object type
`tuple`              any tuple type

`enum`               any enumeration
`proc`               any proc type
`ref`                any `ref` type
`ptr`                any `ptr` type
`var`                any `var` type
`distinct`           any distinct type
`array`              any array type
`set`                any set type
`seq`                any seq type
`auto`               any type
==================   ===================================================
{==+==}
==================   ===================================================
类型类               匹配
==================   ===================================================
`object`             任意对象类型
`tuple`              任意元组类型
`enum`               任意枚举类型
`proc`               任意过程类型
`ref`                任意 `ref` 类型
`ptr`                任意 `ptr` 类型
`var`                任意 `var` 类型
`distinct`           任意 distinct 类型
`array`              任意数组类型
`set`                任意集合类型
`seq`                任意序列类型
`auto`               任意类型
==================   ===================================================
{==+==}

{==+==}
Furthermore, every generic type automatically creates a type class of the same
name that will match any instantiation of the generic type.
{==+==}
此外，任何泛型类型都会自动创建一个同名的类型类，可匹配该泛型类的任意实例。
{==+==}

{==+==}
Type classes can be combined using the standard boolean operators to form
more complex type classes:
{==+==}
类型类通过标准的布尔运算符可组合成更复杂的类型类。
{==+==}

{==+==}
  ```nim
  # create a type class that will match all tuple and object types
  type RecordType = tuple or object

  proc printFields[T: RecordType](rec: T) =
    for key, value in fieldPairs(rec):
      echo key, " = ", value
  ```
{==+==}
  ```nim
  # 创建一个可以匹配所有元组类型和对象类型的类型类
  type RecordType = tuple or object

  proc printFields[T: RecordType](rec: T) =
    for key, value in fieldPairs(rec):
      echo key, " = ", value
  ```
{==+==}

{==+==}
Type constraints on generic parameters can be grouped with `,` and propagation
stops with `;`, similarly to parameters for macros and templates:
{==+==}
泛型参数列表中的参数类型约束可以通过 `,` 进行分组，并以 `;` 结束，就像宏和模板中的参数列表那样:
{==+==}

{==+==}
  ```nim
  proc fn1[T; U, V: SomeFloat]() = discard # T is unconstrained
  template fn2(t; u, v: SomeFloat) = discard # t is unconstrained
  ```
{==+==}
  ```nim
  proc fn1[T; U, V: SomeFloat]() = discard    # T 没有类型约束
  template fn2(t; u, v: SomeFloat) = discard  # t 没有类型约束
  ```
{==+==}

{==+==}
Whilst the syntax of type classes appears to resemble that of ADTs/algebraic data
types in ML-like languages, it should be understood that type classes are static
constraints to be enforced at type instantiations. Type classes are not really
types in themselves but are instead a system of providing generic "checks" that
ultimately *resolve* to some singular type. Type classes do not allow for
runtime type dynamism, unlike object variants or methods.
{==+==}
虽然类型类在语法上接近于类 ML 语言中的代数数据类型 (ADT)，但应该知道，类型类只是实例化时所必须遵守的静态约束。类型类本身并非真的类型，只是一种检查系统，检查泛型是否最终被 *解析* 成某种单一类型。与对象、变量和方法不同，类型类不允许运行时的类型动态特性。
{==+==}

{==+==}
As an example, the following would not compile:
{==+==}
例如，以下代码无法通过编译:
{==+==}

{==+==}
  ```nim
  type TypeClass = int | string
  var foo: TypeClass = 2 # foo's type is resolved to an int here
  foo = "this will fail" # error here, because foo is an int
  ```
{==+==}
  ```nim
  type TypeClass = int | string
  var foo: TypeClass = 2 # foo的类型在这里被解释为 int 类型
  foo = "this will fail" # 这里发生错误，因为 foo 是 int
  ```
{==+==}

{==+==}
Nim allows for type classes and regular types to be specified
as `type constraints`:idx: of the generic type parameter:
{==+==}
Nim 允许将类型类和常规类型用作泛型类型参数的 `type constraints`:idx: "类型约束":
{==+==}

{==+==}
  ```nim
  proc onlyIntOrString[T: int|string](x, y: T) = discard

  onlyIntOrString(450, 616) # valid
  onlyIntOrString(5.0, 0.0) # type mismatch
  onlyIntOrString("xy", 50) # invalid as 'T' cannot be both at the same time
  ```
{==+==}
  ```nim
  proc onlyIntOrString[T: int|string](x, y: T) = discard

  onlyIntOrString(450, 616) # 可以
  onlyIntOrString(5.0, 0.0) # 类型不匹配
  onlyIntOrString("xy", 50) # 不行，因为同一个 T 不能同时是两种不同的类型
  ```
{==+==}

{==+==}
Implicit generics
-----------------
{==+==}
隐式泛型
----------------
{==+==}

{==+==}
A type class can be used directly as the parameter's type.
{==+==}
一个类型类可以直接作为参数的类型使用。
{==+==}

{==+==}
  ```nim
  # create a type class that will match all tuple and object types
  type RecordType = tuple or object

  proc printFields(rec: RecordType) =
    for key, value in fieldPairs(rec):
      echo key, " = ", value
  ```
{==+==}
  ```nim
  # 创建一个可以同时匹配元组和对象类型的类型类
  type RecordType = tuple or object

  proc printFields(rec: RecordType) =
    for key, value in fieldPairs(rec):
      echo key, " = ", value
  ```
{==+==}

{==+==}
Procedures utilizing type classes in such a manner are considered to be
`implicitly generic`:idx:. They will be instantiated once for each unique
combination of param types used within the program.
{==+==}
这种以类型类作为参数类型的过程称为 `implicitly generic`:idx: "隐式泛型"。在程序中每用于一组特定参数类型组合，它们都会被实例化一次。
{==+==}

{==+==}
By default, during overload resolution, each named type class will bind to
exactly one concrete type. We call such type classes `bind once`:idx: types.
Here is an example taken directly from the system module to illustrate this:
{==+==}
通常，重载解析期间，每一个被命名的类型类都将被绑定到单一的具体类型。我们称这些类型类为 `bind once`:idx: "单一绑定" 类型。以下是从 system 模块里直接拿来的例子:
{==+==}

{==+==}
  ```nim
  proc `==`*(x, y: tuple): bool =
    ## requires `x` and `y` to be of the same tuple type
    ## generic `==` operator for tuples that is lifted from the components
    ## of `x` and `y`.
    result = true
    for a, b in fields(x, y):
      if a != b: result = false
  ```
{==+==}
  ```nim
  proc `==`*(x, y: tuple): bool =
    ## 需要 `x` 和 `y` 都是相同的元组类型
    ## 针对元组的泛型操作符 `==` 建立于 `x` 和 `y` 各字段的相等性之上
    result = true
    for a, b in fields(x, y):
      if a != b: result = false
  ```
{==+==}

{==+==}
Alternatively, the `distinct` type modifier can be applied to the type class
to allow each param matching the type class to bind to a different type. Such
type classes are called `bind many`:idx: types.
{==+==}
另一种情况是用 `distinct` 修饰类型类，这将允许每一参数绑定到匹配类型类的不同类型。这样的类型类被称为 `bind many`:idx: "多绑定" 类型。
{==+==}

{==+==}
Procs written with the implicitly generic style will often need to refer to the
type parameters of the matched generic type. They can be easily accessed using
the dot syntax:
{==+==}
使用了隐式泛型的过程，常常需要引用匹配的泛型类型内的类型参数。使用 `.` 语法能便捷地实现此功能:
{==+==}

{==+==}
  ```nim
  type Matrix[T, Rows, Columns] = object
    ...

  proc `[]`(m: Matrix, row, col: int): Matrix.T =
    m.data[col * high(Matrix.Columns) + row]
  ```
{==+==}
  ```nim
  type Matrix[T, Rows, Columns] = object
    ...

  proc `[]`(m: Matrix, row, col: int): Matrix.T =
    m.data[col * high(Matrix.Columns) + row]
  ```
{==+==}

{==+==}
Here are more examples that illustrate implicit generics:
{==+==}
下面是关于隐式泛型更多的例子:
{==+==}

{==+==}
  ```nim
  proc p(t: Table; k: Table.Key): Table.Value

  # is roughly the same as:

  proc p[Key, Value](t: Table[Key, Value]; k: Key): Value
  ```
{==+==}
  ```nim
  proc p(t: Table; k: Table.Key): Table.Value

  # 大致等同于:

  proc p[Key, Value](t: Table[Key, Value]; k: Key): Value
  ```
{==+==}

{==+==}
  ```nim
  proc p(a: Table, b: Table)

  # is roughly the same as:

  proc p[Key, Value](a, b: Table[Key, Value])
  ```
{==+==}
  ```nim
  proc p(a: Table, b: Table)

  # 大致等同于:

  proc p[Key, Value](a, b: Table[Key, Value])
  ```
{==+==}

{==+==}
  ```nim
  proc p(a: Table, b: distinct Table)

  # is roughly the same as:

  proc p[Key, Value, KeyB, ValueB](a: Table[Key, Value], b: Table[KeyB, ValueB])
  ```
{==+==}
  ```nim
  proc p(a: Table, b: distinct Table)

  # 大致等同于:

  proc p[Key, Value, KeyB, ValueB](a: Table[Key, Value], b: Table[KeyB, ValueB])
  ```
{==+==}

{==+==}
`typedesc` used as a parameter type also introduces an implicit
generic. `typedesc` has its own set of rules:
{==+==}
`typedesc` 作为参数类型使用时，也会产生隐式泛型，`typedesc` 有其独有的规则:
{==+==}

{==+==}
  ```nim
  proc p(a: typedesc)

  # is roughly the same as:

  proc p[T](a: typedesc[T])
  ```
{==+==}
  ```nim
  proc p(a: typedesc)

  # 等同于以下写法:

  proc p[T](a: typedesc[T])
  ```
{==+==}

{==+==}
`typedesc` is a "bind many" type class:
{==+==}
`typedesc` 是一个 "多绑定" 类型类:
{==+==}

{==+==}
  ```nim
  proc p(a, b: typedesc)

  # is roughly the same as:

  proc p[T, T2](a: typedesc[T], b: typedesc[T2])
  ```
{==+==}
  ```nim
  proc p(a, b: typedesc)

  # 大致等同于:

  proc p[T, T2](a: typedesc[T], b: typedesc[T2])
  ```
{==+==}

{==+==}
A parameter of type `typedesc` is itself usable as a type. If it is used
as a type, it's the underlying type. (In other words, one level
of "typedesc"-ness is stripped off:
{==+==}
`typedesc` 类型的参数本身可作为类型使用。如果将其作为类型使用，那么它代表的就是底下的 `typedesc` 所匹配的类型。换言之，这时会剥掉一层 `typedesc`:
{==+==}

{==+==}
  ```nim
  proc p(a: typedesc; b: a) = discard

  # is roughly the same as:
  proc p[T](a: typedesc[T]; b: T) = discard

  # hence this is a valid call:
  p(int, 4)
  # as parameter 'a' requires a type, but 'b' requires a value.
  ```
{==+==}
  ```nim
  proc p(a: typedesc; b: a) = discard

  # 大致等同于:
  proc p[T](a: typedesc[T]; b: T) = discard

  # 所以这是合法的:
  p(int, 4)
  # 这里参数 'a' 需要的是一个类型, 而 'b' 需要的则是一个值。
  ```
{==+==}

{==+==}
Generic inference restrictions
------------------------------
{==+==}
泛型推断的局限
------------------------
{==+==}

{==+==}
The types `var T` and `typedesc[T]` cannot be inferred in a generic
instantiation. The following is not allowed:
{==+==}
泛型实例化时不会推断出 `var T` 或 `typedesc[T]`。下面的例子是不允许的:
{==+==}

{==+==}
  ```nim  test = "nim c $1"  status = 1
  proc g[T](f: proc(x: T); x: T) =
    f(x)

  proc c(y: int) = echo y
  proc v(y: var int) =
    y += 100
  var i: int

  # allowed: infers 'T' to be of type 'int'
  g(c, 42)

  # not valid: 'T' is not inferred to be of type 'var int'
  g(v, i)

  # also not allowed: explicit instantiation via 'var int'
  g[var int](v, i)
  ```
{==+==}
  ```nim  test = "nim c $1"  status = 1
  proc g[T](f: proc(x: T); x: T) =
    f(x)

  proc c(y: int) = echo y
  proc v(y: var int) =
    y += 100
  var i: int

  # 允许: 'T' 被推断为 'int' 类型
  g(c, 42)

  # 不允许: 'T' 不会被推断为 'var int'
  g(v, i)

  # 也不允许: 明确地通过 'var int' 实例化
  g[var int](v, i)
  ```
{==+==}

{==+==}
Symbol lookup in generics
-------------------------
{==+==}
泛型中的符号查找
--------------------------------
{==+==}

{==+==}
### Open and Closed symbols
{==+==}
### 开放和封闭符号
{==+==}

{==+==}
The symbol binding rules in generics are slightly subtle: There are "open" and
"closed" symbols. A "closed" symbol cannot be re-bound in the instantiation
context, an "open" symbol can. Per default, overloaded symbols are open
and every other symbol is closed.
{==+==}
泛型中的符号绑定规则略显微妙: 存在开放和封闭两种符号。封闭的符号在实例化的上下文中无法被重新绑定，而开放的符号则可以。默认情况下，重载符号都是开放的，所有其他符号都是封闭的。
{==+==}

{==+==}
Open symbols are looked up in two different contexts: Both the context
at definition and the context at instantiation are considered:
{==+==}
会在两种不同的上下文中查找开放的符号: 一是其定义所处的上下文，二是实例化时的上下文:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    Index = distinct int

  proc `==` (a, b: Index): bool {.borrow.}

  var a = (0, 0.Index)
  var b = (0, 0.Index)

  echo a == b # works!
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    Index = distinct int

  proc `==` (a, b: Index): bool {.borrow.}

  var a = (0, 0.Index)
  var b = (0, 0.Index)

  echo a == b # 可以!
  ```
{==+==}

{==+==}
In the example, the generic `==` for tuples (as defined in the system module)
uses the `==` operators of the tuple's components. However, the `==` for
the `Index` type is defined *after* the `==` for tuples; yet the example
compiles as the instantiation takes the currently defined symbols into account
too.
{==+==}
在这个例子中，针对元组的泛型 `==` (定义于 system 模块) 建立在元组各字段的 `==` 运算之上。然而，针对 `Index` 类型的 `==` 定义发生泛型 `==` 定义 *之后*；这个例子可以编译，因为实例化关于元组的 `==` 时，当前定义的关于 `Index` 的 `==` 也会考虑进来。
{==+==}

{==+==}
Mixin statement
---------------
{==+==}
Mixin 语句
------------------
{==+==}

{==+==}
A symbol can be forced to be open by a `mixin`:idx: declaration:
{==+==}
符号通过 `mixin`:idx: 关键字可以声明为开放的:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  proc create*[T](): ref T =
    # there is no overloaded 'init' here, so we need to state that it's an
    # open symbol explicitly:
    mixin init
    new result
    init result
  ```
{==+==}
  ```nim  test = "nim c $1"
  proc create*[T](): ref T =
    # 这里没有 'init' 的重载，我们需要显式的将其声明为一个开放的符号:
    mixin init
    new result
    init result
  ```
{==+==}

{==+==}
`mixin` statements only make sense in templates and generics.
{==+==}
`mixin` 语句只在模板和泛型中才有意义。
{==+==}

{==+==}
Bind statement
--------------
{==+==}
Bind 语句
----------------
{==+==}

{==+==}
The `bind` statement is the counterpart to the `mixin` statement. It
can be used to explicitly declare identifiers that should be bound early (i.e.
the identifiers should be looked up in the scope of the template/generic
definition):
{==+==}
 `bind` 语句是 `mixin` 语句的反面。可用于显式地声明标识符需要更早绑定(也就是说应在模板/泛型的定义作用域中查找这些标识符)。
{==+==}

{==+==}
  ```nim
  # Module A
  var
    lastId = 0

  template genId*: untyped =
    bind lastId
    inc(lastId)
    lastId
  ```
{==+==}
  ```nim
  # 模块 A
  var
    lastId = 0

  template genId* : untyped =
    bind lastId
    inc(lastId)
    lastId
  ```
{==+==}

{==+==}
  ```nim
  # Module B
  import A

  echo genId()
  ```
{==+==}
  ```nim
  # 模块 B
  import A

  echo genId()
  ```
{==+==}

{==+==}
But a `bind` is rarely useful because symbol binding from the definition
scope is the default.
{==+==}
但是 `bind` 用处不大，因为默认就是从定义作用域绑定符号。
{==+==}

{==+==}
`bind` statements only make sense in templates and generics.
{==+==}
`bind` 语句只在模板和泛型中有意义。
{==+==}

{==+==}
Delegating bind statements
--------------------------
{==+==}
委托绑定语句
------------------------
{==+==}

{==+==}
The following example outlines a problem that can arise when generic
instantiations cross multiple different modules:
{==+==}
下面的示例概述了当泛型的实例化跨越多个不同模块时会出现的一个问题:
{==+==}

{==+==}
  ```nim
  # module A
  proc genericA*[T](x: T) =
    mixin init
    init(x)
  ```
{==+==}
  ```nim
  # 模块 A
  proc genericA* [T](x: T) =
    mixin init
    init(x)
  ```
{==+==}

{==+==}
  ```nim
  import C

  # module B
  proc genericB*[T](x: T) =
    # Without the `bind init` statement C's init proc is
    # not available when `genericB` is instantiated:
    bind init
    genericA(x)
  ```
{==+==}
  ```nim
  import C

  # 模块 B
  proc genericB*[T](x: T) =
	# 实例化 `genericB` 时，如果没有 `bind init` 语句，来自模块 C 的 init 过程就是不可用的:
    bind init
    genericA(x)
  ```
{==+==}

{==+==}
  ```nim
  # module C
  type O = object
  proc init*(x: var O) = discard
  ```
{==+==}
  ```nim
  # 模块 C
  type O = object
  proc init* (x: var O) = discard
  ```
{==+==}

{==+==}
  ```nim
  # module main
  import B, C

  genericB O()
  ```
{==+==}
  ```nim
  # 主模块
  import B, C

  genericB O()
  ```
{==+==}

{==+==}
In module B has an `init` proc from module C in its scope that is not
taken into account when `genericB` is instantiated which leads to the
instantiation of `genericA`. The solution is to `forward`:idx: these
symbols by a `bind` statement inside `genericB`.
{==+==}
当由实例化 `genericB` 引发实例化 `genericA` 时，模块 B 的作用域中那个来自模块 C 的 `init` 过程未在考虑之中。解决方案是在 `genericB` 中通过 `bind` 语句 `forward`:idx: "转发" 这个符号。
{==+==}

{==+==}
Templates
=========
{==+==}
模板
========
{==+==}

{==+==}
A template is a simple form of a macro: It is a simple substitution
mechanism that operates on Nim's abstract syntax trees. It is processed in
the semantic pass of the compiler.
{==+==}
模板是简单形式的宏: 它是运行于 Nim 的抽象语法树的简单替换机制。编译器在语义分析阶段处理它。
{==+==}

{==+==}
The syntax to *invoke* a template is the same as calling a procedure.
{==+==}
*调用* 模板的语法和调用过程的语法是相同的。
{==+==}

{==+==}
Example:
{==+==}
例如:
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
    # 此定义存在于 system 模块中
    not (a == b)

  assert(5 != 6) # 编译器将其重写为: assert(not (5 == 6))
  ```
{==+==}

{==+==}
The `!=`, `>`, `>=`, `in`, `notin`, `isnot` operators are in fact
templates:
{==+==}
 `!=`, `>`, `>=`, `in`, `notin`, `isnot` 等运算符实际上都是模板:
{==+==}

{==+==}
| `a > b` is transformed into `b < a`.
| `a in b` is transformed into `contains(b, a)`.
| `notin` and `isnot` have the obvious meanings.
{==+==}
| `a > b` 转换为 `b < a`。
| `a in b` 转换为 `contains(b, a)`。
| `notin` 和 `isnot` 的转换也显而易见。
{==+==}

{==+==}
The "types" of templates can be the symbols `untyped`,
`typed` or `typedesc`. These are "meta types", they can only be used in certain
contexts. Regular types can be used too; this implies that `typed` expressions
are expected.
{==+==}
模板中的 "类型" 可以使用 `untyped` 、`typed` 或 `typedesc` 等三个符号。这些都是 "元类型" ，它们仅用于特定上下文中。常规类型也可使用；这意味着会得到一个 `typed` 表达式。
{==+==}

{==+==}
Typed vs untyped parameters
---------------------------
{==+==}
Typed 参数和 untyped 参数的比较
--------------------------------------------------------------
{==+==}

{==+==}
An `untyped` parameter means that symbol lookups and type resolution is not
performed before the expression is passed to the template. This means that
*undeclared* identifiers, for example, can be passed to the template:
{==+==}
`untyped` 参数表示表达式传递给模板前不执行符号的查找和类型的解析。这意味着，比如，*未声明* 的标识符也能传递给模板:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  template declareInt(x: untyped) =
    var x: int

  declareInt(x) # valid
  x = 3
  ```
{==+==}
  ```nim  test = "nim c $1"
  template declareInt(x: untyped) =
    var x: int

  declareInt(x) # 可以
  x = 3
  ```
{==+==}

{==+==}
  ```nim  test = "nim c $1"  status = 1
  template declareInt(x: typed) =
    var x: int

  declareInt(x) # invalid, because x has not been declared and so it has no type
  ```
{==+==}
  ```nim  test = "nim c $1"  status = 1
  template declareInt(x: typed) =
    var x: int

  declareInt(x) # 不正确，因为此处 x 没有被声明，所以它没有类型
  ```
{==+==}

{==+==}
A template where every parameter is `untyped` is called an `immediate`:idx:
template. For historical reasons, templates can be explicitly annotated with
an `immediate` pragma and then these templates do not take part in
overloading resolution and the parameters' types are *ignored* by the
compiler. Explicit immediate templates are now deprecated.
{==+==}
如果一个模板的每个参数都是 `untyped` 的，则称它为 `immediate`:idx: 模板。由于历史原因，模板可以用 `immediate` 编译指示显式地标记，这类模板不参与重载解析，参数的类型也将被编译器 *忽略*。显式声明的即时模板现在已经弃用。
{==+==}

{==+==}
**Note**: For historical reasons, `stmt` was an alias for `typed` and
`expr` was an alias for `untyped`, but they are removed.
{==+==}
**注意**: 由于历史原因， `stmt` 是 `typed` 的别名， `expr` 是 `untyped` 的别名，但它们都被移除了。
{==+==}

{==+==}
Passing a code block to a template
----------------------------------
{==+==}
传递代码块到模板
--------------------------------
{==+==}

{==+==}
One can pass a block of statements as the last argument to a template
following the special `:` syntax:
{==+==}
通过专门的 `:` 语法，可以将一个语句块传递给模板的最后一个参数:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  template withFile(f, fn, mode, actions: untyped): untyped =
    var f: File
    if open(f, fn, mode):
      try:
        actions
      finally:
        close(f)
    else:
      quit("cannot open: " & fn)

  withFile(txt, "ttempl3.txt", fmWrite):  # special colon
    txt.writeLine("line 1")
    txt.writeLine("line 2")
  ```
{==+==}
  ```nim  test = "nim c $1"
  template withFile(f, fn, mode, actions: untyped): untyped =
    var f: File
    if open(f, fn, mode):
      try:
        actions
      finally:
        close(f)
    else:
      quit("cannot open: " & fn)

  withFile(txt, "ttempl3.txt", fmWrite):  # 专门的冒号
    txt.writeLine("line 1")
    txt.writeLine("line 2")
  ```
{==+==}

{==+==}
In the example, the two `writeLine` statements are bound to the `actions`
parameter.
{==+==}
在这个例子中，那两行 `writeLine` 语句被绑定到了模板的 `actions` 参数。
{==+==}

{==+==}
Usually, to pass a block of code to a template, the parameter that accepts
the block needs to be of type `untyped`. Because symbol lookups are then
delayed until template instantiation time:
{==+==}
通常，当传递一个代码块到模板时，接受代码块的参数需要被声明为 `untyped` 类型。因为这样，符号查找会被推迟到模板实例化期间:
{==+==}

{==+==}
  ```nim  test = "nim c $1"  status = 1
  template t(body: typed) =
    proc p = echo "hey"
    block:
      body

  t:
    p()  # fails with 'undeclared identifier: p'
  ```
{==+==}
  ```nim  test = "nim c $1"  status = 1
  template t(body: typed) =
    proc p = echo "hey"
    block:
      body

  t:
    p()  # 因 p 未声明而失败
  ```
{==+==}

{==+==}
The above code fails with the error message that `p` is not declared.
The reason for this is that the `p()` body is type-checked before getting
passed to the `body` parameter and type checking in Nim implies symbol lookups.
The same code works with `untyped` as the passed body is not required to be
type-checked:
{==+==}
以上代码错误信息为 `p` 未被声明。其原因是 `p()` 语句在传递到 `body` 参数前执行类型检查和符号查找。修改模板参数类型为 `untyped` 使得传递语句体时不做类型检查，同样的代码便可以通过:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  template t(body: untyped) =
    proc p = echo "hey"
    block:
      body

  t:
    p()  # compiles
  ```
{==+==}
  ```nim  test = "nim c $1"
  template t(body: untyped) =
    proc p = echo "hey"
    block:
      body

  t:
    p()  # 编译通过
  ```
{==+==}

{==+==}
Varargs of untyped
------------------
{==+==}
untyped 可变参数
---------------------------------------
{==+==}

{==+==}
In addition to the `untyped` meta-type that prevents type checking, there is
also `varargs[untyped]` so that not even the number of parameters is fixed:
{==+==}
除了 `untyped` 元类型可以阻止类型检查之外，用了 `varargs[untyped]` 连参数的个数也不检查的了:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  template hideIdentifiers(x: varargs[untyped]) = discard

  hideIdentifiers(undeclared1, undeclared2)
  ```
{==+==}
  ```nim  test = "nim c $1"
  template hideIdentifiers(x: varargs[untyped]) = discard

  hideIdentifiers(undeclared1, undeclared2)
  ```
{==+==}

{==+==}
However, since a template cannot iterate over varargs, this feature is
generally much more useful for macros.
{==+==}
然而，因为模板不能遍历可变参数，一般而言这个功能在宏中更有用。
{==+==}

{==+==}
Symbol binding in templates
---------------------------
{==+==}
模板中的符号绑定
--------------------------------
{==+==}

{==+==}
A template is a `hygienic`:idx: macro and so opens a new scope. Most symbols are
bound from the definition scope of the template:
{==+==}
模板是 `hygienic`:idx: "卫生" 宏，会新开作用域。大部分符号会在宏的定义作用域中绑定:
{==+==}

{==+==}
  ```nim
  # Module A
  var
    lastId = 0

  template genId*: untyped =
    inc(lastId)
    lastId
  ```
{==+==}
  ```nim
  # 模块 A
  var
    lastId = 0

  template genId* : untyped =
    inc(lastId)
    lastId
  ```
{==+==}

{==+==}
  ```nim
  # Module B
  import A

  echo genId() # Works as 'lastId' has been bound in 'genId's defining scope
  ```
{==+==}
  ```nim
  # 模块 B
  import A

  echo genId() # 可以，因为 'lastId' 在 'genId' 的定义作用域中完成绑定
  ```
{==+==}

{==+==}
As in generics, symbol binding can be influenced via `mixin` or `bind`
statements.
{==+==}
像在泛型中一样，模板中的符号绑定也受 `mixin` 或 `bind` 语句影响。
{==+==}

{==+==}
Identifier construction
-----------------------
{==+==}
标识符的构建
--------------------
{==+==}

{==+==}
In templates, identifiers can be constructed with the backticks notation:
{==+==}
在模板中，标识符可以通过反引号标注构建:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  template typedef(name: untyped, typ: typedesc) =
    type
      `T name`* {.inject.} = typ
      `P name`* {.inject.} = ref `T name`

  typedef(myint, int)
  var x: PMyInt
  ```
{==+==}
  ```nim  test = "nim c $1"
  template typedef(name: untyped, typ: typedesc) =
    type
      `T name`* {.inject.} = typ
      `P name`* {.inject.} = ref `T name`

  typedef(myint, int)
  var x: PMyInt
  ```
{==+==}

{==+==}
In the example, `name` is instantiated with `myint`, so \`T name\` becomes
`Tmyint`.
{==+==}
在这个例子中， `name` 参数实例化为 `myint`，所以 \`T name\` 就变为 `Tmyint`。
{==+==}

{==+==}
Lookup rules for template parameters
------------------------------------
{==+==}
模板参数的查找规则
----------------------------------------
{==+==}

{==+==}
A parameter `p` in a template is even substituted in the expression `x.p`.
Thus, template arguments can be used as field names and a global symbol can be
shadowed by the same argument name even when fully qualified:
{==+==}
模板中的参数 `p` 总是会被替换，即使是像 `x.p` 这样的表达式。因此，模板参数可当作字段名称使用，而且一个全局符号会被同名参数所覆盖，即便使用了完全限定也会覆盖:
{==+==}

{==+==}
  ```nim
  # module 'm'

  type
    Lev = enum
      levA, levB

  var abclev = levB

  template tstLev(abclev: Lev) =
    echo abclev, " ", m.abclev

  tstLev(levA)
  # produces: 'levA levA'
  ```
{==+==}
  ```nim
  # 模块 'm'

  type
    Lev = enum
      levA, levB

  var abclev = levB

  template tstLev(abclev: Lev) =
    echo abclev, " ", m.abclev

  tstLev(levA)
  # 输出: 'levA levA'
  ```
{==+==}

{==+==}
But the global symbol can properly be captured by a `bind` statement:
{==+==}
但是全局符号可以通过 `bind` 语句适时捕获:
{==+==}

{==+==}
  ```nim
  # module 'm'

  type
    Lev = enum
      levA, levB

  var abclev = levB

  template tstLev(abclev: Lev) =
    bind m.abclev
    echo abclev, " ", m.abclev

  tstLev(levA)
  # produces: 'levA levB'
  ```
{==+==}
  ```nim
  # 模块 'm'

  type
    Lev = enum
      levA, levB

  var abclev = levB

  template tstLev(abclev: Lev) =
    bind m.abclev
    echo abclev, " ", m.abclev

  tstLev(levA)
  # 输出: 'levA levB'
  ```
{==+==}

{==+==}
Hygiene in templates
--------------------
{==+==}
模板的卫生性
------------------------
{==+==}

{==+==}
Per default, templates are `hygienic`:idx:\: Local identifiers declared in a
template cannot be accessed in the instantiation context:
{==+==}
默认情况下，模板是 `hygienic`:idx: "卫生" 的: 模板内局部声明的标识符，不能在实例化上下文中访问:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  template newException*(exceptn: typedesc, message: string): untyped =
    var
      e: ref exceptn  # e is implicitly gensym'ed here
    new(e)
    e.msg = message
    e

  # so this works:
  let e = "message"
  raise newException(IoError, e)
  ```
{==+==}
  ```nim  test = "nim c $1"
  template newException* (exceptn: typedesc, message: string): untyped =
    var
      e: ref exceptn  # e 在这里被隐式地 gensym
    new(e)
    e.msg = message
    e

  # 允许这样写:
  let e = "message"
  raise newException(IoError, e)
  ```
{==+==}

{==+==}
Whether a symbol that is declared in a template is exposed to the instantiation
scope is controlled by the `inject`:idx: and `gensym`:idx: pragmas:
`gensym`'ed symbols are not exposed but `inject`'ed symbols are.
{==+==}
模板中声明的符号是否向实例所处作用域公开取决于 `inject`:idx: 和 `gensym`:idx: 编译指示。被 `gensym` 编译指示标记的符号不会公开，而 `inject` 编译指示则反之。
{==+==}

{==+==}
The default for symbols of entity `type`, `var`, `let` and `const`
is `gensym` and for `proc`, `iterator`, `converter`, `template`,
`macro` is `inject`. However, if the name of the entity is passed as a
template parameter, it is an `inject`'ed symbol:
{==+==}
`type` , `var`, `let` 和 `const` 等实体符号默认是 `gensym`，`proc`，`iterator`，`converter`，`template`，`macro` 等默认是 `inject`。
然而，如果实体的名称是由模板参数传入的，那么会标记为 `inject`。
{==+==}

{==+==}
  ```nim
  template withFile(f, fn, mode: untyped, actions: untyped): untyped =
    block:
      var f: File  # since 'f' is a template param, it's injected implicitly
      ...

  withFile(txt, "ttempl3.txt", fmWrite):
    txt.writeLine("line 1")
    txt.writeLine("line 2")
  ```
{==+==}
  ```nim
  template withFile(f, fn, mode: untyped, actions: untyped): untyped =
    block:
      var f: File  # 因为 'f' 是一个模板参数，所以隐式地 'inject'
      ...

  withFile(txt, "ttempl3.txt", fmWrite):
    txt.writeLine("line 1")
    txt.writeLine("line 2")
  ```
{==+==}

{==+==}
The `inject` and `gensym` pragmas are second class annotations; they have
no semantics outside a template definition and cannot be abstracted over:
{==+==}
`inject` 和 `gensym` 编译指示是二类注解；它们在模板定义之外没有语义，也不能被再次封装。
{==+==}

{==+==}
  ```nim
  {.pragma myInject: inject.}

  template t() =
    var x {.myInject.}: int # does NOT work
  ```
{==+==}
  ```nim
  {.pragma myInject: inject.}

  template t() =
    var x {.myInject.}: int # 无法工作
  ```
{==+==}

{==+==}
To get rid of hygiene in templates, one can use the `dirty`:idx: pragma for
a template. `inject` and `gensym` have no effect in `dirty` templates.
{==+==}
如果不想保持模板的卫生性，我们可以在模板中使用 `dirty`:idx: 编译指示。`inject` 和 `gensym` 在 `dirty` 模板中没有作用。
{==+==}

{==+==}
`gensym`'ed symbols cannot be used as `field` in the `x.field` syntax.
Nor can they be used in the `ObjectConstruction(field: value)`
and `namedParameterCall(field = value)` syntactic constructs.
{==+==}
标记为 `gensym` 的符号既不能作为 `field` 用在 `x.field` 语义中，也不能用于 `ObjectConstruction(field: value)` 和 `namedParameterCall(field = value)` 等语义构造。
{==+==}

{==+==}
The reason for this is that code like
{==+==}
其原因在于要让以下代码:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  type
    T = object
      f: int

  template tmp(x: T) =
    let f = 34
    echo x.f, T(f: 4)
  ```
{==+==}
  ```nim  test = "nim c $1"
  type
    T = object
      f: int

  template tmp(x: T) =
    let f = 34
    echo x.f, T(f: 4)
  ```
{==+==}

{==+==}
should work as expected.
{==+==}
按预期执行。
{==+==}

{==+==}
However, this means that the method call syntax is not available for
`gensym`'ed symbols:
{==+==}
但是这意味着 `gensym` 生成的符号无法用于方法调用语法:
{==+==}

{==+==}
  ```nim  test = "nim c $1"  status = 1
  template tmp(x) =
    type
      T {.gensym.} = int

    echo x.T # invalid: instead use:  'echo T(x)'.

  tmp(12)
  ```
{==+==}
  ```nim  test = "nim c $1"  status = 1
  template tmp(x) =
    type
      T {.gensym.} = int

    echo x.T # 不可以，应该使用: 'echo T(x)' 。

  tmp(12)
  ```
{==+==}

{==+==}
Limitations of the method call syntax
-------------------------------------
{==+==}
方法调用语法的局限
----------------------------------------
{==+==}

{==+==}
The expression `x` in `x.f` needs to be semantically checked (that means
symbol lookup and type checking) before it can be decided that it needs to be
rewritten to `f(x)`. Therefore, the dot syntax has some limitations when it
is used to invoke templates/macros:
{==+==}
`x.f` 里的表达式 `x` 需要先经过语义检查(意味着符号查找和类型检查)，然后才能决定是否需要重写成 `f(x)` 的形式。因此，当用于调用模板或宏时，`.` 语法有一些局限:
{==+==}

{==+==}
  ```nim  test = "nim c $1"  status = 1
  template declareVar(name: untyped) =
    const name {.inject.} = 45

  # Doesn't compile:
  unknownIdentifier.declareVar
  ```
{==+==}
  ```nim  test = "nim c $1"  status = 1
  template declareVar(name: untyped) =
    const name {.inject.} = 45

  # 无法编译:
  unknownIdentifier.declareVar
  ```
{==+==}

{==+==}
It is also not possible to use fully qualified identifiers with module
symbol in method call syntax. The order in which the dot operator
binds to symbols prohibits this.
{==+==}
在方法调用语义中，无法使用带有模块符号的完全限定标识符，这是 `.` 运算符的绑定顺序决定的。
{==+==}

{==+==}
  ```nim  test = "nim c $1"  status = 1
  import std/sequtils

  var myItems = @[1,3,3,7]
  let N1 = count(myItems, 3) # OK
  let N2 = sequtils.count(myItems, 3) # fully qualified, OK
  let N3 = myItems.count(3) # OK
  let N4 = myItems.sequtils.count(3) # illegal, `myItems.sequtils` can't be resolved
  ```
{==+==}
  ```nim  test = "nim c $1"  status = 1
  import std/sequtils

  var myItems = @[1,3,3,7]
  let N1 = count(myItems, 3) # 可行
  let N2 = sequtils.count(myItems, 3) # 完全限定, 此处可行
  let N3 = myItems.count(3) # 可行
  let N4 = myItems.sequtils.count(3) # 非法的, `myItems.sequtils` 无法解析
  ```
{==+==}

{==+==}
This means that when for some reason a procedure needs a
disambiguation through the module name, the call needs to be
written in function call syntax.
{==+==}
这就是说，当由于某种原因，一个过程需要借助模块名消除歧义时，这个调用就需要使用函数调用的语法来书写。
{==+==}

{==+==}
Macros
======
{==+==}
宏
======
{==+==}

{==+==}
A macro is a special function that is executed at compile time.
Normally, the input for a macro is an abstract syntax
tree (AST) of the code that is passed to it. The macro can then do
transformations on it and return the transformed AST. This can be used to
add custom language features and implement `domain-specific languages`:idx:.
{==+==}
宏是一种在编译时运行的特殊函数。通常，宏的输入是所传入的代码的抽象语法树(AST)。宏然后可以对其执行转换，并将转换后的 AST 结果返回。可以用来添加自定义的语言功能，实现 `domain-specific languages`:idx: "领域特定语言"。
{==+==}

{==+==}
Macro invocation is a case where semantic analysis does **not** entirely proceed
top to bottom and left to right. Instead, semantic analysis happens at least
twice:
{==+==}
宏的调用是一种特殊情况，语义分析并**不**完全是自顶向下、从左到右的。相反，语义分析至少发生两次:
{==+==}

{==+==}
* Semantic analysis recognizes and resolves the macro invocation.
* The compiler executes the macro body (which may invoke other procs).
* It replaces the AST of the macro invocation with the AST returned by the macro.
* It repeats semantic analysis of that region of the code.
* If the AST returned by the macro contains other macro invocations,
  this process iterates.
{==+==}
* 语义分析识别并解析宏调用。
* 编译器执行宏正文(可能会调用其他过程)。
* 将宏调用的 AST 替换为宏返回的 AST。
* 再次对该区域的代码进行语义分析。
* 如果宏返回的 AST 包含其他宏调用，则迭代执行。
{==+==}

{==+==}
While macros enable advanced compile-time code transformations, they
cannot change Nim's syntax.
{==+==}
虽然宏支持高级的编译时代码转换，但它们无法更改 Nim 的语法。
{==+==}

{==+==}
**Style note:** For code readability, it is best to use the least powerful
programming construct that remains expressive. So the "check list" is:
{==+==}
**风格说明:** 为了代码的可读性，最好选用最弱的但又能满足需要的编程结构。建议如下:
{==+==}

{==+==}
(1) Use an ordinary proc/iterator, if possible.
(2) Else: Use a generic proc/iterator, if possible.
(3) Else: Use a template, if possible.
(4) Else: Use a macro.
{==+==}
(1) 尽可能使用常规的过程和迭代器。
(2) 其次尽可能使用泛型过程和迭代器。
(3) 再次尽可能使用模板。
(4) 最后才考虑使用宏。
{==+==}

{==+==}
Debug example
-------------
{==+==}
debug 示例
--------------------
{==+==}

{==+==}
The following example implements a powerful `debug` command that accepts a
variable number of arguments:
{==+==}
下面的例子实现了一个接受可变参数的 `debug` 命令，功能强大:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  # to work with Nim syntax trees, we need an API that is defined in the
  # `macros` module:
  import std/macros

  macro debug(args: varargs[untyped]): untyped =
    # `args` is a collection of `NimNode` values that each contain the
    # AST for an argument of the macro. A macro always has to
    # return a `NimNode`. A node of kind `nnkStmtList` is suitable for
    # this use case.
    result = nnkStmtList.newTree()
    # iterate over any argument that is passed to this macro:
    for n in args:
      # add a call to the statement list that writes the expression;
      # `toStrLit` converts an AST to its string representation:
      result.add newCall("write", newIdentNode("stdout"), newLit(n.repr))
      # add a call to the statement list that writes ": "
      result.add newCall("write", newIdentNode("stdout"), newLit(": "))
      # add a call to the statement list that writes the expressions value:
      result.add newCall("writeLine", newIdentNode("stdout"), n)

  var
    a: array[0..10, int]
    x = "some string"
  a[0] = 42
  a[1] = 45

  debug(a[0], a[1], x)
  ```
{==+==}
  ```nim  test = "nim c $1"
  # 导入 `macros` 模块以获得操作 Nim 语法树所需要的 API
  import std/macros

  macro debug(args: varargs[untyped]): untyped =
    # `args` 是一个 `NimNode` 值列表，每个值对应一个传入参数的 AST
    # 宏总是需要返回一个 `NimNode`，本例子返回的是 `nnkStmtList` 节点
    result = nnkStmtList.newTree()
    # 遍历传入这个宏传递的所有参数:
    for n in args:
      # 为语句列表添加 write 调用;
      # `toStrLit` 将 AST 转换为字符串形式:
      result.add newCall("write", newIdentNode("stdout"), newLit(n.repr))
      # 为语句列表添加 write 调用，输出 ": "
      result.add newCall("write", newIdentNode("stdout"), newLit(": "))
      # 为语句列表添加 writeLine 调用，输出值并换行:
      result.add newCall("writeLine", newIdentNode("stdout"), n)

  var
    a: array[0..10, int]
    x = "some string"
  a[0] = 42
  a[1] = 45

  debug(a[0], a[1], x)
  ```
{==+==}

{==+==}
The macro call expands to:
{==+==}
这个宏展开为以下代码:
{==+==}

{==+==}
  ```nim
  write(stdout, "a[0]")
  write(stdout, ": ")
  writeLine(stdout, a[0])

  write(stdout, "a[1]")
  write(stdout, ": ")
  writeLine(stdout, a[1])

  write(stdout, "x")
  write(stdout, ": ")
  writeLine(stdout, x)
  ```
{==+==}
  ```nim
  write(stdout, "a[0]")
  write(stdout, ": ")
  writeLine(stdout, a[0])

  write(stdout, "a[1]")
  write(stdout, ": ")
  writeLine(stdout, a[1])

  write(stdout, "x")
  write(stdout, ": ")
  writeLine(stdout, x)
  ```
{==+==}

{==+==}
Arguments that are passed to a `varargs` parameter are wrapped in an array
constructor expression. This is why `debug` iterates over all of `args`'s
children.
{==+==}
传递给 `varargs` 的各参数被包装到数组构造函数表达式中。这就是 `debug` 能遍历所有 `args` 子节点的原因。
{==+==}

{==+==}
bindSym
-------
{==+==}
bindSym
-------
{==+==}

{==+==}
The above `debug` macro relies on the fact that `write`, `writeLine` and
`stdout` are declared in the system module and are thus visible in the
instantiating context. There is a way to use bound identifiers
(aka `symbols`:idx:) instead of using unbound identifiers. The `bindSym`
builtin can be used for that:
{==+==}
上面的 `debug` 宏依赖于这样一个事实，`write`、`writeLine` 和 `stdout` 是在 system 模块中声明的，所以在实例化时的上下文里是可见的。有一种使用绑定标识符 (即 `symbols`:idx:) 代替未绑定的标识符的方法，这用到了内置的 `bindSym`:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/macros

  macro debug(n: varargs[typed]): untyped =
    result = newNimNode(nnkStmtList, n)
    for x in n:
      # we can bind symbols in scope via 'bindSym':
      add(result, newCall(bindSym"write", bindSym"stdout", toStrLit(x)))
      add(result, newCall(bindSym"write", bindSym"stdout", newStrLitNode(": ")))
      add(result, newCall(bindSym"writeLine", bindSym"stdout", x))

  var
    a: array[0..10, int]
    x = "some string"
  a[0] = 42
  a[1] = 45

  debug(a[0], a[1], x)
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/macros

  macro debug(n: varargs[typed]): untyped =
    result = newNimNode(nnkStmtList, n)
    for x in n:
      # 我们通过 'bindSym' 在作用域中绑定符号:
      add(result, newCall(bindSym"write", bindSym"stdout", toStrLit(x)))
      add(result, newCall(bindSym"write", bindSym"stdout", newStrLitNode(": ")))
      add(result, newCall(bindSym"writeLine", bindSym"stdout", x))

  var
    a: array[0..10, int]
    x = "some string"
  a[0] = 42
  a[1] = 45

  debug(a[0], a[1], x)
  ```
{==+==}

{==+==}
The macro call expands to:
{==+==}
这个宏展开为以下代码:
{==+==}

{==+==}
However, the symbols `write`, `writeLine` and `stdout` are already bound
and are not looked up again. As the example shows, `bindSym` does work with
overloaded symbols implicitly.
{==+==}
不过，与前一个版本的 `debug` 不同，这里的符号 `write`，`writeLine` 和 `stdout` 已经完成绑定，不会再次查找。如例子所示，`bindSym` 确实可以隐式地处理重载符号。
{==+==}

{==+==}
Note that the symbol names passed to `bindSym` have to be constant. The
experimental feature `dynamicBindSym` (`experimental manual
<manual_experimental.html#dynamic-arguments-for-bindsym>`_)
allows this value to be computed dynamically.
{==+==}
请注意，传递给 `bindSym` 的符号名称必须是常量。实验功能 `dynamicBindSym` ( `experimental manual <manual_experimental.html#dynamic-arguments-for-bindsym>`_ ) 允许动态计算得到此值。
{==+==}
