{====}
**Note**: The experimental features of Nim are
covered [here](manual_experimental.html).
{====}
**注意**: Nim的实现性功能在[这里](manual_experimental.html)。
{====} 

{====}
**Note**: Assignments, moves, and destruction are specified in
the [destructors](destructors.html) document.
{====}
**注意**: 赋值、移动和析构在特定的[析构](destructors.html)文档。
{====}

{====}
To learn how to compile Nim programs and generate documentation see
the [Compiler User Guide](nimc.html) and the [DocGen Tools Guide](docgen.html).
{====}
打算学习怎样编译Nim程序和生成文档，请阅读[用户编译指南](nimc.html)和[文档生成工具指南](docgen.html)。
{====}

{====}
In a typical Nim program, most of the code is compiled into the executable.
However, some code may be executed at
`compile-time`:idx:. This can include constant expressions, macro definitions,
and Nim procedures used by macro definitions. Most of the Nim language is
supported at compile-time, but there are some restrictions -- see [Restrictions
on Compile-Time Execution] for
details. We use the term `runtime`:idx: to cover both compile-time execution
and code execution in the executable.
{====}
常规的Nim程序，大部分代码被编译至可执行文件，而有些代码可能会在 `compile-time`:idx: "编译期" 执行。包括常量表达式、宏定义和宏定义使用的Nim程序。编译期执行支持Nim语言的大部分，但有限制 -- 详情查看[编译期执行限制]。其术语`runtime`:idx: "运行时"涵盖了编译期执行和可执行文件中的代码执行。
{====}

{====}
A `panic`:idx: is an error that the implementation detects
and reports at runtime. The method for reporting such errors is via
*raising exceptions* or *dying with a fatal error*. However, the implementation
provides a means to disable these `runtime checks`:idx:. See the section
[Pragmas] for details.
{====}
`panic`:idx: "恐慌"是在运行时执行检测和报告的错误。报告这种错误是通过 *引发异常* 或 *以致命错误* 结束的方式。也提供了一种方法来禁用这些 `runtime checks`:idx: "运行时检查"。详见[编译指示]一节。
{====}

{====}
The `Rune` type can represent any Unicode character.
`Rune` is declared in the [unicode module](unicode.html).
{====}
`Rune` 类型可以代表任何Unicode字符。
`Rune` 声明在[unicode模块](unicode.html)中。
{====}

{====}
See also [custom numeric literals].
{====}
参阅[自定义数值字面量]。
{====}

{====}
This section lists Nim's standard syntax. How the parser handles
the indentation is already described in the [Lexical Analysis] section.
{====}
本节列出了Nim的标准语法。语法分析器如何处理缩进问题，在[词法分析]一节有说明。
{====}

{====}
  ```nim
  echo(1, 2) # pass 1 and 2 to echo
  ```
{====}
  ```nim
  echo(1, 2) # 把 1 和 2 传递给 echo
  ```
{====}

{====}
  ```nim
  echo (1, 2) # pass the tuple (1, 2) to echo
  ```
{====}
  ```nim
  echo (1, 2) # 把 tuple (1, 2) 传递给 echo
  ```
{====}

{====}
`int`
: the generic signed integer type; its size is platform-dependent and has the
  same size as a pointer. This type should be used in general. An integer
  literal that has no type suffix is of this type if it is in the range
  `low(int32)..high(int32)` otherwise the literal's type is `int64`.
{====}
`int`
: 常规有符号整数类型，其大小与平台有关，并与指针的大小相同。一般情况下应该使用这种类型。一个没有类型后缀的整数字面量，如果在 `low(int32)..high(int32)` 范围内，就属于这种类型，否则该字面量的类型是 `int64` 。
{====}

{====}
`int`\ XX
: additional signed integer types of XX bits use this naming scheme
  (example: int16 is a 16-bit wide integer).
  The current implementation supports `int8`, `int16`, `int32`, `int64`.
  Literals of these types have the suffix 'iXX.
{====}
`int`\ XX
: 这种命名规则，是有符号整数类型附带XX表示位宽(例如：int16是16位宽的整数)。目前支持 `int8`, `int16`, `int32`, `int64` ，这些类型的字面值后缀为 'iXX 。
{====}

{====}
`uint`
: the generic `unsigned integer`:idx: type; its size is platform-dependent and
  has the same size as a pointer. An integer literal with the type
  suffix `'u` is of this type.
{====}
`uint`
: 常规的 `unsigned integer`:idx: "无符号整数"类型，它的大小与平台有关，与指针的大小相同，整数字面值后缀为 `'u` 。
{====}

