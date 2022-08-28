{==+==}
experimental pragma
-------------------
{==+==}
expermimental 的编译指示
------------------------------------------------
{==+==}

{==+==}
The `experimental` pragma enables experimental language features. Depending
on the concrete feature, this means that the feature is either considered
too unstable for an otherwise stable release or that the future of the feature
is uncertain (it may be removed at any time). See the
`experimental manual <manual_experimental.html>`_ for more details.
{==+==}
`expermimental` 编译指示用于启用实验性的语言功能。 取决于具体的特性 这意味着该特性要么被认为是 过于不稳定，要么特性 的未来是不确定的(它可能随时被删除)。 详情请参阅 `expermimental 手册 <manual_experimental.html>`_ 。
{==+==}

{==+==}
Example:
{==+==}
示例:
{==+==}

{-----}
  ```nim
  import std/threadpool
  {.experimental: "parallel".}

  proc threadedEcho(s: string, i: int) =
    echo(s, " ", $i)

  proc useParallel() =
    parallel:
      for i in 0..4:
        spawn threadedEcho("echo in parallel", i)

  useParallel()
  ```
{-----}

{==+==}
As a top-level statement, the experimental pragma enables a feature for the
rest of the module it's enabled in. This is problematic for macro and generic
instantiations that cross a module scope. Currently, these usages have to be
put into a `.push/pop` environment:
{==+==}
作为顶层的语句时，expermimental 编译指示启用功能为 一个模块的余下的所有部分。 这对于横跨模块范围的宏和通用的 实例是有问题的。 所以，这些用法必须是 被放入一个 `.push/pop` 环境中:
{==+==}

{-----}
  ```nim
  # client.nim
  proc useParallel*[T](unused: T) =
    # use a generic T here to show the problem.
    {.push experimental: "parallel".}
    parallel:
      for i in 0..4:
        echo "echo in parallel"

    {.pop.}
  ```
{-----}

{-----}
  ```nim
  import client
  useParallel(1)
  ```
{-----}

{==+==}
Implementation Specific Pragmas
===============================

This section describes additional pragmas that the current Nim implementation
supports but which should not be seen as part of the language specification.
{==+==}
实现特定的编译指示
====================================

本节介绍当前Nim实现 所支持的额外的编译指示，但不应将其视为语言说明的一部分。
{==+==}

{==+==}
Bitsize pragma
--------------

The `bitsize` pragma is for object field members. It declares the field as
a bitfield in C/C++.
{==+==}
Bitsize 编译指示
--------------------------------

`bitsize` 是对象字段成员的编译指示。 这表明该字段为 是C/C++中的一个位域。
{==+==}

{-----}

  ```Nim
  type
    mybitfield = object
      flag {.bitsize:1.}: cuint
  ```
{-----}

{==+==}
generates:
{==+==}
生成:
{==+==}

{-----}

  ```C
  struct mybitfield {
    unsigned int flag:1;
  };
  ```
{-----}

{==+==}
Align pragma
------------

The `align`:idx: pragma is for variables and object field members. It
modifies the alignment requirement of the entity being declared. The
argument must be a constant power of 2. Valid non-zero
alignments that are weaker than other align pragmas on the same
declaration are ignored. Alignments that are weaker than the
alignment requirement of the type are ignored.
{==+==}
Align 编译指示
----------------------------

`align`:idx: 编译指示是针对变量和对象字段成员的。 它 用于修改所声明的实体的字节对齐要求。 参数必须是 2 的幂。 有效的非 0 对齐的编译标记同时存在声明的时候，弱的编译标记 会被忽略。 与类型的 对齐要求相比较弱的对齐编译标记的声明也会被忽略。
{==+==}

{-----}
  ```Nim
  type
    sseType = object
      sseData {.align(16).}: array[4, float32]

    # every object will be aligned to 128-byte boundary
    Data = object
      x: char
      cacheline {.align(128).}: array[128, char] # over-aligned array of char,

  proc main() =
    echo "sizeof(Data) = ", sizeof(Data), " (1 byte + 127 bytes padding + 128-byte array)"
    # output: sizeof(Data) = 256 (1 byte + 127 bytes padding + 128-byte array)
    echo "alignment of sseType is ", alignof(sseType)
    # output: alignment of sseType is 16
    var d {.align(2048).}: Data # this instance of data is aligned even stricter

  main()
  ```
{-----}

{==+==}
This pragma has no effect on the JS backend.
{==+==}
这种编译指示对 JS 后端没有任何影响。
{==+==}

{==+==}
Noalias pragma
--------------

Since version 1.4 of the Nim compiler, there is a `.noalias` annotation for variables
and parameters. It is mapped directly to C/C++'s `restrict`:c: keyword and means that
the underlying pointer is pointing to a unique location in memory, no other aliases to
this location exist. It is *unchecked* that this alias restriction is followed. If the
restriction is violated, the backend optimizer is free to miscompile the code.
This is an **unsafe** language feature.

Ideally in later versions of the language, the restriction will be enforced at
compile time. (This is also why the name `noalias` was chosen instead of a more
verbose name like `unsafeAssumeNoAlias`.)
{==+==}
Noalias 编译指示
--------------------------------

从 Nim 编译器版本 1.4 ，有一个 `.noalias` 注解用于变量 和参数。 它被直接映射到 C/C++ 的 `restrict`:c: 关键字，并表示 底部指向内存中的一个独特位置， 此位置不存在其他别名。 *unchecked* 遵守此别名限制。 如果违反了 限制，后端优化器可以自由地编译代码。 这是一个 **不安全的** 语言功能。

理想情况下，在 Nim 之后的版本中，该限制将在 编译时间强制执行。 (这也是为什么选择 `noalias` 的名字，而不是描述更 详细的名字，如 `unsafeAssumeNoAlias`。)
{==+==}

{==+==}
Volatile pragma
---------------
The `volatile` pragma is for variables only. It declares the variable as
`volatile`:c:, whatever that means in C/C++ (its semantics are not well-defined
in C/C++).

**Note**: This pragma will not exist for the LLVM backend.
{==+==}
Volatile 编译指示
----------------------------------
`volatile` 编译指示仅用于变量。 它宣布变量为 `volatile`:c:, 不论 C/C++ 中 volatile 代表什么含义 (其语义在 C/C+++中是没有明确定义的)。

**注意**: LLVM 后端不存在这种编译指示。
{==+==}

{==+==}
nodecl pragma
-------------
The `nodecl` pragma can be applied to almost any symbol (variable, proc,
type, etc.) and is sometimes useful for interoperability with C:
It tells Nim that it should not generate a declaration for the symbol in
the C code. For example:
{==+==}
nodecl 编译指示
------------------------------
`nodell` 编译指示可以应用于几乎任何符号(变量，程序， 类型等)。 有时在与 C 的相互操作上很有用: <0>nodell</0> 编译指示会告诉 Nim, 不要生成在 C 代码中的符号的声明。 例如:
{==+==}

{-----}
  ```Nim
  var
    EACCES {.importc, nodecl.}: cint # pretend EACCES was a variable, as
                                     # Nim 不知道他的值
  ```
{-----}

