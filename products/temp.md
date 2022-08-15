==========
Nim手册
==========

:作者: Andreas Rumpf, Zahary Karadjov
:版本: |nimversion|

.. default-role:: code
.. include:: rstcommon.rst
.. contents::


> "复杂性" 如同 "能量"：终端用户把它转嫁给其他参与者，但一个给定任务总量似乎没变。 -- Ran


关于手册

**注意**: 当前手册还是草案! Nim的一些功能需要更加准确的描述。手册也在不断推进，以成为标准规范。

**注意**: 这里包含Nim的 `实验性功能 <manual_experimental.html>`_ 。

**注意**: 赋值、移动和析构在特定的 `析构文档 <destrtors.html>`_ 部分。


当前手册描述了Nim语言的词法、语法和语义。

要学习如何编译Nim程序和生成文档，请阅读 `编译器用户指南 <nimc.html>`_ 和 `文档生成工具指南 <docgen.html>`_ 。

语言结构使用扩展BNF解释， `(a)*` 表示0个或多个 `a` ， `a+` 表示1个或多个 `a` ， `(a)?` 表示一个可选的 *a* ，圆括号用来元素分组。

`&` 是查找运算符； `&a` 表示期待一个 `a` ，但没有用掉，而在之后的规则中被消耗。

 `|`, `/` 符号用于标记备选，优先级最低。`/` 是有序的选择，要求解析器按照给定的顺序来尝试备选项，`/` 常用来消除语法歧义。

非终端符号以小写字母开头，抽象的终端符号以大写字母开头，逐字终端符号（包括关键词）用 `'` 引号。例如：

  ifStmt = 'if' expr ':' stmts ('elif' expr ':' stmts)* ('else' stmts)?

The binary `^*` operator is used as a shorthand for 0 or more occurrences
separated by its second argument; likewise `^+` means 1 or more
occurrences: `a ^+ b` is short for `a (b a)*`
and `a ^* b` is short for `(a (b a)*)?`. 示例：:

  arrayConstructor = '[' expr ^* ',' ']'

Nim的其他如作用域规则或运行时语义，使用非标准描述。




定义
===========

Nim代码是特定的计算单元，作用于称为 `locations`:idx: 组件组成的内存。变量本质上是地址的名称，每个变量和地址都有特定的 `type`:idx: ，变量的类型被称为 `static type`:idx: ，地址的类型被称为 `dynamic type`:idx: 。如果静态类型与动态类型不同，它就是动态类型的超类或子类。

 `identifier`:idx: 是变量、类型、过程等的名称声明符号，一个声明所适用的程序区域被称为该声明的 `scope`:idx: ，作用域可以嵌套，一个标识符的含义由标识符所声明的最小包围作用域决定，除非重载解析规则另有建议。

一个表达式特指产生值或地址的计算，产生地址的表达式被称为 `l-values`:idx: ，左值可以表示地址，也可以表示该地址包含的值，这取决于上下文。

Nim `program`:idx: 由一个或多个包含Nim代码的文本 `source files`:idx: 组成，由Nim `compiler`:idx: 处理成 `executable`:idx:,这个可执行文件的性质取决于编译器的实现；例如，它可能是一个本地二进制文件或JavaScript源代码。

在典型的Nim程序中，大部分代码被编译到可执行文件中，然而，有些代码可能在 `compile-time`:idx: 执行，包括常量表达式、宏定义和宏定义使用的Nim过程。大部分的Nim代码支持编译时执行，但是有一些限制 -- 详情阅读 `关于编译时执行的限制 <#restrictions-on-compileminustime-execution>`_ 。我们使用术语 `runtime`:idx: 来涵盖编译时执行和可执行文件中的代码执行。

编译器将Nim源代码解析成一个内部数据结构，称为 `abstract syntax tree`:idx: (`AST`:idx:) ，在执行代码或将其编译为可执行文件之前，通过 `semantic analysis`:idx: 对AST进行转换，增加了语义信息，如表达式类型、标识符的含义，以及在某些情况下的表达式值。在语义分析中检测到的错误被称为 `static error`:idx: ，当前手册中描述的错误在没有其他约定时是静态错误。

`panic`:idx: 是在运行时检测和报告的错误，报告这种错误的方式是通过 *引发异常* 或 *致命错误* 结束，也提供了一种方法来禁用 `runtime checks`:idx: ，详情阅读标记一节。

恐慌的结果是一个异常还是一个致命的错误，是特定的实现，因此，下面的程序是无效的，尽管代码试图捕获越界访问数组的 `IndexDefect` ，但编译器可能会以致命错误终结程序。

  ```nim
  var a: array[0..1, char]
  let i = 5
  try:
    a[i] = 'N'
  except IndexDefect:
    echo "invalid index"
  ```

目前允许通过 `--panics:on|off`:option: 在不同方式之间切换，打开时，程序会因恐慌而终结，关闭时，运行时的错误会变为异常。 `--panics:on`:option: 的好处是产生更小的二进制代码，编译器可以更自由地优化。

`unchecked runtime error`:idx: 是不能保证被检测到的错误，它可能导致计算产生任意的后续行为，如果只使用 `safe`:idx: 语言特性，并且没有禁用运行时检查，就不会产生未检查的运行时错误。

`constant expression`:idx: 是表达式，在对包含它的代码进行语义分析时，值就可以被计算出来。它从来不会是左值，也不会有副作用。常量表达式并不局限于语义分析的能力，例如常量折叠。它可以使用所支持的编译时执行的所有Nim语言特性。由于常量表达式可以作为语义分析的输入，比如用于定义数组的边界，因为这种灵活性的要求，编译器交错进行语义分析和编译时代码执行。

想象一下，语义分析在源代码中从上到下、从左到右地进行，而在必要的时候，为了计算后续语义分析所需要的数值，编译时的代码执行交错进行，这一点是非常确切的。我们将在本文的后面看到，宏调用不仅需要这种交错，而且还造成了，语义分析并不完全是自上而下、自左而右地进行的情况。


词法分析

编码
--------

所有的Nim源文件都采用UTF-8编码（或其ASCII子集），不支持其他编码。任何标准平台的行终端序列都可以使用 - Unix形式使用ASCII LF（换行），Windows形式使用ASCII序列CR LF（换行后返回），或旧的Macintosh形式使用ASCII CR（返回）字符，无论在什么平台上，这些形式都可以无差别地使用。


缩进
-----------

Nim的标准语法描述了 `indentation sensitive`:idx: 缩进敏感的语言，这表示所有的控制结构可以通过缩进来识别，缩进只包括空格，不允许使用制表符。

缩进处理的实现方式如下，词法分析器用前导空格数来解释之后的标记，缩进不是单独的一个标记，这个技巧使得解析Nim时只需要向前查看1个token。

语法分析器使用一个缩进级别的堆栈：该堆栈由计算空格的整数组成，语法分析器在对应的策略位置查询缩进信息，但忽略其他地方。伪终端 `IND{>}` 表示缩进比堆栈顶部的条目包含更多的空格， `IND{=}` 表示缩进有相同的空格数，`DED` 是另一个伪终端，表示从堆栈中弹出一个值的 *action* 动作， `IND{>}` 则意味着推到堆栈中。

用这个标记，我们现在可以很容易地定义核心语法：语句块（这是简化的例子）::

  ifStmt = 'if' expr ':' stmt
           (IND{=} 'elif' expr ':' stmt)*
           (IND{=} 'else' ':' stmt)?

  simpleStmt = ifStmt / ...

  stmt = IND{>} stmt ^+ IND{=} DED  # 语句列表
       / simpleStmt                 # 或者单个语句



注释
--------

注释在字符串或字符字面值之外的任何位置，以 `#` 字符开始，注释由 `comment pieces`:idx: 连接组成，一个注释片断以 `#` 开始直到行尾，包括行末的字符。如果下一行只由一个注释片断组成，在它和前面的注释片断之间没有其他标记，就不会开启一个新的注释。


  ```nim
  i = 0     # 这是一个多行注释。
    # 词法分析器将这两部分合并在一起。
    # 注释在这里继续。
  ```


`Documentation comments`:idx: 是以两个 `##` 开头的注释，文档注释是标记，只允许在输入文件的某些地方出现，因为它们属于语法树。


多行注释
------------------

从0.13.0版本的语言开始，Nim支持多行注释。如下：

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

也存在多行文档注释，并且支持嵌套。

  ```nim
  proc foo =
    ##[Long documentation comment
       here.
    ]##
  ```


标识符和关键字
----------------------

Nim中的标识符可以是任何字母、数字和下划线的组成字符串，但有以下限制:

* 以一个字母开头
* 不允许下划线 `_` 结尾
* 不允许两个下划线 `__` 结尾。

  ```
  letter ::= 'A'..'Z' | 'a'..'z' | '\x80'..'\xff'
  digit ::= '0'..'9'
  IDENTIFIER ::= letter ( ['_'] (letter | digit) )*
  ```

目前，任何序数值大于127的Unicode字符（非ASCII）都被归类为字母 `letter` ，因此可以成为标识符的一部分，但以后的语言版本可能会将一些Unicode字符指定为运算符。

以下关键词被保留，不能作为标识符使用:

  ```nim file="keywords.txt"
  ```

有些关键词是未使用的，它们被保留，供语言未来拓展。


标识符相等
-------------------

如果以下算法返回真，则认为两个标识符相等:

  ```nim
  proc sameIdentifier(a, b: string): bool =
    a[0] == b[0] and
      a.replace("_", "").toLowerAscii == b.replace("_", "").toLowerAscii
  ```

这意味着，在进行比较时，只有第一个字母是区分大小写的，其他字母在ASCII范围内不区分大小，下划线被忽略。

这种相当非正统的标识符比较方式被称为 `partial case-insensitivity`:idx: 部分大小写不敏感，比传统的大小写敏感有一些优势。

它允许程序员大多使用他们自己喜欢的拼写风格。不管是humpStyle驼峰风格还是snake_style蛇形风格，不同程序员编写的库不能使用不兼容的约定。一个按Nim思考的编辑器或IDE可以显示首选的标识符，另一个好处是，它使程序员不必记住标识符的准确拼写。对第一个字母的例外，是允许常见的代码如 `var foo: Foo` 这样的普通代码可以被明确地解析出来。

注意这个规则也适用于关键字，也就是说 `notin` 与 `notIn` 和 `not_in` 相同（关键字书写方式首选全小写 (`notin`, `isnot`) ）。

Nim曾经是一种完全 `style-insensitive`:idx: 大小写不敏感的语言，这意味着它不区分大小写，下划线被忽略，甚至 `foo` 和 `Foo` 之间没有区别。


作为标识符的关键词
-----------------------

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
---------------

语法中的终端符号: `STR_LIT`.

字符串可以用配对的双引号来分隔，可以包含以下的 `escape sequences`:idx:\ 转义字符: 

==================         ===================================================
  转义字符                  含义
==================         ===================================================
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
  ``\x`` HH                `character with hex value HH`:idx:; 十进制值HH
                           只允许两个十六进制数字
  ``\u`` HHHH              `unicode codepoint with hex value HHHH`:idx:; 十进制值HHHH
                           只允许四个十六进制数字
  ``\u`` {H+}              `unicode codepoint`:idx:; unicode字码元素
                           包含在 `{}` 中的所有十六进制数字都用于字码元素
==================         ===================================================


Nim中的字符串可以包含任意8-bit值，甚至嵌入零，然而，某此操作可能会将第一个二进制零解释为终止符。


三重引用字符串字面值
-----------------------------

语法中的终端符号: `TRIPLESTR_LIT`.

字符串也可以用三个双引号 `"""` ... `"""` 来分隔，这种形式的字面值支持多行，可以包含 `"` ，并且不解释任何转义序列，为了方便，开头 `"""` 后面换行符以及空格并不包括在字符串中，字符串的结尾定义为 `"""[^"]` 模式，所以如下:

  ```nim
  """"long string within quotes""""
  ```

生成：:

  "long string within quotes"


原始字符串
-------------------

语法中的终端符号: `RSTR_LIT`。

还有一些原始的字符串字面值，前面为字母 `r` 或 `R` ，并匹配一对双引号的普通字符串，不解释转义序列，这用于正则表达式或Windows中的路径特别方便。

  ```nim
  var f = openFile(r"C:\texts\text.txt") # a raw string, so ``\t`` is no tab
  ```

要在原始字符串字面值中含有 `"` 则必须成双。

  ```nim
  r"a""b"
  ```

生成：:

  a"b

不能用 `r""""` 这个标记，因为原始字符串中引入了三引号的字符串字面值。 `r"""` 与 `"""` 是相同的，三引号原始字符串字面值也不解释转义字符。


广义的原始字符串字面值
-------------------------------

语法中的终端符号: `GENERALIZED_STR_LIT`,
`GENERALIZED_TRIPLESTR_LIT`.

构造 `identifier"string literal"`（标识符和开头的引号之间没有空格）是广义的原始字符串字面值。它是构造 `identifier(r"string literal")` 的简洁方式，它表示以原始字符串字面值为唯一参数的常规调用。广义的原始字符串字面值的意义，在于方便的将mini语言直接嵌入到Nim中，例如正则表达式。

 `identifier"""string literal"""` 结构也存在，是 `identifier("""string literal""")`的简洁方式。


字符字面值
------------------

字符串用单引号 `''` 括起来，可以包含与字符串相同的转义字符 - 但有一种例外：不允许与平台有关的 `newline`:idx: (``\p``)，因为它可能比一个字符宽（它可能是一对CR/LF）。下面是有效的 `escape sequences`:idx: 字符字面值。

==================         ===================================================
  转义字符                  含义
==================         ===================================================
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
==================         ===================================================

一个字符不是一个Unicode字符，而是一个单字节。

原由：为了它能够有效地支持 `array[char, int]` 和 `set[char]`。

 `Rune` 类型可以代表任意Unicode字符，`Rune` 声明在 `unicode module <unicode.html>`_ 中。

如果前面有一个回车符，那么不以 `'` 结尾的字符字面值将被解释为 `'` ，此时前面的回车符和字符字面值之间不能有空格，这种特殊情况是为了保证像 ``proc `'customLiteral`(s: string)`` 这样的声明有效。 ``proc `'customLiteral`(s: string)`` 与 ``proc `'\''customLiteral`(s: string)`` 相同。

参考阅读 `custom numeric literals <#custom-numeric-literals>`_ .


数值字面值
----------------

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


从描述中可以看出，数值字面值可以包含下划线，以便于阅读。整数和浮点数可以用十进制（无前缀）、二进制（前缀 `0b`）、八进制（前缀 `0o`）和十六进制（前缀 `0x`）标记表示。

像 `-1` 这样的数值字面值中的一元减号 `-` 是字面值的一部分，这是后来添加到语言中的，原因是表达式 `-128'i8` 应该是有效的。如果没有这种特殊情况，则这将不被允许 -- `128` 不是有效的 `int8` 值，只有 `-128` 是有效的。

对于 `unary_minus` 规则，有一些限制，但在正式语法中没有提及。 `-` 是数值字面值的一部分时，前面的字符必须在 `{' ', '\t', '\n', '\r', ',', ';', '(', '[', '{'}` 集合中，这个设计是为了更合理的方式涵盖大多数情况。

在下面的例子中， `-1` 是一个单独的token标记。

  ```nim
  echo -1
  echo(-1)
  echo [-1]
  echo 3,-1

  "abc";-1
  ```

在下面的例子中， `-1` 被解析为两个独立的token标记（ `-`:tok: `1`:tok:）。

  ```nim
  echo x-1
  echo (int)-1
  echo [a]-1
  "abc"-1
  ```


以撇号('\'')开始的后缀被称为 `type suffix`:idx: 。没有类型后缀的字面值是整数类型，当包含一个点或 `E|e` ，那么它是 `float` 类型。如果字面值的范围在 `low(int32)..high(int32)` ，那么这个整数类型就是 `int` ，否则就是 `int64`。为了记数方便，如果类型后缀明确，那么后缀的撇号是可选的（只有带类型后缀的十六进制浮点数字面值含义才会不明确）。


预定义的类型后缀有：

=================    =========================
  类型后缀            产生的字面值类型
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

自定义数值字面值由名称为 `CUSTOM_NUMERIC_LIT` 的语法规则涵盖。一个自定义的数值字面值是一个单独的token标记。


运算符
---------

Nim允许用户定义运算符。运算符可以是以下字符的任意组合::

       =     +     -     *     /     <     >
       @     $     ~     &     %     |
       !     ?     ^     .     :     \

