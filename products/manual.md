==============
Nim手册
==============

:作者: Andreas Rumpf, Zahary Karadjov
:版本: |nimversion|

.. default-role:: code
.. include:: rstcommon.rst
.. contents::


> "复杂性" 如同 "能量": 终端用户把它转嫁给其他参与者，但给定任务的总量似乎没变。 -- Ran


关于手册
===============

**注意**: 当前手册还是草案! Nim的一些功能需要更加准确的描述。本手册也在不断更新，以成为标准规范。

**注意**: 这里包含Nim的 `实验性功能 <manual_experimental.html>`_ 。

**注意**: 赋值、移动和析构在特定的 `析构文档 <destrtors.html>`_ 部分。


当前手册描述了Nim语言的词法、语法和语义。

要学习如何编译Nim程序和生成文档，请阅读 `编译器用户指南 <nimc.html>`_ 和 `文档生成工具指南 <docgen.html>`_ 。

Nim语言结构使用"扩展BNF"解释， `(a)*` 表示0个或多个 `a` ， `a+` 表示1个或多个 `a` ， `(a)?` 表示一个可选的 *a* ，圆括号用来元素分组。

`&` 是查找运算符； `&a` 表示期望一个 `a` ，但没有用掉，而在之后的规则中被消耗。

 `|` 和 `/` 符号用来标记备选，优先级最低。`/` 是有序的选择，要求解析器按照给定的顺序来尝试备选项，`/` 常用来消除语法歧义。

非终端符号以小写字母开头，抽象的终端符号字母大写，逐字的终端符号(包括关键词)用 `'` 引号。例如:

  ifStmt = 'if' expr ':' stmts ('elif' expr ':' stmts)* ('else' stmts)?

二元 `^*` 运算符表示为0或更多，由第二个参数分开；`^+` 表示着1或更多。 `a ^+ b` 是 `a (b a)*` 的简写， `a ^* b` 则是 `(a (b a)*)?` 的简写。 例如::

  arrayConstructor = '[' expr ^* ',' ']'

Nim的其他，如作用域规则或运行时语义，使用非标准描述。




定义
========

Nim代码是特定的计算单元，作用于称为 `locations`:idx: "地址"组件构成的内存。变量本质上是地址的名称，每个变量和地址都有特定的 `type`:idx: "类型"，变量的类型被称为 `static type`:idx: "静态类型"，地址的类型被称为 `dynamic type`:idx: "动态类型"。如果静态类型与动态类型不相同，它就是动态类型的父类或子类。

 `identifier`:idx: "标识符"是变量、类型、过程等的名称声明符号，一个声明所适用的程序区域被称为该声明的 `scope`:idx: "作用域"，作用域可以嵌套，一个标识符的含义由标识符所声明的最小包围作用域决定，除非重载解析规则另有建议。

一个表达式特指产生值或地址的计算，产生地址的表达式被称为 `l-values`:idx: "左值"，左值可以表示地址，也可以表示该地址包含的值，这取决于上下文。

Nim `program`:idx: "程序"由一个或多个包含Nim代码的文本 `source files`:idx: "源文件"组成，由Nim `compiler`:idx: "编译器"处理成 `executable`:idx: "可执行的"，这个可执行文件的性质取决于编译器的实现；例如，它可能是一个本地二进制文件或JavaScript源代码。

在典型的Nim程序中，大部分代码被编译到可执行文件中，然而，有些代码可能在 `compile-time`:idx: "编译期"执行，包括常量表达式、宏定义和宏定义使用的Nim过程。大部分的Nim代码支持编译期执行，但是有一些限制 -- 详情阅读 `关于编译时执行的限制 <#restrictions-on-compileminustime-execution>`_ 。我们使用术语 `runtime`:idx: "运行时"来涵盖编译期执行和可执行文件中的代码执行。

编译器将Nim源代码解析成一个内部数据结构，称为 `abstract syntax tree`:idx: (`AST`:idx:) "抽象语法树"，在执行代码或将其编译为可执行文件之前，通过 `semantic analysis`:idx: "语义分析"对AST进行转换，增加了语义信息，如表达式类型、标识符的含义，以及在某些情况下的表达式值。在语义分析中检测到的错误被称为 `static error`:idx: "静态错误"，当前手册中描述的错误在没有其他约定时，是静态错误。

`panic`:idx: "恐慌"是在运行时检测和报告的错误，报告这种错误的方式是通过 *引发异常* 或 *致命错误* 结束，也提供了一种方法来禁用 `runtime checks`:idx: "运行时检查"，详情阅读标记一节。

恐慌的结果是一个异常还是一个致命的错误，是特定实现，因此，下面的程序无效，尽管代码试图捕获越界访问数组的 `IndexDefect` ，但编译器可能会以致命错误终结程序。

  ```nim
  var a: array[0..1, char]
  let i = 5
  try:
    a[i] = 'N'
  except IndexDefect:
    echo "invalid index"
  ```

目前允许通过 `--panics:on|off`:option: 在不同方式之间切换，打开时，程序会因恐慌而终结，关闭时，运行时的错误会变为异常。 `--panics:on`:option: 的好处是产生更小的二进制代码，编译器可以更自由地优化。

`unchecked runtime error`:idx: "未检查的运行时错误"是不能保证被检测到的错误，它可能导致计算产生意外后果，如果只使用 `safe`:idx: "安全"语言特性，并且没有禁用运行时检查，就不会产生未检查的运行时错误。

`constant expression`:idx: "常量表达式"在对包含它的代码进行语义分析时，值就可以被计算出来。它从来不会是左值，也不会有副作用。常量表达式并不局限于语义分析的能力，例如常量折叠。它可以使用所支持的编译期执行的所有Nim语言特性。由于常量表达式可以作为语义分析时的输入，比如用于定义数组的边界，因为这种灵活性的要求，编译器交错进行语义分析和编译时代码执行。

想象一下，语义分析在源代码中从上到下、从左到右地进行，而在必要的时候，为了计算后续语义分析所需要的数值，编译期的代码交错执行，这一点非常明确。我们将在本文的后面看到，宏调用不仅需要这种交错，而且还产生了，语义分析并不完全是自上而下、自左而右地进行的情况。


词法分析
================

编码
--------

所有的Nim源文件都采用UTF-8编码(或其ASCII子集)，不支持其他编码。可以使用任何标准平台的线性终端序列 —— Unix形式使用ASCII LF(换行)，Windows形式使用ASCII序列CR LF(换行后返回)，或旧的Macintosh形式使用ASCII CR(返回)字符，无论在什么平台上，这些形式都可以无差别地使用。


缩进
--------

Nim的标准语法描述了 `indentation sensitive`:idx: "缩进敏感"的语言特性，表示其所有的控制结构可以通过缩进来识别，缩进只包括空格，不允许使用制表符。

缩进处理的实现方式如下，词法分析器用前导空格数来解释之后的标记，缩进不是单独的一个标记，这个技巧使得Nim解析时只需要向前查看1个token。

语法分析器使用一个缩进级别的堆栈：该堆栈由计算空格的整数组成，语法分析器在对应的策略位置查询缩进信息，但忽略其他地方。伪终端 `IND{>}` 表示缩进比堆栈顶部的条目包含更多的空格， `IND{=}` 表示缩进有相同的空格数，`DED` 是另一个伪终端，表示从堆栈中弹出一个值的 *action* 动作， `IND{>}` 则意味着推到堆栈中。

用这个标记，我们现在可以很容易地定义核心语法：语句块(这是简化的例子)::

  ifStmt = 'if' expr ':' stmt
           (IND{=} 'elif' expr ':' stmt)*
           (IND{=} 'else' ':' stmt)?

  simpleStmt = ifStmt / ...

  stmt = IND{>} stmt ^+ IND{=} DED  # 语句列表
       / simpleStmt                 # 或者单个语句



注释
--------

注释在字符串或字符字面值之外的任意位置，以 `#` 字符开头，注释由 `comment pieces`:idx: "注释段"连接组成，一个注释段以 `#` 开始直到行尾，包括行末的字符。如果下一行只由一个注释段组成，在它和前面的注释段之间没有其他标记，就不会开启一个新的注释。


  ```nim
  i = 0     # 这是一个多行注释。
    # 词法分析器将这两部分合并在一起。
    # 注释在这里继续。
  ```


`Documentation comments`:idx: "文档注释"以两个 `##` 开头，文档注释是token标记，它们属于语法树，只允许在输入文件的某些地方出现。


多行注释
----------------

从0.13.0版本的语言开始，Nim支持多行注释。如下:

  ```nim
  #[Comment here.
  Multiple lines
  are not a problem.]#
  ```

多行注释支持嵌套:

  ```nim
  #[  #[ Multiline comment in already
     commented out code. ]#
  proc p[T](x: T) = discard
  ]#
  ```

还有多行文档注释，同样支持嵌套:

  ```nim
  proc foo =
    ##[Long documentation comment
       here.
    ]##
  ```


标识符和关键字
----------------------------

Nim中的标识符可以是任何字母、数字和下划线组成的字符串，但有以下限制:

* 以一个字母开头
* 不允许下划线 `_` 结尾
* 不允许两个下划线 `__` 结尾。

  ```
  letter ::= 'A'..'Z' | 'a'..'z' | '\x80'..'\xff'
  digit ::= '0'..'9'
  IDENTIFIER ::= letter ( ['_'] (letter | digit) )*
  ```

目前，任何序数值大于127的Unicode字符(非ASCII)都被归类为 `letter` "字"，因而可以做为标识符的一部分，但以后的语言版本可能会将一些Unicode字符指定为运算符。

以下关键词被保留，不能作为标识符使用:

  ```nim file="keywords.txt"
  ```

有些关键词还未使用，它们被保留，提供语言未来拓展。


标识符相等
--------------------

如果以下算法返回真，则认为两个标识符相等:

  ```nim
  proc sameIdentifier(a, b: string): bool =
    a[0] == b[0] and
      a.replace("_", "").toLowerAscii == b.replace("_", "").toLowerAscii
  ```

这意味着，在进行比较时，只有第一个字母是区分大小写的，其他字母在ASCII范围内不区分大小，下划线被忽略。

这种相当非正统的标识符比较方式被称为 `partial case-insensitivity`:idx: "部分大小写不敏感"，比传统的大小写敏感有一些优势。

它允许程序员大多使用他们自己喜欢的拼写风格。不管是humpStyle"驼峰风格"还是snake_style"蛇形风格"，不同程序员编写的库不能使用不兼容的约定。一个按Nim思考的编辑器或IDE可以显示首选的标识符，另一个好处是，它使程序员不必记住标识符的准确拼写。第一个字母例外，是允许常见的如 `var foo: Foo` 这样的普通代码可以被明确地解析出来。

注意这个规则也适用于关键字，也就是说 `notin` 与 `notIn` 和 `not_in` 相同 (关键字书写方式首选全小写 (`notin`, `isnot`) )。

Nim曾经是一种完全 `style-insensitive`:idx: "大小写不敏感"的语言，这意味着它不区分大小写，忽略下划线，甚至 `foo` 和 `Foo` 之间没有区别。


作为标识符的关键词
------------------------------------

如果一个关键词被括在反撇号里，它就失去了关键词的属性，变成了一个普通的标识符。

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


字符串字面值
------------------------

语法中的终端符号: `STR_LIT` .

字符串可以用配对的双引号来分隔，可以包含以下 `escape sequences`:idx:\ "转义字符":

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


Nim中的字符串可以包含任意8-bit值，甚至嵌入零，然而，某此操作可能会将第一个二进制零解释为终止符。


三重引用字符串字面值
----------------------------------------

语法中的终端符号: `TRIPLESTR_LIT`.

字符串也可以用三个双引号 `"""` ... `"""` 来分隔，这种形式的字面值支持多行，可以包含 `"` ，并且不解释任何转义字符，为了方便，开头 `"""` 后面换行符以及空格并不包括在字符串中，字符串的结尾定义为 `"""[^"]` 模式，所以如下:

  ```nim
  """"long string within quotes""""
  ```

产生::

  "long string within quotes"


原始字符串
--------------------

语法中的终端符号: `RSTR_LIT` 。

还有一些原始的字符串字面值，前面为字母 `r` 或 `R` ，并匹配一对双引号的普通字符串，不解释转义字符，这用在正则表达式或Windows中的路径时很方便。

  ```nim
  var f = openFile(r"C:\texts\text.txt") # a raw string, so ``\t`` is no tab
  ```

要在原始字符串字面值中含有 `"` 则必须成双。

  ```nim
  r"a""b"
  ```

产生::

  a"b

不能用 `r""""` 这个标记，因为原始字符串中引入了三引号的字符串字面值。 `r"""` 与 `"""` 是相同的，三引号原始字符串字面值也不解释转义字符。


广义的原始字符串字面值
--------------------------------------------

语法中的终端符号: `GENERALIZED_STR_LIT` , `GENERALIZED_TRIPLESTR_LIT` .

 `identifier"string literal"` (标识符和开头的引号之间没有空格) 结构是广义的原始字符串字面值。它是 `identifier(r"string literal")` 构造的简写方式，它表示以原始字符串字面值为唯一参数的常规调用。广义的原始字符串字面值的意义，在于方便的将mini语言直接嵌入到Nim中，例如正则表达式。

还有 `identifier"""string literal"""` 结构，是 `identifier("""string literal""")` 的简写方式。


字符字面值
--------------------

字符串用单引号 `''` 括起来，可以包含与字符串相同的转义字符 —— 但有一种例外：不允许与平台有关的 `newline`:idx: (``\p``) "换行符"，因为它可能比一个字符宽(它可能是一对CR/LF)。下面是有效的 `escape sequences`:idx: "转义字符"字面值。

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

一个字符不是一个Unicode字符，而是一个单字节。

原由：为了能够有效地支持 `array[char, int]` 和 `set[char]` 。

 `Rune` 类型可以代表任意Unicode字符，`Rune` 声明在 `unicode module <unicode.html>`_ 中。

如果前面有一个回车符，那么不以 `'` 结尾的字符字面值将被解释为 `'` ，此时前面的回车符和字符字面值之间不能有空格，这种特殊情况是为了保证像 ``proc `'customLiteral`(s: string)`` 这样的声明有效。 ``proc `'customLiteral`(s: string)`` 与 ``proc `'\''customLiteral`(s: string)`` 相同。

参考阅读 `自定义数值字面值 <#custom-numeric-literals>`_ 。


数值字面值
--------------------

数值字面值具有这种形式::

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

  # CUSTOM_NUMERIC_SUFFIX 是任意非预定义类型后缀的Nim标识符。


从描述中可以看出，数值字面值可以包含下划线，以便于阅读。整数和浮点数可以用十进制(无前缀)、二进制(前缀 `0b` )、八进制(前缀 `0o` )和十六进制(前缀 `0x` )标记表示。

像 `-1` 这样的数值字面值中的一元减号 `-` 是字面值的一部分，这是后来添加到语言中的，原因是表达式 `-128'i8` 应该是有效的。如果没有这种特殊情况，则这将不被允许 -- `128` 不是有效的 `int8` 值，只有 `-128` 是有效的。

对于 `unary_minus` 规则，有一些限制，但在正式语法中没有提及。 `-` 是数值字面值的一部分时，前面的字符必须在 `{' ', '\t', '\n', '\r', ',', ';', '(', '[', '{'}` 集合中，这个设计是为了更合理的方式涵盖大多数情况。

在下面的例子中， `-1` 是一个单独的token标记:

  ```nim
  echo -1
  echo(-1)
  echo [-1]
  echo 3,-1

  "abc";-1
  ```

在下面的例子中， `-1` 被解析为两个独立的token标记( `-`:tok: `1`:tok: ):

  ```nim
  echo x-1
  echo (int)-1
  echo [a]-1
  "abc"-1
  ```


以撇号 ('\'') 开始的后缀被称为 `type suffix`:idx: "类型后缀"。没有类型后缀的字面值是整数类型，当包含一个点或 `E|e` ，那么它是 `float` 类型。如果字面值的范围在 `low(int32)..high(int32)` ，那么这个整数类型就是 `int` ，否则就是 `int64` 。为了记数方便，如果类型后缀明确，那么后缀的撇号是可选的(只有带类型后缀的十六进制浮点数字面值含义才会不明确)。


预定义的类型后缀有:

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

浮点数字面值也可以采用二进制、八进制或十六进制的标记:
`0B0_10001110100_0000101001000111101011101111111011000101001101001001'f64` 
根据IEEE浮点标准，约为1.72826e35。

字面值必须匹配数据类型，例如， `333'i8` 是一个无效的字面值。以非10进制表示的字面值主要用于标记和比特位模式，因此检查是对位宽而不是值范围进行的，因此: 0b10000000'u8 == 0x80'u8 == 128，但是， 0b10000000'i8 == 0x80'i8 == -128 而不是 -1。


### 自定义数值字面值