{==+==}
However, the `header` pragma is often the better alternative.

**Note**: This will not work for the LLVM backend.
{==+==}
然而， `header` 编译指示常是更好的选择。

**注意**: 这在 LLVM 后端无法使用。
{==+==}

{==+==}
Header pragma
-------------
The `header` pragma is very similar to the `nodecl` pragma: It can be
applied to almost any symbol and specifies that it should not be declared
and instead, the generated code should contain an `#include`:c:\:
{==+==}
Header 编译指示
------------------------------
`header` 编译指示和 `nodecl` 编译指示非常相似:几乎可以在任何符号和不应声明的 specifies 上应用，与之替代的是，生成代码会包含一个 `#include`:c:\:
{==+==}

{-----}
  ```Nim
  type
    PFile {.importc: "FILE*", header: "<stdio.h>".} = distinct pointer
      # import C's FILE* type; Nim will treat it as a new pointer type
  ```
{-----}

{==+==}
The `header` pragma always expects a string constant. The string constant
contains the header file: As usual for C, a system header file is enclosed
in angle brackets: `<>`:c:. If no angle brackets are given, Nim
encloses the header file in `""`:c: in the generated C code.

**Note**: This will not work for the LLVM backend.
{==+==}
`header` 编译指示总是需要一个字符串常量。 字符串常量 包含头文件:和 C 的正常使用一样，头文件需要用尖括号包起来 ︰ `<>`:c:。 如果没有给出尖括号，Nim 会在生成的 C 代码中用 `""`:c: 把头文件放在一起。

**注意**: LLVM 后端不存在这种编译指示。
{==+==}

{==+==}
IncompleteStruct pragma
-----------------------
The `incompleteStruct` pragma tells the compiler to not use the
underlying C `struct`:c: in a `sizeof` expression:
{==+==}
IncompleteStruct 编译指示
--------------------------------------------------
`incompleteStruct` 编译指示告诉编译器不要使用 底层 C 的`结构`:c: 在 `sizeof` 表达式中:
{==+==}

{-----}
  ```Nim
  type
    DIR* {.importc: "DIR", header: "<dirent.h>",
           pure, incompleteStruct.} = object
  ```
{-----}

{==+==}
Compile pragma
--------------
The `compile` pragma can be used to compile and link a C/C++ source file
with the project:
{==+==}
Compile 编译指示
--------------------------------
`compile` 编译指示可以将一个 C/C++ 源文件用于编译和链接到项目:
{==+==}

{-----}
  ```Nim
  {.compile: "myfile.cpp".}
  ```
{-----}

{==+==}
**Note**: Nim computes a SHA1 checksum and only recompiles the file if it
has changed. One can use the `-f`:option: command-line option to force
the recompilation of the file.
{==+==}
**注意**: Nim 通过计算 SHA1 校验和，并且只在文件 已经更改时重新编译文件。 可以使用 `-f`:option: 命令行选项来强制重新编译 文件。
{==+==}

{==+==}
Since 1.4 the `compile` pragma is also available with this syntax:
{==+==}
从 1.4 开始， `compile` 编译指示也可以使用此语法:
{==+==}

{-----}
  ```Nim
  {.compile("myfile.cpp", "--custom flags here").}
  ```
{-----}

{==+==}
As can be seen in the example, this new variant allows for custom flags
that are passed to the C compiler when the file is recompiled.
{==+==}
可以从例子中看出。 这种方式允许自定义标识 在重新编译文件时传给 C 编译器。
{==+==}

{==+==}
Link pragma
-----------
The `link` pragma can be used to link an additional file with the project:
{==+==}
Link 编译指示
--------------------------
`link` 编译指示可以用来将附加文件与项目链接:
{==+==}

{-----}
  ```Nim
  {.link: "myfile.o".}
  ```
{-----}

{==+==}
passc pragma
------------
The `passc` pragma can be used to pass additional parameters to the C
compiler like one would use the command-line switch `--passc`:option:\:
{==+==}
passc 编译指示
----------------------------
`passc` 编译指示可以用来传递额外参数到 C 编译器，就像命令行使用的 `--passc`:option:\:
{==+==}

{-----}
  ```Nim
  {.passc: "-Wall -Werror".}
  ```
{-----}

{==+==}
Note that one can use `gorge` from the `system module <system.html>`_ to
embed parameters from an external command that will be executed
during semantic analysis:
{==+==}
请注意，可以从`系统模块<system.html>`中使用 `gorge` 这会在语义分析中嵌入将执行的外部命令的参数:
{==+==}

{-----}
  ```Nim
  {.passc: gorge("pkg-config --cflags sdl").}
  ```
{-----}

{==+==}
localPassC pragma
-----------------
The `localPassC` pragma can be used to pass additional parameters to the C
compiler, but only for the C/C++ file that is produced from the Nim module
the pragma resides in:
{==+==}
localPassC 编译指示
--------------------------------------
`localPassC` 编译指示可以用来传递附加参数到 C 编译器。 但仅适用于 Nim 模块包含该编译指示生成的 C/C++ 文件 :
{==+==}

{-----}
  ```Nim
  # Module A.nim
  # Produces: A.nim.cpp
  {.localPassC: "-Wall -Werror".} # Passed when compiling A.nim.cpp
  ```
{-----}

{==+==}
passl pragma
------------
The `passl` pragma can be used to pass additional parameters to the linker
like one would be using the command-line switch `--passl`:option:\:
{==+==}
passl 编译指示
----------------------------
`passc` 编译指示可以用来传递额外参数到 C 链接器，就像在命令行使用的 `--passc`:option:\:
{==+==}

{-----}
  ```Nim
  {.passl: "-lSDLmain -lSDL".}
  ```
{-----}

{==+==}
Note that one can use `gorge` from the `system module <system.html>`_ to
embed parameters from an external command that will be executed
during semantic analysis:
{==+==}
请注意，可以从`系统模块<system.html>`中使用 `gorge` 这会在语义分析中嵌入将执行的外部命令的参数:
{==+==}

{-----}
  ```Nim
  {.passl: gorge("pkg-config --libs sdl").}
  ```
{-----}

{==+==}
Emit pragma
-----------
The `emit` pragma can be used to directly affect the output of the
compiler's code generator. The code is then unportable to other code
generators/backends. Its usage is highly discouraged! However, it can be
extremely useful for interfacing with `C++`:idx: or `Objective C`:idx: code.

Example:
{==+==}
Emit 编译指示
--------------------------
`emit` 编译指示可以用于直接影响 编译器的代码生成器的输出。 然后，该代码不可移植到其他代码 生成器/后端 非常不鼓励这种用法 然而在以下情况会尤其有用: 当使用 `C++`:idx: 的接口化或者 `Objective C`:idx: 代码的时候。

示例:
{==+==}

{-----}
  ```Nim
  {.emit: """
  static int cvariable = 420;
  """.}

  {.push stackTrace:off.}
  proc embedsC() =
    var nimVar = 89
    # access Nim symbols within an emit section outside of string literals:
    {.emit: ["""fprintf(stdout, "%d\n", cvariable + (int)""", nimVar, ");"].}
  {.pop.}

  embedsC()
  ```
{-----}