(语法中使用终端OPR来指代这里定义的运算符符号。）

这些关键字也是运算符:
`and or not xor shl shr div mod in notin is isnot of as from`.

`.`:tok:, `=`:tok:, `:`:tok:, `::`:tok: 不能作为一般运算符使用; 它们的目的是被用于其他符号。

`*:` 是特殊情况处理的两个token标记 `*`:tok: 和 `:`:tok: (为了支持 `var v*: T`)。

`not` 关键字始终是一元运算符, `a not b` 解析为 `a(not b)` , 并不是 `(a) not (b)` 。


其他标记
------------

以下字符串表示其他标记::

    `   (    )     {    }     [    ]    ,  ;   [.    .]  {.   .}  (.  .)  [:


 `slice`:idx: 切片运算符 `..`:tok: 优先于其他包含点的标记： `{..}` 是三个标记 `{`:tok:, `..`:tok:, `}`:tok: 而不是两个标记 `{.`:tok:, `.}`:tok: 。


句法
======

本节列出了Nim的标准句法。语法分析器如何处理缩进的问题已经在 `Lexical Analysis`_ 一节中描述过了。

Nim允许用户定义的运算符。二元运算符有11个不同的优先级。



结合律
-------------

第一个字符为 `^` 的二元运算符是右结合，所有其他二元运算符是左结合。

  ```nim
  proc `^/`(x, y: float): float =
    # 右结合除法运算符
    result = x / y
  echo 12 ^/ 4 ^/ 8 # 24.0 (4 / 8 = 0.5, then 12 / 0.5 = 24.0)
  echo 12  / 4  / 8 # 0.375 (12 / 4 = 3.0, then 3 / 8 = 0.375)
  ```

优先级
----------

一元运算符总是比任何二元运算符结合性更强： `$a + b` 是 `($a) + b` 而不是 `$(a + b)` 。

如果一个一元运算符的第一个字符是 `@` ，它就是一个 `sigil-like`:idx: 运算符，比 `primarySuffix` 的结合性更强： `@x.abc` 被解析为 `(@x).abc` ，而 `$x.abc` 被解析为 `$(x.abc)` 。 


对于不是关键字的二元运算符，优先级由以下规则决定:

以`->`、`~>`或`=>`结尾的运算符被称为 `arrow like`:idx: ，在所有运算符中优先级最低。

如果运算符以 `=` 结尾，并且其第一个字符不是 `<`, `>`, `!`, `=`, `~`, `?` 中的任意一个，那么它就是一个 *赋值运算符* ，具有第二低的优先级。

否则，优先级由第一个字符决定。


================  =======================================================  ==================  ===============
优先级             运算符                                                    第一个字符          终端符号
================  =======================================================  ==================  ===============
 10 (最高)                                                                  `$  ^`             OP10
  9               `*    /    div   mod   shl  shr  %`                      `*  %  \  /`        OP9
  8               `+    -`                                                 `+  -  ~  |`        OP8
  7               `&`                                                      `&`                 OP7
  6               `..`                                                     `.`                 OP6
  5               `==  <= < >= > !=  in notin is isnot not of as from`     `=  <  >  !`        OP5
  4               `and`                                                                        OP4
  3               `or xor`                                                                     OP3
  2                                                                        `@  :  ?`           OP2
  1               *赋值运算符* (如 `+=`, `*=`)                                                  OP1
  0 (最低)        *箭头运算符* (like `->`, `=>`)                                                OP0
================  =======================================================  ==================  ===============


一个运算符是否被用作前缀运算符，也会受到前面的空格影响（这个解析变化是在0.13.0版本中引入的）。

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
------------------

语法中的终端符号: `DOTLIKEOP` 。

点类运算符是以 `.` 开头的运算符，但不是以 `..` 开头的，例如 `.?` ，它们的优先级与 `.` 相同，因此 `a.?b.c` 被解析为 `(a.?b).c` ，而不是 `a.? (b.c)` 。


语法
-------

语法的起始符号是 `module` 。

.. include:: grammar.txt
   :literal:



求值顺序

求值顺序严格从左到右，由内到外，这是大多数其他强类型编程语言的典型做法:

  ```nim  test = "nim c $1"
  var s = ""

  proc p(arg: int): int =
    s.add $arg
    result = arg

  discard p(p(1) + p(2))

  doAssert s == "123"
  ```


赋值也不特殊，左边的表达式在右边的表达式之前被求值。

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


原由：与重载赋值或类似赋值的操作保持一致，`a = b` 可以理解为 `performSomeCopy(a, b)` 。


然而，"求值顺序" 的概念只有在代码被规范化之后才适用。规范化涉及到模板的扩展和参数的重新排序，这些参数已经被传递给了命名参数。

  ```nim  test = "nim c $1"
  var s = ""

  proc p(): int =
    s.add "p"
    result = 5

  proc q(): int =
    s.add "q"
    result = 3

  # 由于模板扩展的语义，求值顺序是'b' 在 'a' 之前。
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


原由：这比设想的替代方案容易实现得多。


常量和常量表达式
==================================

`constant`:idx: 是一个与常量表达式的值绑定的符号。常量表达式被限制为只依赖于以下类别的值和运算，因为这些值和运算要么被内置在语言中，要么在对常量表达式进行语义分析之前被声明和求值。

* 字面值
* 内置运算符
* 先前声明的常量和编译时变量
* 先前声明的宏和模板
* 先前声明的过程，除了可能修改编译时变量外，没有任何副作用

常量表达式可以包含代码块，这些代码块是可以在内部使用编译时支持的所有Nim功能（详见下面的章节）。在这样的代码块中，可以声明变量，随后读取和更新它们，或者声明变量并将它们传递给其修改值的过程。这样的代码块中的代码，仍须遵守上面列出的关于引用该代码块外的值和运算的限制。

访问和修改编译时变量的能力为常量表达式增加了灵活性，这会让那些来自其他静态类型语言的人惊讶。例如，下面的代码在 **编译时** 返回斐波那契数列的起始。(这是对定义常量灵活性的演示，而不是对解决这个问题的推荐风格）。

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
======================================

编译时执行的Nim代码不能使用以下语言特性:

* methods 方法
* closure iterators 闭包迭代器 
* `cast` 运算符
* 引用 (指针) 类型
* FFI

不允许使用 FFI 和/或 `cast` 的包装器。请注意，这些包装器包括标准库中的包装器。

随着时间的推移，部分或所有这些限制可能会被取消。


类型
=====

在语义分析中是已知的，所有的表达式都有一个类型。Nim是静态类型语言。可以声明新的类型，这实质上是定义了一个标识符，用来表示这个自定义类型。

这些是主要的类型分类:

* 序数类型（包括整数、布尔、字符、枚举、枚举子范围）。
* 浮点类型
* 字符串类型
* 结构化类型
* 引用（指针）类型
* 过程类型
* 通用类型


序数类型
序数类型有以下特征：

- 序数类型是可数和有序的。这种属性允许使用如`inc`, `ord`, `dec` 等函数来操作已定义的序数类型
- 序数类型具有最小可能值，可以通过`low(type)`获取。
  尝试从最小值继续减小会产生panic或静态错误。
- 序数值具有最大可能值，可以通过`high(type)`获取。
  尝试从最大值继续增大会产生panic或静态错误。

整数，bool，字符和枚举类型（以及这些类型的子范围）属于序数类型。

如果基类型是序数类型，则distinct类型是序数类型。


预定义整数类型
这些整数类型是预定义的：

`int`
  通用有符号整数类型。它的大小取决于平台，并且与指针大小相同。如果一个类型后缀的数的字面值在`low(int32)..high(int32)`范围内，则它是这种类型，否则它的类型就是`int64`.

`int`\ XX
  使用XX位额外标记的有符号整数使用这种命名。（比如int16是16位宽整数）当前实现的支持有`int8`, `int16`, `int32`, `int64`。这些类型的字面值后缀为'iXX。

`uint`
  通用的 `无符号整型` 。它的大小取决于平台，并且与指针大小相同。 类型后缀为`'u`的整数字面值就是这种类型。

`uint`\ XX
  使用XX位额外标记的无符号整数使用这种命名。（比如uint16是16位宽的无符号整数）当前实现的支持有`uint8`, `uint16`, `uint32`, `uint64`。这些类型的字面值具有后缀 'uXX 。 无符号操作被全面封装; 不会导致上溢或下溢。


除了有符号和无符号整数的常用算术运算符(`+ - *`等)之外， 还有些操作符可以处理*有符号*整数但将他们的参数视为*无符号*: 它们主要用于之后的版本与缺少无符号整数类型的旧版本语言进行兼容。 有符号整数的这些无符号运算约定使用 `%` 作为后缀:


======================   ======================================================
操作符                    含义
======================   ======================================================
`a +% b`                 无符号整型加法
`a -% b`                 无符号整型减法
`a *% b`                 无符号整型乘法
`a /% b`                 无符号整型除法
`a %% b`                 无符号整型取模
`a <% b`                 无符号比较`a`与`b`
`a <=% b`                无符号比较`a`与`b`
`ze(a)`                  用零填充 `a` 的位，直到它具有 `int`类型的宽度
`toU8(a)`                将`a`视为无符号数值，并将它转成8位无符号整数（但仍是`int8`类型）
`toU16(a)`               将`a`视为无符号数值，并将它转成8位无符号整数（但仍是`int16`类型）
`toU32(a)`               将`a`视为无符号数值，并将它转成8位无符号整数（但仍是`int32`类型）
======================   ======================================================

`自动类型转换`会在使用不同类型的整型的表达式中执行：较小的类型转换为较大的类型。

`缩小类型转换`将较大的类型转换为较小的类型。(比如`int32 -> int16`) `扩展类型转换`将较小的类型转换为较大的类型。（比如`int16 -> int32`) Nim中只有扩展类型转型是 *隐式的*:

  ```nim
  var myInt16 = 5i16
  var myInt: int
  myInt16 + 34     # 为`int16`类型
  myInt16 + myInt  # 为`int`类型
  myInt16 + 2i32   # 为`int32`类型
  ```

然而，如果字面值适合这个较小的类型并且这样的转换比其他隐式转换更好，那么`int`字面值可以隐式转换为较小的整数类型。因而`myInt16 + 34` 结果是`int16`类型。

有关详细信息，请参阅`Convertible relation
<#type-relations-convertible-relation>`_.


子范围类型
--------------
子范围类型是序数或浮点类型（基本类型）的值范围。
要定义子范围类型，必须指定其限制值，即类型的最低值和最高值。例如：

  ```nim
  type
    Subrange = range[0..5]
    PositiveFloat = range[0.0..Inf]
    Positive* = range[1..high(int)] # 正如`system`里定义的一样
  ```


`Subrange` 是整数的子范围，只能保存0到5的值。`PositiveFloat` 定义了包含所有正浮点数的子范围。NaN不属于任何浮点类型的子范围。将任何其他值分配给类型为`Subrange`会产生panic（如果可以在语义分析期间确定，则为静态错误）。允许从基本类型到其子类型之一的分配，反之亦然。

子范围类型与其基类型具有相同的大小（子范围示例中的`int` ）。


预定义浮点类型
--------------------------------

以下浮点类型是预定义的：

`float`
  通用浮点类型;它的大小曾经是平台相关的，但现在它总是映射到 `float64` 。一般应该使用这种类型。

`float`\ XX
  使用XX位额外标记的浮点数可以使用这种命名。（例如：`float64`是64位宽的浮点数）当前支持`float32`和`float64`。 这些类型的字面值具有后缀 'fXX。


可以在具有不同类型浮点数的表达式中执行自动类型转换：详见`Convertible relation
<#type-relations-convertible-relation>`_ 。 在浮点类型上执行的算术遵循IEEE标准。 整数类型不会自动转换为浮点类型，反之亦然。

IEEE标准定义了五种类型的浮点异常：

* 无效: 使用数学上无效的操作数的操作, 例如 0.0/0.0, sqrt(-1.0), 和log(-37.8).
* 除以零：除数为零，且被除数是有限的非零数，例如1.0 / 0.0。
* 溢出：操作产生的结果超出范围，例如MAXDOUBLE + 0.0000000000001e308。
* 下溢：操作产生的结果太小而无法表示为正常数字，例如，MINDOUBLE * MINDOUBLE。
* 不精确：操作产生的结果无法用无限精度表示，例如，输入中的2.0 / 3.0，log(1.1)和0.1。

IEEE异常在执行期间被忽略或映射到Nim异常: `FloatInvalidOpDefect`, `FloatDivByZeroDefect`, `FloatOverflowDefect`, `FloatUnderflowDefect`, 和 `FloatInexactDefect` 。 这些异常继承自 `FloatingPointDefect` 基类。

Nim提供了编译指示 `nanChecks`和`infChecks`控制是否忽略IEEE异常或捕获Nim异常：

  ```nim
  {.nanChecks: on, infChecks: on.}
  var a = 1.0
  var b = 0.0
  echo b / b # 引发 FloatInvalidOpDefect
  echo a / b # 引发 FloatOverflowDefect
  ```

在当前的实现中， `FloatDivByZeroError` 和 `FloatInexactError` 永远不会被引发。 `FloatOverflowError` 取代了 `FloatDivByZeroError` 。 另有 floatChecks 编译指示用作 `nanChecks` 和 `infChecks` 的快捷方式。 `floatChecks` 默认关闭。

只有 `+`, `-`, `*`, `/` 这些操作符受`floatChecks`编译指示影响

在语义分析期间，应始终使用最大精度来评估浮点指针值。这表示在常量展开期间，表达式`0.09'f32 + 0.01'f32 == 0.09'f64 + 0.01'f64` 求值为真。


布尔类型
------------
布尔类型在Nim中命名为 `bool` 并且可以是两个预定义值(`true`和`false`)之一。`while`,`if`, `elif`, `when`中的语句应为`bool`类型.

这种情况成立:

  ord(false) == 0 and ord(true) == 1

The operators `not, and, or, xor, <, <=, >, >=, !=, ==` are defined
for the bool type. The `and` and `or` operators perform short-cut
evaluation. 示例：

  ```nim
  while p != nil and p.name != "xyz":
    # 如果 p == nil， p.name不被求值
    p = p.next
  ```


bool类型的大小是一个字节。


字符类型
--------------
字符类型在Nim中被命名为`char`。它的大小为一个字节。因此，它不能表示UTF-8字符，而只能是UTF-8字符的一部分。

`Rune` 类型用于Unicode字符，它可以表示任何Unicode字符。`Rune` 在 `unicode module <unicode.html>`_ 中声明。




枚举类型
-----------------
Enumeration types define a new type whose values consist of the ones
specified. The values are ordered. 示例：

  ```nim
  type
    Direction = enum
      north, east, south, west
  ```


现在以下内容成立:

  ord(north) == 0
  ord(east) == 1
  ord(south) == 2
  ord(west) == 3

  # 也允许:
  ord(Direction.west) == 3

由此可得，north < east < south < west。比较运算符可以与枚举类型一起使用。枚举值也可以使用它所在的枚举类型来限定，如`north`可以用`Direction.nort`来限定。

为了更好地与其他编程语言连接，可以为枚举类型的字段分配显式序数值。 但是，序数值必须升序排列。 未明确给出序数值的字段被赋予前一个字段+ 1的值。

显式有序枚举可以有*间隔*：

  ```nim
  type
    TokenType = enum
      a = 2, b = 4, c = 89 # 可以有间隔
  ```

但是，它不再是序数，因此不可能将这些枚举用作数组的索引类型。 过程`inc`, `dec`, `succ`和`pred`对于它们不可用。


编译器支持枚举的内置字符串化运算符`$`。 字符串化的结果可以通过显式给出要使用的字符串值来控制：

  ```nim
  type
    MyEnum = enum
      valueA = (0, "my value A"),
      valueB = "value B",
      valueC = 2,
      valueD = (3, "abc")
  ```

从示例中可以看出，可以通过使用元组指定字段的序数值及其字符串值。 也可以只指定其中一个。

枚举可以使用 `pure`编译指示进行标记，以便将其字段添加到特定模块特定的隐藏作用域，该作用域仅作为最后一次尝试进行查询。 只有没有歧义的符号才会添加到此范围。 但总是可以通过写为`MyEnum.value`的类型限定来访问:

  ```nim
  type
    MyEnum {.pure.} = enum
      valueA, valueB, valueC, valueD, amb

    OtherEnum {.pure.} = enum
      valueX, valueY, valueZ, amb


  echo valueA # MyEnum.valueA
  echo amb    # 错误：不清楚它是MyEnum.amb还是OtherEnum.amb
  echo MyEnum.amb # OK.
  ```

要使用枚举实现位字段，请参阅`Bit fields <#set-type-bit-fields>`_


字符串类型
-----------
所有字符串字面值都是`string`类型。 Nim中的字符串与字符序列非常相似。 但是，Nim中的字符串都是以零结尾的并且具有长度字段。 可以用内置的`len`过程检索长度;长度永远不会计算末尾的零。

除非首先将字符串转换为 `cstring` 类型，否则无法访问末尾的零。末尾的零确保可以在O(1)中完成此转换，无需任何分配。

字符串的赋值运算符始终复制字符串。`&` 运算符拼接字符串。

大多数原生Nim类型支持使用特殊的`$`过程转换为字符串。

  ```nim
  echo 3 # 为 `int` 调用 `$`
  ```

每当用户创建一个特定的对象时，该过程的实现提供了`string`表示。

  ```nim
  type
    Person = object
      name: string
      age: int

  proc `$`(p: Person): string = # `$` 始终返回字符串
    result = p.name & "已经" &
            $p.age & # 需要在p.age前添加`$`，因为它是整数类型，而我们要将其转换成字符串
            "岁了。"
  ```

虽然也可以使用`$p.name`，但`$`操作符不会对字符串做任何事情。 请注意，我们不能依赖于从 `int` 到 `string`  的像`echo`过程一样自动转换。

字符串按字典顺序进行比较。 所有比较运算符都可用。 字符串可以像数组一样索引（下限为0）。 与数组不同，字符串可用于case语句：

  ```nim
  case paramStr(i)
  of "-v": incl(options, optVerbose)
  of "-h", "-?": incl(options, optHelp)
  else: write(stdout, "非法的命令行选项\n")
  ```

按照惯例，所有字符串都是UTF-8字符串，但不强制执行。 例如，从二进制文件读取字符串时，它们只是一个字节序列。 索引操作`s[i]`表示 s 的第i个 char ，而不是第i个 unichar 。 来自 `unicode module <unicode.html>`_  的迭代器`runes`可用于迭代所有Unicode字符。


cstring类型

`cstring` 类型意味着 `compatible string` ，是编译后端的字符串的原生表示。 对于C后端，`cstring` 类型表示一个指向末尾为零的char数组的指针，该数组与ANSI C中的 `char*` 类型兼容。 其主要目的在于与C轻松互通。 索引操作 `s[i]` 表示 s 的第i个 *char*;但是没有执行检查 cstring 的边界，导致索引操作并不安全。

为方便起见，Nim中的 `string` 可以隐式转换为 `cstring` 。 如果将Nim字符串传递给C风格的可变参数过程，它也会隐式转换为 `cstring` ：

  ```nim
  proc printf(formatstr: cstring) {.importc: "printf", varargs,
                                    header: "<stdio.h>".}

  printf("这会%s工作", "像预期一样")
  ```

即使转换是隐式的，它也不是*安全的* ：垃圾收集器不认为 `cstring` 是根，并且可能收集底层内存。 因此，隐式转换将在Nim编译器的未来版本中删除。某些习语，例如将`const`字符串转换为`cstring`，是安全的，并且仍将被允许。

为cstring定义的`$`过程能够返回string。因此，从cstring获取nim的string可以这样：

  ```nim
  var str: string = "Hello!"
  var cstr: cstring = str
  var newstr: string = $cstr
  ```

`cstring`不应被逐字修改。

  ```nim
  var x = cstring"literals"
  x[1] = 'A' # 这是错的！！！
  ```

如果`cstring`来自常规内存（而不是只读内存），则可以被逐字修改。

  ```nim
  var x = "123456"
  var s: cstring = x
  s[0] = 'u' # 这是可以的
  ```

结构化类型
----------------
结构化类型的变量可以同时保存多个值。 结构化类型可以嵌套到无限级别。数组、序列、元组、对象和集合属于结构化类型。

数组和序列类型
------------------------
数组是同类型的，这意味着数组中的每个元素都具有相同的类型。 数组总是具有指定为常量表达式的固定长度（开放数组除外）。 它们可以按任何序数类型索引。 若参数 `A` 是*开放数组* ，那么它的索引为由0到 len（A）- 1 的整数。 数组表达式可以由数组构造器 `[]` 构造。 数组表达式的元素类型是从第一个元素的类型推断出来的。 所有其他元素都需要隐式转换为此类型。

可以使用`array[大小，类型]`构造数组类型，也可以使用`array[小..大,类型]`设置数组的起点而不是默认的0。

序列类似于数组，但有动态长度，其长度可能在运行时期间发生变化（如字符串）。 序列实现为可增长的数组，在添加项目时分配内存块。 序列 `S` 的索引为从0到 `len(S)-1`的整数，并检查其边界。 序列可以在序列运算符`@`的帮助下，由数组构造器 `[]` 和数组一起构造。为序列分配空间的另一种方法是调用内置的 `newSeq` 过程。

序列可以传递给*开放数组*类型的参数

示例：

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

数组或序列的下限可以用内置的过程`low()`获取，上限用`high()`获取。 长度可以用`len()`获取。序列或开放数组的 `low()` 总是返回0，因为这是第一个有效索引。 可以使用 `add()` 过程或 `&` 运算符将元素追加到序列中，并使用 `pop()` 过程删除（并获取）序列的最后一个元素。

符号 `x[i]` 可用于访问 `x` 的第i个元素。

数组始终是边界检查的（静态或运行时）。可以通过编译指示禁用这些检查，或使用 `--boundChecks：off` 命令行开关调用编译器。

数组构造器可以具有可读的显式索引：

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

如果省略索引，则使用 `succ(lastIndex)` 作为索引值：

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
-----------

通常，固定大小的数组太不灵活了;程序应该能够处理不同大小的数组。 `开放数组` 类型只能用于参数。 开放数组总是从位置0开始用 `int`索引。 `len`，`low`和`high`操作也可用于开放数组。 具有兼容基类型的任何数组都可以传递给开放数组形参，无关索引类型。 除了数组之外，还可以将序列传递给开放数组参数。

`开放数组`类型不能嵌套： 不支持多维开放数组，因为这种需求很少并且不能有效地完成。

  ```nim
  proc testOpenArray(x: openArray[int]) = echo repr(x)

  testOpenArray([1,2,3])  # array[]
  testOpenArray(@[1,2,3]) # seq[]
  ```

可变参数
-------

`varargs` 参数是一个开放数组参数，它允许将可变数量的参数传递给过程。 编译器隐式地将参数列表转换为数组：

  ```nim
  proc myWriteln(f: File, a: varargs[string]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, "abc", "def", "xyz")
  # 转换成：
  myWriteln(stdout, ["abc", "def", "xyz"])
  ```

仅当`varargs`参数是的最后一个参数时，才会执行此转换。 也可以在此上下文中执行类型转换：

  ```nim
  proc myWriteln(f: File, a: varargs[string, `$`]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, 123, "abc", 4.0)
  # 转换成：
  myWriteln(stdout, [$123, $"abc", $4.0])
  ```

在这个例子中， `$`应用于传递给参数 `a` 的任何参数。 （注意 $ 对字符串是一个空操作。）

请注意，传递给 `varargs` 形参的显式数组构造器不会隐式地构造另一个隐式数组：

  ```nim
  proc takeV[T](a: varargs[T]) = discard

  takeV([123, 2, 1]) # takeV的T是"int", 不是"int数组"
  ```


`varargs[typed]` 被特别对待：它匹配任意类型的参数的变量列表，但*始终*构造一个隐式数组。这是必需的，因而内置的 `echo` 过程能够执行预期的操作：

  ```nim
  proc echo*(x: varargs[typed, `$`]) {...}

  echo @[1, 2, 3]
  # 输出 "@[1, 2, 3]" 而不是 "123"
  ```


未检查数组
----------------
`UncheckedArray[T]`类型是一种特殊的 `数组` ，编译器不检查它的边界。 这对于实现定制灵活大小的数组通常很有用。 另外，未检查数组可以这样转换为不确定大小的C数组：

  ```nim
  type
    MySeq = object
      len, cap: int
      data: UncheckedArray[int]
  ```

生成的C代码大致是这样的：

  ```C
  typedef struct {
    NI len;
    NI cap;
    NI data[];
  } MySeq;
  ```

未检查数组的基本类型可能不包含任何GC内存，但目前尚未核实。

**未来方向**: 应该在未经检查的数组中允许GC内存，并且应该有一个关于GC如何确定数组的运行时大小的显式注释。



元组和对象类型
-----------------------
元组或对象类型的变量是异构存储容器。 元组或对象定义了一个类型的各种*字段*。 元组还定义了字段的*顺序*。 元组是有很少抽象可能性的异构存储类型。 `()` 可用于构造元组。 构造函数中字段的顺序必须与元组定义的顺序相匹配。 如果它们以相同的顺序指定相同类型的相同字段，则不同的元组类型*等效* 。字段的*名称*也必须相同。

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

可以使用括号和尾随逗号构造具有一个未命名字段的元组：

  ```nim
  proc echoUnaryTuple(a: (int,)) =
    echo a[0]

  echoUnaryTuple (1,)
  ```


事实上，每个元组结构都允许使用尾随逗号。

字段将会对齐，以此获得最佳性能。对齐与C编译器的方式兼容。

为了与`object`声明保持一致， `type` 部分中的元组也可以用缩进而不是 `[]` 来定义：

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
      name*: string   # *表示可以从其他模块访问`name`
      age: int        # 没有*表示该字段已隐藏

    Student = ref object of Person # 学生是人
      id: int                      # 有个id字段

  var
    student: Student
    person: Person
  assert(student of Student) # 是真
  assert(student of Person) # 也是真
  ```

对模块外部可见的对象字段必须用 `*` 标记。与元组相反，不同的对象类型永远不会 *等价* 。 没有祖先的对象是隐式的 `final` ，因此没有隐藏的类型字段。 可以使用 `inheritable` 编译指示来引入除`system.RootObj`之外的新根对象。

  ```nim
  type
    Person = object # final 对象的例子
      name*: string
      age: int

    Student = ref object of Person # 错误: 继承只能用于非final对象
      id: int
  ```

元组和对象的赋值操作符复制每个组件。` 这里<manual.html#procedures-type-bound-operations>`_ 描述了覆盖这种复制行为的方法。


对象构造
-------------------

对象也可以使用`对象构造表达式`创建, 即以下语法 `T(fieldA: valueA, fieldB: valueB, ...)` 其中 `T` 是 `object` 类型或 `ref object` 类型：

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
---------------
在需要简单变体类型的某些情况下，对象层次结构通常有点过了。 对象变体是通过用于运行时类型灵活性的枚举类型区分的标记联合，对照如在其他语言中找到的 *sum类型* 和 *代数数据类型(ADTs)* 的概念。

一个例子：

  ```nim
  # 这是一个如何在Nim中建模抽象语法树的示例
  type
    NodeKind = enum  # 不同的节点类型
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

  # 以下语句引发了一个 `FieldError` 异常，因为n.kind的值不合适且 `nkString` 分支未激活：
  n.strVal = ""

  # 无效：会更改活动对象分支：
  n.kind = nkInt

  var x = Node(kind: nkAdd, leftOp: Node(kind: nkInt, intVal: 4),
                            rightOp: Node(kind: nkInt, intVal: 2))
  # 有效：不更改活动对象分支：
  x.kind = nkSub
  ```

从示例中可以看出，对象层次结构的优点是不需要在不同对象类型之间进行转换。 但是，访问无效对象字段会引发异常。

在对象声明中的`case`语句和标准`case`语句语法一致：`case`语句的分支也是如此

在示例中， `kind` 字段称为 `鉴别字段` : 为安全起见，不能对其进行地址限制，并且对其赋值进行限制：新值不得导致活动对象分支发生变化。 此外，在对象构造期间指定特定分支的字段时，必须将相应的鉴别字段值指定为常量表达式。

与改变活动的对象分支不同，将内存中的旧对象换成一个全新的对象是可以的。

  ```nim
  var x = Node(kind: nkAdd, leftOp: Node(kind: nkInt, intVal: 4),
                            rightOp: Node(kind: nkInt, intVal: 2))
  # 改变节点的内容
  x[] = NodeObj(kind: nkString, strVal: "abc")
  ```


从版本0.20开始 `system.reset` 不能再用于支持对象分支的更改，因为这从来就不是完全内存安全的。

作为一项特殊规则，鉴别字段类型也可以使用 `case` 语句来限制。 如果 `case` 语句分支中的鉴别字段变量的可能值是所选对象分支的鉴别字段值的子集，则初始化被认为是有效的。 此分析仅适用于序数类型的不可变判别符，并忽略 `elif` 分支。对于具有`range`类型的鉴别器值，编译器会检查鉴别器值的整个可能值范围是否对所选对象分支有效。

一个小例子：

  ```nim
  let unknownKind = nkSub

  # 无效：不安全的初始化，因为类型字段不是静态已知的：
  var y = Node(kind: unknownKind, strVal: "y")

  var z = Node()
  case unknownKind
  of nkAdd, nkSub:
    # 有效：此分支的可能值是nkAdd / nkSub对象分支的子集：
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
      case kind*: TokenKind
      of strLit:
        s*: string
      of intLit:
        i*: int64

  proc passToVar(x: var TokenKind) = discard

  var t = Token(kind: strLit, s: "abc")

  {.cast(uncheckedAssign).}:
    # 在 'cast' 块中允许将't.kind'传递给 'var T' 参数：
    passToVar(t.kind)

    # 在 'cast' 块中允许设置字段`s`,即便构造的`kind`字段有未知的值
    t = Token(kind: t.kind, s: "abc")

    # 在 'cast' 块中允许直接分配't.kind'字段
    t.kind = intLit
  ```


集合类型

.. include:: sets_fragment.txt

引用和指针类型
---------------------------
引用（类似于其他编程语言中的指针）是引入多对一关系的一种方式。 这意味着不同的引用可以指向并修改内存中的相同位置（也称为 `别名` )。

