{==+==}
==========
Nim Manual
==========
{==+==}
==============
Nim手册
==============
{==+==}

{==+==}
:Authors: Andreas Rumpf, Zahary Karadjov
:Version: |nimversion|
{==+==}
:作者: Andreas Rumpf, Zahary Karadjov
:版本: |nimversion|
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
> "Complexity" seems to be a lot like "energy": you can transfer it from the
> end-user to one/some of the other players, but the total amount seems to remain
> pretty much constant for a given task. -- Ran
{==+==}
> "复杂性" 如同 "能量": 终端用户把它转嫁给其他参与者，但给定任务的总量似乎没变。 -- Ran
{==+==}

{==+==}
About this document
===================
{==+==}
关于手册
===============
{==+==}

{==+==}
**Note**: This document is a draft! Several of Nim's features may need more
precise wording. This manual is constantly evolving into a proper specification.
{==+==}
**注意**: 当前手册还是草案! Nim的一些功能需要更加准确的描述。本手册也在不断更新，以成为标准规范。
{==+==}

{==+==}
**Note**: The experimental features of Nim are
covered `here <manual_experimental.html>`_.
{==+==}
**注意**: 这里包含Nim的 `实验性功能 <manual_experimental.html>`_ 。
{==+==}

{==+==}
**Note**: Assignments, moves, and destruction are specified in
the `destructors <destructors.html>`_ document.
{==+==}
**注意**: 赋值、移动和析构在特定的 `析构文档 <destrtors.html>`_ 部分。
{==+==}

{==+==}
This document describes the lexis, the syntax, and the semantics of the Nim language.
{==+==}
当前手册描述了Nim语言的词法、语法和语义。
{==+==}

{==+==}
To learn how to compile Nim programs and generate documentation see
the `Compiler User Guide <nimc.html>`_ and the `DocGen Tools Guide <docgen.html>`_.
{==+==}
要学习如何编译Nim程序和生成文档，请阅读 `编译器用户指南 <nimc.html>`_ 和 `文档生成工具指南 <docgen.html>`_ 。
{==+==}

{==+==}
The language constructs are explained using an extended BNF, in which `(a)*`
means 0 or more `a`'s, `a+` means 1 or more `a`'s, and `(a)?` means an
optional *a*. Parentheses may be used to group elements.
{==+==}
Nim语言结构使用"扩展BNF"解释， `(a)*` 表示0个或多个 `a` ， `a+` 表示1个或多个 `a` ， `(a)?` 表示一个可选的 *a* ，圆括号用来元素分组。
{==+==}

{==+==}
`&` is the lookahead operator; `&a` means that an `a` is expected but
not consumed. It will be consumed in the following rule.
{==+==}
`&` 是查找运算符； `&a` 表示期望一个 `a` ，但没有用掉，而在之后的规则中被消耗。
{==+==}

{==+==}
The `|`, `/` symbols are used to mark alternatives and have the lowest
precedence. `/` is the ordered choice that requires the parser to try the
alternatives in the given order. `/` is often used to ensure the grammar
is not ambiguous.
{==+==}
 `|` 和 `/` 符号用来标记备选，优先级最低。`/` 是有序的选择，要求解析器按照给定的顺序来尝试备选项，`/` 常用来消除语法歧义。
{==+==}

{==+==}
Non-terminals start with a lowercase letter, abstract terminal symbols are in
UPPERCASE. Verbatim terminal symbols (including keywords) are quoted
with `'`. An example::
{==+==}
非终端符号以小写字母开头，抽象的终端符号字母大写，逐字的终端符号(包括关键词)用 `'` 引号。例如:
{==+==}

{==+==}
  ifStmt = 'if' expr ':' stmts ('elif' expr ':' stmts)* ('else' stmts)?
{==+==}
  ifStmt = 'if' expr ':' stmts ('elif' expr ':' stmts)* ('else' stmts)?
{==+==}

{==+==}
The binary `^*` operator is used as a shorthand for 0 or more occurrences
separated by its second argument; likewise `^+` means 1 or more
occurrences: `a ^+ b` is short for `a (b a)*`
and `a ^* b` is short for `(a (b a)*)?`. Example::

  arrayConstructor = '[' expr ^* ',' ']'
{==+==}
二元 `^*` 运算符表示为0或更多，由第二个参数分开；`^+` 表示着1或更多。 `a ^+ b` 是 `a (b a)*` 的简写， `a ^* b` 则是 `(a (b a)*)?` 的简写。 例如::

  arrayConstructor = '[' expr ^* ',' ']'
{==+==}

{==+==}
Other parts of Nim, like scoping rules or runtime semantics, are
described informally.
{==+==}
Nim的其他，如作用域规则或运行时语义，使用非标准描述。
{==+==}


{==+==}
Definitions
===========
{==+==}
定义
========
{==+==}

{==+==}
Nim code specifies a computation that acts on a memory consisting of
components called `locations`:idx:. A variable is basically a name for a
location. Each variable and location is of a certain `type`:idx:. The
variable's type is called `static type`:idx:, the location's type is called
`dynamic type`:idx:. If the static type is not the same as the dynamic type,
it is a super-type or subtype of the dynamic type.
{==+==}
Nim代码是特定的计算单元，作用于称为 `locations`:idx: "地址"组件构成的内存。变量本质上是地址的名称，每个变量和地址都有特定的 `type`:idx: "类型"，变量的类型被称为 `static type`:idx: "静态类型"，地址的类型被称为 `dynamic type`:idx: "动态类型"。如果静态类型与动态类型不相同，它就是动态类型的父类或子类。
{==+==}


{==+==}
An `identifier`:idx: is a symbol declared as a name for a variable, type,
procedure, etc. The region of the program over which a declaration applies is
called the `scope`:idx: of the declaration. Scopes can be nested. The meaning
of an identifier is determined by the smallest enclosing scope in which the
identifier is declared unless overloading resolution rules suggest otherwise.
{==+==}
 `identifier`:idx: "标识符"是变量、类型、过程等的名称声明符号，一个声明所适用的程序区域被称为该声明的 `scope`:idx: "作用域"，作用域可以嵌套，一个标识符的含义由标识符所声明的最小包围作用域决定，除非重载解析规则另有建议。
{==+==}

{==+==}
An expression specifies a computation that produces a value or location.
Expressions that produce locations are called `l-values`:idx:. An l-value
can denote either a location or the value the location contains, depending on
the context.
{==+==}
一个表达式特指产生值或地址的计算，产生地址的表达式被称为 `l-values`:idx: "左值"，左值可以表示地址，也可以表示该地址包含的值，这取决于上下文。
{==+==}

{==+==}
A Nim `program`:idx: consists of one or more text `source files`:idx: containing
Nim code. It is processed by a Nim `compiler`:idx: into an `executable`:idx:.
The nature of this executable depends on the compiler implementation; it may,
for example, be a native binary or JavaScript source code.
{==+==}
Nim `program`:idx: "程序"由一个或多个包含Nim代码的文本 `source files`:idx: "源文件"组成，由Nim `compiler`:idx: "编译器"处理成 `executable`:idx: "可执行的"，这个可执行文件的性质取决于编译器的实现；例如，它可能是一个本地二进制文件或JavaScript源代码。
{==+==}

{==+==}
In a typical Nim program, most of the code is compiled into the executable.
However, some code may be executed at
`compile-time`:idx:. This can include constant expressions, macro definitions,
and Nim procedures used by macro definitions. Most of the Nim language is
supported at compile-time, but there are some restrictions -- see `Restrictions
on Compile-Time Execution <#restrictions-on-compileminustime-execution>`_ for
details. We use the term `runtime`:idx: to cover both compile-time execution
and code execution in the executable.
{==+==}
在典型的Nim程序中，大部分代码被编译到可执行文件中，然而，有些代码可能在 `compile-time`:idx: "编译期"执行，包括常量表达式、宏定义和宏定义使用的Nim过程。大部分的Nim代码支持编译期执行，但是有一些限制 -- 详情阅读 `关于编译时执行的限制 <#restrictions-on-compileminustime-execution>`_ 。我们使用术语 `runtime`:idx: "运行时"来涵盖编译期执行和可执行文件中的代码执行。
{==+==}

{==+==}
The compiler parses Nim source code into an internal data structure called the
`abstract syntax tree`:idx: (`AST`:idx:). Then, before executing the code or
compiling it into the executable, it transforms the AST through
`semantic analysis`:idx:. This adds semantic information such as expression types,
identifier meanings, and in some cases expression values. An error detected
during semantic analysis is called a `static error`:idx:. Errors described in
this manual are static errors when not otherwise specified.
{==+==}
编译器将Nim源代码解析成一个内部数据结构，称为 `abstract syntax tree`:idx: (`AST`:idx:) "抽象语法树"，在执行代码或将其编译为可执行文件之前，通过 `semantic analysis`:idx: "语义分析"对AST进行转换，增加了语义信息，如表达式类型、标识符的含义，以及在某些情况下的表达式值。在语义分析中检测到的错误被称为 `static error`:idx: "静态错误"，当前手册中描述的错误在没有其他约定时，是静态错误。
{==+==}