{==+==}
``nimbase.h`` defines `NIM_EXTERNC`:c: C macro that can be used for
`extern "C"`:cpp: code to work with both `nim c`:cmd: and `nim cpp`:cmd:, e.g.:
{==+==}
`nimbase.h` 定义了 `NIM_EXTERNC`:c: C宏，可以用于 `extern "C"`:cpp: 代码可以同时用于 `nim c`:cmd: 和 `nim cpp`:cmd:, 例如:
{==+==}

{-----}
  ```Nim
  proc foobar() {.importc:"$1".}
  {.emit: """
  #include <stdio.h>
  NIM_EXTERNC
  void fun(){}
  """.}
  ```
{-----}

{==+==}
.. note:: For backward compatibility, if the argument to the `emit` statement
  is a single string literal, Nim symbols can be referred to via backticks.
  This usage is however deprecated.
{==+==}
.. 注意:: 为了向后兼容，如果到 `emit` 语句的参数 是一个单个字符串， Nim 符号可以通过反引号进行引用。 但这种用法已经废弃。
{==+==}

{==+==}
For a top-level emit statement, the section where in the generated C/C++ file
the code should be emitted can be influenced via the prefixes
`/*TYPESECTION*/`:c: or `/*VARSECTION*/`:c: or `/*INCLUDESECTION*/`:c:\:
{==+==}
对于在顶层的 emit 声明语句， 生成的 C/C++ 文件 中的代码应该被 emit 的部分可以通过前缀 `/*TYPEECTION* /`:c: 或 `/*VARSECTION* /`:c: 或 `/*INCLUDESECTION*`:c:\:
{==+==}

{-----}
  ```Nim
  {.emit: """/*TYPESECTION*/
  struct Vector3 {
  public:
    Vector3(): x(5) {}
    Vector3(float x_): x(x_) {}
    float x;
  };
  """.}

  type Vector3 {.importcpp: "Vector3", nodecl} = object
    x: cfloat

  proc constructVector3(a: cfloat): Vector3 {.importcpp: "Vector3(@)", nodecl}
  ```
{-----}

{==+==}
ImportCpp pragma
----------------

**Note**: `c2nim <https://github.com/nim-lang/c2nim/blob/master/doc/c2nim.rst>`_ can parse a large subset of C++ and knows
about the `importcpp` pragma pattern language. It is not necessary
to know all the details described here.
{==+==}
ImportCpp 编译指示
------------------------------------

**注意**: `c2nim <https://github.com/nim-lang/c2nim/blob/master/doc/c2nim.rst>`_ 可以解析大量 C++ 的子集并知道 关于` importCpp ` 编译指示的模式语言。 不需要 知道这里描述的所有细节。
{==+==}

{==+==}
Similar to the `importc pragma for C
<#foreign-function-interface-importc-pragma>`_, the
`importcpp` pragma can be used to import `C++`:idx: methods or C++ symbols
in general. The generated code then uses the C++ method calling
syntax: `obj->method(arg)`:cpp:. In combination with the `header` and `emit`
pragmas this allows *sloppy* interfacing with libraries written in C++:
{==+==}
类似于对C 的 `importc 编译指示
<#foreign function-interface-importc-pralma>`_, `importc` 编译指示可以用来导入 `C++`:idx: 方法或 C++ 符号 。 生成的代码使用 C++ 方法调用 语法: `obj->method(arg)`:cpp:。 结合 `header` 和 `emit` 编译标记，这允许 *sloppy* 接口使用 C++ 的库:
{==+==}

{-----}
  ```Nim
  # Horrible example of how to interface with a C++ engine ... ;-)

  {.link: "/usr/lib/libIrrlicht.so".}

  {.emit: """
  using namespace irr;
  using namespace core;
  using namespace scene;
  using namespace video;
  using namespace io;
  using namespace gui;
  """.}

  const
    irr = "<irrlicht/irrlicht.h>"

  type
    IrrlichtDeviceObj {.header: irr,
                        importcpp: "IrrlichtDevice".} = object
    IrrlichtDevice = ptr IrrlichtDeviceObj

  proc createDevice(): IrrlichtDevice {.
    header: irr, importcpp: "createDevice(@)".}
  proc run(device: IrrlichtDevice): bool {.
    header: irr, importcpp: "#.run(@)".}
  ```
{-----}

{==+==}
The compiler needs to be told to generate C++ (command `cpp`:option:) for
this to work. The conditional symbol `cpp` is defined when the compiler
emits C++ code.
{==+==}
需要告诉编译器生成 C++ (命令 `cpp`:option:) 才能工作 。 当编译器 emit C++ 代码时，条件符号 `cpp` 已被定义。
{==+==}

{==+==}
### Namespaces
{==+==}
### 命名空间
{==+==}

{==+==}
The *sloppy interfacing* example uses `.emit` to produce `using namespace`:cpp:
declarations. It is usually much better to instead refer to the imported name
via the `namespace::identifier`:cpp: notation:
{==+==}
*sloppy interfacing* 示例使用 `.emit` 来生成 `using namespace`:cpp: 声明。 转而通过 `namespace::identifier`:cpp: 注解来引用导入的名称 通常要好得多:
{==+==}

{-----}
  ```nim
  type
    IrrlichtDeviceObj {.header: irr,
                        importcpp: "irr::IrrlichtDevice".} = object
  ```
{-----}

{==+==}
### Importcpp for enums

When `importcpp` is applied to an enum type the numerical enum values are
annotated with the C++ enum type, like in this example:
`((TheCppEnum)(3))`:cpp:.
(This turned out to be the simplest way to implement it.)
{==+==}
### Importcpp 在枚举的使用

`importcpp` 应用于枚举类型时，数字枚举值 使用 C++ 枚举类型注解， 类似于这个例子: `((TheCppEnum)(3))`:cpp:。 (这已经是最简单的实现方式了。)
{==+==}

{==+==}
### Importcpp for procs

Note that the `importcpp` variant for procs uses a somewhat cryptic pattern
language for maximum flexibility:
{==+==}
### Importcpp 在 proc 中的使用

请注意，procs 中的 `importcpp` 变体使用了一种更加晦涩的模式 语言来实现最大的灵活性:

{==+==}

{==+==}
- A hash ``#`` symbol is replaced by the first or next argument.
- A dot following the hash ``#.`` indicates that the call should use C++'s dot
  or arrow notation.
- An at symbol ``@`` is replaced by the remaining arguments,
  separated by commas.

For example:
{==+==}
- 哈希 `#` 符号会被第一个或下一个参数所取代。
- 哈希符号加个点 `#.` 表示调用应该使用 C++'s 的点 或箭头符号。
- 符号 `@` 被剩余参数替换。 通过逗号分隔。

例如:
{==+==}

{-----}
  ```nim
  proc cppMethod(this: CppObj, a, b, c: cint) {.importcpp: "#.CppMethod(@)".}
  var x: ptr CppObj
  cppMethod(x[], 1, 2, 3)
  ```
{-----}

