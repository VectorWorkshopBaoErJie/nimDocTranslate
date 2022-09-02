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
`noSideEffect` 编译指示用于标记过程和迭代器，它只能通过参数产生副作用。这意味着这个过程或迭代器只能改变形参可访问的地址。假如该过程或迭代器参数中没有 `var`、`ref`、 `ptr`、 `cstring`、 `proc` 中的任意类型，则其无法修改外部地址。
{==+==}

{==+==}
In other words, a routine has no side effects if it does not access a threadlocal
or global variable and it does not call any routine that has a side effect.
{==+==}
换句话说，如果一个例程既不接受本地线程变量或全局变量、也不调用其他带副作用的例程，则该例程是无副作用的。
{==+==}

{==+==}
It is a static error to mark a proc/iterator to have no side effect if the compiler cannot verify this.
{==+==}
如果给予一个过程或迭代器无副作用标记，而编译器无法验证，将引发静态错误。
{==+==}

{==+==}
As a special semantic rule, the built-in `debugEcho
<system.html#debugEcho,varargs[typed,]>`_ pretends to be free of side effects
so that it can be used for debugging routines marked as `noSideEffect`.
{==+==}
作为一个特殊的语义规则，内置的 `debugEcho <system.html#debugEcho,varargs[typed,]>`_ 被视为无副作用的。因此，其可以用于被标记为 `noSideEffect` 例程的调试。
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
`cast` 编译指示可用于强制转换编译器的 `{.noSideEffect.}` 无副作用语义。
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
**副作用通常是被推断的，其类似于异常跟踪的推断。**
{==+==}

{==+==}
GC safety effect
----------------
{==+==}
GC安全的作用
------------------------
{==+==}

{==+==}
We call a proc `p` `GC safe`:idx: when it doesn't access any global variable
that contains GC'ed memory (`string`, `seq`, `ref` or a closure) either
directly or indirectly through a call to a GC unsafe proc.
{==+==}
当不能直接或间接地通过调用GC不安全的过程来访问任何包含GC内存的全局变量( `string` 、 `seq` 、 `ref` 或一个闭包)时，我们调用过程 `p` 则是 `GC safe`:idx: "GC安全" 的。
{==+==}

{==+==}
**The GC safety property is usually inferred. The inference for GC safety is
analogous to the inference for exception tracking.**
{==+==}
**是否GC安全通常是被推断的，其类似于异常跟踪的推断。**
{==+==}

{==+==}
The `gcsafe`:idx: annotation can be used to mark a proc to be gcsafe,
otherwise this property is inferred by the compiler. Note that `noSideEffect`
implies `gcsafe`.
{==+==}
`gcsafe`:idx: 注解可用于标记一个过程为GC安全的，否则将由编译器进行推断。值得注意的是， `noSideEffect` 也就意味着 `gcsafe` 。
{==+==}

{==+==}
Routines that are imported from C are always assumed to be `gcsafe`.
{==+==}
从C语言库导入的例程将总是被看作 `gcsafe` 的。
{==+==}

{==+==}
To override the compiler's gcsafety analysis a `{.cast(gcsafe).}` pragma block can
be used:
{==+==}
 `{.cast(gcsafe).}` 编译指示块可用于覆写编译器的GC安全语义。
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
- `Shared heap memory management <mm.html>`_ 。
{==+==}
- `Shared heap memory management <mm.html>`_ 。
{==+==}

{==+==}
Effects pragma
--------------
{==+==}
作用编译标志
------------------------
{==+==}