{==+==}
A `panic`:idx: is an error that the implementation detects
and reports at runtime. The method for reporting such errors is via
*raising exceptions* or *dying with a fatal error*. However, the implementation
provides a means to disable these `runtime checks`:idx:. See the section
pragmas_ for details.
{==+==}
`panic`:idx: "恐慌"是在运行时检测和报告的错误，报告这种错误的方式是通过 *引发异常* 或 *致命错误* 结束，也提供了一种方法来禁用 `runtime checks`:idx: "运行时检查"，详情阅读标记一节。
{==+==}

{==+==}
Whether a panic results in an exception or in a fatal error is
implementation specific. Thus, the following program is invalid; even though the
code purports to catch the `IndexDefect` from an out-of-bounds array access, the
compiler may instead choose to allow the program to die with a fatal error.
{==+==}
恐慌的结果是一个异常还是一个致命的错误，是特定实现，因此，下面的程序无效，尽管代码试图捕获越界访问数组的 `IndexDefect` ，但编译器可能会以致命错误终结程序。
{==+==}

{==+==}
  ```nim
  var a: array[0..1, char]
  let i = 5
  try:
    a[i] = 'N'
  except IndexDefect:
    echo "invalid index"
  ```
{==+==}
  ```nim
  var a: array[0..1, char]
  let i = 5
  try:
    a[i] = 'N'
  except IndexDefect:
    echo "invalid index"
  ```
{==+==}

{==+==}
The current implementation allows switching between these different behaviors
via `--panics:on|off`:option:. When panics are turned on, the program dies with a
panic, if they are turned off the runtime errors are turned into
exceptions. The benefit of `--panics:on`:option: is that it produces smaller binary
code and the compiler has more freedom to optimize the code.
{==+==}
目前允许通过 `--panics:on|off`:option: 在不同方式之间切换，打开时，程序会因恐慌而终结，关闭时，运行时的错误会变为异常。 `--panics:on`:option: 的好处是产生更小的二进制代码，编译器可以更自由地优化。
{==+==}

{==+==}
An `unchecked runtime error`:idx: is an error that is not guaranteed to be
detected and can cause the subsequent behavior of the computation to
be arbitrary. Unchecked runtime errors cannot occur if only `safe`:idx:
language features are used and if no runtime checks are disabled.
{==+==}
`unchecked runtime error`:idx: "未检查的运行时错误"是不能保证被检测到的错误，它可能导致计算产生意外后果，如果只使用 `safe`:idx: "安全"语言特性，并且没有禁用运行时检查，就不会产生未检查的运行时错误。
{==+==}

{==+==}
A `constant expression`:idx: is an expression whose value can be computed during
a semantic analysis of the code in which it appears. It is never an l-value and
never has side effects. Constant expressions are not limited to the capabilities
of semantic analysis, such as constant folding; they can use all Nim language
features that are supported for compile-time execution. Since constant
expressions can be used as an input to semantic analysis (such as for defining
array bounds), this flexibility requires the compiler to interleave semantic
analysis and compile-time code execution.
{==+==}
`constant expression`:idx: "常量表达式"在对包含它的代码进行语义分析时，值就可以被计算出来。它从来不会是左值，也不会有副作用。常量表达式并不局限于语义分析的能力，例如常量折叠。它可以使用所支持的编译期执行的所有Nim语言特性。由于常量表达式可以作为语义分析时的输入，比如用于定义数组的边界，因为这种灵活性的要求，编译器交错进行语义分析和编译时代码执行。
{==+==}

{==+==}
It is mostly accurate to picture semantic analysis proceeding top to bottom and
left to right in the source code, with compile-time code execution interleaved
when necessary to compute values that are required for subsequent semantic
analysis. We will see much later in this document that macro invocation not only
requires this interleaving, but also creates a situation where semantic analysis
does not entirely proceed top to bottom and left to right.
{==+==}
想象一下，语义分析在源代码中从上到下、从左到右地进行，而在必要的时候，为了计算后续语义分析所需要的数值，编译期的代码交错执行，这一点非常明确。我们将在本文的后面看到，宏调用不仅需要这种交错，而且还产生了，语义分析并不完全是自上而下、自左而右地进行的情况。
{==+==}

{==+==}
Lexical Analysis
================
{==+==}
词法分析
================
{==+==}

{==+==}
Encoding
--------
{==+==}
编码
--------
{==+==}

{==+==}
All Nim source files are in the UTF-8 encoding (or its ASCII subset). Other
encodings are not supported. Any of the standard platform line termination
sequences can be used - the Unix form using ASCII LF (linefeed), the Windows
form using the ASCII sequence CR LF (return followed by linefeed), or the old
Macintosh form using the ASCII CR (return) character. All of these forms can be
used equally, regardless of the platform.
{==+==}
所有的Nim源文件都采用UTF-8编码(或其ASCII子集)，不支持其他编码。可以使用任何标准平台的线性终端序列 —— Unix形式使用ASCII LF(换行)，Windows形式使用ASCII序列CR LF(换行后返回)，或旧的Macintosh形式使用ASCII CR(返回)字符，无论在什么平台上，这些形式都可以无差别地使用。
{==+==}

{==+==}
Indentation
-----------
{==+==}
缩进
--------
{==+==}

{==+==}
Nim's standard grammar describes an `indentation sensitive`:idx: language.
This means that all the control structures are recognized by indentation.
Indentation consists only of spaces; tabulators are not allowed.
{==+==}
Nim的标准语法描述了 `indentation sensitive`:idx: "缩进敏感"的语言特性，表示其所有的控制结构可以通过缩进来识别，缩进只包括空格，不允许使用制表符。
{==+==}

{==+==}
The indentation handling is implemented as follows: The lexer annotates the
following token with the preceding number of spaces; indentation is not
a separate token. This trick allows parsing of Nim with only 1 token of
lookahead.
{==+==}
缩进处理的实现方式如下，词法分析器用前导空格数来解释之后的标记，缩进不是单独的一个标记，这个技巧使得Nim解析时只需要向前查看1个token。
{==+==}

{==+==}
The parser uses a stack of indentation levels: the stack consists of integers
counting the spaces. The indentation information is queried at strategic
places in the parser but ignored otherwise: The pseudo-terminal `IND{>}`
denotes an indentation that consists of more spaces than the entry at the top
of the stack; `IND{=}` an indentation that has the same number of spaces. `DED`
is another pseudo terminal that describes the *action* of popping a value
from the stack, `IND{>}` then implies to push onto the stack.
{==+==}
语法分析器使用一个缩进级别的堆栈：该堆栈由计算空格的整数组成，语法分析器在对应的策略位置查询缩进信息，但忽略其他地方。伪终端 `IND{>}` 表示缩进比堆栈顶部的条目包含更多的空格， `IND{=}` 表示缩进有相同的空格数，`DED` 是另一个伪终端，表示从堆栈中弹出一个值的 *action* 动作， `IND{>}` 则意味着推到堆栈中。
{==+==}

{==+==}
With this notation we can now easily define the core of the grammar: A block of
statements (simplified example)::

  ifStmt = 'if' expr ':' stmt
           (IND{=} 'elif' expr ':' stmt)*
           (IND{=} 'else' ':' stmt)?

  simpleStmt = ifStmt / ...

  stmt = IND{>} stmt ^+ IND{=} DED  # list of statements
       / simpleStmt                 # or a simple statement
{==+==}
用这个标记，我们现在可以很容易地定义核心语法：语句块(这是简化的例子)::

  ifStmt = 'if' expr ':' stmt
           (IND{=} 'elif' expr ':' stmt)*
           (IND{=} 'else' ':' stmt)?

  simpleStmt = ifStmt / ...

  stmt = IND{>} stmt ^+ IND{=} DED  # 语句列表
       / simpleStmt                 # 或者单个语句
{==+==}

{==+==}
Comments
--------
{==+==}
注释
--------
{==+==}

{==+==}
Comments start anywhere outside a string or character literal with the
hash character `#`.
Comments consist of a concatenation of `comment pieces`:idx:. A comment piece
starts with `#` and runs until the end of the line. The end of line characters
belong to the piece. If the next line only consists of a comment piece with
no other tokens between it and the preceding one, it does not start a new
comment:
{==+==}
注释在字符串或字符字面值之外的任意位置，以 `#` 字符开头，注释由 `comment pieces`:idx: "注释段"连接组成，一个注释段以 `#` 开始直到行尾，包括行末的字符。如果下一行只由一个注释段组成，在它和前面的注释段之间没有其他标记，就不会开启一个新的注释。
{==+==}

{==+==}
  ```nim
  i = 0     # This is a single comment over multiple lines.
    # The lexer merges these two pieces.
    # The comment continues here.
  ```
{==+==}
  ```nim
  i = 0     # 这是一个多行注释。
    # 词法分析器将这两部分合并在一起。
    # 注释在这里继续。
  ```
{==+==}