{==+==}
Produces:
{==+==}
生成:
{==+==}

{-----}
  ```C
  x->CppMethod(1, 2, 3)
  ```
{-----}

{==+==}
As a special rule to keep backward compatibility with older versions of the
`importcpp` pragma, if there is no special pattern
character (any of ``# ' @``) at all, C++'s
dot or arrow notation is assumed, so the above example can also be written as:
{==+==}
作为一项特殊规则，以保持与旧版本的 `importcpp` 编译指示的兼容性， 如果没有任何特殊的模式 字符 ( `# ' @`中的任意一个)，则会假定使用 C++'s 点数或箭头符号被假定，因此上面的示例也可以写为:
{==+==}

{-----}
  ```nim
  proc cppMethod(this: CppObj, a, b, c: cint) {.importcpp: "CppMethod".}
  ```
{-----}

{==+==}
Note that the pattern language naturally also covers C++'s operator overloading
capabilities:
{==+==}
请注意，模式语言当然也包括C++的操作符重载的能力:
{==+==}

{-----}
  ```nim
  proc vectorAddition(a, b: Vec3): Vec3 {.importcpp: "# + #".}
  proc dictLookup(a: Dict, k: Key): Value {.importcpp: "#[#]".}
  ```
{-----}

{==+==}
- An apostrophe ``'`` followed by an integer ``i`` in the range 0..9
  is replaced by the i'th parameter *type*. The 0th position is the result
  type. This can be used to pass types to C++ function templates. Between
  the ``'`` and the digit, an asterisk can be used to get to the base type
  of the type. (So it "takes away a star" from the type; `T*`:c: becomes `T`.)
  Two stars can be used to get to the element type of the element type etc.

For example:
{==+==}
- 撇号`'` 之后是一个整数 `i` 取值为 0..9 范围内 将会被第 i 个参数 *type* 替换。 第 0 个位置是返回值的 类型。 这可以用来传递类型到 C++ 函数模板。 在 `'` 与数字之间，可以使用星号来获取类型的基本类型 。 (它会从中拿走星号。 比如 `T*`:c: 变成 `T` 。) 两个星号可以用来获取元素类型的类型。

例如:
{==+==}

{-----}
  ```nim
  type Input {.importcpp: "System::Input".} = object
  proc getSubsystem*[T](): ptr T {.importcpp: "SystemManager::getSubsystem<'*0>()", nodecl.}

  let x: ptr Input = getSubsystem[Input]()
  ```
{-----}

{==+==}
Produces:
{==+==}
生成:
{==+==}

{-----}
  ```C
  x = SystemManager::getSubsystem<System::Input>()
  ```
{-----}

{==+==}
- ``#@`` is a special case to support a `cnew` operation. It is required so
  that the call expression is inlined directly, without going through a
  temporary location. This is only required to circumvent a limitation of the
  current code generator.
{==+==}
- `#@` 是支持 `cnew` 操作的特殊情况。 在直接 inline 内联的，这是必需的 这样调用表达式才无需通过 临时位置调用。 这只是为了绕过 当前代码生成器的限制。
{==+==}

{==+==}
For example C++'s `new`:cpp: operator can be "imported" like this:
{==+==}
例如，C++'s `new`:cpp: 运算符可以像这样“导入”:
{==+==}

{-----}
  ```nim
  proc cnew*[T](x: T): ptr T {.importcpp: "(new '*0#@)", nodecl.}

  # constructor of 'Foo':
  proc constructFoo(a, b: cint): Foo {.importcpp: "Foo(@)".}

  let x = cnew constructFoo(3, 4)
  ```
{-----}

{==+==}
Produces:
{==+==}
生成:
{==+==}

{-----}
  ```C
  x = new Foo(3, 4)
  ```
{-----}

{==+==}
However, depending on the use case `new Foo`:cpp: can also be wrapped like this
instead:
{==+==}
然而，根据使用情况 `new Foo`:cpp: 也可以像这样包裹:
{==+==}

{-----}
  ```nim
  proc newFoo(a, b: cint): ptr Foo {.importcpp: "new Foo(@)".}

  let x = newFoo(3, 4)
  ```
{-----}

{==+==}
### Wrapping constructors

Sometimes a C++ class has a private copy constructor and so code like
`Class c = Class(1,2);`:cpp: must not be generated but instead
`Class c(1,2);`:cpp:.
For this purpose the Nim proc that wraps a C++ constructor needs to be
annotated with the `constructor`:idx: pragma. This pragma also helps to generate
faster C++ code since construction then doesn't invoke the copy constructor:
{==+==}
### 包装构造函数

有时候C++类有一个私有的构造函数，所以代码 `Class c = Class(1,2)；`:cpp: 是不对的，而应该是 `Class c(1,2);`:cpp:。 要达到这种效果，包装一个 C++ 构造函数的 Nim proc 需要使用 附加注释的 `constructor`:idx: 编译指示 这个编译指示也有助于生成 更快的 C++ 代码，因为构造时不会调用复制构造器:

{==+==}

{-----}
  ```nim
  # a better constructor of 'Foo':
  proc constructFoo(a, b: cint): Foo {.importcpp: "Foo(@)", constructor.}
  ```
{-----}

{==+==}
### Wrapping destructors

Since Nim generates C++ directly, any destructor is called implicitly by the
C++ compiler at the scope exits. This means that often one can get away with
not wrapping the destructor at all! However, when it needs to be invoked
explicitly, it needs to be wrapped. The pattern language provides
everything that is required:
{==+==}
### 包装析构器

既然Nim 直接生成 C++ ，任何析构器都会被 C++ 编译器隐含地调用在作用域出口。 这意味着可以完全不包装析构器！ 然而，当需要显式调用 时，它需要包装。 模式语言提供这里 所需一切:
{==+==}

{-----}
  ```nim
  proc destroyFoo(this: var Foo) {.importcpp: "#.~Foo()".}
  ```
{-----}

{==+==}
### Importcpp for objects

Generic `importcpp`'ed objects are mapped to C++ templates. This means that
one can import C++'s templates rather easily without the need for a pattern
language for object types:
{==+==}
### 包装析构器

既然Nim 直接生成 C++ ，任何析构器都会被 C++ 编译器隐含地调用在作用域出口。 这意味着可以完全不包装析构器！ 然而，当需要显式调用 时，它需要包装。 模式语言提供这里 所需一切:
{==+==}

{-----}
  ```nim  test = "nim cpp $1"
  type
    StdMap[K, V] {.importcpp: "std::map", header: "<map>".} = object
  proc `[]=`[K, V](this: var StdMap[K, V]; key: K; val: V) {.
    importcpp: "#[#] = #", header: "<map>".}

  var x: StdMap[cint, cdouble]
  x[6] = 91.4
  ```
{-----}

{==+==}
Produces:
{==+==}
生成:
{==+==}

{-----}
  ```C
  std::map<int, double> x;
  x[6] = 91.4;
  ```
{-----}

{==+==}
- If more precise control is needed, the apostrophe `'` can be used in the
  supplied pattern to denote the concrete type parameters of the generic type.
  See the usage of the apostrophe operator in proc patterns for more details.
{==+==}
- 如果需要更确切的控制的话。 撇号 `'` 可以在可以支持的 模式中来表示通用类型的具体类型参数。 了解更多详情，请参阅 proc 模式中撇号运算符的用法。
{==+==}

{-----}
    ```nim
    type
      VectorIterator {.importcpp: "std::vector<'0>::iterator".} [T] = object

    var x: VectorIterator[cint]
    ```
{-----}

{==+==}
  Produces:
{==+==}
  生成:
{==+==}

{-----}
    ```C

    std::vector<int>::iterator x;
    ```
{-----}
{==+==}
ImportJs pragma
---------------

Similar to the `importcpp pragma for C++ <#implementation-specific-pragmas-importcpp-pragma>`_,
the `importjs` pragma can be used to import Javascript methods or
symbols in general. The generated code then uses the Javascript method
calling syntax: ``obj.method(arg)``.
{==+==}
ImportJs 编译指示
----------------------------------

类似于 `importcpp pragma for C++ <#implementation-specific-pragmas-importcpp-pragma>`_, `importjs` 编译指示可以用来导入 JavaScript 的方法或者符号。 生成的代码会使用 Javascript 方法 调用语法: `obj.method(arg)`

{==+==}

{==+==}
ImportObjC pragma
-----------------
Similar to the `importc pragma for C
<#foreign-function-interface-importc-pragma>`_, the `importobjc` pragma can
be used to import `Objective C`:idx: methods. The generated code then uses the
Objective C method calling syntax: ``[obj method param1: arg]``.
In addition with the `header` and `emit` pragmas this
allows *sloppy* interfacing with libraries written in Objective C:
{==+==}
ImportObjC 编译指示
--------------------------------------
类似于 `importc pragma for C <#foreign-function-interface-importc-pragma>`_ , `importobjc` 编译指示可以用来导入 `Objective C`:idx: 的方法。 生成的代码会使用 Objective C 的方法 调用语法: `[obj method param1: arg]` 。 结合 `header` 和 `emit` 编译标记，这允许 *sloppy* 接口使用 Objective C 的库:

{==+==}

{-----}
  ```Nim
  # horrible example of how to interface with GNUStep ...

  {.passl: "-lobjc".}
  {.emit: """
  #include <objc/Object.h>
  @interface Greeter:Object
  {
  }

  - (void)greet:(long)x y:(long)dummy;
  @end

  #include <stdio.h>
  @implementation Greeter

  - (void)greet:(long)x y:(long)dummy
  {
    printf("Hello, World!\n");
  }
  @end

  #include <stdlib.h>
  """.}

  type
    Id {.importc: "id", header: "<objc/Object.h>", final.} = distinct int

  proc newGreeter: Id {.importobjc: "Greeter new", nodecl.}
  proc greet(self: Id, x, y: int) {.importobjc: "greet", nodecl.}
  proc free(self: Id) {.importobjc: "free", nodecl.}

  var g = newGreeter()
  g.greet(12, 34)
  g.free()
  ```
{-----}

{==+==}
The compiler needs to be told to generate Objective C (command `objc`:option:) for
this to work. The conditional symbol ``objc`` is defined when the compiler
emits Objective C code.
{==+==}
需要告诉编译器生成 Objective C(命令 `objc`:option:) 才能工作 。 当编译器 输出 Objective C 代码时，条件符号 `objc` 会被定义。
{==+==}

{==+==}
CodegenDecl pragma
------------------
{==+==}
CodegenDecl 编译指示
----------------------------------------
{==+==}

{==+==}
The `codegenDecl` pragma can be used to directly influence Nim's code
generator. It receives a format string that determines how the variable
or proc is declared in the generated code.
{==+==}
`codegenDecl`编译指示可以直接影响Nim的代码 生成器。 它接受一个格式字符串，用于决定变量 或程序如何在生成的代码中声明。
{==+==}

{==+==}
For variables, $1 in the format string represents the type of the variable
and $2 is the name of the variable.

The following Nim code:
{==+==}
对于变量，格式字符串中的$1表示变量 的类型，$2表示变量的名称。

以下 Nim 代码:
{==+==}

{-----}
  ```nim
  var
    a {.codegenDecl: "$# progmem $#".}: int
  ```
{-----}

{==+==}
will generate this C code:
{==+==}
将生成此 C 代码:
{==+==}

{-----}
  ```c
  int progmem a
  ```
{-----}

{==+==}
For procedures, $1 is the return type of the procedure, $2 is the name of
the procedure, and $3 is the parameter list.

The following nim code:
{==+==}
就程序而言，$1是程序的返回值类型，$2是程序 的名字，$3是参数列表。

以下 Nim 代码:
{==+==}

{-----}
  ```nim
  proc myinterrupt() {.codegenDecl: "__interrupt $# $#$#".} =
    echo "realistic interrupt handler"
  ```
{-----}

{==+==}
will generate this code:
{==+==}
将生成此代码:
{==+==}

{-----}
  ```c
  __interrupt void myinterrupt()
  ```
{-----}

{==+==}
`cppNonPod` pragma
------------------

The `.cppNonPod` pragma should be used for non-POD `importcpp` types so that they
work properly (in particular regarding constructor and destructor) for
`.threadvar` variables. This requires `--tlsEmulation:off`:option:.
{==+==}
`cppNonPod` 编译指示
----------------------------------------

`.cppNonPod` 编译指示应该用于非POD `importcpp` 类型，以便他们 ` threadvar` 变量正常工作(尤其是对构造器和析构器而言) 。 这需要 `--tlsEmulation:off`:option:。
{==+==}

{-----}
  ```nim
  type Foo {.cppNonPod, importcpp, header: "funs.h".} = object
    x: cint
  proc main()=
    var a {.threadvar.}: Foo
  ```
{-----}

{==+==}
compile-time define pragmas
---------------------------

The pragmas listed here can be used to optionally accept values from
the `-d/--define`:option: option at compile time.

The implementation currently provides the following possible options (various
others may be added later).
{==+==}
编译时定义的编译指示
----------------------------------------

这里列出的编译指示可以用于在编译时间接受 的 `-d/--define`:option: 选项的可选值。

当前的执行提供了以下可能的选项 (以后可能会添加 个其他选项)。

{==+==}

{==+==}
=================  ============================================
pragma             description
=================  ============================================
`intdefine`:idx:   Reads in a build-time define as an integer
`strdefine`:idx:   Reads in a build-time define as a string
`booldefine`:idx:  Reads in a build-time define as a bool
=================  ============================================
{==+==}

=================  ============================================ 
编译指示           描述 
=================  ============================================ 
`intdefine`:idx:   编译时定义读取为整数类型 
`strdefine`:idx:   编译时定义读取为 string 类型 
`booldefine`:idx:  编译时定义读取为 bool 类型 
=================  ============================================
{==+==}

{-----}
  ```nim
  const FooBar {.intdefine.}: int = 5
  echo FooBar
  ```
{-----}

{-----}
  ```cmd
  nim c -d:FooBar=42 foobar.nim
  ```
{-----}

{==+==}
In the above example, providing the `-d`:option: flag causes the symbol
`FooBar` to be overwritten at compile-time, printing out 42. If the
`-d:FooBar=42`:option: were to be omitted, the default value of 5 would be
used. To see if a value was provided, `defined(FooBar)` can be used.
{==+==}
在上述例子中， 提供 `-d`:option: 标志使得符号 `FooBar` 在编译时被覆盖，打印出 42。 如果删除 `-d:FooBar=42`:option: ，则使用默认值 5。 要查看是否提供了一个值， 可以使用`defined(FooBar)`。
{==+==}

{==+==}
The syntax `-d:flag`:option: is actually just a shortcut for
`-d:flag=true`:option:.
{==+==}
语法 `-d:flag`:option: 实际上只是 `-d:flag=true`:option: 的简写。
{==+==}

{==+==}
User-defined pragmas
====================
{==+==}
用户自定义的编译指示:
==========================================
{==+==}

{==+==}
pragma pragma
-------------

The `pragma` pragma can be used to declare user-defined pragmas. This is
useful because Nim's templates and macros do not affect pragmas.
User-defined pragmas are in a different module-wide scope than all other symbols.
They cannot be imported from a module.

Example:
{==+==}
pragma 编译指示
------------------------------

`pragma` 编译指示可以用来声明用户自定义的编译指示。 这是 有用的，因为Nim的模板和宏不会影响编译指示。 用户定义的编译指示与所有其他符号有不同的模块作用域。 它们不能从模块中导入。

示例:

{==+==}

{-----}
  ```nim
  when appType == "lib":
    {.pragma: rtl, exportc, dynlib, cdecl.}
  else:
    {.pragma: rtl, importc, dynlib: "client.dll", cdecl.}

  proc p*(a, b: int): int {.rtl.} =
    result = a + b
  ```
{-----}

{==+==}
In the example, a new pragma named `rtl` is introduced that either imports
a symbol from a dynamic library or exports the symbol for dynamic library
generation.
{==+==}
在上述例子中。 介绍了一个名为 `rtl` 的新的编译指示，它要么从动态库中导入 一个符号，要么导出动态库 生成的符号。
{==+==}

{==+==}
Custom annotations
------------------
It is possible to define custom typed pragmas. Custom pragmas do not affect
code generation directly, but their presence can be detected by macros.
Custom pragmas are defined using templates annotated with pragma `pragma`:
{==+==}
自定义注解
--------------------
这可以定义自定义类型的编译指示。 自定义编译指示不会直接影响 代码生成，但可以被宏检测到。 使用编译指示 `pragma`: 注解模板来定义自定义编译指示。
{==+==}

{-----}
  ```nim
  template dbTable(name: string, table_space: string = "") {.pragma.}
  template dbKey(name: string = "", primary_key: bool = false) {.pragma.}
  template dbForeignKey(t: typedesc) {.pragma.}
  template dbIgnore {.pragma.}
  ```
{-----}

{==+==}
Consider this stylized example of a possible Object Relation Mapping (ORM)
implementation:
{==+==}
考虑一个对象关系映射 (ORM) 的例子 实现:
{==+==}

{-----}
  ```nim
  const tblspace {.strdefine.} = "dev" # switch for dev, test and prod environments

  type
    User {.dbTable("users", tblspace).} = object
      id {.dbKey(primary_key = true).}: int
      name {.dbKey"full_name".}: string
      is_cached {.dbIgnore.}: bool
      age: int

    UserProfile {.dbTable("profiles", tblspace).} = object
      id {.dbKey(primary_key = true).}: int
      user_id {.dbForeignKey: User.}: int
      read_access: bool
      write_access: bool
      admin_access: bool
  ```
{-----}

{==+==}
In this example, custom pragmas are used to describe how Nim objects are
mapped to the schema of the relational database. Custom pragmas can have
zero or more arguments. In order to pass multiple arguments use one of
template call syntaxes. All arguments are typed and follow standard
overload resolution rules for templates. Therefore, it is possible to have
default values for arguments, pass by name, varargs, etc.
{==+==}
在本例中，使用自定义编译指示描述如何将 Nim 对象映射到关系数据库的模式。 自定义编译指示可以有 个或更多参数。 要传递多个参数，请使用 模板调用语法之一。 所有参数都指定类型，并且在模板中遵循标准 重载规则。 因此，可以通过名称、varargs 等指定参数默认值。
{==+==}

{==+==}
Custom pragmas can be used in all locations where ordinary pragmas can be
specified. It is possible to annotate procs, templates, type and variable
definitions, statements, etc.
{==+==}
自定义编译指示可以在所有可以指定原有编译指示的 的地方使用。 可以用来注解proc、模板、类型和变量 定义、语句等。
{==+==}

{==+==}
The macros module includes helpers which can be used to simplify custom pragma
access `hasCustomPragma`, `getCustomPragmaVal`. Please consult the
`macros <macros.html>`_ module documentation for details. These macros are not
magic, everything they do can also be achieved by walking the AST of the object
representation.

More examples with custom pragmas:
{==+==}

宏模块包括可用于简化自定义编译指示 访问 `hasCustomPragma`, `getCustomPragmaVal` 详情请访问 `macros <macros.html>`_ 模块文档。 这些宏并不是 魔法。它们做的一切都可以通过逐个遍历对象 表示的 AST 来实现。

更多自定义编译指示示例:
{==+==}

{==+==}
- Better serialization/deserialization control:
{==+==}
- 更好的序列化/反序列化控制:
{==+==}

{-----}
    ```nim
    type MyObj = object
      a {.dontSerialize.}: int
      b {.defaultDeserialize: 5.}: int
      c {.serializationKey: "_c".}: string
    ```
{-----}

{==+==}
- Adopting type for gui inspector in a game engine:
{==+==}
- 添加类型用于游戏引擎中 gui 检查:
{==+==}

{-----}
    ```nim
    type MyComponent = object
      position {.editable, animatable.}: Vector3
      alpha {.editRange: [0.0..1.0], animatable.}: float32
    ```
{-----}

{==+==}
Macro pragmas
-------------
{==+==}
宏编译指示
--------------------
{==+==}

{==+==}
Macros and templates can sometimes be called with the pragma syntax. Cases
where this is possible include when attached to routine (procs, iterators, etc.)
declarations or routine type expressions. The compiler will perform the
following simple syntactic transformations:
{==+==}

有时可以用编译指示的语法来调用宏和模板。 比如可能可以附加到例程(procs, 迭代器等) 声明或例程类型表达式。 编译器将执行简单的语法转换:
{==+==}

{-----}
  ```nim
  template command(name: string, def: untyped) = discard

  proc p() {.command("print").} = discard
  ```
{-----}

{==+==}
This is translated to:
{==+==}
翻译为:
{==+==}

{-----}
  ```nim
  command("print"):
    proc p() = discard
  ```
{-----}

{-----}
  ```nim
  type
    AsyncEventHandler = proc (x: Event) {.async.}
  ```
{-----}

{==+==}
This is translated to:
{==+==}
翻译为:
{==+==}

{-----}
  ```nim
  type
    AsyncEventHandler = async(proc (x: Event))
  ```
{-----}

{==+==}
When multiple macro pragmas are applied to the same definition, the first one
from left to right will be evaluated. This macro can then choose to keep
the remaining macro pragmas in its output, and those will be evaluated in
the same way.
{==+==}
当多个宏编译指示声明应用在同一个声明上，按对左到右的顺序第一个 声明起作用。 然后，这个宏可以选择在其输出中是否保留其余的宏编译指示，它们将以相同的方式进行计算。
{==+==}

{==+==}
There are a few more applications of macro pragmas, such as in type,
variable and constant declarations, but this behavior is considered to be
experimental and is documented in the `experimental manual
<manual_experimental.html#extended-macro-pragmas>`_ instead.
{==+==}
还有一些宏编译指示的应用例子，例如类型、 变量和常量声明等。 但这种使用方式被认为是 实验性的，所以被记录在 `实验性手册
<manual_experimental.html#extended-macro-pragmas>`_ 中。
{==+==}

{==+==}
Foreign function interface
==========================

Nim's `FFI`:idx: (foreign function interface) is extensive and only the
parts that scale to other future backends (like the LLVM/JavaScript backends)
are documented here.
{==+==}
外部函数接口
========================

Nim 的 `FFI`:idx: (外部函数接口) 很广泛，只有 一部分将会扩展到其他后端(如LLVM/JavaScript 后端) 会在这里被记录。
{==+==}

{==+==}
Importc pragma
--------------
The `importc` pragma provides a means to import a proc or a variable
from C. The optional argument is a string containing the C identifier. If
the argument is missing, the C name is the Nim identifier *exactly as
spelled*:
{==+==}
Importc 编译指示
--------------------------------
`importc` 编译指示提供了从 C 中导入proc 或变量 的手段。 可选参数需要是包含 C 标识符的字符串。 参数缺失，C 的名字就会和Nim标识符*完全一样*:
{==+==}

{-----}
.. code-block::
  proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}
{-----}