{==+==}
The `effects` pragma has been designed to assist the programmer with the
effects analysis. It is a statement that makes the compiler output all inferred
effects up to the `effects`'s position:
{==+==}
`effects` 编译指示用于协助程序员进行作用分析。这条语句可以使编译器输出所有被推断出的作用到 `effects` 的位置上:
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
编译器会产生一条提示消息，提示 `IOError` 可以被引发。 `OSError` 未被列出，因为它不能在 `effects` 编译指示所在的分支中引发。
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
泛型是Nim使用 `type parameters`:idx: "类型参数化" 对过程、迭代器或类型进行参数化的方法。根据上下文的不同，方括号可以引入类型参数，或用于实例化泛型过程、迭代器或类型。
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
    BinaryTree*[T] = ref object # 二叉树是一个使用泛型参数'T'的泛型类
                                
      le, ri: BinaryTree[T]     # 左、右子树; 可能为空
      data: T                   # 数据存储在节点中

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
    # 快捷过程:
    add(root, newNode(data))

  iterator preorder*[T](root: BinaryTree[T]): T =
    # 二叉树的预序遍历.
    # 显式地使用栈(比递归迭代器工厂更有效).
    var stack: seq[BinaryTree[T]] = @[root]
    while stack.len > 0:
      var n = stack.pop()
      while n != nil:
        yield n.data
        add(stack, n.ri)  # 将右子树入栈
        n = n.le          # 并跟随左指针

  var
    root: BinaryTree[string]  # 使用字符串实例化二叉树
  add(root, newNode("hello")) #实例化 `newNode` 和 `add`
  add(root, "world")          # 实例化第二个 `add` 过程
  for str in preorder(root):
    stdout.writeLine(str)
  ```
{==+==}

{==+==}
The `T` is called a `generic type parameter`:idx: or
a `type variable`:idx:.
{==+==}
这里的 `T` 被称为 `generic type parameter`:idx: "泛型类型参数"，或者 `type variable`:idx: "可变类型"。
{==+==}

{==+==}
Is operator
-----------
{==+==}
`is` 操作符
----------------------
{==+==}

{==+==}
The `is` operator is evaluated during semantic analysis to check for type
equivalence. It is therefore very useful for type specialization within generic
code:
{==+==}
`is` 操作符在语义分析期间评估检查类型的等价性。因此其在对类型有特定要求的泛型代码中有重要作用。
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
      when not (Key is string): # 优化空值字符串
        deletedKeys: seq[bool]
  ```
{==+==}

{==+==}
Type classes
------------
{==+==}
Type 类
--------------
{==+==}

{==+==}
A type class is a special pseudo-type that can be used to match against
types in the context of overload resolution or the `is` operator.
Nim supports the following built-in type classes:
{==+==}
Type类是一种特殊的伪类型，可在重载解析或 `is` 操作符处针对性地匹配上下文中的类型。Nim支持以下内置类型类:
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
`object`             实例类型
`tuple`              元组类型
`enum`               枚举类型
`proc`               过程类型
`ref`                过程类型
`ptr`                指针类型
`var`                变量类型
`distinct`           distinct类型
`array`              数组类型
`set`                集合类型
`seq`                序列类型
`auto`               任何类型
==================   ===================================================
{==+==}

{==+==}
Furthermore, every generic type automatically creates a type class of the same
name that will match any instantiation of the generic type.
{==+==}
此外，任何泛型类型都会自动创建一个同名的type类，以此匹配该泛型类的实例。
{==+==}

{==+==}
Type classes can be combined using the standard boolean operators to form
more complex type classes:
{==+==}
Type类可以通过标准的布尔操作符组合为更复杂的Type类。
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
  # 创建一个可以匹配所有tuple类和object类的type类
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
泛型参数列表中的参数类型约束可以通过 `,` 进行分组，并以 `;` 结束一个分组，就像宏和模板中的参数列表那样:
{==+==}

{==+==}
  ```nim
  proc fn1[T; U, V: SomeFloat]() = discard # T is unconstrained
  template fn2(t; u, v: SomeFloat) = discard # t is unconstrained
  ```
{==+==}
  ```nim
  proc fn1[T; U, V: SomeFloat]() = discard    # T 是不受类型约束的
  template fn2(t; u, v: SomeFloat) = discard  # t 是不受类型约束的
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
虽然type类在语法上接近于类ML语言中的抽象数据类型和代数数据类型，但应该知道type类是实例化时强制执行的静态约束。type类本身并非真的类，而只是提供了一个泛型检查系统以将其最终解释为确定的单一类型。type类不允许运行时的动态类型分配，这与object、变量和方法不同。
{==+==}

{==+==}
As an example, the following would not compile:
{==+==}
例如，以下代码将无法通过编译:
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
  var foo: TypeClass = 2 # foo的类型在这里被解释为int类型
  foo = "this will fail" # 这里发生错误，因为foo已经被解释为int类型
  ```
{==+==}

