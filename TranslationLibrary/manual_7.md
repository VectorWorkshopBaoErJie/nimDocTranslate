{==+==}
Post-statement blocks
---------------------
{==+==}
语句后的代码块
---------------------
{==+==}

{==+==}
Macros can receive `of`, `elif`, `else`, `except`, `finally` and `do`
blocks (including their different forms such as `do` with routine parameters)
as arguments if called in statement form.
{==+==}
当以语句形式调用宏时，宏可以接受 `of`，`elif`，`else`，`except`，`finally` 和 `do` 代码块
（包括诸如带有例程参数的 `do` 等其它形式）。
{==+==}

{==+==}
  ```nim
  macro performWithUndo(task, undo: untyped) = ...

  performWithUndo do:
    # multiple-line block of code
    # to perform the task
  do:
    # code to undo it
  
  let num = 12
  # a single colon may be used if there is no initial block
  match (num mod 3, num mod 5):
  of (0, 0):
    echo "FizzBuzz"
  of (0, _):
    echo "Fizz"
  of (_, 0):
    echo "Buzz"
  else:
    echo num
  ```
{==+==}
  ```nim
  macro performWithUndo(task, undo: untyped) = ...

  performWithUndo do:
    # 若干行用来执行
    # 任务的代码
  do:
    # 用来撤消操作的代码

  let num = 12
  # 如果没有初始代码块，可只使用一个冒号
  match (num mod 3, num mod 5):
  of (0, 0):
    echo "FizzBuzz"
  of (0, _):
    echo "Fizz"
  of (_, 0):
    echo "Buzz"
  else:
    echo num
  ```
{==+==}

{==+==}
For loop macro
--------------
{==+==}
For 循环宏
--------------
{==+==}

{==+==}
A macro that takes as its only input parameter an expression of the special
type `system.ForLoopStmt` can rewrite the entirety of a `for` loop:
{==+==}
当宏只有一个输入参数，而且这个参数的类型是特殊的 `system.ForLoopStmt` 时，
这个宏可以重写整个 `for` 循环：
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/macros

  macro example(loop: ForLoopStmt) =
    result = newTree(nnkForStmt)    # Create a new For loop.
    result.add loop[^3]             # This is "item".
    result.add loop[^2][^1]         # This is "[1, 2, 3]".
    result.add newCall(bindSym"echo", loop[0])

  for item in example([1, 2, 3]): discard
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/macros

  macro example(loop: ForLoopStmt) =
    result = newTree(nnkForStmt)    # 创建一个新的 For 循环。
    result.add loop[^3]             # 这是“item”。
    result.add loop[^2][^1]         # 这是“[1, 2, 3]”。
    result.add newCall(bindSym"echo", loop[0])

  for item in example([1, 2, 3]): discard
  ```
{==+==}

{==+==}
Expands to:
{==+==}
展开成：
{==+==}

{-----}
  ```nim
  for item in items([1, 2, 3]):
    echo item
  ```
{-----}

{==+==}
Another example:
{==+==}
再举一个例子：
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/macros

  macro enumerate(x: ForLoopStmt): untyped =
    expectKind x, nnkForStmt
    # check if the starting count is specified:
    var countStart = if x[^2].len == 2: newLit(0) else: x[^2][1]
    result = newStmtList()
    # we strip off the first for loop variable and use it as an integer counter:
    result.add newVarStmt(x[0], countStart)
    var body = x[^1]
    if body.kind != nnkStmtList:
      body = newTree(nnkStmtList, body)
    body.add newCall(bindSym"inc", x[0])
    var newFor = newTree(nnkForStmt)
    for i in 1..x.len-3:
      newFor.add x[i]
    # transform enumerate(X) to 'X'
    newFor.add x[^2][^1]
    newFor.add body
    result.add newFor
    # now wrap the whole macro in a block to create a new scope
    result = quote do:
      block: `result`

  for a, b in enumerate(items([1, 2, 3])):
    echo a, " ", b

  # without wrapping the macro in a block, we'd need to choose different
  # names for `a` and `b` here to avoid redefinition errors
  for a, b in enumerate(10, [1, 2, 3, 5]):
    echo a, " ", b
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/macros

  macro enumerate(x: ForLoopStmt): untyped =
    expectKind x, nnkForStmt
    # 检查是否指定了计数的起始值
    var countStart = if x[^2].len == 2: newLit(0) else: x[^2][1]
    result = newStmtList()
    # 我们把第一个 for 循环变量修改为整数计数器：
    result.add newVarStmt(x[0], countStart)
    var body = x[^1]
    if body.kind != nnkStmtList:
      body = newTree(nnkStmtList, body)
    body.add newCall(bindSym"inc", x[0])
    var newFor = newTree(nnkForStmt)
    for i in 1..x.len-3:
      newFor.add x[i]
    # 将 enumerate(X) 转换为 'X'
    newFor.add x[^2][^1]
    newFor.add body
    result.add newFor
    # 现在将整个宏包装到代码块里从而创建一个新的作用域
    result = quote do:
      block: `result`

  for a, b in enumerate(items([1, 2, 3])):
    echo a, " ", b

  # 如果不将宏包装到代码块里，我们就需要为这里的 `a` 和 `b` 选择不同的名称
  # 以免犯重复定义的错误。
  for a, b in enumerate(10, [1, 2, 3, 5]):
    echo a, " ", b
  ```
{==+==}

{==+==}
Case statement macros
---------------------
{==+==}
Case 语句宏
---------------------
{==+==}