如果后缀不是预定义标记，那么后缀会被认为是对proc过程、template模板、macro宏或其他可调用标识符的调用，包含字面值的字符串被传递给该标识符。可调用标识符需要用一个特殊的 ``'`` 前缀来声明。

  ```nim
  import strutils
  type u4 = distinct uint8 # 一个4位无符号整数，又称 "nibble"
  proc `'u4`(n: string): u4 =
    # 这是必需的。
    result = (parseInt(n) and 0x0F).u4

  var x = 5'u4
  ```

更确切地说，一个自定义的数值字面值 `123'custom` 在解析步骤中被转换为 r"123".`'custom` 。并没有对应于这种转换的AST节点种类，这种转换合理地处理了额外参数被传递给被调用者的情况。

  ```nim
  import strutils
  type u4 = distinct uint8 # 4位无符号整数，又称 "nibble"
  proc `'u4`(n: string; moreData: int): u4 =
    result = (parseInt(n) and 0x0F).u4

  var x = 5'u4(123)
  ```

自定义数值字面值由名称为 `CUSTOM_NUMERIC_LIT` 的语法规则涵盖。一个自定义的数值字面值是单独的token标记。


运算符
------------

Nim允许用户定义运算符。运算符可以是以下字符的任意组合::

       =     +     -     *     /     <     >
       @     $     ~     &     %     |
       !     ?     ^     .     :     \

(语法中使用终端OPR来指代这里定义的运算符符号。)

这些关键字也是运算符:
`and or not xor shl shr div mod in notin is isnot of as from` 。

`.`:tok:, `=`:tok:, `:`:tok:, `::`:tok: 不能作为一般运算符使用; 它们的目的是被用于其他符号。

`*:` 是特殊情况处理为两个token标记 `*`:tok: 和 `:`:tok: (是为了支持 `var v*: T`)。

`not` 关键字始终是一元运算符, `a not b` 解析为 `a(not b)` , 并不是 `(a) not (b)` 。


其他标记
----------------

以下字符串表示其他标记::

    `   (    )     {    }     [    ]    ,  ;   [.    .]  {.   .}  (.  .)  [:


 `slice`:idx: "切片"运算符 `..`:tok: 优先于其他包含点的标记: `{..}` 是三个标记 `{`:tok:, `..`:tok:, `}`:tok: 而不是两个标记 `{.`:tok:, `.}`:tok: 。


句法
========

本节列出了Nim的标准句法。语法分析器如何处理缩进的问题已经在 `Lexical Analysis`_ "词法分析"一节中描述过了。

Nim允许用户定义运算符。二元运算符有11个不同的优先级。



结合律
------------

第一个字符为 `^` 的二元运算符是右结合，所有其他二元运算符是左结合。

  ```nim
  proc `^/`(x, y: float): float =
    # 右结合除法运算符
    result = x / y
  echo 12 ^/ 4 ^/ 8 # 24.0 (4 / 8 = 0.5, then 12 / 0.5 = 24.0)
  echo 12  / 4  / 8 # 0.375 (12 / 4 = 3.0, then 3 / 8 = 0.375)
  ```

优先级
------------

一元运算符总是比任何二元运算符结合性更强: `$a + b` 是 `($a) + b` 而不是 `$(a + b)` 。

如果一个一元运算符的第一个字符是 `@` ，它就是一个 `sigil-like`:idx: "缩写"运算符，比 `primarySuffix` 的结合性更强: `@x.abc` 被解析为 `(@x).abc` ，而 `$x.abc` 被解析为 `$(x.abc)` 。 


对于不是关键字的二元运算符，优先级由以下规则决定:

以 `->` 、 `~>` 或 `=>` 结尾的运算符被称为 `arrow like`:idx: "箭头"，在所有运算符中优先级最低。

如果运算符以 `=` 结尾，并且其第一个字符不是 `<`, `>`, `!`, `=`, `~`, `?` 中的任意一个，那么它就是一个 *赋值运算符* ，具有第二低的优先级。

否则，优先级由第一个字符决定。


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


一个运算符是否被用作前缀运算符，也会受到前面的空格影响 (这个解析变化是在0.13.0版本中引入的) 。

  ```nim
  echo $foo
  # 解析为
  echo($foo)
  ```


空格也决定了 `(a, b)` 是被解析为一个调用的参数列表，还是被解析为一个元组构造。

  ```nim
  echo(1, 2) # 传递1和2给echo

  ```nim
  echo (1, 2) # 传递元组(1, 2)给echo

点类运算符
--------------------

语法中的终端符号: `DOTLIKEOP` 。

点类运算符是以 `.` 开头的运算符，但不是以 `..` 开头的，例如 `.?` ，它们的优先级与 `.` 相同，因此 `a.?b.c` 被解析为 `(a.?b).c` ，而不是 `a.? (b.c)` 。


语法
--------

语法的起始符号是 `module` 。

.. include:: grammar.txt
   :literal:



求值顺序
===================

求值顺序严格从左到右，由内到外，这是大多数其他强类型编程语言的典型做法:

  ```nim  test = "nim c $1"
  var s = ""

  proc p(arg: int): int =
    s.add $arg
    result = arg

  discard p(p(1) + p(2))

  doAssert s == "123"
  ```


赋值也不特殊，左边的表达式在右边的表达式之前被求值:

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


原由：与重载赋值或类似赋值的运算符保持一致，`a = b` 可以理解为 `performSomeCopy(a, b)` 。


然而，"求值顺序" 的概念只有在代码被规范化之后才适用。规范化涉及到模板的扩展和参数的重新排序，这些参数已经被传递给了命名参数。

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


原由:这比设想的替代方案容易实现得多。


常量和常量表达式
================================

`constant`:idx: "常量"是一个与常量表达式的值绑定的符号。常量表达式被限制为只依赖于以下类别的值和运算，因为这些值和运算要么被内置在语言中，要么在对常量表达式进行语义分析之前被声明和求值。

* 字面值
* 内置运算符
* 先前声明的常量和编译时变量
* 先前声明的宏和模板
* 先前声明的过程，除了可能修改编译时变量外，没有任何副作用

常量表达式可以包含代码块，这些代码块是可以在内部使用编译时支持的所有Nim功能(详见下面的章节)。在这样的代码块中，可以声明变量，随后读取和更新它们，或者声明变量并将它们传递给其修改值的过程。这样的代码块中的代码，仍须遵守上面列出的关于引用该代码块外的值和运算的限制。

访问和修改编译时变量的能力为常量表达式增加了灵活性，这会让那些来自其他静态类型语言的人惊讶。例如，下面的代码在 **编译时** 返回斐波那契数列的起始。(这是对定义常量灵活性的演示，而不是对解决这个问题的推荐风格)。

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


对编译时执行的限制
====================================

编译时执行的Nim代码不能使用以下语言特性:

* methods 方法
* closure iterators 闭包迭代器 
* `cast` 运算符
* 引用 (指针) 类型
* FFI

不允许使用 FFI 和/或 `cast` 的包装器。请注意，这些包装器包括标准库中的包装器。

随着时间的推移，部分或所有这些限制可能会被取消。


类型
========

在语义分析中是已知的，所有的表达式都有一个类型。Nim是静态类型语言。可以声明新的类型，这实质上是定义了一个标识符，用来表示这个自定义类型。

这些是主要的类型分类:

* 序数类型(包括整数、布尔、字符、枚举、枚举子范围)
* 浮点类型
* 字符串类型
* 结构化类型
* 引用(指针)类型
* 过程类型
* 通用类型


序数类型
----------------
序数类型有以下特征:

- 序数类型是可数的和有序的。因而允许使用如 `inc`, `ord`, `dec` 等函数，来操作已定义的序数类型。
- 序数类型具有最小可使用值，可以通过 `low(type)` 获取。 尝试从最小值继续减小，会产生panic或静态错误。
- 序数类型具有最大可使用值，可以通过 `high(type)` 获取。  尝试从最大值继续增大，会产生panic或静态错误。

整数、bool、字符和枚举类型(以及这些类型的子范围)属于序数类型。

如果一个distinct类型的基类型是序数类型，则distinct类型也为序数类型。


预定义整数类型
----------------------------
这些整数类型是预定义的:

`int`
  常规有符号整数类型。它的大小取决于平台，并且与指针大小相同。如果一个没有类型后缀的整数字面值在 `low(int32)...high(int32)` 的范围内，则它是这种类型，否则为 `int64` 类型.

`int`\ XX
  使用XX位额外标记的有符号整数使用这种命名。(比如int16是16位宽整数)当前支持实现有 `int8`, `int16`, `int32`, `int64` 。这些类型的字面值后缀为'iXX。

`uint`
  常规 `unsigned integer`:idx: "无符号整数" 。它的大小取决于平台，并且与指针大小相同。 类型后缀为 `'u` 的整数字面值就是这种类型。

`uint`\ XX
  使用XX位额外标记的无符号整数使用这种命名。(比如uint16是16位宽的无符号整数)当前支持的实现有 `uint8`, `uint16`, `uint32`, `uint64` 。这些类型的字面值具有后缀 'uXX 。 无符号运算会环绕，不会导致上溢或下溢错误。


除了有符号和无符号整数的常用算术运算符( `+ - *` 等)之外， 还有些运算符可以处理 *有符号* 整数但将他们的参数视为 *无符号*: 它们主要用于之后的版本与缺少无符号整数类型的旧版本语言进行兼容。 有符号整数的这些无符号运算约定使用 `%` 作为后缀: 


======================   ===========================================================================================
操作符                   含义
======================   ===========================================================================================
`a +% b`                 无符号整型加法
`a -% b`                 无符号整型减法
`a *% b`                 无符号整型乘法
`a /% b`                 无符号整型除法
`a %% b`                 无符号整型取模
`a <% b`                 无符号比较`a`与`b`
`a <=% b`                无符号比较`a`与`b`
`ze(a)`                  用零填充 `a` 的位，直到它具有 `int`类型的宽度
`toU8(a)`                将`a`视为无符号数值，并将它转成8位无符号整数(但仍是`int8`类型)
`toU16(a)`               将`a`视为无符号数值，并将它转成8位无符号整数(但仍是`int16`类型)
`toU32(a)`               将`a`视为无符号数值，并将它转成8位无符号整数(但仍是`int32`类型)
======================   ===========================================================================================

不同类型的整型的表达式中，会执行`Automatic type conversion`:idx: "自动类型转换" : 较小的类型转换为较大的类型。

`Automatic type conversion`:idx: "自动类型转换" 将较大的类型转换为较小的类型(比如 `int32 -> int16` ) ， `widening type conversion`:idx: "扩大类型转换" 将较小的类型转换为较大的类型(比如`int16 -> int32`) ，Nim中仅有扩展类型转型是 *隐式的* :

  ```nim
  var myInt16 = 5i16
  var myInt: int
  myInt16 + 34     # 为 `int16` 类型
  myInt16 + myInt  # 为 `int` 类型
  myInt16 + 2i32   # 为 `int32` 类型
  ```

然而，如果字面值适合这个较小的类型，并且这样的转换比其他隐式转换更好，那么 `int` 字面值可以隐式转换为较小的整数类型，因而 `myInt16 + 34` 结果是 `int16` 类型。

有关详细信息，请阅读参考 `Convertible relation <#type-relations-convertible-relation>`_ 。


子范围类型
--------------------
子范围类型是序数或浮点类型(基类型)的取值范围。要定义子范围类型，必须指定其值的限制，即类型的最低值和最高值。例如:

  ```nim
  type
    Subrange = range[0..5]
    PositiveFloat = range[0.0..Inf]
    Positive* = range[1..high(int)] # 正如 `system` 里定义的一样
  ```


`Subrange` 是整数的子范围，只能保存0到5的值。`PositiveFloat` 定义了包含所有正浮点数的子范围。
NaN不属于任何浮点类型的子范围。将任何其他值赋值给类型为 `Subrange` 会产生panic(如果可以在语义分析期间确认，则为静态错误)。
允许将基类型赋值给它的一个子范围类型(反之亦然)。

子范围类型与其基类型具有相同的大小(子范围示例中的 `int` )。


预定义浮点类型
----------------------------

以下浮点类型是预定义的:

`float`
  常规浮点类型; 它的大小曾经与平台相关，但现在，它总是映射为 `float64` 。一般应该使用这种类型。

`float`\ XX
  使用XX位附加标记的浮点数可以使用这种命名(例如: `float64` 是64位宽的浮点数)，当前支持 `float32` 和 `float64` 。 这些类型的字面值具有后缀 'fXX。


可以在具有不同类型浮点数的表达式中执行自动类型转换: 详见 `Convertible relation <#type-relations-convertible-relation>`_ 。 
在浮点类型上执行的算术遵循IEEE标准。 整数类型不会自动转换为浮点类型，反之亦然。

IEEE标准定义了五种类型的浮点异常:

* 无效: 使用数学上无效的操作数运算, 例如 0.0/0.0, sqrt(-1.0), 和log(-37.8).
* 除以零: 除数为零，且被除数是有限的非零数，例如1.0 / 0.0。
* 溢出: 运算产生的结果超出范围，例如，MAXDOUBLE + 0.0000000000001e308。
* 下溢: 运算产生的结果太小而无法表示为正常数字，例如，MINDOUBLE * MINDOUBLE。
* 不精确: 运算产生的结果无法用无限精度表示，例如，输入中的 2.0 / 3.0，log(1.1) 和 0.1。

IEEE异常在执行期间被忽略或映射到Nim异常: `FloatInvalidOpDefect`:idx: "浮点数无效缺陷" , `FloatDivByZeroDefect`:idx: "浮点数除零缺陷" , `FloatOverflowDefect`:idx: "浮点数溢出缺陷" , `FloatUnderflowDefect`:idx: "浮点数下溢缺陷" , 和 `FloatInexactDefect`:idx: "浮点数不精确缺陷" 。 这些异常继承自 `FloatingPointDefect`:idx: "浮点数缺陷" 基类。

Nim提供了编译指示 `nanChecks`:idx: 和 `infChecks`:idx: 控制是否忽略IEEE异常或捕获Nim异常:

  ```nim
  {.nanChecks: on, infChecks: on.}
  var a = 1.0
  var b = 0.0
  echo b / b # 引发 FloatInvalidOpDefect
  echo a / b # 引发 FloatOverflowDefect
  ```

在当前的实现中，绝不会引发 `FloatDivByZeroError` 和 `FloatInexactError` 。 `FloatOverflowError` 取代了 `FloatDivByZeroError` 。 
另有 `floatChecks`:idx: 编译指示用作 `nanChecks` 和 `infChecks` 的便捷方式。 `floatChecks` 默认关闭。

只有 `+`, `-`, `*`, `/` 这些运算符会受 `floatChecks` 编译指示影响。

在语义分析期间，应始终使用最大精度来评估浮点数，这表示在常量展开期间，表达式  `0.09'f32 + 0.01'f32 == 0.09'f64 + 0.01'f64` 的值为真。


布尔类型
----------------
布尔类型在Nim中命名为 `bool`:idx: ，值为预定义( `true` 和 `false` )之一。 `while` , `if` , `elif` , `when` 中的状态需为 `bool` 类型.

这种情况成立::

  ord(false) == 0 and ord(true) == 1

为布尔类型定义了运算符 `not, and, or, xor, <, <=, >, >=, !=, ==` 。 `and` 和 `or` 运算符进行短路求值。例如:

  ```nim
  while p != nil and p.name != "xyz":
    # 如果 p == nil， p.name不被求值
    p = p.next
  ```


bool类型的大小是一个字节。


字符类型
----------------
字符类型在Nim中被命名为 `char` 。它的大小为一个字节。因此，它不能表示UTF-8字符，而只能是UTF-8字符的一部分。

`Rune` 类型用于Unicode字符，它可以表示任意Unicode字符。`Rune` 声明在 `unicode module <unicode.html>`_ 中。




枚举类型
----------------
枚举类型定义了一个其值由指定的值组成的新类型，这些值是有序的。例如:

  ```nim
  type
    Direction = enum
      north, east, south, west
  ```


那么以下是成立的:

```
  ord(north) == 0
  ord(east) == 1
  ord(south) == 2
  ord(west) == 3

  # 也允许:
  ord(Direction.west) == 3
```

由此可知，north < east < south < west。比较运算符可以与枚举类型一起使用。枚举值也可以使用它所在的枚举类型来限定，如 `north` 可以用 `Direction.nort` 来限定。

为了更好地与其他编程语言连接，可以显式为枚举类型字段分配序数值，但是，序数值必须升序排列。 未明确给出序数值的字段被赋予前一个字段 +1 的值。

显式有序枚举可以有 *间隔* :

  ```nim
  type
    TokenType = enum
      a = 2, b = 4, c = 89 # 可以有间隔
  ```

但是，它不再是序数，因此不可能将这些枚举用作数组类型的索引。 过程 `inc` , `dec`, `succ` 和 `pred` 对于它们不可用。


编译器支持内置的字符串化运算符 `$` 用于枚举。字符串化的效果是，可以通过显式给出要使用的字符串来控制:

  ```nim
  type
    MyEnum = enum
      valueA = (0, "my value A"),
      valueB = "value B",
      valueC = 2,
      valueD = (3, "abc")
  ```

从示例中可以看出，可以通过使用元组指定字段的序数值以及字符串值，也可以只指定其中一个。

枚举可以使用 `pure` 编译指示进行标记，以便将其字段添加到特定模块特定的隐藏作用域，该作用域仅作为最后一次尝试进行查询。 
只有没有歧义的符号才会添加到此作用域。 但总是可以通过写为 `MyEnum.value` 的类型限定来访问:

  ```nim
  type
    MyEnum {.pure.} = enum
      valueA, valueB, valueC, valueD, amb

    OtherEnum {.pure.} = enum
      valueX, valueY, valueZ, amb


  echo valueA # MyEnum.valueA
  echo amb    # 错误: 不确定它是MyEnum.amb还是OtherEnum.amb
  echo MyEnum.amb # OK.
  ```

要使用枚举实现位字段，请参阅 `Bit fields <#set-type-bit-fields>`_ 


字符串类型
--------------------
所有字符串字面值都是 `string` 类型。 Nim中的字符串与字符序列非常相似。 但是，Nim中的字符串都是以零结尾的并且具有长度字段。 可以用内置的 `len` 过程检索长度，长度总是不会计算末尾的零。

除非首先将字符串转换为 `cstring` 类型，否则无法访问末尾的零。末尾的零确保可以在 O(1) 中完成此转换，无需任何分配。

字符串的赋值运算符始终复制字符串。 `&` 运算符拼接字符串。

大多数原生Nim类型支持使用特殊的 `$` 过程转换为字符串。

  ```nim
  echo 3 # 为 `int` 调用 `$`
  ```

每当用户创建一个特定的对象时，该过程的实现提供了 `string` 表示。

  ```nim
  type
    Person = object
      name: string
      age: int

  proc `$`(p: Person): string = # `$` 始终返回字符串
    result = p.name & " 已经 " &
            $p.age & # 需要在p.age前添加`$`，因为它是整数类型，而我们要将其转换成字符串
            "岁了。"
  ```

虽然也可以使用 `$p.name` ，但 `$` 操作符不会对字符串做任何事情。 请注意，我们不能依赖于从 `int` 到 `string` 像 `echo` 过程一样自动转换。

字符串按字典顺序进行比较。 所有比较运算符都可用。 字符串可以像数组一样索引(下限为0)。 与数组不同，字符串可用于case语句:

  ```nim
  case paramStr(i)
  of "-v": incl(options, optVerbose)
  of "-h", "-?": incl(options, optHelp)
  else: write(stdout, "非法的命令行选项\n")
  ```

按照惯例，所有字符串都是UTF-8字符串，但不强制执行。 例如，从二进制文件读取字符串时，它们只是一个字节序列。 索引操作 `s[i]` 表示 s 的第i个 *char* ，而不是第i个 *unichar* 。  `unicode module <unicode.html>`_  中的迭代器 `runes` ，可用于迭代所有Unicode字符。


cstring类型
----------------------

`cstring` 类型意味着 `compatible string` ，是编译后端的字符串的原生表示。 对于C后端， `cstring` 类型表示一个指向末尾为零的char数组的指针，该数组与ANSI C中的 `char*` 类型兼容。 其主要目的在于与C轻松互通。 索引操作 `s[i]` 表示 s 的第i个 *char* ;但是没有执行检查 cstring 的边界，导致索引操作并不安全。

为方便起见，Nim中的 `string` 可以隐式转换为 `cstring` 。 如果将Nim字符串传递给C风格的可变参数过程，它也会隐式转换为 `cstring` :

  ```nim
  proc printf(formatstr: cstring) {.importc: "printf", varargs,
                                    header: "<stdio.h>".}

  printf("这会%s工作", "像预期一样")
  ```

即使转换是隐式的，它也不是 *安全的* : 垃圾收集器不认为 `cstring` 是根，并且可能收集底层内存。 因此，隐式转换将在Nim编译器的未来版本中删除。某些习语，例如将 `const` 字符串转换为 `cstring` 是安全的，并且仍将被允许。

为cstring定义的 `$` 过程能够返回string。因此，从cstring获取nim的string可以这样:

  ```nim
  var str: string = "Hello!"
  var cstr: cstring = str
  var newstr: string = $cstr
  ```

`cstring` 不应被逐字修改。

  ```nim
  var x = cstring"literals"
  x[1] = 'A' # 这是错的！！！
  ```

如果 `cstring` 来自常规内存(而不是只读内存)，则可以被逐字修改:

  ```nim
  var x = "123456"
  var s: cstring = x
  s[0] = 'u' # 这是可以的
  ```

结构化类型
--------------------
结构化类型的变量可以同时保存多个值。 结构化类型可以嵌套到无限级别。数组、序列、元组、对象和集合属于结构化类型。

数组和序列类型
----------------------------
数组是同类型的，这意味着数组中的每个元素都具有相同的类型。 数组总是具有指定为常量表达式的固定长度(开放数组除外)。 它们可以按任何序数类型索引。 若参数 `A` 是 *开放数组* ，那么它的索引为由0到 len(A)- 1 的整数。 数组表达式可以由数组构造器 `[]` 构造。 数组表达式的元素类型是从第一个元素的类型推断出来的。 所有其他元素都需要隐式转换为此类型。

可以使用 `array[size, T]` 构造数组类型，也可以使用 `array[lo..hi, T]` 设置数组的起点而不是默认的0。

序列类似于数组，但有动态长度，其长度可能在运行时期间发生变化(如字符串)。 序列实现为可增长的数组，在添加项目时分配内存块。 序列 `S` 的索引为从0到 `len(S)-1` 的整数，并检查其边界。 序列可以在序列运算符 `@` 的帮助下，由数组构造器 `[]` 和数组一起构造。为序列分配空间的另一种方法是调用内置的 `newSeq` 过程。

序列可以传递给 *开放数组* 类型的参数

示例:

  ```nim
  type
    IntArray = array[0..5, int] # 索引为0到5的数组
    IntSeq = seq[int] # 一个整数序列
  var
    x: IntArray
    y: IntSeq
  x = [1, 2, 3, 4, 5, 6]  # [] 是数组构造器
  y = @[1, 2, 3, 4, 5, 6] #  @ 会将数组转换成序列

  let z = [1.0, 2, 3, 4] # z的类型是 array[0..3, float]
  ```

数组或序列的下限可以用内置的过程 `low()` 获取，上限用 `high()` 获取。 长度可以用 `len()` 获取。序列或开放数组的 `low()` 总是返回0，因为这是第一个有效索引。 可以使用 `add()` 过程或 `&` 运算符将元素追加到序列中，并使用 `pop()` 过程删除(并获取)序列的最后一个元素。

符号 `x[i]` 可用于访问 `x` 的第i个元素。

数组始终是边界检查的(静态或运行时)。可以通过编译指示禁用这些检查，或使用 `--boundChecks:off` 命令行开关调用编译器。

数组构造器可以具有可读的显式索引:

  ```nim
  type
    Values = enum
      valA, valB, valC

  const
    lookupTable = [
      valA: "A",
      valB: "B",
      valC: "C"
    ]
  ```

如果省略索引，则使用 `succ(lastIndex)` 作为索引值:

  ```nim
  type
    Values = enum
      valA, valB, valC, valD, valE

  const
    lookupTable = [
      valA: "A",
      "B",
      valC: "C",
      "D", "e"
    ]
  ```



开放数组
----------------

通常，固定大小的数组太不灵活了，程序应该能够处理不同大小的数组。 `openarray`:idx: "开放数组" 类型只能用于参数。 开放数组总是从位置0开始用 `int` 索引。 `len`，`low` 和 `high` 操作也可用于开放数组。 具有兼容基类型的任何数组都可以传递给开放数组形参，无关索引类型。 除了数组之外，还可以将序列传递给开放数组参数。

 `openarray` 类型不能嵌套: 不支持多维开放数组，因为这种需求很少并且不能有效地完成。

  ```nim
  proc testOpenArray(x: openArray[int]) = echo repr(x)

  testOpenArray([1,2,3])  # array[]
  testOpenArray(@[1,2,3]) # seq[]
  ```

可变参数
----------------

`varargs` 参数是一个开放数组参数，它允许将可变数量的参数传递给过程。 编译器隐式地将参数列表转换为数组:

  ```nim
  proc myWriteln(f: File, a: varargs[string]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, "abc", "def", "xyz")
  # 转换成:
  myWriteln(stdout, ["abc", "def", "xyz"])
  ```

仅当 `varargs` 参数是最后一个参数时，才会执行此转换。 也可以在此上下文中执行类型转换:

  ```nim
  proc myWriteln(f: File, a: varargs[string, `$`]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, 123, "abc", 4.0)
  # 转换成:
  myWriteln(stdout, [$123, $"abc", $4.0])
  ```

在这个例子中， `$` 应用于传递给参数 `a` 的任意参数。 (注意 `$` 对字符串是一个空操作。)

请注意，传递给 `varargs` 形参的显式数组构造器不会隐式地构造另一个隐式数组:

  ```nim
  proc takeV[T](a: varargs[T]) = discard

  takeV([123, 2, 1]) # takeV的T是"int", 不是"int数组"
  ```


`varargs[typed]` 被特别对待: 它匹配任意类型的参数的变量列表，但 *始终* 构造一个隐式数组。这是必需的，只有这样内置的 `echo` 过程能够执行预期的操作:

  ```nim
  proc echo* (x: varargs[typed, `$`]) {...}

  echo @[1, 2, 3]
  # 输出 "@[1, 2, 3]" 而不是 "123"
  ```


未检查数组
--------------------
`UncheckedArray[T]` 类型是一种特殊的 `array` "数组"，编译器不检查它的边界。 这对于实现定制灵活大小的数组通常很有用。 另外，未检查数组可以这样转换为不确定大小的C数组:

  ```nim
  type
    MySeq = object
      len, cap: int
      data: UncheckedArray[int]
  ```

生成的C代码大致是这样的:

  ```C
  typedef struct {
    NI len;
    NI cap;
    NI data[];
  } MySeq;
  ```

未检查数组的基本类型可能不包含任何GC内存，但目前尚未检查。

**未来方向**: 应该在未检查的数组中允许GC内存，并且应该有一个关于GC如何确定数组的运行时大小的显式注解。



元组和对象类型
----------------------------
元组或对象类型的变量是异构存储容器。 元组或对象定义了一个类型的各类 *字段* 。 元组还定义了字段的 *顺序* 。 元组是有很少抽象可能性的异构存储类型。 `()` 可用于构造元组。 构造函数中字段的顺序必须与元组定义的顺序相匹配。 如果它们以相同的顺序指定相同类型的相同字段，则不同的元组类型 *等效*  。字段的 *名称* 也必须相同。

  ```nim
  type
    Person = tuple[name: string, age: int] # type representing a person:
                                           # it consists of a name and an age.
  var person: Person
  person = (name: "Peter", age: 30)
  assert person.name == "Peter"
  # 一样，但不太可读
  person = ("Peter", 30)
  assert person[0] == "Peter"
  assert Person is (string, int)
  assert (string, int) is Person
  assert Person isnot tuple[other: string, age: int] # `other` is a different identifier
  ```

可以使用括号和尾随逗号构造具有一个未命名字段的元组:

  ```nim
  proc echoUnaryTuple(a: (int,)) =
    echo a[0]

  echoUnaryTuple (1,)
  ```


事实上，每个元组结构都允许使用尾随逗号。

字段将会对齐，以此获得最佳性能。对齐与C编译器的方式兼容。

为了与 `object` 声明保持一致， `type` 部分中的元组也可以用缩进而不是 `[]` 来定义:

  ```nim
  type
    Person = tuple   # 代表人的类型
      name: string   # 一个人包括名字
      age: Natural   # 和年龄
  ```

对象提供了许多元组没有的特性。对象提供继承和对其他模块隐藏字段的能力。启用继承的对象在运行时具有有关其类型的信息，因此可以使用 `of` 运算符来确定对象的类型。`of` 运算符类似于 Java 中的 `instanceof` 运算符。

  ```nim
  type
    Person = object of RootObj
      name*: string   # *表示可以从其他模块访问 `name` 
      age: int        # 没有*表示该字段已隐藏

    Student = ref object of Person # 学生是人
      id: int                      # 有个id字段

  var
    student: Student
    person: Person
  assert(student of Student)  # 是真
  assert(student of Person)   # 也是真
  ```

对模块外部可见的对象字段必须用 `*` 标记。与元组相反，不同的对象类型永远不会 *等价* 。 没有祖先的对象是隐式的 `final` ，因此没有隐藏的类型字段。 可以使用 `inheritable` 编译指示来引入除 `system.RootObj` 之外的新根对象。

  ```nim
  type
    Person = object # final 对象的例子
      name* : string
      age: int

    Student = ref object of Person # 错误: 继承只能用于非final对象
      id: int
  ```

元组和对象的赋值操作符复制每个组件。 `这里 <manual.html#procedures-type-bound-operations>`_ 描述了覆盖这种复制行为的方法。


对象构造
----------------

对象也可以使用 `object construction expression`:idx: "对象构建表达式" 创建, 即以下语法 `T(fieldA: valueA, fieldB: valueB, ...)` 其中 `T` 是 `object` 类型或 `ref object` 类型:

 ```nim
  type
    Student = object
      name: string
      age: int
    PStudent = ref Student
  var a1 = Student(name: "Anton", age: 5)
  var a2 = PStudent(name: "Anton", age: 5)
  # 这样也可以直接构造:
  var a3 = (ref Student)(name: "Anton", age: 5)
  # 不是所有字段都必须被提到，而且这些字段可以是乱序的:
  var a4 = Student(age: 5)
  ```

请注意，与元组不同，对象需要字段名称及其值。 对于 `ref object` 类型， `system.new` 是隐式调用的。


对象变体
----------------
在需要简单变体类型的某些情况下，对象层次结构通常有点过了。 对象变体是通过用于运行时类型灵活性的枚举类型区分的标记联合，对照如在其他语言中找到的 *sum类型* 和 *代数数据类型(ADTs)* 的概念。

一个例子:

  ```nim
  # 这是一个如何在Nim中建模抽象语法树的示例
  type
    NodeKind = enum   # 不同的节点类型
      nkInt,          # 带有整数值的叶节点
      nkFloat,        # 带有浮点值的叶节点
      nkString,       # 带有字符串值的叶节点
      nkAdd,          # 加法
      nkSub,          # 减法
      nkIf            # if语句
    Node = ref NodeObj
    NodeObj = object
      case kind: NodeKind  # `kind` 字段是鉴别字段
      of nkInt: intVal: int
      of nkFloat: floatVal: float
      of nkString: strVal: string
      of nkAdd, nkSub:
        leftOp, rightOp: Node
      of nkIf:
        condition, thenPart, elsePart: Node

  # 创建一个新case对象:
  var n = Node(kind: nkIf, condition: nil)
  # 访问`n.thenPart`是有效的，因为 `nkIf` 分支是活动的
  n.thenPart = Node(kind: nkFloat, floatVal: 2.0)

  # 以下语句引发了一个 `FieldError` 异常，因为n.kind的值不合适且 `nkString` 分支未激活:
  n.strVal = ""

  # 无效:会更改活动对象分支:
  n.kind = nkInt

  var x = Node(kind: nkAdd, leftOp: Node(kind: nkInt, intVal: 4),
                            rightOp: Node(kind: nkInt, intVal: 2))
  # 有效:不更改活动对象分支:
  x.kind = nkSub
  ```

从示例中可以看出，对象层次结构的优点是不需要在不同对象类型之间进行转换。 但是，访问无效对象字段会引发异常。

在对象声明中的 `case` 语句和标准 `case` 语句语法一致: `case` 语句的分支也是如此

在示例中， `kind` 字段称为 `discriminator`:idx: "鉴别字段" \: 为安全起见，不能对其进行地址限制，并且对其赋值进行限制: 新值不得导致活动对象分支发生变化。 此外，在对象构造期间指定特定分支的字段时，必须将相应的鉴别字段值指定为常量表达式。

与改变活动的对象分支不同，可以将内存中的旧对象换成一个全新的对象。

  ```nim
  var x = Node(kind: nkAdd, leftOp: Node(kind: nkInt, intVal: 4),
                            rightOp: Node(kind: nkInt, intVal: 2))
  # 改变节点的内容
  x[] = NodeObj(kind: nkString, strVal: "abc")
  ```


从版本0.20开始 `system.reset` 不能再用于支持对象分支的更改，因为这从来就不是完全内存安全的。

作为一项特殊规则，鉴别字段类型也可以使用 `case` 语句来限制。 如果 `case` 语句分支中的鉴别字段变量的可能值是所选对象分支的鉴别字段值的子集，则初始化被认为是有效的。 此分析仅适用于序数类型的不可变判别符，并忽略 `elif` 分支。对于具有 `range` 类型的鉴别器值，编译器会检查鉴别器值的整个可能值范围是否对所选对象分支有效。

一个小例子:

  ```nim
  let unknownKind = nkSub

  # 无效:不安全的初始化，因为类型字段不是静态已知的:
  var y = Node(kind: unknownKind, strVal: "y")

  var z = Node()
  case unknownKind
  of nkAdd, nkSub:
    # 有效:此分支的可能值是nkAdd / nkSub对象分支的子集:
    z = Node(kind: unknownKind, leftOp: Node(), rightOp: Node())
  else:
    echo "ignoring: ", unknownKind

  # 同样有效, 因为 unknownKindBounded 只包含 nkAdd 或 nkSub
  let unknownKindBounded = range[nkAdd..nkSub](unknownKind)
  z = Node(kind: unknownKindBounded, leftOp: Node(), rightOp: Node())
  ```


cast uncheckedAssign
--------------------

case对象的一些限制可以通过 `{.cast(uncheckedAssign).}` 禁用:

  ```nim  test="nim c $1"
  type
    TokenKind* = enum
      strLit, intLit
    Token = object
      case kind* : TokenKind
      of strLit:
        s* : string
      of intLit:
        i* : int64

  proc passToVar(x: var TokenKind) = discard

  var t = Token(kind: strLit, s: "abc")

  {.cast(uncheckedAssign).}:
    # 在 'cast' 块中允许将't.kind'传递给 'var T' 参数:
    passToVar(t.kind)

    # 在 'cast' 块中允许设置字段`s`,即便构造的`kind`字段有未知的值
    t = Token(kind: t.kind, s: "abc")

    # 在 'cast' 块中允许直接分配't.kind'字段
    t.kind = intLit
  ```


集合类型
----------------

.. include:: sets_fragment.txt

引用和指针类型
----------------------------
引用(类似于其他编程语言中的指针)是引入多对一关系的一种方式。 这意味着不同的引用可以指向并修改内存中的相同位置(也称为 `aliasing`:idx: "别名")。

Nim区分 `traced`:idx: "追踪"、`untraced`:idx: "未追踪" 引用。 未追踪引用也叫 *指针* 。 追踪引用指向垃圾回收堆中的对象，未追踪引用指向手动分配对象或内存中其它位置的对象。 因此，未追踪引用是 *不安全* 的。 然而对于某些访问硬件的低级操作，未追踪引用是不可避免的。

使用 **ref** 关键字声明追踪引用，使用 **ptr** 关键字声明未追踪引用。 通常， `ptr T` 可以隐式转换为 `pointer` 类型。

空的下标 `[]` 表示法可以用来取代引用， `addr` 过程返回一个对象的地址。 地址始终是未追踪的引用。 因此， `addr` 的使用是 *不安全的* 功能。

`.` (访问元组和对象字段运算符)和 `[]` (数组/字符串/序列索引运算符)运算符对引用类型执行隐式解引用操作:

  ```nim
  type
    Node = ref NodeObj
    NodeObj = object
      le, ri: Node
      data: int

  var
    n: Node
  new(n)
  n.data = 9
  # 不必写n[].data; 非常不推荐 n[].data！
  ```

可以对例程调用的第一个参数执行自动取消引用，但这是一个实验性功能，在 `这里 <manual_experimental.html#automatic-dereferencing>`_ 进行了说明。

为了简化结构类型检查，递归元组无效:

  ```nim
  # 无效递归
  type MyTuple = tuple[a: ref MyTuple]
  ```

同样， `T = ref T` 是无效类型。

作为语法扩展，如果在类型部分中通过 `ref object` 或 `ptr object` 符号声明，则`object` 类型可以是匿名的。 如果对象只应获取引用语义，则此功能非常有用:

  ```nim
  type
    Node = ref object
      le, ri: Node
      data: int
  ```


要分配新的追踪对象，必须使用内置过程 `new` 。 为了处理未追踪的内存，可以使用过程 `alloc` ， `dealloc` 和 `realloc` 。  `system <system.html>`_ 系统模块的文档包含更多信息。


空(Nil)
--------------

如果一个引用什么都不指向，那么它的值为 `nil` 。 `nil` 是所有 `ref` 和 `ptr` 类型的默认值。`nil` 值也可以像任何其他字面值一样使用。例如，它可以用在像 `my Ref = nil` 这样的赋值中。

取消引用 `nil` 是一个不可恢复的致命运行时错误(而不是panic)。

成功的解引用操作 `p[]` 意味着 `p` 不是 nil。可以利用它来优化代码，例如:

  ```nim
  p[].field = 3
  if p != nil:
    # 如果p是nil, 那么 `p[]` 会导致错误
    # 所以我们知道这里`p`永远不会是nil
    action()
  ```

那么上述代码可以变成:

  ```nim
  p[].field = 3
  action()
  ```


*注意*: 这与 C 用于取消引用 NULL 指针的 "未定义行为" 不具有可比性。


混合GC内存和 `ptr`
------------------------------------

特别要注意的是，如果一个未被跟踪的对象包含被跟踪的对象，例如跟踪的引用，字符串，或序列:为了使得所有对象正确释放，
在释放未被跟踪的内存之前，要手动调用内置过程 `reset` :

  ```nim
  type
    Data = tuple[x, y: int, s: string]

  # 在堆上为Data分配内存:
  var d = cast[ptr Data](alloc0(sizeof(Data)))

  # 在垃圾回收(GC)堆上创建一个新的字符串:
  d.s = "abc"

  # 知GC不再需要这个字符串:
  reset(d.s)

  # 释放内存:
  dealloc(d)
  ```

如果不调用 `reset` ，就绝不会释放分配给 `d.s` 字符串的内存。这个例子从程序底层来说，表现出两个重要的特性: `sizeof` 过程返回一个类型或值的字节大小。 `cast` 操作符可以避开类型系统:
编译器强制将 `alloc0` (会返回一个未定义类型的指针)的结果认定为 `ptr Data` 类型。只有在不可避免的情况下才需要进行转换，因为它破坏了类型安全，bug可能导致未知的崩溃。

**Note**: 当把垃圾收集的数据和非管理的内存混合在一起时，我们需要了解这样的低级细节。这个例子之所以有效，是因为内存被初始化为零( `alloc0` 会这样做，而 `alloc` 不会 )。 `d.s` 因此被初始化为二进制的零，从而可以处理字符串赋值。

.. XXX 终结器，用于跟踪对象


过程类型
----------------
过程类型是一个指向过程的内部指针。对于一个过程类型的变量来说，允许被赋值 `nil` 。

示例:

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


过程类型的一个细微问题是，过程的调用约定会影响类型的兼容性: 过程类型只有在调用约定相同的情况下才兼容。特殊的扩展是，调用约定为 `nimcall` 的过程可以被传递给期望调用约定为 `closure` 的过程参数。

Nim支持下列 `calling conventions`:idx:\ "调用约定":

`nimcall`:idx:
    是默认用于Nim **proc** 的惯例。它和 `fastcall` 一样，但是只有C编译器支持 `fastcall` 。

`closure`:idx:
    对于缺少任意编译指示注解的过程类型 **procedural type** 的默认调用约定。它表明这个过程有一个隐藏的隐式参数(一个 *environment* )。拥有调用约定 `closure` 的函数变量占两个机器字: 一个是用于函数指针，另一个用于隐式传递环境指针。

`stdcall`:idx:
    这是微软指定的标准惯例。声明 `__stdcall` 关键字生成C程序。

`cdecl`:idx:
    cdecl惯例意味着程序将使用和C编译器一样的惯例。在Windows下生成C程序是 `__cdecl` 关键字声明。

`safecall`:idx:
    微软指定的安全调用约定。生成C程序是用 `__safecall` 关键字声明。 *safe* 这个词是指会将所有的硬件寄存器压入硬件堆栈。

`inline`:idx:
    inline内联约定意味着调用者不应该调用过程，而是直接内联其代码。请注意，Nim并不直接内联，而是把这个问题留给C编译器。它生成了 `__inline` 过程，这只是给编译器的一个提示: 编译器可以完全忽略它，也可以内联那些没有标记为 `inline` 的过程。

`fastcall`:idx:
    FastCall意味着对于不同的C编译器有所不同。意味着得获得C `__fastcall` 表示。

`thiscall`:idx:
    这是微软指定的thiscall调用约定，被用于X86架构C++类成员函数中。

`syscall`:idx:
    在C中syscall约定和 `__syscall`:c: 是一样的。它用于中断。

`noconv`:idx:
    生成的C代码将不会有任何的显示调用约定，因此会使用C编译的默认调用约定。这个是需要的，因为Nim默认会对过程使用 `falsecall` 调用约定来提升速度。

大多数调用约定只存在于32位Windows平台。

默认的调用约定是 `nimcall` ，除非它是一个内部过程(一个过程中的过程)。对于一个内部过程，将分析它是否访问其环境。如果它访问了环境，就采用 `closure` 调用约定，否则就采用 `nimcall` 调用约定。


Distinct类型
------------------------

`distinct` 类型是源于 `base type`:idx: "基类"的一个新类型，但它与它的基类并不一致，它是一个特定的基本属性，而且 **不** 意味着它和它的基类型之间存在子类型关系。允许显式将distinct类型转换到它基类型，反之亦然。另请参阅 `distinctBase` 以获取反向操作相关的信息。

如果一个distinct类型的基类型是序数类型，则distinct类型也为序数类型。


### 模拟货币

distinct类型可用于模拟不同的物理 `units`:idx: "单位"，例如，数字基本类型。以下模拟货币的示例。

在货币计算中不应混用不同的货币。Distinct类型是一个模拟不同货币的理想工具:

  ```nim
  type
    Dollar = distinct int
    Euro = distinct int

  var
    d: Dollar
    e: Euro

  echo d + 12
  # 错误: 一个无单位的数字不可以与 `Dollar` 相加
  ```

可惜, 不允许 `d + 12.Dollar` ，因为 `+` 已被 `int` (以及其他)定义，而非 `Dollat` 。所以用于 `Dollar` 的 `+` 需要被这样定义:

  ```nim
  proc `+` (x, y: Dollar): Dollar =
    result = Dollar(int(x) + int(y))
  ```

将一美元乘以一美元是没有意义的，但是可以乘以一个没有单位的数字，除法也一样:

  ```nim
  proc `*` (x: Dollar, y: int): Dollar =
    result = Dollar(int(x) * y)

  proc `*` (x: int, y: Dollar): Dollar =
    result = Dollar(x * int(y))

  proc `div` ...
  ```

这很快就会变得乏味。实现很简单，编译器不应该生成所有这些代码，而稍后又优化它 —— 美元的 `+` 应该产生与整数的 `+` 相同的二进制代码。编译指示 `borrow`:idx: "借用"旨在解决这个问题； 原则上，它会生成上述简单的实现:

  ```nim
  proc `*` (x: Dollar, y: int): Dollar {.borrow.}
  proc `*` (x: int, y: Dollar): Dollar {.borrow.}
  proc `div` (x: Dollar, y: int): Dollar {.borrow.}
  ```

The `borrow` pragma makes the compiler use the same implementation as
the proc that deals with the distinct type's base type, so no code is
generated.

但似乎上述所有的样板要在 `Euro` 货币上都要重复一遍。这个可以使用 templates_ 来解决。

  ```nim  test = "nim c $1"
  template additive(typ: typedesc) =
    proc `+` * (x, y: typ): typ {.borrow.}
    proc `-` * (x, y: typ): typ {.borrow.}

    # 一元操作符:
    proc `+` * (x: typ): typ {.borrow.}
    proc `-` * (x: typ): typ {.borrow.}

  template multiplicative(typ, base: typedesc) =
    proc `*` * (x: typ, y: base): typ {.borrow.}
    proc `*` * (x: base, y: typ): typ {.borrow.}
    proc `div` * (x: typ, y: base): typ {.borrow.}
    proc `mod` * (x: typ, y: base): typ {.borrow.}

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


borrow编译指示也可用于注解distinct类型，以提升某些内置操作:

  ```nim
  type
    Foo = object
      a, b: int
      s: string

    Bar {.borrow: `.`.} = distinct Foo

  var bb: ref Bar
  new bb
  # 字段访问有效
  bb.a = 90
  bb.s = "abc"
  ```

目前只有点访问器可以通过这个方式borrow


### 避免SQL注入攻击

从Nim传递到SQL数据库的SQL语句可能转化为字符串。但是，使用字符串模板并填写值很容易受到著名的 `SQL injection attack`:idx: "SQL注入攻击" \:

  ```nim
  import std/strutils

  proc query(db: DbHandle, statement: string) = ...

  var
    username: string

  db.query("SELECT FROM users WHERE name = '$1'" % username)
  # 糟糕的安全漏洞，但是编译器不关心
  ```

这可以通过区分包含 SQL 的字符串和不包含 SQL 的字符串来避免。Distinct类型提供了一种引入与 `string` 不兼容的新字符串类型 `SQL` 的方法:

  ```nim
  type
    SQL = distinct string

  proc query(db: DbHandle, statement: SQL) = ...

  var
    username: string

  db.query("SELECT FROM users WHERE name = '$1'" % username)
  # 静态错误: `query` 期望一个SQL字符串
  ```


抽象类型有一个重要的属性是，抽象类型与它们的子类型之间没有父子关系。允许显示将 `string` 类型转换到 `SQL` :

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

由于 `"".SQL` 被转换为 `SQL("")` ，因此良好的 `SQL` 字符串文本不需要新的语法。假定的 `SQL` 类型实际作为  `SqlQuery type <db_common.html#SqlQuery>`_ 的模块存在于库中，例如 `db_sqlite <db_sqlite.html>`_ 。


Auto类型
----------------

`auto` 类型只能用来作为返回类型和参数。对于返回类型，它会使编译器从例程主体推断类型:

  ```nim
  proc returnsInt(): auto = 1984
  ```

对于参数，它当前创建隐式常规例程:

  ```nim
  proc foo(a, b: auto) = discard
  ```

和如下一样:

  ```nim
  proc foo[T1, T2](a: T1, b: T2) = discard
  ```

但是，该语言的后续版本可能会将其更改为"从主体推断参数类型"。从而上面的 `foo` 将会被拒绝，因为无法从一个空的 `discard` 语句中推断出参数的类型。


类型关系
================

以下部分定义了描述编译器完成的类型检查所需的几种类型关系。


类型相等性
--------------------

Nim 对大多数类型使用结构类型相等。仅对对象、枚举和distinct类型以及泛型类型使用名称相等。


Subtype关系
----------------------

如果对象 `a` 继承自 `b` ， `a` 是 `b` 的子类型。

子类型关系被拓展到类型 `var` , `ref` , `prt` 。如果 `A` 是 `B` 的子类型， `A` 和 `B` 是 `object` 类型那么:

- `var A`是`var B`的子类型
- `ref A`是`ref B`的子类型
- `ptr A`是`ptr B`的子类型。

**注意**: 在该语言的更高版本中，子类型关系可能会更改为 *要求* 间接指针，以防止 "对象切割" 。


交换关系
----------------

如果以下算法返回 true，则类型 `a` **隐式** 可转换为类型 `b` :

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

我们使用判断 `typeEquals(a, b)` 表示 "类型相等" 属性，使用判断 `isSubtype(a, b)` 表示 "子类型关系"。`compatibleParametersAndEffects(a, b)` 当前未指定。

Nim 的 `range` 类型构造函数也执行隐式转换。

Let `a0`, `b0`为类型`T`。

让 `A = range[a0..b0]` 为参数的类型， `F` 为形参的类型。如果 `a0 >= low(F) 和 b0 <= high(F)` 并且 `T` 和 `F` 都是有符号整数或两者都是无符号整数，则存在从 `A` 到 `F` 的隐式转换。


如果下列算法返回true，则类型 `a` 是显示转换为类型 `b` :

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

可转换关系可以通过用户定义的类型 `converter`:idx: "转换器"放宽。

  ```nim
  converter toInt(x: char): int = result = ord(x)

  var
    x: int
    chr: char = 'a'

  # 隐式转换变化在这里发生
  x = chr
  echo x # => 97
  # 另一个也可以使用显式形式
  x = chr.toInt
  echo x # => 97
  ```

如果 `a` 是左值，并且 `typeEqualsOrDistinct(T, typeof(a))` 成立，则类型转换 `T(a)` 是左值。


Assignment compatibility
------------------------

An expression `b` can be assigned to an expression `a` iff `a` is an
`l-value` and `isImplicitlyConvertible(b.typ, a.typ)` holds.


重载解决方案
========================

在调用 `p(args)` 中，选择最匹配的例程 `p`。如果多个例程匹配相同，则在语义分析期间报告歧义。

args 中的每个 arg 都需要匹配。一个实参可以匹配多个不同的类别。假设 `f` 是形参的类型，`a` 是参数的类型。

1. 完全匹配: `a` 和 `f` 是同一类型。
2. 字面值匹配: `a` 是值 `v` 的整数字面值， `f` 是有符号或无符号整数类型， `v` 在 `f` 的范围内。 或者: `a` 是值`v` 的浮点字面值， `f` 是浮点类型， `v` 在 `f` 的范围内。
3. 泛型匹配: `f` 是泛型类型和 `a` 匹配，例如 `a` 是 `int` 而 `f` 是泛型(受约束的)参数类型(如在 `[T]` 或 `[ T:int|char]` )。
4. 子范围或子类型匹配: `a` 是 `range[T]` ， `T` 与 `f` 完全匹配。 或者: `a` 是 `f` 的子类型。
5. 整数转换匹配: `a` 可以转换为 `f` ， `f` 和 `a` 是某些整数或浮点类型。
6. 转换匹配: `a` 可转换为 `f` ，可能通过用户定义的 `converter` 。

在下文中，`count(p, m)` 计算例程 `p` 的匹配类别 `m` 的匹配数。

这些匹配类别有一个优先级: 精确匹配比字面值匹配更好，比常规匹配更好，等等。在下面的代码中，`count(p, m)` 计算了例程 `p` 匹配类别 `m` 的匹配次数。

如果以下算法返回 true，则例程 `p` 比例程 `q` 匹配得更好:

  for each matching category m in ["exact match", "literal match",
                                  "generic match", "subtype match",
                                  "integral match", "conversion match"]:
    if count(p, m) > count(q, m): return true
    elif count(p, m) == count(q, m):
      discard "continue with next category m"
    else:
      return false
  return "ambiguous"


一些例子:

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


如果此算法返回 "ambiguous" "歧义"，则执行进一步消除歧义: 如果参数 `a` 通过子类型关系同时匹配 `p` 的参数类型 `f` 和 `q` 的 `g`，则考虑继承深度:

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
  # 没有歧义, 调用 'B' ，而不是 'A' ，因为 B 是 A 的子类型
  # 但反之亦然:
  p(c)

  proc pp(obj: A, obj2: B) = echo "A B"
  proc pp(obj: B, obj2: A) = echo "B A"

  # 但是这个有歧义:
  pp(c, c)
  ```


类似，对于泛型匹配，最特化的泛型类型(仍然匹配)是首选:

  ```nim
  proc gen[T](x: ref ref T) = echo "ref ref T"
  proc gen[T](x: ref T) = echo "ref T"
  proc gen[T](x: T) = echo "T"

  var ri: ref int
  gen(ri) # "ref T"
  ```


基于 'var T' 的重载
--------------------------------------

如果形参 `f` 是 `var T` 类型，除了普通类型检查外，参数会被检查为 `l-value`:idx: "左值" 。`var T` 比 `T` 更好匹配。

  ```nim
  proc sayHi(x: int): string =
    # 匹配一个非可变整型
    result = $x
  proc sayHi(x: var int): string =
    # 匹配一个整形变量
    result = $(x + 10)

  proc sayHello(x: int) =
    var m = x # 一个x的可变版本
    echo sayHi(x) # 匹配sayHi的非可变版本
    echo sayHi(m) # 匹配sayHi的可变版本

  sayHello(3) # 3
              # 13
  ```


无类型的惰性类型解析
----------------------------------------

`unresolved`:idx: "未解析"表达式是没有符号的表达式，不执行查找和类型检查。

由于未声明为 `immediate` 的模板和宏参与重载解析，因此必须有一种方法将未解析的表达式传递给模板或宏。 这就是元类型 `untyped` 的任务:

  ```nim
  template rem(x: untyped) = discard

  rem unresolvedExpression(undeclaredIdentifier)
  ```

`untyped` 类型的参数总是匹配任意参数(只要有任意参数传递给它)。

但是必须小心，因为其他重载可能会触发参数解析:

  ```nim
  template rem(x: untyped) = discard
  proc rem[T](x: T) = discard

  # 未声明的标识符: 'unresolvedExpression'
  rem unresolvedExpression(undeclaredIdentifier)
  ```

`untyped` 和 `varargs[untyped]` 是唯一在这个意义上惰性的元类型，其他元类型 `typed` 和 `typedesc` 是非惰性的。


可变参数匹配
------------------------

参阅 `Varargs <#types-varargs>`_.


迭代器
------------

yielding类型 `T` 的迭代器可以通过类型为 `untyped` (用于未解析的表达式)或类型类 `iterable` 或 `iterable[T]` (在类型检查和重载解析之后)的参数传递给模板或宏。

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


重载disambiguation
====================================

对于例程调用，执行 "重载解析" 。 有一种称为 *overload disambiguation* *重载歧义消除* 的弱形式的重载解析，当重载符号用于有附加类型信息可用的上下文中时执行。 假设 `p` 成为重载符号， 则上下文是:

- 当 `q` 的相应形式参数是 `proc` 类型时，在函数调用 `q(..., p, ...)` 中。 如果 `q` 本身被重载，则必须考虑 `q` 和 `p` 的每种解释的笛卡尔积。
- 在一个对象构造函数中 `Obj(..., field: p, ...)` 当 `field` 是 `proc` 类型。类似的规则也适用于 array/set/tuple 的构造函数。
- 有这样的声明 `x: T = p` 当 `T` 是 `proc` 类型。

通常情况下，有歧义的匹配会产生编译错误。

命名参数重载
------------------------

如果形参的名称不同，则可以分别调用具有相同类型签名的例程。

  ```Nim
  proc foo(x: int) =
    echo "Using x: ", x
  proc foo(y: int) =
    echo "Using y: ", y

  foo(x = 2) # Using x: 2
  foo(y = 2) # Using y: 2
  ```

在这种情况下不提供参数名称会导致歧义错误。


语句和表达式
========================

Nim 使用通用的"语句/表达式"范式: 与表达式相比，语句不产生值。 但是，有些表达式是语句。

语句被分成  `simple statements`:idx: "简单语句" 和 `complex statements`:idx: "复杂语句" 。单语句是不能包含其他语句的语句，如赋值、调用或 `return` 语句； 复杂语句包含其他语句。 为了避免  `dangling else problem`:idx: "不确定性问题"，复杂的语句总是必须缩进, 细节可以在语法一节中找到。


语句列表表达式
----------------------------

语句也可以出现在看起来像 `(stmt1; stmt2; ...; ex)` 这样的形式。 这称为语句列表表达式或 `(;)` 。 `(stmt1; stmt2; ...; ex)` 的类型是 `ex` 类型。 所有其他语句必须是 `void` 类型。 (可以使用 `discard` 来生成 `void` 类型。) `(;)` 不会引入新的作用域。


Discard语句
----------------------

示例:

```nim
  proc p(x, y: int): int =
    result = x + y

  discard p(3, 4) # 丢弃 `p` 的返回值
  ```

`discard` 语句评估其表达式的副作用并将表达式的结果值丢弃，并且只应在已知忽略此值不会导致问题时使用。

忽略过程的返回值而不使用丢弃语句是静态错误。

如果调用的 proc/iterator 已使用 `discardable`:idx: "可废弃的"编译指示声明，则可以隐式忽略返回值:

  ```nim
  proc p(x, y: int): int {.discardable.} =
    result = x + y

  p(3, 4) # 当前有效
  ```

但是可丢弃的编译指示不适用于模板，因为模板会替换掉 AST。 例如:

  ```nim
  {.push discardable .}
  template example(): string = "https://nim-lang.org"
  {.pop.}

  example()
  ```

此模板将解析为字符串字面值 "https://nim-lang.org" ，但由于 {.discardable.} 不适用于字面值，编译器会出错。

空的 `discard` 语句通常用于一个空的语句中:

  ```nim
  proc classify(s: string) =
    case s[0]
    of SymChars, '_': echo "an identifier"
    of '0'..'9': echo "a number"
    else: discard
  ```


空下上文
----------------

在语句列表中，除了最后一个表达式之外，每个表达式都需要类型为 `void` 。除了这个规则，对内置 `result` 符号的赋值也会为后续的表达式触发一个强制的 `void` 上下文:

  ```nim
  proc invalid* (): string =
    result = "foo"
    "invalid"  # 错误: 类型 `string` 的值必须被抛弃
  ```

  ```nim
  proc valid*(): string =
    let x = 317
    "valid"
  ```


Var语句
--------------

Var 语句声明新的局部和全局变量并初始化它们。逗号分隔的变量列表可用于指定相同类型的变量:

  ```nim
  var
    a: int = 0
    x, y, z: int
  ```

如果给定了初始化器，则可以省略类型: 变量的类型与初始化表达式的类型相同。如果没有初始化表达式，则始终使用默认值初始化变量。默认值取决于类型，并且在二进制中始终为零。

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
tuple[x: A, y: B, ...]          (default(A), default(B), ...)
                                (analogous for objects)
array[0..., T]                  [default(T), ...]
range[T]                        default(T); 这个可能会超出有效范围
T = enum                        cast[T]\(0); 这个可能是一个非法值
============================    ==========================================================

出于优化原因，可以使用 `noinit`:idx: "无初始化"编译指示来避免隐式初始化:

  ```nim
  var
    a {.noinit.}: array[0..1023, char]
  ```

如果proc使用 `noinit` 编译指示，这指的是其隐式 `result` 变量:

  ```nim
  proc returnUndefinedValue: int {.noinit.} = discard
  ```


`requiresInit`:idx: "需初始化"类型编译指示也可以防止隐式初始化。编译器需要对对象及其所有字段进行显式初始化。但是，它会进行 `control flow analysis`:idx: "控制流分析" 以验证变量已被初始化并且不依赖于语法属性:

  ```nim
  type
    MyObject = object {.requiresInit.}

  proc p() =
    # 以下有效:
    var x: MyObject
    if someCondition():
      x = a()
    else:
      x = a()
    # 使用 x
  ```

`requiresInit` 编译指示也可以应用于 `distinct` 类型。

给定以下不同的类型定义:

  ```nim
  type
    Foo = object
      x: string

    DistinctFoo {.requiresInit, borrow: `.`.} = distinct Foo
    DistinctString {.requiresInit.} = distinct string
  ```

下列代码块将会编译失败:

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

但这些将会编译成功:

  ```nim
  let foo = DistinctFoo(Foo(x: "test"))
  doAssert foo.x == "test"
  ```

  ```nim
  let s = DistinctString("test")
  doAssert string(s) == "test"
  ```

Let语句
--------------

`let` 语句声明了新的局部和全局 `single assignment`:idx: "唯一赋值"变量并将值绑定到它们。语法与 `var` 语句的语法相同，只是关键字 `var` 被关键字 `let` 替换。let变量不是左值，因此不能传递给 `var` 参数也不能获取他们的地址。不能为它们分配新值。

对于 let 变量，可以使用与普通变量相同的编译指示。

由于 `let` 语句在创建后是不可变的，因此它们需要在声明时定义一个值。 唯一的例外是如果应用了 `{.importc.}` 编译指示(或任何其他 `importX` 编译指示)，在这种情况下，值应该来自本机代码，通常是 C/C++ `const` 。


元组解包
----------------

在 `var` 或 `let` 语句中可以执行元组解包。 特殊标识符 `_` 可用于忽略元组的某些部分:

  ```nim
  proc returnsTuple(): (int, int, int) = (4, 2, 3)

  let (x, _, z) = returnsTuple()
  ```



常量域
------------

const部分声明的常量的值是常量表达式:

  ```nim
  import std/[strutils]
  const
    roundPi = 3.1415
    constEval = contains("abc", 'b') # 在编译时计算
  ```

一旦声明，常量的符号就可以用作常量表达式。

详情参阅 `Constants and Constant Expressions <#constants-and-constant-expressions>`_ 。

静态语句/表达式
------------------------------

静态语句/表达式明确需要编译时执行。甚至在静态块中也允许一些具有副作用的代码:

  ```nim
  static:
    echo "echo at compile time"
  ```

`static` 也可以像例程一样使用。

  ```nim
  proc getNum(a: int): int = a

  # 以下，在编译时调用 "echo getNum(123)" 
  static:
    echo getNum(123)

  # 下面的调用在编译时计算 "getNum(123)" ，但其结果在运行时使用。
  echo static(getNum(123))
  ```

在编译时可以执行哪些 Nim 代码是有限制的；详情参阅 `Restrictions on Compile-Time Execution <#restrictions-on-compileminustime-execution>`_ 。如果编译器无法在编译时执行该块，则会是一个静态错误。


If语句
------------

示例:

  ```nim
  var name = readLine(stdin)

  if name == "Andreas":
    echo "What a nice name!"
  elif name == "":
    echo "Don't you have a name?"
  else:
    echo "Boring name..."
  ```

`if` 语句是在控制流中创建分支的一种简单方法: 计算关键字 `if` 后的表达式，如果为真，则执行 `:` 后的相应语句。 否则，计算 `elif` 之后的表达式(如果有 `elif` 分支)。 如果所有条件都失败，则执行 `else` 部分。 如果没有 `else` 部分，则继续执行下一条语句。

在 `if` 语句中，新的作用域在 `if`/`elif`/`else` 关键字之后立即开始，并在相应的 *那个* 块之后结束。 出于呈现的目的，在以下示例中，作用域被包含在 `{| |}` 中:

  ```nim
  if {| (let m = input =~ re"(\w+)=\w+"; m.isMatch):
    echo "key ", m[0], " value ", m[1]  |}
  elif {| (let m = input =~ re""; m.isMatch):
    echo "new m in this scope"  |}
  else: {|
    echo "m not declared here"  |}
  ```

Case 语句
------------------

示例:

  ```nim
  let line = readline(stdin)
  case line
  of "delete-everything", "restart-computer":
    echo "permission denied"
  of "go-for-a-walk":     echo "please yourself"
  elif line.len == 0:     echo "empty" # optional, must come after `of` branches
  else:                   echo "unknown command" # ditto

  # 允许分支缩进; 冒号是可选的
  # 在选择表达式之后:
  case readline(stdin):
    of "delete-everything", "restart-computer":
      echo "permission denied"
    of "go-for-a-walk":     echo "please yourself"
    else:                   echo "unknown command"
  ```


`case` 语句类似于 `if` 语句, 但它表示一种多分支选择。
关键字 `case` 后面的表达式是求值, 如果它的值在 *slicelist* 列表中, 那么则执行( `of` 关键字之后)相应语句。
如果该值不在任何已给定的 *slicelist* 中, 那么 `elif` 和 `else` 部分所执行的语句与 `if` 语句相同, `elif` 的处理就像 `else: if` 。
如果没有 `else` 或 `elif` 部分，并且 `expr` 不能持有所有可能的值,则在 *slicelist* 会发生静态错误。
这仅适用于序数类型的表达式。 `expr` 的 "所有可能的值" 由 `expr` 的类型决定，为了阻止静态错误应该使用 `else: discard`。

对于非序数类型, 不可能列出每一个可能的值，所以这些值总是需要 `else` 部分。
该规则的一个例外是 `string` 类型，目前它不需要在后面添加 `else` 或 `elif` 分支。
目前还不确定这是否会在未来的版本中继续工作。

因为在语义分析期间检查case语句的穷尽性，所以每个 `of` 分支中的值必须是常量表达式。
此限制可以让编译器生成更高性能的代码。

作为一种特殊的语义扩展, case语句的 `of` 分支中的表达式可以计算为集合或数组构造函数，
然后将集合或数组扩展为其元素列表:

  ```nim
  const
    SymChars: set[char] = {'a'..'z', 'A'..'Z', '\x80'..'\xFF'}

  proc classify(s: string) =
    case s[0]
    of SymChars, '_': echo "an identifier"
    of '0'..'9': echo "a number"
    else: echo "other"

  # 等价于:
  proc classify(s: string) =
    case s[0]
    of 'a'..'z', 'A'..'Z', '\x80'..'\xFF', '_': echo "an identifier"
    of '0'..'9': echo "a number"
    else: echo "other"
  ```

 `case` 语句不会产生左值, 所以下面的示例不会生效:

    ```nim
  type
    Foo = ref object
      x: seq[string]

  proc get_x(x: Foo): var seq[string] =
    # 不生效
    case true
    of true:
      x.x
    else:
      x.x

  var foo = Foo(x: @[])
  foo.get_x().add("asd")
  ```

这可以通过显式使用 'result' 或 'return' 来修复:

  ```nim
  proc get_x(x: Foo): var seq[string] =
    case true
    of true:
      result = x.x
    else:
      result = x.x
  ```


When 语句
------------------

示例:

  ```nim
  when sizeof(int) == 2:
    echo "running on a 16 bit system!"
  elif sizeof(int) == 4:
    echo "running on a 32 bit system!"
  elif sizeof(int) == 8:
    echo "running on a 64 bit system!"
  else:
    echo "cannot happen!"
  ```

 `when` 语句几乎与 `if` 语句完全相同, 但有一些例外:

* 每个条件 ( `expr` ) 必须是一个常量表达式 (类型为 `bool` )。
* 语句不产生新作用域。
* 属于计算为true的表达式的语句由编译器翻译, 其他语句不检查语义! 但是, 检查每个条件的语义。

 `when` 语句启用条件编译技术。作为一种特殊的语法扩展,  `when` 结构也可以在 `object` 定义中使用。


When nimvm 语句
------------------------------

`nimvm` 是一个特殊的符号, 可以作为 `when nimvm` 语句的表达式来区分编译时和可执行文件之间的执行路径。

示例:

  ```nim
  proc someProcThatMayRunInCompileTime(): bool =
    when nimvm:
      # 编译时采用这个分支.
      result = true
    else:
      # 可执行文件中采用这个分支.
      result = false
  const ctValue = someProcThatMayRunInCompileTime()
  let rtValue = someProcThatMayRunInCompileTime()
  assert(ctValue == true)
  assert(rtValue == false)
  ```

 `when nimvm` 语句必须满足以下要求: 

* 它的表达式必须是 `nimvm` 。不允许使用的复杂表达式。
* 它必须不含有 `elif` 分支。
* 必须含有 `else` 分支。
* 分支中的代码不能影响 `when nimvm` 语句后面的代码的语义. 比如它不能定义后续代码中使用的符号。

Return 语句
----------------------

示例:

  ```nim
  return 40 + 2
  ```

 `return` 语句结束当前过程的执行。它只允许在过程中使用。如果有一个 `expr` , 将是一个语法糖:

  ```nim
  result = expr
  return result
  ```


如果proc有返回类型，不带表达式的 `return` 是 `return result` 的简短表示法.
变量 `result`:idx: 始终是过程的返回值。它由编译器自动声明。与所有变量一样, `result` 初始化为(二进制)0:

  ```nim
  proc returnZero(): int =
    # 隐式返回0
  ```


Yield 语句
--------------------

示例:

  ```nim
  yield (1, 2, 3)
  ```

在迭代器中使用 `yield` 语句而不是 `return` 语句。它只在迭代器中生效。执行返回给调用迭代器的for循环体。
Yield不会结束迭代过程，但是如果下一次迭代开始，则执行会返回到迭代器。请参阅关于迭代器的部分( `Iterators and the for statement`_ )以了解更多信息。


Block 语句
--------------------

示例:

  ```nim
  var found = false
  block myblock:
    for i in 0..3:
      for j in 0..3:
        if a[j][i] == 7:
          found = true
          break myblock # 跳出两个for循环块
  echo found
  ```

block语句是一种将语句分组到(命名) `block` 的方法。在block语句内，允许 `break` 语句立即跳出block。 `break` 语句可以包含周围block的名称, 以指定要跳出的block。


Break 语句
--------------------

示例:

  ```nim
  break
  ```

 `break` 语句用于立即跳出block。如果给出 `symbol` 类型, 则它是要跳出的封闭block的名称。如果不存在，则跳出最里面的block。


While 语句
--------------------

示例:

  ```nim
  echo "Please tell me your password:"
  var pw = readLine(stdin)
  while pw != "12345":
    echo "Wrong password! Next try:"
    pw = readLine(stdin)
  ```


执行 `while` 语句直到 `expr` 计算结果为false。无尽的循环不是错误。 `while` 语句打开一个 `implicit block` "隐式块"，这样它们就可以用 `break` 语句跳出。


Continue 语句
--------------------------

 `continue` 语句会导致循环结构进行下一次迭代，它只允许在循环中使用。continue语句是嵌套block的语法糖:

  ```nim
  while expr1:
    stmt1
    continue
    stmt2
  ```

等价于:

  ```nim
  while expr1:
    block myBlockName:
      stmt1
      break myBlockName
      stmt2
  ```


汇编语句
----------------

不安全的 `asm` 语句支持将汇编代码直接嵌入到Nim代码中。在汇编代码中引用Nim标识符的标识符应该包含在一个特殊字符中。该字符可以在语句的编译指示中指定。默认的特殊字符是 `'\`'` :

  ```nim
  {.push stackTrace:off.}
  proc addInt(a, b: int): int =
    # a 在 eax 中, b 在 edx 中
    asm """
        mov eax, `a`
        add eax, `b`
        jno theEnd
        call `raiseOverflow`
      theEnd:
    """
  {.pop.}
  ```

如果使用GNU汇编器，则会自动插入引号和换行符: 

  ```nim
  proc addInt(a, b: int): int =
    asm """
      addl %%ecx, %%eax
      jno 1
      call `raiseOverflow`
      1:
      :"=a"(`result`)
      :"a"(`a`), "c"(`b`)
    """
  ```

替代:

  ```nim
  proc addInt(a, b: int): int =
    asm """
      "addl %%ecx, %%eax\n"
      "jno 1\n"
      "call `raiseOverflow`\n"
      "1: \n"
      :"=a"(`result`)
      :"a"(`a`), "c"(`b`)
    """
  ```

Using语句
------------------

`using` 语句在模块中反复使用相同的参数名称和类型提供了语法上的便利，而不必:

  ```nim
  proc foo(c: Context; n: Node) = ...
  proc bar(c: Context; n: Node, counter: int) = ...
  proc baz(c: Context; n: Node) = ...
  ```

你可以告知编译器一个名为 `c` 的参数默认类型为 `Context` , `n` 默认类型为 `Node` :

  ```nim
  using
    c: Context
    n: Node
    counter: int

  proc foo(c, n) = ...
  proc bar(c, n, counter) = ...
  proc baz(c, n) = ...

  proc mixedMode(c, n; x, y: int) =
    # 'c' 被推断为 'Context' 类型
    # 'n' 被推断为 'Node' 类型
    # 'x' and 'y' 是 'int' 类型。
  ```

 `using` 部分使用相同的基于缩进的分组语法作为 `var` 或 `let` 部分。

注意, `using` 不适用于 `template` ,因为无类型模板参数默认为类型 `system.untyped` 。

应该使用 `using` 声明和显式类型的参数混合参数，它们之间需要分号。


If 表达式
------------------

`if` 表达式与if语句非常相似，但它是一个表达式。这个特性类似于其他语言中的 *三元操作符* 。
示例: 

  ```nim
  var y = if x > 8: 9 else: 10
  ```

if表达式总是会产生一个值，所以 `else` 部分是必需的。`Elif` 部分也可以使用。

When表达式
--------------------

和 `if` 表达式相似，但对应的是 `when` 语句。

Case表达式
--------------------

 `case` 表达式与case语句非常相似:

  ```nim
  var favoriteFood = case animal
    of "dog": "bones"
    of "cat": "mice"
    elif animal.endsWith"whale": "plankton"
    else:
      echo "I'm not sure what to serve, but everybody loves ice cream"
      "ice cream"
  ```

如上例所示，case表达式也可以引入副作用。当为分支给出多个语句时，Nim将使用最后一个表达式作为结果值。

Block表达式
----------------------

 `block` 表达式几乎和block语句相同，但它是一个表达式，它使用block的最后一个表达式作为值。它类似于语句列表表达式，但语句列表表达式不会创建新的block作用域。

  ```nim
  let a = block:
    var fib = @[0, 1]
    for i in 0..10:
      fib.add fib[^1] + fib[^2]
    fib
  ```

表构造函数
--------------------

表构造函数是数组构造函数的语法糖: 

  ```nim
  {"key1": "value1", "key2", "key3": "value2"}

  # 等同于:
  [("key1", "value1"), ("key2", "value2"), ("key3", "value2")]
  ```


空表可以写成 `{:}` (与 `{}` 的空集相反)，这是另一种写为空数组构造函数 `[]` 的方法。这种略微不同寻常的书写表的方式有很多优点:

* 保留了(键, 值)对的顺序, 因此很容易支持有序的字典，例如`{key: val}.newOrderedTable`。
* 表字面值可以放入 const 部分，编译器可以很容易地将它放入可执行文件的数据部分，就像数组一样，生成的数据部分只需要很少的内存。
* 每个表的实现 在语法上都是一样的。
* 除了最小的语法糖之外, 语言核心不需要了解表。


类型转换
----------------

从语法上来说， *类型转换* 类似于过程调用，但是类型名替换过程名。类型转换总是安全的，因为将类型转换为另一个类型失败会导致异常(如果无法静态确定)。

普通的procs通常比Nim中的类型转换更受欢迎: 例如, `$` 是 `toString` 运算符, 而 `toFloat` 和 `toInt` 可用于从浮点转换为整数, 反之亦然。

类型转换也可用于消除重载例程的歧义:

  ```nim
  proc p(x: int) = echo "int"
  proc p(x: string) = echo "string"

  let procVar = (proc(x: string))(p)
  procVar("a")
  ```

由于对无符号数的操作会自动换行且不会检查，因此到无符号整数的类型转换以及无符号整数之间的类型转换也是如此。这样做的基本原理是，当算法从C移植到Nim时，可以更好地与C编程语言进行互操作。

异常: 将检查在编译时转换为unsigned类型的值, 以使 `byte(-1)` 之类的代码无法编译。

**注意**: 历史版本上运算是未检查的，转换有时也会检查，但从本文档的1.0.4版本和语言实现开始，转换 *总是未检查* 。


类型强转
----------------

类型强转是一种粗暴的机制，用于解释表达式的位模式，就好像它将是另一种类型一样。类型强转仅用于低级编程，并且本质上是不安全的。

  ```nim
  cast[int](x)
  ```

强制转换的目标类型必须是具体类型，例如，类型类(非具体)的目标类型将是无效的:

  ```nim
  type Foo = int or float
  var x = cast[Foo](1) # Error: cannot cast to a non concrete type: 'Foo'
  ```

类型转换不应与 *类型转换混淆* , 如前一节所述。与类型转换不同，类型强制转换不能更改被强制转换数据的底层位模式(除了目标类型的大小可能与源类型不同之外)。强制转换类似于其他语言中的特性 *类型双关语* 或c++的 `reinterpret_cast`:cpp: 和 `bit_cast`:cpp: 。

addr操作符
--------------------
 `addr` 运算符返回左值的地址。如果地址的类型是 `T`, 则 `addr` 运算符结果的类型为 `ptr T` 。地址总是一个未追踪引用的值。获取驻留在堆栈上的对象的地址是 **不安全的** , 因为指针可能比堆栈中的对象存在更久, 因此可以引用不存在的对象，我们可以得到变量的地址。为了更容易与其他编译语言(如C)互操作，检索 `let` 变量、参数或 `for` 循环变量的地址也可以完成:

  ```nim
  let t1 = "Hello"
  var
    t2 = t1
    t3 : pointer = addr(t2)
  echo repr(addr(t2))
  # --> ref 0x7fff6b71b670 --> 0x10bb81050"Hello"
  echo cast[ptr string](t3)[]
  # --> Hello
  # The following line also works
  echo repr(addr(t1))
  ```

unsafeAddr操作符
--------------------------------

`unsafeAddr` 操作符是 `addr` 操作符的已弃用别名:

  ```nim
  let myArray = [1, 2, 3]
  foreignProcThatTakesAnAddr(unsafeAddr myArray)
  ```

过程
========

大多数编程语言称之为 `methods`:idx "方法"或 `functions`:idx "函数"在Nim中称为 `procedures`:idx "过程"。过程声明由标识符、零个或多个形式参数、返回值类型和代码块组成，形式参数声明为由逗号或分号分隔的标识符列表。形参由 `: typename` 给出一个类型。该类型适用于紧接其之前的所有参数，直到达到参数列表的开头，分号分隔符或已经键入的参数。
分号可用于使类型和后续标识符的分隔更加清晰。

  ```nim
  # 只使用逗号
  proc foo(a, b: int, c, d: bool): int

  # 使用分号进行视觉区分
  proc foo(a, b: int; c, d: bool): int

  # 会失败: a是无类型的, 因为 ';' 停止类型传播
  proc foo(a; b: int; c, d: bool): int
  ```

可以使用默认值声明参数，如果调用者没有为参数提供值，则使用该默认值，每次调用函数时，都会重新计算该值。

  ```nim
  # b是可选的, 默认值为47。
  proc foo(a: int, b: int = 47): int
  ```

正如逗号从右到左传播类型，直到遇到第一个参数或分号，它也从用它声明的参数开始传播默认值。

  ```nim
  # a和b都是可选的，默认值为47。
  proc foo(a, b: int = 47): int
  ```

参数可以声明为可变的，因此允许proc通过使用类型修饰符 `var` 来修改这些参数。

  ```nim
  # 通过第二个参数 "returning" 一个值给调用者
  # 请注意, 该函数根本不使用实际返回值(即void)
  proc foo(inp: int, outp: var int) =
    outp = inp + 47
  ```

如果proc声明没有正文, 则它是一个 `forward`:idx: "前置"声明。如果proc返回一个值，那么过程体可以访问一个名为 `result`:idx: 的隐式声明的变量。过程可能会重载，重载解析算法确定哪个proc是参数的最佳匹配。
示例: 

  ```nim
  proc toLower(c: char): char = # toLower 字符
    if c in {'A'..'Z'}:
      result = chr(ord(c) + (ord('a') - ord('A')))
    else:
      result = c

  proc toLower(s: string): string = # 字符串 toLower
    result = newString(len(s))
    for i in 0..len(s) - 1:
      result[i] = toLower(s[i]) # 为字符调用toLower;不递归!
  ```

调用过程可以通过多种方式完成: 

  ```nim
  proc callme(x, y: int, s: string = "", c: char, b: bool = false) = ...

  # 带位置参数的调用     # 参数绑定:
  callme(0, 1, "abc", '\t', true)       # (x=0, y=1, s="abc", c='\t', b=true)
  # 使用命名参数和位置参数调用:
  callme(y=1, x=0, "abd", '\t')         # (x=0, y=1, s="abd", c='\t', b=false)
  # 带命名参数的调用(顺序无关):
  callme(c='\t', y=1, x=0)              # (x=0, y=1, s="", c='\t', b=false)
  # 作为命令语句调用:不需要():
  callme 0, 1, "abc", '\t'              # (x=0, y=1, s="abc", c='\t', b=false)
  ```

过程可以递归地调用自身。


`Operators`:idx: 是具有特殊运算符符号作为标识符的过程:

  ```nim
  proc `$` (x: int): string =
    # 将整数转换为字符串;这是一个前缀运算符。
    result = intToStr(x)
  ```

具有一个参数的运算符是前缀运算符，具有两个参数的运算符是中缀运算符。(但是, 解析器将这些与运算符在表达式中的位置区分开来。) 没有办法声明后缀运算符: 所有后缀运算符都是内置的，并由语法显式处理。

任何运算符都可以像普通的proc一样用 \`opr\` 表示法调用。(因此运算符可以有两个以上的参数):

  ```nim
  proc `*+` (a, b, c: int): int =
    # 乘 和 加
    result = a * b + c

  assert `*+`(3, 4, 6) == `+`(`*`(a, b), c)
  ```


导出标记
----------------

如果声明的符号标有 `asterisk`:idx: "星号"，它从当前模块导出:

  ```nim
  proc exportedEcho*(s: string) = echo s
  proc `*`*(a: string; b: int): string =
    result = newStringOfCap(a.len * b)
    for i in 1..b: result.add a

  var exportedVar*: int
  const exportedConst* = 78
  type
    ExportedType* = object
      exportedField*: int
  ```


方法调用语法
------------------------

对于面向对象的编程，可以使用语法 `obj.methodName(args)` 而不是 `methodName(obj, args)` 。
如果没有剩余的参数，则可以省略括号: `obj.len` (而不是 `len(obj)` )。

此方法调用语法不限于对象，它可用于为过程提供任何类型的第一个参数:

  ```nim
  echo "abc".len # is the same as echo len "abc"
  echo "abc".toUpper()
  echo {'a', 'b', 'c'}.card
  stdout.writeLine("Hallo") # the same as writeLine(stdout, "Hallo")
  ```

查看方法调用语法的另一种方法是它提供了缺少的后缀表示法。

方法调用语法与显式泛型实例化冲突: `p[T](x)` 不能写为 `x.p[T]` 因为 `x.p[T]` 总是被解析为 `(x.p)[T]` 。

详见: `Limitations of the method call syntax <#templates-limitations-of-the-method-call-syntax>`_ 。

`[: ]` 符号是为了缓解这个问题: `x.p[:T]` 由解析器重写为 `p[T](x)` , `x.p[:T](y)` 被重写为 `p[T](x, y)` . 注意 `[: ]` 没有AST表示, 重写直接在解析步骤中执行。


属性
--------
Nim不需要 *get-properties* :使用 *方法调用语法* 调用的普通get-procedure达到相同目的。但设定值是不同的; 为此需要一个特殊的setter语法: 

  ```nim
  #  asocket 模块
  type
    Socket* = ref object of RootObj
      host: int # cannot be accessed from the outside of the module

  proc `host=`*(s: var Socket, value: int) {.inline.} =
    ## hostAddr的setter.
    ## 它访问'host'字段并且不是对 ``host =`` 的递归调用, 如果内置的点访问方法可用, 则首选点访问:
    s.host = value

  proc host*(s: Socket): int {.inline.} =
    ##hostAddr的getter
    ## This accesses the 'host' field and is not a recursive call to
    ## 它访问'host'字段并且不是对 ``host`` 的递归调用, 如果内置的点访问方法可用, 则首选点访问:
    s.host
  ```

  ```nim
  # 模块 B
  import asocket
  var s: Socket
  new s
  s.host = 34  # same as `host=`(s, 34)
  ```

定义为 `f=` 的proc(后面跟 `=` )被称为 `setter`:idx: 。
可以通过常见的反引号表示法显式调用setter: 

  ```nim
  proc `f=`(x: MyObject; value: string) =
    discard

  `f=`(myObject, "value")
  ```


 `f=` 可以在模式 `x.f = value` 中隐式调用，当且仅当 `x` 的类型没有名为 `f` 的字段或者 `f` 时在当前模块中不可见。这些规则确保对象字段和访问者可以具有相同的名称。在模块 `x.f` 中总是被解释为字段访问，在模块外部它被解释为访问器proc调用。


命令调用语法
------------------------

如果调用在语法上是一个语句，则可以在没有 `()` 的情况下调用例程。此命令调用语法也适用于表达式。但之后只能有一个参数。这种限制意味着 `echo f 1, f 2` 被解析为 `echo(f(1), f(2))` 而不是 `echo(f(1, f(2)))` 。
在这种情况下, 方法调用语法可以用来提供更多的参数。

  ```nim
  proc optarg(x: int, y: int = 0): int = x + y
  proc singlearg(x: int): int = 20*x

  echo optarg 1, " ", singlearg 2  # 打印 "1 40"

  let fail = optarg 1, optarg 8   # 错误。命令调用的参数太多
  let x = optarg(1, optarg 8)  # 传统过程调用2个参数
  let y = 1.optarg optarg 8    # 与上面相同, 没有括号
  assert x == y
  ```

命令调用语法也不能将复杂表达式作为参数。例如: ( `anonymous procs <#procedures-anonymous-procs>`_ "匿名过程"), `if` , `case` 或 `try` 。没有参数的函数调用仍需要()来区分调用和函数本身作为第一类值。


闭包
--------

过程可以出现在模块的顶层，也可以出现在其他作用域中，在这种情况下，它们称为嵌套过程。嵌套的过程可以从其封闭的作用域访问局部变量，这就变成了一个闭包。任何捕获的变量都存储在闭包(它的环境)的隐藏附加参数中，并且它们通过闭包及其封闭作用域的引用来访问(即, 对它们进行的任何修改在两个地方都是可见的)。如果编译器确定这是安全的，则可以在堆上或堆栈上分配闭包环境。

### 在循环中创建闭包

由于闭包通过引用捕获局部变量，所以在循环体中通常不需要这种行为。有关如何更改此行为的详细信息,
请参阅 `closureScope <system.html#closureScope.t,untyped>`_ 和 `capture <sugar.html#capture.m,varargs[typed],untyped>`_ 。

匿名过程
----------------

未命名过程可以用作lambda表达式传递给其他过程:

  ```nim
  var cities = @["Frankfurt", "Tokyo", "New York", "Kyiv"]

  cities.sort(proc (x, y: string): int =
    cmp(x.len, y.len))
  ```


作为表达式的过程既可以作为嵌套的过程出现，也可以出现在顶级可执行代码中。 `sugar <sugar.html>`_ 模块包含 `=>` 宏，该宏为类似于lambdas的匿名过程提供了更简洁的语法，就像在JavaScript、c#等语言中一样。

Do 标记
--------------

作为一种特殊的方便表示法， `do` 关键字可以用来将匿名过程传递给过程:

  ```nim
  var cities = @["Frankfurt", "Tokyo", "New York", "Kyiv"]

  sort(cities) do (x, y: string) -> int:
    cmp(x.len, y.len)

  # 使用方法加命令语法减少括号:
  cities = cities.map do (x: string) -> string:
    "City of " & x
  ```

`do` 写在包含常规程序参数的括号之后。由 `do` 块表示的proc表达式作为最后一个参数附加到例程调用。 在使用命令语法的调用中, `do` 块将绑定到紧接在前面的表达式，而不是命令调用。

带参数列表或pragma列表的 `do` 对应于匿名的 `proc` , 但是不带参数或程序中的 `do` 被视为正常的语句列表。 这允许宏接收缩进语句列表作为内联调用的参数， 以及Nim例程语法的直接镜像。

  ```nim
  # 将语句列表传递给内联宏:
  macroResults.add quote do:
    if not `ex`:
      echo `info`, ": Check failed: ", `expString`
  
  # 在宏中处理例程定义:
  rpc(router, "add") do (a, b: int) -> int:
    result = a + b
  ```

函数
--------

The `func` 关键字为 `noSideEffect` 的过程引入了一个快捷方式。

  ```nim
  func binarySearch[T](a: openArray[T]; elem: T): int
  ```

是它的简写:

  ```nim
  proc binarySearch[T](a: openArray[T]; elem: T): int {.noSideEffect.}
  ```



例程
--------

例程是一类符号: `proc`, `func`, `method`, `iterator`, `macro`, `template`, `converter` 。

类型绑定操作符
----------------------------

类型绑定操作符是 `proc` 或 `func` ， 其名称以 `=` 开始， 但不是操作符(即只包含符号，如 `==` )。这些与setter无关(参见 `properties <manual.html#procedures-properties>`_ ), 它们以 `=` 结尾。为类型声明的类型绑定操作符将应用于该类型，无论操作符是否在作用域中(包括是否为私有)。

  ```nim
  # foo.nim:
  var witness* = 0
  type Foo[T] = object
  proc initFoo*(T: typedesc): Foo[T] = discard
  proc `=destroy`[T](x: var Foo[T]) = witness.inc # type bound operator

  # main.nim:
  import foo
  block:
    var a = initFoo(int)
    doAssert witness == 0
  doAssert witness == 1
  block:
    var a = initFoo(int)
    doAssert witness == 1
    `=destroy`(a) # can be called explicitly, even without being in scope
    doAssert witness == 2
  # 在退出范围时仍然会被调用
  doAssert witness == 3
  ```

类型绑定操作符: `=destroy `, `=copy` , `=sink` , `=trace` , `=deepcopy` 。

这些操作可以被 *overridden* , 而不是 *overloaded* 。 这意味着实现会自动提升为结构化类型. 例如，如果类型 `T` 有一个覆盖的赋值操作符 `=` , 这个操作符也用于类型 `seq[T]` 的赋值。

由于这些操作被绑定到一个类型，为了实现的简单性，它们必须绑定到一个名义类型; 这意味着一个被重写的 `deepCopy` 的 `ref T` 是真正绑定到 `T` 而不是 `ref T` 。这也意味着，一个不能覆盖 `deepCopy` 的 `ptr T` 和 `ref T` 同时，相反，一个不同的或对象helper类型必须用于一个指针类型。

有关这些过程的更多细节, 请参见 `Lifetime-tracking hooks <destructors.html#lifetimeminustracking-hooks>`_ 。

Nonoverloadable 内置命令
------------------------------------------------

出于实现简单性的原因, 以下内置procs不能重载(它们需要专门的语义检查)::

  declared, defined, definedInScope, compiles, sizeof,
  is, shallowCopy, getAst, astToStr, spawn, procCall

因此, 它们更像关键字而不是普通标识符，与关键字不同的是, 重定义可能会在 system_ 模块中 `shadow`:idx: 定义。从这个列表中，下面的内容不应该用点符号 `x.f` , 因为 `x` 在传递给 `f` 之前不能进行类型检查::

  declared, defined, definedInScope, compiles, getAst, astToStr


Var 参数
----------------
参数的类型可以使用 var 关键字作为前缀:

  ```nim
  proc divmod(a, b: int; res, remainder: var int) =
    res = a div b
    remainder = a mod b

  var
    x, y: int

  divmod(8, 5, x, y) # modifies x and y
  assert x == 1
  assert y == 3
  ```

在示例中,  `res` 和 `remainder` 是 `var parameters` 。可以通过过程修改Var参数，并且调用者可以看到更改。传递给var参数的参数必须是左值。Var参数实现为隐藏指针。上面的例子相当于:

  ```nim
  proc divmod(a, b: int; res, remainder: ptr int) =
    res[] = a div b
    remainder[] = a mod b

  var
    x, y: int
  divmod(8, 5, addr(x), addr(y))
  assert x == 1
  assert y == 3
  ```

在示例中，var形参或指针用于提供两个返回值。这可以通过返回一个元组以一种更简洁的方式来完成:

  ```nim
  proc divmod(a, b: int): tuple[res, remainder: int] =
    (a div b, a mod b)

  var t = divmod(8, 5)

  assert t.res == 1
  assert t.remainder == 3
  ```

可以使用 `tuple unpacking` 来访问元组的字段

  ```nim
  var (x, y) = divmod(8, 5) # tuple unpacking
  assert x == 1
  assert y == 3
  ```


**注意**: `var` 参数对于有效的参数传递永远不是必需的。由于无法修改非var参数，因此如果编译器认为可以加快执行速度，则编译器始终可以通过引用自由传递参数。


Var 返回类型
------------------------

过程，转换器或者迭代器可能会返回 `var` 类型，它意味着返回值是一个左值并且可以被调用者修改:

  ```nim
  var g = 0

  proc writeAccessToG(): var int =
    result = g

  writeAccessToG() = 6
  assert g == 6
  ```

如果隐式创建的指针指向的内存地址有被回收的可能，则会导致静态错误:

  ```nim
  proc writeAccessToG(): var int =
    var g = 0
    result = g # Error!
  ```

对于迭代器来说，当元组作为返回值时，元组的元素也可以是 `var` 类型:

  ```nim
  iterator mpairs(a: var seq[string]): tuple[key: int, val: var string] =
    for i in 0..a.high:
      yield (i, a[i])
  ```

在标准库中，所有返回 `var` 类型的例程，都遵循以 `m` 为前缀的命名规范。


.. include:: manual/var_t_return.md

### 将来的改进方向

未来的Nim在借用规则上将会更加准确，比如下面的语句:

  ```nim
  proc foo(other: Y; container: var X): var T from container
  ```

`var T from contaner` 显式指定了返回值的地址必须源自第二个参数(本例中称为 'container' )。
`var T from p` 语句指定了类型 `varTy[T, 2]` ，它与 `varTy[T, 1]` 类型不兼容。


具名返回值优化 (NRVO)
------------------------------------------

**注意**: 本节文档仅描述当前版本的代码实现。这部分语言规范将会有变动。
详情请查看链接 https://github.com/nim-lang/RFCs/issues/230 。

返回值以例程的特殊变量 `result` :idx: 出现。这便为实现类似C++的"具名返回值优化" (`NRVO`:idx:) 机制创造了条件。
NRVO 指的是对 `p` 内部 `result` 的操作会直接影响 `let/var dest = p(args)` (`dest` 的定义) 与 `dest = p(args)` (`dest` 的赋值) 中的目标 `dest` 。
这是通过将 `dest = p(args)` 重写为 `p'(args, dest)` 来实现的，其中 `p'` 是 `p` 的变体，它返回 `void` 并且接收一个 `result` 的可变参数。

不太正式的示例: 

  ```nim
  proc p(): BigT = ...

  var x = p()
  x = p()

  # 上面这段代码大体上会被翻译为如下代码

  proc p(result: var BigT) = ...

  var x; p(x)
  p(x)
  ```


让 `T` 作为 `p` 的返回值。
当 `sizeof(T) >= N` ( `N` 的值依赖于具体实现) 时，NRVO 会将返回值申请为 `T` 。
换句话说，它会将返回值申请为 "较大" 的结构体。

若 `p` 会抛出异常，NRVO仍会应用。这种情况下，不同的行为可能会导致很大的差别。

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


然而，在这种情况下，当前版本的实现会提出警告。
处理这种警告有多种方法: 

1. 通过 `{.push warning[ObservableStores]: off.}` ... `{.pop.}` 禁用警告。
   则开发者需要确保 `p` 仅在任何 `result` 的操作之前抛出异常。

2. 开发者可以使用一个临时的帮助变量，比如在 `x = p(8)` 内部使用 `let tmp = p(8); x = tmp` 。


重载下标运算符
----------------------------

数组/可变参数/序列的 `[]` 下标运算符可以被重载。


方法
========

过程总是使用静态方法匹配。方法使用动态方法匹配。用于动态匹配的对象应该是引用类型。

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

在这个例子中，构造器 `newLit` 和 `newPlus` 都是过程，因为它们都使用静态方法匹配，但是 `eval` 是一个方法因为它需要动态方法匹配。

从这个例子可以看出，基方法必须使用 `base`:idx: 编译指示修饰。对于开发者来说，`base` 编译指示也是一个提示，它提示 `m` 是任何调用结果的推断基础。


**注意**: 目前还不支持方法的编译期执行。

**注意**: 从Nim 0.20开始，泛型方法已被弃用。

多版本方法
----------------------------------------

**Note** 从Nim 0.20 开始，要启用多版本方法，开发者必须在编译时显式添加 `--multimethods:on`:option: 参数。

在多版本方法中，所有对象类型的参数都会用于方法匹配: 

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

通过 proCall 防止动态方法解析
----------------------------------------------------------

通过调用内置的 `system.procCall`:idx: 可以防止动态方法解析。
某种程度上它与传统面向对象语言提供的 `super`:idx: 关键字类似。

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


迭代器与 for 循环语句
==========================================

`for`:idx 语句是一种迭代容器中元素的抽象机制。它依赖于迭代器 `iterator`:idx: 来实现。与 `while` 语句类似，`for` 语句打开了一个 `implicit block`:idx: "隐式块"，这样可以与 `break` 语句搭配。

`for` 循环声明了迭代器变量 - 它们的生命周期持续到循环体的结束。迭代器的类型是由迭代器的返回值类型推断。

迭代器与过程类似，除了迭代器只在 `for` 循环的上下文中调用。迭代器提供了一种特殊的使用抽象类型的迭代方式。
在 `for` 循环的执行过程中， `yield` 语句对迭代器的调用起到关键性的作用。
当程序执行到 `yield` 语句时，数据会与 `for` 循环的当前变量绑定但循环体继续执行。迭代器的局部变量和执行语句会在循环之间自动保存。
实例如下:

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

编译器会生成如下代码，就像是开发者写的代码一样: 

  ```nim
  var i = 0
  while i < len(a):
    var ch = a[i]
    echo ch
    inc(i)
  ```

如果迭代器遍历一个元组，则元组的元素便是迭代器的变量。
第 i 次迭代的变量类型是元组第 i 个元素的类型。换句话说，循环上下文支持隐式元组拆包。

隐式 items/pairs 调用
------------------------------------------

如果循环表达式 `e` 不显式指定使用迭代器并且循环只迭代一个变量，则循环表达式会被重写为 `items(e)` ；
即 `items` 迭代器会被隐式调用: 

  ```nim
  for x in [1,2,3]: echo x
  ```

如果循环恰迭代两个变量，则 `pairs` 迭代器会被隐式调用。

`items`/`pairs` 标识符的符号查找在编译器重写之后执行，所以 `items`/`pairs` 的重载可以生效。


第一类迭代器
------------------------

Nim 中有两种迭代器: *inline* (内联)和 *closure* (闭包)迭代器。
`inline iterator`:idx: 内联迭代器指总是被编译器内联优化的迭代器，
这样在运行时解释抽象的同时不需要付出额外的代价(零成本抽象)，但可能会导致代码体积大大增加。

请警惕:  在使用内联迭代器时，循环体会被内联进循环中所有的 `yield` 语句里，所以在使用内联迭代器时，开发者应该尽量只使用一个 yield 语句以避免代码体积膨胀。

内联迭代器是二等公民; 它们只能作为参数传递给其他内联代码工具，如模板、宏和其他内联迭代器。

相反， `closure iterator`:idx: 闭包迭代器则可以更自由传递:

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

闭包迭代器和内联迭代器都有一些限制: 

1. 目前，闭包迭代器不能在编译期执行。
2. 闭包迭代器允许使用 `return` 语句并结束循环，但内联迭代器不行(这并不常用与内联迭代器)。
3. 内联迭代器不能用于递归。
4. 内联迭代器与闭包迭代器都没有特殊的 `result` 变量。
5. JS 后端不支持闭包迭代器。

如果不使用 `{.closure.}` 或 `{.inline.}` 显式标记迭代器，则默认为内联迭代器。但是将来的版本可能会改动。 

`iterator` 类型通常约定隐式使用 `closure` 闭包迭代器; 下面的例子展示了如何实现一个 `collaborative tasking`:idx: "协作任务"系统: 

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

内置的 `system.finished` 可以用来推断迭代器是否已经完成了它的操作; 如果迭代器已经完成了工作，再调用 `system.finished` 也不会抛出异常。

请注意 `system.finished` 容易引发错误，因为它只在迭代器最后一次循环完成后的下一次迭代才会返回 `true` :

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

想得到正确的结果，应该想下面的代码一样调用迭代器:

  ```nim
  var c = mycount # 初始化迭代器
  while true:
    let value = c(1, 3)
    if finished(c): break # 丢弃返回值!
    echo value
  ```

您可以这样认为迭代器实际上返回键值对 `(value, done)` ，并且 `finished` 访问了隐藏的 `done` 字段。


闭包迭代器是 *可恢复函数* ，因此每次调用必须提供参数。可以给迭代器套一层"工厂"过程，通过捕获外部"工厂"过程的参数来绕过这个限制:

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

这个过程可以变成内联迭代器，用于for循环的宏:

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

因为调用闭包迭代器需要所有后端函数调用的参与，所以代价比调用内联迭代器更高。宏装饰器在调用处的包装是有用的提醒。

作为一个普通的过程，工厂过程 `proc` 可以递归。上文中的宏可以用更像迭代器递归的语法重写。比如:

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


关于如果给模板和宏传递迭代器，可以看这一节 `iterable <#overloading-resolution-iterable>`_ 。

转换器
============

转换器就像普通的过程，只不过它增强了"隐式可转换"类型关系 (参见`Convertible relation <#type-relations-convertible-relation>`_ ):

  ```nim
  # 不推荐的代码风格:不推荐用 C 语言的风格编写 Nim 代码。
  converter toBool(x: int): bool = x != 0

  if 4:
    echo "compiles"
  ```


开发者可以显式调用转换器以提高代码的可读性。
请注意隐式转换器不支持自动的链式调用: 如果存在 A 类型到 B 类型的转换器和 B 类型到 C 类型的转换器，Nim 不提供从 A 转换为 C 类型的隐式转换。


Type 段
==============

示例:

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

类型段由 `type` 关键字开启。它包含多个类型定义。类型定义给类型绑定一个名称。类型定义可以是递归的甚至是相互递归的。相互递归类型只能在单层 `type` 段中出现。
像 `objects` 或者 `enums` 这样的标称类型仅能在 `type` 段中定义。



异常处理
================

Try 语句
----------------

示例:

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


除非有异常 `e` 抛出，否则 `try` 之后的语句顺序执行。如果 `e` 的异常类型能够匹配 `except` 子句列出的异常类型，则执行对应的代码。 `except` 子句之后的代码被称为 `exception handlers`:idx: "异常处理"。

如果程序抛出了未列出的异常，则将执行空的 `except`:idx: 子句。就像 `if` 语句的 `else` 子句。

`finally`:idx 子句总会在异常处理程序之后执行，如果存在 `finally` 子句的话。

异常在异常处理器中 *处理* 。然而异常处理器也可能抛出异常。如果没有处理这样的异常，则它会通过调用栈传递出去。所以当这种情况发生时，剩下的代码将不会被执行( `finally` 子句的代码依旧会执行)。


Try 表达式
--------------------

try 也可以用作表达式; `try` 部分的类型需要兼容 `except` 部分的类型，但是 `finally` 部分只能是 `void` : 

  ```nim
  from std/strutils import parseInt

  let x = try: parseInt("133a")
          except: -1
          finally: echo "hi"
  ```


为了防止令人迷惑的代码，有一个解析限制: 如果 `try` 语句在 `(` 之后，则表达式必须写成一行:

  ```nim
  let x = (try: parseInt("133a") except: -1)
  ```


Except 子句
----------------------

在 `except` 子句中，可能需要使用下面的语法访问当前抛出的异常: 

  ```nim
  try:
    # ...
  except IOError as e:
    # Now use "e"
    echo "I/O error: " & e.msg
  ```

或者，使用 `getCurrentException` 也可以获取当前抛出的异常。

  ```nim
  try:
    # ...
  except IOError:
    let e = getCurrentException()
    # Now use "e"
  ```

注意， `getCurrentException` 总是返回 `ref Exception` 类型。如果需要使用具体类型(比如上面例子中的 `IOError`)的变量，则需要显式转换: 

  ```nim
  try:
    # ...
  except IOError:
    let e = (ref IOError)(getCurrentException())
    # 现在 "e" 是具体的异常类型了
  ```

但是，这样的情况很少发生。常见的使用场景是从 `e` 中提取异常信息，对于这种场景，使用 `getCurrentExceptionMsg` 已经足够了:

  ```nim
  try:
    # ...
  except:
    echo getCurrentExceptionMsg()
  ```

自定义异常
--------------------

您可以创建自定义异常。自定义异常就是自定义类型: 

  ```nim
  type
    LoadError* = object of Exception
  ```

自定义异常的名称建议以 `Error` 结尾。

自定义异常可以像其他异常一样抛出，例如: 

  ```nim
  raise newException(LoadError, "Failed to load data")
  ```

Defer 语句
--------------------

使用 `defer` 语句代替 `try finally` 语句可以避免代码的复杂嵌套，在下面的例子中，您也可以看到它提供更灵活的作用域。

当前代码块中， `defer` 之后的任何语句都将考虑包裹在隐式 try 块中: 

  ```nim  test = "nim c $1"
  proc main =
    var f = open("numbers.txt", fmWrite)
    defer: close(f)
    f.write "abc"
    f.write "def"
  ```

会被编译器重写为: 

  ```nim  test = "nim c $1"
  proc main =
    var f = open("numbers.txt")
    try:
      f.write "abc"
      f.write "def"
    finally:
      close(f)
  ```

当 `defer` 位于最外层的模板/宏的作用域中时，它的作用域将延伸到模板被调用的代码块中: 

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

Nim 不支持最顶层(没有任何缩进的)的 `defer` 语句，因为无法判断它用于哪一段代码。


Raise 语句
--------------------

示例:

  ```nim
  raise newException(IOError, "IO failed")
  ```

除了数组索引，内存分配等内置操作之外， `raise` 语句是抛出异常的唯一方法。

.. XXX document this better!

如果没有给出异常的名称，则当前异常会 `re-raised`:idx: (重新抛出)。如果当前没有异常可以重新抛出，则会抛出 `ReraiseDefect`:idx: 异常。它遵循 `raise` 语句 *总是* 抛出异常的规则。


异常的层级
--------------------

`system <system.html>`_ 模块定义了异常树。所有异常都继承自 `system.Exception` 。
表示编码错误的异常继承自 `system.Defect` (它是 `Exception` 的子类)，严格来说，这类异常无法捕获，因为它也可以映射成一个结束整个进程的操作。
如果 panic 被转换为异常，则这类异常继承自 `Defect` 。

表示可捕获的所有运行时错误的异常继承自 `system.CatchableError`(它是 `Exception` 的子类)。


导入的异常
--------------------

导入的 C++ 异常也可以抛出和捕获。使用 `importcpp` 导入的类型可以抛出和捕获。异常通过值抛出，通过引用捕获。
例子如下: 

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

**注意** `getCurrentException()` 和 `getCurrentExceptionMsg()` 不能从C++导入。开发者需要使用 `except ImportedException as x:` 语句并且需要依据对象 `x` 的功能获取异常的具体信息。


Effect 系统
======================

**注意** : Nim 1.6 版本编译器改动了 effect 跟踪的规则。本小节的中的新规则需要通过添加 `--experimental:strictEffects` 选项才能生效。


异常跟踪
----------------

Nim 支持异常跟踪。 `raises`:idx: 编译指示可以显式定义哪些异常可以由 过程/迭代器/方法/转换器 抛出。编译期会验证如下代码: 

  ```nim  test = "nim c $1"
  proc p(what: bool) {.raises: [IOError, OSError].} =
    if what: raise newException(IOError, "IO")
    else: raise newException(OSError, "OS")
  ```

空的 `raises` 列表(`raises: []`)意味着不允许抛出异常: 

  ```nim
  proc p(): bool {.raises: [].} =
    try:
      unsafeCall()
      result = true
    except:
      result = false
  ```


`raises` 列表也可以附加到过程类型上。这会影响类型兼容性: 

  ```nim  test = "nim c $1"  status = 1
  type
    Callback = proc (s: string) {.raises: [IOError].}
  var
    c: Callback

  proc p(x: string) =
    raise newException(OSError, "OS")

  c = p # type error
  ```


对于例程 `p` 来说，编译器使用推断规则来判断可能引发的异常; 算法在 `p` 的调用图上运行: 

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


继承自 `system.Defect` 的异常不会根据 `.raises: []` 异常跟踪机制跟踪。这跟内置的运算符保持一致。
下面的代码是合理的: 

  ```nim
  proc mydiv(a, b): int {.raises: [].} =
    a div b # 会抛出 DivByZeroDefect 异常
  ```

同理，下面的代码 也是合理的: 

  ```nim
  proc mydiv(a, b): int {.raises: [].} =
    if b == 0: raise newException(DivByZeroDefect, "division by zero")
    else: result = a div b
  ```


因为 `DivByZeroDefect` 继承自 `Defect` 并且已添加 `--panics:on`:option: 选项，所以异常变成无法修复还原的错误。(自从 Nim 1.4 开始支持) 


EffectsOf 编译指示
------------------------------------

异常追踪(之前的小节)的第一条与第二条异常推断规则确保以下代码正常工作: 

  ```nim
  proc weDontRaiseButMaybeTheCallback(callback: proc()) {.raises: [], effectsOf: callback.} =
    callback()

  proc doRaise() {.raises: [IOError].} =
    raise newException(IOError, "IO")

  proc use() {.raises: [].} =
    # 不会编译通过! 会抛出 IOError 错误!
    weDontRaiseButMaybeTheCallback(doRaise)
  ```

从这个例子中可以看出， `proc (...)` 类型的参数可以标记为 `.effectsOf` 。这样的参数允许 effect 多态: 过程 `weDontRaiseButMaybeTheCallback` 可以抛出 `callback` 抛出的异常。

所以在很多场景中，callback 并不会导致编译器在 effect 分析中过于保守: 

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



Tag 跟踪
----------------

异常追踪是 Nim `effect system`:idx: "作用系统"的一部分。抛出异常是一个 *effect* 。当然可以定义其他 effect 。用户定义的 effect 是对例程打上一个 *tag* 并检查这个 tag : 

  ```nim  test = "nim c --warningAsError:Effect:on $1"  status = 1
  type IO = object ## 输入/输出 effect
  proc readLine(): string {.tags: [IO].} = discard

  proc no_effects_please() {.tags: [].} =
    # 编译器会阻止下面代码通过编译:
    let x = readLine()
  ```

`tag` 必须是类型名。
就像 `raises` 列表， `tags` 列表也可以附加到过程类型上。这会影响类型的兼容性。

tag 跟踪的推断规则与异常追踪的推断规则类型。

也有几种方式可以禁用某些effect"作用":

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

`forbids` 编译指示定义了一个非法 effect 的列表。如果任何语句调用这些 effect ，则编译会失败。
带有非法 effect 的过程类型是原(没有非法 effect )过程类型的子类型: 

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

`ProcType2` 是 `ProcType1` 的子类。跟 tag 不同，父级的上下文(调用其他有禁用 effect 函数的函数)并不继承 effect 的禁用列表。


副作用
------------

`noSideEffect` 编译指示用于标记过程和迭代器，它只能通过参数产生副作用。这意味着这个过程或迭代器只能改变形参可访问的地址。假如该过程或迭代器参数中没有 `var`、`ref`、 `ptr`、 `cstring`、 `proc` 中的任意类型，则其无法修改外部地址。

换句话说，如果一个例程既不接受本地线程变量或全局变量、也不调用其他带副作用的例程，则该例程是无副作用的。

如果给予一个过程或迭代器无副作用标记，而编译器无法验证，将引发静态错误。

作为一个特殊的语义规则，内置的 `debugEcho <system.html#debugEcho,varargs[typed,]>`_ 被视为无副作用的。因此，其可以用于被标记为 `noSideEffect` 例程的调试。

`func` 是无副作用过程的语法糖:

  ```nim
  func `+` (x, y: int): int
  ```


`cast` 编译指示可用于强制转换编译器的 `{.noSideEffect.}` 无副作用语义。

  ```nim
  func f() =
    {.cast(noSideEffect).}:
      echo "test"
  ```

**副作用通常是被推断的，其类似于异常跟踪的推断。**


GC安全的作用
------------------------

当不能直接或间接地通过调用GC不安全的过程来访问任何包含GC内存的全局变量( `string` 、 `seq` 、 `ref` 或一个闭包)时，我们调用过程 `p` 则是 `GC safe`:idx: "GC安全" 的。

**是否GC安全通常是被推断的，其类似于异常跟踪的推断。**

`gcsafe`:idx: 注解可用于标记一个过程为GC安全的，否则将由编译器进行推断。值得注意的是， `noSideEffect` 也就意味着 `gcsafe` 。

从C语言库导入的例程将总是被看作 `gcsafe` 的。

 `{.cast(gcsafe).}` 编译指示块可用于覆写编译器的GC安全语义。

  ```nim
  var
    someGlobal: string = "some string here"
    perThread {.threadvar.}: string

  proc setPerThread() =
    {.cast(gcsafe).}:
      deepCopy(perThread, someGlobal)
  ```


另请参阅:

- `Shared heap memory management <mm.html>`_.



作用编译标志
------------------------

`effects` 编译指示用于协助程序员进行作用分析。这条语句可以使编译器输出所有被推断出的作用到 `effects` 的位置上:

  ```nim
  proc p(what: bool) =
    if what:
      raise newException(IOError, "IO")
      {.effects.}
    else:
      raise newException(OSError, "OS")
  ```

编译器会产生一条提示消息，提示 `IOError` 可以被引发。 `OSError` 未被列出，因为它不能在 `effects` 编译指示所在的分支中引发。


泛型
========

泛型是Nim使用 `type parameters`:idx: "类型参数化" 对过程、迭代器或类型进行参数化的方法。根据上下文的不同，方括号可以引入类型参数，或用于实例化泛型过程、迭代器或类型。

以下例子展示了如何构建一个泛型二叉树:

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

这里的 `T` 被称为 `generic type parameter`:idx: "泛型类型参数"，或者 `type variable`:idx: "可变类型"。

`is` 操作符
----------------------

`is` 操作符在语义分析期间评估检查类型的等价性。因此其在对类型有特定要求的泛型代码中有重要作用。

  ```nim
  type
    Table[Key, Value] = object
      keys: seq[Key]
      values: seq[Value]
      when not (Key is string): # 优化空值字符串
        deletedKeys: seq[bool]
  ```


Type 类
--------------

Type类是一种特殊的伪类型，可在重载解析或 `is` 操作符处针对性地匹配上下文中的类型。Nim支持以下内置类型类:

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

此外，任何泛型类型都会自动创建一个同名的type类，以此匹配该泛型类的实例。

Type类可以通过标准的布尔操作符组合为更复杂的Type类。

  ```nim
  # 创建一个可以匹配所有tuple类和object类的type类
  type RecordType = tuple or object

  proc printFields[T: RecordType](rec: T) =
    for key, value in fieldPairs(rec):
      echo key, " = ", value
  ```

泛型参数列表中的参数类型约束可以通过 `,` 进行分组，并以 `;` 结束一个分组，就像宏和模板中的参数列表那样:

  ```nim
  proc fn1[T; U, V: SomeFloat]() = discard    # T 是不受类型约束的
  template fn2(t; u, v: SomeFloat) = discard  # t 是不受类型约束的
  ```

虽然type类在语法上接近于类ML语言中的抽象数据类型和代数数据类型，但应该知道type类是实例化时强制执行的静态约束。type类本身并非真的类，而只是提供了一个泛型检查系统以将其最终解释为确定的单一类型。type类不允许运行时的动态类型分配，这与object、变量和方法不同。

例如，以下代码将无法通过编译:

  ```nim
  type TypeClass = int | string
  var foo: TypeClass = 2 # foo的类型在这里被解释为int类型
  foo = "this will fail" # 这里发生错误，因为foo已经被解释为int类型
  ```

Nim允许将type类和常规类用作泛型类型参数的 `type constraints`:idx: "类型约束":

  ```nim
  proc onlyIntOrString[T: int|string](x, y: T) = discard

  onlyIntOrString(450, 616) # 有效的
  onlyIntOrString(5.0, 0.0) # 类型不匹配
  onlyIntOrString("xy", 50) # 无效的，因为同一个T不能被同时指定为两种不同类型
  ```


隐式泛型
----------------

一个type类可以直接作为参数的类型使用。

  ```nim
  # 创建一个可以同时匹配tuple和object类的type类
  type RecordType = tuple or object

  proc printFields(rec: RecordType) =
    for key, value in fieldPairs(rec):
      echo key, " = ", value
  ```


像这样以type类作为参数类型的过程被称为 `implicitly generic`:idx: "隐式泛型"。隐式泛型每使用一组特定参数类型组合，都将在程序中创建一个实例。

通常，重载解析期间，每一个被命名的type类都将被绑定到一个确切的混合类。我们称这些type类 `bind once`:idx: "单一绑定"。以下是从系统模块里直接拿来的例子:

  ```nim
  proc `==`*(x, y: tuple): bool =
    ## 需要 `x` 和 `y` 都是相同的元组类型
    ## 针对元组的泛型操作符 `==` 在`x` 和 `y`的组合中是左结合的
    result = true
    for a, b in fields(x, y):
      if a != b: result = false
  ```

或者，当 `distinct` 类修饰词用于type类，将允许每一参数绑定到匹配type类中的不同类型，这些type类被称为 `bind many`:idx: "多绑定"。

以隐式泛型的方式书写过程时，需要指定匹配的类型参数。这样，才能用 `.` 语法便捷的使用它们所包含的内容。

  ```nim
  type Matrix[T, Rows, Columns] = object
    ...

  proc `[]`(m: Matrix, row, col: int): Matrix.T =
    m.data[col * high(Matrix.Columns) + row]
  ```


这里有说明隐式泛型的更多例子:

  ```nim
  proc p(t: Table; k: Table.Key): Table.Value

  # 等同于以下写法:

  proc p[Key, Value](t: Table[Key, Value]; k: Key): Value
  ```


  ```nim
  proc p(a: Table, b: Table)

  # 等同于以下写法:

  proc p[Key, Value](a, b: Table[Key, Value])
  ```


  ```nim
  proc p(a: Table, b: distinct Table)

  # 等同于以下写法:

  proc p[Key, Value, KeyB, ValueB](a: Table[Key, Value], b: Table[KeyB, ValueB])
  ```


`typedesc` 作为参数类型使用时，总是产生一个隐式泛型，`typedesc` 有其独有的设置规则。

  ```nim
  proc p(a: typedesc)

  # 等同于以下写法:

  proc p[T](a: typedesc[T])
  ```


`typedesc` 是一个多绑定type类型:

  ```nim
  proc p(a, b: typedesc)

  # 等同于以下写法:

  proc p[T, T2](a: typedesc[T], b: typedesc[T2])
  ```


一个具 `typedesc` 类型的参数自身也是可以作为一个类型使用。如果将其作为类型使用，其将是底层类型。(换言之， `typedesc` 类型参数最终绑定的类型将被剥离出来使用):

  ```nim
  proc p(a: typedesc; b: a) = discard

  # 等同于以下代码:
  proc p[T](a: typedesc[T]; b: T) = discard

  # 这是有效的调用:
  p(int, 4)
  # 这里 'a' 需要的参数是一个类型, 而 'b' 需要的则是一个该类型的值。
  ```


泛型推断局限
------------------------

类型 `var T` 和 `typedesc[T]` 无法在泛型实例中被推断，以下语句是不允许的:

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



泛型中的符号查找
--------------------------------

### 开放和封闭符号

泛型中的符号绑定规则略显微妙: 其存在开放和封闭两种状态的符号。一个封闭的符号在实例的上下文中无法被重新绑定，而一个开放的符号可以。默认情况下，重载符号都是开放的，而所有其他符号都是封闭的。

开放的符号可以在在两种不同的上下文中被找到: 一是其定义所处的上下文，二是实例中的上下文:

  ```nim  test = "nim c $1"
  type
    Index = distinct int

  proc `==` (a, b: Index): bool {.borrow.}

  var a = (0, 0.Index)
  var b = (0, 0.Index)

  echo a == b # works!
  ```

在这个例子中，针对元组泛型符号 `==` (定义于系统模块)，使用 `==` 操作符进行元组的组合。然而，针对 `Index` 类型的 `==` 符号定义在其针对元组的定义之后；所以，这个例子在被编译时，实例中当前符号的定义也会进入其中。

Mixin 语句
------------------

一个符号可以通过 `mixin`:idx: "混合" 关键字声明为开放:

  ```nim  test = "nim c $1"
  proc create*[T](): ref T =
    # 这里没有 'init' 的重载，我们需要显式的将其声明为一个开放的符号:
    mixin init
    new result
    init result
  ```

`mixin` 语句只有在模板和泛型中才有意义。


绑定语句
----------------

 `bind` 语句相对于 `mixin` 语句。可用于显式地声明标识符需要之前绑定(标识符应在模板或泛型的作用域中被定义)。

  ```nim
  # 模块 A
  var
    lastId = 0

  template genId* : untyped =
    bind lastId
    inc(lastId)
    lastId
  ```

  ```nim
  # 模块 B
  import A

  echo genId()
  ```

但是 `bind` 很少被用到，因为符号绑定的定义作用域是默认的。

`bind` 语句只在模板和泛型中有意义。


委托绑定语句
------------------------

下面的示例概述了当泛型的实例跨越多个不同模块时可能出现的问题:

  ```nim
  # 模块 A
  proc genericA* [T](x: T) =
    mixin init
    init(x)
  ```


  ```nim
  import C

  # 模块 B
  proc genericB*[T](x: T) =
	# 没有 `bind init` 语句，当 `genericB` 实例化时，来自C模块的init过程是不可用的:
    bind init
    genericA(x)
  ```

  ```nim
  # 模块 C
  type O = object
  proc init* (x: var O) = discard
  ```

  ```nim
  # 主模块
  import B, C

  genericB O()
  ```

在模块 B 作用域中有一个来自模块 C 的 `init` 过程，当实例化 `genericB` 从而使 `genericA` 实例化时， `init` 过程未被考虑在内。解决方案是 `forward`:idx: "传递"，将这些符号通过 `bind` 语句引入 `genericB` 中。


模板
========

模板就是简单形式的宏: 它是简单的替换机制，在Nim的抽象语法树上运行。它运作在编译器的语义分析中。

调用模板的语法和调用过程的语法是相同的。

示例:

  ```nim
  template `!=` (a, b: untyped): untyped =
    # 此定义存在于系统模块中
    not (a == b)

  assert(5 != 6) # 编译器将其重写为: assert(not (5 == 6))
  ```

 `!=`, `>`, `>=`, `in`, `notin`, `isnot` 等操作符实际上都是模板:

| `a > b` 从 `b < a` 变换而来.
| `a in b` 从 `contains(b, a)` 变换而来.
| `notin` 和 `isnot` 的实现显而易见。

模板中的类型可以使用 `untyped` 、 `typed` 及 `typedesc` 三个符号。这些都是 "元类型" ，它们仅用于特定上下文中。常规类型也可被同样使用；这意味着 `typed` 的表达式可推断。


Typed 参数和 untyped 参数的比较
--------------------------------------------------------------

一个 `untyped` 参数意味着符号的查找和类型的解析在表达式传递给模板前不执行。这意味着像以下例子这样不声明标识符的代码可以通过:

  ```nim  test = "nim c $1"
  template declareInt(x: untyped) =
    var x: int

  declareInt(x) # 有效的
  x = 3
  ```


  ```nim  test = "nim c $1"  status = 1
  template declareInt(x: typed) =
    var x: int

  declareInt(x) # 不正确，因为此处x的类型没有被声明，其类型未确定
  ```

如果一个模板的每个参数都是 `untyped` 的，则其被称为 `immediate`:idx: "即时"模板。由于历史原因，模板可以用 `immediate` 编译指示显式的标记，这些模板将不参与重载解析，其参数中的类型将被编译器忽略。显式的声明即时模板现在已经被弃用。

**注意**: 由于历史原因， `stmt` 是 `typed` 的别名， `expr` 是 `untyped` 的别名，但这两者都被移除了。


传递代码块到模板
--------------------------------

通过特殊的 `:` 语法，可以将一个语句块传递给模板的最后一个参数:

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

在这个例子中，这两行 `writeLine` 语句被绑定到了模板的 `actions` 参数。


通常，为了传递一个代码块到模板，接受代码块的参数需要被声明为 `untyped` 类型。因为这样，符号查找会被推迟到模板实例化期间进行:

  ```nim  test = "nim c $1"  status = 1
  template t(body: typed) =
    proc p = echo "hey"
    block:
      body

  t:
    p()  # 失败，因为p'是一个未被声明的标识符
  ```

以上代码错误信息为 `p` 未被声明。其原因是 `p()` 语句体在传递到 `body` 参数前执行类型检查和符号查找。通过修改模板参数类型为 `untyped` 使得传递语句体时无需类型检查，同样的代码便可以通过:

  ```nim  test = "nim c $1"
  template t(body: untyped) =
    proc p = echo "hey"
    block:
      body

  t:
    p()  # 编译通过
  ```


可变参数的untyped
---------------------------------------

除了 `untyped` 元类型阻止类型检查外， `varargs[untyped]` 中的参数数量也不确定。

  ```nim  test = "nim c $1"
  template hideIdentifiers(x: varargs[untyped]) = discard

  hideIdentifiers(undeclared1, undeclared2)
  ```

然而，因为模板不能迭代可变参数，这个功能通常在宏中更有用。


模板中的符号绑定
--------------------------------

模板就是 `hygienic`:idx: "洁净"宏，因此也会开启新的作用域。大部分符号会在宏定义作用域中绑定:

  ```nim
  # 模块 A
  var
    lastId = 0

  template genId* : untyped =
    inc(lastId)
    lastId
  ```

  ```nim
  # 模块 B
  import A

  echo genId() # Works as 'lastId' has been bound in 'genId's defining scope
  ```

像在泛型中一样，模板中的符号绑定可以被 `mixin` 或 `bind` 语句影响。



标识符构建
--------------------

在模板中，标识符可以通过反引号标注进行构建:

  ```nim  test = "nim c $1"
  template typedef(name: untyped, typ: typedesc) =
    type
      `T name`* {.inject.} = typ
      `P name`* {.inject.} = ref `T name`

  typedef(myint, int)
  var x: PMyInt
  ```

在这个例子中， `name` 参数实例化为 `myint` 类型，所以 \`T name\` 变成了 `Tmyint` 。


模板参数中的查找规则
----------------------------------------

模板中的参数 `p` 总是被替换为 `x.p` 这样的表达式。因此，模板参数可像字段名称一样使用，且一个全局符号会被一个合法的同名参数覆盖:

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

但是全局符号可以通过 `bind` 语句适时捕获:

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


"洁净"模板
------------------------

默认情况下，在模板中声明的 `hygienic`:idx: "洁净"局部标识符，不能在实例化上下文中访问:

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


模板中声明的一个符号是否向实例所处作用域中公开取决于 `inject`:idx: 和 `gensym`:idx: 编译指示。被 `gensym` 编译指示标记的符号不会被公开，而 `inject` 编译指示反之。

`type` , `var`, `let` 和 `const` 等实体符号默认是 `gensym` 的， `proc` , `iterator` , `converter`, `template` , `macro` 等默认是 `inject` 的。
而如果一个实体的名称是由模板参数传递的，其将总被标记为 `inject` 的。

  ```nim
  template withFile(f, fn, mode: untyped, actions: untyped): untyped =
    block:
      var f: File  # 因为 'f' 是一个模板参数，其是被标记为 `inject` 
      ...

  withFile(txt, "ttempl3.txt", fmWrite):
    txt.writeLine("line 1")
    txt.writeLine("line 2")
  ```


 `inject` 和`gensym` 编译指示是两个类注解；它们在模板定义之外没有语义，不能被抽象出来。

  ```nim
  {.pragma myInject: inject.}

  template t() =
    var x {.myInject.}: int # 无法工作
  ```


为了消除模板中的洁净问题，我们可以在模板中使用 `dirty`:idx: "脏位" 指示 。 `inject` 和 `gensym` 在 `dirty` 模板中没有作用。

被标记为 `gensym` 的符号无法作为 `field` 使用在 `x.field` 语义中。也不能用于 `ObjectConstruction(field: value)` 和 `namedParameterCall(field = value)` 语义构造。

其原因如以下代码所示:

  ```nim  test = "nim c $1"
  type
    T = object
      f: int

  template tmp(x: T) =
    let f = 34
    echo x.f, T(f: 4)
  ```


以上代码将按预期执行。

而这意味着被 `gensym` 标记的符号无法应用方法调用语义:

  ```nim  test = "nim c $1"  status = 1
  template tmp(x) =
    type
      T {.gensym.} = int

    echo x.T # 无效的: 应该使用: 'echo T(x)' 。

  tmp(12)
  ```


方法调用语义的局限性
----------------------------------------

在像 `x.f` 这样的表达式中的 `x` 在确定执行前需要进行语义检查(这意味着符号查找和类型检查)，这一过程中其将被写作 `f(x)` 的形式。因此，当 `.` 语义用于调用模板和宏时有一些局限性。

  ```nim  test = "nim c $1"  status = 1
  template declareVar(name: untyped) =
    const name {.inject.} = 45

  # 无法通过编译:
  unknownIdentifier.declareVar
  ```


在方法调用语义中，把模块符号用作完全限定的标识符是行不通的。 `.` 操作符绑定符号的次序禁止这样做。

  ```nim  test = "nim c $1"  status = 1
  import std/sequtils

  var myItems = @[1,3,3,7]
  let N1 = count(myItems, 3) # 可行
  let N2 = sequtils.count(myItems, 3) # 完全被限定, 此处可行
  let N3 = myItems.count(3) # 可行
  let N4 = myItems.sequtils.count(3) # 非法的, `myItems.sequtils` 无法被解析
  ```

这意味着，当由于某种原因，某个过程需要通过模块名称消除歧义时，需要以函数调用语法书写调用。

宏
======

宏是一种在编译时运行的特殊函数。通常，宏的输入是代码传递的抽象语法树(AST)。然后，宏可以对其执行转换，并将转换后的AST的结果返回。这可以被用来添加自定义语言功能，并实现 `domain-specific languages`:idx: "域特定语言"。

宏的语义分析并不完全是从上到下和从左到右的。相反，语义分析至少发生两次:

* 语义分析识别并解析宏调用。
* 编译器执行宏正文(可能会调用其他过程)。
* 将宏调用的AST替换为返回的AST。
* 再次对该区域的代码进行语义分析。
* 如果宏返回的AST包含其他宏调用，则此过程将迭代进行。

虽然宏支持编译时的代码转换，但它们无法更改 Nim 的语法。

**样式说明:** 为了提高代码的可读性，最好使用简洁而富有表现力的编程结构。建议如下:

(1) 首先尽可能使用普通的过程和迭代器。
(2) 其次尽可能使用泛型过程和迭代器。
(3) 再次尽可能使用模板。
(4) 最后才考虑使用宏。

Debug 例子
--------------------

以下例子展现了通过接受可变数量参数的高效的 `debug` 命令:

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

这个宏调用后将展开为以下代码:

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


传递给 `varargs` 参数的参数被包装在数组构造函数表达式中。这就是为什么 `debug` 会迭代所有 `args` 的子级的原因。


bindSym
-------

上面的 `debug` 宏依赖于这样一个事实，即 `write` ， `writeLine` 和 `stdout` 在系统模块中已被声明，而且在实例的上下文中总是可见。有一种方法可以使用绑定标识符(即 `symbols`:idx: )以替换未绑定的标识符。内置的 `bindSym` 可用于此目的。

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

这个宏调用后将展开为以下代码:

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

但是，符号 `write` ， `writeLine` 和 `stdout` 已经绑定，且不会再次查找。如示例所示， `bindSym` 确实可以隐式地处理重载符号。

请注意，传递给 `bindSym` 的符号名称必须是常量。实验功能 `dynamicBindSym` ( `experimental manual <manual_experimental.html#dynamic-arguments-for-bindsym>`_ ) 允许动态计算此值。

语句后的代码块
----------------------------

当以语句形式调用宏时，宏可以接受 `of`，`elif`，`else`，`except`，`finally` 和 `do` 代码块
(包括诸如带有例程参数的 `do` 等其它形式)。

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


For 循环宏
--------------------

当宏只有一个输入参数，而且这个参数的类型是特殊的 `system.ForLoopStmt` 时，
这个宏可以重写整个 `for` 循环:

  ```nim  test = "nim c $1"
  import std/macros

  macro example(loop: ForLoopStmt) =
    result = newTree(nnkForStmt)    # 创建一个新的 For 循环。
    result.add loop[^3]             # 这是 "item" 。
    result.add loop[^2][^1]         # 这是 "[1, 2, 3]" 。
    result.add newCall(bindSym"echo", loop[0])

  for item in example([1, 2, 3]): discard
  ```

展开成:

  ```nim
  for item in items([1, 2, 3]):
    echo item
  ```

再举一个例子:

  ```nim  test = "nim c $1"
  import std/macros

  macro enumerate(x: ForLoopStmt): untyped =
    expectKind x, nnkForStmt
    # 检查是否指定了计数的起始值
    var countStart = if x[^2].len == 2: newLit(0) else: x[^2][1]
    result = newStmtList()
    # 我们把第一个 for 循环变量修改为整数计数器:
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


Case 语句宏
----------------------

名为 `` `case` `` 的宏能够为特定类型实现 `case` 语句。
下面的例子借助元组已有的相等运算符(由 `system.==` 提供)为它们实现了 `case` 语句。

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

重载解析会处理 `case` 宏: `case` 宏的第一个参数的类型用来匹配 `case` 语句选择器表达式的类型。
然后整个 `case` 语句被填入这个参数并对宏求值。

换句话说，这种宏需要转换整个 `case` 语句，但是决定调用哪个宏的仅是语句的选择器表达式。


特殊类型
================

static[T]
---------

如名称所示，静态参数必须是常数表达式:

  ```nim
  proc precompiledRegex(pattern: static string): RegEx =
    var res {.global.} = re(pattern)
    return res

  precompiledRegex("/d+") # 这个调用被替换成一个预编译的、
                          # 存储在全局变量里的正则表达式

  precompiledRegex(paramStr(1)) # 错误，命令行选项不是常数表达式
  ```


为了代码生成，所有的静态参数都被视为泛型参数——每遇到一种新的输入参数(或者参数的组合)，函数就会被编译一次。

静态参数也可以出现在泛型的签名里:

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

请注意，`static T` 只是泛型类 `static[T]` 的语法糖。
省略类型参数 `T` 可以获得所有常数表达式的类型类。用 `static` 把其它类型类实例化能够得到一种更具体的类型类。

把表达式强制转换成对应的 `static` 类型可以强制其像常数表达式一样在编译期就进行求值。

  ```nim
  import std/math

  echo static(fac(5)), " ", static[bool](16.isPowerOfTwo)
  ```

编译器将报告表达式求值失败或可能的类型不匹配错误。

typedesc[T]
-----------

在一些上下文中，Nim 把类型名当作常规的值处理。这些值只存在于编译阶段，由于所有的值都必须有类型，
就用 `typedesc` 来表示它们的这种特殊类型。

`typedesc` 像一种泛型类。比如，符号 `int` 的类型是 `typedesc[int]` 。就像普通泛型类一样，
省略了泛型参数的 `typedesc` 代表所有类型的类型类。作为一种语法糖，`typedesc` 也可用作修饰符。

带有 `typedesc` 参数的函数被认为是隐式泛型的。这些函数针对每种唯一的输入类型组合都会有一个实例。
在函数体内，每个参数的名字都指代所绑定的具体的类型:

  ```nim
  proc new(T: typedesc): ref T =
    echo "allocating ", T.name
    new(result)

  var n = Node.new
  var tree = new(BinaryTree[int])
  ```

当存在多个类型参数时，它们可以自由地绑定到不同的类型。使用显式泛型参数可只允许单次绑定:

  ```nim
  proc acceptOnlyTypePairs[T, U](A, B: typedesc[T]; C, D: typedesc[U])
  ```

一旦绑定，类型参数就可以在函数签名剩余部分里出现:

  ```nim  test = "nim c $1"
  template declareVariableWithType(T: typedesc, value: T) =
    var x: T = value

  declareVariableWithType int, 42
  ```


限制类型参数所能匹配的类型可以进一步影响重载解析。实践中借助模板为类型附加约束就可以实现这个效果。
这里的约束可以是一个具体的类型或者一个类型类。

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
  ```

给宏传入 `typedesc` 与传入其它参数几乎是一样的，区别仅在于宏一般不会被实例化。类型表达式简单地作为 `NimNode` 传给宏，就像其它任何东西一样。

  ```nim
  import std/macros

  macro forwardType(arg: typedesc): typedesc =
    # `arg` 的类型是 `NimNode`
    let tmp: NimNode = arg
    result = tmp

  var tmp: forwardType(int)
  ```

typeof 运算符
--------------------------

**注意**: 由于历史原因 `typeof(x)` 也可写作 `type(x)` ，但是不鼓励这种写法。

取给定的表达式的 `typeof` 值就能得到这个表达式的类型(在其它的很多语言里这被称为 `typeof`:idx: 运算符):

  ```nim
  var x = 0
  var y: typeof(x) # y 的类型是 int
  ```


如果 `typeof` 被用来判断函数(或迭代子、变换器)调用 `c(X)` 的结果的类型(这里，`X` 代表可能为空的参数列表)，
解释代码时，与其它方式相比，优先考虑把 `c` 视作迭代子。通过给 `typeof` 传入第二个参数 `typeOfProc` 可以改变这种行为。

  ```nim  test = "nim c $1"
  iterator split(s: string): string = discard
  proc split(s: string): seq[string] = discard

  # 由于迭代子是优先考虑的解释方式，下面的类型是 `string`:
  assert typeof("a b c".split) is string

  assert typeof("a b c".split, typeOfProc) is seq[string]
  ```



模块
========
依靠模块概念 Nim 支持将程序拆分成小块。每个模块单独一个文件，有其独立的 `namespace`:idx: "命名空间"。
模块为 `information hiding`:idx: "信息隐藏"和 `separate compilation`:idx: "独立编译"提供了可能。一个模块可以通过 `import`:idx:
语句访问另一个模块里的符号。允许 `Recursive module dependencies`:idx: "递归模块依赖"，但是略微复杂。只会导出带了星号( `*` )标记的顶层符号。
只有合法的 Nim 标识符才能作为模块名(所以对应的文件名是 ``identifier.nim`` )。

编译模块的算法如下:

- 递归地追随导入语句正常编译整个模块。

- 如果发现成环，只导入已经完成语法分析的(且被导出的)符号；如果遇到未知标识符就中止。

最好用一个例子来演示(译者注:代码里的注释描述了编译模块 A 时编译器的行为):

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

  proc p* (x: A.T1): A.T1 =
    # 编译器已把 T1 添加到 A 的接口符号表，所以这么写没问题
    result = x + 1
  ```


Import 语句
----------------------

`import` 关键字的后面可以跟一个由若干模块名组成的列表，或者带有 `except` 列表的单个模块名。
`except` 列表里的符号不会导入。

  ```nim  test = "nim c $1"  status = 1
  import std/strutils except `%`, toUpperAscii

  # 这行代码无法工作:
  echo "$1" % "abc".toUpperAscii
  ```


编译器不会检查 `except` 列表里的符号是否真的已经导出。这一特性允许我们与模块的不同版本一起编译，
即便某个版本可能没有导出列表里的某些符号。

`import` 只允许在顶层出现。


Include 语句
------------------------

`include` 语句所干的事情与导入模块截然不同: 它只是把文件的内容包含进来而已。
`include` 语句可用来把一个大模块切分成几个文件:

  ```nim
  include fileA, fileB, fileC
  ```

`include` 语句可以在顶层之外使用，比如:

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


导入语句里的模块名
------------------------------------

通过 `as` 关键字可为模块引入别名(原模块名就不可用了):

  ```nim
  import std/strutils as su, std/sequtils as qu

  echo su.format("$1", "lalelu")
  ```

使用 `path/to/module` 或者 `"path/to/module"` 这些写法来引用子目录里的模块:

  ```nim
  import lib/pure/os, "lib/pure/times"
  ```

注意模块名仍然是 `strutils` 而不是 `lib/pure/strutils`，所以 **不能** 这么干:

  ```nim
  import lib/pure/strutils
  echo lib/pure/strutils.toUpperAscii("abc")
  ```

与之类似，因为模块名已经就是 `strutils` 了，所以下面的代码是不合理的:

  ```nim
  import lib/pure/strutils as strutils
  ```


从目录里集体导入
--------------------------------

使用语法 `import dir / [moduleA, moduleB]` 能够从同一个路径里导入多个模块。

在语法上，路径名可以是 Nim 标识符或者字符串字面量。如果路径名不是一个合法的 Nim 标识符，
那么就需要写成字符串字面量的形式:

  ```nim
  import "gfx/3d/somemodule" # '3d' 不是合法的 Nim 标识符，要用引号
  ```


用于 import/include 的伪路径
--------------------------------------------------------

路径也可以是所谓的 "pseudo directory" "伪路径"。它们用来解决存在同名模块时的多义问题。

有两个伪路径:

1. `std`:`std` 这个伪路径代表了 Nim 标准库的抽象位置。例如，`import std / strutils` 可用来明确地导入标准库里的 `stutils` 模块。
2. `pkg`:`pkg` 这个伪路径用来明确地指向 Nim 软件包。不过，其技术细节不在本文档的范围以内。
  它的语义是: *使用搜索路径去查找模块名，但是忽略标准库所在位置* 。换句话说，它是 `std` 的反面。

对于所有导入标准库(stdlib)里的模块的情况，建议、优选(但是目前并不强制)把 std/ 这个伪路径写到导入语句里。

From import 语句
--------------------------------

`from` 关键字后面是一个模块名，然后是 `import` 关键字，最后是符号列表。这个列表里的符号，开发者不需要显式地全限定就能直接使用。

  ```nim  test = "nim c $1"
  from std/strutils import `%`

  echo "$1" % "abc"
  # 总是允许全限定形式:
  echo strutils.replace("abc", "a", "z")
  ```

如果要导入模块 `module` ，又要强制以全限定的形式访问它的每一个符号，那么可以 `from module import nil` 。


Export 语句
----------------------

`export` 语句用来转发符号，这样客户模块就不需要再导入本模块的依赖了:

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

  # 这里 B.MyObject 被隐式导入:
  var x: MyObject
  echo $x
  ```

当被导出的符号是另一个模块时，这个模块里的所有定义都会被导出。通过使用 `except` 列表可以将其中的某些符号排除。

注意当导出时，只需要指定模块名:

  ```nim
  import foo/bar/baz
  export baz
  ```



作用域规则
--------------------
标识符从它的声明处开始生效，并持续到到其声明所在的那个块结束。标识符为已知状态的那段代码范围称为标识符的作用域。标识符的准确的作用域与其声明方式有关。

### 块作用域

对于在块(block)的声明部分里声明的变量，其作用域从其声明处开始，直到块的末尾结束。
如果一个块里包含另一个块，在这个块里又再次声明了这个标识符，那么，在这个内部的块里，第二个声明有效。
当离开这个内部的块时，第一个声明又一次有效。在同一个块里，同一个标识符不能被重复定义，
除非是为了过程或者迭代子重载之目的。


### 元组或对象作用域

在元组或者对象定义里的字段标识符在下列地方有效:

* 直到元组/对象的定义结束
* 所给的元组/对象类型的变量的字段指示器(designators)
* 对象类型的所有派生类型内

### 模块作用域

模块里的所有标识符从声明开始直到模块结束一直有效。间接依赖的模块里的标识符在本模块里 *不可用* 。
每个模块都自动导入了 `system`:idx: "系统"模块。

如果一个模块从两个不同模块里导入了相同的标识符，那么每次使用它时都必须加上限定，除非它是一个重载的过程或者迭代子，
这时重载解析会进来解决多义性:

  ```nim
  # 模块 A
  var x* : string
  ```

  ```nim
  # 模块 B
  var x* : int
  ```

  ```nim
  # 模块 C
  import A, B
  write(stdout, x) # 错误:x 指代不明
  write(stdout, A.x) # 正确:加上限定后 x 的指代明确

  var x = 4
  write(stdout, x) # 没有多义性: 这是模块 C 自己的 x
  ```


包
----
对于根目录里有一个 ``identifier.nimble`` 文件的目录树，里面的那些模块被合称为一个 Nimble 包。
``identifier.nimble`` 这个文件名里的 ``identifier`` 就是包的名称，必须是合法的 Nim 标识符。
对于没有与之关联的 ``.nimble`` 文件的模块，给它这么一个包名: `unknown` 。

包与包之间有了区分，就可以限制编译器输出的诊断信息的范围: 仅限当前项目里的包，或者仅限项目外部的包。



编译器消息
====================

Nim 编译器会输出不同类型的消息: `hint`:idx: "提示"，`warning`:idx: "警告"和 `error`:idx: "错误"。
编译器遇到静态错误时会输出 *错误* 消息。



编译指示
================

编译指示(pragmas)是 Nim 语言在不引入大量新关键字的前提下给编译器提供额外信息、命令的方法。
编译指示在语法检查时随即就处理了。编译指示由一对特殊的花括号 `{.` 和 `.}` 包围。
当语言有了新特性但是还没设计出与之匹配的漂亮语法时，常常通过编译指示提供尝鲜体验。


deprecated 编译指示
--------------------------------------

deprecated 编译指示用来标记某符号已废弃:

  ```nim
  proc p() {.deprecated.}
  var x {.deprecated.}: char
  ```

可选地，这个编译指示还能接受一个包含警告信息的字符串，编译器会把它呈现给开发者。

  ```nim
  proc thing(x: bool) {.deprecated: "请改用 thong".}
  ```



compileTime 编译指示
----------------------------------------
`compileTime` 编译指示用来指示一个过程或者变量只能用于编译期的执行。不会为它生成代码。
编译期过程可作为宏的辅助。从语言的 0.12.0 版本开始，包含 `system.NimNode`
类型的参数的过程隐式地声明为 `compileTime`:

  ```nim
  proc astHelper(n: NimNode): NimNode =
    result = n
  ```

和如下一样:

  ```nim
  proc astHelper(n: NimNode): NimNode {.compileTime.} =
    result = n
  ```

加了 `compileTime` 编译指示的变量在运行时也存在。很多时候希望某些变量(例如查找表)在编译时填充数据、
在运行时访问——这轻而易举:

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


noreturn 编译指示
----------------------------------
`noreturn` 编译指示用来指示过程永远不会返回。


acyclic 编译指示
--------------------------------
`acyclic` 编译指示用来指示对象类型是无环的，即使看起来像是有环的。
这个信息是一种 **优化** ，有了这个信息垃圾回收器不再需要考虑这个类的对象构成环的情况:

  ```nim
  type
    Node = ref NodeObj
    NodeObj {.acyclic.} = object
      left, right: Node
      data: string
  ```

我们也可以直接使用引用对象类型:

  ```nim
  type
    Node {.acyclic.} = ref object
      left, right: Node
      data: string
  ```

这个例子里通过 `Node` 类型声明了一个树形结构。注意到这个类型的定义是递归的，GC 不得不考虑各对象可能构成一个有环图的情况。
`acyclic` 编译指示告知 GC 这不可能发生。如果程序员把 `acyclic` 编译指示赋予了实际上有环的数据类型，那么将导致内存泄露，但是不会破坏内存安全。



final 编译指示
----------------------------
`final` 编译指示用来指示一个对象类型不能被继承。注意只能继承那些继承自已有对象类型的类型(通过 `object of SuperType` 语法)
或者标注了 `inheritable` 的类型。


shallow 编译指示
--------------------------------
`shallow` 编译指示影响类型的语义: 允许编译器进行浅拷贝。这会导致严重的语义问题，破坏内存安全！
但是，它也可以大幅度提高赋值的速度，因为 Nim 的语义要求对序列和字符串做深拷贝。深拷贝代价高昂，
尤其是用序列来构造树形结构的时候:

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


pure 编译指示
--------------------------
给对象类型加上 `pure` 编译指示后，编译器就不再为它生成用于运行时类型识别的类型字段。
这曾是为了实现与其它编译型语言的二进制兼容。

枚举类型可以标记为 `pure` 。这样一来，访问其成员时总是需要使用全限定。


asmNoStackFrame 编译指示
------------------------------------------------
可以给过程加上 `asmNoStackFrame` 编译指示以告知编译器不要为它生成栈帧。编译器同样也不会生成类似`return result;` 的退出语句。
根据所用的 C 编译器，生成的 C 函数会被声明成 `__declspec(naked)`:c: 或者 `__attribute__((naked))`:c: 。

**注意**: 这个编译指示应该只用于完全由汇编语句构成的过程。

error 编译指示
----------------------------
`error` 编译指示可使编译器输出一条包含指定内容的错误消息。但是输出了这个错误消息后，编译过程并不一定会中止。

可以给符号(比如迭代子或者过程)附加 `error` 编译指示。 *使用* 这个符号将触发静态错误。
当需要排除某些由于重载和类型转换导致的合法操作时，这个 `error` 就派上用场了:

  ```nim
  ## 检查所比较的是整形数值，而不是指针:
  proc `==`(x, y: ptr int): bool {.error.}
  ```


fatal 编译指示
----------------------------
`fatal` 编译指示可使编译器输出一条包含指定内容的错误消息。与 `error` 编译指示不同，
输出了这个错误消息后，编译过程必然中止。例子:

  ```nim
  when not defined(objc):
    {.fatal: "编译这个程序时带上 objc 命令！".}
  ```

warning 编译指示
--------------------------------
`warning` 编译指示可使编译器输出一条包含指定内容的警告消息，然后继续编译。

hint 编译指示
--------------------------
`hint` 编译指示可使编译器输出一条包含指定内容的提示消息，然后继续编译。

line 编译指示
--------------------------
`line` 编译指示可以修改所在语句的代码行信息。这个行信息可在栈回溯信息里看到:

  ```nim
  template myassert*(cond: untyped, msg = "") =
    if not cond:
      # 修改 `raise` 语句运行时的行信息
      {.line: instantiationInfo().}:
        raise newException(AssertionDefect, msg)
  ```

如果 `line` 带了参数，那么参数需要是 `tuple[filename: string, line: int]` 的形式；
如果不带参数，那么相当于以 `system.instantiationInfo()` 为参数。


linearScanEnd 编译指示
--------------------------------------------
`linearScanEnd` 编译指示用来告知编译器如何处理 Nim `case`:idx: 语句。这个编译指示在语法上必须是一个语句:

  ```nim
  case myInt
  of 0:
    echo "最常见的情况"
  of 1:
    {.linearScanEnd.}
    echo "第二常见的情况"
  of 2: echo "不常见:使用分支表"
  else: echo "也不常见:使用了分支表，数值为 ", myInt
  ```

在这个例子里， `0` 和 `1` 分支比其它情况更加常见。所以，生成的汇编代码应该首先测试这两个值以使 CPU的分支预测器有更大的几率预测成功(避免出现开销高昂的 CPU 流水线停滞)。
其它的情况则可以放到跳转表里，其开销为 O(1)，但代价是一次(很可能出现的)流水线停滞。

`linearScanEnd` 编译指示应该被到最后一个需要进行线性扫描的分支里。如果放到整个 `case` 语句最后那个分支里，那么整个 `case` 语句都会使用线性扫描。


computedGoto 编译指示
------------------------------------------
`computedGoto` 编译指令告知编译器如何编译嵌在 `while true` 语句里的 Nim `case`:idx: 语句。
这个编译指示在语法上必须是这个循环体里的一条语句:

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

如例子所示，`computedGoto` 对于实现解释器非常有用。如果所使用的后端(C 编译器)不支持计算跳转这个扩展功能，那么该编译指示被直接忽略。


immediate 编译指示
------------------------------------

`immediate` 编译指示已经淘汰。参考 `Typed vs untyped parameters <#templates-typed-vs-untyped-parameters>`_ "有类型 vs 无类型参数" .


与编译选项相关的编译指示
------------------------------------------------
下面列出的编译指示用来改写过程、方法、转换器的代码生成选项。

当前，编译器提供以下可能的选项(以后可能会增加)。

===================  =======================  ==================================================================
编译指示             允许的值                 描述
===================  =======================  ==================================================================
checks               on|off                   是否为所有的运行时检查生成代码。
boundChecks          on|off                   是否为数组边界检查生成代码。
overflowChecks       on|off                   是否为上、下溢出检查生成代码。
nilChecks            on|off                   是否为空指针检查生成代码。
assertions           on|off                   是否为断言生成代码。
warnings             on|off                   打开或关闭编译器的警告消息。
hints                on|off                   打开或关闭编译器的提示消息。
optimization         none|speed|size          设置优化目标为执行速度(speed)、文件大小(size)，
                                              或者关闭优化(none)
patterns             on|off                   打开或关闭项重写模块、宏。
callconv             cdecl|...                为所有过程(及过程类型)设置默认的调用规范。
===================  =======================  ==================================================================

例如:

  ```nim
  {.checks: off, optimization: speed.}
  # 关闭运行时检查，优化执行速度
  ```


push 和 pop 编译指示
----------------------------------------
`push/pop`:idx: 编译指示也是用来控制编译选项的，不过是用于临时性地修改设置然后还原。例子:

  ```nim
  {.push checks: off.}
  # 由于这一段代码对于执行速度非常关键，所以不做运行时检查
  # ... 一些代码 ...
  {.pop.} # 恢复原来旧的编译设置
  ```

`push/pop`:idx: 能够开关一些来自标准库的编译指示，例如:

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

对于来自第三方的编译指示，`push/pop`:idx: 是否有效与第三方的实现有关，但是无论如何使用的语法是相同的。


register 编译指示
----------------------------------
`register` 编译指示仅用于变量。这个编译指示将变量声明为 `register`，
提示编译器应该将这个变量放到硬件寄存器里以提高访问速度。C 编译器经常忽略这个提示，理由充分:
没有这个提示它们往往能把活干得更漂亮。

然而，特定的情况下(例如一个字节码解释器的调度循环)这个编译指示可能会有所帮助。


global 编译提示
------------------------------
可以给过程里的变量加上 `global` 编译提示，命令编译器把这个变量存储在全局位置，并且在程序启动时初始化一次。

  ```nim
  proc isHexNumber(s: string): bool =
    var pattern {.global.} = re"[0-9a-fA-F]+"
    result = s.match(pattern)
  ```

在泛型过程里使用时，编译器会为泛型过程的每个实例创建独立的全局变量。编译器为某个模块创建的这些全局变量，
其初始化时的先后顺序不做规定；但是，整体上是先初始化这个模块的顶层变量，再初始化这些全局变量；
如果其它模块导入了这个模块，那么这些全局变量的初始化将早于其它模块里的变量。

禁用某些消息
------------------------
Nim 产生的某些警告和提示消息(如"line too long")可能令人厌烦。为此提供了一种禁用消息的机制: 
每条提示和警告消息都关联了一个符号。这个符号就是消息的标识符，把它放到编译指示后面的方括号里就可以使能或者禁用这条消息:

  ```Nim
  {.hint[LineTooLong]: off.} # 关闭关于代码行太长的那条提示
  ```

对于警告消息而言，这种办法往往比一股脑地禁用所有警告更好。


used 编译提示
--------------------------

当一个符号既未导出也未被使用时，Nim 会输出一条警告消息。给这个符号加上 `used` 编译提示可以抑制这条消息。
当通过宏生成符号时，这个编译提示非常有用:

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

`used` 也可用作顶层语句，把模块标记为"已使用"。这样就可以抑制针对这个模块的"未使用的导入"这条警告:

  ```nim
  # 模块:debughelper.nim
  when defined(nimHasUsed):
    # 'import debughelper' 对于调试来说非常有用，
    # 即使这个模块未被使用，也不需要 Nim 输出警告:
    {.used.}
  ```


expermimental 的编译指示
------------------------------------------------

`expermimental` 编译指示用于启用实验性的语言功能。取决于具体的特性，意味着，特性要么被认为过于不稳定，要么并不确定，可能随时被删除。详情参阅 `experimental manual <manual_experimental.html>`_ 。

示例:

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


作为顶层声明，expermimental 编译指示为它所启用的模块的其他部分启用一个特性。这对于跨越模块作用域的宏和泛型实例有问题。目前，这些用法必须放到 `.push/pop` 环境中:

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


  ```nim
  import client
  useParallel(1)
  ```


实现特定的编译指示
====================================

本节介绍当前Nim实现所支持的额外的编译指示，但不应将其视为语言规范的一部分。

Bitsize 编译指示
--------------------------------

`bitsize` 是对象字段成员的编译指示。表明该字段为 C/C++ 中的位域。

  ```Nim
  type
    mybitfield = object
      flag {.bitsize:1.}: cuint
  ```

生成:

  ```C
  struct mybitfield {
    unsigned int flag:1;
  };
  ```


Align 编译指示
----------------------------

`align`:idx: "对齐"编译指示是针对变量和对象字段成员的。它用于修改所声明的实体的字节对齐要求。参数必须是 2 的幂。 有效的非 0 对齐的编译指示存在同时声明的时候，弱的编译指示会被忽略。与类型的对齐要求相比较弱的对齐编译指示的声明也会被忽略。

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

这种编译指示对 JS 后端没有任何影响。


Noalias 编译指示
--------------------------------

从 Nim 编译器版本 1.4 ，有一个 `.noalias` 注解用于变量和参数。它被直接映射到 C/C++ 的 `restrict`:c: 关键字，表示底层指向内存中的一个独特地址，此地址不存在其他别名。 *unchecked* 遵守此别名限制。 如果违反了限制，后端优化器可以自主编译代码。这是一个 **不安全的** 语言功能。

理想情况下，在Nim之后的版本中，该限制将在编译期强制执行。(这也是为什么选择 `noalias` 的名称，而不是描述更详细的名称，如 `unsafeAssumeNoAlias` 。)


Volatile 编译指示
----------------------------------
`volatile` 编译指示仅用于变量。它声明变量为 `volatile`:c: ,不论 C/C++ 中 volatile 代表什么含义 (其语义在 C/C++中没有明确定义)。

**注意**: LLVM 后端不存在这种编译指示。


nodecl 编译指示
------------------------------
`nodell` 编译指示可以应用于几乎任何标识符(变量、过程、类型等)。有时在与 C 的互操作上很有用: nodell编译指示会告知Nim,不要生成在 C 代码中的标识符的声明。例如:

  ```Nim
  var
    EACCES {.importc, nodecl.}: cint # pretend EACCES was a variable, as
                                     # Nim does not know its value
  ```

然而， `header` 编译指示通常是更好的选择。

**注意**: 这在 LLVM 后端无法使用。


Header 编译指示
------------------------------
`header` 编译指示和 `nodecl` 编译指示非常相似: 可以应用于几乎所有的标识符，并指定它不应该被声明，与之相反，生成的代码应该包含一个 `#include`:c:\: 。

  ```Nim
  type
    PFile {.importc: "FILE*", header: "<stdio.h>".} = distinct pointer
      # import C's FILE* type; Nim will treat it as a new pointer type
  ```

`header` 编译指示总是需要一个字符串常量。这个字符串常量包含头文件。像C语言一样，系统头文件被括在角括号中: `<>`:c: 。如果没有给出角括号，Nim会在生成的C代码中把头文件括在 `""`:c: 中。

**注意**: LLVM 后端不存在这种编译指示。


IncompleteStruct 编译指示
--------------------------------------------------
`incompleteStruct` 编译指示告知编译器不要在 `sizeof` 表达式中使用底层的 C `struct`:c: 。

  ```Nim
  type
    DIR* {.importc: "DIR", header: "<dirent.h>",
           pure, incompleteStruct.} = object
  ```


Compile 编译指示
--------------------------------
`compile` 编译指示可以用来编译和链接一个C/C++源文件与项目:

  ```Nim
  {.compile: "myfile.cpp".}
  ```

**注意**: Nim 通过计算SHA1校验和，并且只在文件有变化时才重新编译。可以使用 `-f`:option: 命令行选项来强制重新编译文件。

从 1.4 开始， `compile` 编译指示也可以使用此语法:

  ```Nim
  {.compile("myfile.cpp", "--custom flags here").}
  ```

可以从例子中看出，这个新变量允许在文件重新编译时将自定义标志传递给C编译器。


Link 编译指示
--------------------------
`link` 编译指示用来将附加文件与项目链接:

  ```Nim
  {.link: "myfile.o".}
  ```


passc 编译指示
----------------------------
`passc` 编译指示可以用来传递额外参数到 C 编译器，就像命令行使用的 `--passc`:option:\:

  ```Nim
  {.passc: "-Wall -Werror".}
  ```

请注意，可以使用 `system module <system.html>`_ 中的 `gorge` 来嵌入来自外部命令的参数，该命令将在语义分析期间执行:

  ```Nim
  {.passc: gorge("pkg-config --cflags sdl").}
  ```


localPassC 编译指示
--------------------------------------
`localPassC` 编译指示可以用来向C编译器传递额外的参数，但只适用于由编译指示所在的Nim模块生成的C/C++文件:

  ```Nim
  # Module A.nim
  # 生成: A.nim.cpp
  {.localPassC: "-Wall -Werror".} # Passed when compiling A.nim.cpp
  ```


passl 编译指示
----------------------------
`passc` 编译指示可以用来传递额外参数到 C 链接器，就像在命令行使用的 `--passc`:option:\:

  ```Nim
  {.passl: "-lSDLmain -lSDL".}
  ```

请注意，可以使用 `system module <system.html>`_ 中的 `gorge` 来嵌入来自外部命令的参数，该命令将在语义分析期间执行:

  ```Nim
  {.passl: gorge("pkg-config --libs sdl").}
  ```


Emit 编译指示
--------------------------
`emit` 编译指示可以用来直接影响编译器代码生成器的输出。这样一来，该代码就不能被其他代码生成器/后端所移植。我们非常不鼓励使用这种方法。然而，它对与 `C++`:idx: 或 `Objective C`:idx: 代码的接口非常有用。

示例:

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

`nimbase.h` 定义了 `NIM_EXTERNC`:c: C宏，可以用于 `extern "C"`:cpp: 代码可以同时用于 `nim c`:cmd: 和 `nim cpp`:cmd: , 例如:

  ```Nim
  proc foobar() {.importc:"$1".}
  {.emit: """
  #include <stdio.h>
  NIM_EXTERNC
  void fun(){}
  """.}
  ```

.. note:: 为了向后兼容，如果 `emit` 语句的参数是单一的字符串字面值，Nim标识符可以通过反引号引起来。但这种用法已经废弃。

对于一个顶层 emit 声明，在生成的 C/C++ 文件中，代码应该被 emit 标记的部分可以通过前缀 `/*TYPESECTION*/`:c: 或 `/*VARSECTION*/`:c: 或 `/*INCLUDESECTION*/`:c:\: 来影响。

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


ImportCpp 编译指示
------------------------------------

**注意**: `c2nim <https://github.com/nim-lang/c2nim/blob/master/doc/c2nim.rst>`_ 可以解析C++的大的子集，并且知道 `importcpp` 编译指示的模式语言。不需要知道这里描述的所有细节。


类似于C语言的 `importc pragma <#foreign-function-interface-importc-pragma>`_ ， `importcpp` 编译指示可以用来导入 `C++`:idx: 方法或一般的C++ 标识符。
生成的代码使用C++方法调用语法: `obj->method(arg)`:cpp: 。与 `header` 和 `emit` 语义相结合，这允许 *sloppy* *宽松的* 与用C++编写的库对接。

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

需要告知编译器生成C++(命令 `cpp`:option: )，才能工作。条件标识符 `cpp` 在编译器生成C++代码时被定义。

### 命名空间

这个 *sloppy interfacing* 例子使用 `.emit` 来生成 `using namespace`:cpp: 声明。通常，通过 `namespace::identifier`:cpp: 标识符来引用导入的名称会好很多:

  ```nim
  type
    IrrlichtDeviceObj {.header: irr,
                        importcpp: "irr::IrrlichtDevice".} = object
  ```


### Importcpp 应用于枚举

`importcpp` 应用于枚举类型时，数字枚举值被注解为C++枚举类型，就像在这个例子中: `((TheCppEnum)(3))`:cpp: 。(这已是最简单的实现方式。)


### Importcpp 应用于过程

请注意，过程的 `importcpp` 变量使用了一种有些隐晦的范式语言，以获得最大的灵活性:

- 哈希 ``#`` 符号会被第一个或下一个参数所取代。
- 哈希符号加个点 ``#.`` 表示调用应该使用 C++ 的点或箭头符号。
- 符号 ``@`` 被剩余参数替换。通过逗号分隔。

例如:

  ```nim
  proc cppMethod(this: CppObj, a, b, c: cint) {.importcpp: "#.CppMethod(@)".}
  var x: ptr CppObj
  cppMethod(x[], 1, 2, 3)
  ```

生成:

  ```C
  x->CppMethod(1, 2, 3)
  ```

作为一项特殊规则，为了保持与旧版本的 `importcpp` 编译指示的向后兼容性，如果没有任何特殊的模式字符 ( ``# ' @`` 中的任意一个 )，就会假定为C++的点或箭头符号，所以上述例子也可以写成:

  ```nim
  proc cppMethod(this: CppObj, a, b, c: cint) {.importcpp: "CppMethod".}
  ```

请注意，模式语言当然也包括C++的操作符重载的能力:

  ```nim
  proc vectorAddition(a, b: Vec3): Vec3 {.importcpp: "# + #".}
  proc dictLookup(a: Dict, k: Key): Value {.importcpp: "#[#]".}
  ```


- 撇号 ``'`` 后面是 0..9 范围内的整数 ``i`` ，被第i个参数 *type* 替换。第0个位置是返回值类型。这可以用来向C++函数模板传递类型。
在 ``'`` 和数字之间，可以用星号来获得该类型的基本类型。(所以它从类型中拿走星号，如 `T*`:c: 变成了 `T` 。)两个星号可以用来获取元素类型的类型等。

例如:

  ```nim
  type Input {.importcpp: "System::Input".} = object
  proc getSubsystem*[T](): ptr T {.importcpp: "SystemManager::getSubsystem<'*0>()", nodecl.}

  let x: ptr Input = getSubsystem[Input]()
  ```

生成:

  ```C
  x = SystemManager::getSubsystem<System::Input>()
  ```


- `#@` 是支持 `cnew` 操作的特殊情况。它使调用表达式直接被内联，而不需要通过一个临时地址。这只是为了规避当前代码生成器的限制。

例如，C++中 `new`:cpp: 运算符可以像这样 "imported" 导入:

  ```nim
  proc cnew*[T](x: T): ptr T {.importcpp: "(new '*0#@)", nodecl.}

  # constructor of 'Foo':
  proc constructFoo(a, b: cint): Foo {.importcpp: "Foo(@)".}

  let x = cnew constructFoo(3, 4)
  ```

生成:

  ```C
  x = new Foo(3, 4)
  ```

然而，根据使用情况 `new Foo`:cpp: 也可以像这样包裹:

  ```nim
  proc newFoo(a, b: cint): ptr Foo {.importcpp: "new Foo(@)".}

  let x = newFoo(3, 4)
  ```


### 包装构造函数

有时候C++类有一个私有的构造函数，所以代码 `Class c = Class(1,2);`:cpp: 不正确，而应该是 `Class c(1,2);`:cpp: 。
要达到这种效果，包装一个 C++ 构造函数的 Nim 过程需要使用附加注解的 `constructor`:idx: 编译指示，这个编译指示也有助于生成更快的 C++ 代码，因为构造时不会调用拷贝构造器:

  ```nim
  # a better constructor of 'Foo':
  proc constructFoo(a, b: cint): Foo {.importcpp: "Foo(@)", constructor.}
  ```


### 包装析构器

由于Nim直接生成C++，任何析构函数都会在作用域退出时被C++编译器隐式调用。这意味着，通常我们可以不包装析构函数！
但是，当它需要显式调用时，就需要包装。模式语言提供了所需一切。

  ```nim
  proc destroyFoo(this: var Foo) {.importcpp: "#.~Foo()".}
  ```


### Importcpp 应用于对象

通用的 `importcpp` 对象被映射到C++模板。这意味着可以很容易地导入C++的模板，而不需要对象类型的模式语言:

  ```nim  test = "nim cpp $1"
  type
    StdMap[K, V] {.importcpp: "std::map", header: "<map>".} = object
  proc `[]=`[K, V](this: var StdMap[K, V]; key: K; val: V) {.
    importcpp: "#[#] = #", header: "<map>".}

  var x: StdMap[cint, cdouble]
  x[6] = 91.4
  ```


生成:

  ```C
  std::map<int, double> x;
  x[6] = 91.4;
  ```


- 如果需要更精确的控制，可以在提供的模式中使用撇号 `'` 来表示泛型的具体类型参数。更多细节请参见过程模式中的撇号操作符的用法。

    ```nim
    type
      VectorIterator {.importcpp: "std::vector<'0>::iterator".} [T] = object

    var x: VectorIterator[cint]
    ```

  生成:

    ```C

    std::vector<int>::iterator x;
    ```


ImportJs 编译指示
----------------------------------

类似于 `importcpp pragma for C++ <#implementation-specific-pragmas-importcpp-pragma>`_ , `importjs` 编译指示可以用来导入 JavaScript 的方法或者符号。生成的代码会使用 Javascript 方法调用语法: `obj.method(arg)` 。


ImportObjC 编译指示
--------------------------------------
类似于 `importc pragma for C <#foreign-function-interface-importc-pragma>`_ , `importobjc` 编译指示可以用来导入 `Objective C`:idx: 的方法。生成的代码会使用 Objective C 的方法调用语法: `[obj method param1: arg]` 。 结合 `header` 和 `emit` 编译指示，这允许 *sloppy* 接口使用 Objective C 的库:

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

需要告知编译器生成 Objective C(命令 `objc`:option: ) 才能工作。当编译器输出 Objective C 代码时，条件标识符 `objc` 会被定义。


CodegenDecl 编译指示
----------------------------------------

`codegenDecl` 编译指示可以直接影响Nim的代码生成器。它接受一个格式字符串，用于决定变量或过程如何在生成的代码中声明。

对于变量，格式字符串中的$1表示变量的类型，$2表示变量的名称。

以下 Nim 代码:

  ```nim
  var
    a {.codegenDecl: "$# progmem $#".}: int
  ```

将生成此 C 代码:

  ```c
  int progmem a
  ```

就程序而言，$1是程序的返回值类型，$2是程序的名字，$3是参数列表。

以下 Nim 代码:

  ```nim
  proc myinterrupt() {.codegenDecl: "__interrupt $# $#$#".} =
    echo "realistic interrupt handler"
  ```

将生成此代码:

  ```c
  __interrupt void myinterrupt()
  ```


`cppNonPod` 编译指示
----------------------------------------

`.cppNonPod` 编译指示应该用于非POD `importcpp` 类型，以便他们 `.threadvar` 变量正常工作(尤其是对构造器和析构器而言)。这需要 `--tlsEmulation:off`:option: 。

  ```nim
  type Foo {.cppNonPod, importcpp, header: "funs.h".} = object
    x: cint
  proc main()=
    var a {.threadvar.}: Foo
  ```


编译期定义的编译指示
----------------------------------------

这里列出的编译指示可以用来在编译时接受 `-d/-define`:option: 可选的选项值。

当前的提供了以下可能的选项 (以后可能会添加其他选项)。


=================  ============================================ 
编译指示           描述 
=================  ============================================ 
`intdefine`:idx:   编译时定义读取为整数类型 
`strdefine`:idx:   编译时定义读取为 string 类型 
`booldefine`:idx:  编译时定义读取为 bool 类型 
=================  ============================================

  ```nim
  const FooBar {.intdefine.}: int = 5
  echo FooBar
  ```

  ```cmd
  nim c -d:FooBar=42 foobar.nim
  ```

在上述例子中，提供 `-d`:option: 标志使得符号 `FooBar` 在编译时被覆盖，打印出 42。 如果删除 `-d:FooBar=42`:option: ，则使用默认值5。要查看是否提供了值，可以使用 `defined(FooBar)` 。

语法 `-d:flag`:option: 实际上是 `-d:flag=true`:option: 的简写。

用户定义的编译指示
==========================================


pragma 编译指示
------------------------------

`pragma` 编译指示可以用来声明用户自定义的编译指示。这是有用的，因为Nim的模板和宏不会影响编译指示。用户定义的编译指示与所有其他符号有不同的模块作用域。它们不能从模块中导入。

示例:

  ```nim
  when appType == "lib":
    {.pragma: rtl, exportc, dynlib, cdecl.}
  else:
    {.pragma: rtl, importc, dynlib: "client.dll", cdecl.}

  proc p*(a, b: int): int {.rtl.} =
    result = a + b
  ```

在这个例子中，引入了一个名为 `rtl` 的新编译指示，它可以从动态库中导入一个符号，也可以为动态库的生成导出该符号。


自定义注解
--------------------
这可以定义自定义类型的编译指示。 自定义编译指示不会直接影响代码生成，但可以被宏检测。使用编译指示 `pragma` 注解模板来定义自定义编译指示:

  ```nim
  template dbTable(name: string, table_space: string = "") {.pragma.}
  template dbKey(name: string = "", primary_key: bool = false) {.pragma.}
  template dbForeignKey(t: typedesc) {.pragma.}
  template dbIgnore {.pragma.}
  ```


这个是可能的对象关系映射 (ORM) 实现的典型例子:

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

在本例中，自定义编译指示被用来描述Nim对象如何被映射到关系数据库的模式中。自定义编译指示可以有零个或多个参数。为了传递多个参数，请使用模板调用语法之一。
所有的参数都有类型，并且遵循模板的标准重载解析规则。因此，可为参数设置默认值，传递名称，varargs等。

自定义编译指示可以在所有可以指定通常编译指示的地方使用。可以用来注解过程、模板、类型和变量 定义、语句等。

宏模块包括可以用来简化自定义编译指示访问的辅助工具 `hasCustomPragma` ， `getCustomPragmaVal` 。详情参阅 `macros <macros.html>`_ 模块文档。
这些宏并不神奇，它们所做的一切也可以通过逐个遍历对象表示的AST来实现。

更多自定义编译指示示例:

- 更好的序列化/反序列化控制:

    ```nim
    type MyObj = object
      a {.dontSerialize.}: int
      b {.defaultDeserialize: 5.}: int
      c {.serializationKey: "_c".}: string
    ```

- 添加类型用于游戏引擎中 gui 检查:

    ```nim
    type MyComponent = object
      position {.editable, animatable.}: Vector3
      alpha {.editRange: [0.0..1.0], animatable.}: float32
    ```


宏编译指示
--------------------

有时可以用编译指示语法来调用宏和模板。可以这样做的情况包括附加到例程(过程、迭代器等)声明或例程类型表达式上。编译器将执行以下简单的语法转换:

  ```nim
  template command(name: string, def: untyped) = discard

  proc p() {.command("print").} = discard
  ```

转换为:

  ```nim
  command("print"):
    proc p() = discard
  ```

------

  ```nim
  type
    AsyncEventHandler = proc (x: Event) {.async.}
  ```

转换为:

  ```nim
  type
    AsyncEventHandler = async(proc (x: Event))
  ```

------

当多个宏编译指示应用于同一个定义时，从左到右的第一个将被评估。
然后，这个宏可以选择在其输出中保留其余的宏语法，这些语法将以同样的方式被评估。

还有一些宏编译指示的应用例子，例如类型、变量和常量声明等。但这种使用方式被认为是实验性的，所以被记录在 `experimental manual <manual_experimental.html#extended-macro-pragmas>`_ "实验性手册"中。


外部函数接口
========================

Nim的 `FFI`:idx: (外部函数接口)很宽泛，这里只记录了能扩展到其他未来后端(如LLVM/JavaScript后端) 的部分。


Importc 编译指示
--------------------------------
`importc` 编译指示提供了一种从C语言导入程序或变量的方法。可选参数是一个包含C语言标识符的字符串。如果没有这个参数，C语言的名称就是Nim的标识符 *完全一样* :

.. code-block::
  proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}

当 `importc` 被应用于 `let` 语句时，它可以忽略其值，这将被期望来自C。这可以用来导入 C `const`:c:\:

.. code-block::
  {.emit: "const int cconst = 42;".}

  let cconst {.importc, nodecl.}: cint

  assert cconst == 42

注意，这个编译指示曾在JS后端JS对象和函数上被滥用。其他后端在相同的名称下提供相同的功能。此外，如果目标语言没有设置为C，还可以使用其他编译指令:

 * `importcpp <manual.html#implementation-specific-pragmas-importcpp-pragma>`_
 * `importobjc <manual.html#implementation-specific-pragmas-importobjc-pragma>`_
 * `importjs <manual.html#implementation-specific-pragmas-importjs-pragma>`_

  ```Nim
  proc p(s: cstring) {.importc: "prefix$1".}
  ```

例如， `p` 的外部名称会被设置为 `prefixp`。只有 ``$1`` 可用，美元符号必须写成 ``$$`` 。


Exportc 编译指示
--------------------------------
`exportc` 编译指示提供了一种将类型、变量或过程导出到C的手段。枚举和常量不能导出。可选参数是包含 C 标识符的字符串。如果参数缺失，C的名字就会和Nim标识符 *完全一样* :

  ```Nim
  proc callme(formatstr: cstring) {.exportc: "callMe", varargs.}
  ```

请注意这个编译指示有时候不正确: 因为其他后端也用相同名称提供了这个功能。

传递给 `exportc` 可以是一个格式化的字符串:

  ```Nim
  proc p(s: string) {.exportc: "prefix$1".} =
    echo s
  ```

例如， `p` 的外部名称会被设置为 `prefixp` 。只有 ``$1`` 可用，美元符号必须写成 ``$$`` 。

如果需要符号也应导出到动态库， `dynlib` 编译指示需要和 `exportc` 编译指示一起使用。请参阅 `Dynlib pragma for export <#foreign-function-interface-dynlib-pragma-for-export>`_ 。


Extern 编译指示
------------------------------
像 `exportc` 或 `importc`一样, `extern` 编译指示会影响名称混淆。传递给 `extern` 可以是一个格式化的字符串:

  ```Nim
  proc p(s: string) {.extern: "prefix$1".} =
    echo s
  ```

例如， `p` 的外部名称会被设置为 `prefixp`。只有 ``$1`` 可用，美元符号必须写成 ``$$`` 。


Bycopy 编译指示
------------------------------

`bycopy` 编译指示可以应用于对象或元组类型，指示编译器按值类型传递给过程:

  ```nim
  type
    Vector {.bycopy.} = object
      x, y, z: float
  ```

Nim编译器根据参数类型的大小自动决定参数是根据值传递的还是按引用传递。如果一个参数必须通过值或引用传递(例如当与 C 库对接时)，请使用 bycopy 或 byref 编译指示。

Byref 编译指示
----------------------------

`byref` 编译指示可以应用于对象或元组类型，指示编译器按引用传递类型(隐藏指针)给过程:


Varargs 编译指示
--------------------------------
`varargs` 编译指示只能应用于过程(和过程类型)。它会告知Nim, 在最后一个指定的参数之后, 过程还可以接受一个变量作为参数。Nim字符串值将会自动转换为C字符串:

  ```Nim
  proc printf(formatstr: cstring) {.nodecl, varargs.}

  printf("hallo %s", "world") # "world" will be passed as C string
  ```


Union 编译指示
----------------------------
`Union` 编译指示可以应用于任意 `object` 类型。这意味着一个对象字段的所有都会在内存中被覆盖。这在生成的 C/C++ 代码中产生了 `union`:c: 而不是 `struct`:c:。对象声明不能使用继承或任何 GC 过但目前未检查的内存。

**未来的方向**: 应该允许 GC 回收过的内存，而GC 应该保守地扫描 union 共用体。


Packed 编译指示
------------------------------
`packed` 编译指示可以应用于任意 `object` 类型。它确保一个对象的字段在内存中连续打包。
它对于存储网络或硬件驱动的数据包或消息，以及与C语言的互操作中非常有用。将packed编译指示与继承相结合是未定义的，它不应该被用于GC的内存(ref's)。

**未来方向**: 在packed 编译指示中使用 GC 的内存将导致静态错误。继承用法应加以定义和文档记录。


Dynlib 编译指示用于导入
------------------------------------------------
使用 `dynlib` 编译指示，过程或变量可以从动态库中导入(`.dll` Windows 文件, `lib*.so` UNIX 文件)。
非可选参数必须是动态库的名称:

  ```Nim
  proc gtk_image_new(): PGtkWidget
    {.cdecl, dynlib: "libgtk-x11-2.0.so", importc.}
  ```

一般来说，导入动态库不需要任何特殊链接选项或与导入库链接。这也意味着不需要安装 *devel* 软件包。

`dynlib` 导入机制支持版本化:

  ```nim
  proc Tcl_Eval(interp: pTcl_Interp, script: cstring): int {.cdecl,
    importc, dynlib: "libtcl(|8.5|8.4|8.3).so.(1|0)".}
  ```

运行时, 动态库(按此顺序)搜索::

  libtcl.so.1
  libtcl.so.0
  libtcl8.5.so.1
  libtcl8.5.so.0
  libtcl8.4.so.1
  libtcl8.4.so.0
  libtcl8.3.so.1
  libtcl8.3.so.0

`dynlib` 编译指示不仅支持作为参数的常量字符串，而且还支持常南侧的字符串表达式:

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

**注意**: 类似 ``libtcl(|8.5|8.4).so`` 只支持常量字符串，因为它们是预编译的。

**注意**: 由于初始化顺序的问题，向 `dynlib` 编译指示传递变量将在运行时出错。

**注意**: `dynlib`导入可以通过 `--dynlibOverride:name`:option: 命令行选项进行覆盖。更多信息查看 `Compiler User Guide <nimc.html>`_ 。


Dynlib 编译指示应用于导出
------------------------------------------------

一个使用了 `dynlib` 编译指示的过程，也能被导出为动态库。这样以来，它不需要参数，但必须结合 `exportc` 编译指示来使用:

  ```Nim
  proc exportme(): int {.cdecl, exportc, dynlib.}
  ```

这只有在程序通过 `--app:lib`:option: 命令行选项被编译为动态库时才有用。



线程
========

要启用线程支持，需要使用 `--threads:on`:option: 命令行开关。同时，system_模块包含几个线程基元。
关于底层的线程API，请参阅 `channels <channels_builtin.html>`_ 模块。还有一些高层次的并行结构可用。详情请见 `spawn <manual_experimental.html#parallel-amp-spawn>`_ 。

相较于其他的通用编程语言(C, Pascal, Java)，Nim 中线程的内存模型是相当与众不同的：
每个线程都有它自己的(垃圾回收)堆，内存共享也仅限于全局变量。这样有助于防止竞态条件。
因为 GC 永远不必停止其他线程，并查看它们到底引用了什么。故而 GC 的效率也得以被大大提升。

只有通过 `spawn` 或者 `createThread` 才能创建一个线程。被调用的过程不得使用 `var` 声明参数，参数类型也不得包含 `ref` 或 `closure` 。

Thread 编译指示
-------------------------------

出于可读性的考虑，作为新线程执行的程序应该用 `thread` 编译指示进行标记。
编译器会检查是否违反了 `no heap sharing restriction`:idx:\: "无堆共享限制"
这个限制意味着，无法构造由不同(线程本地)堆分配的内存组成的数据结构。

一个线程过程被传递给 `createThread` 或 `spawn` ，并被间接调用；
因此，`thread` 编译指示等价于 `procvar` 。



Threadvar 编译指示
--------------------------------

变量可以用 `threadvar` 编译指示来标记，这会使它成为 `thread-local`:idx: "线程本地"变量；
此外，这意味着 `global` 编译指示的所有作用。

  ```nim
  var checkpoints* {.threadvar.}: seq[string]
  ```

由于实现的限制，本地线程变量不能在 `var` 块中初始化。(每个线程本地变量都需要在线程创建时复制。)


线程和异常
----------------------

线程和异常之间的交互很简单:
一个线程中， *被捕获* 了的异常，无法影响其他的线程。
然而，某个线程中 *未捕获* 的异常，会终止整个 *进程* 。


守卫和锁
================

Nim 提供了诸如锁、原子性内部函数和条件变量这样的常见底层并发机制。

Nim 通过附带编译指示，显著地提高了这些功能的安全性:

1) 引入 `guard`:idx: 注解，以防止数据竞争。
2) 每次访问受保护的内存位置，都需要在适当的 `locks`:idx: 语句中进行。


