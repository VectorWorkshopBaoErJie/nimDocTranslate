
{==+==}
Mixing GC'ed memory with `ptr`
--------------------------------
{==+==}
混合GC内存和 `ptr`
--------------------------------
{==+==}

{==+==}
Special care has to be taken if an untraced object contains traced objects like
traced references, strings, or sequences: in order to free everything properly,
the built-in procedure `reset` has to be called before freeing the untraced
memory manually:
{==+==}
特别要注意的是，如果一个未被跟踪的对象包含跟踪的对象，如跟踪引用，字符串，或序列：为了使得所有对象正确释放，
在释放未被跟踪的内存之前，要手动调用内置过程 `reset` :
{==+==}

{==+==}
  ```nim
  type
    Data = tuple[x, y: int, s: string]

  # allocate memory for Data on the heap:
  var d = cast[ptr Data](alloc0(sizeof(Data)))

  # create a new string on the garbage collected heap:
  d.s = "abc"

  # tell the GC that the string is not needed anymore:
  reset(d.s)

  # free the memory:
  dealloc(d)
  ```
{==+==}
  ```nim
  type
    Data = tuple[x, y: int, s: string]

  # 在堆上为Data分配内存:
  var d = cast[ptr Data](alloc0(sizeof(Data)))

  # 在垃圾回收(GC)堆上创建一个新的字符串:
  d.s = "abc"

  # 告诉GC不再需要这个字符串:
  reset(d.s)

  # 释放内存:
  dealloc(d)
  ```
{==+==}

{==+==}
Without the `reset` call the memory allocated for the `d.s` string would
never be freed. The example also demonstrates two important features for
low-level programming: the `sizeof` proc returns the size of a type or value
in bytes. The `cast` operator can circumvent the type system: the compiler
is forced to treat the result of the `alloc0` call (which returns an untyped
pointer) as if it would have the type `ptr Data`. Casting should only be
done if it is unavoidable: it breaks type safety and bugs can lead to
mysterious crashes.
{==+==}
如果不调用`reset`，就永远不会释放分配给`d.s`字符串的内存。这个例子从编程底层来说，表现出两个重要的特性：`sizeof` 过程返回一个类型或值的字节大小。`cast`操作符可以避开类型系统：
编译器强制将`alloc0`(会返回一个未定义类型的指针)的结果认定为`ptr Data`的类型。只有在不可避免的情况下才需要进行转换，因为它破坏了类型安全，bug可能导致未知的崩溃。
{==+==}


{==+==}
The example only works because the memory is initialized to zero
(`alloc0` instead of `alloc` does this): `d.s` is thus initialized to
binary zero which the string assignment can handle. One needs to know low-level
details like this when mixing garbage-collected data with unmanaged memory.
{==+==}
当把垃圾收集的数据和非管理的内存混合在一起时，我们需要了解这样的低级细节。这个例子之所以有效，是因为内存被初始化为零（`alloc0`会这样做，而不是`alloc`）。`d.s`因此被初始化为二进制的零，从而字符串赋值可以处理。
{==+==}

{==+==}
.. XXX finalizers for traced objects
{==+==}
.. XXX 终结器，用于跟踪对象
{==+==}

{==+==}
Procedural type
---------------
{==+==}
过程类型
---------------
{==+==}

{==+==}
A procedural type is internally a pointer to a procedure. `nil` is
an allowed value for a variable of a procedural type.
{==+==}
过程类型是一个指向过程的内部指针。对于一个过程类型的变量来说，允许被赋值`nil`。
{==+==}

{==+==}
Examples:

  ```nim
  proc printItem(x: int) = ...

  proc forEach(c: proc (x: int) {.cdecl.}) =
    ...

  forEach(printItem)  # this will NOT compile because calling conventions differ
  ```


  ```nim
  type
    OnMouseMove = proc (x, y: int) {.closure.}

  proc onMouseMove(mouseX, mouseY: int) =
    # has default calling convention
    echo "x: ", mouseX, " y: ", mouseY

  proc setOnMouseMove(mouseMoveEvent: OnMouseMove) = discard

  # ok, 'onMouseMove' has the default calling convention, which is compatible
  # to 'closure':
  setOnMouseMove(onMouseMove)
  ```
{==+==}
示例：
   ```nim
  proc printItem(x: int) = ...

  proc forEach(c: proc (x: int) {.cdecl.}) =
    ...

  forEach(printItem)  # 这个将不会被编译，因为调用约定不同
  ```


  ```nim
  type
    OnMouseMove = proc (x, y: int) {.closure.}

  proc onMouseMove(mouseX, mouseY: int) =
    # 有默认的调用约定
    echo "x: ", mouseX, " y: ", mouseY

  proc setOnMouseMove(mouseMoveEvent: OnMouseMove) = discard

  # 好的, 'onMouseMove' 有默认的调用约定 可以兼容 'closure':
  setOnMouseMove(onMouseMove)
  ```
{==+==}

{==+==}
A subtle issue with procedural types is that the calling convention of the
procedure influences the type compatibility: procedural types are only
compatible if they have the same calling convention. As a special extension,
a procedure of the calling convention `nimcall` can be passed to a parameter
that expects a proc of the calling convention `closure`.
{==+==}
过程类型的一个细微问题是，过程的调用约定会影响类型的兼容性：过程类型只有在调用约定相同的情况下才兼容。特殊的扩展是，调用约定为 `nimcall` 的过程可以被传递给期望调用约定为 `closure` 的过程参数。
{==+==}

{==+==}
Nim supports these `calling conventions`:idx:\:
{==+==}
Nim支持下列 `calling conventions`:idx:\:
{==+==}

{==+==}
`nimcall`:idx:
    is the default convention used for a Nim **proc**. It is the
    same as `fastcall`, but only for C compilers that support `fastcall`.
{==+==}
`nimcall`:idx:
    是默认用于Nim **proc** 的惯例。它和`fastcall`一样，但是只有C编译器支持`fastcall`。
{==+==}

{==+==}
`closure`:idx:
    is the default calling convention for a **procedural type** that lacks
    any pragma annotations. It indicates that the procedure has a hidden
    implicit parameter (an *environment*). Proc vars that have the calling
    convention `closure` take up two machine words: One for the proc pointer
    and another one for the pointer to implicitly passed environment.
{==+==}
`closure`:idx:
    对于缺少任意编译指示注解的过程类型 **procedural type** 的默认调用约定。它表明这个过程有一个隐藏的隐式参数(一个*environment*)。拥有调用约定`closure`的函数变量占两个机器字:一个是用于函数指针，另一个用于隐式传递环境指针。
{==+==}

{==+==}
`stdcall`:idx:
    This is the stdcall convention as specified by Microsoft. The generated C
    procedure is declared with the `__stdcall` keyword.
{==+==}
`stdcall`:idx:
    这是微软指定的标准惯例。声明`__stdcall`关键字生成C程序。
{==+==}

{==+==}
`cdecl`:idx:
    The cdecl convention means that a procedure shall use the same convention
    as the C compiler. Under Windows the generated C procedure is declared with
    the `__cdecl` keyword.
{==+==}
`cdecl`:idx:
    cdecl惯例意味着程序将使用和C编译器一样的惯例。在Windows下生成C程序是声明`__cdecl`关键字。
{==+==}

{==+==}
`safecall`:idx:
    This is the safecall convention as specified by Microsoft. The generated C
    procedure is declared with the `__safecall` keyword. The word *safe*
    refers to the fact that all hardware registers shall be pushed to the
    hardware stack.
{==+==}
`safecall`:idx:
    微软指定的安全调用约定。生成C程序是用`__safecall`关键字声明。 *safe* 这个词是指会将所有的硬件寄存器压入硬件堆栈。
{==+==}

{==+==}
`inline`:idx:
    The inline convention means the caller should not call the procedure,
    but inline its code directly. Note that Nim does not inline, but leaves
    this to the C compiler; it generates `__inline` procedures. This is
    only a hint for the compiler: it may completely ignore it, and
    it may inline procedures that are not marked as `inline`.
{==+==}
`inline`:idx:
    inline内联惯例意味着调用者不应该调用过程，而是直接内联其代码。请注意，Nim并不直接内联，而是把这个问题留给C编译器。它生成了`__inline`过程，这只是给编译器的一个提示：编译器可以完全忽略它，也可以内联那些没有标记为`inline`的过程。
{==+==}