{==+==}
When `importc` is applied to a `let` statement it can omit its value which
will then be expected to come from C. This can be used to import a C `const`:c:\:
{==+==}
当 `importc` 被应用在一个 `let` 语句时它可以忽略它的值，然后 取从 C 产生的值。 这可以用于导入 C 的常量 `const`:c:\:
{==+==}

{-----}
.. code-block::
  {.emit: "const int cconst = 42;".}

  let cconst {.importc, nodecl.}: cint

  assert cconst == 42
{-----}

{==+==}
Note that this pragma has been abused in the past to also work in the
JS backend for JS objects and functions. Other backends do provide
the same feature under the same name. Also, when the target language
is not set to C, other pragmas are available:
{==+==}
注意，这个编译指示曾在 JS 后端在 JS 对象和函数上被滥用。 其他后端也用同样的名字提供了相同 功能。 另外，当目标语言 没有设置为 C时，其他编译指示可以使用:
{==+==}

{-----}
 * `importcpp <manual.html#implementation-specific-pragmas-importcpp-pragma>`_
 * `importobjc <manual.html#implementation-specific-pragmas-importobjc-pragma>`_
 * `importjs <manual.html#implementation-specific-pragmas-importjs-pragma>`_
{-----}

{-----}
  ```Nim
  proc p(s: cstring) {.importc: "prefix$1".}
  ```
{-----}