{==+==}
Nim allows for type classes and regular types to be specified
as `type constraints`:idx: of the generic type parameter:
{==+==}
Nim允许将type类和常规类用作泛型类型参数的 `type constraints`:idx: "类型约束":
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

  onlyIntOrString(450, 616) # 有效的
  onlyIntOrString(5.0, 0.0) # 类型不匹配
  onlyIntOrString("xy", 50) # 无效的，因为同一个T不能被同时指定为两种不同类型
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
一个type类可以直接作为参数的类型使用。
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
  # 创建一个可以同时匹配tuple和object类的type类
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
像这样以type类作为参数类型的过程被称为 `implicitly generic`:idx: "隐式泛型"。隐式泛型每使用一组特定参数类型组合，都将在程序中创建一个实例。
{==+==}

{==+==}
By default, during overload resolution, each named type class will bind to
exactly one concrete type. We call such type classes `bind once`:idx: types.
Here is an example taken directly from the system module to illustrate this:
{==+==}
通常，重载解析期间，每一个被命名的type类都将被绑定到一个确切的混合类。我们称这些type类 `bind once`:idx: "单一绑定"。以下是从系统模块里直接拿来的例子:
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
    ## 针对元组的泛型操作符 `==` 在`x` 和 `y`的组合中是左结合的
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
或者，当 `distinct` 类修饰词用于type类，将允许每一参数绑定到匹配type类中的不同类型，这些type类被称为 `bind many`:idx: "多绑定"。
{==+==}

{==+==}
Procs written with the implicitly generic style will often need to refer to the
type parameters of the matched generic type. They can be easily accessed using
the dot syntax:
{==+==}
以隐式泛型的方式书写过程时，需要指定匹配的类型参数。这样，才能用 `.` 语法便捷的使用它们所包含的内容。
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
这里有说明隐式泛型的更多例子:
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

  # 等同于以下写法:

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

  # 等同于以下写法:

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

  # 等同于以下写法:

  proc p[Key, Value, KeyB, ValueB](a: Table[Key, Value], b: Table[KeyB, ValueB])
  ```
{==+==}

{==+==}
`typedesc` used as a parameter type also introduces an implicit
generic. `typedesc` has its own set of rules:
{==+==}
`typedesc` 作为参数类型使用时，总是产生一个隐式泛型，`typedesc` 有其独有的设置规则。
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
`typedesc` 是一个多绑定type类型:
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

  # 等同于以下写法:

  proc p[T, T2](a: typedesc[T], b: typedesc[T2])
  ```
{==+==}

{==+==}
A parameter of type `typedesc` is itself usable as a type. If it is used
as a type, it's the underlying type. (In other words, one level
of "typedesc"-ness is stripped off:
{==+==}
一个具 `typedesc` 类型的参数自身也是可以作为一个类型使用。如果将其作为类型使用，其将是底层类型。(换言之， `typedesc` 类型参数最终绑定的类型将被剥离出来使用):
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

  # 等同于以下代码:
  proc p[T](a: typedesc[T]; b: T) = discard

  # 这是有效的调用:
  p(int, 4)
  # 这里 'a' 需要的参数是一个类型, 而 'b' 需要的则是一个该类型的值。
  ```
{==+==}

{==+==}
Generic inference restrictions
------------------------------
{==+==}
泛型推断局限
------------------------
{==+==}

{==+==}
The types `var T` and `typedesc[T]` cannot be inferred in a generic
instantiation. The following is not allowed:
{==+==}
类型 `var T` 和 `typedesc[T]` 无法在泛型实例中被推断，以下语句是不允许的:
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

  # 允许的: 'T' 被推断为 'int'类型
  g(c, 42)

  # 无效的: 'T' 无法被推断为 'var int'
  g(v, i)

  # 总是允许的: 明确通过 'var int' 进行实例化
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
泛型中的符号绑定规则略显微妙: 其存在开放和封闭两种状态的符号。一个封闭的符号在实例的上下文中无法被重新绑定，而一个开放的符号可以。默认情况下，重载符号都是开放的，而所有其他符号都是封闭的。
{==+==}

{==+==}
Open symbols are looked up in two different contexts: Both the context
at definition and the context at instantiation are considered:
{==+==}
开放的符号可以在在两种不同的上下文中被找到: 一是其定义所处的上下文，二是实例中的上下文:
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

  echo a == b # works!
  ```
{==+==}