{==+==}
`fastcall`:idx:
    Fastcall means different things to different C compilers. One gets whatever
    the C `__fastcall` means.
{==+==}
`fastcall`:idx:
    FastCall意味着对于不同的C编译器有所不同。意味着得获得C`__fastcall`表示。
{==+==}

{==+==}
`thiscall`:idx:
    This is the thiscall calling convention as specified by Microsoft, used on
    C++ class member functions on the x86 architecture.
{==+==}
`thiscall`:idx:
    这是微软指定的thiscall调用约定，被用于X86架构C++类成员函数中。
{==+==}

{==+==}
`syscall`:idx:
    The syscall convention is the same as `__syscall`:c: in C. It is used for
    interrupts.
{==+==}
`syscall`:idx:
    在C中syscall惯例和 `__syscall`:c: 是一样的。它用于中断。
{==+==}

{==+==}
`noconv`:idx:
    The generated C code will not have any explicit calling convention and thus
    use the C compiler's default calling convention. This is needed because
    Nim's default calling convention for procedures is `fastcall` to
    improve speed.
{==+==}
`noconv`:idx:
    生成的C代码将不会有任何的显示调用约定，因此会使用C编译的默认调用约定。这个是需要的，因为Nim默认会对过程使用`falsecall`调用约定来提升速度。
{==+==}

{==+==}
Most calling conventions exist only for the Windows 32-bit platform.
{==+==}
大多数调用约定只存在于32位Windows平台。
{==+==}

{==+==}
The default calling convention is `nimcall`, unless it is an inner proc (a
proc inside of a proc). For an inner proc an analysis is performed whether it
accesses its environment. If it does so, it has the calling convention
`closure`, otherwise it has the calling convention `nimcall`.
{==+==}
默认的调用约定是 `nimcall` ，除非它是一个内部过程（一个过程中的过程）。对于一个内部过程，将分析它是否访问其环境。如果它访问了环境，就采用`closure`的调用约定，否则就采用`nimcall`的调用约定。
{==+==}

{==+==}
Distinct type
-------------
{==+==}
Distinct类型
-------------
{==+==}

{==+==}
A `distinct` type is a new type derived from a `base type`:idx: that is
incompatible with its base type. In particular, it is an essential property
of a distinct type that it **does not** imply a subtype relation between it
and its base type. Explicit type conversions from a distinct type to its
base type and vice versa are allowed. See also `distinctBase` to get the
reverse operation.
{==+==}
`distinct`类型是一个新类型源于 `base type`:idx: 它与它的基础类型不兼容。特别的是，它**不**暗示它与其基类型之间的子类型关系是不同类型的基本属性。从distinct类型到它的显式类型转换允许使用基本类型，反之亦然。另请参阅 `distinctBase` 以获取反向操作。
{==+==}

{==+==}
A distinct type is an ordinal type if its base type is an ordinal type.
{==+==}
如果一个distinct类型的基类型是序数类型，则distinct类型也为序数类型。
{==+==}

{==+==}
### Modeling currencies
{==+==}
### 模拟货币
{==+==}

{==+==}
A distinct type can be used to model different physical `units`:idx: with a
numerical base type, for example. The following example models currencies.
{==+==}
distinct类型可用于建模不同的物理“单位”:idx:例如，具有数字基本类型。 以下示例模拟货币。
{==+==}

{==+==}
Different currencies should not be mixed in monetary calculations. Distinct
types are a perfect tool to model different currencies:
{==+==}
在货币计算中不应混用不同的货币。Distinct类型是一个模拟不同货币的完美工具：
{==+==}

{==+==}
```nim
  type
    Dollar = distinct int
    Euro = distinct int

  var
    d: Dollar
    e: Euro

  echo d + 12
  # Error: cannot add a number with no unit and a `Dollar`
  ```
{==+==}
```nim
  type
    Dollar = distinct int
    Euro = distinct int

  var
    d: Dollar
    e: Euro

  echo d + 12
  # 错误: 一个无单位的数字不可以与`Dollar`相加
  ```
{==+==}

{==+==}
Unfortunately, `d + 12.Dollar` is not allowed either,
because `+` is defined for `int` (among others), not for `Dollar`. So
a `+` for dollars needs to be defined:
{==+==}
不幸的是,`d + 12.Dollar`也是不被允许的，因为`+`被`int`(以及其他)定义，并非`Dollat`。所以对于`Dollar`的`+`需要被这样定义：
{==+==}

{==+==}
  ```nim
  proc `+` (x, y: Dollar): Dollar =
    result = Dollar(int(x) + int(y))
  ```
{==+==}
  ```nim
  proc `+` (x, y: Dollar): Dollar =
    result = Dollar(int(x) + int(y))
  ```
{==+==}

{==+==}
It does not make sense to multiply a dollar with a dollar, but with a
number without unit; and the same holds for division:
{==+==}
将一美元乘以一美元是没有意义的，但是可以乘以一个没有单位的数字；除法也一样：
{==+==}

{==+==}
  ```nim
  proc `*` (x: Dollar, y: int): Dollar =
    result = Dollar(int(x) * y)

  proc `*` (x: int, y: Dollar): Dollar =
    result = Dollar(x * int(y))

  proc `div` ...
  ```
{==+==}
  ```nim
  proc `*` (x: Dollar, y: int): Dollar =
    result = Dollar(int(x) * y)

  proc `*` (x: int, y: Dollar): Dollar =
    result = Dollar(x * int(y))

  proc `div` ...
  ```
{==+==}

{==+==}
This quickly gets tedious. The implementations are trivial and the compiler
should not generate all this code only to optimize it away later - after all
`+` for dollars should produce the same binary code as `+` for ints.
The pragma `borrow`:idx: has been designed to solve this problem; in principle,
it generates the above trivial implementations:
{==+==}
这很快就会变得乏味.实现很简单，编译器不应该生成所有这些代码只是为了稍后优化它 - 毕竟美元的 `+` 应该产生与整数的 `+` 相同的二进制代码。编译指示`borrow`:idx: 旨在解决这个问题； 原则上，它会生成上述简单的实现：
{==+==}

{==+==}
  ```nim
  proc `*` (x: Dollar, y: int): Dollar {.borrow.}
  proc `*` (x: int, y: Dollar): Dollar {.borrow.}
  proc `div` (x: Dollar, y: int): Dollar {.borrow.}
  ```
{==+==}
  ```nim
  proc `*` (x: Dollar, y: int): Dollar {.borrow.}
  proc `*` (x: int, y: Dollar): Dollar {.borrow.}
  proc `div` (x: Dollar, y: int): Dollar {.borrow.}
  ```
{==+==}

{==+==}
But it seems all this boilerplate code needs to be repeated for the `Euro`
currency. This can be solved with templates_.
{==+==}
但似乎所有的上述样板在`Euro`货币都要重复一遍。这个可以使用templates_来解决。
{==+==}

{==+==}

  ```nim  test = "nim c $1"
  template additive(typ: typedesc) =
    proc `+` *(x, y: typ): typ {.borrow.}
    proc `-` *(x, y: typ): typ {.borrow.}

    # unary operators:
    proc `+` *(x: typ): typ {.borrow.}
    proc `-` *(x: typ): typ {.borrow.}

  template multiplicative(typ, base: typedesc) =
    proc `*` *(x: typ, y: base): typ {.borrow.}
    proc `*` *(x: base, y: typ): typ {.borrow.}
    proc `div` *(x: typ, y: base): typ {.borrow.}
    proc `mod` *(x: typ, y: base): typ {.borrow.}

  template comparable(typ: typedesc) =
    proc `<` * (x, y: typ): bool {.borrow.}
    proc `<=` * (x, y: typ): bool {.borrow.}
    proc `==` * (x, y: typ): bool {.borrow.}

  template defineCurrency(typ, base: untyped) =
    type
      typ* = distinct base
    additive(typ)
    multiplicative(typ, base)
    comparable(typ)

  defineCurrency(Dollar, int)
  defineCurrency(Euro, int)
  ```
{==+==}

  ```nim  test = "nim c $1"
  template additive(typ: typedesc) =
    proc `+` *(x, y: typ): typ {.borrow.}
    proc `-` *(x, y: typ): typ {.borrow.}

    # 一元操作符:
    proc `+` *(x: typ): typ {.borrow.}
    proc `-` *(x: typ): typ {.borrow.}

  template multiplicative(typ, base: typedesc) =
    proc `*` *(x: typ, y: base): typ {.borrow.}
    proc `*` *(x: base, y: typ): typ {.borrow.}
    proc `div` *(x: typ, y: base): typ {.borrow.}
    proc `mod` *(x: typ, y: base): typ {.borrow.}

  template comparable(typ: typedesc) =
    proc `<` * (x, y: typ): bool {.borrow.}
    proc `<=` * (x, y: typ): bool {.borrow.}
    proc `==` * (x, y: typ): bool {.borrow.}

  template defineCurrency(typ, base: untyped) =
    type
      typ* = distinct base
    additive(typ)
    multiplicative(typ, base)
    comparable(typ)

  defineCurrency(Dollar, int)
  defineCurrency(Euro, int)
  ```
{==+==}