{==+==}
Macros named `` `case` `` can provide implementations of `case` statements
for certain types. The following is an example of such an implementation
for tuples, leveraging the existing equality operator for tuples
(as provided in `system.==`):
{==+==}
名为 `` `case` `` 的宏能够为特定类型实现 `case` 语句。
下面的例子借助元组已有的相等运算符（由 `system.==` 提供）为它们实现了 `case` 语句。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/macros

  macro `case`(n: tuple): untyped =
    result = newTree(nnkIfStmt)
    let selector = n[0]
    for i in 1 ..< n.len:
      let it = n[i]
      case it.kind
      of nnkElse, nnkElifBranch, nnkElifExpr, nnkElseExpr:
        result.add it
      of nnkOfBranch:
        for j in 0..it.len-2:
          let cond = newCall("==", selector, it[j])
          result.add newTree(nnkElifBranch, cond, it[^1])
      else:
        error "custom 'case' for tuple cannot handle this node", it

  case ("foo", 78)
  of ("foo", 78): echo "yes"
  of ("bar", 88): echo "no"
  else: discard
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/macros

  macro `case`(n: tuple): untyped =
    result = newTree(nnkIfStmt)
    let selector = n[0]
    for i in 1 ..< n.len:
      let it = n[i]
      case it.kind
      of nnkElse, nnkElifBranch, nnkElifExpr, nnkElseExpr:
        result.add it
      of nnkOfBranch:
        for j in 0..it.len-2:
          let cond = newCall("==", selector, it[j])
          result.add newTree(nnkElifBranch, cond, it[^1])
      else:
        error "自定义的元组 'case' 无法处理这个节点", it

  case ("foo", 78)
  of ("foo", 78): echo "yes"
  of ("bar", 88): echo "no"
  else: discard
  ```
{==+==}

{==+==}
`case` macros are subject to overload resolution. The type of the
`case` statement's selector expression is matched against the type
of the first argument of the `case` macro. Then the complete `case`
statement is passed in place of the argument and the macro is evaluated.
{==+==}
重载解析会处理 `case` 宏：`case` 宏的第一个参数的类型用来匹配 `case` 语句选择器表达式的类型。
然后整个 `case` 语句被填入这个参数并对宏求值。
{==+==}

{==+==}
In other words, the macro needs to transform the full `case` statement
but only the statement's selector expression is used to determine which
macro to call.
{==+==}
换句话说，这种宏需要转换整个 `case` 语句，但是决定调用哪个宏的仅是语句的选择器表达式。
{==+==}

{==+==}
Special Types
=============
{==+==}
特殊类型
=============
{==+==}

{==+==}
static[T]
---------
{==+==}
static[T]
---------
{==+==}

{==+==}
As their name suggests, static parameters must be constant expressions:
{==+==}
如名称所示，静态参数必须是常数表达式：
{==+==}

{==+==}
  ```nim
  proc precompiledRegex(pattern: static string): RegEx =
    var res {.global.} = re(pattern)
    return res

  precompiledRegex("/d+") # Replaces the call with a precompiled
                          # regex, stored in a global variable

  precompiledRegex(paramStr(1)) # Error, command-line options
                                # are not constant expressions
  ```
{==+==}
  ```nim
  proc precompiledRegex(pattern: static string): RegEx =
    var res {.global.} = re(pattern)
    return res

  precompiledRegex("/d+") # 这个调用被替换成一个预编译的、
                          # 存储在全局变量里的正则表达式

  precompiledRegex(paramStr(1)) # 错误，命令行选项不是常数表达式
  ```
{==+==}

{==+==}
For the purposes of code generation, all static params are treated as
generic params - the proc will be compiled separately for each unique
supplied value (or combination of values).
{==+==}
为了代码生成，所有的静态参数都被视为泛型参数——每遇到一种新的输入参数（或者参数的组合），函数就会被编译一次。
{==+==}

{==+==}
Static params can also appear in the signatures of generic types:
{==+==}
静态参数也可以出现在泛型的签名里：
{==+==}

{==+==}
  ```nim
  type
    Matrix[M,N: static int; T: Number] = array[0..(M*N - 1), T]
      # Note how `Number` is just a type constraint here, while
      # `static int` requires us to supply an int value

    AffineTransform2D[T] = Matrix[3, 3, T]
    AffineTransform3D[T] = Matrix[4, 4, T]

  var m1: AffineTransform3D[float]  # OK
  var m2: AffineTransform2D[string] # Error, `string` is not a `Number`
  ```
{==+==}
  ```nim
  type
    Matrix[M,N: static int; T: Number] = array[0..(M*N - 1), T]
      # 注意这里的 `Number` 只是一个类型约束，而
      # `static int` 则要求我们提供一个整数值

    AffineTransform2D[T] = Matrix[3, 3, T]
    AffineTransform3D[T] = Matrix[4, 4, T]

  var m1: AffineTransform3D[float]  # OK
  var m2: AffineTransform2D[string] # 错误，`string` 不是一种 `Number`
  ```
{==+==}

{==+==}
Please note that `static T` is just a syntactic convenience for the underlying
generic type `static[T]`. The type param can be omitted to obtain the type
class of all constant expressions. A more specific type class can be created by
instantiating `static` with another type class.
{==+==}
请注意，`static T` 只是泛型类 `static[T]` 的语法糖。
省略类型参数 `T` 可以获得所有常数表达式的类型类。用 `static` 把其它类型类实例化能够得到一种更具体的类型类。
{==+==}

{==+==}
One can force an expression to be evaluated at compile time as a constant
expression by coercing it to a corresponding `static` type:
{==+==}
把表达式强制转换成对应的 `static` 类型可以强制其像常数表达式一样在编译期就进行求值。
{==+==}

{==+==}
  ```nim
  import std/math

  echo static(fac(5)), " ", static[bool](16.isPowerOfTwo)
  ```
{==+==}
  ```nim
  import std/math

  echo static(fac(5)), " ", static[bool](16.isPowerOfTwo)
  ```
{==+==}

{==+==}
The compiler will report any failure to evaluate the expression or a
possible type mismatch error.
{==+==}
编译器会报告表达式求值或者类型匹配中遇到的任何失败。
{==+==}

{==+==}
typedesc[T]
-----------
{==+==}
typedesc[T]
-----------
{==+==}

{==+==}
In many contexts, Nim treats the names of types as regular
values. These values exist only during the compilation phase, but since
all values must have a type, `typedesc` is considered their special type.
{==+==}
在一些上下文中，Nim 把类型名当作常规的值处理。这些值只存在于编译阶段，由于所有的值都必须有类型，
就用 `typedesc` 来表示它们的这种特殊类型。
{==+==}

{==+==}
`typedesc` acts as a generic type. For instance, the type of the symbol
`int` is `typedesc[int]`. Just like with regular generic types, when the
generic param is omitted, `typedesc` denotes the type class of all types.
As a syntactic convenience, one can also use `typedesc` as a modifier.
{==+==}
`typedesc` 像一种泛型类。比如，符号 `int` 的类型是 `typedesc[int]`。就像普通泛型类一样，
省略了泛型参数的 `typedesc` 代表所有类型的类型类。作为一种语法糖，`typedesc` 也可用作修饰符。
{==+==}

{==+==}
Procs featuring `typedesc` params are considered implicitly generic.
They will be instantiated for each unique combination of supplied types,
and within the body of the proc, the name of each param will refer to
the bound concrete type:
{==+==}
带有 `typedesc` 参数的函数被认为是隐式泛型的。这些函数针对每种唯一的输入类型组合都会有一个实例。
在函数体内，每个参数的名字都指代所绑定的具体的类型：
{==+==}

{==+==}
  ```nim
  proc new(T: typedesc): ref T =
    echo "allocating ", T.name
    new(result)

  var n = Node.new
  var tree = new(BinaryTree[int])
  ```
{==+==}
  ```nim
  proc new(T: typedesc): ref T =
    echo "allocating ", T.name
    new(result)

  var n = Node.new
  var tree = new(BinaryTree[int])
  ```
{==+==}

{==+==}
When multiple type params are present, they will bind freely to different
types. To force a bind-once behavior, one can use an explicit generic param:
{==+==}
当存在多个类型参数时，它们可以自由地绑定到不同的类型。使用显式泛型参数可只允许单次绑定：
{==+==}

{==+==}
  ```nim
  proc acceptOnlyTypePairs[T, U](A, B: typedesc[T]; C, D: typedesc[U])
  ```
{==+==}
  ```nim
  proc acceptOnlyTypePairs[T, U](A, B: typedesc[T]; C, D: typedesc[U])
  ```
{==+==}

{==+==}
Once bound, type params can appear in the rest of the proc signature:
{==+==}
一旦绑定，类型参数就可以在函数签名剩余部分里出现：
{==+==}

{-----}
  ```nim  test = "nim c $1"
  template declareVariableWithType(T: typedesc, value: T) =
    var x: T = value

  declareVariableWithType int, 42
  ```
{-----}

{==+==}
Overload resolution can be further influenced by constraining the set
of types that will match the type param. This works in practice by
attaching attributes to types via templates. The constraint can be a
concrete type or a type class.
{==+==}
限制类型参数所能匹配的类型可以进一步影响重载解析。实践中借助模板为类型附加约束就可以实现这个效果。
这里的约束可以是一个具体的类型或者一个类型类。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  template maxval(T: typedesc[int]): int = high(int)
  template maxval(T: typedesc[float]): float = Inf

  var i = int.maxval
  var f = float.maxval
  when false:
    var s = string.maxval # error, maxval is not implemented for string

  template isNumber(t: typedesc[object]): string = "Don't think so."
  template isNumber(t: typedesc[SomeInteger]): string = "Yes!"
  template isNumber(t: typedesc[SomeFloat]): string = "Maybe, could be NaN."

  echo "is int a number? ", isNumber(int)
  echo "is float a number? ", isNumber(float)
  echo "is RootObj a number? ", isNumber(RootObj)
  ```
{==+==}
  ```nim  test = "nim c $1"
  template maxval(T: typedesc[int]): int = high(int)
  template maxval(T: typedesc[float]): float = Inf

  var i = int.maxval
  var f = float.maxval
  when false:
    var s = string.maxval # error, maxval is not implemented for string

  template isNumber(t: typedesc[object]): string = "不这么看。"
  template isNumber(t: typedesc[SomeInteger]): string = "是的！"
  template isNumber(t: typedesc[SomeFloat]): string = "有可能，也可能是 NaN。"

  echo "int 是数字吗？ ", isNumber(int)
  echo "float 是数字吗？ ", isNumber(float)
  echo "RootObj 是数字吗？ ", isNumber(RootObj)
{==+==}

{==+==}
Passing `typedesc` is almost identical, just with the difference that
the macro is not instantiated generically. The type expression is
simply passed as a `NimNode` to the macro, like everything else.
{==+==}
给宏传入 `typedesc` 与传入其它参数几乎是一样的，区别仅在于宏一般不会被实例化。类型表达式简单地作为 `NimNode` 传给宏，就像其它任何东西一样。
{==+==}

{==+==}
  ```nim
  import std/macros

  macro forwardType(arg: typedesc): typedesc =
    # `arg` is of type `NimNode`
    let tmp: NimNode = arg
    result = tmp

  var tmp: forwardType(int)
  ```
{==+==}
  ```nim
  import std/macros

  macro forwardType(arg: typedesc): typedesc =
    # `arg` 的类型是 `NimNode`
    let tmp: NimNode = arg
    result = tmp

  var tmp: forwardType(int)
  ```
{==+==}

{==+==}
typeof operator
---------------
{==+==}
typeof 运算符
---------------
{==+==}

{==+==}
**Note**: `typeof(x)` can for historical reasons also be written as
`type(x)` but `type(x)` is discouraged.
{==+==}
**注意**: 由于历史原因 `typeof(x)` 也可写作 `type(x)`，但是不鼓励这种写法。
{==+==}

{==+==}
One can obtain the type of a given expression by constructing a `typeof`
value from it (in many other languages this is known as the `typeof`:idx:
operator):
{==+==}
取给定的表达式的 `typeof` 值就能得到这个表达式的类型（在其它的很多语言里这被称为 `typeof`:idx: 运算符）：
{==+==}

{==+==}
  ```nim
  var x = 0
  var y: typeof(x) # y has type int
  ```
{==+==}
  ```nim
  var x = 0
  var y: typeof(x) # y 的类型是 int
  ```
{==+==}

{==+==}
If `typeof` is used to determine the result type of a proc/iterator/converter
call `c(X)` (where `X` stands for a possibly empty list of arguments), the
interpretation, where `c` is an iterator, is preferred over the
other interpretations, but this behavior can be changed by
passing `typeOfProc` as the second argument to `typeof`:
{==+==}
如果 `typeof` 被用来判断函数（或迭代子、变换器）调用 `c(X)` 的结果的类型（这里，`X` 代表可能为空的参数列表），
解释代码时，与其它方式相比，优先考虑把 `c` 视作迭代子。通过给 `typeof` 传入第二个参数 `typeOfProc` 可以改变这种行为。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  iterator split(s: string): string = discard
  proc split(s: string): seq[string] = discard

  # since an iterator is the preferred interpretation, `y` has the type `string`:
  assert typeof("a b c".split) is string

  assert typeof("a b c".split, typeOfProc) is seq[string]
  ```
{==+==}
  ```nim  test = "nim c $1"
  iterator split(s: string): string = discard
  proc split(s: string): seq[string] = discard

  # 由于迭代子是优先考虑的解释方式，下面的类型是 `string`：
  assert typeof("a b c".split) is string

  assert typeof("a b c".split, typeOfProc) is seq[string]
  ```
{==+==}