{==+==}
In the example, the external name of `p` is set to `prefixp`. Only ``$1``
is available and a literal dollar sign must be written as ``$$``.
{==+==}
例如， `p` 的外部名称会被设置为 `prefixp`。 只有 `$1` 可用，美元符号必须写成 `$$`。
{==+==}

{==+==}
Exportc pragma
--------------
{==+==}
Exportc 编译指示
--------------------------------
{==+==}

{==+==}
The `exportc` pragma provides a means to export a type, a variable, or a
procedure to C. Enums and constants can't be exported. The optional argument
is a string containing the C identifier. If the argument is missing, the C
name is the Nim identifier *exactly as spelled*:
{==+==}
`exportc` 编译指示提供了一种将类型、变量或 程序导出到 C 的手段。 枚举和常量不能导出。 可选参数 是包含 C 标识符的字符串。 如果参数缺失，C 的名字就会和Nim标识符 *完全一样* :
{==+==}

{-----}
  ```Nim
  proc callme(formatstr: cstring) {.exportc: "callMe", varargs.}
  ```
{-----}

{==+==}
Note that this pragma is somewhat of a misnomer: Other backends do provide
the same feature under the same name.

The string literal passed to `exportc` can be a format string:
{==+==}
请注意这个编译指示有时候不正确:因为其他后端也用相同名称提供了这个功能。