{==+==}
The borrow pragma can also be used to annotate the distinct type to allow
certain builtin operations to be lifted:
{==+==}
borrow语法也可用于注释distinct类型以运行提升某些内置操作。
{==+==}

{==+==}
  ```nim
  type
    Foo = object
      a, b: int
      s: string

    Bar {.borrow: `.`.} = distinct Foo

  var bb: ref Bar
  new bb
  # field access now valid
  bb.a = 90
  bb.s = "abc"
  ```
{==+==}
  ```nim
  type
    Foo = object
      a, b: int
      s: string

    Bar {.borrow: `.`.} = distinct Foo

  var bb: ref Bar
  new bb
  # 域访问有效
  bb.a = 90
  bb.s = "abc"
  ```
{==+==}

{==+==}
Currently, only the dot accessor can be borrowed in this way.
{==+==}
目前只有点访问器可以通过这个方式borrow
{==+==}

{==+==}
### Avoiding SQL injection attacks
{==+==}
### 避免SQL注入攻击
{==+==}

{==+==}
An SQL statement that is passed from Nim to an SQL database might be
modeled as a string. However, using string templates and filling in the
values is vulnerable to the famous `SQL injection attack`:idx:\:
{==+==}
从Nim传递到SQL数据库的SQL语句可能转化为字符串。但是，使用字符串模板并填写。但是，使用字符串模板并填写值很容易受到著名的“SQL注入攻击”:idx:\：
{==+==}

{==+==}
  ```nim
  import std/strutils

  proc query(db: DbHandle, statement: string) = ...

  var
    username: string

  db.query("SELECT FROM users WHERE name = '$1'" % username)
  # Horrible security hole, but the compiler does not mind!
  ```
{==+==}
  ```nim
  import std/strutils

  proc query(db: DbHandle, statement: string) = ...

  var
    username: string

  db.query("SELECT FROM users WHERE name = '$1'" % username)
  # 糟糕的安全漏洞，但是编译器不关心
  ```
{==+==}

{==+==}
This can be avoided by distinguishing strings that contain SQL from strings
that don't. Distinct types provide a means to introduce a new string type
`SQL` that is incompatible with `string`:
{==+==}
这可以通过区分包含 SQL 的字符串和不包含 SQL 的字符串来避免。Distinct类型提供了一种引入与 `string` 不兼容的新字符串类型 `SQL` 的方法：
{==+==}

{==+==}
  ```nim
  type
    SQL = distinct string

  proc query(db: DbHandle, statement: SQL) = ...

  var
    username: string

  db.query("SELECT FROM users WHERE name = '$1'" % username)
  # Static error: `query` expects an SQL string!
  ```
{==+==}
  ```nim
  type
    SQL = distinct string

  proc query(db: DbHandle, statement: SQL) = ...

  var
    username: string

  db.query("SELECT FROM users WHERE name = '$1'" % username)
  # 静态错误: `query` 期望一个SQL字符串
  ```
{==+==}

{==+==}
It is an essential property of abstract types that they **do not** imply a
subtype relation between the abstract type and its base type. Explicit type
conversions from `string` to `SQL` are allowed:
{==+==}
抽象类型有一个重要的属性是，抽象类型与它们的子类型之间没有父子关系。运行从`string`到`SQL`的显示类型转换。
{==+==}

{==+==}
```nim
  import std/[strutils, sequtils]

  proc properQuote(s: string): SQL =
    # quotes a string properly for an SQL statement
    return SQL(s)

  proc `%` (frmt: SQL, values: openarray[string]): SQL =
    # quote each argument:
    let v = values.mapIt(properQuote(it))
    # we need a temporary type for the type conversion :-(
    type StrSeq = seq[string]
    # call strutils.`%`:
    result = SQL(string(frmt) % StrSeq(v))

  db.query("SELECT FROM users WHERE name = '$1'".SQL % [username])
  ```
{==+==}
```nim
  import std/[strutils, sequtils]

  proc properQuote(s: string): SQL =
    # 为SQL语句正确引用字符串
    return SQL(s)

  proc `%` (frmt: SQL, values: openarray[string]): SQL =
    # 引用每个参数:
    let v = values.mapIt(properQuote(it))
    # 我们需要一个临时类型为了类型转换 :-(
    type StrSeq = seq[string]
    # 调用 strutils.`%`:
    result = SQL(string(frmt) % StrSeq(v))

  db.query("SELECT FROM users WHERE name = '$1'".SQL % [username])
  ```
{==+==}

{==+==}
Now we have compile-time checking against SQL injection attacks. Since
`"".SQL` is transformed to `SQL("")` no new syntax is needed for nice
looking `SQL` string literals. The hypothetical `SQL` type actually
exists in the library as the `SqlQuery type <db_common.html#SqlQuery>`_ of
modules like `db_sqlite <db_sqlite.html>`_.
{==+==}
由于 `"".SQL`被转换为 `SQL("")`，因此美观的 `SQL` 字符串文字不需要新的语法。假定的 `SQL` 类型实际上作为 `SqlQuery 类型 <db_common.html#SqlQuery>`_ 的模块存在于库中，例如 `db_sqlite <db_sqlite.html>`_。
{==+==}


{==+==}
Auto type
---------
{==+==}
Auto类型
---------
{==+==}

{==+==}
The `auto` type can only be used for return types and parameters. For return
types it causes the compiler to infer the type from the routine body:
{==+==}
`auto`类型只能用来作为返回类型和参数。对于返回类型，它会导致编译器从例程主体推断类型：
{==+==}

{==+==}
  ```nim
  proc returnsInt(): auto = 1984
  ```
{==+==}
  ```nim
  proc returnsInt(): auto = 1984
  ```
{==+==}

{==+==}
For parameters it currently creates implicitly generic routines:
{==+==}
对于参数，它当前创建隐式通用例程：
{==+==}

{==+==}

  ```nim
  proc foo(a, b: auto) = discard
  ```
{==+==}
  ```nim
  proc foo(a, b: auto) = discard
  ```
{==+==}

{==+==}
Is the same as:
{==+==}
和如下一样：
{==+==}

{==+==}
  ```nim
  proc foo[T1, T2](a: T1, b: T2) = discard
  ```
{==+==}
  ```nim
  proc foo[T1, T2](a: T1, b: T2) = discard
  ```
{==+==}

{==+==}
However, later versions of the language might change this to mean "infer the
parameters' types from the body". Then the above `foo` would be rejected as
the parameters' types can not be inferred from an empty `discard` statement.
{==+==}
但是，该语言的之后版本可能会将其更改为“从主体推断参数的类型”。
{==+==}

{==+==}
Type relations
==============
{==+==}
类型关系
==============
{==+==}

{==+==}
The following section defines several relations on types that are needed to
describe the type checking done by the compiler.
{==+==}
以下部分定义了描述编译器完成的类型检查所需的几种类型关系。
{==+==}

{==+==}
Type equality
-------------
{==+==}
类型相等性
-------------
{==+==}

{==+==}
Nim uses structural type equivalence for most types. Only for objects,
enumerations and distinct types and for generic types name equivalence is used.
{==+==}
Nim 对大多数类型使用结构类型等价。仅对对象、枚举和不同类型以及泛型类型使用名称等价。
{==+==}

{==+==}
Subtype relation
----------------
{==+==}
Subtype关系
----------------
{==+==}

{==+==}
If object `a` inherits from `b`, `a` is a subtype of `b`.
{==+==}
如果对象`a`继承自`b`，`a`是`b`的子类型。
{==+==}

{==+==}
This subtype relation is extended to the types `var`, `ref`, `ptr`.
If `A` is a subtype of `B` and `A` and `B` are `object` types then:
{==+==}
子类型关系被拓展到类型`var`,`ref`,`prt`。如果`A`是`B`的子类型，`A`和`B`是`object`类型那么：
{==+==}