{====}
`uint`\ XX
: additional unsigned integer types of XX bits use this naming scheme
  (example: uint16 is a 16-bit wide unsigned integer).
  The current implementation supports `uint8`, `uint16`, `uint32`,
  `uint64`. Literals of these types have the suffix 'uXX.
  Unsigned operations all wrap around; they cannot lead to over- or
  underflow errors.
{====}
`uint`\ XX
: 这种命名规则，是无符号整数类型附带XX，表示位宽(例如：uint16是16位宽的无符号整数)，目前支持 `uint8`, `uint16`, `uint32`, `uint64` ，字面值后缀为'uXX'。无符号运算会环绕，从面不会导致溢出或下溢的错误。
{====}

{====}
For further details, see [Convertible relation].
{====}
关于细节查看[转换关系]。
{====}

{====}
`float`
: the generic floating-point type; its size used to be platform-dependent,
  but now it is always mapped to `float64`.
  This type should be used in general.
{====}
`float`
: 常规的浮点类型，其大小曾与平台有关，但现在总是被映射为 `float64` 。一般情况下应该使用这个类型。
{====}

{====}
`float`\ XX
: an implementation may define additional floating-point types of XX bits using
  this naming scheme (example: `float64` is a 64-bit wide float). The current
  implementation supports `float32` and `float64`. Literals of these types
  have the suffix 'fXX.
{====}
`float`\ XX
: 这种命名规则，是浮点类型附带XX位，表示位宽(例如： `float64` 是64位宽的浮点数)。目前支持 `float32` 和 `float64` ，字面值后缀为 'fXX 。
{====}

{====}
Automatic type conversion in expressions with different kinds of floating-point
types is performed: See [Convertible relation] for further details. Arithmetic
performed on floating-point types follows the IEEE standard. Integer types are
not converted to floating-point types automatically and vice versa.
{====}
在具有不同种类的浮点类型的表达式中，会进行自动类型转换，详情见[转换关系]。对于浮点类型进行的算术运算遵循IEEE标准。整数类型不会自动转换为浮点类型，反之亦然。
{====}

{====}
The `Rune` type is used for Unicode characters, it can represent any Unicode
character. `Rune` is declared in the [unicode module](unicode.html).
{====}
`Rune` 类型声明在[unicode模块](unicode.html)中，可以表示任意Unicode字符。
{====}

{====}
Enum value names are overloadable, much like routines. If both of the enums
`T` and `U` have a member named `foo`, then the identifier `foo` corresponds
to a choice between `T.foo` and `U.foo`. During overload resolution,
the correct type of `foo` is decided from the context. If the type of `foo` is
ambiguous, a static error will be produced.
{====}
枚举值的名称是可重载的，就像例程。如果枚举 `T` 和 `U` 都有一个名为 `foo` 的成员，那么标识符 `foo` 要在 `T.foo` 和 `U.foo` 之间二选一。在重载解析过程中， `foo` 的最终类型由上下文决定。如果 `foo` 的类型不明确，将产生静态错误。
{====}

{====}
  ```nim  test = "nim c $1"

  type
    E1 = enum
      value1,
      value2
    E2 = enum
      value1,
      value2 = 4

  const
    Lookuptable = [
      E1.value1: "1",
      # no need to qualify value2, known to be E1.value2
      value2: "2"
    ]

  proc p(e: E1) =
    # disambiguation in 'case' statements:
    case e
    of value1: echo "A"
    of value2: echo "B"

  p value2
  ```
{====}
  ```nim  test = "nim c $1"

  type
    E1 = enum
      value1,
      value2
    E2 = enum
      value1,
      value2 = 4

  const
    Lookuptable = [
      E1.value1: "1",
      # 不需要再修饰value2，已经知道是E1.value2。
      value2: "2"
    ]

  proc p(e: E1) =
    # 在 'case' 语句中消除歧义。
    case e
    of value1: echo "A"
    of value2: echo "B"

  p value2
  ```
{====}

{====}
To implement bit fields with enums see [Bit fields].
{====}
对于用枚举实现位域，请查看[位域]部分。
{====}

{====}
Per convention, all strings are UTF-8 strings, but this is not enforced. For
example, when reading strings from binary files, they are merely a sequence of
bytes. The index operation `s[i]` means the i-th *char* of `s`, not the
i-th *unichar*. The iterator `runes` from the [unicode module](unicode.html)
can be used for iteration over all Unicode characters.
{====}
按照约定，所有字符串都是UTF-8格式，但这不是强制的要求。例如，从二进制文件读取字符串时，得到的将是字节序列。索引运算 `s[i]` 表示 `s` 的第i个*char*，而不是第i个 *unichar* 。在[unicode模块](unicode.html)的迭代器 `runes` 可用来迭代所有unicode字符。 
{====}

{====}
`cstring` values may also be used in case statements like strings.
{====}
`cstring` 值像字符串一样，也可用于case语句。
{====}


{====}
The assignment operator for tuples and objects copies each component.
The methods to override this copying behavior are described [here][type
bound operators].
{====}
对于元组和对象的赋值操作，将拷贝每个组件。
重写这种拷贝行为的方法描述在[这里][类型绑定操作符]。
{====}