传递到 `exportc` 可以是一个格式化的字符串:
{==+==}

{-----}
  ```Nim
  proc p(s: string) {.exportc: "prefix$1".} =
    echo s
  ```
{-----}

{==+==}
In the example, the external name of `p` is set to `prefixp`. Only ``$1``
is available and a literal dollar sign must be written as ``$$``.

If the symbol should also be exported to a dynamic library, the `dynlib`
pragma should be used in addition to the `exportc` pragma. See
`Dynlib pragma for export <#foreign-function-interface-dynlib-pragma-for-export>`_.
{==+==}

例如， `p` 的外部名称会被设置为 `prefixp`。 只有 `$1` 可用，美元符号必须写成 `$$`。

如果需要符号也应导出到动态库， `dynlib` 编译指示 需要和`exportc` 编译指示一起使用。 请参阅 `Dynlib pragma for export <#foreign-function-interface-dynlib-pragma-for-export>`_。
{==+==}

{==+==}
Extern pragma
-------------
Like `exportc` or `importc`, the `extern` pragma affects name
mangling. The string literal passed to `extern` can be a format string:
{==+==}
Extern 编译指示
------------------------------
像 `exportc` 或 `importc`一样, `extern` 编译指示会影响名称混淆。 传递到 `extern` 可以是一个格式化的字符串:
{==+==}

{-----}
  ```Nim
  proc p(s: string) {.extern: "prefix$1".} =
    echo s
  ```
{-----}

{==+==}
In the example, the external name of `p` is set to `prefixp`. Only ``$1``
is available and a literal dollar sign must be written as ``$$``.
{==+==}
例如， `p` 的外部名称会被设置为 `prefixp`。 只有 `$1` 可用，美元符号必须写成 `$$`。
{==+==}

{==+==}
Bycopy pragma
-------------
{==+==}
Bycopy 编译指示
------------------------------
{==+==}

{==+==}
The `bycopy` pragma can be applied to an object or tuple type and
instructs the compiler to pass the type by value to procs:
{==+==}
`bycopy` 编译指示可以应用于对象或元组类型， 指示编译器按值传递类型到程序中:
{==+==}