{==+==}
- `var A` is a subtype of `var B`
- `ref A` is a subtype of `ref B`
- `ptr A` is a subtype of `ptr B`.
{==+==}
- `var A`是`var B`的子类型
- `ref A`是`ref B`的子类型
- `ptr A`是`ptr B`的子类型。
{==+==}

{==+==}
**Note**: In later versions of the language the subtype relation might
be changed to *require* the pointer indirection in order to prevent
"object slicing".

{==+==}
**注意**：在该语言的更高版本中，子类型关系可能会更改为*要求*指针间接，以防止“object slicing”。
{==+==}

{==+==}
Convertible relation
--------------------
{==+==}
交换关系
{==+==}

{==+==}
A type `a` is **implicitly** convertible to type `b` iff the following
algorithm returns true:
{==+==}
如果以下算法返回 true，则类型 `a` **隐式**可转换为类型 `b`：
{==+==}

{==+==}
  ```nim
  proc isImplicitlyConvertible(a, b: PType): bool =
    if isSubtype(a, b):
      return true
    if isIntLiteral(a):
      return b in {int8, int16, int32, int64, int, uint, uint8, uint16,
                   uint32, uint64, float32, float64}
    case a.kind
    of int:     result = b in {int32, int64}
    of int8:    result = b in {int16, int32, int64, int}
    of int16:   result = b in {int32, int64, int}
    of int32:   result = b in {int64, int}
    of uint:    result = b in {uint32, uint64}
    of uint8:   result = b in {uint16, uint32, uint64}
    of uint16:  result = b in {uint32, uint64}
    of uint32:  result = b in {uint64}
    of float32: result = b in {float64}
    of float64: result = b in {float32}
    of seq:
      result = b == openArray and typeEquals(a.baseType, b.baseType)
    of array:
      result = b == openArray and typeEquals(a.baseType, b.baseType)
      if a.baseType == char and a.indexType.rangeA == 0:
        result = b == cstring
    of cstring, ptr:
      result = b == pointer
    of string:
      result = b == cstring
    of proc:
      result = typeEquals(a, b) or compatibleParametersAndEffects(a, b)
  ```
{==+==}
  ```nim
  proc isImplicitlyConvertible(a, b: PType): bool =
    if isSubtype(a, b):
      return true
    if isIntLiteral(a):
      return b in {int8, int16, int32, int64, int, uint, uint8, uint16,
                   uint32, uint64, float32, float64}
    case a.kind
    of int:     result = b in {int32, int64}
    of int8:    result = b in {int16, int32, int64, int}
    of int16:   result = b in {int32, int64, int}
    of int32:   result = b in {int64, int}
    of uint:    result = b in {uint32, uint64}
    of uint8:   result = b in {uint16, uint32, uint64}
    of uint16:  result = b in {uint32, uint64}
    of uint32:  result = b in {uint64}
    of float32: result = b in {float64}
    of float64: result = b in {float32}
    of seq:
      result = b == openArray and typeEquals(a.baseType, b.baseType)
    of array:
      result = b == openArray and typeEquals(a.baseType, b.baseType)
      if a.baseType == char and a.indexType.rangeA == 0:
        result = b == cstring
    of cstring, ptr:
      result = b == pointer
    of string:
      result = b == cstring
    of proc:
      result = typeEquals(a, b) or compatibleParametersAndEffects(a, b)
  ```
{==+==}

{==+==}
We used the predicate `typeEquals(a, b)` for the "type equality" property
and the predicate `isSubtype(a, b)` for the "subtype relation".
`compatibleParametersAndEffects(a, b)` is currently not specified.
{==+==}
我们使用谓词 `typeEquals(a, b)` 表示“类型相等”属性，使用谓词 `isSubtype(a, b)` 表示“子类型关系”。`compatibleParametersAndEffects(a, b)` 当前未指定。
{==+==}

{==+==}
Implicit conversions are also performed for Nim's `range` type
constructor.
{==+==}
Nim 的 `range` 类型构造函数也执行隐式转换。
{==+==}

{==+==}
Let `a0`, `b0` of type `T`.
{==+==}
Let `a0`, `b0`为类型`T`。
{==+==}

{==+==}
Let `A = range[a0..b0]` be the argument's type, `F` the formal
parameter's type. Then an implicit conversion from `A` to `F`
exists if `a0 >= low(F) and b0 <= high(F)` and both `T` and `F`
are signed integers or if both are unsigned integers.
{==+==}
让 `A = range[a0..b0]` 为参数的类型， `F` 为形参的类型。如果 `a0 >= low(F) 和 b0 <= high(F)` 并且 `T` 和 `F` 都是有符号整数或两者都是无符号整数，则存在从 `A` 到 `F` 的隐式转换。
{==+==}

{==+==}
A type `a` is **explicitly** convertible to type `b` iff the following
algorithm returns true:
{==+==}
如果下列算法返回true，则类型`a`是显示转换为类型`b`：
{==+==}

{==+==}
 ```nim
  proc isIntegralType(t: PType): bool =
    result = isOrdinal(t) or t.kind in {float, float32, float64}

  proc isExplicitlyConvertible(a, b: PType): bool =
    result = false
    if isImplicitlyConvertible(a, b): return true
    if typeEquals(a, b): return true
    if a == distinct and typeEquals(a.baseType, b): return true
    if b == distinct and typeEquals(b.baseType, a): return true
    if isIntegralType(a) and isIntegralType(b): return true
    if isSubtype(a, b) or isSubtype(b, a): return true
  ```
{==+==}
 ```nim
  proc isIntegralType(t: PType): bool =
    result = isOrdinal(t) or t.kind in {float, float32, float64}

  proc isExplicitlyConvertible(a, b: PType): bool =
    result = false
    if isImplicitlyConvertible(a, b): return true
    if typeEquals(a, b): return true
    if a == distinct and typeEquals(a.baseType, b): return true
    if b == distinct and typeEquals(b.baseType, a): return true
    if isIntegralType(a) and isIntegralType(b): return true
    if isSubtype(a, b) or isSubtype(b, a): return true
  ```
{==+==}

{==+==}
The convertible relation can be relaxed by a user-defined type
`converter`:idx:.
{==+==}
可转换关系可以通过用户定义的类型 `converter`:idx:来relax:
{==+==}

{==+==}

  ```nim
  converter toInt(x: char): int = result = ord(x)

  var
    x: int
    chr: char = 'a'

  # implicit conversion magic happens here
  x = chr
  echo x # => 97
  # one can use the explicit form too
  x = chr.toInt
  echo x # => 97
  ```
{==+==}

  ```nim
  converter toInt(x: char): int = result = ord(x)

  var
    x: int
    chr: char = 'a'

  # 隐式转换魔法在这里发生
  x = chr
  echo x # => 97
  # 另一个也可以使用显式形式
  x = chr.toInt
  echo x # => 97
  ```
{==+==}

{==+==}
The type conversion `T(a)` is an L-value if `a` is an L-value and
`typeEqualsOrDistinct(T, typeof(a))` holds.
{==+==}
如果 `a` 是 L-value 并且 `typeEqualsOrDistinct(T, typeof(a))` 成立，则类型转换 `T(a)` 是 L-value。
{==+==}

{==+==}
Overload resolution
===================
{==+==}
重载解决方案
===================
{==+==}

{==+==}
In a call `p(args)` the routine `p` that matches best is selected. If
multiple routines match equally well, the ambiguity is reported during
semantic analysis.
{==+==}
在调用 `p(args)` 中，选择最匹配的例程 `p`。如果多个例程匹配得一样好，则在语义分析期间报告歧义。
{==+==}

{==+==}
Every arg in args needs to match. There are multiple different categories how an
argument can match. Let `f` be the formal parameter's type and `a` the type
of the argument.
{==+==}
args 中的每个 arg 都需要匹配。有多个不同的类别可以匹配一个参数。Let `f` 是形参的类型，`a` 是参数的类型。
{==+==}

{==+==}
1. Exact match: `a` and `f` are of the same type.
2. Literal match: `a` is an integer literal of value `v`
   and `f` is a signed or unsigned integer type and `v` is in `f`'s
   range. Or:  `a` is a floating-point literal of value `v`
   and `f` is a floating-point type and `v` is in `f`'s
   range.
3. Generic match: `f` is a generic type and `a` matches, for
   instance `a` is `int` and `f` is a generic (constrained) parameter
   type (like in `[T]` or `[T: int|char]`).
4. Subrange or subtype match: `a` is a `range[T]` and `T`
   matches `f` exactly. Or: `a` is a subtype of `f`.