{==+==}
Modules
=======
{==+==}
模块
=======
{==+==}

{==+==}
Nim supports splitting a program into pieces by a module concept.
Each module needs to be in its own file and has its own `namespace`:idx:.
Modules enable `information hiding`:idx: and `separate compilation`:idx:.
A module may gain access to the symbols of another module by the `import`:idx:
statement. `Recursive module dependencies`:idx: are allowed, but are slightly
subtle. Only top-level symbols that are marked with an asterisk (`*`) are
exported. A valid module name can only be a valid Nim identifier (and thus its
filename is ``identifier.nim``).
{==+==}
依靠模块概念 Nim 支持将程序拆分成小块。每个模块单独一个文件，有其独立的 `命名空间`:idx:。
模块为 `信息隐藏`:idx: 和 `独立编译`:idx: 提供了可能。一个模块可以通过 `import`:idx:
语句访问另一个模块里的符号。允许 `递归模块依赖`:idx:，但是略微复杂。只会导出带了星号（`*`）标记的顶层符号。
只有合法的 Nim 标识符才能作为模块名（所以对应的文件名是 ``identifier.nim``）。
{==+==}

{==+==}
The algorithm for compiling modules is:

- Compile the whole module as usual, following import statements recursively.

- If there is a cycle, only import the already parsed symbols (that are
  exported); if an unknown identifier occurs then abort.
{==+==}
编译模块的算法如下：

- 递归地追随导入语句正常编译整个模块。

- 如果发现成环，只导入已经完成语法分析的（且被导出的）符号；如果遇到未知标识符就中止。
{==+==}

{==+==}
This is best illustrated by an example:
{==+==}
最好用一个例子来演示（译者注：代码里的注释描述了编译模块 A 时编译器的行为）：
{==+==}

{==+==}
  ```nim
  # Module A
  type
    T1* = int  # Module A exports the type `T1`
  import B     # the compiler starts parsing B

  proc main() =
    var i = p(3) # works because B has been parsed completely here

  main()
  ```


  ```nim
  # Module B
  import A  # A is not parsed here! Only the already known symbols
            # of A are imported.

  proc p*(x: A.T1): A.T1 =
    # this works because the compiler has already
    # added T1 to A's interface symbol table
    result = x + 1
  ```
{==+==}
  ```nim
  # 模块 A
  type
    T1* = int  # 模块 A 导出了类型 `T1`
  import B     # 编译器开始分析模块 B

  proc main() =
    var i = p(3) # 由于此处模块 B 已经完成语法分析，所以没有问题

  main()
  ```


  ```nim
  # 模块 B
  import A  # 此时模块 A 未完成语法分析，只会导入模块 A 中目前已知的符号

  proc p*(x: A.T1): A.T1 =
    # 编译器已把 T1 添加到 A 的接口符号表，所以这么写没问题
    result = x + 1
  ```
{==+==}

{==+==}
Import statement
----------------
{==+==}
Import 语句
----------------
{==+==}

{==+==}
After the `import` statement, a list of module names can follow or a single
module name followed by an `except` list to prevent some symbols from being
imported:
{==+==}
`import` 关键字的后面可以跟一个由若干模块名组成的列表，或者带有 `except` 列表的单个模块名。
`except` 列表里的符号不会导入。
{==+==}

{==+==}
  ```nim  test = "nim c $1"  status = 1
  import std/strutils except `%`, toUpperAscii

  # doesn't work then:
  echo "$1" % "abc".toUpperAscii
  ```
{==+==}
  ```nim  test = "nim c $1"  status = 1
  import std/strutils except `%`, toUpperAscii

  # 这行代码无法工作：
  echo "$1" % "abc".toUpperAscii
  ```
{==+==}

{==+==}
It is not checked that the `except` list is really exported from the module.
This feature allows us to compile against an older version of the module that
does not export these identifiers.
{==+==}
编译器不会检查 `except` 列表里的符号是否真的已经导出。这一特性允许我们与模块的不同版本一起编译，
即便某个版本可能没有导出列表里的某些符号。
{==+==}

{==+==}
The `import` statement is only allowed at the top level.
{==+==}
`import` 只允许在顶层出现。
{==+==}

{==+==}
Include statement
-----------------
{==+==}
Include 语句
-----------------
{==+==}

{==+==}
The `include` statement does something fundamentally different than
importing a module: it merely includes the contents of a file. The `include`
statement is useful to split up a large module into several files:
{==+==}
`include` 语句所干的事情与导入模块截然不同：它只是把文件的内容包含进来而已。
`include` 语句可用来把一个大模块切分成几个文件：
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
The `include` statement can be used outside the top level, as such:
{==+==}
`include` 语句可以在顶层之外使用，比如：
{==+==}

{==+==}
  ```nim
  # Module A
  echo "Hello World!"
  ```

  ```nim
  # Module B
  proc main() =
    include A

  main() # => Hello World!
  ```
{==+==}
  ```nim
  # 模块 A
  echo "Hello World!"
  ```

  ```nim
  # 模块 B
  proc main() =
    include A

  main() # => Hello World!
  ```
{==+==}

{==+==}
Module names in imports
-----------------------
{==+==}
导入语句里的模块名
------------
{==+==}