{==+==}
In the example, the generic `==` for tuples (as defined in the system module)
uses the `==` operators of the tuple's components. However, the `==` for
the `Index` type is defined *after* the `==` for tuples; yet the example
compiles as the instantiation takes the currently defined symbols into account
too.
{==+==}
在这个例子中，针对元组泛型符号 `==` (定义于系统模块)，使用 `==` 操作符进行元组的组合。然而，针对 `Index` 类型的 `==` 符号定义在其针对元组的定义之后；所以，这个例子在被编译时，实例中当前符号的定义也会进入其中。
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
一个符号可以通过 `mixin`:idx: "混合" 关键字声明为开放:
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
`mixin` 语句只有在模板和泛型中才有意义。
{==+==}

{==+==}
Bind statement
--------------
{==+==}
绑定语句
----------------
{==+==}

{==+==}
The `bind` statement is the counterpart to the `mixin` statement. It
can be used to explicitly declare identifiers that should be bound early (i.e.
the identifiers should be looked up in the scope of the template/generic
definition):
{==+==}
 `bind` 语句相对于 `mixin` 语句。可用于显式地声明标识符需要之前绑定(标识符应在模板或泛型的作用域中被定义)。
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
但是 `bind` 很少被用到，因为符号绑定的定义作用域是默认的。
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
下面的示例概述了当泛型的实例跨越多个不同模块时可能出现的问题:
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
	# 没有 `bind init` 语句，当 `genericB` 实例化时，来自C模块的init过程是不可用的:
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
在模块 B 作用域中有一个来自模块 C 的 `init` 过程，当实例化 `genericB` 从而使 `genericA` 实例化时， `init` 过程未被考虑在内。解决方案是 `forward`:idx: "传递"，将这些符号通过 `bind` 语句引入 `genericB` 中。
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
模板就是简单形式的宏: 它是简单的替换机制，在Nim的抽象语法树上运行。它运作在编译器的语义分析中。
{==+==}

{==+==}
The syntax to *invoke* a template is the same as calling a procedure.
{==+==}
调用模板的语法和调用过程的语法是相同的。
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
    # 此定义存在于系统模块中
    not (a == b)

  assert(5 != 6) # 编译器将其重写为: assert(not (5 == 6))
  ```
{==+==}

{==+==}
The `!=`, `>`, `>=`, `in`, `notin`, `isnot` operators are in fact
templates:
{==+==}
 `!=`, `>`, `>=`, `in`, `notin`, `isnot` 等操作符实际上都是模板:
{==+==}

{==+==}
| `a > b` is transformed into `b < a`.
| `a in b` is transformed into `contains(b, a)`.
| `notin` and `isnot` have the obvious meanings.
{==+==}
| `a > b` 从 `b < a` 变换而来.
| `a in b` 从 `contains(b, a)` 变换而来.
| `notin` 和 `isnot` 的实现显而易见。
{==+==}

{==+==}
The "types" of templates can be the symbols `untyped`,
`typed` or `typedesc`. These are "meta types", they can only be used in certain
contexts. Regular types can be used too; this implies that `typed` expressions
are expected.
{==+==}
模板中的类型可以使用 `untyped` 、 `typed` 及 `typedesc` 三个符号。这些都是 "元类型" ，它们仅用于特定上下文中。常规类型也可被同样使用；这意味着 `typed` 的表达式可推断。
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
一个 `untyped` 参数意味着符号的查找和类型的解析在表达式传递给模板前不执行。这意味着像以下例子这样不声明标识符的代码可以通过:
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

  declareInt(x) # 有效的
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

  declareInt(x) # 不正确，因为此处x的类型没有被声明，其类型未确定
  ```
{==+==}

{==+==}
A template where every parameter is `untyped` is called an `immediate`:idx:
template. For historical reasons, templates can be explicitly annotated with
an `immediate` pragma and then these templates do not take part in
overloading resolution and the parameters' types are *ignored* by the
compiler. Explicit immediate templates are now deprecated.
{==+==}
如果一个模板的每个参数都是 `untyped` 的，则其被称为 `immediate`:idx: "即时"模板。由于历史原因，模板可以用 `immediate` 编译指示显式的标记，这些模板将不参与重载解析，其参数中的类型将被编译器忽略。显式的声明即时模板现在已经被弃用。
{==+==}