Nim区分 `追踪`和 `未追踪` 引用。 未追踪引用也叫 *指针* 。 追踪引用指向垃圾回收堆中的对象，未追踪引用指向手动分配对象或内存中其它位置的对象。 因此，未追踪引用是*不安全* 的。 然而对于某些访问硬件的低级操作，未追踪引用是不可避免的。

使用**ref**关键字声明追踪引用，使用**ptr**关键字声明未追踪引用。 通常， `ptr T` 可以隐式转换为`pointer` 类型。

空的下标 `[]` 表示法可以用来取代引用， `addr` 过程返回一个对象的地址。 地址始终是未追踪的引用。 因此， `addr` 的使用是 *不安全的* 功能。

`.`（访问元组和对象字段运算符）和 `[]`（数组/字符串/序列索引运算符）运算符对引用类型执行隐式解引用操作：

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
  # 不必写n[].data; 实际上 n[].data是非常不推荐的！
  ```

可以对例程调用的第一个参数执行自动取消引用，但这是一个实验性功能，在`here<manual_experimental.html#automatic-dereferencing>`_进行了说明。

为了简化结构类型检查，递归元组无效：

  ```nim
  # 无效递归
  type MyTuple = tuple[a: ref MyTuple]
  ```

同样， `T = ref T` 是无效类型。

作为语法扩展，如果在类型部分中通过 `ref object` 或 `ptr object` 符号声明，则`object` 类型可以是匿名的。 如果对象只应获取引用语义，则此功能非常有用：

  ```nim
  type
    Node = ref object
      le, ri: Node
      data: int
  ```


要分配新的追踪对象，必须使用内置过程 `new` 。 为了处理未追踪的内存，可以使用过程 `alloc` ， `dealloc` 和 `realloc` 。 系统模块的文档包含更多信息。


空(Nil)
---

如果一个引用什么都不指向，那么它的值为`nil`。`nil` 是所有 `ref` 和 `ptr` 类型的默认值。`nil` 值也可以像任何其他字面值一样使用。例如，它可以用在像 `my Ref = nil` 这样的赋值中。

取消引用 `nil` 是一个不可恢复的致命运行时错误（而不是panic）。

成功的解引用操作 `p[]` 意味着 `p` 不是 nil。可以利用它来优化代码，例如：

  ```nim
  p[].field = 3
  if p != nil:
    # 如果p是nil, 那么 `p[]` 会导致错误
    # 所以我们知道这里`p`永远不会是nil
    action()
  ```

那么上述代码可以变成：

  ```nim
  p[].field = 3
  action()
  ```


*注意*：这与 C 用于取消引用 NULL 指针的“未定义行为”不具有可比性。


Mixing GC'ed memory with `ptr`
--------------------------------

Special care has to be taken if an untraced object contains traced objects like
traced references, strings, or sequences: in order to free everything properly,
the built-in procedure `reset` has to be called before freeing the untraced
memory manually:

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

Without the `reset` call the memory allocated for the `d.s` string would
never be freed. The example also demonstrates two important features for
low-level programming: the `sizeof` proc returns the size of a type or value
in bytes. The `cast` operator can circumvent the type system: the compiler
is forced to treat the result of the `alloc0` call (which returns an untyped
pointer) as if it would have the type `ptr Data`. Casting should only be
done if it is unavoidable: it breaks type safety and bugs can lead to
mysterious crashes.

**Note**: The example only works because the memory is initialized to zero
(`alloc0` instead of `alloc` does this): `d.s` is thus initialized to
binary zero which the string assignment can handle. One needs to know low-level
details like this when mixing garbage-collected data with unmanaged memory.

.. XXX finalizers for traced objects


Procedural type
---------------
A procedural type is internally a pointer to a procedure. `nil` is
an allowed value for a variable of a procedural type.

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


A subtle issue with procedural types is that the calling convention of the
procedure influences the type compatibility: procedural types are only
compatible if they have the same calling convention. As a special extension,
a procedure of the calling convention `nimcall` can be passed to a parameter
that expects a proc of the calling convention `closure`.

Nim supports these `calling conventions`:idx:\:

`nimcall`:idx:
    is the default convention used for a Nim **proc**. It is the
    same as `fastcall`, but only for C compilers that support `fastcall`.

`closure`:idx:
    is the default calling convention for a **procedural type** that lacks
    any pragma annotations. It indicates that the procedure has a hidden
    implicit parameter (an *environment*). Proc vars that have the calling
    convention `closure` take up two machine words: One for the proc pointer
    and another one for the pointer to implicitly passed environment.

`stdcall`:idx:
    This is the stdcall convention as specified by Microsoft. The generated C
    procedure is declared with the `__stdcall` keyword.

`cdecl`:idx:
    The cdecl convention means that a procedure shall use the same convention
    as the C compiler. Under Windows the generated C procedure is declared with
    the `__cdecl` keyword.

`safecall`:idx:
    This is the safecall convention as specified by Microsoft. The generated C
    procedure is declared with the `__safecall` keyword. The word *safe*
    refers to the fact that all hardware registers shall be pushed to the
    hardware stack.

`inline`:idx:
    The inline convention means the caller should not call the procedure,
    but inline its code directly. Note that Nim does not inline, but leaves
    this to the C compiler; it generates `__inline` procedures. This is
    only a hint for the compiler: it may completely ignore it, and
    it may inline procedures that are not marked as `inline`.

`fastcall`:idx:
    Fastcall means different things to different C compilers. One gets whatever
    the C `__fastcall` means.

`thiscall`:idx:
    This is the thiscall calling convention as specified by Microsoft, used on
    C++ class member functions on the x86 architecture.

`syscall`:idx:
    The syscall convention is the same as `__syscall`:c: in C. It is used for
    interrupts.

`noconv`:idx:
    The generated C code will not have any explicit calling convention and thus
    use the C compiler's default calling convention. This is needed because
    Nim's default calling convention for procedures is `fastcall` to
    improve speed.

Most calling conventions exist only for the Windows 32-bit platform.

The default calling convention is `nimcall`, unless it is an inner proc (a
proc inside of a proc). For an inner proc an analysis is performed whether it
accesses its environment. If it does so, it has the calling convention
`closure`, otherwise it has the calling convention `nimcall`.


Distinct type
-------------

A `distinct` type is a new type derived from a `base type`:idx: that is
incompatible with its base type. In particular, it is an essential property
of a distinct type that it **does not** imply a subtype relation between it
and its base type. Explicit type conversions from a distinct type to its
base type and vice versa are allowed. See also `distinctBase` to get the
reverse operation.

如果基类型是序数类型，则distinct类型是序数类型。


### Modeling currencies

A distinct type can be used to model different physical `units`:idx: with a
numerical base type, for example. The following example models currencies.

Different currencies should not be mixed in monetary calculations. Distinct
types are a perfect tool to model different currencies:

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

Unfortunately, `d + 12.Dollar` is not allowed either,
because `+` is defined for `int` (among others), not for `Dollar`. So
a `+` for dollars needs to be defined:

  ```nim
  proc `+` (x, y: Dollar): Dollar =
    result = Dollar(int(x) + int(y))
  ```

It does not make sense to multiply a dollar with a dollar, but with a
number without unit; and the same holds for division:

  ```nim
  proc `*` (x: Dollar, y: int): Dollar =
    result = Dollar(int(x) * y)

  proc `*` (x: int, y: Dollar): Dollar =
    result = Dollar(x * int(y))

  proc `div` ...
  ```

This quickly gets tedious. The implementations are trivial and the compiler
should not generate all this code only to optimize it away later - after all
`+` for dollars should produce the same binary code as `+` for ints.
The pragma `borrow`:idx: has been designed to solve this problem; in principle,
it generates the above trivial implementations:

  ```nim
  proc `*` (x: Dollar, y: int): Dollar {.borrow.}
  proc `*` (x: int, y: Dollar): Dollar {.borrow.}
  proc `div` (x: Dollar, y: int): Dollar {.borrow.}
  ```

The `borrow` pragma makes the compiler use the same implementation as
the proc that deals with the distinct type's base type, so no code is
generated.

But it seems all this boilerplate code needs to be repeated for the `Euro`
currency. This can be solved with templates_.

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


The borrow pragma can also be used to annotate the distinct type to allow
certain builtin operations to be lifted:

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

Currently, only the dot accessor can be borrowed in this way.


### Avoiding SQL injection attacks

An SQL statement that is passed from Nim to an SQL database might be
modeled as a string. However, using string templates and filling in the
values is vulnerable to the famous `SQL injection attack`:idx:\:

  ```nim
  import std/strutils

  proc query(db: DbHandle, statement: string) = ...

  var
    username: string

  db.query("SELECT FROM users WHERE name = '$1'" % username)
  # Horrible security hole, but the compiler does not mind!
  ```

This can be avoided by distinguishing strings that contain SQL from strings
that don't. Distinct types provide a means to introduce a new string type
`SQL` that is incompatible with `string`:

  ```nim
  type
    SQL = distinct string

  proc query(db: DbHandle, statement: SQL) = ...

  var
    username: string

  db.query("SELECT FROM users WHERE name = '$1'" % username)
  # Static error: `query` expects an SQL string!
  ```


It is an essential property of abstract types that they **do not** imply a
subtype relation between the abstract type and its base type. Explicit type
conversions from `string` to `SQL` are allowed:

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

Now we have compile-time checking against SQL injection attacks. Since
`"".SQL` is transformed to `SQL("")` no new syntax is needed for nice
looking `SQL` string literals. The hypothetical `SQL` type actually
exists in the library as the `SqlQuery type <db_common.html#SqlQuery>`_ of
modules like `db_sqlite <db_sqlite.html>`_.


Auto type
---------

The `auto` type can only be used for return types and parameters. For return
types it causes the compiler to infer the type from the routine body:

  ```nim
  proc returnsInt(): auto = 1984
  ```

For parameters it currently creates implicitly generic routines:

  ```nim
  proc foo(a, b: auto) = discard
  ```

Is the same as:

  ```nim
  proc foo[T1, T2](a: T1, b: T2) = discard
  ```

However, later versions of the language might change this to mean "infer the
parameters' types from the body". Then the above `foo` would be rejected as
the parameters' types can not be inferred from an empty `discard` statement.


Type relations
==============

The following section defines several relations on types that are needed to
describe the type checking done by the compiler.


Type equality
-------------

Nim uses structural type equivalence for most types. Only for objects,
enumerations and distinct types and for generic types name equivalence is used.


Subtype relation
----------------

If object `a` inherits from `b`, `a` is a subtype of `b`.

This subtype relation is extended to the types `var`, `ref`, `ptr`.
If `A` is a subtype of `B` and `A` and `B` are `object` types then:

- `var A` is a subtype of `var B`
- `ref A` is a subtype of `ref B`
- `ptr A` is a subtype of `ptr B`.

**Note**: In later versions of the language the subtype relation might
be changed to *require* the pointer indirection in order to prevent
"object slicing".


Convertible relation
--------------------

A type `a` is **implicitly** convertible to type `b` iff the following
algorithm returns true:

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

We used the predicate `typeEquals(a, b)` for the "type equality" property
and the predicate `isSubtype(a, b)` for the "subtype relation".
`compatibleParametersAndEffects(a, b)` is currently not specified.

Implicit conversions are also performed for Nim's `range` type
constructor.

Let `a0`, `b0` of type `T`.

Let `A = range[a0..b0]` be the argument's type, `F` the formal
parameter's type. Then an implicit conversion from `A` to `F`
exists if `a0 >= low(F) and b0 <= high(F)` and both `T` and `F`
are signed integers or if both are unsigned integers.


A type `a` is **explicitly** convertible to type `b` iff the following
algorithm returns true:

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

The convertible relation can be relaxed by a user-defined type
`converter`:idx:.

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

The type conversion `T(a)` is an L-value if `a` is an L-value and
`typeEqualsOrDistinct(T, typeof(a))` holds.


Assignment compatibility
------------------------

An expression `b` can be assigned to an expression `a` iff `a` is an
`l-value` and `isImplicitlyConvertible(b.typ, a.typ)` holds.


Overload resolution
===================

In a call `p(args)` the routine `p` that matches best is selected. If
multiple routines match equally well, the ambiguity is reported during
semantic analysis.

Every arg in args needs to match. There are multiple different categories how an
argument can match. Let `f` be the formal parameter's type and `a` the type
of the argument.

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

These matching categories have a priority: An exact match is better than a
literal match and that is better than a generic match etc. In the following,
`count(p, m)` counts the number of matches of the matching category `m`
for the routine `p`.

A routine `p` matches better than a routine `q` if the following
algorithm returns true::

  for each matching category m in ["exact match", "literal match",
                                  "generic match", "subtype match",
                                  "integral match", "conversion match"]:
    if count(p, m) > count(q, m): return true
    elif count(p, m) == count(q, m):
      discard "continue with next category m"
    else:
      return false
  return "ambiguous"


Some examples:

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


If this algorithm returns "ambiguous" further disambiguation is performed:
If the argument `a` matches both the parameter type `f` of `p`
and `g` of `q` via a subtyping relation, the inheritance depth is taken
into account:

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


Likewise, for generic matches, the most specialized generic type (that still
matches) is preferred:

  ```nim
  proc gen[T](x: ref ref T) = echo "ref ref T"
  proc gen[T](x: ref T) = echo "ref T"
  proc gen[T](x: T) = echo "T"

  var ri: ref int
  gen(ri) # "ref T"
  ```


Overloading based on 'var T'
--------------------------------------

If the formal parameter `f` is of type `var T`
in addition to the ordinary type checking,
the argument is checked to be an `l-value`:idx:.
`var T` matches better than just `T` then.

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


Lazy type resolution for untyped
--------------------------------

**Note**: An `unresolved`:idx: expression is an expression for which no symbol
lookups and no type checking have been performed.

Since templates and macros that are not declared as `immediate` participate
in overloading resolution, it's essential to have a way to pass unresolved
expressions to a template or macro. This is what the meta-type `untyped`
accomplishes:

  ```nim
  template rem(x: untyped) = discard

  rem unresolvedExpression(undeclaredIdentifier)
  ```

A parameter of type `untyped` always matches any argument (as long as there is
any argument passed to it).

But one has to watch out because other overloads might trigger the
argument's resolution:

  ```nim
  template rem(x: untyped) = discard
  proc rem[T](x: T) = discard

  # undeclared identifier: 'unresolvedExpression'
  rem unresolvedExpression(undeclaredIdentifier)
  ```

`untyped` and `varargs[untyped]` are the only metatype that are lazy in this sense, the other
metatypes `typed` and `typedesc` are not lazy.


Varargs matching
----------------

See `Varargs <#types-varargs>`_.


iterable
--------

A called `iterator` yielding type `T` can be passed to a template or macro via
a parameter typed as `untyped` (for unresolved expressions) or the type class
`iterable` or `iterable[T]` (after type checking and overload resolution).

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


Overload disambiguation
=======================

For routine calls "overload resolution" is performed. There is a weaker form of
overload resolution called *overload disambiguation* that is performed when an
overloaded symbol is used in a context where there is additional type information
available. Let `p` be an overloaded symbol. These contexts are:

- In a function call `q(..., p, ...)` when the corresponding formal parameter
  of `q` is a `proc` type. If `q` itself is overloaded then the cartesian product
  of every interpretation of `q` and `p` must be considered.
- In an object constructor `Obj(..., field: p, ...)` when `field` is a `proc`
  type. Analogous rules exist for array/set/tuple constructors.
- In a declaration like `x: T = p` when `T` is a `proc` type.

As usual, ambiguous matches produce a compile-time error.

Named argument overloading
--------------------------

Routines with the same type signature can be called individually if
a parameter has different names between them.

  ```Nim
  proc foo(x: int) =
    echo "Using x: ", x
  proc foo(y: int) =
    echo "Using y: ", y

  foo(x = 2) # Using x: 2
  foo(y = 2) # Using y: 2
  ```

Not supplying the parameter name in such cases results in an
ambiguity error.


Statements and expressions
==========================

Nim uses the common statement/expression paradigm: Statements do not
produce a value in contrast to expressions. However, some expressions are
statements.

Statements are separated into `simple statements`:idx: and
`complex statements`:idx:.
Simple statements are statements that cannot contain other statements like
assignments, calls, or the `return` statement; complex statements can
contain other statements. To avoid the `dangling else problem`:idx:, complex
statements always have to be indented. The details can be found in the grammar.


Statement list expression
-------------------------

Statements can also occur in an expression context that looks
like `(stmt1; stmt2; ...; ex)`. This is called
a statement list expression or `(;)`. The type
of `(stmt1; stmt2; ...; ex)` is the type of `ex`. All the other statements
must be of type `void`. (One can use `discard` to produce a `void` type.)
`(;)` does not introduce a new scope.


Discard statement
-----------------

示例：

  ```nim
  proc p(x, y: int): int =
    result = x + y

  discard p(3, 4) # discard the return value of `p`
  ```

The `discard` statement evaluates its expression for side-effects and
throws the expression's resulting value away, and should only be used
when ignoring this value is known not to cause problems.

Ignoring the return value of a procedure without using a discard statement is
a static error.

The return value can be ignored implicitly if the called proc/iterator has
been declared with the `discardable`:idx: pragma:

  ```nim
  proc p(x, y: int): int {.discardable.} =
    result = x + y

  p(3, 4) # now valid
  ```

however the discardable pragma does not work on templates as templates substitute the AST in place. For example:

  ```nim
  {.push discardable .}
  template example(): string = "https://nim-lang.org"
  {.pop.}

  example()
  ```

This template will resolve into "https://nim-lang.org" which is a string literal and since {.discardable.} doesn't apply to literals, the compiler will error.

An empty `discard` statement is often used as a null statement:

  ```nim
  proc classify(s: string) =
    case s[0]
    of SymChars, '_': echo "an identifier"
    of '0'..'9': echo "a number"
    else: discard
  ```


Void context
------------

In a list of statements, every expression except the last one needs to have the
type `void`. In addition to this rule an assignment to the builtin `result`
symbol also triggers a mandatory `void` context for the subsequent expressions:

  ```nim
  proc invalid*(): string =
    result = "foo"
    "invalid"  # Error: value of type 'string' has to be discarded
  ```

  ```nim
  proc valid*(): string =
    let x = 317
    "valid"
  ```


Var statement
-------------

Var statements declare new local and global variables and
initialize them. A comma-separated list of variables can be used to specify
variables of the same type:

  ```nim
  var
    a: int = 0
    x, y, z: int
  ```

If an initializer is given, the type can be omitted: the variable is then of the
same type as the initializing expression. Variables are always initialized
with a default value if there is no initializing expression. The default
value depends on the type and is always a zero in binary.

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


The implicit initialization can be avoided for optimization reasons with the
`noinit`:idx: pragma:

  ```nim
  var
    a {.noinit.}: array[0..1023, char]
  ```

If a proc is annotated with the `noinit` pragma, this refers to its implicit
`result` variable:

  ```nim
  proc returnUndefinedValue: int {.noinit.} = discard
  ```


The implicit initialization can also be prevented by the `requiresInit`:idx:
type pragma. The compiler requires an explicit initialization for the object
and all of its fields. However, it does a `control flow analysis`:idx: to prove
the variable has been initialized and does not rely on syntactic properties:

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

`requiresInit` pragma can also be applied to `distinct` types.

Given the following distinct type definitions:

  ```nim
  type
    Foo = object
      x: string

    DistinctFoo {.requiresInit, borrow: `.`.} = distinct Foo
    DistinctString {.requiresInit.} = distinct string
  ```

The following code blocks will fail to compile:

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

But these will compile successfully:

  ```nim
  let foo = DistinctFoo(Foo(x: "test"))
  doAssert foo.x == "test"
  ```

  ```nim
  let s = DistinctString("test")
  doAssert string(s) == "test"
  ```

Let statement
-------------

A `let` statement declares new local and global `single assignment`:idx:
variables and binds a value to them. The syntax is the same as that of the `var`
statement, except that the keyword `var` is replaced by the keyword `let`.
Let variables are not l-values and can thus not be passed to `var` parameters
nor can their address be taken. They cannot be assigned new values.

For let variables, the same pragmas are available as for ordinary variables.

As `let` statements are immutable after creation they need to define a value
when they are declared. The only exception to this is if the `{.importc.}`
pragma (or any of the other `importX` pragmas) is applied, in this case the
value is expected to come from native code, typically a C/C++ `const`.


Tuple unpacking
---------------

In a `var` or `let` statement tuple unpacking can be performed. The special
identifier `_` can be used to ignore some parts of the tuple:

  ```nim
  proc returnsTuple(): (int, int, int) = (4, 2, 3)

  let (x, _, z) = returnsTuple()
  ```



Const section
-------------

A const section declares constants whose values are constant expressions:

  ```nim
  import std/[strutils]
  const
    roundPi = 3.1415
    constEval = contains("abc", 'b') # computed at compile time!
  ```

Once declared, a constant's symbol can be used as a constant expression.

See `Constants and Constant Expressions <#constants-and-constant-expressions>`_
for details.

Static statement/expression
---------------------------

A static statement/expression explicitly requires compile-time execution.
Even some code that has side effects is permitted in a static block:

  ```nim
  static:
    echo "echo at compile time"
  ```

`static` can also be used like a routine.

  ```nim
  proc getNum(a: int): int = a

  # Below calls "echo getNum(123)" at compile time.
  static:
    echo getNum(123)

  # Below call evaluates the "getNum(123)" at compile time, but its
  # result gets used at run time.
  echo static(getNum(123))
  ```

There are limitations on what Nim code can be executed at compile time;
see `Restrictions on Compile-Time Execution
<#restrictions-on-compileminustime-execution>`_ for details.
It's a static error if the compiler cannot execute the block at compile
time.


If statement
------------

示例：

  ```nim
  var name = readLine(stdin)

  if name == "Andreas":
    echo "What a nice name!"
  elif name == "":
    echo "Don't you have a name?"
  else:
    echo "Boring name..."
  ```

The `if` statement is a simple way to make a branch in the control flow:
The expression after the keyword `if` is evaluated, if it is true
the corresponding statements after the `:` are executed. Otherwise,
the expression after the `elif` is evaluated (if there is an
`elif` branch), if it is true the corresponding statements after
the `:` are executed. This goes on until the last `elif`. If all
conditions fail, the `else` part is executed. If there is no `else`
part, execution continues with the next statement.

In `if` statements, new scopes begin immediately after
the `if`/`elif`/`else` keywords and ends after the
corresponding *then* block.
For visualization purposes the scopes have been enclosed
in `{|  |}` in the following example:

  ```nim
  if {| (let m = input =~ re"(\w+)=\w+"; m.isMatch):
    echo "key ", m[0], " value ", m[1]  |}
  elif {| (let m = input =~ re""; m.isMatch):
    echo "new m in this scope"  |}
  else: {|
    echo "m not declared here"  |}
  ```

Case statement
--------------

示例：

  ```nim
  let line = readline(stdin)
  case line
  of "delete-everything", "restart-computer":
    echo "permission denied"
  of "go-for-a-walk":     echo "please yourself"
  elif line.len == 0:     echo "empty" # optional, must come after `of` branches
  else:                   echo "unknown command" # ditto

  # indentation of the branches is also allowed; and so is an optional colon
  # after the selecting expression:
  case readline(stdin):
    of "delete-everything", "restart-computer":
      echo "permission denied"
    of "go-for-a-walk":     echo "please yourself"
    else:                   echo "unknown command"
  ```