{==+==}
`Documentation comments`:idx: are comments that start with two `##`.
Documentation comments are tokens; they are only allowed at certain places in
the input file as they belong to the syntax tree.
{==+==}
`Documentation comments`:idx: "文档注释"以两个 `##` 开头，文档注释是token标记，它们属于语法树，只允许在输入文件的某些地方出现。
{==+==}


{==+==}
Multiline comments
------------------
{==+==}
多行注释
----------------
{==+==}

{==+==}
Starting with version 0.13.0 of the language Nim supports multiline comments.
They look like:
{==+==}
从0.13.0版本的语言开始，Nim支持多行注释。如下:
{==+==}

{==+==}
  ```nim
  #[Comment here.
  Multiple lines
  are not a problem.]#
  ```
{==+==}
  ```nim
  #[Comment here.
  Multiple lines
  are not a problem.]#
  ```
{==+==}

{==+==}
Multiline comments support nesting:
{==+==}
多行注释支持嵌套:
{==+==}

{==+==}
  ```nim
  #[  #[ Multiline comment in already
     commented out code. ]#
  proc p[T](x: T) = discard
  ]#
  ```
{==+==}
  ```nim
  #[  #[ Multiline comment in already
     commented out code. ]#
  proc p[T](x: T) = discard
  ]#
  ```
{==+==}

{==+==}
Multiline documentation comments also exist and support nesting too:
{==+==}
还有多行文档注释，同样支持嵌套:
{==+==}

{==+==}
  ```nim
  proc foo =
    ##[Long documentation comment
       here.
    ]##
  ```
{==+==}
  ```nim
  proc foo =
    ##[Long documentation comment
       here.
    ]##
  ```
{==+==}

{==+==}
Identifiers & Keywords
----------------------
{==+==}
标识符和关键字
----------------------------
{==+==}

{==+==}
Identifiers in Nim can be any string of letters, digits
and underscores, with the following restrictions:
{==+==}
Nim中的标识符可以是任何字母、数字和下划线组成的字符串，但有以下限制:
{==+==}

{==+==}
* begins with a letter
* does not end with an underscore `_`
* two immediate following underscores `__` are not allowed:
{==+==}
* 以一个字母开头
* 不允许下划线 `_` 结尾
* 不允许两个下划线 `__` 结尾。
{==+==}

{==+==}
  ```
  letter ::= 'A'..'Z' | 'a'..'z' | '\x80'..'\xff'
  digit ::= '0'..'9'
  IDENTIFIER ::= letter ( ['_'] (letter | digit) )*
  ```
{==+==}
  ```
  letter ::= 'A'..'Z' | 'a'..'z' | '\x80'..'\xff'
  digit ::= '0'..'9'
  IDENTIFIER ::= letter ( ['_'] (letter | digit) )*
  ```
{==+==}

{==+==}
Currently, any Unicode character with an ordinal value > 127 (non-ASCII) is
classified as a `letter` and may thus be part of an identifier but later
versions of the language may assign some Unicode characters to belong to the
operator characters instead.
{==+==}
目前，任何序数值大于127的Unicode字符(非ASCII)都被归类为 `letter` "字"，因而可以做为标识符的一部分，但以后的语言版本可能会将一些Unicode字符指定为运算符。
{==+==}

{==+==}
The following keywords are reserved and cannot be used as identifiers:

  ```nim file="keywords.txt"
  ```
{==+==}
以下关键词被保留，不能作为标识符使用:

  ```nim file="keywords.txt"
  ```
{==+==}

{==+==}
Some keywords are unused; they are reserved for future developments of the
language.
{==+==}
有些关键词还未使用，它们被保留，提供语言未来拓展。
{==+==}

{==+==}
Identifier equality
-------------------
{==+==}
标识符相等
--------------------
{==+==}

{==+==}
Two identifiers are considered equal if the following algorithm returns true:
{==+==}
如果以下算法返回真，则认为两个标识符相等:
{==+==}

{==+==}
  ```nim
  proc sameIdentifier(a, b: string): bool =
    a[0] == b[0] and
      a.replace("_", "").toLowerAscii == b.replace("_", "").toLowerAscii
  ```
{==+==}
  ```nim
  proc sameIdentifier(a, b: string): bool =
    a[0] == b[0] and
      a.replace("_", "").toLowerAscii == b.replace("_", "").toLowerAscii
  ```
{==+==}

{==+==}
That means only the first letters are compared in a case-sensitive manner. Other
letters are compared case-insensitively within the ASCII range and underscores are ignored.
{==+==}
这意味着，在进行比较时，只有第一个字母是区分大小写的，其他字母在ASCII范围内不区分大小，下划线被忽略。
{==+==}

{==+==}
This rather unorthodox way to do identifier comparisons is called
`partial case-insensitivity`:idx: and has some advantages over the conventional
case sensitivity:
{==+==}
这种相当非正统的标识符比较方式被称为 `partial case-insensitivity`:idx: "部分大小写不敏感"，比传统的大小写敏感有一些优势。
{==+==}

{==+==}
It allows programmers to mostly use their own preferred
spelling style, be it humpStyle or snake_style, and libraries written
by different programmers cannot use incompatible conventions.
A Nim-aware editor or IDE can show the identifiers as preferred.
Another advantage is that it frees the programmer from remembering
the exact spelling of an identifier. The exception with respect to the first
letter allows common code like `var foo: Foo` to be parsed unambiguously.
{==+==}
它允许程序员大多使用他们自己喜欢的拼写风格。不管是humpStyle"驼峰风格"还是snake_style"蛇形风格"，不同程序员编写的库不能使用不兼容的约定。一个按Nim思考的编辑器或IDE可以显示首选的标识符，另一个好处是，它使程序员不必记住标识符的准确拼写。第一个字母例外，是允许常见的如 `var foo: Foo` 这样的普通代码可以被明确地解析出来。
{==+==}

{==+==}
Note that this rule also applies to keywords, meaning that `notin` is
the same as `notIn` and `not_in` (all-lowercase version (`notin`, `isnot`)
is the preferred way of writing keywords).
{==+==}
注意这个规则也适用于关键字，也就是说 `notin` 与 `notIn` 和 `not_in` 相同 (关键字书写方式首选全小写 (`notin`, `isnot`) )。
{==+==}

{==+==}
Historically, Nim was a fully `style-insensitive`:idx: language. This meant that
it was not case-sensitive and underscores were ignored and there was not even a
distinction between `foo` and `Foo`.
{==+==}
Nim曾经是一种完全 `style-insensitive`:idx: "大小写不敏感"的语言，这意味着它不区分大小写，忽略下划线，甚至 `foo` 和 `Foo` 之间没有区别。
{==+==}

{==+==}
Keywords as identifiers
-----------------------
{==+==}
作为标识符的关键词
------------------------------------
{==+==}

{==+==}
If a keyword is enclosed in backticks it loses its keyword property and becomes an ordinary identifier.
{==+==}
如果一个关键词被括在反撇号里，它就失去了关键词的属性，变成了一个普通的标识符。
{==+==}

{==+==}
Examples

  ```nim
  var `var` = "Hello Stropping"
  ```

  ```nim
  type Obj = object
    `type`: int

  let `object` = Obj(`type`: 9)
  assert `object` is Obj
  assert `object`.`type` == 9

  var `var` = 42
  let `let` = 8
  assert `var` + `let` == 50

  const `assert` = true
  assert `assert`
  ```
{==+==}
Examples

  ```nim
  var `var` = "Hello Stropping"
  ```

  ```nim
  type Obj = object
    `type`: int

  let `object` = Obj(`type`: 9)
  assert `object` is Obj
  assert `object`.`type` == 9

  var `var` = 42
  let `let` = 8
  assert `var` + `let` == 50

  const `assert` = true
  assert `assert`
  ```
{==+==}

{==+==}
String literals
---------------
{==+==}
字符串字面值
------------------------
{==+==}

{==+==}
Terminal symbol in the grammar: `STR_LIT`.
{==+==}
语法中的终端符号: `STR_LIT` .
{==+==}

{==+==}
String literals can be delimited by matching double quotes, and can
contain the following `escape sequences`:idx:\ :
{==+==}
字符串可以用配对的双引号来分隔，可以包含以下 `escape sequences`:idx:\ "转义字符":
{==+==}

{==+==}
==================         ===================================================
  Escape sequence          Meaning
==================         ===================================================
  ``\p``                   platform specific newline: CRLF on Windows,
                           LF on Unix
  ``\r``, ``\c``           `carriage return`:idx:
  ``\n``, ``\l``           `line feed`:idx: (often called `newline`:idx:)
  ``\f``                   `form feed`:idx:
  ``\t``                   `tabulator`:idx:
  ``\v``                   `vertical tabulator`:idx:
  ``\\``                   `backslash`:idx:
  ``\"``                   `quotation mark`:idx:
  ``\'``                   `apostrophe`:idx:
  ``\`` '0'..'9'+          `character with decimal value d`:idx:;
                           all decimal digits directly
                           following are used for the character
  ``\a``                   `alert`:idx:
  ``\b``                   `backspace`:idx:
  ``\e``                   `escape`:idx: `[ESC]`:idx:
  ``\x`` HH                `character with hex value HH`:idx:;
                           exactly two hex digits are allowed
  ``\u`` HHHH              `unicode codepoint with hex value HHHH`:idx:;
                           exactly four hex digits are allowed
  ``\u`` {H+}              `unicode codepoint`:idx:;
                           all hex digits enclosed in `{}` are used for
                           the codepoint