{==+==}
**Note**: For historical reasons, `stmt` was an alias for `typed` and
`expr` was an alias for `untyped`, but they are removed.
{==+==}
**注意**: 由于历史原因， `stmt` 是 `typed` 的别名， `expr` 是 `untyped` 的别名，但这两者都被移除了。
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
通过特殊的 `:` 语法，可以将一个语句块传递给模板的最后一个参数:
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

  withFile(txt, "ttempl3.txt", fmWrite):  # 特殊冒号
    txt.writeLine("line 1")
    txt.writeLine("line 2")
  ```
{==+==}

{==+==}
In the example, the two `writeLine` statements are bound to the `actions`
parameter.
{==+==}
在这个例子中，这两行 `writeLine` 语句被绑定到了模板的 `actions` 参数。
{==+==}

{==+==}
Usually, to pass a block of code to a template, the parameter that accepts
the block needs to be of type `untyped`. Because symbol lookups are then
delayed until template instantiation time:
{==+==}
通常，为了传递一个代码块到模板，接受代码块的参数需要被声明为 `untyped` 类型。因为这样，符号查找会被推迟到模板实例化期间进行:
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
    p()  # 失败，因为p'是一个未被声明的标识符
  ```
{==+==}

{==+==}
The above code fails with the error message that `p` is not declared.
The reason for this is that the `p()` body is type-checked before getting
passed to the `body` parameter and type checking in Nim implies symbol lookups.
The same code works with `untyped` as the passed body is not required to be
type-checked:
{==+==}
以上代码错误信息为 `p` 未被声明。其原因是 `p()` 语句体在传递到 `body` 参数前执行类型检查和符号查找。通过修改模板参数类型为 `untyped` 使得传递语句体时无需类型检查，同样的代码便可以通过:
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
可变参数的untyped
---------------------------------------
{==+==}

{==+==}
In addition to the `untyped` meta-type that prevents type checking, there is
also `varargs[untyped]` so that not even the number of parameters is fixed:
{==+==}
除了 `untyped` 元类型阻止类型检查外， `varargs[untyped]` 中的参数数量也不确定。
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
然而，因为模板不能迭代可变参数，这个功能通常在宏中更有用。
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
模板就是 `hygienic`:idx: "洁净"宏，因此也会开启新的作用域。大部分符号会在宏定义作用域中绑定:
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

  echo genId() # Works as 'lastId' has been bound in 'genId's defining scope
  ```
{==+==}

{==+==}
As in generics, symbol binding can be influenced via `mixin` or `bind`
statements.
{==+==}
像在泛型中一样，模板中的符号绑定可以被 `mixin` 或 `bind` 语句影响。
{==+==}

{==+==}
Identifier construction
-----------------------
{==+==}
标识符构建
--------------------
{==+==}

{==+==}
In templates, identifiers can be constructed with the backticks notation:
{==+==}
在模板中，标识符可以通过反引号标注进行构建:
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
在这个例子中， `name` 参数实例化为 `myint` 类型，所以 \`T name\` 变成了 `Tmyint` 。
{==+==}

{==+==}
Lookup rules for template parameters
------------------------------------
{==+==}
模板参数中的查找规则
----------------------------------------
{==+==}

{==+==}
A parameter `p` in a template is even substituted in the expression `x.p`.
Thus, template arguments can be used as field names and a global symbol can be
shadowed by the same argument name even when fully qualified:
{==+==}
模板中的参数 `p` 总是被替换为 `x.p` 这样的表达式。因此，模板参数可像字段名称一样使用，且一个全局符号会被一个合法的同名参数覆盖:
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
  # 生成: 'levA levA'
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
  # 生成: 'levA levB'
  ```
{==+==}

{==+==}
Hygiene in templates
--------------------
{==+==}
"洁净"模板
------------------------
{==+==}