The `case` statement is similar to the `if` statement, but it represents
a multi-branch selection. The expression after the keyword `case` is
evaluated and if its value is in a *slicelist* the corresponding statements
(after the `of` keyword) are executed. If the value is not in any
given *slicelist*, trailing `elif` and `else` parts are executed using same
semantics as for `if` statement, and `elif` is handled just like `else: if`.
If there are no `else` or `elif` parts and not
all possible values that `expr` can hold occur in a *slicelist*, a static error occurs.
This holds only for expressions of ordinal types.
"All possible values" of `expr` are determined by `expr`'s type.
To suppress the static error an `else: discard` should be used.

For non-ordinal types, it is not possible to list every possible value and so
these always require an `else` part.
An exception to this rule is for the `string` type, which currently doesn't
require a trailing `else` or `elif` branch; it's unspecified whether this will
keep working in future versions.

Because case statements are checked for exhaustiveness during semantic analysis,
the value in every `of` branch must be a constant expression.
This restriction also allows the compiler to generate more performant code.

As a special semantic extension, an expression in an `of` branch of a case
statement may evaluate to a set or array constructor; the set or array is then
expanded into a list of its elements:

  ```nim
  const
    SymChars: set[char] = {'a'..'z', 'A'..'Z', '\x80'..'\xFF'}

  proc classify(s: string) =
    case s[0]
    of SymChars, '_': echo "an identifier"
    of '0'..'9': echo "a number"
    else: echo "other"

  # is equivalent to:
  proc classify(s: string) =
    case s[0]
    of 'a'..'z', 'A'..'Z', '\x80'..'\xFF', '_': echo "an identifier"
    of '0'..'9': echo "a number"
    else: echo "other"
  ```

The `case` statement doesn't produce an l-value, so the following example
won't work:

  ```nim
  type
    Foo = ref object
      x: seq[string]

  proc get_x(x: Foo): var seq[string] =
    # doesn't work
    case true
    of true:
      x.x
    else:
      x.x

  var foo = Foo(x: @[])
  foo.get_x().add("asd")
  ```

This can be fixed by explicitly using `result` or `return`:

  ```nim
  proc get_x(x: Foo): var seq[string] =
    case true
    of true:
      result = x.x
    else:
      result = x.x
  ```


When statement
--------------

示例：

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

The `when` statement is almost identical to the `if` statement with some
exceptions:

* Each condition (`expr`) has to be a constant expression (of type `bool`).
* The statements do not open a new scope.
* The statements that belong to the expression that evaluated to true are
  translated by the compiler, the other statements are not checked for
  semantics! However, each condition is checked for semantics.

The `when` statement enables conditional compilation techniques. As
a special syntactic extension, the `when` construct is also available
within `object` definitions.


When nimvm statement
--------------------

`nimvm` is a special symbol that may be used as the expression of a
`when nimvm` statement to differentiate the execution path between
compile-time and the executable.

示例：

  ```nim
  proc someProcThatMayRunInCompileTime(): bool =
    when nimvm:
      # This branch is taken at compile time.
      result = true
    else:
      # This branch is taken in the executable.
      result = false
  const ctValue = someProcThatMayRunInCompileTime()
  let rtValue = someProcThatMayRunInCompileTime()
  assert(ctValue == true)
  assert(rtValue == false)
  ```

A `when nimvm` statement must meet the following requirements:

* Its expression must always be `nimvm`. More complex expressions are not
  allowed.
* It must not contain `elif` branches.
* It must contain an `else` branch.
* Code in branches must not affect semantics of the code that follows the
  `when nimvm` statement. E.g. it must not define symbols that are used in
  the following code.

Return statement
----------------

示例：

  ```nim
  return 40 + 2
  ```

The `return` statement ends the execution of the current procedure.
It is only allowed in procedures. If there is an `expr`, this is syntactic
sugar for:

  ```nim
  result = expr
  return result
  ```


`return` without an expression is a short notation for `return result` if
the proc has a return type. The `result`:idx: variable is always the return
value of the procedure. It is automatically declared by the compiler. As all
variables, `result` is initialized to (binary) zero:

  ```nim
  proc returnZero(): int =
    # implicitly returns 0
  ```


Yield statement
---------------

示例：

  ```nim
  yield (1, 2, 3)
  ```

The `yield` statement is used instead of the `return` statement in
iterators. It is only valid in iterators. Execution is returned to the body
of the for loop that called the iterator. Yield does not end the iteration
process, but the execution is passed back to the iterator if the next iteration
starts. See the section about iterators (`Iterators and the for statement`_)
for further information.


Block statement
---------------

示例：

  ```nim
  var found = false
  block myblock:
    for i in 0..3:
      for j in 0..3:
        if a[j][i] == 7:
          found = true
          break myblock # leave the block, in this case both for-loops
  echo found
  ```

The block statement is a means to group statements to a (named) `block`.
Inside the block, the `break` statement is allowed to leave the block
immediately. A `break` statement can contain a name of a surrounding
block to specify which block is to be left.


Break statement
---------------

示例：

  ```nim
  break
  ```

The `break` statement is used to leave a block immediately. If `symbol`
is given, it is the name of the enclosing block that is to be left. If it is
absent, the innermost block is left.


While statement
---------------

示例：

  ```nim
  echo "Please tell me your password:"
  var pw = readLine(stdin)
  while pw != "12345":
    echo "Wrong password! Next try:"
    pw = readLine(stdin)
  ```


The `while` statement is executed until the `expr` evaluates to false.
Endless loops are no error. `while` statements open an `implicit block`
so that they can be left with a `break` statement.


Continue statement
------------------

A `continue` statement leads to the immediate next iteration of the
surrounding loop construct. It is only allowed within a loop. A continue
statement is syntactic sugar for a nested block:

  ```nim
  while expr1:
    stmt1
    continue
    stmt2
  ```

Is equivalent to:

  ```nim
  while expr1:
    block myBlockName:
      stmt1
      break myBlockName
      stmt2
  ```


Assembler statement
-------------------

The direct embedding of assembler code into Nim code is supported
by the unsafe `asm` statement. Identifiers in the assembler code that refer to
Nim identifiers shall be enclosed in a special character which can be
specified in the statement's pragmas. The default special character is `'\`'`:

  ```nim
  {.push stackTrace:off.}
  proc addInt(a, b: int): int =
    # a in eax, and b in edx
    asm """
        mov eax, `a`
        add eax, `b`
        jno theEnd
        call `raiseOverflow`
      theEnd:
    """
  {.pop.}
  ```

If the GNU assembler is used, quotes and newlines are inserted automatically:

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

Instead of:

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

Using statement
---------------

The `using` statement provides syntactic convenience in modules where
the same parameter names and types are used over and over. Instead of:

  ```nim
  proc foo(c: Context; n: Node) = ...
  proc bar(c: Context; n: Node, counter: int) = ...
  proc baz(c: Context; n: Node) = ...
  ```

One can tell the compiler about the convention that a parameter of
name `c` should default to type `Context`, `n` should default to
`Node` etc.:

  ```nim
  using
    c: Context
    n: Node
    counter: int

  proc foo(c, n) = ...
  proc bar(c, n, counter) = ...
  proc baz(c, n) = ...

  proc mixedMode(c, n; x, y: int) =
    # 'c' is inferred to be of the type 'Context'
    # 'n' is inferred to be of the type 'Node'
    # But 'x' and 'y' are of type 'int'.
  ```

The `using` section uses the same indentation based grouping syntax as
a `var` or `let` section.

Note that `using` is not applied for `template` since the untyped template
parameters default to the type `system.untyped`.

Mixing parameters that should use the `using` declaration with parameters
that are explicitly typed is possible and requires a semicolon between them.


If expression
-------------

An `if` expression is almost like an if statement, but it is an expression.
This feature is similar to *ternary operators* in other languages.
示例：

  ```nim
  var y = if x > 8: 9 else: 10
  ```

An if expression always results in a value, so the `else` part is
required. `Elif` parts are also allowed.

When expression
---------------

Just like an `if` expression, but corresponding to the `when` statement.

Case expression
---------------

The `case` expression is again very similar to the case statement:

  ```nim
  var favoriteFood = case animal
    of "dog": "bones"
    of "cat": "mice"
    elif animal.endsWith"whale": "plankton"
    else:
      echo "I'm not sure what to serve, but everybody loves ice cream"
      "ice cream"
  ```

As seen in the above example, the case expression can also introduce side
effects. When multiple statements are given for a branch, Nim will use
the last expression as the result value.

Block expression
----------------

A `block` expression is almost like a block statement, but it is an expression
that uses the last expression under the block as the value.
It is similar to the statement list expression, but the statement list expression
does not open a new block scope.

  ```nim
  let a = block:
    var fib = @[0, 1]
    for i in 0..10:
      fib.add fib[^1] + fib[^2]
    fib
  ```

Table constructor
-----------------

A table constructor is syntactic sugar for an array constructor:

  ```nim
  {"key1": "value1", "key2", "key3": "value2"}

  # is the same as:
  [("key1", "value1"), ("key2", "value2"), ("key3", "value2")]
  ```


The empty table can be written `{:}` (in contrast to the empty set
which is `{}`) which is thus another way to write the empty array
constructor `[]`. This slightly unusual way of supporting tables
has lots of advantages:

* The order of the (key,value)-pairs is preserved, thus it is easy to
  support ordered dicts with for example `{key: val}.newOrderedTable`.
* A table literal can be put into a `const` section and the compiler
  can easily put it into the executable's data section just like it can
  for arrays and the generated data section requires a minimal amount
  of memory.
* Every table implementation is treated equally syntactically.
* Apart from the minimal syntactic sugar, the language core does not need to
  know about tables.


Type conversions
----------------

Syntactically a *type conversion* is like a procedure call, but a
type name replaces the procedure name. A type conversion is always
safe in the sense that a failure to convert a type to another
results in an exception (if it cannot be determined statically).

Ordinary procs are often preferred over type conversions in Nim: For instance,
`$` is the `toString` operator by convention and `toFloat` and `toInt`
can be used to convert from floating-point to integer or vice versa.

Type conversion can also be used to disambiguate overloaded routines:

  ```nim
  proc p(x: int) = echo "int"
  proc p(x: string) = echo "string"

  let procVar = (proc(x: string))(p)
  procVar("a")
  ```

Since operations on unsigned numbers wrap around and are unchecked so are
type conversions to unsigned integers and between unsigned integers. The
rationale for this is mostly better interoperability with the C Programming
language when algorithms are ported from C to Nim.

Exception: Values that are converted to an unsigned type at compile time
are checked so that code like `byte(-1)` does not compile.

**Note**: Historically the operations
were unchecked and the conversions were sometimes checked but starting with
the revision 1.0.4 of this document and the language implementation the
conversions too are now *always unchecked*.


Type casts
----------

*Type casts* are a crude mechanism to interpret the bit pattern of an expression
as if it would be of another type. Type casts are only needed for low-level
programming and are inherently unsafe.

  ```nim
  cast[int](x)
  ```

The target type of a cast must be a concrete type, for instance, a target type
that is a type class (which is non-concrete) would be invalid:

  ```nim
  type Foo = int or float
  var x = cast[Foo](1) # Error: cannot cast to a non concrete type: 'Foo'
  ```

Type casts should not be confused with *type conversions,* as mentioned in the
prior section. Unlike type conversions, a type cast cannot change the underlying
bit pattern of the data being cast (aside from that the size of the target type
may differ from the source type). Casting resembles *type punning* in other
languages or C++'s `reinterpret_cast`:cpp: and `bit_cast`:cpp: features.

The addr operator
-----------------
The `addr` operator returns the address of an l-value. If the type of the
location is `T`, the `addr` operator result is of the type `ptr T`. An
address is always an untraced reference. Taking the address of an object that
resides on the stack is **unsafe**, as the pointer may live longer than the
object on the stack and can thus reference a non-existing object. One can get
the address of variables. For easier interoperability with other compiled languages
such as C, retrieving the address of a `let` variable, a parameter,
or a `for` loop variable can be accomplished too:

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

The unsafeAddr operator
-----------------------

The `unsafeAddr` operator is a deprecated alias for the `addr` operator:

  ```nim
  let myArray = [1, 2, 3]
  foreignProcThatTakesAnAddr(unsafeAddr myArray)
  ```

Procedures
==========

What most programming languages call `methods`:idx: or `functions`:idx: are
called `procedures`:idx: in Nim. A procedure
declaration consists of an identifier, zero or more formal parameters, a return
value type and a block of code. Formal parameters are declared as a list of
identifiers separated by either comma or semicolon. A parameter is given a type
by `: typename`. The type applies to all parameters immediately before it,
until either the beginning of the parameter list, a semicolon separator, or an
already typed parameter, is reached. The semicolon can be used to make
separation of types and subsequent identifiers more distinct.

  ```nim
  # Using only commas
  proc foo(a, b: int, c, d: bool): int

  # Using semicolon for visual distinction
  proc foo(a, b: int; c, d: bool): int

  # Will fail: a is untyped since ';' stops type propagation.
  proc foo(a; b: int; c, d: bool): int
  ```

A parameter may be declared with a default value which is used if the caller
does not provide a value for the argument. The value will be reevaluated
every time the function is called.

  ```nim
  # b is optional with 47 as its default value.
  proc foo(a: int, b: int = 47): int
  ```

Just as the comma propagates the types from right to left until the
first parameter or until a semicolon is hit, it also propagates the
default value starting from the parameter declared with it.

  ```nim
  # Both a and b are optional with 47 as their default values.
  proc foo(a, b: int = 47): int
  ```

Parameters can be declared mutable and so allow the proc to modify those
arguments, by using the type modifier `var`.

  ```nim
  # "returning" a value to the caller through the 2nd argument
  # Notice that the function uses no actual return value at all (ie void)
  proc foo(inp: int, outp: var int) =
    outp = inp + 47
  ```

If the proc declaration doesn't have a body, it is a `forward`:idx: declaration.
If the proc returns a value, the procedure body can access an implicitly declared
variable named `result`:idx: that represents the return value. Procs can be
overloaded. The overloading resolution algorithm determines which proc is the
best match for the arguments. 示例：

  ```nim
  proc toLower(c: char): char = # toLower for characters
    if c in {'A'..'Z'}:
      result = chr(ord(c) + (ord('a') - ord('A')))
    else:
      result = c

  proc toLower(s: string): string = # toLower for strings
    result = newString(len(s))
    for i in 0..len(s) - 1:
      result[i] = toLower(s[i]) # calls toLower for characters; no recursion!
  ```

Calling a procedure can be done in many ways:

  ```nim
  proc callme(x, y: int, s: string = "", c: char, b: bool = false) = ...

  # call with positional arguments      # parameter bindings:
  callme(0, 1, "abc", '\t', true)       # (x=0, y=1, s="abc", c='\t', b=true)
  # call with named and positional arguments:
  callme(y=1, x=0, "abd", '\t')         # (x=0, y=1, s="abd", c='\t', b=false)
  # call with named arguments (order is not relevant):
  callme(c='\t', y=1, x=0)              # (x=0, y=1, s="", c='\t', b=false)
  # call as a command statement: no () needed:
  callme 0, 1, "abc", '\t'              # (x=0, y=1, s="abc", c='\t', b=false)
  ```

A procedure may call itself recursively.


`Operators`:idx: are procedures with a special operator symbol as identifier:

  ```nim
  proc `$` (x: int): string =
    # converts an integer to a string; this is a prefix operator.
    result = intToStr(x)
  ```