==================         ===================================================
{==+==}
==================         ==============================================================================
  转义字符                 含义
==================         ==============================================================================
  ``\p``                   平台特定的换行符:Windows上的CRLF, Unix上的LF
  ``\r``, ``\c``           `carriage return`:idx: 回车
  ``\n``, ``\l``           `line feed`:idx: 换行(通常叫创建新行 `newline`:idx:)
  ``\f``                   `form feed`:idx: 换页
  ``\t``                   `tabulator`:idx: 制表符
  ``\v``                   `vertical tabulator`:idx: 垂直制表符
  ``\\``                   `backslash`:idx: 反斜线
  ``\"``                   `quotation mark`:idx: 双引号
  ``\'``                   `apostrophe`:idx: 撇号
  ``\`` '0'..'9'+          `character with decimal value d`:idx:; 十进制值字符
                           后面的所有十进制数字都用于该字符
  ``\a``                   `alert`:idx: 警报
  ``\b``                   `backspace`:idx: 退格符
  ``\e``                   `escape`:idx: `[ESC]`:idx:
  ``\x`` HH                `character with hex value HH`:idx: ; 十进制值HH
                           只允许两个十六进制数字
  ``\u`` HHHH              `unicode codepoint with hex value HHHH`:idx:; 十进制值HHHH
                           只允许四个十六进制数字
  ``\u`` {H+}              `unicode codepoint`:idx:; unicode字码元素
                           包含在 `{}` 中的所有十六进制数字都用于字码元素
==================         ==============================================================================
{==+==}

{==+==}
Strings in Nim may contain any 8-bit value, even embedded zeros. However,
some operations may interpret the first binary zero as a terminator.
{==+==}
Nim中的字符串可以包含任意8-bit值，甚至嵌入零，然而，某此操作可能会将第一个二进制零解释为终止符。
{==+==}

{==+==}
Triple quoted string literals
-----------------------------
{==+==}
三重引用字符串字面值
----------------------------------------
{==+==}

{==+==}
Terminal symbol in the grammar: `TRIPLESTR_LIT`.
{==+==}
语法中的终端符号: `TRIPLESTR_LIT`.
{==+==}

{==+==}
String literals can also be delimited by three double quotes `"""` ... `"""`.
Literals in this form may run for several lines, may contain `"` and do not
interpret any escape sequences.
For convenience, when the opening `"""` is followed by a newline (there may
be whitespace between the opening `"""` and the newline),
the newline (and the preceding whitespace) is not included in the string. The
ending of the string literal is defined by the pattern `"""[^"]`, so this:
{==+==}
字符串也可以用三个双引号 `"""` ... `"""` 来分隔，这种形式的字面值支持多行，可以包含 `"` ，并且不解释任何转义字符，为了方便，开头 `"""` 后面换行符以及空格并不包括在字符串中，字符串的结尾定义为 `"""[^"]` 模式，所以如下:
{==+==}

{==+==}
  ```nim
  """"long string within quotes""""
  ```
{==+==}
  ```nim
  """"long string within quotes""""
  ```
{==+==}

{==+==}
Produces::

  "long string within quotes"
{==+==}
产生::

  "long string within quotes"
{==+==}

{==+==}
Raw string literals
-------------------
{==+==}
原始字符串
--------------------
{==+==}

{==+==}
Terminal symbol in the grammar: `RSTR_LIT`.
{==+==}
语法中的终端符号: `RSTR_LIT` 。
{==+==}

{==+==}
There are also raw string literals that are preceded with the
letter `r` (or `R`) and are delimited by matching double quotes (just
like ordinary string literals) and do not interpret the escape sequences.
This is especially convenient for regular expressions or Windows paths:
{==+==}
还有一些原始的字符串字面值，前面为字母 `r` 或 `R` ，并匹配一对双引号的普通字符串，不解释转义字符，这用在正则表达式或Windows中的路径时很方便。
{==+==}

{==+==}
  ```nim
  var f = openFile(r"C:\texts\text.txt") # a raw string, so ``\t`` is no tab
  ```
{==+==}
  ```nim
  var f = openFile(r"C:\texts\text.txt") # a raw string, so ``\t`` is no tab
  ```
{==+==}

{==+==}
To produce a single `"` within a raw string literal, it has to be doubled:
{==+==}
要在原始字符串字面值中含有 `"` 则必须成双。
{==+==}

{==+==}
  ```nim
  r"a""b"
  ```
{==+==}
  ```nim
  r"a""b"
  ```
{==+==}

{==+==}
Produces::

  a"b
{==+==}
产生::

  a"b
{==+==}

{==+==}
`r""""` is not possible with this notation, because the three leading
quotes introduce a triple quoted string literal. `r"""` is the same
as `"""` since triple quoted string literals do not interpret escape
sequences either.
{==+==}
不能用 `r""""` 这个标记，因为原始字符串中引入了三引号的字符串字面值。 `r"""` 与 `"""` 是相同的，三引号原始字符串字面值也不解释转义字符。
{==+==}

{==+==}
Generalized raw string literals
-------------------------------
{==+==}
广义的原始字符串字面值
--------------------------------------------
{==+==}

{==+==}
Terminal symbols in the grammar: `GENERALIZED_STR_LIT`,
`GENERALIZED_TRIPLESTR_LIT`.
{==+==}
语法中的终端符号: `GENERALIZED_STR_LIT` , `GENERALIZED_TRIPLESTR_LIT` .
{==+==}

{==+==}
The construct `identifier"string literal"` (without whitespace between the
identifier and the opening quotation mark) is a
generalized raw string literal. It is a shortcut for the construct
`identifier(r"string literal")`, so it denotes a routine call with a
raw string literal as its only argument. Generalized raw string literals
are especially convenient for embedding mini languages directly into Nim
(for example regular expressions).
{==+==}
 `identifier"string literal"` (标识符和开头的引号之间没有空格) 结构是广义的原始字符串字面值。它是 `identifier(r"string literal")` 构造的简写方式，它表示以原始字符串字面值为唯一参数的常规调用。广义的原始字符串字面值的意义，在于方便的将mini语言直接嵌入到Nim中，例如正则表达式。
{==+==}

{==+==}
The construct `identifier"""string literal"""` exists too. It is a shortcut
for `identifier("""string literal""")`.
{==+==}
还有 `identifier"""string literal"""` 结构，是 `identifier("""string literal""")` 的简写方式。
{==+==}

{==+==}
Character literals
------------------
{==+==}
字符字面值
--------------------
{==+==}

{==+==}
Character literals are enclosed in single quotes `''` and can contain the
same escape sequences as strings - with one exception: the platform
dependent `newline`:idx: (``\p``)
is not allowed as it may be wider than one character (it can be the pair
CR/LF). Here are the valid `escape sequences`:idx: for character
literals:
{==+==}
字符串用单引号 `''` 括起来，可以包含与字符串相同的转义字符 —— 但有一种例外：不允许与平台有关的 `newline`:idx: (``\p``) "换行符"，因为它可能比一个字符宽(它可能是一对CR/LF)。下面是有效的 `escape sequences`:idx: "转义字符"字面值。
{==+==}

{==+==}
==================         ===================================================
  Escape sequence          Meaning
==================         ===================================================
  ``\r``, ``\c``           `carriage return`:idx:
  ``\n``, ``\l``           `line feed`:idx:
  ``\f``                   `form feed`:idx:
  ``\t``                   `tabulator`:idx:
  ``\v``                   `vertical tabulator`:idx:
  ``\\``                   `backslash`:idx:
  ``\"``                   `quotation mark`:idx:
  ``\'``                   `apostrophe`:idx:
  ``\`` '0'..'9'+          `character with decimal value d`:idx:;
                           all decimal digits directly
                           following are used for the character
  ``\a``                   `alert`:idx:
  ``\b``                   `backspace`:idx:
  ``\e``                   `escape`:idx: `[ESC]`:idx:
  ``\x`` HH                `character with hex value HH`:idx:;
                           exactly two hex digits are allowed
==================         ===================================================
{==+==}
==================         =================================================================================
  转义字符                 含义