守卫和锁块
-------------------------

### 受保护的全局变量

对象字段和全局变量都可以使用 `guard` 编译指令进行标注:

  ```nim
  import std/locks

  var glock: Lock
  var gdata {.guard: glock.}: int
  ```

然后，编译器会确保每次访问 `gdata` 都在 `locks` 块中:

  ```nim
  proc invalid =
    # invalid: unguarded access:
    echo gdata

  proc valid =
    # valid access:
    {.locks: [glock].}:
      echo gdata
  ```

为了能够方便地初始化，始终允许了对 `gdata` 的顶级访问。
这样 *假设* (但不强制)的前提是，所有顶级语句都执行在未发生并发操作之前。

我们故意让 `locks` 块看起来很丑，因为它没有运行时的语意，不应该被直接使用！
它应该只在运行时中，同时能够实现某种形式的锁定的模板里使用:

  ```nim
  template lock(a: Lock; body: untyped) =
    pthread_mutex_lock(a)
    {.locks: [a].}:
      try:
        body
      finally:
        pthread_mutex_unlock(a)
  ```


守卫不需要属于任何特定类型。它足够灵活到可以对低级无锁机制进行建模:

  ```nim
  var dummyLock {.compileTime.}: int
  var atomicCounter {.guard: dummyLock.}: int

  template atomicRead(x): untyped =
    {.locks: [dummyLock].}:
      memoryReadBarrier()
      x

  echo atomicRead(atomicCounter)
  ```