Operators with one parameter are prefix operators, operators with two
parameters are infix operators. (However, the parser distinguishes these from
the operator's position within an expression.) There is no way to declare
postfix operators: all postfix operators are built-in and handled by the
grammar explicitly.

Any operator can be called like an ordinary proc with the \`opr\`
notation. (Thus an operator can have more than two parameters):

  ```nim
  proc `*+` (a, b, c: int): int =
    # Multiply and add
    result = a * b + c

  assert `*+`(3, 4, 6) == `+`(`*`(a, b), c)
  ```


Export marker
-------------

If a declared symbol is marked with an `asterisk`:idx: it is exported from the
current module:

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


Method call syntax
------------------

For object-oriented programming, the syntax `obj.methodName(args)` can be used
instead of `methodName(obj, args)`. The parentheses can be omitted if
there are no remaining arguments: `obj.len` (instead of `len(obj)`).

This method call syntax is not restricted to objects, it can be used
to supply any type of first argument for procedures:

  ```nim
  echo "abc".len # is the same as echo len "abc"
  echo "abc".toUpper()
  echo {'a', 'b', 'c'}.card
  stdout.writeLine("Hallo") # the same as writeLine(stdout, "Hallo")
  ```

Another way to look at the method call syntax is that it provides the missing
postfix notation.

The method call syntax conflicts with explicit generic instantiations:
`p[T](x)` cannot be written as `x.p[T]` because `x.p[T]` is always
parsed as `(x.p)[T]`.

另请参见： `Limitations of the method call syntax
<#templates-limitations-of-the-method-call-syntax>`_.

The `[: ]` notation has been designed to mitigate this issue: `x.p[:T]`
is rewritten by the parser to `p[T](x)`, `x.p[:T](y)` is rewritten to
`p[T](x, y)`. Note that `[: ]` has no AST representation, the rewrite
is performed directly in the parsing step.


Properties
----------
Nim has no need for *get-properties*: Ordinary get-procedures that are called
with the *method call syntax* achieve the same. But setting a value is
different; for this, a special setter syntax is needed:

  ```nim
  # Module asocket
  type
    Socket* = ref object of RootObj
      host: int # cannot be accessed from the outside of the module

  proc `host=`*(s: var Socket, value: int) {.inline.} =
    ## setter of hostAddr.
    ## This accesses the 'host' field and is not a recursive call to
    ## `host=` because the builtin dot access is preferred if it is
    ## available:
    s.host = value

  proc host*(s: Socket): int {.inline.} =
    ## getter of hostAddr
    ## This accesses the 'host' field and is not a recursive call to
    ## `host` because the builtin dot access is preferred if it is
    ## available:
    s.host
  ```

  ```nim
  # module B
  import asocket
  var s: Socket
  new s
  s.host = 34  # same as `host=`(s, 34)
  ```

A proc defined as `f=` (with the trailing `=`) is called
a `setter`:idx:. A setter can be called explicitly via the common
backticks notation:

  ```nim
  proc `f=`(x: MyObject; value: string) =
    discard

  `f=`(myObject, "value")
  ```


`f=` can be called implicitly in the pattern
`x.f = value` if and only if the type of `x` does not have a field
named `f` or if `f` is not visible in the current module. These rules
ensure that object fields and accessors can have the same name. Within the
module `x.f` is then always interpreted as field access and outside the
module it is interpreted as an accessor proc call.


Command invocation syntax
-------------------------

Routines can be invoked without the `()` if the call is syntactically
a statement. This command invocation syntax also works for
expressions, but then only a single argument may follow. This restriction
means `echo f 1, f 2` is parsed as `echo(f(1), f(2))` and not as
`echo(f(1, f(2)))`. The method call syntax may be used to provide one
more argument in this case:

  ```nim
  proc optarg(x: int, y: int = 0): int = x + y
  proc singlearg(x: int): int = 20*x

  echo optarg 1, " ", singlearg 2  # prints "1 40"

  let fail = optarg 1, optarg 8   # Wrong. Too many arguments for a command call
  let x = optarg(1, optarg 8)  # traditional procedure call with 2 arguments
  let y = 1.optarg optarg 8    # same thing as above, w/o the parenthesis
  assert x == y
  ```

The command invocation syntax also can't have complex expressions as arguments.
For example: (`anonymous procs <#procedures-anonymous-procs>`_), `if`,
`case` or `try`. Function calls with no arguments still need () to
distinguish between a call and the function itself as a first-class value.


Closures
--------

Procedures can appear at the top level in a module as well as inside other
scopes, in which case they are called nested procs. A nested proc can access
local variables from its enclosing scope and if it does so it becomes a
closure. Any captured variables are stored in a hidden additional argument
to the closure (its environment) and they are accessed by reference by both
the closure and its enclosing scope (i.e. any modifications made to them are
visible in both places). The closure environment may be allocated on the heap
or on the stack if the compiler determines that this would be safe.

### Creating closures in loops

Since closures capture local variables by reference it is often not wanted
behavior inside loop bodies. See `closureScope
<system.html#closureScope.t,untyped>`_ and `capture
<sugar.html#capture.m,varargs[typed],untyped>`_ for details on how to change this behavior.

Anonymous procedures
--------------------

Unnamed procedures can be used as lambda expressions to pass into other
procedures:

  ```nim
  var cities = @["Frankfurt", "Tokyo", "New York", "Kyiv"]

  cities.sort(proc (x, y: string): int =
    cmp(x.len, y.len))
  ```


Procs as expressions can appear both as nested procs and inside top-level
executable code. The  `sugar <sugar.html>`_ module contains the `=>` macro
which enables a more succinct syntax for anonymous procedures resembling
lambdas as they are in languages like JavaScript, C#, etc.

Do notation
-----------

As a special convenience notation that keeps most elements of a
regular proc expression, the `do` keyword can be used to pass
anonymous procedures to routines:

  ```nim
  var cities = @["Frankfurt", "Tokyo", "New York", "Kyiv"]

  sort(cities) do (x, y: string) -> int:
    cmp(x.len, y.len)

  # Less parentheses using the method plus command syntax:
  cities = cities.map do (x: string) -> string:
    "City of " & x
  ```

`do` is written after the parentheses enclosing the regular proc params.
The proc expression represented by the `do` block is appended to the routine
call as the last argument. In calls using the command syntax, the `do` block
will bind to the immediately preceding expression rather than the command call.

`do` with a parameter list or pragma list corresponds to an anonymous `proc`,
however `do` without parameters or pragmas is treated as a normal statement
list. This allows macros to receive both indented statement lists as an
argument in inline calls, as well as a direct mirror of Nim's routine syntax.

  ```nim
  # Passing a statement list to an inline macro:
  macroResults.add quote do:
    if not `ex`:
      echo `info`, ": Check failed: ", `expString`
  
  # Processing a routine definition in a macro:
  rpc(router, "add") do (a, b: int) -> int:
    result = a + b
  ```

Func
----

The `func` keyword introduces a shortcut for a `noSideEffect`:idx: proc.

  ```nim
  func binarySearch[T](a: openArray[T]; elem: T): int
  ```

Is short for:

  ```nim
  proc binarySearch[T](a: openArray[T]; elem: T): int {.noSideEffect.}
  ```



Routines
--------

A routine is a symbol of kind: `proc`, `func`, `method`, `iterator`, `macro`, `template`, `converter`.

Type bound operators
--------------------

A type bound operator is a `proc` or `func` whose name starts with `=` but isn't an operator
(i.e. containing only symbols, such as `==`). These are unrelated to setters
(see `properties <manual.html#procedures-properties>`_), which instead end in `=`.
A type bound operator declared for a type applies to the type regardless of whether
the operator is in scope (including if it is private).

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
  # will still be called upon exiting scope
  doAssert witness == 3
  ```

Type bound operators are:
`=destroy`, `=copy`, `=sink`, `=trace`, `=deepcopy`.

These operations can be *overridden* instead of *overloaded*. This means that
the implementation is automatically lifted to structured types. For instance,
if the type `T` has an overridden assignment operator `=`, this operator is
also used for assignments of the type `seq[T]`.

Since these operations are bound to a type, they have to be bound to a
nominal type for reasons of simplicity of implementation; this means an
overridden `deepCopy` for `ref T` is really bound to `T` and not to `ref T`.
This also means that one cannot override `deepCopy` for both `ptr T` and
`ref T` at the same time, instead a distinct or object helper type has to be
used for one pointer type.

For more details on some of those procs, see
`Lifetime-tracking hooks <destructors.html#lifetimeminustracking-hooks>`_.

Nonoverloadable builtins
------------------------

The following built-in procs cannot be overloaded for reasons of implementation
simplicity (they require specialized semantic checking)::

  declared, defined, definedInScope, compiles, sizeof,
  is, shallowCopy, getAst, astToStr, spawn, procCall

Thus, they act more like keywords than like ordinary identifiers; unlike a
keyword however, a redefinition may `shadow`:idx: the definition in
the system_ module. From this list the following should not be written in dot
notation `x.f` since `x` cannot be type-checked before it gets passed
to `f`::

  declared, defined, definedInScope, compiles, getAst, astToStr


Var parameters
--------------
The type of a parameter may be prefixed with the `var` keyword:

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

In the example, `res` and `remainder` are `var parameters`.
Var parameters can be modified by the procedure and the changes are
visible to the caller. The argument passed to a var parameter has to be
an l-value. Var parameters are implemented as hidden pointers. The
above example is equivalent to:

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

In the examples, var parameters or pointers are used to provide two
return values. This can be done in a cleaner way by returning a tuple:

  ```nim
  proc divmod(a, b: int): tuple[res, remainder: int] =
    (a div b, a mod b)

  var t = divmod(8, 5)

  assert t.res == 1
  assert t.remainder == 3
  ```

One can use `tuple unpacking`:idx: to access the tuple's fields:

  ```nim
  var (x, y) = divmod(8, 5) # tuple unpacking
  assert x == 1
  assert y == 3
  ```


**Note**: `var` parameters are never necessary for efficient parameter
passing. Since non-var parameters cannot be modified the compiler is always
free to pass arguments by reference if it considers it can speed up execution.


Var return type
---------------

A proc, converter, or iterator may return a `var` type which means that the
returned value is an l-value and can be modified by the caller:

  ```nim
  var g = 0

  proc writeAccessToG(): var int =
    result = g

  writeAccessToG() = 6
  assert g == 6
  ```

It is a static error if the implicitly introduced pointer could be
used to access a location beyond its lifetime:

  ```nim
  proc writeAccessToG(): var int =
    var g = 0
    result = g # Error!
  ```

For iterators, a component of a tuple return type can have a `var` type too:

  ```nim
  iterator mpairs(a: var seq[string]): tuple[key: int, val: var string] =
    for i in 0..a.high:
      yield (i, a[i])
  ```

In the standard library every name of a routine that returns a `var` type
starts with the prefix `m` per convention.


.. include:: manual/var_t_return.md

### Future directions

Later versions of Nim can be more precise about the borrowing rule with
a syntax like:

  ```nim
  proc foo(other: Y; container: var X): var T from container
  ```

Here `var T from container` explicitly exposes that the
location is derived from the second parameter (called
'container' in this case). The syntax `var T from p` specifies a type
`varTy[T, 2]` which is incompatible with `varTy[T, 1]`.


NRVO
----

**Note**: This section describes the current implementation. This part
of the language specification will be changed.
See https://github.com/nim-lang/RFCs/issues/230 for more information.

The return value is represented inside the body of a routine as the special
`result`:idx: variable. This allows for a mechanism much like C++'s
"named return value optimization" (`NRVO`:idx:). NRVO means that the stores
to `result` inside `p` directly affect the destination `dest`
in `let/var dest = p(args)` (definition of `dest`) and also in `dest = p(args)`
(assignment to `dest`). This is achieved by rewriting `dest = p(args)`
to `p'(args, dest)` where `p'` is a variation of `p` that returns `void` and
receives a hidden mutable parameter representing `result`.

Informally:

  ```nim
  proc p(): BigT = ...

  var x = p()
  x = p()

  # is roughly turned into:

  proc p(result: var BigT) = ...

  var x; p(x)
  p(x)
  ```


Let `T`'s be `p`'s return type. NRVO applies for `T`
if `sizeof(T) >= N` (where `N` is implementation dependent),
in other words, it applies for "big" structures.

If `p` can raise an exception, NRVO applies regardless. This can produce
observable differences in behavior:

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


However, the current implementation produces a warning in these cases.
There are different ways to deal with this warning:

1. Disable the warning via `{.push warning[ObservableStores]: off.}` ... `{.pop.}`.
   Then one may need to ensure that `p` only raises *before* any stores to `result`
   happen.

2. One can use a temporary helper variable, for example instead of `x = p(8)`
   use `let tmp = p(8); x = tmp`.


Overloading of the subscript operator
-------------------------------------

The `[]` subscript operator for arrays/openarrays/sequences can be overloaded.


Methods
=============

Procedures always use static dispatch. Methods use dynamic
dispatch. For dynamic dispatch to work on an object it should be a reference
type.

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

In the example the constructors `newLit` and `newPlus` are procs
because they should use static binding, but `eval` is a method because it
requires dynamic binding.

As can be seen in the example, base methods have to be annotated with
the `base`:idx: pragma. The `base` pragma also acts as a reminder for the
programmer that a base method `m` is used as the foundation to determine all
the effects that a call to `m` might cause.


**Note**: Compile-time execution is not (yet) supported for methods.

**Note**: Starting from Nim 0.20, generic methods are deprecated.

Multi-methods
--------------

**Note:** Starting from Nim 0.20, to use multi-methods one must explicitly pass
`--multimethods:on`:option: when compiling.

In a multi-method, all parameters that have an object type are used for the
dispatching:

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

Inhibit dynamic method resolution via procCall
-----------------------------------------------

Dynamic method resolution can be inhibited via the builtin `system.procCall`:idx:.
This is somewhat comparable to the `super`:idx: keyword that traditional OOP
languages offer.

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


Iterators and the for statement
===============================

The `for`:idx: statement is an abstract mechanism to iterate over the elements
of a container. It relies on an `iterator`:idx: to do so. Like `while`
statements, `for` statements open an `implicit block`:idx: so that they
can be left with a `break` statement.

The `for` loop declares iteration variables - their scope reaches until the
end of the loop body. The iteration variables' types are inferred by the
return type of the iterator.

An iterator is similar to a procedure, except that it can be called in the
context of a `for` loop. Iterators provide a way to specify the iteration over
an abstract type. The `yield` statement in the called iterator plays a key
role in the execution of a `for` loop. Whenever a `yield` statement is
reached, the data is bound to the `for` loop variables and control continues
in the body of the `for` loop. The iterator's local variables and execution
state are automatically saved between calls. 示例：

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

The compiler generates code as if the programmer had written this:

  ```nim
  var i = 0
  while i < len(a):
    var ch = a[i]
    echo ch
    inc(i)
  ```

If the iterator yields a tuple, there can be as many iteration variables
as there are components in the tuple. The i'th iteration variable's type is
the type of the i'th component. In other words, implicit tuple unpacking in a
for loop context is supported.

Implicit items/pairs invocations
--------------------------------

If the for loop expression `e` does not denote an iterator and the for loop
has exactly 1 variable, the for loop expression is rewritten to `items(e)`;
i.e. an `items` iterator is implicitly invoked:

  ```nim
  for x in [1,2,3]: echo x
  ```

If the for loop has exactly 2 variables, a `pairs` iterator is implicitly
invoked.

Symbol lookup of the identifiers `items`/`pairs` is performed after
the rewriting step, so that all overloads of `items`/`pairs` are taken
into account.


First-class iterators
---------------------

There are 2 kinds of iterators in Nim: *inline* and *closure* iterators.
An `inline iterator`:idx: is an iterator that's always inlined by the compiler
leading to zero overhead for the abstraction, but may result in a heavy
increase in code size.

Caution: the body of a for loop over an inline iterator is inlined into
each `yield` statement appearing in the iterator code,
so ideally the code should be refactored to contain a single yield when possible
to avoid code bloat.

Inline iterators are second class citizens;
They can be passed as parameters only to other inlining code facilities like
templates, macros, and other inline iterators.

In contrast to that, a `closure iterator`:idx: can be passed around more freely:

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

Closure iterators and inline iterators have some restrictions:

1. For now, a closure iterator cannot be executed at compile time.
2. `return` is allowed in a closure iterator but not in an inline iterator
   (but rarely useful) and ends the iteration.
3. Inline iterators cannot be recursive.
4. Neither inline nor closure iterators have the special `result` variable.
5. Closure iterators are not supported by the JS backend.

Iterators that are neither marked `{.closure.}` nor `{.inline.}` explicitly
default to being inline, but this may change in future versions of the
implementation.

The `iterator` type is always of the calling convention `closure`
implicitly; the following example shows how to use iterators to implement
a `collaborative tasking`:idx: system:

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

The builtin `system.finished` can be used to determine if an iterator has
finished its operation; no exception is raised on an attempt to invoke an
iterator that has already finished its work.

Note that `system.finished` is error-prone to use because it only returns
`true` one iteration after the iterator has finished:

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

Instead, this code has to be used:

  ```nim
  var c = mycount # instantiate the iterator
  while true:
    let value = c(1, 3)
    if finished(c): break # and discard 'value'!
    echo value
  ```

It helps to think that the iterator actually returns a
pair `(value, done)` and `finished` is used to access the hidden `done`
field.


Closure iterators are *resumable functions* and so one has to provide the
arguments to every call. To get around this limitation one can capture
parameters of an outer factory proc:

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

The call can be made more like an inline iterator with a for loop macro:

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

Because of full backend function call apparatus involvement, closure iterator
invocation is typically higher cost than inline iterators. Adornment by
a macro wrapper at the call site like this is a possibly useful reminder.

The factory `proc`, as an ordinary procedure, can be recursive. The
above macro allows such recursion to look much like a recursive iterator
would. For example:

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


See also see `iterable <#overloading-resolution-iterable>`_ for passing iterators to templates and macros.

Converters
==========

A converter is like an ordinary proc except that it enhances
the "implicitly convertible" type relation (see `Convertible relation
<#type-relations-convertible-relation>`_):

  ```nim
  # bad style ahead: Nim is not C.
  converter toBool(x: int): bool = x != 0

  if 4:
    echo "compiles"
  ```


A converter can also be explicitly invoked for improved readability. Note that
implicit converter chaining is not supported: If there is a converter from
type A to type B and from type B to type C the implicit conversion from A to C
is not provided.


Type sections
=============

示例：

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

A type section begins with the `type` keyword. It contains multiple
type definitions. A type definition binds a type to a name. Type definitions
can be recursive or even mutually recursive. Mutually recursive types are only
possible within a single `type` section. Nominal types like `objects`
or `enums` can only be defined in a `type` section.



Exception handling
==================

Try statement
-------------

示例：

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


The statements after the `try` are executed in sequential order unless
an exception `e` is raised. If the exception type of `e` matches any
listed in an `except` clause, the corresponding statements are executed.
The statements following the `except` clauses are called
`exception handlers`:idx:.

The empty `except`:idx: clause is executed if there is an exception that is
not listed otherwise. It is similar to an `else` clause in `if` statements.

If there is a `finally`:idx: clause, it is always executed after the
exception handlers.

The exception is *consumed* in an exception handler. However, an
exception handler may raise another exception. If the exception is not
handled, it is propagated through the call stack. This means that often
the rest of the procedure - that is not within a `finally` clause -
is not executed (if an exception occurs).


Try expression
--------------

Try can also be used as an expression; the type of the `try` branch then
needs to fit the types of `except` branches, but the type of the `finally`
branch always has to be `void`:

  ```nim
  from std/strutils import parseInt

  let x = try: parseInt("133a")
          except: -1
          finally: echo "hi"
  ```


To prevent confusing code there is a parsing limitation; if the `try`
follows a `(` it has to be written as a one liner:

  ```nim
  let x = (try: parseInt("133a") except: -1)
  ```


Except clauses
--------------

Within an `except` clause it is possible to access the current exception
using the following syntax:

  ```nim
  try:
    # ...
  except IOError as e:
    # Now use "e"
    echo "I/O error: " & e.msg
  ```

Alternatively, it is possible to use `getCurrentException` to retrieve the
exception that has been raised:

  ```nim
  try:
    # ...
  except IOError:
    let e = getCurrentException()
    # Now use "e"
  ```

Note that `getCurrentException` always returns a `ref Exception`
type. If a variable of the proper type is needed (in the example
above, `IOError`), one must convert it explicitly:

  ```nim
  try:
    # ...
  except IOError:
    let e = (ref IOError)(getCurrentException())
    # "e" is now of the proper type
  ```

However, this is seldom needed. The most common case is to extract an
error message from `e`, and for such situations, it is enough to use
`getCurrentExceptionMsg`:

  ```nim
  try:
    # ...
  except:
    echo getCurrentExceptionMsg()
  ```

Custom exceptions
-----------------

It is possible to create custom exceptions. A custom exception is a custom type:

  ```nim
  type
    LoadError* = object of Exception
  ```

Ending the custom exception's name with `Error` is recommended.

Custom exceptions can be raised just like any other exception, e.g.:

  ```nim
  raise newException(LoadError, "Failed to load data")
  ```

Defer statement
---------------

Instead of a `try finally` statement a `defer` statement can be used, which
avoids lexical nesting and offers more flexibility in terms of scoping as shown
below.

Any statements following the `defer` in the current block will be considered
to be in an implicit try block:

  ```nim  test = "nim c $1"
  proc main =
    var f = open("numbers.txt", fmWrite)
    defer: close(f)
    f.write "abc"
    f.write "def"
  ```

Is rewritten to:

  ```nim  test = "nim c $1"
  proc main =
    var f = open("numbers.txt")
    try:
      f.write "abc"
      f.write "def"
    finally:
      close(f)
  ```

When `defer` is at the outermost scope of a template/macro, its scope extends
to the block where the template is called from:

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

Top-level `defer` statements are not supported
since it's unclear what such a statement should refer to.


Raise statement
---------------

示例：

  ```nim
  raise newException(IOError, "IO failed")
  ```

Apart from built-in operations like array indexing, memory allocation, etc.
the `raise` statement is the only way to raise an exception.

.. XXX document this better!

If no exception name is given, the current exception is `re-raised`:idx:. The
`ReraiseDefect`:idx: exception is raised if there is no exception to
re-raise. It follows that the `raise` statement *always* raises an
exception.


Exception hierarchy
-------------------

The exception tree is defined in the `system <system.html>`_ module.
Every exception inherits from `system.Exception`. Exceptions that indicate
programming bugs inherit from `system.Defect` (which is a subtype of `Exception`)
and are strictly speaking not catchable as they can also be mapped to an operation
that terminates the whole process. If panics are turned into exceptions, these
exceptions inherit from `Defect`.

Exceptions that indicate any other runtime error that can be caught inherit from
`system.CatchableError` (which is a subtype of `Exception`).


Imported exceptions
-------------------

It is possible to raise/catch imported C++ exceptions. Types imported using
`importcpp` can be raised or caught. Exceptions are raised by value and
caught by reference. 示例：

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

**Note:** `getCurrentException()` and `getCurrentExceptionMsg()` are not available
for imported exceptions from C++. One needs to use the `except ImportedException as x:` syntax
and rely on functionality of the `x` object to get exception details.


Effect system
=============

**Note**: The rules for effect tracking changed with the release of version
1.6 of the Nim compiler. This section describes the new rules that are activated
via `--experimental:strictEffects`.


Exception tracking
------------------

Nim supports exception tracking. The `raises`:idx: pragma can be used
to explicitly define which exceptions a proc/iterator/method/converter is
allowed to raise. The compiler verifies this:

  ```nim  test = "nim c $1"
  proc p(what: bool) {.raises: [IOError, OSError].} =
    if what: raise newException(IOError, "IO")
    else: raise newException(OSError, "OS")
  ```

An empty `raises` list (`raises: []`) means that no exception may be raised:

  ```nim
  proc p(): bool {.raises: [].} =
    try:
      unsafeCall()
      result = true
    except:
      result = false
  ```


A `raises` list can also be attached to a proc type. This affects type
compatibility:

  ```nim  test = "nim c $1"  status = 1
  type
    Callback = proc (s: string) {.raises: [IOError].}
  var
    c: Callback

  proc p(x: string) =
    raise newException(OSError, "OS")

  c = p # type error
  ```


For a routine `p`, the compiler uses inference rules to determine the set of
possibly raised exceptions; the algorithm operates on `p`'s call graph:

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


Exceptions inheriting from `system.Defect` are not tracked with
the `.raises: []` exception tracking mechanism. This is more consistent with the
built-in operations. The following code is valid:

  ```nim
  proc mydiv(a, b): int {.raises: [].} =
    a div b # can raise an DivByZeroDefect
  ```

And so is:

  ```nim
  proc mydiv(a, b): int {.raises: [].} =
    if b == 0: raise newException(DivByZeroDefect, "division by zero")
    else: result = a div b
  ```


The reason for this is that `DivByZeroDefect` inherits from `Defect` and
with `--panics:on`:option: Defects become unrecoverable errors.
(Since version 1.4 of the language.)


EffectsOf annotation
--------------------

Rules 1-2 of the exception tracking inference rules (see the previous section)
ensure the following works:

  ```nim
  proc weDontRaiseButMaybeTheCallback(callback: proc()) {.raises: [], effectsOf: callback.} =
    callback()

  proc doRaise() {.raises: [IOError].} =
    raise newException(IOError, "IO")

  proc use() {.raises: [].} =
    # doesn't compile! Can raise IOError!
    weDontRaiseButMaybeTheCallback(doRaise)
  ```

As can be seen from the example, a parameter of type `proc (...)` can be
annotated as `.effectsOf`. Such a parameter allows for effect polymorphism:
The proc `weDontRaiseButMaybeTheCallback` raises the exceptions
that `callback` raises.

So in many cases a callback does not cause the compiler to be overly
conservative in its effect analysis:

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



Tag tracking
------------

Exception tracking is part of Nim's `effect system`:idx:. Raising an exception
is an *effect*. Other effects can also be defined. A user defined effect is a
means to *tag* a routine and to perform checks against this tag:

  ```nim  test = "nim c --warningAsError:Effect:on $1"  status = 1
  type IO = object ## input/output effect
  proc readLine(): string {.tags: [IO].} = discard

  proc no_effects_please() {.tags: [].} =
    # the compiler prevents this:
    let x = readLine()
  ```

A tag has to be a type name. A `tags` list - like a `raises` list - can
also be attached to a proc type. This affects type compatibility.

The inference for tag tracking is analogous to the inference for
exception tracking.

There is also a way which can be used to forbid certain effects:

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

The `forbids` pragma defines a list of illegal effects - if any statement
invokes any of those effects, the compilation will fail.
Procedure types with any disallowed effect are the subtypes of equal
procedure types without such lists:

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

`ProcType2` is a subtype of `ProcType1`. Unlike with tags, the parent context - the function which calls other functions with forbidden effects - doesn't inherit the forbidden list of effects.


副作用

`noSideEffect` 编译指示标记只能通过传递参数产生副作用的过程或迭代器。这意味着这个过程或迭代器只能改变形参可访问的地址。假如该过程或迭代器参数中没有 `var`、`ref`、 `ptr`、 `cstring`、 `proc` 中的任意类型，其无法修改外部地址。

换句话说，如果一个例程既不接受本地线程变量或全局变量、也不调用其他带副作用的例程，则该例程是无副作用的。

如果给予一个过程或迭代器无副作用标记，而编译器无法验证，将引发静态错误。

作为一个特殊的语义规则，内置的`debugEcho`被视作为无副作用的。因此，其可以用于被标记为`noSideEffect`例程的debug。

`func`是无副作用过程的语法糖。

  ```nim
  func `+` (x, y: int): int
  ```


`cast` 编译标志可用于强制转换编译器的 `{.noSideEffect.}`无副作用语义。

  ```nim
  func f() =
    {.cast(noSideEffect).}:
      echo "test"
  ```

副作用通常是被推断的，其类似于异常跟踪的推断。


GC安全的作用

如果一个过程未接收任何包含于垃圾回收内存中的全局变量（`string`, `seq`, `ref`或者一个 closure（闭包）），也没有直接或间接调用涉及这类全局变量的GC不安全过程，该过程就是GC安全的：`GC safe`。

是否GC安全通常是被推断的，其类似于异常跟踪的推断。

`gcsafe`:idx:标识符可用于标记一个过程为GC安全的，否则将由编译器进行推断。值得注意的是，`noSideEffect`也就意味着`gcsafe`。

一个从C语言库导入的例程将总是被看作`gcsafe`的

 `{.cast(gcsafe).}` 编译标志块可用于覆写编译器的GC安全语义。

  ```nim
  var
    someGlobal: string = "some string here"
    perThread {.threadvar.}: string

  proc setPerThread() =
    {.cast(gcsafe).}:
      deepCopy(perThread, someGlobal)
  ```


另请参见：

- `Shared heap memory management <mm.html>`_.



作用编译标志

`effects` 编译标志用于协助程序员进行作用分析。这条语句可以使编译器输出所有被推断出的作用到`effects`的位置上

  ```nim
  proc p(what: bool) =
    if what:
      raise newException(IOError, "IO")
      {.effects.}
    else:
      raise newException(OSError, "OS")
  ```

编译器生成一条可能引发 `IOError`的提示消息。而`OSError`相关的信息不会被列出，因为它无法在出现 `effects` 编译标志的分支中引发。


泛型

泛型是Nim以`type parameters`:idx:类型化参数实现参数化的过程、迭代器和类型的途径。根据上下文，中括号可用于引入泛型参数或实例化泛型过程、泛型迭代器或者泛型类型。

以下例子展示了如何构建一个泛型二叉树：

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
        # 比较数据项; 使用泛型过程`cmp`
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
    # 便利过程:
    add(root, newNode(data))

  iterator preorder*[T](root: BinaryTree[T]): T =
    # 二叉树的预序遍历.
    # 显式地使用栈（比递归迭代器工厂更有效）.
    var stack: seq[BinaryTree[T]] = @[root]
    while stack.len > 0:
      var n = stack.pop()
      while n != nil:
        yield n.data
        add(stack, n.ri)  # 将右子树入栈
        n = n.le          # 并跟随左指针

  var
    root: BinaryTree[string] # 使用字符串实例化二叉树
  add(root, newNode("hello")) #实例化 `newNode`和 `add`
  add(root, "world")          # 实例化第二个`add` 过程
  for str in preorder(root):
    stdout.writeLine(str)
  ```

这里的`T`被称为泛型类型参数`generic type parameter`:idx:，或者可变类型

`is` 操作符

`is` 操作符在语义分析期间评估检查类型的等价性。因此其在对类型有特定要求的泛型代码中有重要作用。

  ```nim
  type
    Table[Key, Value] = object
      keys: seq[Key]
      values: seq[Value]
      when not (Key is string): # 优化空值字符串
        deletedKeys: seq[bool]
  ```


Type类
------------

Type类是一种特殊的伪类型，可在重载解析或`is` 操作符处针对性地匹配上下文中的类型 。Nim支持以下内置类型类：

==================   ===================================================
type class           matches
==================   ===================================================
`object`             实例类型
`tuple`              元组类型
`enum`               枚举类型
`proc`               过程类型
`ref`                过程类型
`ptr`               指针类型
`var`               变量类型
`distinct`           distinct类型
`array`              数组类型
`set`                集合类型
`seq`                序列类型
`auto`               任何类型
==================   ===================================================

此外，任何泛型类型都会自动创建一个同名的type类，籍此匹配该泛型类的实例。

Type类可以通过标准的布尔操作符组合为更复杂的Type类。

  ```nim
  # 创建一个可以匹配所有tuple类和object类的type类
  type RecordType = tuple or object

  proc printFields[T: RecordType](rec: T) =
    for key, value in fieldPairs(rec):
      echo key, " = ", value
  ```

泛型参数列表中的参数类型约束可以通过`,` 进行分组，并以 `;`结束一个分组，就像宏和模板中的参数列表那样：

  ```nim
  proc fn1[T; U, V: SomeFloat]() = discard # T 是不受类型约束的
  template fn2(t; u, v: SomeFloat) = discard # t是不受类型约束的
  ```

虽然type类在语法上接近于类ML语言中的抽象数据类型和代数数据类型，但应该知道type类是实例化时强制执行的静态约束。type类本身并非真的类，而只是提供了一个泛型检查系统以将其最终解释为确定的单一类型。type类不允许运行时的动态类型分配，这与object、变量和方法不同。

例如，以下代码将无法通过编译。

  ```nim
  type TypeClass = int | string
  var foo: TypeClass = 2 # foo的类型在这里被解释为int类型
  foo = "this will fail" # 这里发生错误，因为foo已经被解释为int类型
  ```

Nim允许将type类和常规类用作泛型类型参数的类型约束`type constraints`:idx:。

  ```nim
  proc onlyIntOrString[T: int|string](x, y: T) = discard

  onlyIntOrString(450, 616) # 有效的
  onlyIntOrString(5.0, 0.0) # 类型不匹配
  onlyIntOrString("xy", 50) # 无效的，因为同一个T不能被同时指定为两种不同类型
  ```


隐式泛型

一个type类可以直接作为参数的类型使用。

  ```nim
  # 创建一个可以同时匹配tuple和object类的type类
  type RecordType = tuple or object

  proc printFields(rec: RecordType) =
    for key, value in fieldPairs(rec):
      echo key, " = ", value
  ```


像这样以type类作为参数类型的过程被称为`implicitly generic`:idx:隐式泛型。隐式泛型每使用一组特定参数类型组合，都将在程序中创建一个实例。

通常，重载解析期间，每一个被命名的type类都将被绑定到一个确切的混合类。我们称这些type类 `bind once`:idx:单一绑定类。这里是一个从系统模块里直接拿来的例子：

  ```nim
  proc `==`*(x, y: tuple): bool =
    ## 需要 `x` 和 `y` 都是同样的元组类型
    ## 针对元组的泛型操作符 `==` 在`x` 和 `y`的组合中是左结合的
    result = true
    for a, b in fields(x, y):
      if a != b: result = false
  ```

或者， 当`distinct` 类修饰词用于type类，将允许每一参数绑定到匹配type类中的不同类型，这些type类被称为 `bind many`:idx:多绑定类。

以隐式泛型的方式书写过程时，需要制定匹配的类型参数。这样，才能使用`.`语法便捷的使用它们所包含的内容。

  ```nim
  type Matrix[T, Rows, Columns] = object
    ...

  proc `[]`(m: Matrix, row, col: int): Matrix.T =
    m.data[col * high(Matrix.Columns) + row]
  ```


这里有说明隐式泛型的更多例子

  ```nim
  proc p(t: Table; k: Table.Key): Table.Value

  # 等同于以下写法:

  proc p[Key, Value](t: Table[Key, Value]; k: Key): Value
  ```


  ```nim
  proc p(a: Table, b: Table)

  # 等同于以下写法：

  proc p[Key, Value](a, b: Table[Key, Value])
  ```


  ```nim
  proc p(a: Table, b: distinct Table)

  # 等同于以下写法：

  proc p[Key, Value, KeyB, ValueB](a: Table[Key, Value], b: Table[KeyB, ValueB])
  ```


`typedesc` 作为参数类型使用时，总是产生一个隐式泛型，`typedesc` 有其独有的设置规则。

  ```nim
  proc p(a: typedesc)

  # 等同于以下写法：

  proc p[T](a: typedesc[T])
  ```


`typedesc` 是一个多绑定type类型。

  ```nim
  proc p(a, b: typedesc)

  # 等同于以下写法：

  proc p[T, T2](a: typedesc[T], b: typedesc[T2])
  ```


一个具 `typedesc`类型的 参数自身也是可以作为一个类型使用的。如果将其作为类型使用，其将是底层类型。（换言之， `typedesc`类型参数最终绑定的类型将被剥离出来使用）：

  ```nim
  proc p(a: typedesc; b: a) = discard

  # 等同于以下代码：
  proc p[T](a: typedesc[T]; b: T) = discard

  # 这是有效的调用:
  p(int, 4)
  # 这里'a'需要的参数是一个类型, 而 'b' 需要的则是一个该类型的值.
  ```


泛型推断局限

类型 `var T` 和 `typedesc[T]` 无法在泛型实例中被推断，以下语句是不允许的：

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

  # 总是允许的: 明确了通过'var int'进行实例化
  g[var int](v, i)
  ```



泛型中的符号查找
-------------------------

开放和封闭符号

泛型中的符号绑定规则略显微妙：其存在开放和封闭两种状态的符号。一个封闭的符号在实例的上下文中无法被重新绑定，而一个开放的符号可以。默认情况下，重载符号都是开放的，而所有其他符号都是封闭的。

开放的符号可以在在两种不同的上下文中被找到：一是其定义所处的上下文，二是实例中的上下文：

  ```nim  test = "nim c $1"
  type
    Index = distinct int

  proc `==` (a, b: Index): bool {.borrow.}

  var a = (0, 0.Index)
  var b = (0, 0.Index)

  echo a == b # works!
  ```

在这个例子中，针对元组泛型符号 `==` （定义于系统模块），使用 `==` 操作符进行元组的组合。然而，针对`Index` 类型的 `==`符号定义在其针对元组的定义之后；所以，这个例子在被编译时，实例中当前符号的定义也会进入其中。

Mixin语句

一个符号可以通过`mixin`:idx:关键字声明开放

  ```nim  test = "nim c $1"
  proc create*[T](): ref T =
    # 这里没有'init'的重载，我们需要显式的将其声明为一个开放的符号:
    mixin init
    new result
    init result
  ```

`mixin`语句只有在模板和泛型中才有意义


绑定语句
--------------

 `bind` 语句相对于 `mixin` 语句。可用于显式地声明标识符需要绑定于先前（标识符应在模板或泛型的作用域中被定义）。

  ```nim
  # 模块 A
  var
    lastId = 0

  template genId*: untyped =
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
--------------------------

下面的示例概述了当泛型的实例跨越多个不同模块时可能出现的问题：

  ```nim
  # 模块 A
  proc genericA*[T](x: T) =
    mixin init
    init(x)
  ```


  ```nim
  import C

  # 模块 B
  proc genericB*[T](x: T) =
	# 没有`bind init`语句，当`genericB`实例化时，来自C模块的init过程是不可用的
    bind init
    genericA(x)
  ```

  ```nim
  # 模块 C
  type O = object
  proc init*(x: var O) = discard
  ```

  ```nim
  # 主模块
  import B, C

  genericB O()
  ```

在模块 B 作用域中有一个来自模块 C 的`init`过程，当实例化`genericB`时并导致`genericA`的实例化时，`init`过程未被考虑在内。解决方案是转发`forward`:idx:，将这些符号通过`bind`语句进入 `genericB`中。


模板
=========

一个模板就是一个简单形式的宏：它是一个简单的替换机制，在Nim的抽象语法树上运行。它运作在编译器的语义传递中。

调用模板的语法和调用过程的语法是相同的

示例：

  ```nim
  template `!=` (a, b: untyped): untyped =
    # 此定义存在于系统模块中
    not (a == b)

  assert(5 != 6) # 编译器将其重写为: assert(not (5 == 6))
  ```

 `!=`, `>`, `>=`, `in`, `notin`, `isnot` 等操作符实际上都是模板

| `a > b` 从 `b < a`变化而来.
| `a in b` 从 `contains(b, a)`变化而来.
| `notin` 和 `isnot` 的实现也是显而易见的.

模板中的类型可以使用`untyped`、`typed` 及 `typedesc`三个符号。这些都是“元类型”，它们只能被用于特定上下文中。常规类型也可被同样的使用；这意味着 `typed` 的表现是可预期的。


Typed 参数和untyped参数的比较
---------------------------

一个`untyped` 参数意味着符号的查找和类型的解析在表达式传递给模板前是不执行的。这意味着像以下例子这样不声明标识符的代码是可通过的：

  ```nim  test = "nim c $1"
  template declareInt(x: untyped) =
    var x: int

  declareInt(x) # 有效的
  x = 3
  ```


  ```nim  test = "nim c $1"  status = 1
  template declareInt(x: typed) =
    var x: int

  declareInt(x) # 不正确的，因为此处x的类型没有被声明，其类型是未确定的
  ```

如果一个模板的每个参数都是`untyped`的，则其被称为 `immediate`:idx:模板(即时模板)。由于历史原因，模板可以用`immediate` 编译标志显式的标记，这些模板将不参与重载解析，其参数中的类型将被编译器忽略。显式的声明即时模板现在已经被弃用。

注意：由于历史原因，`stmt` 是`typed` 的别名，`expr` 是 `untyped`的别名，但这两者都被移除了。


传递代码块到模板
----------------------------------

通过特殊的 `:` 语法，可以将一个语句块传递给模板的最后一个参数。

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

在这个例子中，这两行`writeLine` 语句被绑定到了模板的 `actions`参数


通常，为了传递一个代码块到模板，接受代码块的参数需要被声明为`untyped`类型。因为这样，符号查找会被推迟到模板实例化的进行期间内执行：

  ```nim  test = "nim c $1"  status = 1
  template t(body: typed) =
    proc p = echo "hey"
    block:
      body

  t:
    p()  # 失败，因为p是一个未被声明的标识符'
  ```

以上代码错误信息为 `p` 未被声明。其原因是`p()` 语句体在传递到 `body` 参数前执行类型检查和符号查找。通过修改模板参数类型为`untyped` 使得传递语句体时无需类型检查，同样的代码便可以通过：

  ```nim  test = "nim c $1"
  template t(body: untyped) =
    proc p = echo "hey"
    block:
      body

  t:
    p()  # 编译通过
  ```


无需类型检查的数量可变参数
------------------

除了`untyped` 元类型阻止类型检查外， `varargs[untyped]`中的参数数量也是不确定的。

  ```nim  test = "nim c $1"
  template hideIdentifiers(x: varargs[untyped]) = discard

  hideIdentifiers(undeclared1, undeclared2)
  ```

然而，因为模板不能迭代数量可变参数，这个功能通常在宏中更有用。


模板中的符号绑定
---------------------------

一个模板就是一个卫生宏`hygienic`:idx:，因此也会开启一个新的作用域。大部分符号会在宏的定义域中绑定。

  ```nim
  # 模块 A
  var
    lastId = 0

  template genId*: untyped =
    inc(lastId)
    lastId
  ```

  ```nim
  # 模块 B
  import A

  echo genId() # Works as 'lastId' has been bound in 'genId's defining scope
  ```

像在泛型中一样，模板中的符号绑定可以被 `mixin` 或`bind`语句影响。



标识符构建
-----------------------

在模板中，标识符可以通过反引号标注进行构建

  ```nim  test = "nim c $1"
  template typedef(name: untyped, typ: typedesc) =
    type
      `T name`* {.inject.} = typ
      `P name`* {.inject.} = ref `T name`

  typedef(myint, int)
  var x: PMyInt
  ```

在这个例子中， `name` 参数实例化为`myint`类型，所以\`T name\` 变成了`Tmyint`。


模板参数中的查找规则

模板中的一个参数 `p`总是被替换为`x.p`这样的表达式。因此，模板参数可像字段名称一样使用，且一个全局符号会被一个合法的同名参数覆盖：

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

但是全局符号可以通过`bind` 语句适时地捕获。

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


模板中的卫生
--------------------

默认地，模板是卫生的`hygienic`:idx:。模板中的本地标识符被声明后，无法在模板实例所处的上下文中访问。

  ```nim  test = "nim c $1"
  template newException*(exceptn: typedesc, message: string): untyped =
    var
      e: ref exceptn  # e 在这里被隐式地定义
    new(e)
    e.msg = message
    e

  # 这是可以工作的:
  let e = "message"
  raise newException(IoError, e)
  ```


模板中声明的一个符号是否向实例所处作用域中公开取决于`inject`:idx:和 `gensym`:idx:编译标志。被`gensym`编译标志标记的符号不会被公开，而`inject`编译标志反之。

`type`, `var`, `let` 和 `const`等实体符号默认是`gensym` 的， `proc`, `iterator`, `converter`, `template`,
`macro` 等默认是 `inject`的。而如果一个实体的名字是由模板参数传递的，其将总被标记为`inject`的。

  ```nim
  template withFile(f, fn, mode: untyped, actions: untyped): untyped =
    block:
      var f: File  # 因为'f' 是一个模板参数，其是被标记为`inject`的
      ...

  withFile(txt, "ttempl3.txt", fmWrite):
    txt.writeLine("line 1")
    txt.writeLine("line 2")
  ```


 `inject` 和`gensym` 编译标志是两个类附注；它们在模板定义之外没有语义，不能被抽象出来。

  ```nim
  {.pragma myInject: inject.}

  template t() =
    var x {.myInject.}: int # 无法工作
  ```


为摆脱模板中的卫生，可使用`dirty`:idx:编译标志标记模板， `inject` 和 `gensym` 无法作用于标记为 `dirty` 的模板

被标记为`gensym`的符号无法作为`field`使用在`x.field` 语义中。也不能用于 `ObjectConstruction(field: value)`和 `namedParameterCall(field = value)` 语义的构建。

其原因如以下代码所示：

  ```nim  test = "nim c $1"
  type
    T = object
      f: int

  template tmp(x: T) =
    let f = 34
    echo x.f, T(f: 4)
  ```


以上代码将按预期工作

而这意味着被`gensym`标记的符号无法应用方法调用语义

  ```nim  test = "nim c $1"  status = 1
  template tmp(x) =
    type
      T {.gensym.} = int

    echo x.T # 无效的: 应该使用:  'echo T(x)'.

  tmp(12)
  ```


方法调用语义的局限性
-------------------------------------

 在像 `x.f` 这样的表达式中的`x` 在确定执行前需要进行语义检查（这意味着符号查找和类型检查），这一过程中其将被写作 `f(x)`的形式。因此，当`.`语义用于调用模板和宏时有一些局限性。

  ```nim  test = "nim c $1"  status = 1
  template declareVar(name: untyped) =
    const name {.inject.} = 45

  # 无法通过编译:
  unknownIdentifier.declareVar
  ```


在方法调用语义中，把模块符号用作完全限定的标识符是行不通的。`.`操作符绑定符号的次序禁止这样做。

  ```nim  test = "nim c $1"  status = 1
  import std/sequtils

  var myItems = @[1,3,3,7]
  let N1 = count(myItems, 3) # 可行
  let N2 = sequtils.count(myItems, 3) # 完全被限定, 此处可行
  let N3 = myItems.count(3) # 可行
  let N4 = myItems.sequtils.count(3) # 非法的, `myItems.sequtils` 无法被解析
  ```

这意味着，当由于某种原因，某个过程需要通过模块名称消除歧义时，需要以函数调用语法编写调用。

宏
======

宏是一种在编译时运行的特殊函数。通常地，宏的输入是代码传递的抽象语法树（AST）。然后宏可以对其执行转换并将转换后的AST的结果返回。这可以被用来添加自定义语言功能，并实现域特定语言`domain-specific languages`:idx:。

宏的语义分析并不完全是从上到下和从左到右的。相反，语义分析至少发生两次：

* 语义分析识别并解析宏调用。
* 编译器执行宏正文（可能会调用其他进程）。
* 将宏调用的AST替换为返回的AST。
* 再次对该区域的代码进行语义分析。
* 如果宏返回的AST包含其他宏调用，则此过程将迭代进行。

虽然宏支持编译时的代码转换，但它们无法更改 Nim 的语法

**样式说明：** 为了提高代码的可读性，最好使用简洁而富表现力的编程结构。建议如下：

（1）首先尽可能使用普通的过程和迭代器。
（2）其次尽可能使用泛型过程和迭代器。
（3）再次尽可能使用模板。
（4）最后才考虑使用宏。

Debug例子
-------------

以下例子展现了通过接受可变数量参数的有效`debug`命令

  ```nim  test = "nim c $1"
  # 要使用Nim语法树，我们需要一个在“宏”模块中定义的API
  import std/macros

  macro debug(args: varargs[untyped]): untyped =
    # `args` 是一个 `NimNode` 值的集合，其中每一个值都包含了一个传递给宏参数的AST
    #一个宏总是返回一个`NimNode`.
    #一个`nnkStmtList`节点适合于本用例
    result = nnkStmtList.newTree()
    # 迭代从宏传递过来的任何参数:
    for n in args:
      # 为语句列表添加调用以书写表达式;
      # `toStrLit`将AST转换为其字符串表达形式:
      result.add newCall("write", newIdentNode("stdout"), newLit(n.repr))
      # 为语句列表添加调用以添加": "
      result.add newCall("write", newIdentNode("stdout"), newLit(": "))
      #为语句列表添加调用以填写值:
      result.add newCall("writeLine", newIdentNode("stdout"), n)

  var
    a: array[0..10, int]
    x = "some string"
  a[0] = 42
  a[1] = 45

  debug(a[0], a[1], x)
  ```

这个宏调用后将展开为以下代码：

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


传递给`varargs` 参数的参数被包装在数组构造函数表达式中。这就是为什么`debug` 会迭代所有“`args`的子级的原因。


bindSym
-------

上面的`debug` 宏依赖于这样一个事实，即`write`，`writeLine`和`stdout` 在系统模块中已被声明，而且在实例的上下文中总是可见地。有一种方法可以使用绑定标识符（即 `symbols`:idx:）以替换未绑定的标识符。内置的 `bindSym`可用于此目的。

  ```nim  test = "nim c $1"
  import std/macros

  macro debug(n: varargs[typed]): untyped =
    result = newNimNode(nnkStmtList, n)
    for x in n:
      # 我们可以通过'bindSym'在作用域中绑定符号:
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

这个宏调用后将展开为以下代码：

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

但是，符号 `write`，`writeLine` 和`stdout` 已经绑定，且不会再次查找。如示例所示，`bindSym` 确实可以隐式地处理重载符号

请注意，传递给`bindSym` 的符号名称必须是常量。实验功能 `dynamicBindSym` (`experimental manual
<manual_experimental.html#dynamic-arguments-for-bindsym>`_)
允许动态地计算此值

Post-statement blocks
---------------------

Macros can receive `of`, `elif`, `else`, `except`, `finally` and `do`
blocks (including their different forms such as `do` with routine parameters)
as arguments if called in statement form.

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


For loop macro
--------------

A macro that takes as its only input parameter an expression of the special
type `system.ForLoopStmt` can rewrite the entirety of a `for` loop:

  ```nim  test = "nim c $1"
  import std/macros

  macro example(loop: ForLoopStmt) =
    result = newTree(nnkForStmt)    # Create a new For loop.
    result.add loop[^3]             # This is "item".
    result.add loop[^2][^1]         # This is "[1, 2, 3]".
    result.add newCall(bindSym"echo", loop[0])

  for item in example([1, 2, 3]): discard
  ```

Expands to:

  ```nim
  for item in items([1, 2, 3]):
    echo item
  ```

Another example:

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


Case statement macros
---------------------

Macros named `` `case` `` can provide implementations of `case` statements
for certain types. The following is an example of such an implementation
for tuples, leveraging the existing equality operator for tuples
(as provided in `system.==`):

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

`case` macros are subject to overload resolution. The type of the
`case` statement's selector expression is matched against the type
of the first argument of the `case` macro. Then the complete `case`
statement is passed in place of the argument and the macro is evaluated.

In other words, the macro needs to transform the full `case` statement
but only the statement's selector expression is used to determine which
macro to call.


Special 类型
=============

static[T]
---------

As their name suggests, static parameters must be constant expressions:

  ```nim
  proc precompiledRegex(pattern: static string): RegEx =
    var res {.global.} = re(pattern)
    return res

  precompiledRegex("/d+") # Replaces the call with a precompiled
                          # regex, stored in a global variable

  precompiledRegex(paramStr(1)) # Error, command-line options
                                # are not constant expressions
  ```


For the purposes of code generation, all static params are treated as
generic params - the proc will be compiled separately for each unique
supplied value (or combination of values).

Static params can also appear in the signatures of generic types:

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

Please note that `static T` is just a syntactic convenience for the underlying
generic type `static[T]`. The type param can be omitted to obtain the type
class of all constant expressions. A more specific type class can be created by
instantiating `static` with another type class.

One can force an expression to be evaluated at compile time as a constant
expression by coercing it to a corresponding `static` type:

  ```nim
  import std/math

  echo static(fac(5)), " ", static[bool](16.isPowerOfTwo)
  ```

The compiler will report any failure to evaluate the expression or a
possible type mismatch error.

typedesc[T]
-----------

In many contexts, Nim treats the names of types as regular
values. These values exist only during the compilation phase, but since
all values must have a type, `typedesc` is considered their special type.

`typedesc` acts as a generic type. For instance, the type of the symbol
`int` is `typedesc[int]`. Just like with regular generic types, when the
generic param is omitted, `typedesc` denotes the type class of all types.
As a syntactic convenience, one can also use `typedesc` as a modifier.

Procs featuring `typedesc` params are considered implicitly generic.
They will be instantiated for each unique combination of supplied types,
and within the body of the proc, the name of each param will refer to
the bound concrete type:

  ```nim
  proc new(T: typedesc): ref T =
    echo "allocating ", T.name
    new(result)

  var n = Node.new
  var tree = new(BinaryTree[int])
  ```

When multiple type params are present, they will bind freely to different
types. To force a bind-once behavior, one can use an explicit generic param:

  ```nim
  proc acceptOnlyTypePairs[T, U](A, B: typedesc[T]; C, D: typedesc[U])
  ```

Once bound, type params can appear in the rest of the proc signature:

  ```nim  test = "nim c $1"
  template declareVariableWithType(T: typedesc, value: T) =
    var x: T = value

  declareVariableWithType int, 42
  ```


Overload resolution can be further influenced by constraining the set
of types that will match the type param. This works in practice by
attaching attributes to types via templates. The constraint can be a
concrete type or a type class.

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

Passing `typedesc` is almost identical, just with the difference that
the macro is not instantiated generically. The type expression is
simply passed as a `NimNode` to the macro, like everything else.

  ```nim
  import std/macros

  macro forwardType(arg: typedesc): typedesc =
    # `arg` is of type `NimNode`
    let tmp: NimNode = arg
    result = tmp

  var tmp: forwardType(int)
  ```

typeof operator
---------------

**Note**: `typeof(x)` can for historical reasons also be written as
`type(x)` but `type(x)` is discouraged.

One can obtain the type of a given expression by constructing a `typeof`
value from it (in many other languages this is known as the `typeof`:idx:
operator):

  ```nim
  var x = 0
  var y: typeof(x) # y has type int
  ```


If `typeof` is used to determine the result type of a proc/iterator/converter
call `c(X)` (where `X` stands for a possibly empty list of arguments), the
interpretation, where `c` is an iterator, is preferred over the
other interpretations, but this behavior can be changed by
passing `typeOfProc` as the second argument to `typeof`:

  ```nim  test = "nim c $1"
  iterator split(s: string): string = discard
  proc split(s: string): seq[string] = discard

  # since an iterator is the preferred interpretation, `y` has the type `string`:
  assert typeof("a b c".split) is string

  assert typeof("a b c".split, typeOfProc) is seq[string]
  ```



Modules
=======
Nim supports splitting a program into pieces by a module concept.
Each module needs to be in its own file and has its own `namespace`:idx:.
Modules enable `information hiding`:idx: and `separate compilation`:idx:.
A module may gain access to the symbols of another module by the `import`:idx:
statement. `Recursive module dependencies`:idx: are allowed, but are slightly
subtle. Only top-level symbols that are marked with an asterisk (`*`) are
exported. A valid module name can only be a valid Nim identifier (and thus its
filename is ``identifier.nim``).

The algorithm for compiling modules is:

- Compile the whole module as usual, following import statements recursively.

- If there is a cycle, only import the already parsed symbols (that are
  exported); if an unknown identifier occurs then abort.

This is best illustrated by an example:

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


Import statement
----------------

After the `import` statement, a list of module names can follow or a single
module name followed by an `except` list to prevent some symbols from being
imported:

  ```nim  test = "nim c $1"  status = 1
  import std/strutils except `%`, toUpperAscii

  # doesn't work then:
  echo "$1" % "abc".toUpperAscii
  ```


It is not checked that the `except` list is really exported from the module.
This feature allows us to compile against an older version of the module that
does not export these identifiers.

The `import` statement is only allowed at the top level.


Include statement
-----------------

The `include` statement does something fundamentally different than
importing a module: it merely includes the contents of a file. The `include`
statement is useful to split up a large module into several files:

  ```nim
  include fileA, fileB, fileC
  ```

The `include` statement can be used outside the top level, as such:

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


Module names in imports
-----------------------

A module alias can be introduced via the `as` keyword:

  ```nim
  import std/strutils as su, std/sequtils as qu

  echo su.format("$1", "lalelu")
  ```

The original module name is then not accessible. The notations
`path/to/module` or `"path/to/module"` can be used to refer to a module
in subdirectories:

  ```nim
  import lib/pure/os, "lib/pure/times"
  ```

Note that the module name is still `strutils` and not `lib/pure/strutils`,
thus one **cannot** do:

  ```nim
  import lib/pure/strutils
  echo lib/pure/strutils.toUpperAscii("abc")
  ```

Likewise, the following does not make sense as the name is `strutils` already:

  ```nim
  import lib/pure/strutils as strutils
  ```


Collective imports from a directory
-----------------------------------

The syntax `import dir / [moduleA, moduleB]` can be used to import multiple modules
from the same directory.

Path names are syntactically either Nim identifiers or string literals. If the path
name is not a valid Nim identifier it needs to be a string literal:

  ```nim
  import "gfx/3d/somemodule" # in quotes because '3d' is not a valid Nim identifier
  ```


Pseudo import/include paths
---------------------------

A directory can also be a so-called "pseudo directory". They can be used to
avoid ambiguity when there are multiple modules with the same path.

There are two pseudo directories:

1. `std`: The `std` pseudo directory is the abstract location of Nim's standard
   library. For example, the syntax `import std / strutils` is used to unambiguously
   refer to the standard library's `strutils` module.
2. `pkg`: The `pkg` pseudo directory is used to unambiguously refer to a Nimble
   package. However, for technical details that lie outside the scope of this document,
   its semantics are: *Use the search path to look for module name but ignore the standard
   library locations*. In other words, it is the opposite of `std`.

It is recommended and preferred but not currently enforced that all stdlib module imports include the std/ "pseudo directory" as part of the import name.

From import statement
---------------------

After the `from` statement, a module name followed by
an `import` to list the symbols one likes to use without explicit
full qualification:

  ```nim  test = "nim c $1"
  from std/strutils import `%`

  echo "$1" % "abc"
  # always possible: full qualification:
  echo strutils.replace("abc", "a", "z")
  ```

It's also possible to use `from module import nil` if one wants to import
the module but wants to enforce fully qualified access to every symbol
in `module`.


Export statement
----------------

An `export` statement can be used for symbol forwarding so that client
modules don't need to import a module's dependencies:

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

When the exported symbol is another module, all of its definitions will
be forwarded. One can use an `except` list to exclude some of the symbols.

Notice that when exporting, one needs to specify only the module name:

  ```nim
  import foo/bar/baz
  export baz
  ```



Scope rules
-----------
Identifiers are valid from the point of their declaration until the end of
the block in which the declaration occurred. The range where the identifier
is known is the scope of the identifier. The exact scope of an
identifier depends on the way it was declared.

### Block scope

The *scope* of a variable declared in the declaration part of a block
is valid from the point of declaration until the end of the block. If a
block contains a second block, in which the identifier is redeclared,
then inside this block, the second declaration will be valid. Upon
leaving the inner block, the first declaration is valid again. An
identifier cannot be redefined in the same block, except if valid for
procedure or iterator overloading purposes.


### Tuple or object scope

The field identifiers inside a tuple or object definition are valid in the
following places:

* To the end of the tuple/object definition.
* Field designators of a variable of the given tuple/object type.
* In all descendant types of the object type.

### Module scope

All identifiers of a module are valid from the point of declaration until
the end of the module. Identifiers from indirectly dependent modules are *not*
available. The `system`:idx: module is automatically imported in every module.

If a module imports an identifier by two different modules, each occurrence of
the identifier has to be qualified unless it is an overloaded procedure or
iterator in which case the overloading resolution takes place:

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


Packages
--------
A collection of modules in a file tree with an ``identifier.nimble`` file in the
root of the tree is called a Nimble package. A valid package name can only be a
valid Nim identifier and thus its filename is ``identifier.nimble`` where
``identifier`` is the desired package name. A module without a ``.nimble`` file
is assigned the package identifier: `unknown`.

The distinction between packages allows diagnostic compiler messages to be
scoped to the current project's package vs foreign packages.



Compiler Messages
=================

The Nim compiler emits different kinds of messages: `hint`:idx:,
`warning`:idx:, and `error`:idx: messages. An *error* message is emitted if
the compiler encounters any static error.



Pragmas
=======

Pragmas are Nim's method to give the compiler additional information /
commands without introducing a massive number of new keywords. Pragmas are
processed on the fly during semantic checking. Pragmas are enclosed in the
special `{.` and `.}` curly brackets. Pragmas are also often used as a
first implementation to play with a language feature before a nicer syntax
to access the feature becomes available.


deprecated pragma
-----------------

The deprecated pragma is used to mark a symbol as deprecated:

  ```nim
  proc p() {.deprecated.}
  var x {.deprecated.}: char
  ```

This pragma can also take in an optional warning string to relay to developers.

  ```nim
  proc thing(x: bool) {.deprecated: "use thong instead".}
  ```



compileTime pragma
------------------
The `compileTime` pragma is used to mark a proc or variable to be used only
during compile-time execution. No code will be generated for it. Compile-time
procs are useful as helpers for macros. Since version 0.12.0 of the language, a
proc that uses `system.NimNode` within its parameter types is implicitly
declared `compileTime`:

  ```nim
  proc astHelper(n: NimNode): NimNode =
    result = n
  ```

Is the same as:

  ```nim
  proc astHelper(n: NimNode): NimNode {.compileTime.} =
    result = n
  ```

`compileTime` variables are available at runtime too. This simplifies certain
idioms where variables are filled at compile-time (for example, lookup tables)
but accessed at runtime:

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


noreturn pragma
---------------
The `noreturn` pragma is used to mark a proc that never returns.


acyclic pragma
--------------
The `acyclic` pragma can be used for object types to mark them as acyclic
even though they seem to be cyclic. This is an **optimization** for the garbage
collector to not consider objects of this type as part of a cycle:

  ```nim
  type
    Node = ref NodeObj
    NodeObj {.acyclic.} = object
      left, right: Node
      data: string
  ```

Or if we directly use a ref object:

  ```nim
  type
    Node {.acyclic.} = ref object
      left, right: Node
      data: string
  ```

In the example, a tree structure is declared with the `Node` type. Note that
the type definition is recursive and the GC has to assume that objects of
this type may form a cyclic graph. The `acyclic` pragma passes the
information that this cannot happen to the GC. If the programmer uses the
`acyclic` pragma for data types that are in reality cyclic, this may result
in memory leaks, but memory safety is preserved.



final pragma
------------
The `final` pragma can be used for an object type to specify that it
cannot be inherited from. Note that inheritance is only available for
objects that inherit from an existing object (via the `object of SuperType`
syntax) or that have been marked as `inheritable`.


shallow pragma
--------------
The `shallow` pragma affects the semantics of a type: The compiler is
allowed to make a shallow copy. This can cause serious semantic issues and
break memory safety! However, it can speed up assignments considerably,
because the semantics of Nim require deep copying of sequences and strings.
This can be expensive, especially if sequences are used to build a tree
structure:

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


pure pragma
-----------
An object type can be marked with the `pure` pragma so that its type field
which is used for runtime type identification is omitted. This used to be
necessary for binary compatibility with other compiled languages.

An enum type can be marked as `pure`. Then access of its fields always
requires full qualification.


asmNoStackFrame pragma
----------------------
A proc can be marked with the `asmNoStackFrame` pragma to tell the compiler
it should not generate a stack frame for the proc. There are also no exit
statements like `return result;` generated and the generated C function is
declared as `__declspec(naked)`:c: or `__attribute__((naked))`:c: (depending on
the used C compiler).

**Note**: This pragma should only be used by procs which consist solely of
assembler statements.

error pragma
------------
The `error` pragma is used to make the compiler output an error message
with the given content. The compilation does not necessarily abort after an error
though.

The `error` pragma can also be used to
annotate a symbol (like an iterator or proc). The *usage* of the symbol then
triggers a static error. This is especially useful to rule out that some
operation is valid due to overloading and type conversions:

  ```nim
  ## check that underlying int values are compared and not the pointers:
  proc `==`(x, y: ptr int): bool {.error.}
  ```


fatal pragma
------------
The `fatal` pragma is used to make the compiler output an error message
with the given content. In contrast to the `error` pragma, the compilation
is guaranteed to be aborted by this pragma. 示例：

  ```nim
  when not defined(objc):
    {.fatal: "Compile this program with the objc command!".}
  ```

warning pragma
--------------
The `warning` pragma is used to make the compiler output a warning message
with the given content. Compilation continues after the warning.

hint pragma
-----------
The `hint` pragma is used to make the compiler output a hint message with
the given content. Compilation continues after the hint.

line pragma
-----------
The `line` pragma can be used to affect line information of the annotated
statement, as seen in stack backtraces:

  ```nim
  template myassert*(cond: untyped, msg = "") =
    if not cond:
      # change run-time line information of the 'raise' statement:
      {.line: instantiationInfo().}:
        raise newException(AssertionDefect, msg)
  ```

If the `line` pragma is used with a parameter, the parameter needs to be a
`tuple[filename: string, line: int]`. If it is used without a parameter,
`system.instantiationInfo()` is used.


linearScanEnd pragma
--------------------
The `linearScanEnd` pragma can be used to tell the compiler how to
compile a Nim `case`:idx: statement. Syntactically it has to be used as a
statement:

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

In the example, the case branches `0` and `1` are much more common than
the other cases. Therefore, the generated assembler code should test for these
values first so that the CPU's branch predictor has a good chance to succeed
(avoiding an expensive CPU pipeline stall). The other cases might be put into a
jump table for O(1) overhead but at the cost of a (very likely) pipeline
stall.

The `linearScanEnd` pragma should be put into the last branch that should be
tested against via linear scanning. If put into the last branch of the
whole `case` statement, the whole `case` statement uses linear scanning.


computedGoto pragma
-------------------
The `computedGoto` pragma can be used to tell the compiler how to
compile a Nim `case`:idx: in a `while true` statement.
Syntactically it has to be used as a statement inside the loop:

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

As the example shows, `computedGoto` is mostly useful for interpreters. If
the underlying backend (C compiler) does not support the computed goto
extension the pragma is simply ignored.


immediate pragma
----------------

The immediate pragma is obsolete. See `Typed vs untyped parameters
<#templates-typed-vs-untyped-parameters>`_.


compilation option pragmas
--------------------------
The listed pragmas here can be used to override the code generation options
for a proc/method/converter.

The implementation currently provides the following possible options (various
others may be added later).

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

示例：

  ```nim
  {.checks: off, optimization: speed.}
  # compile without runtime checks and optimize for speed
  ```


push and pop pragmas
--------------------
The `push/pop`:idx: pragmas are very similar to the option directive,
but are used to override the settings temporarily. 示例：

  ```nim
  {.push checks: off.}
  # compile this section without runtime checks as it is
  # speed critical
  # ... some code ...
  {.pop.} # restore old settings
  ```

`push/pop`:idx: can switch on/off some standard library pragmas, example:

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

For third party pragmas, it depends on its implementation but uses the same syntax.


register pragma
---------------
The `register` pragma is for variables only. It declares the variable as
`register`, giving the compiler a hint that the variable should be placed
in a hardware register for faster access. C compilers usually ignore this
though and for good reasons: Often they do a better job without it anyway.

However, in highly specific cases (a dispatch loop of a bytecode interpreter
for example) it may provide benefits.


global pragma
-------------
The `global` pragma can be applied to a variable within a proc to instruct
the compiler to store it in a global location and initialize it once at program
startup.

  ```nim
  proc isHexNumber(s: string): bool =
    var pattern {.global.} = re"[0-9a-fA-F]+"
    result = s.match(pattern)
  ```

When used within a generic proc, a separate unique global variable will be
created for each instantiation of the proc. The order of initialization of
the created global variables within a module is not defined, but all of them
will be initialized after any top-level variables in their originating module
and before any variable in a module that imports it.

Disabling certain messages
--------------------------
Nim generates some warnings and hints ("line too long") that may annoy the
user. A mechanism for disabling certain messages is provided: Each hint
and warning message contains a symbol in brackets. This is the message's
identifier that can be used to enable or disable it:

  ```Nim
  {.hint[LineTooLong]: off.} # turn off the hint about too long lines
  ```

This is often better than disabling all warnings at once.


used pragma
-----------

Nim produces a warning for symbols that are not exported and not used either.
The `used` pragma can be attached to a symbol to suppress this warning. This
is particularly useful when the symbol was generated by a macro:

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

`used` can also be used as a top-level statement to mark a module as "used".
This prevents the "Unused import" warning:

  ```nim
  # module: debughelper.nim
  when defined(nimHasUsed):
    # 'import debughelper' is so useful for debugging
    # that Nim shouldn't produce a warning for that import,
    # even if currently unused:
    {.used.}
  ```


expermimental 的编译指示
-------------------

`expermimental` 编译指示用于启用实验性的语言功能。 取决于具体的特性 这意味着该特性要么被认为是 过于不稳定，要么特性 的未来是不确定的(它可能随时被删除)。 详情请参阅 `expermimental 手册 <manual_experimental.html>`_ 。

示例：

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


作为顶层的语句时，expermimental 编译指示启用功能为 一个模块的余下的所有部分。 这对于横跨模块范围的宏和通用的 实例是有问题的。 所以，这些用法必须是 被放入一个 `.push/pop` 环境中：

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
===============================

本节介绍当前Nim实现 所支持的额外的编译指示，但不应将其视为语言说明的一部分。

Bitsize 编译指示
--------------

`bitsize` 是对象字段成员的编译指示。 这表明该字段为 是C/C++中的一个位域。

  ```Nim
  type
    mybitfield = object
      flag {.bitsize:1.}: cuint
  ```

生成：

  ```C
  struct mybitfield {
    unsigned int flag:1;
  };
  ```


Align 编译指示
------------

`align`:idx: 编译指示是针对变量和对象字段成员的。 它 用于修改所声明的实体的字节对齐要求。 参数必须是 2 的幂。 有效的非 0 对齐的编译标记同时存在声明的时候，弱的编译标记 会被忽略。 与类型的 对齐要求相比较弱的对齐编译标记的声明也会被忽略。

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
--------------

从 Nim 编译器版本 1.4 ，有一个 `.noalias` 注解用于变量 和参数。 它被直接映射到 C/C++ 的 `restrict`:c: 关键字，并表示 底部指向内存中的一个独特位置， 此位置不存在其他别名。 *unchecked*遵守此别名限制。 如果违反了 限制，后端优化器可以自由地编译代码。 这是一个 **不安全的** 语言功能。

理想情况下，在 Nim 之后的版本中，该限制将在 编译时间强制执行。 (这也是为什么选择 `noalias` 的名字，而不是描述更 详细的名字，如 `unsafeAssumeNoAlias`。)


Volatile 编译指示
---------------
`volatile` 编译指示仅用于变量。 它宣布变量为 `volatile`:c:, 不论 C/C++ 中 volatile 代表什么含义 (其语义在 C/C+++中是没有明确定义的)。

**注意**: LLVM 后端不存在这种编译指示。



nodecl 编译指示
-------------
`nodell` 编译指示可以应用于几乎任何符号（变量，程序， 类型等）。 有时在与 C 的相互操作上很有用： <0>nodell</0> 编译指示会告诉 Nim, 不要生成在 C 代码中的符号的声明。 例如：

  ```Nim
  var
    EACCES {.importc, nodecl.}: cint # pretend EACCES was a variable, as
                                     # Nim does not know its value
  ```

然而， `header` 编译指示常是更好的选择。

**注意**: 这在 LLVM 后端无法使用。


Header 编译指示
-------------
`header` 编译指示和 `nodecl` 编译指示非常相似:几乎可以在任何符号和不应声明的 specifies 上应用，与之替代的是，生成代码会包含一个 `#include`:c:\:

  ```Nim
  type
    PFile {.importc: "FILE*", header: "<stdio.h>".} = distinct pointer
      # import C's FILE* type; Nim will treat it as a new pointer type
  ```

`header` 编译指示总是需要一个字符串常量。 字符串常量 包含头文件：和 C 的正常使用一样，头文件需要用尖括号包起来 ︰ `<>`:c:。 如果没有给出尖括号，Nim 会在生成的 C 代码中用 `""`:c: 把头文件放在一起。

**注意**: LLVM 后端不存在这种编译指示。


IncompleteStruct 编译指示
-----------------------
`incompleteStruct` 编译指示告诉编译器不要使用 底层 C 的`结构`:c: 在 `sizeof` 表达式中：

  ```Nim
  type
    DIR* {.importc: "DIR", header: "<dirent.h>",
           pure, incompleteStruct.} = object
  ```


Compile 编译指示
--------------
`compile` 编译指示可以将一个 C/C++ 源文件用于编译和链接到项目：

  ```Nim
  {.compile: "myfile.cpp".}
  ```

**注意**: Nim 通过计算 SHA1 校验和，并且只在文件 已经更改时重新编译文件。 可以使用 `-f`:option: 命令行选项来强制重新编译 文件。

从 1.4 开始， `compile` 编译指示也可以使用此语法：

  ```Nim
  {.compile("myfile.cpp", "--custom flags here").}
  ```

可以从例子中看出。 这种方式允许自定义标识 在重新编译文件时传给 C 编译器。


Link 编译指示
-----------
`link` 编译指示可以用来将附加文件与项目链接：

  ```Nim
  {.link: "myfile.o".}
  ```


passc 编译指示
------------
`passc` 编译指示可以用来传递额外参数到 C 编译器，就像命令行使用的 `--passc`:option:\：

  ```Nim
  {.passc: "-Wall -Werror".}
  ```

请注意，可以从`系统模块<system.html>`中使用 `gorge` 这会在语义分析中嵌入将执行的外部命令的参数：

  ```Nim
  {.passc: gorge("pkg-config --cflags sdl").}
  ```


localPassC 编译指示
-----------------
`localPassC` 编译指示可以用来传递附加参数到 C 编译器。 但仅适用于 Nim 模块包含该编译指示生成的 C/C++ 文件 ：

  ```Nim
  # Module A.nim
  # 生成： A.nim.cpp
  {.localPassC: "-Wall -Werror".} # Passed when compiling A.nim.cpp
  ```


passl 编译指示
------------
`passc` 编译指示可以用来传递额外参数到 C 链接器，就像在命令行使用的 `--passc`:option:\：

  ```Nim
  {.passl: "-lSDLmain -lSDL".}
  ```

请注意，可以从`系统模块<system.html>`中使用 `gorge` 这会在语义分析中嵌入将执行的外部命令的参数：

  ```Nim
  {.passl: gorge("pkg-config --libs sdl").}
  ```


Emit pragma
-----------
The `emit` pragma can be used to directly affect the output of the
compiler's code generator. The code is then unportable to other code
generators/backends. Its usage is highly discouraged! However, it can be
extremely useful for interfacing with `C++`:idx: or `Objective C`:idx: code.

示例：

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

`nimbase.h` 定义了 `NIM_EXTERNC`:c: C宏，可以用于 `extern "C"`:cpp: 代码可以同时用于 `nim c`:cmd: 和 `nim cpp`:cmd:, 例如：

  ```Nim
  proc foobar() {.importc:"$1".}
  {.emit: """
  #include <stdio.h>
  NIM_EXTERNC
  void fun(){}
  """.}
  ```

.. 注意:: 为了向后兼容，如果到 `emit` 语句的参数 是一个单个字符串， Nim 符号可以通过反引号进行引用。 但这种用法已经废弃。

对于在顶层的 emit 声明语句， 生成的 C/C++ 文件 中的代码应该被 emit 的部分可以通过前缀 `/*TYPEECTION* /`:c: 或 `/*VARSECTION* /`:c: 或 `/*INCLUDESECTION*`:c:\：

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
----------------

**注意**: `c2nim <https://github.com/nim-lang/c2nim/blob/master/doc/c2nim.rst>`_ 可以解析大量 C++ 的子集并知道 关于` importCpp ` 编译指示的模式语言。 不需要 知道这里描述的所有细节。


类似于对C 的 `importc 编译指示
<#foreign function-interface-importc-pralma>`_, `importc` 编译指示可以用来导入 `C++`:idx: 方法或 C++ 符号 。 生成的代码使用 C++ 方法调用 语法： `obj->method(arg)`:cpp:。 结合 `header` 和 `emit` 编译标记，这允许 *sloppy* 接口使用 C++ 的库:

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

需要告诉编译器生成 C++ (命令 `cpp`:option:) 才能工作 。 当编译器 emit C++ 代码时，条件符号 `cpp` 已被定义。

### 命名空间

*sloppy interfacing* 示例使用 `.emit` 来生成`using namespace`:cpp: 声明。 转而通过 `namespace::identifier`:cpp: 注解来引用导入的名称 通常要好得多：

  ```nim
  type
    IrrlichtDeviceObj {.header: irr,
                        importcpp: "irr::IrrlichtDevice".} = object
  ```


### Importcpp 在枚举的使用

`importcpp` 应用于枚举类型时，数字枚举值 使用 C++ 枚举类型注解， 类似于这个例子： `((TheCppEnum)(3))`:cpp:。 (这已经是最简单的实现方式了。)


### Importcpp 在 proc 中的使用

请注意，procs 中的 `importcpp` 变体使用了一种更加晦涩的模式 语言来实现最大的灵活性：


- 哈希 `#` 符号会被第一个或下一个参数所取代。
- 哈希符号加个点 `#.` 表示调用应该使用 C++'s 的点 或箭头符号。
- 符号 `@` 被剩余参数替换。 通过逗号分隔。

例如：

  ```nim
  proc cppMethod(this: CppObj, a, b, c: cint) {.importcpp: "#.CppMethod(@)".}
  var x: ptr CppObj
  cppMethod(x[], 1, 2, 3)
  ```

生成：

  ```C
  x->CppMethod(1, 2, 3)
  ```

作为一项特殊规则，以保持与旧版本的 `importcpp` 编译指示的兼容性， 如果没有任何特殊的模式 字符 ( `# ' @`中的任意一个)，则会假定使用 C++'s 点数或箭头符号被假定，因此上面的示例也可以写为：

  ```nim
  proc cppMethod(this: CppObj, a, b, c: cint) {.importcpp: "CppMethod".}
  ```

请注意，模式语言当然也包括C++的操作符重载的能力：

  ```nim
  proc vectorAddition(a, b: Vec3): Vec3 {.importcpp: "# + #".}
  proc dictLookup(a: Dict, k: Key): Value {.importcpp: "#[#]".}
  ```


- 撇号`'` 之后是一个整数 `i` 取值为 0..9 范围内 将会被第 i 个参数 *type* 替换。 第 0 个位置是返回值的 类型。 这可以用来传递类型到 C++ 函数模板。 在 `'` 与数字之间，可以使用星号来获取类型的基本类型 。 (它会从 T* 中“拿走 *”。 比如 `T*`:c: 变成 `T`。) 两个星号 ** 可以用来获取元素类型的类型。

例如：

  ```nim
  type Input {.importcpp: "System::Input".} = object
  proc getSubsystem*[T](): ptr T {.importcpp: "SystemManager::getSubsystem<'*0>()", nodecl.}

  let x: ptr Input = getSubsystem[Input]()
  ```

生成：

  ```C
  x = SystemManager::getSubsystem<System::Input>()
  ```


- `#@` 是支持 `cnew` 操作的特殊情况。 在直接 inline 内联的，这是必需的 这样调用表达式才无需通过 临时位置调用。 这只是为了绕过 当前代码生成器的限制。

例如，C++'s `new`:cpp: 运算符可以像这样“导入”：

  ```nim
  proc cnew*[T](x: T): ptr T {.importcpp: "(new '*0#@)", nodecl.}

  # constructor of 'Foo':
  proc constructFoo(a, b: cint): Foo {.importcpp: "Foo(@)".}

  let x = cnew constructFoo(3, 4)
  ```

生成：

  ```C
  x = new Foo(3, 4)
  ```

然而，根据使用情况 `new Foo`:cpp: 也可以像这样包裹：

  ```nim
  proc newFoo(a, b: cint): ptr Foo {.importcpp: "new Foo(@)".}

  let x = newFoo(3, 4)
  ```


### 包装构造函数

有时候C++类有一个私有的构造函数，所以代码 `Class c = Class(1,2)；`:cpp: 是不对的，而应该是 `Class c(1,2);`:cpp:。 要达到这种效果，包装一个 C++ 构造函数的 Nim proc 需要使用 附加注释的 `constructor`:idx: 编译指示 这个编译指示也有助于生成 更快的 C++ 代码，因为构造时不会调用复制构造器：


  ```nim
  # a better constructor of 'Foo':
  proc constructFoo(a, b: cint): Foo {.importcpp: "Foo(@)", constructor.}
  ```


### 包装析构器

既然Nim 直接生成 C++ ，任何析构器都会被 C++ 编译器隐含地调用在作用域出口。 这意味着可以完全不包装析构器！ 然而，当需要显式调用 时，它需要包装。 模式语言提供这里 所需一切：

  ```nim
  proc destroyFoo(this: var Foo) {.importcpp: "#.~Foo()".}
  ```


### 包装析构器

既然Nim 直接生成 C++ ，任何析构器都会被 C++ 编译器隐含地调用在作用域出口。 这意味着可以完全不包装析构器！ 然而，当需要显式调用 时，它需要包装。 模式语言提供这里 所需一切：

  ```nim  test = "nim cpp $1"
  type
    StdMap[K, V] {.importcpp: "std::map", header: "<map>".} = object
  proc `[]=`[K, V](this: var StdMap[K, V]; key: K; val: V) {.
    importcpp: "#[#] = #", header: "<map>".}

  var x: StdMap[cint, cdouble]
  x[6] = 91.4
  ```


生成：

  ```C
  std::map<int, double> x;
  x[6] = 91.4;
  ```


- 如果需要更确切的控制的话。 撇号 `'` 可以在可以支持的 模式中来表示通用类型的具体类型参数。 了解更多详情，请参阅 proc 模式中撇号运算符的用法。


    ```nim
    type
      VectorIterator {.importcpp: "std::vector<'0>::iterator".} [T] = object

    var x: VectorIterator[cint]
    ```

  生成：

    ```C

    std::vector<int>::iterator x;
    ```


ImportJs 编译指示
---------------

类似于 `importcpp pragma for C++ <#implementation-specific-pragmas-importcpp-pragma>`_, `importjs` 编译指示可以用来导入 JavaScript 的方法或者符号。 生成的代码会使用 Javascript 方法 调用语法： `obj.method(arg)`



ImportObjC 编译指示
-----------------
类似于 `importc pragma for C
<#foreign-function-interface-importc-pragma>`_, `importobjc` 编译指示可以用来导入 `Objective C`:idx: 的方法。 生成的代码会使用 Objective C 的方法 调用语法： `[obj method param1: arg]`。 结合 `header` 和 `emit` 编译标记，这允许 *sloppy* 接口使用 Objective C 的库:


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

需要告诉编译器生成 Objective C(命令 `objc`:option:) 才能工作 。 当编译器 输出 Objective C 代码时，条件符号 `objc` 会被定义。



CodegenDecl 编译指示
------------------

`codegenDecl`编译指示可以直接影响Nim的代码 生成器。 它接受一个格式字符串，用于决定变量 或程序如何在生成的代码中声明。


对于变量，格式字符串中的$1表示变量 的类型，$2表示变量的名称。

以下 Nim 代码：


  ```nim
  var
    a {.codegenDecl: "$# progmem $#".}: int
  ```

将生成此 C 代码：

  ```c
  int progmem a
  ```

就程序而言，$1是程序的返回值类型，$2是程序 的名字，$3是参数列表。

以下 Nim 代码：

  ```nim
  proc myinterrupt() {.codegenDecl: "__interrupt $# $#$#".} =
    echo "realistic interrupt handler"
  ```

将生成此代码：

  ```c
  __interrupt void myinterrupt()
  ```


`cppNonPod` 编译指示
------------------

`.cppNonPod` 编译指示应该用于非POD `importcpp` 类型，以便他们 ` threadvar` 变量正常工作(尤其是对构造器和析构器而言) 。 这需要 `--tlsEmulation:off`:option:。


  ```nim
  type Foo {.cppNonPod, importcpp, header: "funs.h".} = object
    x: cint
  proc main()=
    var a {.threadvar.}: Foo
  ```


编译时定义的编译指示
---------------------------

这里列出的编译指示可以用于在编译时间接受 的 `-d/--define`:option: 选项的可选值。

当前的执行提供了以下可能的选项 (以后可能会添加 个其他选项)。



=================  ============================================ 编译指示             描述 =================  ============================================ `intdefine`:idx:   编译时定义读取为整数类型 `strdefine`:idx:   编译时定义读取为 string 类型 `booldefine`:idx:  编译时定义读取为 bool 类型 =================  ============================================


  ```nim
  const FooBar {.intdefine.}: int = 5
  echo FooBar
  ```

  ```cmd
  nim c -d:FooBar=42 foobar.nim
  ```

在上述例子中， 提供 `-d`:option: 标志使得符号 `FooBar` 在编译时被覆盖，打印出 42。 如果删除 `-d:FooBar=42`:option: ，则使用默认值 5。 要查看是否提供了一个值， 可以使用`defined(FooBar)`。

语法 `-d:flag`:option: 实际上只是 `-d:flag=true`:option: 的简写。

用户自定义的编译指示：
====================



pragma pragma
-------------

The `pragma` pragma can be used to declare user-defined pragmas. This is
useful because Nim's templates and macros do not affect pragmas.
User-defined pragmas are in a different module-wide scope than all other symbols.
They cannot be imported from a module.

示例：

  ```nim
  when appType == "lib":
    {.pragma: rtl, exportc, dynlib, cdecl.}
  else:
    {.pragma: rtl, importc, dynlib: "client.dll", cdecl.}

  proc p*(a, b: int): int {.rtl.} =
    result = a + b
  ```


在上述例子中。 介绍了一个名为 `rtl` 的新的编译指示，它要么从动态库中导入 一个符号，要么导出动态库 生成的符号。



自定义注解：
------------------
这可以定义自定义类型的编译指示。 自定义编译指示不会直接影响 代码生成，但可以被宏检测到。 使用编译指示 `pragma`: 注解模板来定义自定义编译指示。


  ```nim
  template dbTable(name: string, table_space: string = "") {.pragma.}
  template dbKey(name: string = "", primary_key: bool = false) {.pragma.}
  template dbForeignKey(t: typedesc) {.pragma.}
  template dbIgnore {.pragma.}
  ```


考虑一个对象关系映射 (ORM) 的例子 实现：

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

在本例中，使用自定义编译指示描述如何将 Nim 对象映射到关系数据库的模式。 自定义编译指示可以有 个或更多参数。 要传递多个参数，请使用 模板调用语法之一。 所有参数都指定类型，并且在模板中遵循标准 重载规则。 因此，可以通过名称、varargs 等指定参数默认值。


自定义编译指示可以在所有可以指定原有编译指示的 的地方使用。 可以用来注解proc、模板、类型和变量 定义、语句等。



宏模块包括可用于简化自定义编译指示 访问 `hasCustomPragma`, `getCustomPragmaVal` 详情请访问 `macros <macros.html>`_ 模块文档。 这些宏并不是 魔法。它们做的一切都可以通过逐个遍历对象 表示的 AST 来实现。

更多自定义编译指示示例：

- 更好的序列化/反序列化控制：

    ```nim
    type MyObj = object
      a {.dontSerialize.}: int
      b {.defaultDeserialize: 5.}: int
      c {.serializationKey: "_c".}: string
    ```

- 添加类型用于游戏引擎中 gui 检查：
    ```nim
    type MyComponent = object
      position {.editable, animatable.}: Vector3
      alpha {.editRange: [0.0..1.0], animatable.}: float32
    ```

宏编译指示
-------------



有时可以用编译指示的语法来调用宏和模板。 比如可能可以附加到例程(procs, 迭代器等) 声明或例程类型表达式。 编译器将执行简单的语法转换：

  ```nim
  template command(name: string, def: untyped) = discard

  proc p() {.command("print").} = discard
  ```

翻译为：

  ```nim
  command("print"):
    proc p() = discard
  ```

------

  ```nim
  type
    AsyncEventHandler = proc (x: Event) {.async.}
  ```

翻译为：

  ```nim
  type
    AsyncEventHandler = async(proc (x: Event))
  ```

------

当多个宏编译指示声明应用在同一个声明上，按对左到右的顺序第一个 声明起作用。 然后，这个宏可以选择在其输出中是否保留其余的宏编译指示，它们将以相同的方式进行计算。


还有一些宏编译指示的应用例子，例如类型、 变量和常量声明等。 但这种使用方式被认为是 实验性的，所以被记录在 `实验性手册
<manual_experimental.html#extended-macro-pragmas>`_ 中。



外部函数接口
==========================

Nim 的 `FFI`:idx: (外部函数接口) 很广泛，只有 一部分将会扩展到其他后端(如LLVM/JavaScript 后端) 会在这里被记录。



Importc 编译指示
--------------
`importc` 编译指示提供了从 C 中导入proc 或变量 的手段。 可选参数需要是包含 C 标识符的字符串。 参数缺失，C 的名字就会和Nim标识符*完全一样*:


.. code-block::
  proc printf(formatstr: cstring) {.header: "<stdio.h>", importc: "printf", varargs.}


当 `importc` 被应用在一个 `let` 语句时它可以忽略它的值，然后 取从 C 产生的值。 这可以用于导入 C 的常量 `const`:c:\:


.. code-block::
  {.emit: "const int cconst = 42;".}

  let cconst {.importc, nodecl.}: cint

  assert cconst == 42

注意，这个编译指示曾在 JS 后端在 JS 对象和函数上被滥用。 其他后端也用同样的名字提供了相同 功能。 另外，当目标语言 没有设置为 C时，其他编译指示可以使用：

 * `importcpp <manual.html#implementation-specific-pragmas-importcpp-pragma>`_
 * `importobjc <manual.html#implementation-specific-pragmas-importobjc-pragma>`_
 * `importjs <manual.html#implementation-specific-pragmas-importjs-pragma>`_

  ```Nim
  proc p(s: cstring) {.importc: "prefix$1".}
  ```


例如， `p` 的外部名称会被设置为 `prefixp`。 只有 `$1` 可用，美元符号必须写成 `$$`。


Exportc 编译指示
--------------
`exportc` 编译指示提供了一种将类型、变量或 程序导出到 C 的手段。 枚举和常量不能导出。 可选参数 是包含 C 标识符的字符串。 如果参数缺失，C 的名字就会和Nim标识符*完全一样*:


  ```Nim
  proc callme(formatstr: cstring) {.exportc: "callMe", varargs.}
  ```

请注意这个编译指示有时候不正确：因为其他后端也用相同名称提供了这个功能。

传递到 `exportc` 可以是一个格式化的字符串：


  ```Nim
  proc p(s: string) {.exportc: "prefix$1".} =
    echo s
  ```


例如， `p` 的外部名称会被设置为 `prefixp`。 只有 `$1` 可用，美元符号必须写成 `$$`。

If the symbol should also be exported to a dynamic library, the `dynlib`
pragma should be used in addition to the `exportc` pragma. See
`Dynlib pragma for export <#foreign-function-interface-dynlib-pragma-for-export>`_.


Extern 编译指示
-------------
像 `exportc` 或 `importc`一样, `extern` 编译指示会影响名称混淆。 传递到 `extern` 可以是一个格式化的字符串：


  ```Nim
  proc p(s: string) {.extern: "prefix$1".} =
    echo s
  ```


例如， `p` 的外部名称会被设置为 `prefixp`。 只有 `$1` 可用，美元符号必须写成 `$$`。



Bycopy 编译指示
-------------

`bycopy` 编译指示可以应用于对象或元组类型， 指示编译器按值传递类型到程序中：


  ```nim
  type
    Vector {.bycopy.} = object
      x, y, z: float
  ```

Nim编译器通过根据参数类型的大小自动决定参数是根据值传递的还是按引用传递的。 如果一个参数必须通过值或引用传递(例如当与 C 库对接时时)，请使用 bycopy 或 byref 编译指示。

Byref 编译指示
------------

`byref` 编译指示可以应用于对象或元组类型， 指示编译器按引用传递类型（隐藏指针）到程序中：


Varargs 编译指示
--------------
`varargs` 编译指示只能应用于程序 (和程序 类型)。 它会告诉Nim, 在最后一个指定的参数之后, proc 还可以接受一个变量作为参数。 Nim 字符串值将会自动转换为 C 的 字符串：

  ```Nim
  proc printf(formatstr: cstring) {.nodecl, varargs.}

  printf("hallo %s", "world") # "world" will be passed as C string
  ```


Union 编译指示
------------
`Union` 编译指示可以应用于任意 `object` 类型。 这意味着一个对象字段的所有 都会在内存中被覆盖。 这在生成的 C/C++ 代码中产生了 `union`:c: 而不是 `struct`:c:。 对象声明 不能使用继承或任何 GC 过但目前未检查的内存。

**未来的方向**：应该允许 GC 回收过的内存，而GC 应该保守地扫描 union 共用体。




Packed 编译指示
-------------
`packed` 编译指示可以应用于任意 `object` 类型。 它能确保 一个对象的字段在内存中连续打包。 它非常有用， 在用于存储来自/到网络或硬件驱动程序的数据包或消息是，以及 与C的互操作性上。组合 packed 编译指示和继承是不被定义的 定义，也不应与 GC 的内存（引用的）一起使用。

**未来方向**: 在packed 编译指示中使用 GC'ed 内存将导致 静态错误。 继承的用法应加以定义和文档记录。



Dynlib 编译指示用于导入
------------------------
使用 `dynlib` 编译指示，程序或变量可以从 动态库中导入 (`.dll` Windows 文件, `lib*.so` UNIX 文件)。 必须参数必须是动态库的名称：


  ```Nim
  proc gtk_image_new(): PGtkWidget
    {.cdecl, dynlib: "libgtk-x11-2.0.so", importc.}
  ```

一般来说，导入动态库不需要任何特殊链接 选项或与导入库链接。 这也意味着不需要安装 *devel* 软件包。

`dynlib` 导入机制支持版本化：


  ```nim
  proc Tcl_Eval(interp: pTcl_Interp, script: cstring): int {.cdecl,
    importc, dynlib: "libtcl(|8.5|8.4|8.3).so.(1|0)".}
  ```

运行时, 动态库(按此顺序) 搜索:

  libtcl.so.1 libtcl.so.0 libtcl8.5.so.1 libtcl8.5.so.0 libtcl8.4.so.1 libtcl8.4.so.0 libtcl8.3.so.1 libtcl8.3.so.0

`dynlib` 编译指示不仅支持作为参数的常量字符串，而且还支持一般的 字符串表达式：


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

**注意**: 类似`libtcl(|8.5|8.4).so` 只支持常量 字符串，因为它们是预编译的。

**注意**: 将变量传递到 `dynlib` 编译指示会因为程序初始化的先后顺序，在运行时出错。


**注意**: 导入 `dynlib` 会被覆盖当使用 `--dynlibOverride:name`:option: 命令行选项时。 `编译器用户指南 <nimc.html>`_ 包含更多信息。


Dynlib pragma for export
------------------------

With the `dynlib` pragma, a procedure can also be exported to
a dynamic library. The pragma then has no argument and has to be used in
conjunction with the `exportc` pragma:

  ```Nim
  proc exportme(): int {.cdecl, exportc, dynlib.}
  ```

This is only useful if the program is compiled as a dynamic library via the
`--app:lib`:option: command-line option.



Threads
=======

To enable thread support the `--threads:on`:option: command-line switch needs to
be used. The system_ module then contains several threading primitives.
See the `channels <channels_builtin.html>`_ modules
for the low-level thread API. There are also high-level parallelism constructs
available. See `spawn <manual_experimental.html#parallel-amp-spawn>`_ for
further details.

Nim's memory model for threads is quite different than that of other common
programming languages (C, Pascal, Java): Each thread has its own (garbage
collected) heap, and sharing of memory is restricted to global variables. This
helps to prevent race conditions. GC efficiency is improved quite a lot,
because the GC never has to stop other threads and see what they reference.

The only way to create a thread is via `spawn` or
`createThread`. The invoked proc must not use `var` parameters nor must
any of its parameters contain a `ref` or `closure` type. This enforces
the *no heap sharing restriction*.

Thread pragma
-------------

A proc that is executed as a new thread of execution should be marked by the
`thread` pragma for reasons of readability. The compiler checks for
violations of the `no heap sharing restriction`:idx:\: This restriction implies
that it is invalid to construct a data structure that consists of memory
allocated from different (thread-local) heaps.

A thread proc is passed to `createThread` or `spawn` and invoked
indirectly; so the `thread` pragma implies `procvar`.



Threadvar pragma
----------------

A variable can be marked with the `threadvar` pragma, which makes it a
`thread-local`:idx: variable; Additionally, this implies all the effects
of the `global` pragma.

  ```nim
  var checkpoints* {.threadvar.}: seq[string]
  ```

Due to implementation restrictions, thread-local variables cannot be
initialized within the `var` section. (Every thread-local variable needs to
be replicated at thread creation.)


Threads and exceptions
----------------------

The interaction between threads and exceptions is simple: A *handled* exception
in one thread cannot affect any other thread. However, an *unhandled* exception
in one thread terminates the whole *process*.


Guards and locks
================

Nim provides common low level concurrency mechanisms like locks, atomic
intrinsics or condition variables.

Nim significantly improves on the safety of these features via additional
pragmas:

1) A `guard`:idx: annotation is introduced to prevent data races.
2) Every access of a guarded memory location needs to happen in an
   appropriate `locks`:idx: statement.