{==+==}
Per default, templates are `hygienic`:idx:\: Local identifiers declared in a
template cannot be accessed in the instantiation context:
{==+==}
默认情况下，在模板中声明的 `hygienic`:idx: "洁净"局部标识符，不能在实例化上下文中访问:
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
      e: ref exceptn  # e 在这里被隐式地定义
    new(e)
    e.msg = message
    e

  # 这是可以工作的:
  let e = "message"
  raise newException(IoError, e)
  ```
{==+==}

{==+==}
Whether a symbol that is declared in a template is exposed to the instantiation
scope is controlled by the `inject`:idx: and `gensym`:idx: pragmas:
`gensym`'ed symbols are not exposed but `inject`'ed symbols are.
{==+==}
模板中声明的一个符号是否向实例所处作用域中公开取决于 `inject`:idx: 和 `gensym`:idx: 编译指示。被 `gensym` 编译指示标记的符号不会被公开，而 `inject` 编译指示反之。
{==+==}

{==+==}
The default for symbols of entity `type`, `var`, `let` and `const`
is `gensym` and for `proc`, `iterator`, `converter`, `template`,
`macro` is `inject`. However, if the name of the entity is passed as a
template parameter, it is an `inject`'ed symbol:
{==+==}
`type` , `var`, `let` 和 `const` 等实体符号默认是 `gensym` 的， `proc` , `iterator` , `converter`, `template` , `macro` 等默认是 `inject` 的。
而如果一个实体的名称是由模板参数传递的，其将总被标记为 `inject` 的。
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
      var f: File  # 因为 'f' 是一个模板参数，其是被标记为 `inject` 
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
 `inject` 和`gensym` 编译指示是两个类注解；它们在模板定义之外没有语义，不能被抽象出来。
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
为了消除模板中的洁净问题，我们可以在模板中使用 `dirty`:idx: "脏位" 指示 。 `inject` 和 `gensym` 在 `dirty` 模板中没有作用。
{==+==}

{==+==}
`gensym`'ed symbols cannot be used as `field` in the `x.field` syntax.
Nor can they be used in the `ObjectConstruction(field: value)`
and `namedParameterCall(field = value)` syntactic constructs.
{==+==}
被标记为 `gensym` 的符号无法作为 `field` 使用在 `x.field` 语义中。也不能用于 `ObjectConstruction(field: value)` 和 `namedParameterCall(field = value)` 语义构造。
{==+==}

{==+==}
The reason for this is that code like
{==+==}
其原因如以下代码所示:
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
以上代码将按预期执行。
{==+==}

{==+==}
However, this means that the method call syntax is not available for
`gensym`'ed symbols:
{==+==}
而这意味着被 `gensym` 标记的符号无法应用方法调用语义:
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

    echo x.T # 无效的: 应该使用: 'echo T(x)' 。

  tmp(12)
  ```
{==+==}

{==+==}
Limitations of the method call syntax
-------------------------------------
{==+==}
方法调用语义的局限性
----------------------------------------
{==+==}

{==+==}
The expression `x` in `x.f` needs to be semantically checked (that means
symbol lookup and type checking) before it can be decided that it needs to be
rewritten to `f(x)`. Therefore, the dot syntax has some limitations when it
is used to invoke templates/macros:
{==+==}
在像 `x.f` 这样的表达式中的 `x` 在确定执行前需要进行语义检查(这意味着符号查找和类型检查)，这一过程中其将被写作 `f(x)` 的形式。因此，当 `.` 语义用于调用模板和宏时有一些局限性。
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

  # 无法通过编译:
  unknownIdentifier.declareVar
  ```
{==+==}

{==+==}
It is also not possible to use fully qualified identifiers with module
symbol in method call syntax. The order in which the dot operator
binds to symbols prohibits this.
{==+==}
在方法调用语义中，把模块符号用作完全限定的标识符是行不通的。 `.` 操作符绑定符号的次序禁止这样做。
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
  let N2 = sequtils.count(myItems, 3) # 完全被限定, 此处可行
  let N3 = myItems.count(3) # 可行
  let N4 = myItems.sequtils.count(3) # 非法的, `myItems.sequtils` 无法被解析
  ```
{==+==}

{==+==}
This means that when for some reason a procedure needs a
disambiguation through the module name, the call needs to be
written in function call syntax.
{==+==}
这意味着，当由于某种原因，某个过程需要通过模块名称消除歧义时，需要以函数调用语法书写调用。
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
宏是一种在编译时运行的特殊函数。通常，宏的输入是代码传递的抽象语法树(AST)。然后，宏可以对其执行转换，并将转换后的AST的结果返回。这可以被用来添加自定义语言功能，并实现 `domain-specific languages`:idx: "域特定语言"。
{==+==}