为了支持 *多锁* 语句，`locks` 编译指令采用了锁表达式 `locks: [a, b, ...]` 。
在 `lock levels <#guards-and-locks-lock-levels>`_ 章节中对这样做的原因进行了解释。


### 保护常规地址

`guard` 注解也可以用于保护对象中的字段。然后，需要用同一个对象或者全局变量中的另一个字段作为守卫。

由于对象可以驻留在堆上或堆栈上，这么做大大地增强了语言的表现力:

  ```nim
  import std/locks

  type
    ProtectedCounter = object
      v {.guard: L.}: int
      L: Lock

  proc incCounters(counters: var openArray[ProtectedCounter]) =
    for i in 0..counters.high:
      lock counters[i].L:
        inc counters[i].v
  ```

允许访问字段 `x.v` ，因为它守卫的 `x.L` 处于活动状态。当模板扩展后，就相当于:

  ```nim
  proc incCounters(counters: var openArray[ProtectedCounter]) =
    for i in 0..counters.high:
      pthread_mutex_lock(counters[i].L)
      {.locks: [counters[i].L].}:
        try:
          inc counters[i].v
        finally:
          pthread_mutex_unlock(counters[i].L)
  ```

有一个分析器，可以检查 `counters[i].L` 是否是对应受保护地址 `counters[i].v` 的锁。
因为这个分析器能够处理像 `obj.field[i].fieldB[j]` 这样的地址的路径，所以我们叫它 `path analysis`:idx: "路径分析"。

路径分析器 **目前不健全** ，但它不是不能用。如果两条路径在语法上相同，则会被认为相互等效。

(目前来说)这意味着如下的编译，哪怕实在不应该这么做:

  ```nim
  {.locks: [a[i].L].}:
    inc i
    access a[i].v
  ```