{==+==}
A module alias can be introduced via the `as` keyword:
{==+==}
通过 `as` 关键字可为模块引入别名（原模块名就不可用了）：
{==+==}

{==+==}
  ```nim
  import std/strutils as su, std/sequtils as qu

  echo su.format("$1", "lalelu")
  ```
{==+==}
  ```nim
  import std/strutils as su, std/sequtils as qu

  echo su.format("$1", "lalelu")
  ```
{==+==}

{==+==}
The original module name is then not accessible. The notations
`path/to/module` or `"path/to/module"` can be used to refer to a module
in subdirectories:
{==+==}
使用 `path/to/module` 或者 `"path/to/module"` 这些写法来引用子目录里的模块：
{==+==}

{-----}
  ```nim
  import lib/pure/os, "lib/pure/times"
  ```
{-----}

{==+==}
Note that the module name is still `strutils` and not `lib/pure/strutils`,
thus one **cannot** do:
{==+==}
注意模块名仍然是 `strutils` 而不是 `lib/pure/strutils`，所以**不能**这么干：
{==+==}

{-----}
  ```nim
  import lib/pure/strutils
  echo lib/pure/strutils.toUpperAscii("abc")
  ```
{-----}

{==+==}
Likewise, the following does not make sense as the name is `strutils` already:
{==+==}
与之类似，因为模块名已经就是 `strutils` 了，所以下面的代码是不合理的:
{==+==}

{-----}
  ```nim
  import lib/pure/strutils as strutils
  ```
{-----}

{==+==}
Collective imports from a directory
-----------------------------------
{==+==}
从目录里集体导入
--------------
{==+==}

{==+==}
The syntax `import dir / [moduleA, moduleB]` can be used to import multiple modules
from the same directory.
{==+==}
使用语法 `import dir / [moduleA, moduleB]` 能够从同一个路径里导入多个模块。
{==+==}

{==+==}
Path names are syntactically either Nim identifiers or string literals. If the path
name is not a valid Nim identifier it needs to be a string literal:
{==+==}
在语法上，路径名可以是 Nim 标识符或者字符串字面量。如果路径名不是一个合法的 Nim 标识符，
那么就需要写成字符串字面量的形式：
{==+==}

{==+==}
  ```nim
  import "gfx/3d/somemodule" # in quotes because '3d' is not a valid Nim identifier
  ```
{==+==}
  ```nim
  import "gfx/3d/somemodule" # '3d' 不是合法的 Nim 标识符，要用引号
  ```
{==+==}

{==+==}
Pseudo import/include paths
---------------------------
{==+==}
用于 import/include 的伪路径
---------------------------
{==+==}

{==+==}
A directory can also be a so-called "pseudo directory". They can be used to
avoid ambiguity when there are multiple modules with the same path.
{==+==}
路径也可以是所谓的“伪路径”。它们用来解决存在同名模块时的多义问题。
{==+==}

{==+==}
There are two pseudo directories:

1. `std`: The `std` pseudo directory is the abstract location of Nim's standard
   library. For example, the syntax `import std / strutils` is used to unambiguously
   refer to the standard library's `strutils` module.
2. `pkg`: The `pkg` pseudo directory is used to unambiguously refer to a Nimble
   package. However, for technical details that lie outside the scope of this document,
   its semantics are: *Use the search path to look for module name but ignore the standard
   library locations*. In other words, it is the opposite of `std`.
{==+==}
有两个伪路径：

1. `std`：`std` 这个伪路径代表了 Nim 标准库的抽象位置。例如，`import std / strutils` 可用来明确地导入标准库里的 `stutils` 模块。
2. `pkg`：`pkg` 这个伪路径用来明确地指向 Nim 软件包。不过，其技术细节不在本文档的范围以内。
    它的语义是：*使用搜索路径去查找模块名，但是忽略标准库所在位置*。换句话说，它是 `std` 的反面。
{==+==}

{==+==}
It is recommended and preferred but not currently enforced that all stdlib module imports include the std/ "pseudo directory" as part of the import name.
{==+==}
对于所有导入标准库（stdlib）里的模块的情况，建议、优选（但是目前并不强制）把 std/ 这个伪路径写到导入语句里。
{==+==}

{==+==}
From import statement
---------------------
{==+==}
From import 语句
---------------------
{==+==}

{==+==}
After the `from` statement, a module name followed by
an `import` to list the symbols one likes to use without explicit
full qualification:
{==+==}
`from` 关键字后面是一个模块名，然后是 `import` 关键字，最后是符号列表。这个列表里的符号开发者不需要显式地全限定就能直接使用。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  from std/strutils import `%`

  echo "$1" % "abc"
  # always possible: full qualification:
  echo strutils.replace("abc", "a", "z")
  ```
{==+==}
  ```nim  test = "nim c $1"
  from std/strutils import `%`

  echo "$1" % "abc"
  # 总是允许全限定形式：
  echo strutils.replace("abc", "a", "z")
  ```
{==+==}

{==+==}
It's also possible to use `from module import nil` if one wants to import
the module but wants to enforce fully qualified access to every symbol
in `module`.
{==+==}
如果要导入模块 `module`，又要强制以全限定的形式访问它的每一个符号，那么可以 `from module import nil`。
{==+==}

{==+==}
Export statement
----------------
{==+==}
Export 语句
----------
{==+==}

{==+==}
An `export` statement can be used for symbol forwarding so that client
modules don't need to import a module's dependencies:
{==+==}
`export` 语句用来转发符号，这样客户模块就不需要再导入本模块的依赖了：
{==+==}

{==+==}
  ```nim
  # module B
  type MyObject* = object
  ```

  ```nim
  # module A
  import B
  export B.MyObject

  proc `$`*(x: MyObject): string = "my object"
  ```


  ```nim
  # module C
  import A

  # B.MyObject has been imported implicitly here:
  var x: MyObject
  echo $x
  ```
{==+==}
  ```nim
  # 模块 B
  type MyObject* = object
  ```

  ```nim
  # 模块 A
  import B
  export B.MyObject

  proc `$`*(x: MyObject): string = "my object"
  ```


  ```nim
  # 模块 C
  import A

  # 这里 B.MyObject 被隐式导入：
  var x: MyObject
  echo $x
  ```
{==+==}

{==+==}
When the exported symbol is another module, all of its definitions will
be forwarded. One can use an `except` list to exclude some of the symbols.
{==+==}
当被导出的符号是另一个模块时，这个模块里的所有定义都会被导出。通过使用 `except` 列表可以将其中的某些符号排除。
{==+==}

{==+==}
Notice that when exporting, one needs to specify only the module name:
{==+==}
注意当导出时，只需要指定模块名：
{==+==}

{==+==}
  ```nim
  import foo/bar/baz
  export baz
  ```
{==+==}
  ```nim
  import foo/bar/baz
  export baz
  ```
{==+==}

{==+==}
Scope rules
-----------
Identifiers are valid from the point of their declaration until the end of
the block in which the declaration occurred. The range where the identifier
is known is the scope of the identifier. The exact scope of an
identifier depends on the way it was declared.
{==+==}
作用域规则
-------
标识符从它的声明处开始生效，并持续到到其声明所在的那个块结束。标识符为已知状态的那段代码范围称为标识符的作用域。标识符的准确的作用域与其声明方式有关。
{==+==}

{==+==}
### Block scope
{==+==}
### 块（Block）作用域
{==+==}

{==+==}
The *scope* of a variable declared in the declaration part of a block
is valid from the point of declaration until the end of the block. If a
block contains a second block, in which the identifier is redeclared,
then inside this block, the second declaration will be valid. Upon
leaving the inner block, the first declaration is valid again. An
identifier cannot be redefined in the same block, except if valid for
procedure or iterator overloading purposes.
{==+==}
对于在块（block）的声明部分里声明的变量，其作用域从其声明处开始，直到块的末尾结束。
如果一个块里包含另一个块，在这个块里又再次声明了这个标识符，那么，在这个内部的块里，第二个声明有效。
当离开这个内部的块时，第一个声明又一次有效。在同一个块里，同一个标识符不能被重复定义，
除非是为了过程或者迭代子重载之目的。
{==+==}

{==+==}
### Tuple or object scope
{==+==}
### 元组或对象作用域
{==+==}

{==+==}
The field identifiers inside a tuple or object definition are valid in the
following places:

* To the end of the tuple/object definition.
* Field designators of a variable of the given tuple/object type.
* In all descendant types of the object type.
{==+==}
在元组或者对象定义里的字段标识符在下列地方有效：

* 直到元组/对象的定义结束
* 所给的元组/对象类型的变量的字段指示器（designators）
* 对象类型的所有派生类型内
{==+==}

{==+==}
### Module scope
{==+==}
### 模块作用域
{==+==}

{==+==}
All identifiers of a module are valid from the point of declaration until
the end of the module. Identifiers from indirectly dependent modules are *not*
available. The `system`:idx: module is automatically imported in every module.
{==+==}
模块里的所有标识符从声明开始直到模块结束一直有效。间接依赖的模块里的标识符在本模块里*不可用*。
每个模块都自动导入了系统模块（`system`:idx:）。
{==+==}

{==+==}
If a module imports an identifier by two different modules, each occurrence of
the identifier has to be qualified unless it is an overloaded procedure or
iterator in which case the overloading resolution takes place:
{==+==}
如果一个模块从两个不同模块里导入了相同的标识符，那么每次使用它时都必须加上限定，除非它是一个重载的过程或者迭代子，
这时重载解析会进来解决多义性：
{==+==}

{==+==}
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
  write(stdout, A.x) # no error: qualifier used

  var x = 4
  write(stdout, x) # not ambiguous: uses the module C's x
  ```
{==+==}
  ```nim
  # 模块 A
  var x*: string
  ```

  ```nim
  # 模块 B
  var x*: int
  ```

  ```nim
  # 模块 C
  import A, B
  write(stdout, x) # 错误：x 指代不明
  write(stdout, A.x) # 正确：加上限定后 x 的指代明确

  var x = 4
  write(stdout, x) # 没有多义性：这是模块 C 自己的 x
  ```
{==+==}