5. Integral conversion match: `a` is convertible to `f` and `f` and `a`
   is some integer or floating-point type.
6. Conversion match: `a` is convertible to `f`, possibly via a user
   defined `converter`.
{==+==}
1. 完全匹配: `a`和`f`是同一类型。
2. 字面量匹配：`a` 是值`v` 的整数字面量，`f` 是有符号或无符号整数类型，`v` 在`f` 的范围内。 或者：`a` 是值`v` 的浮点字面量，`f` 是浮点类型，`v` 在`f` 的范围内。
3. 泛型匹配：`f` 是泛型类型和 `a` 匹配，例如 `a` 是 `int` 而 `f` 是泛型（受约束的）参数类型（如在 `[T]` 或 `[ T：int|char]`）。
4. 子范围或子类型匹配：`a` 是`range[T]`，`T` 与`f` 完全匹配。 或者：`a` 是 `f` 的子类型。
5. 整数转换匹配：`a`可以转换为`f`，`f`和`a`是某些整数或浮点类型。
6. 转换匹配: `a` 可转换为 `f`，可能通过用户定义的 `converter`。
{==+==}

{==+==}
These matching categories have a priority: An exact match is better than a
literal match and that is better than a generic match etc. In the following,
`count(p, m)` counts the number of matches of the matching category `m`
for the routine `p`.
{==+==}
在下文中，`count(p, m)` 计算例程`p` 的匹配类别`m` 的匹配数。
{==+==}

{==+==}
A routine `p` matches better than a routine `q` if the following
algorithm returns true::
{==+==}
如果以下算法返回 true，则例程 `p` 比例程 `q` 匹配得更好：
{==+==}

{==+==}
  for each matching category m in ["exact match", "literal match",
                                  "generic match", "subtype match",
                                  "integral match", "conversion match"]:
    if count(p, m) > count(q, m): return true
    elif count(p, m) == count(q, m):
      discard "continue with next category m"
    else:
      return false
  return "ambiguous"
{==+==}
 对每个匹配类别m在["完全匹配", "字面量匹配", "泛型匹配", "子类型匹配", "整型配型", "转换匹配"]:
        if count(p, m) > count(q, m): return true
    elif count(p, m) == count(q, m):
      discard "continue with next category m"
    else:
      return false
  return "ambiguous"
{==+==}

{==+==}
Some examples:
{==+==}
一些例子：
{==+==}

{==+==}
  ```nim
  proc takesInt(x: int) = echo "int"
  proc takesInt[T](x: T) = echo "T"
  proc takesInt(x: int16) = echo "int16"

  takesInt(4) # "int"
  var x: int32
  takesInt(x) # "T"
  var y: int16
  takesInt(y) # "int16"
  var z: range[0..4] = 0
  takesInt(z) # "T"
  ```

{==+==}
  ```nim
  proc takesInt(x: int) = echo "int"
  proc takesInt[T](x: T) = echo "T"
  proc takesInt(x: int16) = echo "int16"

  takesInt(4) # "int"
  var x: int32
  takesInt(x) # "T"
  var y: int16
  takesInt(y) # "int16"
  var z: range[0..4] = 0
  takesInt(z) # "T"
  ```

{==+==}

{==+==}
If this algorithm returns "ambiguous" further disambiguation is performed:
If the argument `a` matches both the parameter type `f` of `p`
and `g` of `q` via a subtyping relation, the inheritance depth is taken
into account:
{==+==}
如果此算法返回“歧义”，则执行进一步消歧：如果参数 `a` 通过子类型关系同时匹配 `p` 的参数类型 `f` 和 `q` 的 `g`，则考虑继承深度 ：
{==+==}

{==+==}
  ```nim
  type
    A = object of RootObj
    B = object of A
    C = object of B

  proc p(obj: A) =
    echo "A"

  proc p(obj: B) =
    echo "B"

  var c = C()
  # not ambiguous, calls 'B', not 'A' since B is a subtype of A
  # but not vice versa:
  p(c)

  proc pp(obj: A, obj2: B) = echo "A B"
  proc pp(obj: B, obj2: A) = echo "B A"

  # but this is ambiguous:
  pp(c, c)
  ```
{==+==}
  ```nim
  type
    A = object of RootObj
    B = object of A
    C = object of B

  proc p(obj: A) =
    echo "A"

  proc p(obj: B) =
    echo "B"

  var c = C()
  # 没有歧义, 调用“B”，而不是“A”，因为 B 是 A 的子类型
  # 但是反之:
  p(c)

  proc pp(obj: A, obj2: B) = echo "A B"
  proc pp(obj: B, obj2: A) = echo "B A"

  # 但是这个有歧义:
  pp(c, c)
  ```
{==+==}

{==+==}
Likewise, for generic matches, the most specialized generic type (that still
matches) is preferred:
{==+==}
同样，对于泛型匹配，最专用的泛型类型（仍然匹配）是首选：
{==+==}

{==+==}
  ```nim
  proc gen[T](x: ref ref T) = echo "ref ref T"
  proc gen[T](x: ref T) = echo "ref T"
  proc gen[T](x: T) = echo "T"

  var ri: ref int
  gen(ri) # "ref T"
  ```
{==+==}
  ```nim
  proc gen[T](x: ref ref T) = echo "ref ref T"
  proc gen[T](x: ref T) = echo "ref T"
  proc gen[T](x: T) = echo "T"

  var ri: ref int
  gen(ri) # "ref T"
  ```
{==+==}

{==+==}
Overloading based on 'var T'
--------------------------------------
{==+==}
基于 'var T' 的重载
--------------------------------------
{==+==}

{==+==}
If the formal parameter `f` is of type `var T`
in addition to the ordinary type checking,
the argument is checked to be an `l-value`:idx:.
`var T` matches better than just `T` then.
{==+==}
如果形参 `f` 是 `var T` 类型，除了普通类型检查外，参数会被检查为 `左值`:idx:。`var T` 比 `T` 匹配得更好。
{==+==}

{==+==}
  ```nim
  proc sayHi(x: int): string =
    # matches a non-var int
    result = $x
  proc sayHi(x: var int): string =
    # matches a var int
    result = $(x + 10)

  proc sayHello(x: int) =
    var m = x # a mutable version of x
    echo sayHi(x) # matches the non-var version of sayHi
    echo sayHi(m) # matches the var version of sayHi

  sayHello(3) # 3
              # 13
  ```
{==+==}
  ```nim
  proc sayHi(x: int): string =
    # 匹配一个非变量整型
    result = $x
  proc sayHi(x: var int): string =
    # 匹配一个整形变量
    result = $(x + 10)

  proc sayHello(x: int) =
    var m = x # 一个x的可变版本
    echo sayHi(x) # 匹配sayHi的非变量版本
    echo sayHi(m) # 匹配sayHi的变量版本

  sayHello(3) # 3
              # 13
  ```
{==+==}

{==+==}
Lazy type resolution for untyped
--------------------------------
{==+==}
无类型的惰性类型解析
--------------------------------
{==+==}

{==+==}
**Note**: An `unresolved`:idx: expression is an expression for which no symbol
lookups and no type checking have been performed.
{==+==}
`unresolved`:idx:表达式是没有符号的表达式，不执行查找和类型检查。
{==+==}

{==+==}
Since templates and macros that are not declared as `immediate` participate
in overloading resolution, it's essential to have a way to pass unresolved
expressions to a template or macro. This is what the meta-type `untyped`
accomplishes:
{==+==}
由于未声明为 `immediate` 的模板和宏参与重载解析，因此必须有一种方法将未解析的表达式传递给模板或宏。 这就是元类型 `untyped` 完成的工作：
{==+==}

{==+==}
  ```nim
  template rem(x: untyped) = discard

  rem unresolvedExpression(undeclaredIdentifier)
  ```
{==+==}
  ```nim
  template rem(x: untyped) = discard

  rem unresolvedExpression(undeclaredIdentifier)
  ```
{==+==}

{==+==}
A parameter of type `untyped` always matches any argument (as long as there is
any argument passed to it).
{==+==}
`untyped` 类型的参数总是匹配任何参数（只要有任何参数传递给它）。
{==+==}

{==+==}
But one has to watch out because other overloads might trigger the
argument's resolution:
{==+==}
但是必须小心，因为其他重载可能会触发参数的解析：
{==+==}