==================         =================================================================================
  ``\r``, ``\c``           `carriage return`:idx: 回车
  ``\n``, ``\l``           `line feed`:idx: 换行(通常叫创建新行 `newline`:idx:)
  ``\f``                   `form feed`:idx: 换页
  ``\t``                   `tabulator`:idx: 制表符
  ``\v``                   `vertical tabulator`:idx: 垂直制表符
  ``\\``                   `backslash`:idx: 反斜线
  ``\"``                   `quotation mark`:idx: 双引号
  ``\'``                   `apostrophe`:idx: 撇号
  ``\`` '0'..'9'+          `character with decimal value d`:idx:; 十进制值字符
                           后面的所有十进制数字都用于该字符
  ``\a``                   `alert`:idx: 警报
  ``\b``                   `backspace`:idx: 退格符
  ``\e``                   `escape`:idx: `[ESC]`:idx:
  ``\x`` HH                `character with hex value HH`:idx:; 十进制值HH
                           只允许两个十六进制数字
==================         =================================================================================
{==+==}

{==+==}
A character is not a Unicode character but a single byte.
{==+==}
一个字符不是一个Unicode字符，而是一个单字节。
{==+==}

{==+==}
Rationale: It enables the efficient support of `array[char, int]` or
`set[char]`.
{==+==}
原由：为了能够有效地支持 `array[char, int]` 和 `set[char]` 。
{==+==}

{==+==}
The `Rune` type can represent any Unicode character.
`Rune` is declared in the `unicode module <unicode.html>`_.
{==+==}
 `Rune` 类型可以代表任意Unicode字符，`Rune` 声明在 `unicode module <unicode.html>`_ 中。
{==+==}

{==+==}
A character literal that does not end in `'` is interpreted as `'` if there
is a preceding backtick token. There must be no whitespace between the preceding
backtick token and the character literal. This special case ensures that a declaration
like ``proc `'customLiteral`(s: string)`` is valid. ``proc `'customLiteral`(s: string)``
is the same as ``proc `'\''customLiteral`(s: string)``.
{==+==}
如果前面有一个回车符，那么不以 `'` 结尾的字符字面值将被解释为 `'` ，此时前面的回车符和字符字面值之间不能有空格，这种特殊情况是为了保证像 ``proc `'customLiteral`(s: string)`` 这样的声明有效。 ``proc `'customLiteral`(s: string)`` 与 ``proc `'\''customLiteral`(s: string)`` 相同。
{==+==}

{==+==}
See also `custom numeric literals <#custom-numeric-literals>`_.
{==+==}
参考阅读 `自定义数值字面值 <#custom-numeric-literals>`_ 。
{==+==}

{==+==}
Numeric literals
----------------
{==+==}
数值字面值
--------------------
{==+==}

{==+==}
Numeric literals have the form::
{==+==}
数值字面值具有这种形式::
{==+==}

{==+==}
  hexdigit = digit | 'A'..'F' | 'a'..'f'
  octdigit = '0'..'7'
  bindigit = '0'..'1'
  unary_minus = '-' # See the section about unary minus
  HEX_LIT = unary_minus? '0' ('x' | 'X' ) hexdigit ( ['_'] hexdigit )*
  DEC_LIT = unary_minus? digit ( ['_'] digit )*
  OCT_LIT = unary_minus? '0' 'o' octdigit ( ['_'] octdigit )*
  BIN_LIT = unary_minus? '0' ('b' | 'B' ) bindigit ( ['_'] bindigit )*

  INT_LIT = HEX_LIT
          | DEC_LIT
          | OCT_LIT
          | BIN_LIT

  INT8_LIT = INT_LIT ['\''] ('i' | 'I') '8'
  INT16_LIT = INT_LIT ['\''] ('i' | 'I') '16'
  INT32_LIT = INT_LIT ['\''] ('i' | 'I') '32'
  INT64_LIT = INT_LIT ['\''] ('i' | 'I') '64'

  UINT_LIT = INT_LIT ['\''] ('u' | 'U')
  UINT8_LIT = INT_LIT ['\''] ('u' | 'U') '8'
  UINT16_LIT = INT_LIT ['\''] ('u' | 'U') '16'
  UINT32_LIT = INT_LIT ['\''] ('u' | 'U') '32'
  UINT64_LIT = INT_LIT ['\''] ('u' | 'U') '64'

  exponent = ('e' | 'E' ) ['+' | '-'] digit ( ['_'] digit )*
  FLOAT_LIT = unary_minus? digit (['_'] digit)* (('.' digit (['_'] digit)* [exponent]) |exponent)
  FLOAT32_SUFFIX = ('f' | 'F') ['32']
  FLOAT32_LIT = HEX_LIT '\'' FLOAT32_SUFFIX
              | (FLOAT_LIT | DEC_LIT | OCT_LIT | BIN_LIT) ['\''] FLOAT32_SUFFIX
  FLOAT64_SUFFIX = ( ('f' | 'F') '64' ) | 'd' | 'D'
  FLOAT64_LIT = HEX_LIT '\'' FLOAT64_SUFFIX
              | (FLOAT_LIT | DEC_LIT | OCT_LIT | BIN_LIT) ['\''] FLOAT64_SUFFIX

  CUSTOM_NUMERIC_LIT = (FLOAT_LIT | INT_LIT) '\'' CUSTOM_NUMERIC_SUFFIX
{==+==}
  hexdigit = digit | 'A'..'F' | 'a'..'f'
  octdigit = '0'..'7'
  bindigit = '0'..'1'
  unary_minus = '-' # See the section about unary minus
  HEX_LIT = unary_minus? '0' ('x' | 'X' ) hexdigit ( ['_'] hexdigit )*
  DEC_LIT = unary_minus? digit ( ['_'] digit )*
  OCT_LIT = unary_minus? '0' 'o' octdigit ( ['_'] octdigit )*
  BIN_LIT = unary_minus? '0' ('b' | 'B' ) bindigit ( ['_'] bindigit )*

  INT_LIT = HEX_LIT
          | DEC_LIT
          | OCT_LIT
          | BIN_LIT

  INT8_LIT = INT_LIT ['\''] ('i' | 'I') '8'
  INT16_LIT = INT_LIT ['\''] ('i' | 'I') '16'
  INT32_LIT = INT_LIT ['\''] ('i' | 'I') '32'
  INT64_LIT = INT_LIT ['\''] ('i' | 'I') '64'

  UINT_LIT = INT_LIT ['\''] ('u' | 'U')
  UINT8_LIT = INT_LIT ['\''] ('u' | 'U') '8'
  UINT16_LIT = INT_LIT ['\''] ('u' | 'U') '16'
  UINT32_LIT = INT_LIT ['\''] ('u' | 'U') '32'
  UINT64_LIT = INT_LIT ['\''] ('u' | 'U') '64'

  exponent = ('e' | 'E' ) ['+' | '-'] digit ( ['_'] digit )*
  FLOAT_LIT = unary_minus? digit (['_'] digit)* (('.' digit (['_'] digit)* [exponent]) |exponent)
  FLOAT32_SUFFIX = ('f' | 'F') ['32']
  FLOAT32_LIT = HEX_LIT '\'' FLOAT32_SUFFIX
              | (FLOAT_LIT | DEC_LIT | OCT_LIT | BIN_LIT) ['\''] FLOAT32_SUFFIX
  FLOAT64_SUFFIX = ( ('f' | 'F') '64' ) | 'd' | 'D'
  FLOAT64_LIT = HEX_LIT '\'' FLOAT64_SUFFIX
              | (FLOAT_LIT | DEC_LIT | OCT_LIT | BIN_LIT) ['\''] FLOAT64_SUFFIX

  CUSTOM_NUMERIC_LIT = (FLOAT_LIT | INT_LIT) '\'' CUSTOM_NUMERIC_SUFFIX
{==+==}

{==+==}
  # CUSTOM_NUMERIC_SUFFIX is any Nim identifier that is not
  # a pre-defined type suffix.
{==+==}
  # CUSTOM_NUMERIC_SUFFIX 是任意非预定义类型后缀的Nim标识符。
{==+==}
  
{==+==}
As can be seen in the productions, numeric literals can contain underscores
for readability. Integer and floating-point literals may be given in decimal (no
prefix), binary (prefix `0b`), octal (prefix `0o`), and hexadecimal
(prefix `0x`) notation.
{==+==}
从描述中可以看出，数值字面值可以包含下划线，以便于阅读。整数和浮点数可以用十进制(无前缀)、二进制(前缀 `0b` )、八进制(前缀 `0o` )和十六进制(前缀 `0x` )标记表示。
{==+==}

{==+==}
The fact that the unary minus `-` in a number literal like `-1` is considered
to be part of the literal is a late addition to the language. The rationale is that
an expression `-128'i8` should be valid and without this special case, this would
be impossible -- `128` is not a valid `int8` value, only `-128` is.
{==+==}
像 `-1` 这样的数值字面值中的一元减号 `-` 是字面值的一部分，这是后来添加到语言中的，原因是表达式 `-128'i8` 应该是有效的。如果没有这种特殊情况，则这将不被允许 -- `128` 不是有效的 `int8` 值，只有 `-128` 是有效的。
{==+==}