{==+==}
Packages
--------
{==+==}
包
---
{==+==}

{==+==}
A collection of modules in a file tree with an ``identifier.nimble`` file in the
root of the tree is called a Nimble package. A valid package name can only be a
valid Nim identifier and thus its filename is ``identifier.nimble`` where
``identifier`` is the desired package name. A module without a ``.nimble`` file
is assigned the package identifier: `unknown`.
{==+==}
对于根目录里有一个 ``identifier.nimble`` 文件的目录树，里面的那些模块被合称为一个 Nimble 包。
``identifier.nimble`` 这个文件名里的 ``identifier`` 就是包的名称，必须是合法的 Nim 标识符。
对于没有与之关联的 ``.nimble`` 文件的模块，给它这么一个包名：`unknown`。
{==+==}

{==+==}
The distinction between packages allows diagnostic compiler messages to be
scoped to the current project's package vs foreign packages.
{==+==}
包与包之间有了区分，就可以限制编译器输出的诊断信息的范围：仅限当前项目里的包，或者仅限项目外部的包。
{==+==}

{==+==}
Compiler Messages
=================
{==+==}
编译器消息
========
{==+==}

{==+==}
The Nim compiler emits different kinds of messages: `hint`:idx:,
`warning`:idx:, and `error`:idx: messages. An *error* message is emitted if
the compiler encounters any static error.
{==+==}
Nim 编译器会输出不同类型的消息：提示（`hint`:idx:），警告（`warning`:idx:）和错误（`error`:idx:）。
编译器遇到静态错误时会输出*错误*消息。
{==+==}

{==+==}
Pragmas
=======
{==+==}
编译指示
================
{==+==}

{==+==}
Pragmas are Nim's method to give the compiler additional information /
commands without introducing a massive number of new keywords. Pragmas are
processed on the fly during semantic checking. Pragmas are enclosed in the
special `{.` and `.}` curly brackets. Pragmas are also often used as a
first implementation to play with a language feature before a nicer syntax
to access the feature becomes available.
{==+==}
编译指示（pragmas）是 Nim 语言在不引入大量新关键字的前提下给编译器提供额外信息、命令的方法。
编译指示在语法检查时随即就处理了。编译指示由一对特殊的花括号 `{.` 和 `.}` 包围。
当语言有了新特性但是还没设计出与之匹配的漂亮语法时，常常通过编译指示提供尝鲜体验。
{==+==}

{==+==}
deprecated pragma
-----------------
{==+==}
deprecated 编译指示
{==+==}

{==+==}
The deprecated pragma is used to mark a symbol as deprecated:
{==+==}
deprecated 编译指示用来标记某符号已废弃：
{==+==}

{-----}
  ```nim
  proc p() {.deprecated.}
  var x {.deprecated.}: char
  ```
{-----}


{==+==}
This pragma can also take in an optional warning string to relay to developers.

  ```nim
  proc thing(x: bool) {.deprecated: "use thong instead".}
  ```
{==+==}
可选地，这个编译指示还能接受一个包含警告信息的字符串，编译器会把它呈现给开发者。

  ```nim
  proc thing(x: bool) {.deprecated: "请改用 thong".}
  ```
{==+==}

{==+==}
compileTime pragma
------------------
{==+==}
compileTime 编译指示
------------------
{==+==}

{==+==}
The `compileTime` pragma is used to mark a proc or variable to be used only
during compile-time execution. No code will be generated for it. Compile-time
procs are useful as helpers for macros. Since version 0.12.0 of the language, a
proc that uses `system.NimNode` within its parameter types is implicitly
declared `compileTime`:
{==+==}
`compileTime` 编译指示用来指示一个过程或者变量只能用于编译期的执行。不会为它生成代码。
编译期过程可作为宏的辅助。从语言的 0.12.0 版本开始，包含 `system.NimNode`
类型的参数的过程隐式地声明为 `compileTime`：
{==+==}

{==+==}
  ```nim
  proc astHelper(n: NimNode): NimNode =
    result = n
  ```
{==+==}
  ```nim
  proc astHelper(n: NimNode): NimNode =
    result = n
  ```
{==+==}

{==+==}
Is the same as:
{==+==}
与下面的代码一致：
{==+==}

{==+==}
  ```nim
  proc astHelper(n: NimNode): NimNode {.compileTime.} =
    result = n
  ```
{==+==}
  ```nim
  proc astHelper(n: NimNode): NimNode {.compileTime.} =
    result = n
  ```
{==+==}

{==+==}
`compileTime` variables are available at runtime too. This simplifies certain
idioms where variables are filled at compile-time (for example, lookup tables)
but accessed at runtime:
{==+==}
加了 `compileTime` 编译指示的变量在运行时也存在。很多时候希望某些变量（例如查找表）在编译时填充数据、
在运行时访问——这轻而易举：
{==+==}

{==+==}
  ```nim  test = "nim c -r $1"
  import std/macros

  var nameToProc {.compileTime.}: seq[(string, proc (): string {.nimcall.})]

  macro registerProc(p: untyped): untyped =
    result = newTree(nnkStmtList, p)

    let procName = p[0]
    let procNameAsStr = $p[0]
    result.add quote do:
      nameToProc.add((`procNameAsStr`, `procName`))

  proc foo: string {.registerProc.} = "foo"
  proc bar: string {.registerProc.} = "bar"
  proc baz: string {.registerProc.} = "baz"

  doAssert nameToProc[2][1]() == "baz"
  ```
{==+==}
  ```nim  test = "nim c -r $1"
  import std/macros

  var nameToProc {.compileTime.}: seq[(string, proc (): string {.nimcall.})]

  macro registerProc(p: untyped): untyped =
    result = newTree(nnkStmtList, p)

    let procName = p[0]
    let procNameAsStr = $p[0]
    result.add quote do:
      nameToProc.add((`procNameAsStr`, `procName`))

  proc foo: string {.registerProc.} = "foo"
  proc bar: string {.registerProc.} = "bar"
  proc baz: string {.registerProc.} = "baz"

  doAssert nameToProc[2][1]() == "baz"
  ```
{==+==}