Guards and locks sections
-------------------------

### Protecting global variables

Object fields and global variables can be annotated via a `guard` pragma:

  ```nim
  import std/locks

  var glock: Lock
  var gdata {.guard: glock.}: int
  ```

The compiler then ensures that every access of `gdata` is within a `locks`
section:

  ```nim
  proc invalid =
    # invalid: unguarded access:
    echo gdata

  proc valid =
    # valid access:
    {.locks: [glock].}:
      echo gdata
  ```

Top level accesses to `gdata` are always allowed so that it can be initialized
conveniently. It is *assumed* (but not enforced) that every top level statement
is executed before any concurrent action happens.

The `locks` section deliberately looks ugly because it has no runtime
semantics and should not be used directly! It should only be used in templates
that also implement some form of locking at runtime:

  ```nim
  template lock(a: Lock; body: untyped) =
    pthread_mutex_lock(a)
    {.locks: [a].}:
      try:
        body
      finally:
        pthread_mutex_unlock(a)
  ```


The guard does not need to be of any particular type. It is flexible enough to
model low level lockfree mechanisms:

  ```nim
  var dummyLock {.compileTime.}: int
  var atomicCounter {.guard: dummyLock.}: int

  template atomicRead(x): untyped =
    {.locks: [dummyLock].}:
      memoryReadBarrier()
      x

  echo atomicRead(atomicCounter)
  ```


The `locks` pragma takes a list of lock expressions `locks: [a, b, ...]`
in order to support *multi lock* statements. Why these are essential is
explained in the `lock levels <#guards-and-locks-lock-levels>`_ section.


### Protecting general locations

The `guard` annotation can also be used to protect fields within an object.
The guard then needs to be another field within the same object or a
global variable.

Since objects can reside on the heap or on the stack, this greatly enhances
the expressiveness of the language:

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

The access to field `x.v` is allowed since its guard `x.L`  is active.
After template expansion, this amounts to:

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

There is an analysis that checks that `counters[i].L` is the lock that
corresponds to the protected location `counters[i].v`. This analysis is called
`path analysis`:idx: because it deals with paths to locations
like `obj.field[i].fieldB[j]`.

The path analysis is **currently unsound**, but that doesn't make it useless.
Two paths are considered equivalent if they are syntactically the same.

This means the following compiles (for now) even though it really should not:

  ```nim
  {.locks: [a[i].L].}:
    inc i
    access a[i].v
  ```