{==+==}
For the `unary_minus` rule there are further restrictions that are not covered
in the formal grammar. For `-` to be part of the number literal the immediately
preceding character has to be in the
set `{' ', '\t', '\n', '\r', ',', ';', '(', '[', '{'}`. This set was designed to
cover most cases in a natural manner.
{==+==}
对于 `unary_minus` 规则，有一些限制，但在正式语法中没有提及。 `-` 是数值字面值的一部分时，前面的字符必须在 `{' ', '\t', '\n', '\r', ',', ';', '(', '[', '{'}` 集合中，这个设计是为了更合理的方式涵盖大多数情况。
{==+==}

{==+==}
In the following examples, `-1` is a single token:
{==+==}
在下面的例子中， `-1` 是一个单独的token标记:
{==+==}

{==+==}
  ```nim
  echo -1
  echo(-1)
  echo [-1]
  echo 3,-1

  "abc";-1
  ```
{==+==}
  ```nim
  echo -1
  echo(-1)
  echo [-1]
  echo 3,-1

  "abc";-1
  ```
{==+==}

{==+==}
In the following examples, `-1` is parsed as two separate tokens
(as `-`:tok: `1`:tok:):
{==+==}
在下面的例子中， `-1` 被解析为两个独立的token标记( `-`:tok: `1`:tok: ):
{==+==}

{==+==}
  ```nim
  echo x-1
  echo (int)-1
  echo [a]-1
  "abc"-1
  ```
{==+==}
  ```nim
  echo x-1
  echo (int)-1
  echo [a]-1
  "abc"-1
  ```
{==+==}

{==+==}
The suffix starting with an apostrophe ('\'') is called a
`type suffix`:idx:. Literals without a type suffix are of an integer type
unless the literal contains a dot or `E|e` in which case it is of
type `float`. This integer type is `int` if the literal is in the range
`low(int32)..high(int32)`, otherwise it is `int64`.
For notational convenience, the apostrophe of a type suffix
is optional if it is not ambiguous (only hexadecimal floating-point literals
with a type suffix can be ambiguous).
{==+==}
以撇号 ('\'') 开始的后缀被称为 `type suffix`:idx: "类型后缀"。没有类型后缀的字面值是整数类型，当包含一个点或 `E|e` ，那么它是 `float` 类型。如果字面值的范围在 `low(int32)..high(int32)` ，那么这个整数类型就是 `int` ，否则就是 `int64` 。为了记数方便，如果类型后缀明确，那么后缀的撇号是可选的(只有带类型后缀的十六进制浮点数字面值含义才会不明确)。
{==+==}

{==+==}
The pre-defined type suffixes are:
{==+==}
预定义的类型后缀有:
{==+==}

{==+==}
=================    =========================
  Type Suffix        Resulting type of literal
=================    =========================
  `'i8`              int8
  `'i16`             int16
  `'i32`             int32
  `'i64`             int64
  `'u`               uint
  `'u8`              uint8
  `'u16`             uint16
  `'u32`             uint32
  `'u64`             uint64
  `'f`               float32
  `'d`               float64
  `'f32`             float32
  `'f64`             float64
=================    =========================
{==+==}
=================    ====================================================
  类型后缀           产生的字面值类型
=================    ====================================================
  `'i8`              int8
  `'i16`             int16
  `'i32`             int32
  `'i64`             int64
  `'u`               uint
  `'u8`              uint8
  `'u16`             uint16
  `'u32`             uint32
  `'u64`             uint64
  `'f`               float32
  `'d`               float64
  `'f32`             float32
  `'f64`             float64
=================    ====================================================
{==+==}

{==+==}
Floating-point literals may also be in binary, octal or hexadecimal
notation:
`0B0_10001110100_0000101001000111101011101111111011000101001101001001'f64`
is approximately 1.72826e35 according to the IEEE floating-point standard.
{==+==}
浮点数字面值也可以采用二进制、八进制或十六进制的标记:
`0B0_10001110100_0000101001000111101011101111111011000101001101001001'f64` 
根据IEEE浮点标准，约为1.72826e35。
{==+==}

{==+==}
Literals must match the datatype, for example, `333'i8` is an invalid literal.
Non-base-10 literals are used mainly for flags and bit pattern representations,
therefore the checking is done on bit width and not on value range.
Hence: 0b10000000'u8 == 0x80'u8 == 128, but, 0b10000000'i8 == 0x80'i8 == -1
instead of causing an overflow error.
{==+==}
字面值必须匹配数据类型，例如， `333'i8` 是一个无效的字面值。以非10进制表示的字面值主要用于标记和比特位模式，因此检查是对位宽而不是值范围进行的，因此: 0b10000000'u8 == 0x80'u8 == 128，但是， 0b10000000'i8 == 0x80'i8 == -128 而不是 -1。
{==+==}

{==+==}
### Custom numeric literals
{==+==}
### 自定义数值字面值
{==+==}

{==+==}
If the suffix is not predefined, then the suffix is assumed to be a call
to a proc, template, macro or other callable identifier that is passed the
string containing the literal. The callable identifier needs to be declared
with a special ``'`` prefix:
{==+==}
如果后缀不是预定义标记，那么后缀会被认为是对proc过程、template模板、macro宏或其他可调用标识符的调用，包含字面值的字符串被传递给该标识符。可调用标识符需要用一个特殊的 ``'`` 前缀来声明。
{==+==}

{==+==}
  ```nim
  import strutils
  type u4 = distinct uint8 # a 4-bit unsigned integer aka "nibble"
  proc `'u4`(n: string): u4 =
    # The leading ' is required.
    result = (parseInt(n) and 0x0F).u4

  var x = 5'u4
  ```
{==+==}
  ```nim
  import strutils
  type u4 = distinct uint8 # 一个4位无符号整数，又称 "nibble"
  proc `'u4`(n: string): u4 =
    # 这是必需的。
    result = (parseInt(n) and 0x0F).u4

  var x = 5'u4
  ```
{==+==}

{==+==}
More formally, a custom numeric literal `123'custom` is transformed
to r"123".`'custom` in the parsing step. There is no AST node kind that
corresponds to this transformation. The transformation naturally handles
the case that additional parameters are passed to the callee:
{==+==}
更确切地说，一个自定义的数值字面值 `123'custom` 在解析步骤中被转换为 r"123".`'custom` 。并没有对应于这种转换的AST节点种类，这种转换合理地处理了额外参数被传递给被调用者的情况。
{==+==}