{==+==}
noreturn pragma
---------------
The `noreturn` pragma is used to mark a proc that never returns.
{==+==}
noreturn 编译指示
----------------
`noreturn` 编译指示用来指示过程永远不会返回。
{==+==}

{==+==}
acyclic pragma
--------------
The `acyclic` pragma can be used for object types to mark them as acyclic
even though they seem to be cyclic. This is an **optimization** for the garbage
collector to not consider objects of this type as part of a cycle:
{==+==}
acyclic 编译指示
---------------
`acyclic` 编译指示用来指示对象类型是无环的，即使看起来像是有环的。
这个信息是一种**优化**，有了这个信息垃圾回收器不再需要考虑这个类的对象构成环的情况：
{==+==}

{==+==}
  ```nim
  type
    Node = ref NodeObj
    NodeObj {.acyclic.} = object
      left, right: Node
      data: string
  ```
{==+==}
  ```nim
  type
    Node = ref NodeObj
    NodeObj {.acyclic.} = object
      left, right: Node
      data: string
  ```
{==+==}

{==+==}
Or if we directly use a ref object:
{==+==}
我们也可以直接使用引用对象类型：
{==+==}

{==+==}
  ```nim
  type
    Node {.acyclic.} = ref object
      left, right: Node
      data: string
  ```
{==+==}
  ```nim
  type
    Node {.acyclic.} = ref object
      left, right: Node
      data: string
  ```
{==+==}

{==+==}
In the example, a tree structure is declared with the `Node` type. Note that
the type definition is recursive and the GC has to assume that objects of
this type may form a cyclic graph. The `acyclic` pragma passes the
information that this cannot happen to the GC. If the programmer uses the
`acyclic` pragma for data types that are in reality cyclic, this may result
in memory leaks, but memory safety is preserved.
{==+==}
这个例子里通过 `Node` 类型声明了一个树形结构。注意到这个类型的定义是递归的，GC 不得不考虑各对象可能构成一个有环图的情况。
`acyclic` 编译指示告诉 GC 这不可能发生。如果程序员把 `acyclic` 编译指示赋予了实际上有环的数据类型，那么将导致内存泄露，但是不会破坏内存安全。
{==+==}

{==+==}
final pragma
------------
{==+==}
final 编译指示
-------------
{==+==}

{==+==}
The `final` pragma can be used for an object type to specify that it
cannot be inherited from. Note that inheritance is only available for
objects that inherit from an existing object (via the `object of SuperType`
syntax) or that have been marked as `inheritable`.
{==+==}
`final` 编译指示用来指示一个对象类型不能被继承。注意只能继承那些继承自已有对象类型的类型（通过 `object of 超类型` 语法）
或者标注了 `inheritable` 的类型。
{==+==}

{==+==}
shallow pragma
--------------
{==+==}
shallow 编译指示
--------------
{==+==}

{==+==}
The `shallow` pragma affects the semantics of a type: The compiler is
allowed to make a shallow copy. This can cause serious semantic issues and
break memory safety! However, it can speed up assignments considerably,
because the semantics of Nim require deep copying of sequences and strings.
This can be expensive, especially if sequences are used to build a tree
structure:
{==+==}
`shallow` 编译指示影响类型的语义：允许编译器进行浅拷贝。这会导致严重的语义问题，破坏内存安全！
但是，它也可以大幅度提高赋值的速度，因为 Nim 的语义要求对序列和字符串做深拷贝。深拷贝代价高昂，
尤其是用序列来构造树形结构的时候：
{==+==}

{==+==}
  ```nim
  type
    NodeKind = enum nkLeaf, nkInner
    Node {.shallow.} = object
      case kind: NodeKind
      of nkLeaf:
        strVal: string
      of nkInner:
        children: seq[Node]
  ```
{==+==}
  ```nim
  type
    NodeKind = enum nkLeaf, nkInner
    Node {.shallow.} = object
      case kind: NodeKind
      of nkLeaf:
        strVal: string
      of nkInner:
        children: seq[Node]
  ```
{==+==}

{==+==}
pure pragma
-----------
{==+==}
pure 编译指示
------------
{==+==}

{==+==}
An object type can be marked with the `pure` pragma so that its type field
which is used for runtime type identification is omitted. This used to be
necessary for binary compatibility with other compiled languages.
{==+==}
给对象类型加上 `pure` 编译指示后，编译器就不再为它生成用于运行时类型识别的类型字段。
这曾是为了实现与其它编译型语言的二进制兼容。
{==+==}

{==+==}
An enum type can be marked as `pure`. Then access of its fields always
requires full qualification.
{==+==}
枚举类型可以标记为 `pure`。这样一来，访问其成员时总是需要使用全限定。
{==+==}

{==+==}
asmNoStackFrame pragma
----------------------
{==+==}
asmNoStackFrame 编译指示
----------------------
{==+==}

{==+==}
A proc can be marked with the `asmNoStackFrame` pragma to tell the compiler
it should not generate a stack frame for the proc. There are also no exit
statements like `return result;` generated and the generated C function is
declared as `__declspec(naked)`:c: or `__attribute__((naked))`:c: (depending on
the used C compiler).
{==+==}
可以给过程加上 `asmNoStackFrame` 编译指示以告诉编译器不要为它生成栈帧。编译器同样也不会生成类似
`return result;` 的退出语句。根据所用的 C 编译器，生成的 C 函数会被声明成 `__declspec(naked)`:c:
或者 `__attribute__((naked))`:c:。
{==+==}

{==+==}
**Note**: This pragma should only be used by procs which consist solely of
assembler statements.
{==+==}
**注意**：这个编译指示应该只用于完全由汇编语句构成的过程。
{==+==}

{==+==}
error pragma
------------
{==+==}
error 编译指示
-------------
{==+==}

{==+==}
The `error` pragma is used to make the compiler output an error message
with the given content. The compilation does not necessarily abort after an error
though.
{==+==}
`error` 编译指示可使编译器输出一条包含指定内容的错误消息。但是输出了这个错误消息后，编译过程并不一定会中止。
{==+==}

{==+==}
The `error` pragma can also be used to
annotate a symbol (like an iterator or proc). The *usage* of the symbol then
triggers a static error. This is especially useful to rule out that some
operation is valid due to overloading and type conversions:
{==+==}
可以给符号（比如迭代子或者过程）附加 `error` 编译指示。*使用*这个符号将触发静态错误。
当需要排除某些由于重载和类型转换导致的合法操作时，这个 `error` 就派上用场了：
{==+==}

{==+==}
  ```nim
  ## check that underlying int values are compared and not the pointers:
  proc `==`(x, y: ptr int): bool {.error.}
  ```
{==+==}
  ```nim
  ## 检查所比较的是整形数值，而不是指针：
  proc `==`(x, y: ptr int): bool {.error.}
  ```
{==+==}

{==+==}
fatal pragma
------------
{==+==}
fatal 编译指示
-------------
{==+==}

{==+==}
The `fatal` pragma is used to make the compiler output an error message
with the given content. In contrast to the `error` pragma, the compilation
is guaranteed to be aborted by this pragma. Example:
{==+==}
`fatal` 编译指示可使编译器输出一条包含指定内容的错误消息。与 `error` 编译指示不同，
输出了这个错误消息后，编译过程必然中止。例子：
{==+==}

{==+==}
  ```nim
  when not defined(objc):
    {.fatal: "Compile this program with the objc command!".}
  ```
{==+==}
  ```nim
  when not defined(objc):
    {.fatal: "编译这个程序时带上 objc 命令！".}
  ```
{==+==}

{==+==}
warning pragma
--------------
{==+==}
warning 编译指示
---------------
{==+==}

{==+==}
The `warning` pragma is used to make the compiler output a warning message
with the given content. Compilation continues after the warning.
{==+==}
`warning` 编译指示可使编译器输出一条包含指定内容的警告消息，然后继续编译。
{==+==}

{==+==}
hint pragma
-----------
{==+==}
hint 编译指示
------------
{==+==}

{==+==}
The `hint` pragma is used to make the compiler output a hint message with
the given content. Compilation continues after the hint.
{==+==}
`hint` 编译指示可使编译器输出一条包含指定内容的提示消息，然后继续编译。
{==+==}