{====}
Automatic dereferencing can be performed for the first argument of a routine
call, but this is an experimental feature and is described [here](
manual_experimental.html#automatic-dereferencing).
{====}
可以对例程调用的第一个参数进行自动去引用，但这是一个实验性功能，描述在[这里](manual_experimental.html#automatic-dereferencing)。
{====}

{====}
To allocate a new traced object, the built-in procedure `new` has to be used.
To deal with untraced memory, the procedures `alloc`, `dealloc` and
`realloc` can be used. The documentation of the [system](system.html) module
contains further information.
{====}
要分配一个新的追踪对象，必须使用内置的过程 `new` 。可以使用过程 `alloc` ， `dealloc` 和 `realloc` 来处理未追踪的内存。更多信息，查看[系统](system.html)模块文档。
{====}

{====}
`nimcall`:idx:
:   is the default convention used for a Nim **proc**. It is the
    same as `fastcall`, but only for C compilers that support `fastcall`.
{====}
`nimcall`:idx:
:   是Nim **proc** 使用的默认约定。它与 `fastcall` 相同，但只适用于支持 `fastcall` 的C编译器。
{====}

{====}
`closure`:idx:
:   is the default calling convention for a **procedural type** that lacks
    any pragma annotations. It indicates that the procedure has a hidden
    implicit parameter (an *environment*). Proc vars that have the calling
    convention `closure` take up two machine words: One for the proc pointer
    and another one for the pointer to implicitly passed environment.
{====}
`closure`:idx:
:   是 **程序类型** 没有任意编译指示注解的默认调用约定，该过程有一个隐藏参数( *environment* "环境")。具有 `closure` 调用约定的过程变体占用两个机器字。一个是过程的指针，另一个是指向隐藏参数环境的指针。
{====}

{====}
`stdcall`:idx:
:   This is the stdcall convention as specified by Microsoft. The generated C
    procedure is declared with the `__stdcall` keyword.
{====}
`stdcall`:idx:
:   这是由微软指定的标准调用惯例，生成的C过程将用 `__stdcall` 关键字声明。
{====}

{====}
`cdecl`:idx:
:   The cdecl convention means that a procedure shall use the same convention
    as the C compiler. Under Windows the generated C procedure is declared with
    the `__cdecl` keyword.
{====}
`cdecl`:idx:
:   其意味着一个过程应使用与C编译器相同的约定。在Windows中，将用 `__cdecl` 关键字声明生成的C过程。
{====}

{====}
`safecall`:idx:
:   This is the safecall convention as specified by Microsoft. The generated C
    procedure is declared with the `__safecall` keyword. The word *safe*
    refers to the fact that all hardware registers shall be pushed to the
    hardware stack.
{====}
`safecall`:idx:
:   这是由微软指定的安全调用约定，将用 `__safecall` 关键字声明生成的C程序。 *安全* 这个词是指所有的硬件寄存器都应被push到硬件堆栈中。
{====}

{====}
`inline`:idx:
:   The inline convention means the caller should not call the procedure,
    but inline its code directly. Note that Nim does not inline, but leaves
    this to the C compiler; it generates `__inline` procedures. This is
    only a hint for the compiler: it may completely ignore it, and
    it may inline procedures that are not marked as `inline`.
{====}
`inline`:idx:
:   内联约定表示调用者不应该调用过程，而是直接内联其代码。需注意，Nim自身并不内联，而是留给C编译器，它将生成 `__inline` 过程，这只是给编译器的提示，编译器则可能忽略，也可能内联那些没有 `inline` 的过程。
{====}

{====}
`fastcall`:idx:
:   Fastcall means different things to different C compilers. One gets whatever
    the C `__fastcall` means.
{====}
`fastcall`:idx:
:   对于不同的C编译器其含义不同，有一种是表示C语言中的 `__fastcall` 。
{====}

{====}
`thiscall`:idx:
:   This is the thiscall calling convention as specified by Microsoft, used on
    C++ class member functions on the x86 architecture.
{====}
`thiscall`:idx:
:   这是微软指定的调用约定，应用于x86架构上C++类的成员函数。
{====}

{====}
`syscall`:idx:
:   The syscall convention is the same as `__syscall`:c: in C. It is used for
    interrupts.
{====}
`syscall`:idx:
:   其与C语言中的 `__syscall`:c: 相同，用于中断。
{====}

{====}
`noconv`:idx:
:   The generated C code will not have any explicit calling convention and thus
    use the C compiler's default calling convention. This is needed because
    Nim's default calling convention for procedures is `fastcall` to
    improve speed.
{====}
`noconv`:idx:
:   其生成的C代码将不会去明确调用约定，将使用C编译器自身的默认调用约定。这是有必要的，因为Nim过程的默认调用约定是 `fastcall` 以提高速度。
{====}

{====}
But it seems all this boilerplate code needs to be repeated for the `Euro`
currency. This can be solved with [templates].
{====}
但是，`Euro` 货币似乎需要重复这些样式的代码，这个可以用[模板]来解决。
{====}

{====}
Now we have compile-time checking against SQL injection attacks. Since
`"".SQL` is transformed to `SQL("")` no new syntax is needed for nice
looking `SQL` string literals. The hypothetical `SQL` type actually
exists in the library as the [SqlQuery type](db_common.html#SqlQuery) of
modules like [db_sqlite](db_sqlite.html).
{====}
现在我们有了针对SQL注入攻击的编译期检查。由于 `"".SQL` 被转换为 `SQL("")` ，所以不需要新的语法来实现简洁的 `SQL` 字符串字面值。假设 `SQL` 类型与 [db_sqlite](db_sqlite.html) 等类似，已经作为 [SqlQuery type](db_common.html#SqlQuery) 实际存在与库中。
{====}

{====}
**Note**: One of the above pointer-indirections is required for assignment from
a subtype to its parent type to prevent "object slicing".
{====}
**注意**: 从子类型到父类型的赋值，需要上述指针注解之一，以防止 "对象切割" 。
{====}

{====}
See [Varargs].
{====}
参阅 [Varargs]。
{====}

{====}
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
`tuple[x: A, y: B, ...]`        (default(A), default(B), ...)
                                (analogous for objects)
`array[0..., T]`                `[default(T), ...]`
`range[T]`                      default(T); this may be out of the valid range
T = enum                        `cast[T](0)`; this may be an invalid value
============================    ==============================================
{====}
============================    ==========================================================
类型                            默认值
============================    ==========================================================
any integer type                0
any float                       0.0
char                            '\\0'
bool                            false
ref or pointer type             nil
procedural type                 nil
sequence                        `@[]`
string                          `""`
`tuple[x: A, y: B, ...]`        (default(A), default(B), ...)
                                (analogous for objects)
`array[0..., T]`                `[default(T), ...]`
`range[T]`                      default(T); 这可能会超出有效范围
T = enum                        `cast[T](0)`; 这可能是一个无效值
============================    ==========================================================
{====}

{====}
  ```nim
  type
    MyObject {.requiresInit.} = object

  proc p() =
    # the following is valid:
    var x: MyObject
    if someCondition():
      x = a()
    else:
      x = a()
    # use x
  ```
{====}
  ```nim
  type
    MyObject {.requiresInit.} = object

  proc p() =
    # 以下是有效的:
    var x: MyObject
    if someCondition():
      x = a()
    else:
      x = a()
    # 使用 x
  ```
{====}

{====}
See [Constants and Constant Expressions] for details.
{====}
详情参阅[常量和常量表达式]。
{====}

{====}
There are limitations on what Nim code can be executed at compile time;
see [Restrictions on Compile-Time Execution] for details.
It's a static error if the compiler cannot execute the block at compile
time.
{====}
对于哪些Nim代码可以在编译期执行，是有限制的，详情参阅[编译期执行限制]。如果编译器不能在编译期执行该块，将是一个静态错误。
{====}

{====}
Only ordinal types, floats, strings and cstrings are allowed as values
in case statements.
{====}
在case语句中，只允许使用序数类型、浮点数、字符串和cstring作为值。
{====}

{====}
The `yield` statement is used instead of the `return` statement in
iterators. It is only valid in iterators. Execution is returned to the body
of the for loop that called the iterator. Yield does not end the iteration
process, but the execution is passed back to the iterator if the next iteration
starts. See the section about iterators ([Iterators and the for statement])
for further information.
{====}
在迭代器中使用 `yield` 语句代替 `return` 语句。它只在迭代器中有效。执行将被返回到调用该迭代器的for循环的主体。Yield并不会结束迭代过程，当下一次迭代开始，执行会被传回迭代器。更多信息请参阅关于迭代器的章节([迭代器和for语句])。
{====}

{====}
[Limitations of the method call syntax].
{====}
[方法调用语法限制]。
{====}

{====}
The command invocation syntax also can't have complex expressions as arguments.
For example: [anonymous procedures], `if`,
`case` or `try`. Function calls with no arguments still need () to
distinguish between a call and the function itself as a first-class value.
{====}
命令调用的语法也不能有复杂的表达式作为参数。例如：[匿名过程]、`if`、`case`、`try`。没有参数的函数调用仍然需要 () 来区分调用和函数本身优先类的值。
{====}

{====}
Since closures capture local variables by reference it is often not wanted
behavior inside loop bodies. See [closureScope](
system.html#closureScope.t,untyped) and [capture](
sugar.html#capture.m,varargs[typed],untyped) for details on how to change this behavior.
{====}
由于闭包通过引用来捕获局部变量，这种行为往往在循环体内部并不友好。参阅 [closureScope](system.html#closureScope.t,untyped) 和 [capture](sugar.html#capture.m,varargs[typed],untyped) 来了解如何改变这种行为。
{====}

{====}
Procs as expressions can appear both as nested procs and inside top-level
executable code. The  [sugar](sugar.html) module contains the `=>` macro
which enables a more succinct syntax for anonymous procedures resembling
lambdas as they are in languages like JavaScript, C#, etc.
{====}
过程表达式既可以嵌套在过程中，也可以在上层可执行代码中。[sugar](sugar.html) 模块包含 `=>` 宏，它为匿名过程提供了更简洁的语法，类似于JavaScript、c#等语言中的lambda。
{====}

{====}
`do` is written after the parentheses enclosing the regular proc parameters.
The proc expression represented by the `do` block is appended to the routine
call as the last argument. In calls using the command syntax, the `do` block
will bind to the immediately preceding expression rather than the command call.
{====}
`do` 写在包含常规过程参数的圆括号之后。
由 `do` 块表示的过程表达式，将作为最后一个参数附加到例程调用。
在使用命令语法的调用中， `do` 块将绑定到前面紧靠的表达式，而不是命令调用。
{====}

{====}
  ```nim
  # Passing a statement list to an inline macro:
  macroResults.add quote do:
    if not `ex`:
      echo `info`, ": Check failed: ", `expString`

  # Processing a routine definition in a macro:
  rpc(router, "add") do (a, b: int) -> int:
    result = a + b
  ```
{====}
  ```nim
  # 将语句列表传递给内联宏:
  macroResults.add quote do:
    if not `ex`:
      echo `info`, ": Check failed: ", `expString`

  # 处理宏中的例程定义:
  rpc(router, "add") do (a, b: int) -> int:
    result = a + b
  ```
{====}

{====}
A type bound operator is a `proc` or `func` whose name starts with `=` but isn't an operator
(i.e. containing only symbols, such as `==`). These are unrelated to setters
(see [Properties]), which instead end in `=`.
A type bound operator declared for a type applies to the type regardless of whether
the operator is in scope (including if it is private).
{====}
类型绑定操作符是名称以 `=` 开头的 `proc` 或 `func` ，但不是运算符(即只是包含符号而矣，如 `==`)。它们与以 `=` 结尾的setter无关(参阅[属性])。为类型声明的类型绑定操作符，不论是否在作用域中(包括是否私有)，都将应用于该类型。
{====}

{====}
For more details on some of those procs, see
[Lifetime-tracking hooks](destructors.html#lifetimeminustracking-hooks).
{====}
想了解关于这些过程的更多细节，参阅[生命期追踪钩子](destructors.html#lifetimeminustracking-hooks)。
{====}

{====}
The following built-in procs cannot be overloaded for reasons of implementation
simplicity (they require specialized semantic checking)::

  declared, defined, definedInScope, compiles, sizeof,
  is, shallowCopy, getAst, astToStr, spawn, procCall
{====}
从实现简单性考虑(不需要专门的语义检查)，下面的内置过程不能重载::

  declared, defined, definedInScope, compiles, sizeof,
  is, shallowCopy, getAst, astToStr, spawn, procCall
{====}

{====}
Thus, they act more like keywords than like ordinary identifiers; unlike a
keyword however, a redefinition may `shadow`:idx: the definition in
the [system](system.html) module.
From this list the following should not be written in dot
notation `x.f` since `x` cannot be type-checked before it gets passed
to `f`::

  declared, defined, definedInScope, compiles, getAst, astToStr
{====}
因此，它们更像是关键字，而不是普通标识符，但与关键字不同的是，
重定义可能会 `shadow`:idx: "隐藏"[system](system.html)模块中的定义。
这个列表中的下列内容不应该使用点表示法 `x.f` 。
因为在 `x` 传递给 `f` 之前不能进行类型检查::

  declared, defined, definedInScope, compiles, getAst, astToStr
{====}

{====}
  ```nim  test = "nim c --multiMethods:on $1"
  type
    Thing = ref object of RootObj
    Unit = ref object of Thing
      x: int

  method collide(a, b: Thing) {.base, inline.} =
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
{====}
  ```nim  test = "nim c --multiMethods:on $1"
  type
    Thing = ref object of RootObj
    Unit = ref object of Thing
      x: int

  method collide(a, b: Thing) {.base, inline.} =
    quit "to override!"

  method collide(a: Thing, b: Unit) {.inline.} =
    echo "1"

  method collide(a: Unit, b: Thing) {.inline.} =
    echo "2"

  var a, b: Unit
  new a
  new b
  collide(a, b) # 输出: 2
  ```
{====}

{====}
See also [iterable] for passing iterators to templates and macros.
{====}
另请参阅[iterable]，将迭代器传递给模板和宏。
{====}

{====}
A converter is like an ordinary proc except that it enhances
the "implicitly convertible" type relation (see [Convertible relation]):
{====}
转换器和普通过程相似，但它增强了"隐式转换"类型的关系，参阅[转换关系]:
{====}

{====}
Any statements following the `defer` will be considered
to be in an implicit try block in the current block:
{====}
在 `defer` 之后的任意语句，都认为处在当前块的隐式try块中:
{====}

{====}
The exception tree is defined in the [system](system.html) module.
Every exception inherits from `system.Exception`. Exceptions that indicate
programming bugs inherit from `system.Defect` (which is a subtype of `Exception`)
and are strictly speaking not catchable as they can also be mapped to an operation
that terminates the whole process. If panics are turned into exceptions, these
exceptions inherit from `Defect`.
{====}
异常树被定义在[system](system.html)模块中。每个异常都继承自 `system.Exception` 。表示程序错误的异常继承自 `system.Defect` (它是`Exception`的子类型)，因为它们可以被映射到终止整个进程的操作中，因此将不能捕捉。如果恐慌变为异常，则这些异常继承自 `Defect` 。
{====}

{====}
  ```nim  test = "nim c --warningAsError:Effect:on $1"  status = 1
  type IO = object ## input/output effect
  proc readLine(): string {.tags: [IO].} = discard
  proc echoLine(): void = discard

  proc no_IO_please() {.forbids: [IO].} =
    # this is OK because it didn't define any tag:
    echoLine()
    # the compiler prevents this:
    let y = readLine()
  ```
{====}
  ```nim  test = "nim c --warningAsError:Effect:on $1"  status = 1
  type IO = object ## input/output effect
  proc readLine(): string {.tags: [IO].} = discard
  proc echoLine(): void = discard

  proc no_IO_please() {.forbids: [IO].} =
    # 这是可以的，因为它没有定义任何标签:
    echoLine()
    # 编译器会阻止这种情况:
    let y = readLine()
  ```
{====}

{====}
  ```nim
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
  ```
{====}
  ```nim
  type MyEffect = object
  type ProcType1 = proc (i: int): void {.forbids: [MyEffect].}
  type ProcType2 = proc (i: int): void

  proc caller1(p: ProcType1): void = p(1)
  proc caller2(p: ProcType2): void = p(1)

  proc effectful(i: int): void {.tags: [MyEffect].} = echo $i
  proc effectless(i: int): void {.forbids: [MyEffect].} = echo $i

  proc toBeCalled1(i: int): void = effectful(i)
  proc toBeCalled2(i: int): void = effectless(i)

  ## 这将会失败，因为toBeCalled1使用了ProcType1所禁止的MyEffect:
  caller1(toBeCalled1)
  ## 这是可以的，因为toBeCalled2和ProcType1有相同的限制:
  caller1(toBeCalled2)
  ## 这些都是可以的，因为ProcType2没有副作用限制:
  caller2(toBeCalled1)
  caller2(toBeCalled2)
  ```
{====}

{====}
`ProcType2` is a subtype of `ProcType1`. Unlike with the `tags` pragma, the parent context - the
function which calls other functions with forbidden effects - doesn't inherit the forbidden list of effects.
{====}
`ProcType2` 是 `ProcType1` 的子类型。与 `tags` 编译指示所不同的是，父上下文将:调用具有禁用副作用的其他函数的函数;不继承禁用副作用列表。
{====}

{====}
As a special semantic rule, the built-in [debugEcho](
system.html#debugEcho,varargs[typed,]) pretends to be free of side effects
so that it can be used for debugging routines marked as `noSideEffect`.
{====}
作为一个特殊的语义规则，内置的[debugEcho](system.html#debugEcho,varargs[typed,])忽略副作用，这样它就可以用于调试标记为 `noSideEffect` 的例程。
{====}

{====}
- [Shared heap memory management](mm.html).
{====}
- [共享堆内存管理](mm.html).
{====}

{====}
  ```nim  test = "nim c $1"
  type
    BinaryTree*[T] = ref object # BinaryTree is a generic type with
                                # generic parameter `T`
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
{====}
  ```nim  test = "nim c $1"
  type
    BinaryTree*[T] = ref object # 二叉树是具有
                                # 通用参数 `T` 的常规类型。
      le, ri: BinaryTree[T]     # 左右子树;可能是nil
      data: T                   # 存储在节点中的数据

  proc newNode*[T](data: T): BinaryTree[T] =
    # 节点的构造函数
    result = BinaryTree[T](le: nil, ri: nil, data: data)

  proc add*[T](root: var BinaryTree[T], n: BinaryTree[T]) =
    # 向树中插入一个节点
    if root == nil:
      root = n
    else:
      var it = root
      while it != nil:
        # 使用通用的 `cmp` 过程，比较数据项;
        # 这适用于任意具有 `==` 和 `<` 运算符的类型
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
    # 便捷过程:
    add(root, newNode(data))

  iterator preorder*[T](root: BinaryTree[T]): T =
    # 二叉树预遍历。
    # 使用显式堆栈。
    # (这比递归迭代器工厂更有效).
    var stack: seq[BinaryTree[T]] = @[root]
    while stack.len > 0:
      var n = stack.pop()
      while n != nil:
        yield n.data
        add(stack, n.ri)  # 将右子树push到堆栈上
        n = n.le          # 并跟踪左子树

  var
    root: BinaryTree[string]  # 用 `string` 实例化二叉树
  add(root, newNode("hello")) # 实例化 `newNode` 和 `add`
  add(root, "world")          # 实例化 `add` 过程
  for str in preorder(root):
    stdout.writeLine(str)
  ```
{====}

{====}
Procedures utilizing type classes in such a manner are considered to be
`implicitly generic`:idx:. They will be instantiated once for each unique
combination of parameter types used within the program.
{====}

{====}

{====}
Alternatively, the `distinct` type modifier can be applied to the type class
to allow each parameter matching the type class to bind to a different type. Such
type classes are called `bind many`:idx: types.
{====}

{====}

{====}
A parameter of type `typedesc` is itself usable as a type. If it is used
as a type, it's the underlying type. In other words, one level
of "typedesc"-ness is stripped off:
{====}

{====}

{====}
  ```nim
  template `!=` (a, b: untyped): untyped =
    # this definition exists in the system module
    not (a == b)

  assert(5 != 6) # the compiler rewrites that to: assert(not (5 == 6))
  ```
{====}

{====}

{====}
  ```nim
  template withFile(f, fn, mode: untyped, actions: untyped): untyped =
    block:
      var f: File  # since 'f' is a template parameter, it's injected implicitly
      ...

  withFile(txt, "ttempl3.txt", fmWrite):
    txt.writeLine("line 1")
    txt.writeLine("line 2")
  ```
{====}

In this version of `debug`, the symbols `write`, `writeLine` and `stdout`
are already bound and are not looked up again. As the example shows, `bindSym`
does work with overloaded symbols implicitly.

Note that the symbol names passed to `bindSym` have to be constant. The
experimental feature `dynamicBindSym` ([experimental manual](
manual_experimental.html#dynamic-arguments-for-bindsym))
allows this value to be computed dynamically.
{====}

{====}

{====}
static\[T]
----------
{====}

{====}

{====}
For the purposes of code generation, all static parameters are treated as
generic parameters - the proc will be compiled separately for each unique
supplied value (or combination of values).
{====}

{====}

{====}
Static parameters can also appear in the signatures of generic types:
{====}

{====}

{====}
Please note that `static T` is just a syntactic convenience for the underlying
generic type `static[T]`. The type parameter can be omitted to obtain the type
class of all constant expressions. A more specific type class can be created by
instantiating `static` with another type class.
{====}

{====}

{====}
typedesc\[T]
------------
{====}

{====}

{====}
`typedesc` acts as a generic type. For instance, the type of the symbol
`int` is `typedesc[int]`. Just like with regular generic types, when the
generic parameter is omitted, `typedesc` denotes the type class of all types.
As a syntactic convenience, one can also use `typedesc` as a modifier.
{====}

{====}

{====}
Procs featuring `typedesc` parameters are considered implicitly generic.
They will be instantiated for each unique combination of supplied types,
and within the body of the proc, the name of each parameter will refer to
the bound concrete type:
{====}

{====}

{====}
When multiple type parameters are present, they will bind freely to different
types. To force a bind-once behavior, one can use an explicit generic parameter:
{====}

{====}

{====}
Once bound, type parameters can appear in the rest of the proc signature:
{====}

{====}

{====}
Overload resolution can be further influenced by constraining the set
of types that will match the type parameter. This works in practice by
attaching attributes to types via templates. The constraint can be a
concrete type or a type class.
{====}

{====}

{====}
  ```nim  test = "nim c $1"
  iterator split(s: string): string = discard
  proc split(s: string): seq[string] = discard

  # since an iterator is the preferred interpretation, this has the type `string`:
  assert typeof("a b c".split) is string

  assert typeof("a b c".split, typeOfProc) is seq[string]
  ```
{====}

{====}

{====}
After the `import` keyword, a list of module names can follow or a single
module name followed by an `except` list to prevent some symbols from being
imported:
{====}

{====}

{====}
It is not checked that the `except` list is really exported from the module.
This feature allows us to compile against different versions of the module,
even when one version does not export some of these identifiers.
{====}

{====}

{====}
A module alias can be introduced via the `as` keyword, after which the original module name
is inaccessible:
{====}

{====}

{====}
The notations `path/to/module` or `"path/to/module"` can be used to refer to a module
in subdirectories:
{====}

{====}

{====}
After the `from` keyword, a module name followed by
an `import` to list the symbols one likes to use without explicit
full qualification:
{====}

{====}

{====}
The immediate pragma is obsolete. See [Typed vs untyped parameters].
{====}

{====}

{====}
redefine pragma
---------------
{====}

{====}

{====}
Redefinition of template symbols with the same signature is allowed.
This can be made explicit with the `redefine` pragma:
{====}

{====}

{====}
```nim
template foo: int = 1
echo foo() # 1
template foo: int {.redefine.} = 2
echo foo() # 2
# warning: implicit redefinition of template
template foo: int = 3
```
{====}

{====}

{====}
This is mostly intended for macro generated code. 
{====}

{====}

{====}
Disabling certain messages
--------------------------
{====}

{====}

{====}
Nim generates some warnings and hints ("line too long") that may annoy the
user. A mechanism for disabling certain messages is provided: Each hint
and warning message is associated with a symbol. This is the message's
identifier, which can be used to enable or disable the message by putting it
in brackets following the pragma:
{====}

{====}

{====}
The `experimental` pragma enables experimental language features. Depending
on the concrete feature, this means that the feature is either considered
too unstable for an otherwise stable release or that the future of the feature
is uncertain (it may be removed at any time). See the
[experimental manual](manual_experimental.html) for more details.
{====}

{====}

{====}
Note that one can use `gorge` from the [system module](system.html) to
embed parameters from an external command that will be executed
during semantic analysis:
{====}

{====}

{====}
Note that one can use `gorge` from the [system module](system.html) to
embed parameters from an external command that will be executed
during semantic analysis:
{====}

{====}

{====}
ImportCpp pragma
----------------
{====}

{====}

{====}
**Note**: [c2nim](https://github.com/nim-lang/c2nim/blob/master/doc/c2nim.rst)
can parse a large subset of C++ and knows
about the `importcpp` pragma pattern language. It is not necessary
to know all the details described here.
{====}

{====}

{====}
Similar to the [importc pragma] for C, the
`importcpp` pragma can be used to import `C++`:idx: methods or C++ symbols
in general. The generated code then uses the C++ method calling
syntax: `obj->method(arg)`:cpp:. In combination with the `header` and `emit`
pragmas this allows *sloppy* interfacing with libraries written in C++:
{====}

{====}

{====}
    ```nim
    type
      VectorIterator[T] {.importcpp: "std::vector<'0>::iterator".} = object

    var x: VectorIterator[cint]
    ```
{====}

{====}

{====}
ImportJs pragma
---------------
{====}

{====}

{====}
Similar to the [importcpp pragma] for C++,
the `importjs` pragma can be used to import Javascript methods or
symbols in general. The generated code then uses the Javascript method
calling syntax: ``obj.method(arg)``.
{====}

{====}

{====}
ImportObjC pragma
-----------------
Similar to the [importc pragma] for C, the `importobjc` pragma can
be used to import `Objective C`:idx: methods. The generated code then uses the
Objective C method calling syntax: ``[obj method param1: arg]``.
In addition with the `header` and `emit` pragmas this
allows *sloppy* interfacing with libraries written in Objective C:
{====}

{====}

{====}
The macros module includes helpers which can be used to simplify custom pragma
access `hasCustomPragma`, `getCustomPragmaVal`. Please consult the
[macros](macros.html) module documentation for details. These macros are not
magic, everything they do can also be achieved by walking the AST of the object
representation.
{====}

{====}

{====}
More examples with custom pragmas:
{====}

{====}

{====}
There are a few more applications of macro pragmas, such as in type,
variable and constant declarations, but this behavior is considered to be
experimental and is documented in the [experimental manual](
manual_experimental.html#extended-macro-pragmas) instead.
{====}

{====}

{====}
  ```nim
  proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}
  ```
{====}

{====}

{====}
  ```nim
  {.emit: "const int cconst = 42;".}

  let cconst {.importc, nodecl.}: cint

  assert cconst == 42
  ```
{====}

{====}

{====}
 * [importcpp][importcpp pragma]
 * [importobjc][importobjc pragma]
 * [importjs][importjs pragma]
{====}

{====}

{====}
If the symbol should also be exported to a dynamic library, the `dynlib`
pragma should be used in addition to the `exportc` pragma. See
[Dynlib pragma for export].
{====}

{====}

{====}
**Note**: A `dynlib` import can be overridden with
the `--dynlibOverride:name`:option: command-line option. The
[Compiler User Guide](nimc.html) contains further information.
{====}

{====}

{====}
To enable thread support the `--threads:on`:option: command-line switch needs to
be used. The [system module](system.html) module then contains several threading primitives.
See the [channels](channels_builtin.html) modules
for the low-level thread API. There are also high-level parallelism constructs
available. See [spawn](manual_experimental.html#parallel-amp-spawn) for
further details.
{====}

{====}

{====}
A thread proc can be passed to `createThread` or `spawn`.
{====}

{====}

{====}
The `locks` pragma takes a list of lock expressions `locks: [a, b, ...]`
in order to support *multi lock* statements. Why these are essential is
explained in the [lock levels](manual_experimental.md#lock-levels) section
of experimental manual.
{====}

{====}