{==+==}
  ```nim
  import strutils
  type u4 = distinct uint8 # a 4-bit unsigned integer aka "nibble"
  proc `'u4`(n: string; moreData: int): u4 =
    result = (parseInt(n) and 0x0F).u4

  var x = 5'u4(123)
  ```
{==+==}
  ```nim
  import strutils
  type u4 = distinct uint8 # 4位无符号整数，又称 "nibble"
  proc `'u4`(n: string; moreData: int): u4 =
    result = (parseInt(n) and 0x0F).u4

  var x = 5'u4(123)
  ```
{==+==}

{==+==}
Custom numeric literals are covered by the grammar rule named `CUSTOM_NUMERIC_LIT`.
A custom numeric literal is a single token.
{==+==}
自定义数值字面值由名称为 `CUSTOM_NUMERIC_LIT` 的语法规则涵盖。一个自定义的数值字面值是单独的token标记。
{==+==}

{==+==}
Operators
---------
{==+==}
运算符
------------
{==+==}

{==+==}
Nim allows user defined operators. An operator is any combination of the
following characters::
{==+==}
Nim允许用户定义运算符。运算符可以是以下字符的任意组合::
{==+==}

{==+==}
       =     +     -     *     /     <     >
       @     $     ~     &     %     |
       !     ?     ^     .     :     \
{==+==}
       =     +     -     *     /     <     >
       @     $     ~     &     %     |
       !     ?     ^     .     :     \
{==+==}

{==+==}
(The grammar uses the terminal OPR to refer to operator symbols as
defined here.)
{==+==}
(语法中使用终端OPR来指代这里定义的运算符符号。)
{==+==}

{==+==}
These keywords are also operators:
`and or not xor shl shr div mod in notin is isnot of as from`.
{==+==}
这些关键字也是运算符:
`and or not xor shl shr div mod in notin is isnot of as from` 。
{==+==}

{==+==}
`.`:tok:, `=`:tok:, `:`:tok:, `::`:tok: are not available as general operators; they
are used for other notational purposes.
{==+==}
`.`:tok:, `=`:tok:, `:`:tok:, `::`:tok: 不能作为一般运算符使用; 它们的目的是被用于其他符号。
{==+==}

{==+==}
`*:` is as a special case treated as the two tokens `*`:tok: and `:`:tok:
(to support `var v*: T`).
{==+==}
`*:` 是特殊情况处理为两个token标记 `*`:tok: 和 `:`:tok: (是为了支持 `var v*: T`)。
{==+==}

{==+==}
The `not` keyword is always a unary operator, `a not b` is parsed
as `a(not b)`, not as `(a) not (b)`.
{==+==}
`not` 关键字始终是一元运算符, `a not b` 解析为 `a(not b)` , 并不是 `(a) not (b)` 。
{==+==}

{==+==}
Other tokens
------------
{==+==}
其他标记
----------------
{==+==}

{==+==}
The following strings denote other tokens::
{==+==}
以下字符串表示其他标记::
{==+==}

{==+==}
    `   (    )     {    }     [    ]    ,  ;   [.    .]  {.   .}  (.  .)  [:
{==+==}
    `   (    )     {    }     [    ]    ,  ;   [.    .]  {.   .}  (.  .)  [:
{==+==}

{==+==}
The `slice`:idx: operator `..`:tok: takes precedence over other tokens that
contain a dot: `{..}` are the three tokens `{`:tok:, `..`:tok:, `}`:tok:
and not the two tokens `{.`:tok:, `.}`:tok:.
{==+==}
 `slice`:idx: "切片"运算符 `..`:tok: 优先于其他包含点的标记: `{..}` 是三个标记 `{`:tok:, `..`:tok:, `}`:tok: 而不是两个标记 `{.`:tok:, `.}`:tok: 。
{==+==}

{==+==}
Syntax
======
{==+==}
句法
========
{==+==}

{==+==}
This section lists Nim's standard syntax. How the parser handles
the indentation is already described in the `Lexical Analysis`_ section.
{==+==}
本节列出了Nim的标准句法。语法分析器如何处理缩进的问题已经在 `Lexical Analysis`_ "词法分析"一节中描述过了。
{==+==}

{==+==}
Nim allows user-definable operators.
Binary operators have 11 different levels of precedence.
{==+==}
Nim允许用户定义运算符。二元运算符有11个不同的优先级。
{==+==}

{==+==}
Associativity
-------------
{==+==}
结合律
------------
{==+==}

{==+==}
Binary operators whose first character is `^` are right-associative, all
other binary operators are left-associative.
{==+==}
第一个字符为 `^` 的二元运算符是右结合，所有其他二元运算符是左结合。
{==+==}

{==+==}
  ```nim
  proc `^/`(x, y: float): float =
    # a right-associative division operator
    result = x / y
  echo 12 ^/ 4 ^/ 8 # 24.0 (4 / 8 = 0.5, then 12 / 0.5 = 24.0)
  echo 12  / 4  / 8 # 0.375 (12 / 4 = 3.0, then 3 / 8 = 0.375)
  ```
{==+==}
  ```nim
  proc `^/`(x, y: float): float =
    # 右结合除法运算符
    result = x / y
  echo 12 ^/ 4 ^/ 8 # 24.0 (4 / 8 = 0.5, then 12 / 0.5 = 24.0)
  echo 12  / 4  / 8 # 0.375 (12 / 4 = 3.0, then 3 / 8 = 0.375)
  ```
{==+==}

{==+==}
Precedence
----------
{==+==}
优先级
------------
{==+==}

{==+==}
Unary operators always bind stronger than any binary
operator: `$a + b` is `($a) + b` and not `$(a + b)`.
{==+==}
一元运算符总是比任何二元运算符结合性更强: `$a + b` 是 `($a) + b` 而不是 `$(a + b)` 。
{==+==}

{==+==}
If a unary operator's first character is `@` it is a `sigil-like`:idx:
operator which binds stronger than a `primarySuffix`: `@x.abc` is parsed
as `(@x).abc` whereas `$x.abc` is parsed as `$(x.abc)`.
{==+==}
如果一个一元运算符的第一个字符是 `@` ，它就是一个 `sigil-like`:idx: "缩写"运算符，比 `primarySuffix` 的结合性更强: `@x.abc` 被解析为 `(@x).abc` ，而 `$x.abc` 被解析为 `$(x.abc)` 。 
{==+==}

{==+==}
For binary operators that are not keywords, the precedence is determined by the
following rules:
{==+==}
对于不是关键字的二元运算符，优先级由以下规则决定:
{==+==}

{==+==}
Operators ending in either `->`, `~>` or `=>` are called
`arrow like`:idx:, and have the lowest precedence of all operators.
{==+==}
以 `->` 、 `~>` 或 `=>` 结尾的运算符被称为 `arrow like`:idx: "箭头"，在所有运算符中优先级最低。
{==+==}

{==+==}
If the operator ends with `=` and its first character is none of
`<`, `>`, `!`, `=`, `~`, `?`, it is an *assignment operator* which
has the second-lowest precedence.
{==+==}
如果运算符以 `=` 结尾，并且其第一个字符不是 `<`, `>`, `!`, `=`, `~`, `?` 中的任意一个，那么它就是一个 *赋值运算符* ，具有第二低的优先级。
{==+==}

{==+==}
Otherwise, precedence is determined by the first character.
{==+==}
否则，优先级由第一个字符决定。
{==+==}

{==+==}
================  =======================================================  ==================  ===============
Precedence level    Operators                                              First character     Terminal symbol
================  =======================================================  ==================  ===============
 10 (highest)                                                              `$  ^`              OP10
  9               `*    /    div   mod   shl  shr  %`                      `*  %  \  /`        OP9
  8               `+    -`                                                 `+  -  ~  |`        OP8
  7               `&`                                                      `&`                 OP7
  6               `..`                                                     `.`                 OP6
  5               `==  <= < >= > !=  in notin is isnot not of as from`     `=  <  >  !`        OP5
  4               `and`                                                                        OP4
  3               `or xor`                                                                     OP3
  2                                                                        `@  :  ?`           OP2
  1               *assignment operator* (like `+=`, `*=`)                                      OP1
  0 (lowest)      *arrow like operator* (like `->`, `=>`)                                      OP0
================  =======================================================  ==================  ===============
{==+==}
================  =======================================================  =========================  ====================
优先级            运算符                                                   第一个字符                 终端符号
================  =======================================================  =========================  ====================
 10 (最高)                                                                 `$  ^`                     OP10
  9               `*    /    div   mod   shl  shr  %`                      `*  %  \  /`               OP9
  8               `+    -`                                                 `+  -  ~  |`               OP8
  7               `&`                                                      `&`                        OP7
  6               `..`                                                     `.`                        OP6
  5               `==  <= < >= > !=  in notin is isnot not of as from`     `=  <  >  !`               OP5
  4               `and`                                                                               OP4
  3               `or xor`                                                                            OP3
  2                                                                        `@  :  ?`                  OP2
  1               *赋值运算符* (如 `+=`, `*=`)                                                        OP1
  0 (最低)        *箭头运算符* (like `->`, `=>`)                                                      OP0
================  =======================================================  =========================  ====================
{==+==}

{==+==}
Whether an operator is used as a prefix operator is also affected by preceding
whitespace (this parsing change was introduced with version 0.13.0):
{==+==}
一个运算符是否被用作前缀运算符，也会受到前面的空格影响 (这个解析变化是在0.13.0版本中引入的) 。
{==+==}

{==+==}
  ```nim
  echo $foo
  # is parsed as
  echo($foo)
  ```
{==+==}
  ```nim
  echo $foo
  # 解析为
  echo($foo)
  ```
{==+==}

{==+==}
Spacing also determines whether `(a, b)` is parsed as an argument list
of a call or whether it is parsed as a tuple constructor:
{==+==}
空格也决定了 `(a, b)` 是被解析为一个调用的参数列表，还是被解析为一个元组构造。
{==+==}

{==+==}
  ```nim
  echo(1, 2) # pass 1 and 2 to echo

  ```nim
  echo (1, 2) # pass the tuple (1, 2) to echo
{==+==}
  ```nim
  echo(1, 2) # 传递1和2给echo

  ```nim
  echo (1, 2) # 传递元组(1, 2)给echo
{==+==}

{==+==}
Dot-like operators
------------------
{==+==}
点类运算符
--------------------
{==+==}

{==+==}
Terminal symbol in the grammar: `DOTLIKEOP`.
{==+==}
语法中的终端符号: `DOTLIKEOP` 。
{==+==}

{==+==}
Dot-like operators are operators starting with `.`, but not with `..`, for e.g. `.?`;
they have the same precedence as `.`, so that `a.?b.c` is parsed as `(a.?b).c` instead of `a.?(b.c)`.
{==+==}
点类运算符是以 `.` 开头的运算符，但不是以 `..` 开头的，例如 `.?` ，它们的优先级与 `.` 相同，因此 `a.?b.c` 被解析为 `(a.?b).c` ，而不是 `a.? (b.c)` 。
{==+==}

{==+==}
Grammar
-------
{==+==}
语法
--------
{==+==}

{==+==}
The grammar's start symbol is `module`.
{==+==}
语法的起始符号是 `module` 。
{==+==}

{==+==}
.. include:: grammar.txt
   :literal:
{==+==}
.. include:: grammar.txt
   :literal:
{==+==}

{==+==}
Order of evaluation
===================
{==+==}
求值顺序
===================
{==+==}

{==+==}
Order of evaluation is strictly left-to-right, inside-out as it is typical for most others
imperative programming languages:
{==+==}
求值顺序严格从左到右，由内到外，这是大多数其他强类型编程语言的典型做法:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var s = ""

  proc p(arg: int): int =
    s.add $arg
    result = arg

  discard p(p(1) + p(2))

  doAssert s == "123"
  ```
{==+==}
  ```nim  test = "nim c $1"
  var s = ""

  proc p(arg: int): int =
    s.add $arg
    result = arg

  discard p(p(1) + p(2))

  doAssert s == "123"
  ```
{==+==}

{==+==}
Assignments are not special, the left-hand-side expression is evaluated before the
right-hand side:
{==+==}
赋值也不特殊，左边的表达式在右边的表达式之前被求值:
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var v = 0
  proc getI(): int =
    result = v
    inc v

  var a, b: array[0..2, int]

  proc someCopy(a: var int; b: int) = a = b

  a[getI()] = getI()

  doAssert a == [1, 0, 0]

  v = 0
  someCopy(b[getI()], getI())

  doAssert b == [1, 0, 0]
  ```
{==+==}
  ```nim  test = "nim c $1"
  var v = 0
  proc getI(): int =
    result = v
    inc v

  var a, b: array[0..2, int]

  proc someCopy(a: var int; b: int) = a = b

  a[getI()] = getI()

  doAssert a == [1, 0, 0]

  v = 0
  someCopy(b[getI()], getI())

  doAssert b == [1, 0, 0]
  ```
{==+==}

{==+==}
Rationale: Consistency with overloaded assignment or assignment-like operations,
`a = b` can be read as `performSomeCopy(a, b)`.
{==+==}
原由：与重载赋值或类似赋值的运算符保持一致，`a = b` 可以理解为 `performSomeCopy(a, b)` 。
{==+==}

{==+==}
However, the concept of "order of evaluation" is only applicable after the code
was normalized: The normalization involves template expansions and argument
reorderings that have been passed to named parameters:
{==+==}
然而，"求值顺序" 的概念只有在代码被规范化之后才适用。规范化涉及到模板的扩展和参数的重新排序，这些参数已经被传递给了命名参数。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  var s = ""

  proc p(): int =
    s.add "p"
    result = 5

  proc q(): int =
    s.add "q"
    result = 3

  # Evaluation order is 'b' before 'a' due to template
  # expansion's semantics.
  template swapArgs(a, b): untyped =
    b + a

  doAssert swapArgs(p() + q(), q() - p()) == 6
  doAssert s == "qppq"

  # Evaluation order is not influenced by named parameters:
  proc construct(first, second: int) =
    discard

  # 'p' is evaluated before 'q'!
  construct(second = q(), first = p())

  doAssert s == "qppqpq"
  ```
{==+==}
  ```nim  test = "nim c $1"
  var s = ""

  proc p(): int =
    s.add "p"
    result = 5

  proc q(): int =
    s.add "q"
    result = 3

  # 由于模板扩展的语义，求值顺序是 'b' 在 'a' 之前。
  template swapArgs(a, b): untyped =
    b + a

  doAssert swapArgs(p() + q(), q() - p()) == 6
  doAssert s == "qppq"

  # 求值顺序不受命名参数的影响:
  proc construct(first, second: int) =
    discard

  # 'p' 在 'q' 之前求值!
  construct(second = q(), first = p())

  doAssert s == "qppqpq"
  ```
{==+==}

{==+==}
Rationale: This is far easier to implement than hypothetical alternatives.
{==+==}
原由:这比设想的替代方案容易实现得多。
{==+==}

{==+==}
Constants and Constant Expressions
==================================
{==+==}
常量和常量表达式
================================
{==+==}

{==+==}
A `constant`:idx: is a symbol that is bound to the value of a constant
expression. Constant expressions are restricted to depend only on the following
categories of values and operations, because these are either built into the
language or declared and evaluated before semantic analysis of the constant
expression:
{==+==}
`constant`:idx: "常量"是一个与常量表达式的值绑定的符号。常量表达式被限制为只依赖于以下类别的值和运算，因为这些值和运算要么被内置在语言中，要么在对常量表达式进行语义分析之前被声明和求值。
{==+==}

{==+==}
* literals
* built-in operators
* previously declared constants and compile-time variables
* previously declared macros and templates
* previously declared procedures that have no side effects beyond
  possibly modifying compile-time variables
{==+==}
* 字面值
* 内置运算符
* 先前声明的常量和编译时变量
* 先前声明的宏和模板
* 先前声明的过程，除了可能修改编译时变量外，没有任何副作用
{==+==}

{==+==}
A constant expression can contain code blocks that may internally use all Nim
features supported at compile time (as detailed in the next section below).
Within such a code block, it is possible to declare variables and then later
read and update them, or declare variables and pass them to procedures that
modify them. However, the code in such a block must still adhere to the
restrictions listed above for referencing values and operations outside the
block.
{==+==}
常量表达式可以包含代码块，这些代码块是可以在内部使用编译时支持的所有Nim功能(详见下面的章节)。在这样的代码块中，可以声明变量，随后读取和更新它们，或者声明变量并将它们传递给其修改值的过程。这样的代码块中的代码，仍须遵守上面列出的关于引用该代码块外的值和运算的限制。
{==+==}

{==+==}
The ability to access and modify compile-time variables adds flexibility to
constant expressions that may be surprising to those coming from other
statically typed languages. For example, the following code echoes the beginning
of the Fibonacci series **at compile-time**. (This is a demonstration of
flexibility in defining constants, not a recommended style for solving this
problem.)
{==+==}
访问和修改编译时变量的能力为常量表达式增加了灵活性，这会让那些来自其他静态类型语言的人惊讶。例如，下面的代码在 **编译时** 返回斐波那契数列的起始。(这是对定义常量灵活性的演示，而不是对解决这个问题的推荐风格)。
{==+==}

{==+==}
  ```nim  test = "nim c $1"
  import std/strformat

  var fibN {.compileTime.}: int
  var fibPrev {.compileTime.}: int
  var fibPrevPrev {.compileTime.}: int

  proc nextFib(): int =
    result = if fibN < 2:
      fibN
    else:
      fibPrevPrev + fibPrev
    inc(fibN)
    fibPrevPrev = fibPrev
    fibPrev = result

  const f0 = nextFib()
  const f1 = nextFib()

  const displayFib = block:
    const f2 = nextFib()
    var result = fmt"Fibonacci sequence: {f0}, {f1}, {f2}"
    for i in 3..12:
      add(result, fmt", {nextFib()}")
    result

  static:
    echo displayFib
  ```
{==+==}
  ```nim  test = "nim c $1"
  import std/strformat

  var fibN {.compileTime.}: int
  var fibPrev {.compileTime.}: int
  var fibPrevPrev {.compileTime.}: int

  proc nextFib(): int =
    result = if fibN < 2:
      fibN
    else:
      fibPrevPrev + fibPrev
    inc(fibN)
    fibPrevPrev = fibPrev
    fibPrev = result

  const f0 = nextFib()
  const f1 = nextFib()

  const displayFib = block:
    const f2 = nextFib()
    var result = fmt"Fibonacci sequence: {f0}, {f1}, {f2}"
    for i in 3..12:
      add(result, fmt", {nextFib()}")
    result

  static:
    echo displayFib
  ```
{==+==}

{==+==}
Restrictions on Compile-Time Execution
======================================
{==+==}
对编译时执行的限制
====================================
{==+==}

{==+==}
Nim code that will be executed at compile time cannot use the following
language features:
{==+==}
编译时执行的Nim代码不能使用以下语言特性:
{==+==}

{==+==}
* methods
* closure iterators
* the `cast` operator
* reference (pointer) types
* FFI
{==+==}
* methods 方法
* closure iterators 闭包迭代器 
* `cast` 运算符
* 引用 (指针) 类型
* FFI
{==+==}

{==+==}
The use of wrappers that use FFI and/or `cast` is also disallowed. Note that
these wrappers include the ones in the standard libraries.
{==+==}
不允许使用 FFI 和/或 `cast` 的包装器。请注意，这些包装器包括标准库中的包装器。
{==+==}

{==+==}
Some or all of these restrictions are likely to be lifted over time.
{==+==}
随着时间的推移，部分或所有这些限制可能会被取消。
{==+==}

{==+==}
Types
=====
{==+==}
类型
========
{==+==}

{==+==}
All expressions have a type that is known during semantic analysis. Nim
is statically typed. One can declare new types, which is in essence defining
an identifier that can be used to denote this custom type.
{==+==}
在语义分析中是已知的，所有的表达式都有一个类型。Nim是静态类型语言。可以声明新的类型，这实质上是定义了一个标识符，用来表示这个自定义类型。
{==+==}

{==+==}
These are the major type classes:
{==+==}
这些是主要的类型分类:
{==+==}

{==+==}
* ordinal types (consist of integer, bool, character, enumeration
  (and subranges thereof) types)
* floating-point types
* string type
* structured types
* reference (pointer) type
* procedural type
* generic type
{==+==}
* 序数类型(包括整数、布尔、字符、枚举、枚举子范围)
* 浮点类型
* 字符串类型
* 结构化类型
* 引用(指针)类型
* 过程类型
* 通用类型
{==+==}