{==+==}
line pragma
-----------
{==+==}
line 编译指示
------------
{==+==}

{==+==}
The `line` pragma can be used to affect line information of the annotated
statement, as seen in stack backtraces:
{==+==}
`line` 编译指示可以修改所在语句的代码行信息。这个行信息可在栈回溯信息里看到：
{==+==}

{==+==}
  ```nim
  template myassert*(cond: untyped, msg = "") =
    if not cond:
      # change run-time line information of the 'raise' statement:
      {.line: instantiationInfo().}:
        raise newException(AssertionDefect, msg)
  ```
{==+==}
  ```nim
  template myassert*(cond: untyped, msg = "") =
    if not cond:
      # 修改 `raise` 语句运行时的行信息
      {.line: instantiationInfo().}:
        raise newException(AssertionDefect, msg)
  ```
{==+==}

{==+==}
If the `line` pragma is used with a parameter, the parameter needs to be a
`tuple[filename: string, line: int]`. If it is used without a parameter,
`system.instantiationInfo()` is used.
{==+==}
如果 `line` 带了参数，那么参数需要是 `tuple[filename: string, line: int]` 的形式；
如果不带参数，那么相当于以 `system.instantiationInfo()` 为参数。
{==+==}

{==+==}
linearScanEnd pragma
--------------------
{==+==}
linearScanEnd 编译指示
---------------------
{==+==}

{==+==}
The `linearScanEnd` pragma can be used to tell the compiler how to
compile a Nim `case`:idx: statement. Syntactically it has to be used as a
statement:
{==+==}
`linearScanEnd` 编译指示用来告诉编译器如何处理 Nim `case`:idx: 语句。这个编译指示在语法上必须是一个语句：
{==+==}

{==+==}
  ```nim
  case myInt
  of 0:
    echo "most common case"
  of 1:
    {.linearScanEnd.}
    echo "second most common case"
  of 2: echo "unlikely: use branch table"
  else: echo "unlikely too: use branch table for ", myInt
  ```
{==+==}
  ```nim
  case myInt
  of 0:
    echo "最常见的情况"
  of 1:
    {.linearScanEnd.}
    echo "第二常见的情况"
  of 2: echo "不常见：使用分支表"
  else: echo "也不常见：使用了分支表，数值为 ", myInt
  ```
{==+==}

{==+==}
In the example, the case branches `0` and `1` are much more common than
the other cases. Therefore, the generated assembler code should test for these
values first so that the CPU's branch predictor has a good chance to succeed
(avoiding an expensive CPU pipeline stall). The other cases might be put into a
jump table for O(1) overhead but at the cost of a (very likely) pipeline
stall.
{==+==}
在这个例子里，`0` 和 `1` 分支比其它情况更加常见。所以，生成的汇编代码应该首先测试这两个值以使 CPU
的分支预测器有更大的几率预测成功（避免出现开销高昂的 CPU 流水线停滞）。其它的情况则可以放到跳转表里，
其开销为 O(1)，但代价是一次（很可能出现的）流水线停滞。
{==+==}

{==+==}
The `linearScanEnd` pragma should be put into the last branch that should be
tested against via linear scanning. If put into the last branch of the
whole `case` statement, the whole `case` statement uses linear scanning.
{==+==}
`linearScanEnd` 编译指示应该被到最后一个需要进行线性扫描的分支里。如果放到整个 `case` 语句最后那个分支里，
那么整个 `case` 语句都会使用线性扫描。
{==+==}

{==+==}
computedGoto pragma
-------------------
{==+==}
computedGoto 编译指示
-------------------
{==+==}

{==+==}
The `computedGoto` pragma can be used to tell the compiler how to
compile a Nim `case`:idx: in a `while true` statement.
Syntactically it has to be used as a statement inside the loop:
{==+==}
`computedGoto` 编译指令告诉编译器如何编译嵌在 `while true` 语句里的 Nim `case`:idx: 语句。
这个编译指示在语法上必须是这个循环体里的一条语句：
{==+==}

{==+==}
  ```nim
  type
    MyEnum = enum
      enumA, enumB, enumC, enumD, enumE

  proc vm() =
    var instructions: array[0..100, MyEnum]
    instructions[2] = enumC
    instructions[3] = enumD
    instructions[4] = enumA
    instructions[5] = enumD
    instructions[6] = enumC
    instructions[7] = enumA
    instructions[8] = enumB

    instructions[12] = enumE
    var pc = 0
    while true:
      {.computedGoto.}
      let instr = instructions[pc]
      case instr
      of enumA:
        echo "yeah A"
      of enumC, enumD:
        echo "yeah CD"
      of enumB:
        echo "yeah B"
      of enumE:
        break
      inc(pc)

  vm()
  ```
{==+==}
  ```nim
  type
    MyEnum = enum
      enumA, enumB, enumC, enumD, enumE

  proc vm() =
    var instructions: array[0..100, MyEnum]
    instructions[2] = enumC
    instructions[3] = enumD
    instructions[4] = enumA
    instructions[5] = enumD
    instructions[6] = enumC
    instructions[7] = enumA
    instructions[8] = enumB

    instructions[12] = enumE
    var pc = 0
    while true:
      {.computedGoto.}
      let instr = instructions[pc]
      case instr
      of enumA:
        echo "哦，A"
      of enumC, enumD:
        echo "啊，CD"
      of enumB:
        echo "呀，B"
      of enumE:
        break
      inc(pc)

  vm()
  ```
{==+==}

{==+==}
As the example shows, `computedGoto` is mostly useful for interpreters. If
the underlying backend (C compiler) does not support the computed goto
extension the pragma is simply ignored.
{==+==}
如例子所示，`computedGoto` 对于实现解释器非常有用。如果所使用的后端（C
编译器）不支持计算跳转这个扩展功能，那么该编译指示被直接忽略。
{==+==}

{==+==}
immediate pragma
----------------
{==+==}
immediate 编译指示
----------------
{==+==}

{==+==}
The immediate pragma is obsolete. See `Typed vs untyped parameters
<#templates-typed-vs-untyped-parameters>`_.
{==+==}
`immediate` 编译指示已经淘汰。参考 `有类型 vs 无类型参数 <#templates-typed-vs-untyped-parameters>`_ .
{==+==}

{==+==}
compilation option pragmas
--------------------------
{==+==}
与编译选项相关的编译指示
--------------------------
{==+==}

{==+==}
The listed pragmas here can be used to override the code generation options
for a proc/method/converter.
{==+==}
下面列出的编译指示用来改写过程、方法、转换器的代码生成选项。
{==+==}

{==+==}
The implementation currently provides the following possible options (various
others may be added later).
{==+==}
当前，编译器提供以下可能的选项（以后可能会增加）。
{==+==}

{==+==}
===============  ===============  ============================================
pragma           allowed values   description
===============  ===============  ============================================
checks           on|off           Turns the code generation for all runtime
                                  checks on or off.
boundChecks      on|off           Turns the code generation for array bound
                                  checks on or off.
overflowChecks   on|off           Turns the code generation for over- or
                                  underflow checks on or off.
nilChecks        on|off           Turns the code generation for nil pointer
                                  checks on or off.
assertions       on|off           Turns the code generation for assertions
                                  on or off.
warnings         on|off           Turns the warning messages of the compiler
                                  on or off.
hints            on|off           Turns the hint messages of the compiler
                                  on or off.
optimization     none|speed|size  Optimize the code for speed or size, or
                                  disable optimization.
patterns         on|off           Turns the term rewriting templates/macros
                                  on or off.
callconv         cdecl|...        Specifies the default calling convention for
                                  all procedures (and procedure types) that
                                  follow.
===============  ===============  ============================================
{==+==}
===============  ===============  ============================================
编译指示           允许的值          描述
===============  ===============  ============================================
checks           on|off           是否为所有的运行时检查生成代码。
boundChecks      on|off           是否为数组边界检查生成代码。
overflowChecks   on|off           是否为上、下溢出检查生成代码。
nilChecks        on|off           是否为空指针检查生成代码。
assertions       on|off           是否为断言生成代码。
warnings         on|off           打开或关闭编译器的警告消息。
hints            on|off           打开或关闭编译器的提示消息。
optimization     none|speed|size  设置优化目标为执行速度（speed）、文件大小（size），
                                  或者关闭优化（none）