{==+==}

  ```nim
  template rem(x: untyped) = discard
  proc rem[T](x: T) = discard

  # undeclared identifier: 'unresolvedExpression'
  rem unresolvedExpression(undeclaredIdentifier)
  ```
{==+==}

  ```nim
  template rem(x: untyped) = discard
  proc rem[T](x: T) = discard

  # 未声明的标识符: 'unresolvedExpression'
  rem unresolvedExpression(undeclaredIdentifier)
  ```
{==+==}

{==+==}
`untyped` and `varargs[untyped]` are the only metatype that are lazy in this sense, the other
metatypes `typed` and `typedesc` are not lazy.
{==+==}
`untyped` 和 `varargs[untyped]` 是唯一在这个意义上是惰性的元类型，其他元类型 `typed` 和 `typedesc` 不是惰性的。
{==+==}

{==+==}
Varargs matching
----------------
{==+==}
可变参数匹配
----------------
{==+==}

{==+==}
See `Varargs <#types-varargs>`_.
{==+==}
参阅`Varargs <#types-varargs>`_.
{==+==}

{==+==}
iterable
--------
{==+==}
迭代器
{==+==}

{==+==}
iterable
--------
{==+==}
迭代器
{==+==}

{==+==}
A called `iterator` yielding type `T` can be passed to a template or macro via
a parameter typed as `untyped` (for unresolved expressions) or the type class
`iterable` or `iterable[T]` (after type checking and overload resolution).
{==+==}
yielding类型`T`的迭代器可以通过类型为“untyped”（用于未解析的表达式）或类型类“iterable”或“iterable[T]”（在类型检查和重载解析之后）的参数传递给模板或宏。
{==+==}

{==+==}
  ```nim
  iterator iota(n: int): int =
    for i in 0..<n: yield i

  template toSeq2[T](a: iterable[T]): seq[T] =
    var ret: seq[T]
    assert a.typeof is T
    for ai in a: ret.add ai
    ret

  assert iota(3).toSeq2 == @[0, 1, 2]
  assert toSeq2(5..7) == @[5, 6, 7]
  assert not compiles(toSeq2(@[1,2])) # seq[int] is not an iterable
  assert toSeq2(items(@[1,2])) == @[1, 2] # but items(@[1,2]) is
  ```
{==+==}
  ```nim
  iterator iota(n: int): int =
    for i in 0..<n: yield i

  template toSeq2[T](a: iterable[T]): seq[T] =
    var ret: seq[T]
    assert a.typeof is T
    for ai in a: ret.add ai
    ret

  assert iota(3).toSeq2 == @[0, 1, 2]
  assert toSeq2(5..7) == @[5, 6, 7]
  assert not compiles(toSeq2(@[1,2])) # seq[int] is not an iterable
  assert toSeq2(items(@[1,2])) == @[1, 2] # but items(@[1,2]) is
  ```
{==+==}

{==+==}
  ```nim
  iterator iota(n: int): int =
    for i in 0..<n: yield i

  template toSeq2[T](a: iterable[T]): seq[T] =
    var ret: seq[T]
    assert a.typeof is T
    for ai in a: ret.add ai
    ret

  assert iota(3).toSeq2 == @[0, 1, 2]
  assert toSeq2(5..7) == @[5, 6, 7]
  assert not compiles(toSeq2(@[1,2])) # seq[int] is not an iterable
  assert toSeq2(items(@[1,2])) == @[1, 2] # but items(@[1,2]) is
  ```
{==+==}
  ```nim
  iterator iota(n: int): int =
    for i in 0..<n: yield i

  template toSeq2[T](a: iterable[T]): seq[T] =
    var ret: seq[T]
    assert a.typeof is T
    for ai in a: ret.add ai
    ret

  assert iota(3).toSeq2 == @[0, 1, 2]
  assert toSeq2(5..7) == @[5, 6, 7]
  assert not compiles(toSeq2(@[1,2])) # seq[int] is not an iterable
  assert toSeq2(items(@[1,2])) == @[1, 2] # but items(@[1,2]) is
  ```
{==+==}

{==+==}
Overload disambiguation
=======================
{==+==}
重载disambiguation
=======================
{==+==}

{==+==}
For routine calls "overload resolution" is performed. There is a weaker form of
overload resolution called *overload disambiguation* that is performed when an
overloaded symbol is used in a context where there is additional type information
available. Let `p` be an overloaded symbol. These contexts are:
{==+==}
对于例程调用，执行“重载解决方案”。 有一种称为 *overload disambiguation* 的较弱形式的重载解析，当重载符号用于有附加类型信息可用的上下文中时执行。 让 `p` 成为重载符号。 这些上下文是：
{==+==}

{==+==}
- In a function call `q(..., p, ...)` when the corresponding formal parameter
  of `q` is a `proc` type. If `q` itself is overloaded then the cartesian product
  of every interpretation of `q` and `p` must be considered.
- In an object constructor `Obj(..., field: p, ...)` when `field` is a `proc`
  type. Analogous rules exist for array/set/tuple constructors.
- In a declaration like `x: T = p` when `T` is a `proc` type.
{==+==}
当 `q` 的相应形式参数是 `proc` 类型时，在函数调用 `q(..., p, ...)` 中。 如果 `q` 本身被重载，则必须考虑 `q` 和 `p` 的每种解释的笛卡尔积。
{==+==}

{==+==}
As usual, ambiguous matches produce a compile-time error.
{==+==}
通常情况下，有歧义的匹配会产生编译错误。
{==+==}

{==+==}
Named argument overloading
--------------------------
{==+==}
命名参数重载
{==+==}

{==+==}
Routines with the same type signature can be called individually if
a parameter has different names between them.
{==+==}
具有相同类型签名的例程可以单独调用，如果参数在它们之间具有不同的名称。
{==+==}

{==+==}
  ```Nim
  proc foo(x: int) =
    echo "Using x: ", x
  proc foo(y: int) =
    echo "Using y: ", y

  foo(x = 2) # Using x: 2
  foo(y = 2) # Using y: 2
  ```
{==+==}
  ```Nim
  proc foo(x: int) =
    echo "Using x: ", x
  proc foo(y: int) =
    echo "Using y: ", y

  foo(x = 2) # Using x: 2
  foo(y = 2) # Using y: 2
  ```
{==+==}

{==+==}
Not supplying the parameter name in such cases results in an
ambiguity error.
{==+==}
在这种情况下不提供参数名称会导致歧义错误。
{==+==}

{==+==}
Statements and expressions
==========================
{==+==}
语句和表达式
==========================
{==+==}

{==+==}
Nim uses the common statement/expression paradigm: Statements do not
produce a value in contrast to expressions. However, some expressions are
statements.
{==+==}
Nim 使用通用语句/表达式范例：与表达式相比，语句不产生值。 但是，有些表达式是语句。
{==+==}

{==+==}
Statements are separated into `simple statements`:idx: and
`complex statements`:idx:.
Simple statements are statements that cannot contain other statements like
assignments, calls, or the `return` statement; complex statements can
contain other statements. To avoid the `dangling else problem`:idx:, complex
statements always have to be indented. The details can be found in the grammar.
{==+==}
语句被分成 `简单语句`:idx:和`复杂语句`:idx:。就按单语句是不能包含其他语句的语句，如赋值、调用或 `return` 语句； 复杂语句可以包含其他语句。 为了避免 `悬空别的问题`，复杂的语句总是必须缩进。 细节可以在语法中找到。
{==+==}

{==+==}
Statement list expression
-------------------------
{==+==}
语句列表表达式
-------------------------
{==+==}

{==+==}
Statements can also occur in an expression context that looks
like `(stmt1; stmt2; ...; ex)`. This is called
a statement list expression or `(;)`. The type
of `(stmt1; stmt2; ...; ex)` is the type of `ex`. All the other statements
must be of type `void`. (One can use `discard` to produce a `void` type.)
`(;)` does not introduce a new scope.
{==+==}
语句也可以出现在看起来像`(stmt1; stmt2; ...; ex)`。 这称为语句列表表达式或`(;)`。 `(stmt1; stmt2; ...; ex)` 的类型是 `ex` 的类型。 所有其他语句必须是 `void` 类型。 （可以使用 `discard` 来生成 `void` 类型。）`(;)` 不会引入新的范围。
{==+==}

{==+==}
Discard statement
-----------------
{==+==}
Discard语句
{==+==}

{==+==}
Example:
{==+==}
示例：
{==+==}

{==+==}
  ```nim
  proc p(x, y: int): int =
    result = x + y

  discard p(3, 4) # discard the return value of `p`
  ```
{==+==}
```nim
  proc p(x, y: int): int =
    result = x + y

  discard p(3, 4) # 丢弃`p`的返回值
  ```
{==+==}