{==+==}
Macro invocation is a case where semantic analysis does **not** entirely proceed
top to bottom and left to right. Instead, semantic analysis happens at least
twice:
{==+==}
宏的语义分析并不完全是从上到下和从左到右的。相反，语义分析至少发生两次:
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
* 将宏调用的AST替换为返回的AST。
* 再次对该区域的代码进行语义分析。
* 如果宏返回的AST包含其他宏调用，则此过程将迭代进行。
{==+==}

{==+==}
While macros enable advanced compile-time code transformations, they
cannot change Nim's syntax.
{==+==}
虽然宏支持编译时的代码转换，但它们无法更改 Nim 的语法。
{==+==}

{==+==}
**Style note:** For code readability, it is best to use the least powerful
programming construct that remains expressive. So the "check list" is:
{==+==}
**样式说明:** 为了提高代码的可读性，最好使用简洁而富有表现力的编程结构。建议如下:
{==+==}

{==+==}
(1) Use an ordinary proc/iterator, if possible.
(2) Else: Use a generic proc/iterator, if possible.
(3) Else: Use a template, if possible.
(4) Else: Use a macro.
{==+==}
(1) 首先尽可能使用普通的过程和迭代器。
(2) 其次尽可能使用泛型过程和迭代器。
(3) 再次尽可能使用模板。
(4) 最后才考虑使用宏。
{==+==}

{==+==}
Debug example
-------------
{==+==}
Debug 例子
--------------------
{==+==}

{==+==}
The following example implements a powerful `debug` command that accepts a
variable number of arguments:
{==+==}
以下例子展现了通过接受可变数量参数的高效的 `debug` 命令:
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
  # 要使用Nim语法树，我们需要一个在"宏"模块中定义的API
  import std/macros

  macro debug(args: varargs[untyped]): untyped =
    # `args` 是一个 `NimNode` 值的集合，其中每一个值都包含了一个传递给宏参数的AST
    # 一个宏总是返回一个 `NimNode` 。
    # 一个 `nnkStmtList` 节点适合于本用例
    result = nnkStmtList.newTree()
    # 迭代从宏传递过来的任意参数:
    for n in args:
      # 为语句列表添加调用以书写表达式;
      # `toStrLit` 将AST转换为其字符串表达形式:
      result.add newCall("write", newIdentNode("stdout"), newLit(n.repr))
      # 为语句列表添加调用以添加 ": "
      result.add newCall("write", newIdentNode("stdout"), newLit(": "))
      # 为语句列表添加调用以填写值:
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
这个宏调用后将展开为以下代码:
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
传递给 `varargs` 参数的参数被包装在数组构造函数表达式中。这就是为什么 `debug` 会迭代所有 `args` 的子级的原因。
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
上面的 `debug` 宏依赖于这样一个事实，即 `write` ， `writeLine` 和 `stdout` 在系统模块中已被声明，而且在实例的上下文中总是可见。有一种方法可以使用绑定标识符(即 `symbols`:idx: )以替换未绑定的标识符。内置的 `bindSym` 可用于此目的。
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
      # 我们可以通过 'bindSym' 在作用域中绑定符号:
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
这个宏调用后将展开为以下代码:
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
However, the symbols `write`, `writeLine` and `stdout` are already bound
and are not looked up again. As the example shows, `bindSym` does work with
overloaded symbols implicitly.
{==+==}
但是，符号 `write` ， `writeLine` 和 `stdout` 已经绑定，且不会再次查找。如示例所示， `bindSym` 确实可以隐式地处理重载符号。
{==+==}

{==+==}
Note that the symbol names passed to `bindSym` have to be constant. The
experimental feature `dynamicBindSym` (`experimental manual
<manual_experimental.html#dynamic-arguments-for-bindsym>`_)
allows this value to be computed dynamically.
{==+==}
请注意，传递给 `bindSym` 的符号名称必须是常量。实验功能 `dynamicBindSym` ( `experimental manual <manual_experimental.html#dynamic-arguments-for-bindsym>`_ ) 允许动态计算此值。
{==+==}