patterns         on|off           打开或关闭项重写模块、宏。
callconv         cdecl|...        为所有过程（及过程类型）设置默认的调用规范。
===============  ===============  ============================================
{==+==}

{==+==}
Example:

  ```nim
  {.checks: off, optimization: speed.}
  # compile without runtime checks and optimize for speed
  ```
{==+==}
例如：

  ```nim
  {.checks: off, optimization: speed.}
  # 关闭运行时检查，优化执行速度
  ```
{==+==}

{==+==}
push and pop pragmas
--------------------
{==+==}
push 和 pop 编译指示
--------------------
{==+==}

{==+==}
The `push/pop`:idx: pragmas are very similar to the option directive,
but are used to override the settings temporarily. Example:
{==+==}
`push/pop`:idx: 编译指示也是用来控制编译选项的，不过是用于临时性地修改设置然后还原。例子：
{==+==}

{==+==}
  ```nim
  {.push checks: off.}
  # compile this section without runtime checks as it is
  # speed critical
  # ... some code ...
  {.pop.} # restore old settings
  ```
{==+==}
  ```nim
  {.push checks: off.}
  # 由于这一段代码对于执行速度非常关键，所以不做运行时检查
  # ... 一些代码 ...
  {.pop.} # 恢复原来旧的编译设置
  ```
{==+==}

{==+==}
`push/pop`:idx: can switch on/off some standard library pragmas, example:
{==+==}
`push/pop`:idx: 能够开关一些来自标准库的编译指示，例如：
{==+==}

{==+==}
  ```nim
  {.push inline.}
  proc thisIsInlined(): int = 42
  func willBeInlined(): float = 42.0
  {.pop.}
  proc notInlined(): int = 9

  {.push discardable, boundChecks: off, compileTime, noSideEffect, experimental.}
  template example(): string = "https://nim-lang.org"
  {.pop.}

  {.push deprecated, hint[LineTooLong]: off, used, stackTrace: off.}
  proc sample(): bool = true
  {.pop.}
  ```
{==+==}
  ```nim
  {.push inline.}
  proc thisIsInlined(): int = 42
  func willBeInlined(): float = 42.0
  {.pop.}
  proc notInlined(): int = 9

  {.push discardable, boundChecks: off, compileTime, noSideEffect, experimental.}
  template example(): string = "https://nim-lang.org"
  {.pop.}

  {.push deprecated, hint[LineTooLong]: off, used, stackTrace: off.}
  proc sample(): bool = true
  {.pop.}
  ```
{==+==}

{==+==}
For third party pragmas, it depends on its implementation but uses the same syntax.
{==+==}
对于来自第三方的编译指示，`push/pop`:idx: 是否有效与第三方的实现有关，但是无论如何使用的语法是相同的。
{==+==}

{==+==}
register pragma
---------------
The `register` pragma is for variables only. It declares the variable as
`register`, giving the compiler a hint that the variable should be placed
in a hardware register for faster access. C compilers usually ignore this
though and for good reasons: Often they do a better job without it anyway.

However, in highly specific cases (a dispatch loop of a bytecode interpreter
for example) it may provide benefits.
{==+==}
register 编译指示
----------------
`register` 编译指示仅用于变量。这个编译指示将变量声明为 `register`，
提示编译器应该将这个变量放到硬件寄存器里以提高访问速度。C 编译器经常忽略这个提示，理由充分：
没有这个提示它们往往能把活干得更漂亮。

然而，特定的情况下（例如一个字节码解释器的调度循环）这个编译指示可能会有所帮助。
{==+==}

{==+==}
global pragma
-------------
The `global` pragma can be applied to a variable within a proc to instruct
the compiler to store it in a global location and initialize it once at program
startup.
{==+==}
global 编译提示
--------------
可以给过程里的变量加上 `global` 编译提示，命令编译器把这个变量存储在全局位置，并且在程序启动时初始化一次。
{==+==}

{==+==}
  ```nim
  proc isHexNumber(s: string): bool =
    var pattern {.global.} = re"[0-9a-fA-F]+"
    result = s.match(pattern)
  ```
{==+==}
  ```nim
  proc isHexNumber(s: string): bool =
    var pattern {.global.} = re"[0-9a-fA-F]+"
    result = s.match(pattern)
  ```
{==+==}

{==+==}
When used within a generic proc, a separate unique global variable will be
created for each instantiation of the proc. The order of initialization of
the created global variables within a module is not defined, but all of them
will be initialized after any top-level variables in their originating module
and before any variable in a module that imports it.
{==+==}
在泛型过程里使用时，编译器会为泛型过程的每个实例创建独立的全局变量。编译器为某个模块创建的这些全局变量，
其初始化时的先后顺序不做规定；但是，整体上是先初始化这个模块的顶层变量，再初始化这些全局变量；
如果其它模块导入了这个模块，那么这些全局变量的初始化将早于其它模块里的变量。
{==+==}

{==+==}
Disabling certain messages
--------------------------
Nim generates some warnings and hints ("line too long") that may annoy the
user. A mechanism for disabling certain messages is provided: Each hint
and warning message contains a symbol in brackets. This is the message's
identifier that can be used to enable or disable it:
{==+==}
禁用某些消息
----------
Nim 产生的某些警告和提示消息（如“line too long”）可能令人厌烦。为此提供了一种禁用消息的机制：
每条提示和警告消息都关联了一个符号。这个符号就是消息的标识符，把它放到编译指示后面的方括号里就可以使能或者禁用这条消息：
{==+==}

{==+==}
  ```Nim
  {.hint[LineTooLong]: off.} # turn off the hint about too long lines
  ```
{==+==}
  ```Nim
  {.hint[LineTooLong]: off.} # 关闭关于代码行太长的那条提示
  ```
{==+==}

{==+==}
This is often better than disabling all warnings at once.
{==+==}
对于警告消息而言，这种办法往往比一股脑地禁用所有警告更好。
{==+==}

{==+==}
used pragma
-----------
{==+==}
used 编译提示
------------
{==+==}

{==+==}
Nim produces a warning for symbols that are not exported and not used either.
The `used` pragma can be attached to a symbol to suppress this warning. This
is particularly useful when the symbol was generated by a macro:
{==+==}
当一个符号既未导出也未被使用时，Nim 会输出一条警告消息。给这个符号加上 `used` 编译提示可以抑制这条消息。
当通过宏生成符号时，这个编译提示非常有用：
{==+==}

{==+==}
  ```nim
  template implementArithOps(T) =
    proc echoAdd(a, b: T) {.used.} =
      echo a + b
    proc echoSub(a, b: T) {.used.} =
      echo a - b

  # no warning produced for the unused 'echoSub'
  implementArithOps(int)
  echoAdd 3, 5
  ```
{==+==}
  ```nim
  template implementArithOps(T) =
    proc echoAdd(a, b: T) {.used.} =
      echo a + b
    proc echoSub(a, b: T) {.used.} =
      echo a - b

  # 'echoSub' 虽然未被使用，但是不会触发警告
  implementArithOps(int)
  echoAdd 3, 5
  ```
{==+==}

{==+==}
`used` can also be used as a top-level statement to mark a module as "used".
This prevents the "Unused import" warning:
{==+==}
`used` 也可用作顶层语句，把模块标记为“已使用”。这样就可以抑制针对这个模块的“未使用的导入”这条警告：
{==+==}

{==+==}
  ```nim
  # module: debughelper.nim
  when defined(nimHasUsed):
    # 'import debughelper' is so useful for debugging
    # that Nim shouldn't produce a warning for that import,
    # even if currently unused:
    {.used.}
  ```
{==+==}
  ```nim
  # 模块：debughelper.nim
  when defined(nimHasUsed):
    # 'import debughelper' 对于调试来说非常有用，
    # 即使这个模块未被使用，也不需要 Nim 输出警告：
    {.used.}
  ```
{==+==}