{==+==}
The `discard` statement evaluates its expression for side-effects and
throws the expression's resulting value away, and should only be used
when ignoring this value is known not to cause problems.
{==+==}
`discard` 语句评估其表达式的副作用并将表达式的结果值丢弃，并且只应在已知忽略此值不会导致问题时使用。
{==+==}

{==+==}
Ignoring the return value of a procedure without using a discard statement is
a static error.
{==+==}
忽略过程的返回值而不使用丢弃语句是静态错误。
{==+==}

{==+==}
The return value can be ignored implicitly if the called proc/iterator has
been declared with the `discardable`:idx: pragma:
{==+==}
如果调用的 proc/iterator 已使用 `discardable`:idx:编译指示声明，则可以隐式忽略返回值：
{==+==}

{==+==}
  ```nim
  proc p(x, y: int): int {.discardable.} =
    result = x + y

  p(3, 4) # now valid
  ```
{==+==}
  ```nim
  proc p(x, y: int): int {.discardable.} =
    result = x + y

  p(3, 4) # 现在有效
  ```
{==+==}

{==+==}
however the discardable pragma does not work on templates as templates substitute the AST in place. For example:
{==+==}
但是可丢弃的编译指示不适用于模板，因为模板替代了 AST。 例如：
{==+==}

{==+==}
  ```nim
  {.push discardable .}
  template example(): string = "https://nim-lang.org"
  {.pop.}

  example()
  ```
{==+==}
  ```nim
  {.push discardable .}
  template example(): string = "https://nim-lang.org"
  {.pop.}

  example()
  ```
{==+==}

{==+==}
This template will resolve into "https://nim-lang.org" which is a string literal and since {.discardable.} doesn't apply to literals, the compiler will error.
{==+==}
此模板将解析为字符串文字“https://nim-lang.org”，但由于 {.discardable.} 不适用于文字，编译器会出错。
{==+==}

{==+==}
An empty `discard` statement is often used as a null statement:
{==+==}
空的`discard`语句通常用于一个空的语句中
{==+==}

{==+==}
  ```nim
  proc classify(s: string) =
    case s[0]
    of SymChars, '_': echo "an identifier"
    of '0'..'9': echo "a number"
    else: discard
  ```
{==+==}
  ```nim
  proc classify(s: string) =
    case s[0]
    of SymChars, '_': echo "an identifier"
    of '0'..'9': echo "a number"
    else: discard
  ```
{==+==}

{==+==}
Void context
------------
{==+==}
空下上文
------------
{==+==}

{==+==}
In a list of statements, every expression except the last one needs to have the
type `void`. In addition to this rule an assignment to the builtin `result`
symbol also triggers a mandatory `void` context for the subsequent expressions:
{==+==}
在语句列表中，除最后一个之外的每个表达式都需要具有“void”类型。 除了这条规则之外，对内置 `result` 符号的赋值还会触发后续表达式的强制 `void` 上下文：
{==+==}

{==+==}
  ```nim
  proc invalid*(): string =
    result = "foo"
    "invalid"  # Error: value of type 'string' has to be discarded
  ```
{==+==}
  ```nim
  proc invalid*(): string =
    result = "foo"
    "invalid"  # 错误: 类型`string`的值必须被抛弃
  ```
{==+==}

{==+==}
  ```nim
  proc valid*(): string =
    let x = 317
    "valid"
  ```
{==+==}
  ```nim
  proc valid*(): string =
    let x = 317
    "valid"
  ```
{==+==}

{==+==}
  ```nim
  proc valid*(): string =
    let x = 317
    "valid"
  ```
{==+==}
  ```nim
  proc valid*(): string =
    let x = 317
    "valid"
  ```
{==+==}

{==+==}
Var statement
-------------
{==+==}
Var语句
-------------
{==+==}

{==+==}
Var statements declare new local and global variables and
initialize them. A comma-separated list of variables can be used to specify
variables of the same type:
{==+==}
Var 语句声明新的局部和全局变量并初始化它们。 逗号分隔的变量列表可用于指定相同类型的变量：
{==+==}

{==+==}
  ```nim
  var
    a: int = 0
    x, y, z: int
  ```
{==+==}
  ```nim
  var
    a: int = 0
    x, y, z: int
  ```
{==+==}

{==+==}
If an initializer is given, the type can be omitted: the variable is then of the
same type as the initializing expression. Variables are always initialized
with a default value if there is no initializing expression. The default
value depends on the type and is always a zero in binary.
{==+==}
如果给定了初始化器，则可以省略类型：变量的类型与初始化表达式的类型相同。 如果没有初始化表达式，则始终使用默认值初始化变量。 默认值取决于类型，并且在二进制中始终为零。
{==+==}

{==+==}
============================    ==============================================
Type                            default value
============================    ==============================================
any integer type                0
any float                       0.0
char                            '\\0'
bool                            false
ref or pointer type             nil
procedural type                 nil
sequence                        `@[]`
string                          `""`
tuple[x: A, y: B, ...]          (default(A), default(B), ...)
                                (analogous for objects)
array[0..., T]                  [default(T), ...]
range[T]                        default(T); this may be out of the valid range
T = enum                        cast[T]\(0); this may be an invalid value
============================    ==============================================

{==+==}
============================    ==============================================
Type                            default value
============================    ==============================================
any integer type                0
any float                       0.0
char                            '\\0'
bool                            false
ref or pointer type             nil
procedural type                 nil
sequence                        `@[]`
string                          `""`
tuple[x: A, y: B, ...]          (default(A), default(B), ...)
                                (analogous for objects)
array[0..., T]                  [default(T), ...]
range[T]                        default(T); 这个可能会超出有效范围
T = enum                        cast[T]\(0); 这个可能是一个非法值
============================    ==============================================
{==+==}

{==+==}
The implicit initialization can be avoided for optimization reasons with the
`noinit`:idx: pragma:
{==+==}
出于优化原因，可以使用`noinit`:idx:编译指示来避免隐式初始化：
{==+==}

{==+==}
  ```nim
  var
    a {.noinit.}: array[0..1023, char]
  ```
{==+==}
  ```nim
  var
    a {.noinit.}: array[0..1023, char]
  ```
{==+==}

{==+==}
If a proc is annotated with the `noinit` pragma, this refers to its implicit
`result` variable:
{==+==}
如果proc使用`noinit`编译指示，这指的是其隐式`result`变量：
{==+==}

{==+==}
  ```nim
  proc returnUndefinedValue: int {.noinit.} = discard
  ```
{==+==}
  ```nim
  proc returnUndefinedValue: int {.noinit.} = discard
  ```
{==+==}

{==+==}
The implicit initialization can also be prevented by the `requiresInit`:idx:
type pragma. The compiler requires an explicit initialization for the object
and all of its fields. However, it does a `control flow analysis`:idx: to prove
the variable has been initialized and does not rely on syntactic properties:
{==+==}
`requiresInit`:idx:类型编译指示也可以防止隐式初始化。编译器需要对对象及其所有字段进行显式初始化。但是，它会进行“控制流分析”:idx:以证明变量已被初始化并且不依赖于句法属性：
{==+==}

{==+==}
  ```nim
  type
    MyObject = object {.requiresInit.}

  proc p() =
    # the following is valid:
    var x: MyObject
    if someCondition():
      x = a()
    else:
      x = a()
    # use x
  ```
{==+==}
  ```nim
  type
    MyObject = object {.requiresInit.}

  proc p() =
    # 下方有效:
    var x: MyObject
    if someCondition():
      x = a()
    else:
      x = a()
    # 使用x
  ```
{==+==}

{==+==}
`requiresInit` pragma can also be applied to `distinct` types.
{==+==}
`requiresInit`编译指示也可以应用于 `distinct` 类型。
{==+==}

{==+==}
Given the following distinct type definitions:
{==+==}
给定以下不同的类型定义：
{==+==}

{==+==}
  ```nim
  type
    Foo = object
      x: string

    DistinctFoo {.requiresInit, borrow: `.`.} = distinct Foo
    DistinctString {.requiresInit.} = distinct string
  ```
{==+==}
  ```nim
  type
    Foo = object
      x: string

    DistinctFoo {.requiresInit, borrow: `.`.} = distinct Foo
    DistinctString {.requiresInit.} = distinct string
  ```
{==+==}

{==+==}
The following code blocks will fail to compile:
{==+==}
下列代码块将会编译失败：
{==+==}