{-----}
  ```nim
  type
    Vector {.bycopy.} = object
      x, y, z: float
  ```
{-----}

{==+==}
The Nim compiler automatically determines whether a parameter is passed by value or by reference based on the parameter type's size. If a parameter must be passed by value or by reference, (such as when interfacing with a C library) use the bycopy or byref pragmas.
{==+==}
Nim编译器通过根据参数类型的大小自动决定参数是根据值传递的还是按引用传递的。 如果一个参数必须通过值或引用传递(例如当与 C 库对接时时)，请使用 bycopy 或 byref 编译指示。
{==+==}

{==+==}
Byref pragma
------------
{==+==}
Byref 编译指示
----------------------------
{==+==}

{==+==}
The `byref` pragma can be applied to an object or tuple type and instructs
the compiler to pass the type by reference (hidden pointer) to procs.
{==+==}
`byref` 编译指示可以应用于对象或元组类型， 指示编译器按引用传递类型(隐藏指针)到程序中:
{==+==}

{==+==}
Varargs pragma
--------------
The `varargs` pragma can be applied to procedures only (and procedure
types). It tells Nim that the proc can take a variable number of parameters
after the last specified parameter. Nim string values will be converted to C
strings automatically:
{==+==}
Varargs 编译指示
--------------------------------
`varargs` 编译指示只能应用于程序 (和程序 类型)。 它会告诉Nim, 在最后一个指定的参数之后, proc 还可以接受一个变量作为参数。 Nim 字符串值将会自动转换为 C 的 字符串:
{==+==}


{-----}
  ```Nim
  proc printf(formatstr: cstring) {.nodecl, varargs.}

  printf("hallo %s", "world") # "world" will be passed as C string
  ```
{-----}

{==+==}
Union pragma
------------
The `union` pragma can be applied to any `object` type. It means all
of an object's fields are overlaid in memory. This produces a `union`:c:
instead of a `struct`:c: in the generated C/C++ code. The object declaration
then must not use inheritance or any GC'ed memory but this is currently not
checked.

**Future directions**: GC'ed memory should be allowed in unions and the GC
should scan unions conservatively.
{==+==}
Union 编译指示
----------------------------
`Union` 编译指示可以应用于任意 `object` 类型。 这意味着一个对象字段的所有 都会在内存中被覆盖。 这在生成的 C/C++ 代码中产生了 `union`:c: 而不是 `struct`:c:。 对象声明 不能使用继承或任何 GC 过但目前未检查的内存。

**未来的方向**:应该允许 GC 回收过的内存，而GC 应该保守地扫描 union 共用体。
{==+==}

{==+==}
Packed pragma
-------------
The `packed` pragma can be applied to any `object` type. It ensures
that the fields of an object are packed back-to-back in memory. It is useful
to store packets or messages from/to network or hardware drivers, and for
interoperability with C. Combining packed pragma with inheritance is not
defined, and it should not be used with GC'ed memory (ref's).

**Future directions**: Using GC'ed memory in packed pragma will result in
a static error. Usage with inheritance should be defined and documented.
{==+==}
Packed 编译指示
------------------------------
`packed` 编译指示可以应用于任意 `object` 类型。 它能确保 一个对象的字段在内存中连续打包。 它非常有用， 在用于存储来自/到网络或硬件驱动程序的数据包或消息是，以及 与C的互操作性上。组合 packed 编译指示和继承是不被定义的 定义，也不应与 GC 的内存(引用的)一起使用。

**未来方向**: 在packed 编译指示中使用 GC'ed 内存将导致 静态错误。 继承的用法应加以定义和文档记录。
{==+==}

{==+==}
Dynlib pragma for import
------------------------
With the `dynlib` pragma, a procedure or a variable can be imported from
a dynamic library (``.dll`` files for Windows, ``lib*.so`` files for UNIX).
The non-optional argument has to be the name of the dynamic library:
{==+==}
Dynlib 编译指示用于导入
------------------------------------------------
使用 `dynlib` 编译指示，程序或变量可以从 动态库中导入 (`.dll` Windows 文件, `lib*.so` UNIX 文件)。 必须参数必须是动态库的名称:
{==+==}

{-----}
  ```Nim
  proc gtk_image_new(): PGtkWidget
    {.cdecl, dynlib: "libgtk-x11-2.0.so", importc.}
  ```
{-----}

{==+==}
In general, importing a dynamic library does not require any special linker
options or linking with import libraries. This also implies that no *devel*
packages need to be installed.

The `dynlib` import mechanism supports a versioning scheme:
{==+==}
一般来说，导入动态库不需要任何特殊链接 选项或与导入库链接。 这也意味着不需要安装 *devel* 软件包。

`dynlib` 导入机制支持版本化:
{==+==}

{-----}
  ```nim
  proc Tcl_Eval(interp: pTcl_Interp, script: cstring): int {.cdecl,
    importc, dynlib: "libtcl(|8.5|8.4|8.3).so.(1|0)".}
  ```
{-----}

{==+==}
At runtime, the dynamic library is searched for (in this order)::

  libtcl.so.1
  libtcl.so.0
  libtcl8.5.so.1
  libtcl8.5.so.0
  libtcl8.4.so.1
  libtcl8.4.so.0
  libtcl8.3.so.1
  libtcl8.3.so.0

The `dynlib` pragma supports not only constant strings as an argument but also
string expressions in general:
{==+==}
运行时, 动态库(按此顺序) 搜索:

  libtcl.so.1 libtcl.so.0 libtcl8.5.so.1 libtcl8.5.so.0 libtcl8.4.so.1 libtcl8.4.so.0 libtcl8.3.so.1 libtcl8.3.so.0

`dynlib` 编译指示不仅支持作为参数的常量字符串，而且还支持一般的 字符串表达式:

{==+==}

{-----}
  ```nim
  import std/os

  proc getDllName: string =
    result = "mylib.dll"
    if fileExists(result): return
    result = "mylib2.dll"
    if fileExists(result): return
    quit("could not load dynamic library")

  proc myImport(s: cstring) {.cdecl, importc, dynlib: getDllName().}
  ```
{-----}

{==+==}
**Note**: Patterns like ``libtcl(|8.5|8.4).so`` are only supported in constant
strings, because they are precompiled.
{==+==}
**注意**: 类似`libtcl(|8.5|8.4).so` 只支持常量 字符串，因为它们是预编译的。
{==+==}

{==+==}
**Note**: Passing variables to the `dynlib` pragma will fail at runtime
because of order of initialization problems.
{==+==}
**注意**: 将变量传递到 `dynlib` 编译指示会因为程序初始化的先后顺序，在运行时出错。

{==+==}

{==+==}
**Note**: A `dynlib` import can be overridden with
the `--dynlibOverride:name`:option: command-line option. The
`Compiler User Guide <nimc.html>`_ contains further information.
{==+==}
**注意**: 导入 `dynlib` 会被覆盖当使用 `--dynlibOverride:name`:option: 命令行选项时。 `编译器用户指南 <nimc.html>`_ 包含更多信息。
{==+==}