{==+==}
  ```nim
  var foo: DistinctFoo
  foo.x = "test"
  doAssert foo.x == "test"
  ```

  ```nim
  var s: DistinctString
  s = "test"
  doAssert string(s) == "test"
  ```
{==+==}
  ```nim
  var foo: DistinctFoo
  foo.x = "test"
  doAssert foo.x == "test"
  ```

  ```nim
  var s: DistinctString
  s = "test"
  doAssert string(s) == "test"
  ```
{==+==}

{==+==}
But these will compile successfully:
{==+==}
但这些将会编译成功：
{==+==}

{==+==}
  ```nim
  let foo = DistinctFoo(Foo(x: "test"))
  doAssert foo.x == "test"
  ```
{==+==}
  ```nim
  let foo = DistinctFoo(Foo(x: "test"))
  doAssert foo.x == "test"
  ```
{==+==}

{==+==}
  ```nim
  let s = DistinctString("test")
  doAssert string(s) == "test"
  ```
{==+==}
  ```nim
  let s = DistinctString("test")
  doAssert string(s) == "test"
  ```
{==+==}

{==+==}
Let statement
-------------
{==+==}
Let语句
-------------
{==+==}

{==+==}
A `let` statement declares new local and global `single assignment`:idx:
variables and binds a value to them. The syntax is the same as that of the `var`
statement, except that the keyword `var` is replaced by the keyword `let`.
Let variables are not l-values and can thus not be passed to `var` parameters
nor can their address be taken. They cannot be assigned new values.
{==+==}
`let` 语句声明了新的局部和全局“单一赋值”:idx:变量并将值绑定到它们。语法与`var`语句的语法相同，只是关键字`var`被关键字`let`替换。let变量不是左值，因此不能传递给`var`参数也不能获取他们的地址。不能为它们分配新值。
{==+==}

{==+==}
For let variables, the same pragmas are available as for ordinary variables.
{==+==}
对于 let 变量，可以使用与普通变量相同的编译指示。
{==+==}

{==+==}
As `let` statements are immutable after creation they need to define a value
when they are declared. The only exception to this is if the `{.importc.}`
pragma (or any of the other `importX` pragmas) is applied, in this case the
value is expected to come from native code, typically a C/C++ `const`.
{==+==}
由于 `let` 语句在创建后是不可变的，因此它们需要在声明时定义一个值。 唯一的例外是如果应用了 `{.importc.}` 编译指示（或任何其他 `importX` 编译指示），在这种情况下，值应该来自本机代码，通常是 C/C++ `const `。
{==+==}

{==+==}
Tuple unpacking
---------------
{==+==}
元组解包
---------------
{==+==}

{==+==}
In a `var` or `let` statement tuple unpacking can be performed. The special
identifier `_` can be used to ignore some parts of the tuple:
{==+==}
在 `var` 或 `let` 语句中可以执行元组解包。 特殊标识符 `_` 可用于忽略元组的某些部分：
{==+==}

{==+==}
  ```nim
  proc returnsTuple(): (int, int, int) = (4, 2, 3)

  let (x, _, z) = returnsTuple()
  ```
{==+==}
  ```nim
  proc returnsTuple(): (int, int, int) = (4, 2, 3)

  let (x, _, z) = returnsTuple()
  ```
{==+==}

{==+==}
Const section
-------------
{==+==}
常量域
-------------
{==+==}

{==+==}
A const section declares constants whose values are constant expressions:
{==+==}
常量域声明其值为常量表达式的常量
{==+==}

{==+==}
  ```nim
  import std/[strutils]
  const
    roundPi = 3.1415
    constEval = contains("abc", 'b') # computed at compile time!
  ```
{==+==}
  ```nim
  import std/[strutils]
  const
    roundPi = 3.1415
    constEval = contains("abc", 'b') # 在编译时计算
  ```
{==+==}

{==+==}
Once declared, a constant's symbol can be used as a constant expression.
{==+==}
一旦声明，常量的符号就可以用作常量表达式
{==+==}


{==+==}
See `Constants and Constant Expressions <#constants-and-constant-expressions>`_
for details.
{==+==}
参阅`Constants and Constant Expressions <#constants-and-constant-expressions>`_以获取详情
{==+==}

{==+==}
Static statement/expression
---------------------------
{==+==}
静态语句/表达式
{==+==}

{==+==}
A static statement/expression explicitly requires compile-time execution.
Even some code that has side effects is permitted in a static block:
{==+==}
静态语句/表达式明确需要编译时执行。 甚至在静态块中也允许一些具有副作用的代码：
{==+==}

{==+==}
  ```nim
  static:
    echo "echo at compile time"
  ```
{==+==}
  ```nim
  static:
    echo "echo at compile time"
  ```
{==+==}

{==+==}
`static` can also be used like a routine.
{==+==}
`static` 也可以像例程一样使用。
{==+==}

{==+==}
  ```nim
  proc getNum(a: int): int = a

  # Below calls "echo getNum(123)" at compile time.
  static:
    echo getNum(123)

  # Below call evaluates the "getNum(123)" at compile time, but its
  # result gets used at run time.
  echo static(getNum(123))
  ```
{==+==}
  ```nim
  proc getNum(a: int): int = a

  # 下列调用"echo getNum(123)"是在编译时
  static:
    echo getNum(123)

  # 下面的调用在编译时计算“getNum(123)”，但其结果在运行时使用。
  echo static(getNum(123))
  ```
{==+==}

{==+==}
There are limitations on what Nim code can be executed at compile time;
see `Restrictions on Compile-Time Execution
<#restrictions-on-compileminustime-execution>`_ for details.
It's a static error if the compiler cannot execute the block at compile
time.
{==+==}
在编译时可以执行哪些 Nim 代码是有限制的；详情参阅`Restrictions on Compile-Time Execution<#restrictions-on-compileminustime-execution>`。如果编译器无法在编译时执行该块，则这是一个静态错误。
{==+==}

{==+==}
If statement
------------
{==+==}
If语句
------------
{==+==}

{==+==}
Example:
{==+==}
示例：
{==+==}

{==+==}

  ```nim
  var name = readLine(stdin)

  if name == "Andreas":
    echo "What a nice name!"
  elif name == "":
    echo "Don't you have a name?"
  else:
    echo "Boring name..."
  ```

{==+==}

  ```nim
  var name = readLine(stdin)

  if name == "Andreas":
    echo "What a nice name!"
  elif name == "":
    echo "Don't you have a name?"
  else:
    echo "Boring name..."
  ```

{==+==}

{==+==}
The `if` statement is a simple way to make a branch in the control flow:
The expression after the keyword `if` is evaluated, if it is true
the corresponding statements after the `:` are executed. Otherwise,
the expression after the `elif` is evaluated (if there is an
`elif` branch), if it is true the corresponding statements after
the `:` are executed. This goes on until the last `elif`. If all
conditions fail, the `else` part is executed. If there is no `else`
part, execution continues with the next statement.
{==+==}
`if` 语句是在控制流中创建分支的一种简单方法：计算关键字 `if` 后的表达式，如果为真，则执行 `:` 后的相应语句。 否则，计算 `elif` 之后的表达式（如果有 `elif` 分支），如果为真，则执行 `:` 之后的相应语句。 这一直持续到最后一个 `elif`。 如果所有条件都失败，则执行 `else` 部分。 如果没有 `else` 部分，则继续执行下一条语句。
{==+==}

{==+==}
In `if` statements, new scopes begin immediately after
the `if`/`elif`/`else` keywords and ends after the
corresponding *then* block.
For visualization purposes the scopes have been enclosed
in `{|  |}` in the following example:
{==+==}
在 `if` 语句中，新的作用域在 `if`/`elif`/`else` 关键字之后立即开始，并在相应的 *then* 块之后结束。 出于可视化目的，范围已包含在 `{| |}` 在以下示例中：
{==+==}


{==+==}
```nim
  if {| (let m = input =~ re"(\w+)=\w+"; m.isMatch):
    echo "key ", m[0], " value ", m[1]  |}
  elif {| (let m = input =~ re""; m.isMatch):
    echo "new m in this scope"  |}
  else: {|
    echo "m not declared here"  |}
  ```
{==+==}
```nim
  if {| (let m = input =~ re"(\w+)=\w+"; m.isMatch):
    echo "key ", m[0], " value ", m[1]  |}
  elif {| (let m = input =~ re""; m.isMatch):
    echo "new m in this scope"  |}
  else: {|
    echo "m not declared here"  |}
  ```
{==+==}