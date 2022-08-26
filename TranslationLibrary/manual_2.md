{==+==}
Ordinal types
-------------
{==+==}
序数类型
--------
{==+==}

{==+==}
Ordinal types have the following characteristics:
{==+==}
序数类型有以下特征：
{==+==}

{==+==}
- Ordinal types are countable and ordered. This property allows the operation
  of functions such as `inc`, `ord`, and `dec` on ordinal types to
  be defined.
- Ordinal types have a smallest possible value, accessible with `low(type)`.
  Trying to count further down than the smallest value produces a panic or
  a static error.
- Ordinal types have a largest possible value, accessible with `high(type)`.
  Trying to count further up than the largest value produces a panic or
  a static error.
{==+==}
- 序数类型是可数的和有序的。因而允许使用如 `inc`, `ord`, `dec` 等函数，来操作已定义的序数类型。
- 序数类型具有最小可使用值，可以通过`low(type)`获取。 尝试从最小值继续减小，会产生panic或静态错误。
- 序数类型具有最大可使用值，可以通过`high(type)`获取。  尝试从最大值继续增大，会产生panic或静态错误。
{==+==}

{==+==}
Integers, bool, characters, and enumeration types (and subranges of these
types) belong to ordinal types.
{==+==}
整数、bool、字符和枚举类型（以及这些类型的子范围）属于序数类型。
{==+==}


{==+==}
A distinct type is an ordinal type if its base type is an ordinal type.
{==+==}
如果基类型是序数类型，则distinct类型是序数类型。
{==+==}


{==+==}
Pre-defined integer types
-------------------------
{==+==}
预定义整数类型
--------------
{==+==}

{==+==}
These integer types are pre-defined:
{==+==}
这些整数类型是预定义的：
{==+==}

{==+==}
`int`
  the generic signed integer type; its size is platform-dependent and has the
  same size as a pointer. This type should be used in general. An integer
  literal that has no type suffix is of this type if it is in the range
  `low(int32)..high(int32)` otherwise the literal's type is `int64`.
{==+==}
`int`
  通用有符号整数类型。它的大小取决于平台，并且与指针大小相同。如果一个没有类型后缀的整数字面值在 `low(int32)...high(int32)` 的范围内，则它是这种类型，否则为 `int64` 类型.
{==+==}

{==+==}
`int`\ XX
  additional signed integer types of XX bits use this naming scheme
  (example: int16 is a 16-bit wide integer).
  The current implementation supports `int8`, `int16`, `int32`, `int64`.
  Literals of these types have the suffix 'iXX.
{==+==}
`int`\ XX
  使用XX位额外标记的有符号整数使用这种命名。（比如int16是16位宽整数）当前支持实现有 `int8`, `int16`, `int32`, `int64` 。这些类型的字面值后缀为'iXX。
{==+==}

{==+==}
`uint`
  the generic `unsigned integer`:idx: type; its size is platform-dependent and
  has the same size as a pointer. An integer literal with the type
  suffix `'u` is of this type.
{==+==}
`uint`
  通用的 `无符号整型` 。它的大小取决于平台，并且与指针大小相同。 类型后缀为 `'u` 的整数字面值就是这种类型。
{==+==}

{==+==}
`uint`\ XX
  additional unsigned integer types of XX bits use this naming scheme
  (example: uint16 is a 16-bit wide unsigned integer).
  The current implementation supports `uint8`, `uint16`, `uint32`,
  `uint64`. Literals of these types have the suffix 'uXX.
  Unsigned operations all wrap around; they cannot lead to over- or
  underflow errors.
{==+==}
`uint`\ XX
  使用XX位额外标记的无符号整数使用这种命名。（比如uint16是16位宽的无符号整数）当前支持的实现有`uint8`, `uint16`, `uint32`, `uint64`。这些类型的字面值具有后缀 'uXX 。 无符号操作会环绕; 不会导致上溢或下溢错误。
{==+==}


{==+==}
In addition to the usual arithmetic operators for signed and unsigned integers
(`+ - *` etc.) there are also operators that formally work on *signed*
integers but treat their arguments as *unsigned*: They are mostly provided
for backwards compatibility with older versions of the language that lacked
unsigned integer types. These unsigned operations for signed integers use
the `%` suffix as convention:
{==+==}
除了有符号和无符号整数的常用算术运算符( `+ - *` 等)之外， 还有些运算符可以处理 *有符号* 整数但将他们的参数视为 *无符号* : 它们主要用于之后的版本与缺少无符号整数类型的旧版本语言进行兼容。 有符号整数的这些无符号运算约定使用 `%` 作为后缀:
{==+==}


{==+==}
======================   ======================================================
operation                meaning
======================   ======================================================
`a +% b`                 unsigned integer addition
`a -% b`                 unsigned integer subtraction
`a *% b`                 unsigned integer multiplication
`a /% b`                 unsigned integer division
`a %% b`                 unsigned integer modulo operation
`a <% b`                 treat `a` and `b` as unsigned and compare
`a <=% b`                treat `a` and `b` as unsigned and compare
`ze(a)`                  extends the bits of `a` with zeros until it has the
                         width of the `int` type
`toU8(a)`                treats `a` as unsigned and converts it to an
                         unsigned integer of 8 bits (but still the
                         `int8` type)
`toU16(a)`               treats `a` as unsigned and converts it to an
                         unsigned integer of 16 bits (but still the
                         `int16` type)
`toU32(a)`               treats `a` as unsigned and converts it to an
                         unsigned integer of 32 bits (but still the
                         `int32` type)
======================   ======================================================
{==+==}
======================   ==================================================================
操作符                   含义
======================   ==================================================================
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
======================   ==================================================================
{==+==}

{==+==}
`Automatic type conversion`:idx: is performed in expressions where different
kinds of integer types are used: the smaller type is converted to the larger.
{==+==}
不同类型的整型的表达式中，会执行`自动类型转换`：较小的类型转换为较大的类型。
{==+==}

{==+==}
A `narrowing type conversion`:idx: converts a larger to a smaller type (for
example `int32 -> int16`). A `widening type conversion`:idx: converts a
smaller type to a larger type (for example `int16 -> int32`). In Nim only
widening type conversions are *implicit*:
{==+==}
`缩小类型转换`将较大的类型转换为较小的类型(比如`int32 -> int16`) ，`扩展类型转换`将较小的类型转换为较大的类型（比如`int16 -> int32`) ，Nim中仅有扩展类型转型是 *隐式的*:
{==+==}


{==+==}
  ```nim
  var myInt16 = 5i16
  var myInt: int
  myInt16 + 34     # of type `int16`
  myInt16 + myInt  # of type `int`
  myInt16 + 2i32   # of type `int32`
  ```
{==+==}
  ```nim
  var myInt16 = 5i16
  var myInt: int
  myInt16 + 34     # 为`int16`类型
  myInt16 + myInt  # 为`int`类型
  myInt16 + 2i32   # 为`int32`类型
  ```
{==+==}


{==+==}
However, `int` literals are implicitly convertible to a smaller integer type
if the literal's value fits this smaller type and such a conversion is less
expensive than other implicit conversions, so `myInt16 + 34` produces
an `int16` result.
{==+==}
然而，如果字面值适合这个较小的类型，并且这样的转换比其他隐式转换更好，那么`int`字面值可以隐式转换为较小的整数类型，因而`myInt16 + 34` 结果是`int16`类型。
{==+==}

{==+==}
For further details, see `Convertible relation
<#type-relations-convertible-relation>`_.
{==+==}
有关详细信息，请阅读参考 `Convertible relation <#type-relations-convertible-relation>`_ 。
{==+==}


{==+==}
Subrange types
--------------
{==+==}
子范围类型
----------
{==+==}

{==+==}
A subrange type is a range of values from an ordinal or floating-point type (the base
type). To define a subrange type, one must specify its limiting values -- the
lowest and highest value of the type. For example:
{==+==}
子范围类型是序数或浮点类型（基类型）的取值范围。
要定义子范围类型，必须指定其限制值，即类型的最低值和最高值。例如：
{==+==}

{==+==}
  ```nim
  type
    Subrange = range[0..5]
    PositiveFloat = range[0.0..Inf]
    Positive* = range[1..high(int)] # as defined in `system`
  ```
{==+==}
  ```nim
  type
    Subrange = range[0..5]
    PositiveFloat = range[0.0..Inf]
    Positive* = range[1..high(int)] # 正如`system`里定义的一样
  ```
{==+==}


{==+==}
`Subrange` is a subrange of an integer which can only hold the values 0
to 5. `PositiveFloat` defines a subrange of all positive floating-point values.
NaN does not belong to any subrange of floating-point types.
Assigning any other value to a variable of type `Subrange` is a
panic (or a static error if it can be determined during
semantic analysis). Assignments from the base type to one of its subrange types
(and vice versa) are allowed.
{==+==}
`Subrange` 是整数的子范围，只能保存0到5的值。`PositiveFloat` 定义了包含所有正浮点数的子范围。
NaN不属于任何浮点类型的子范围。将任何其他值分配给类型为`Subrange`会产生panic（如果可以在语义分析期间确认，则为静态错误）。
允许从基本类型到其子类型之一的分配，反之亦然。
{==+==}

{==+==}
A subrange type has the same size as its base type (`int` in the
Subrange example).
{==+==}
子范围类型与其基类型具有相同的大小（子范围示例中的 `int` ）。
{==+==}


{==+==}
Pre-defined floating-point types
--------------------------------
{==+==}
预定义浮点类型
--------------
{==+==}

{==+==}
The following floating-point types are pre-defined:
{==+==}
以下浮点类型是预定义的：
{==+==}

{==+==}
`float`
  the generic floating-point type; its size used to be platform-dependent,
  but now it is always mapped to `float64`.
  This type should be used in general.
{==+==}
`float`
  通用浮点类型; 它的大小曾经是平台相关的，但现在它总是映射到 `float64` 。一般应该使用这种类型。
{==+==}

{==+==}
`float`\ XX
  an implementation may define additional floating-point types of XX bits using
  this naming scheme (example: `float64` is a 64-bit wide float). The current
  implementation supports `float32` and `float64`. Literals of these types
  have the suffix 'fXX.
{==+==}
`float`\ XX
  使用XX位附加标记的浮点数可以使用这种命名（例如：`float64`是64位宽的浮点数），当前支持`float32`和`float64`。 这些类型的字面值具有后缀 'fXX。
{==+==}


{==+==}
Automatic type conversion in expressions with different kinds of floating-point
types is performed: See `Convertible relation
<#type-relations-convertible-relation>`_ for further details. Arithmetic
performed on floating-point types follows the IEEE standard. Integer types are
not converted to floating-point types automatically and vice versa.
{==+==}
可以在具有不同类型浮点数的表达式中执行自动类型转换：详见`Convertible relation<#type-relations-convertible-relation>`_ 。 
在浮点类型上执行的算术遵循IEEE标准。 整数类型不会自动转换为浮点类型，反之亦然。
{==+==}

{==+==}
The IEEE standard defines five types of floating-point exceptions:
{==+==}
IEEE标准定义了五种类型的浮点异常：
{==+==}

{==+==}
* Invalid: operations with mathematically invalid operands,
  for example 0.0/0.0, sqrt(-1.0), and log(-37.8).
* Division by zero: divisor is zero and dividend is a finite nonzero number,
  for example 1.0/0.0.
* Overflow: operation produces a result that exceeds the range of the exponent,
  for example MAXDOUBLE+0.0000000000001e308.
* Underflow: operation produces a result that is too small to be represented
  as a normal number, for example, MINDOUBLE * MINDOUBLE.
* Inexact: operation produces a result that cannot be represented with infinite
  precision, for example, 2.0 / 3.0, log(1.1) and 0.1 in input.
{==+==}
* 无效: 使用数学上无效的操作数操作, 例如 0.0/0.0, sqrt(-1.0), 和log(-37.8).
* 除以零：除数为零，且被除数是有限的非零数，例如1.0 / 0.0。
* 溢出：操作产生的结果超出范围，例如，MAXDOUBLE + 0.0000000000001e308。
* 下溢：操作产生的结果太小而无法表示为正常数字，例如，MINDOUBLE * MINDOUBLE。
* 不精确：操作产生的结果无法用无限精度表示，例如，输入中的 2.0 / 3.0，log(1.1) 和 0.1。
{==+==}

{==+==}
The IEEE exceptions are either ignored during execution or mapped to the
Nim exceptions: `FloatInvalidOpDefect`:idx:, `FloatDivByZeroDefect`:idx:,
`FloatOverflowDefect`:idx:, `FloatUnderflowDefect`:idx:,
and `FloatInexactDefect`:idx:.
These exceptions inherit from the `FloatingPointDefect`:idx: base class.
{==+==}
IEEE异常在执行期间被忽略或映射到Nim异常: `FloatInvalidOpDefect`, `FloatDivByZeroDefect`, `FloatOverflowDefect`, `FloatUnderflowDefect`, 和 `FloatInexactDefect` 。 这些异常继承自 `FloatingPointDefect` 基类。
{==+==}

{==+==}
Nim provides the pragmas `nanChecks`:idx: and `infChecks`:idx: to control
whether the IEEE exceptions are ignored or trap a Nim exception:
{==+==}
Nim提供了编译指示 `nanChecks`和`infChecks`控制是否忽略IEEE异常或捕获Nim异常：
{==+==}

{==+==}
  ```nim
  {.nanChecks: on, infChecks: on.}
  var a = 1.0
  var b = 0.0
  echo b / b # raises FloatInvalidOpDefect
  echo a / b # raises FloatOverflowDefect
  ```
{==+==}
  ```nim
  {.nanChecks: on, infChecks: on.}
  var a = 1.0
  var b = 0.0
  echo b / b # 引发 FloatInvalidOpDefect
  echo a / b # 引发 FloatOverflowDefect
  ```
{==+==}

{==+==}
In the current implementation `FloatDivByZeroDefect` and `FloatInexactDefect`
are never raised. `FloatOverflowDefect` is raised instead of
`FloatDivByZeroDefect`.
There is also a `floatChecks`:idx: pragma that is a short-cut for the
combination of `nanChecks` and `infChecks` pragmas. `floatChecks` are
turned off as default.
{==+==}
在当前的实现中，绝不会引发 `FloatDivByZeroError` 和 `FloatInexactError` 。 `FloatOverflowError` 取代了 `FloatDivByZeroError` 。 
另有 floatChecks 编译指示用作 `nanChecks` 和 `infChecks` 的便捷方式。 `floatChecks` 默认关闭。
{==+==}

{==+==}
The only operations that are affected by the `floatChecks` pragma are
the `+`, `-`, `*`, `/` operators for floating-point types.
{==+==}
只有 `+`, `-`, `*`, `/` 这些运算符会受`floatChecks`编译指示影响。
{==+==}

{==+==}
An implementation should always use the maximum precision available to evaluate
floating-point values during semantic analysis; this means expressions like
`0.09'f32 + 0.01'f32 == 0.09'f64 + 0.01'f64` that are evaluating during
constant folding are true.
{==+==}
在语义分析期间，应始终使用最大精度来评估浮点数，这表示在常量展开期间，表达式  `0.09'f32 + 0.01'f32 == 0.09'f64 + 0.01'f64` 的值为真。
{==+==}


{==+==}
Boolean type
------------
{==+==}
布尔类型
--------
{==+==}

{==+==}
The boolean type is named `bool`:idx: in Nim and can be one of the two
pre-defined values `true` and `false`. Conditions in `while`,
`if`, `elif`, `when`-statements need to be of type `bool`.
{==+==}
布尔类型在Nim中命名为 `bool` ，值为预定义(`true`和`false`)之一。`while`,`if`, `elif`, `when` 中的状态需为 `bool` 类型.
{==+==}

{==+==}
This condition holds::
{==+==}
这种情况成立::
{==+==}

{-----}
  ord(false) == 0 and ord(true) == 1
{-----}

{==+==}
The operators `not, and, or, xor, <, <=, >, >=, !=, ==` are defined
for the bool type. The `and` and `or` operators perform short-cut
evaluation. Example:
{==+==}
为布尔类型定义了运算符 `not, and, or, xor, <, <=, >, >=, !=, ==` 。 `and` 和 `or` 运算符进行短路求值。例如:
{==+==}

{==+==}
  ```nim
  while p != nil and p.name != "xyz":
    # p.name is not evaluated if p == nil
    p = p.next
  ```
{==+==}
  ```nim
  while p != nil and p.name != "xyz":
    # 如果 p == nil， p.name不被求值
    p = p.next
  ```
{==+==}


{==+==}
The size of the bool type is one byte.
{==+==}
bool类型的大小是一个字节。
{==+==}


{==+==}
Character type
--------------
{==+==}
字符类型
--------
{==+==}

{==+==}
The character type is named `char` in Nim. Its size is one byte.
Thus, it cannot represent a UTF-8 character, but a part of it.
{==+==}
字符类型在Nim中被命名为 `char` 。它的大小为一个字节。因此，它不能表示UTF-8字符，而只能是UTF-8字符的一部分。
{==+==}

{==+==}
The `Rune` type is used for Unicode characters, it can represent any Unicode
character. `Rune` is declared in the `unicode module <unicode.html>`_.
{==+==}
`Rune` 类型用于Unicode字符，它可以表示任意Unicode字符。`Rune` 声明在 `unicode module <unicode.html>`_ 中。
{==+==}

{==+==}
Enumeration types
-----------------
{==+==}
枚举类型
--------
{==+==}

{==+==}
Enumeration types define a new type whose values consist of the ones
specified. The values are ordered. Example:
{==+==}
枚举类型定义了一个其值由指定的值组成的新类型，这些值是有序的。例如：
{==+==}

{-----}
  ```nim
  type
    Direction = enum
      north, east, south, west
  ```
{-----}


{==+==}
Now the following holds::
{==+==}
那么以下是成立的:
{==+==}

{==+==}
  ord(north) == 0
  ord(east) == 1
  ord(south) == 2
  ord(west) == 3

  # Also allowed:
  ord(Direction.west) == 3
{==+==}
  ord(north) == 0
  ord(east) == 1
  ord(south) == 2
  ord(west) == 3

  # 也允许:
  ord(Direction.west) == 3
{==+==}

{==+==}
The implied order is: north < east < south < west. The comparison operators can be used
with enumeration types. Instead of `north` etc., the enum value can also
be qualified with the enum type that it resides in, `Direction.north`.
{==+==}
由此可知，north < east < south < west。比较运算符可以与枚举类型一起使用。枚举值也可以使用它所在的枚举类型来限定，如 `north` 可以用 `Direction.nort` 来限定。
{==+==}

{==+==}
For better interfacing to other programming languages, the fields of enum
types can be assigned an explicit ordinal value. However, the ordinal values
have to be in ascending order. A field whose ordinal value is not
explicitly given is assigned the value of the previous field + 1.
{==+==}
为了更好地与其他编程语言连接，可以显式为枚举类型字段分配序数值，但是，序数值必须升序排列。 未明确给出序数值的字段被赋予前一个字段 +1 的值。
{==+==}

{==+==}
An explicit ordered enum can have *holes*:
{==+==}
显式有序枚举可以有 *间隔* ：
{==+==}

{==+==}
  ```nim
  type
    TokenType = enum
      a = 2, b = 4, c = 89 # holes are valid
  ```
{==+==}
  ```nim
  type
    TokenType = enum
      a = 2, b = 4, c = 89 # 可以有间隔
  ```
{==+==}

{==+==}
However, it is then not ordinal anymore, so it is impossible to use these
enums as an index type for arrays. The procedures `inc`, `dec`, `succ`
and `pred` are not available for them either.
{==+==}
但是，它不再是序数，因此不可能将这些枚举用作数组的索引类型。 过程`inc`, `dec`, `succ`和`pred`对于它们不可用。
{==+==}


{==+==}
The compiler supports the built-in stringify operator `$` for enumerations.
The stringify's result can be controlled by explicitly giving the string
values to use:
{==+==}
编译器支持内置的字符串化运算符 `$` 用于枚举。字符串化的效果是，可以通过显式给出要使用的字符串来控制：
{==+==}

{-----}
  ```nim
  type
    MyEnum = enum
      valueA = (0, "my value A"),
      valueB = "value B",
      valueC = 2,
      valueD = (3, "abc")
  ```
{-----}

{==+==}
As can be seen from the example, it is possible to both specify a field's
ordinal value and its string value by using a tuple. It is also
possible to only specify one of them.
{==+==}
从示例中可以看出，可以通过使用元组指定字段的序数值以及字符串值，也可以只指定其中一个。
{==+==}

{==+==}
An enum can be marked with the `pure` pragma so that its fields are
added to a special module-specific hidden scope that is only queried
as the last attempt. Only non-ambiguous symbols are added to this scope.
But one can always access these via type qualification written
as `MyEnum.value`:
{==+==}
枚举可以使用 `pure` 编译指示进行标记，以便将其字段添加到特定模块特定的隐藏作用域，该作用域仅作为最后一次尝试进行查询。 
只有没有歧义的符号才会添加到此作用域。 但总是可以通过写为 `MyEnum.value` 的类型限定来访问:
{==+==}

{==+==}
  ```nim
  type
    MyEnum {.pure.} = enum
      valueA, valueB, valueC, valueD, amb

    OtherEnum {.pure.} = enum
      valueX, valueY, valueZ, amb


  echo valueA # MyEnum.valueA
  echo amb    # Error: Unclear whether it's MyEnum.amb or OtherEnum.amb
  echo MyEnum.amb # OK.
  ```
{==+==}
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
{==+==}

{==+==}
To implement bit fields with enums see `Bit fields <#set-type-bit-fields>`_
{==+==}
要使用枚举实现位字段，请参阅 `Bit fields <#set-type-bit-fields>`_
{==+==}


{==+==}
String type
-----------
{==+==}
字符串类型
----------
{==+==}

{==+==}
All string literals are of the type `string`. A string in Nim is very
similar to a sequence of characters. However, strings in Nim are both
zero-terminated and have a length field. One can retrieve the length with the
builtin `len` procedure; the length never counts the terminating zero.
{==+==}
所有字符串字面值都是`string`类型。 Nim中的字符串与字符序列非常相似。 但是，Nim中的字符串都是以零结尾的并且具有长度字段。 可以用内置的 `len` 过程检索长度;长度总是不会计算末尾的零。
{==+==}

{==+==}
The terminating zero cannot be accessed unless the string is converted
to the `cstring` type first. The terminating zero assures that this
conversion can be done in O(1) and without any allocations.
{==+==}
除非首先将字符串转换为 `cstring` 类型，否则无法访问末尾的零。末尾的零确保可以在 O(1) 中完成此转换，无需任何分配。
{==+==}

{==+==}
The assignment operator for strings always copies the string.
The `&` operator concatenates strings.
{==+==}
字符串的赋值运算符始终复制字符串。`&` 运算符拼接字符串。
{==+==}

{==+==}
Most native Nim types support conversion to strings with the special `$` proc.
When calling the `echo` proc, for example, the built-in stringify operation
for the parameter is called:
{==+==}
大多数原生Nim类型支持使用特殊的 `$` 过程转换为字符串。
{==+==}

{==+==}
  ```nim
  echo 3 # calls `$` for `int`
  ```
{==+==}
  ```nim
  echo 3 # 为 `int` 调用 `$`
  ```
{==+==}

{==+==}
Whenever a user creates a specialized object, implementation of this procedure
provides for `string` representation.
{==+==}
每当用户创建一个特定的对象时，该过程的实现提供了 `string` 表示。
{==+==}

{==+==}
  ```nim
  type
    Person = object
      name: string
      age: int

  proc `$`(p: Person): string = # `$` always returns a string
    result = p.name & " is " &
            $p.age & # we *need* the `$` in front of p.age which
                     # is natively an integer to convert it to
                     # a string
            " years old."
  ```
{==+==}
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
{==+==}

{==+==}
While `$p.name` can also be used, the `$` operation on a string does
nothing. Note that we cannot rely on automatic conversion from an `int` to
a `string` like we can for the `echo` proc.
{==+==}
虽然也可以使用`$p.name`，但`$`操作符不会对字符串做任何事情。 请注意，我们不能依赖于从 `int` 到 `string` 像`echo`过程一样自动转换。
{==+==}

{==+==}
Strings are compared by their lexicographical order. All comparison operators
are available. Strings can be indexed like arrays (lower bound is 0). Unlike
arrays, they can be used in case statements:
{==+==}
字符串按字典顺序进行比较。 所有比较运算符都可用。 字符串可以像数组一样索引（下限为0）。 与数组不同，字符串可用于case语句：
{==+==}

{==+==}
  ```nim
  case paramStr(i)
  of "-v": incl(options, optVerbose)
  of "-h", "-?": incl(options, optHelp)
  else: write(stdout, "invalid command line option!\n")
  ```
{==+==}
  ```nim
  case paramStr(i)
  of "-v": incl(options, optVerbose)
  of "-h", "-?": incl(options, optHelp)
  else: write(stdout, "非法的命令行选项\n")
  ```
{==+==}

{==+==}
Per convention, all strings are UTF-8 strings, but this is not enforced. For
example, when reading strings from binary files, they are merely a sequence of
bytes. The index operation `s[i]` means the i-th *char* of `s`, not the
i-th *unichar*. The iterator `runes` from the `unicode module
<unicode.html>`_ can be used for iteration over all Unicode characters.
{==+==}
按照惯例，所有字符串都是UTF-8字符串，但不强制执行。 例如，从二进制文件读取字符串时，它们只是一个字节序列。 索引操作`s[i]`表示 s 的第i个 char ，而不是第i个 unichar 。  `unicode module <unicode.html>`_  中的迭代器`runes`，可用于迭代所有Unicode字符。
{==+==}


{==+==}
cstring type
------------
{==+==}
cstring类型
-----------
{==+==}

{==+==}
The `cstring` type meaning `compatible string` is the native representation
of a string for the compilation backend. For the C backend the `cstring` type
represents a pointer to a zero-terminated char array
compatible with the type `char*` in ANSI C. Its primary purpose lies in easy
interfacing with C. The index operation `s[i]` means the i-th *char* of
`s`; however no bounds checking for `cstring` is performed making the
index operation unsafe.
{==+==}
`cstring` 类型意味着 `compatible string` ，是编译后端的字符串的原生表示。 对于C后端，`cstring` 类型表示一个指向末尾为零的char数组的指针，该数组与ANSI C中的 `char*` 类型兼容。 其主要目的在于与C轻松互通。 索引操作 `s[i]` 表示 s 的第i个 *char* ;但是没有执行检查 cstring 的边界，导致索引操作并不安全。
{==+==}

{==+==}
A Nim `string` is implicitly convertible
to `cstring` for convenience. If a Nim string is passed to a C-style
variadic proc, it is implicitly converted to `cstring` too:
{==+==}
为方便起见，Nim中的 `string` 可以隐式转换为 `cstring` 。 如果将Nim字符串传递给C风格的可变参数过程，它也会隐式转换为 `cstring` ：
{==+==}

{==+==}
  ```nim
  proc printf(formatstr: cstring) {.importc: "printf", varargs,
                                    header: "<stdio.h>".}

  printf("This works %s", "as expected")
  ```
{==+==}
  ```nim
  proc printf(formatstr: cstring) {.importc: "printf", varargs,
                                    header: "<stdio.h>".}

  printf("这会%s工作", "像预期一样")
  ```
{==+==}

{==+==}
Even though the conversion is implicit, it is not *safe*: The garbage collector
does not consider a `cstring` to be a root and may collect the underlying
memory. For this reason, the implicit conversion will be removed in future
releases of the Nim compiler. Certain idioms like conversion of a `const` string
to `cstring` are safe and will remain to be allowed.
{==+==}
即使转换是隐式的，它也不是 *安全的* ：垃圾收集器不认为 `cstring` 是根，并且可能收集底层内存。 因此，隐式转换将在Nim编译器的未来版本中删除。某些习语，例如将`const`字符串转换为`cstring`，是安全的，并且仍将被允许。
{==+==}

{==+==}
A `$` proc is defined for cstrings that returns a string. Thus, to get a nim
string from a cstring:
{==+==}
为cstring定义的`$`过程能够返回string。因此，从cstring获取nim的string可以这样：
{==+==}

{-----}
  ```nim
  var str: string = "Hello!"
  var cstr: cstring = str
  var newstr: string = $cstr
  ```
{-----}

{==+==}
`cstring` literals shouldn't be modified.
{==+==}
`cstring`不应被逐字修改。
{==+==}

{==+==}
  ```nim
  var x = cstring"literals"
  x[1] = 'A' # This is wrong!!!
  ```
{==+==}
  ```nim
  var x = cstring"literals"
  x[1] = 'A' # 这是错的！！！
  ```
{==+==}

{==+==}
If the `cstring` originates from a regular memory (not read-only memory),
it can be modified:
{==+==}
如果`cstring`来自常规内存（而不是只读内存），则可以被逐字修改。
{==+==}

{==+==}
  ```nim
  var x = "123456"
  var s: cstring = x
  s[0] = 'u' # This is ok
  ```
{==+==}
  ```nim
  var x = "123456"
  var s: cstring = x
  s[0] = 'u' # 这是可以的
  ```
{==+==}

{==+==}
Structured types
----------------
{==+==}
结构化类型
----------
{==+==}

{==+==}
A variable of a structured type can hold multiple values at the same
time. Structured types can be nested to unlimited levels. Arrays, sequences,
tuples, objects, and sets belong to the structured types.
{==+==}
结构化类型的变量可以同时保存多个值。 结构化类型可以嵌套到无限级别。数组、序列、元组、对象和集合属于结构化类型。
{==+==}

{==+==}
Array and sequence types
------------------------
{==+==}
数组和序列类型
--------------
{==+==}

{==+==}
Arrays are a homogeneous type, meaning that each element in the array has the
same type. Arrays always have a fixed length specified as a constant expression
(except for open arrays). They can be indexed by any ordinal type.
A parameter `A` may be an *open array*, in which case it is indexed by
integers from 0 to `len(A)-1`. An array expression may be constructed by the
array constructor `[]`. The element type of this array expression is
inferred from the type of the first element. All other elements need to be
implicitly convertible to this type.
{==+==}
数组是同类型的，这意味着数组中的每个元素都具有相同的类型。 数组总是具有指定为常量表达式的固定长度（开放数组除外）。 它们可以按任何序数类型索引。 若参数 `A` 是*开放数组* ，那么它的索引为由0到 len（A）- 1 的整数。 数组表达式可以由数组构造器 `[]` 构造。 数组表达式的元素类型是从第一个元素的类型推断出来的。 所有其他元素都需要隐式转换为此类型。
{==+==}

{==+==}
An array type can be defined using the `array[size, T]` syntax, or using
`array[lo..hi, T]` for arrays that start at an index other than zero.
{==+==}
可以使用 `array[size, T]` 构造数组类型，也可以使用 `array[lo..hi, T]` 设置数组的起点而不是默认的0。
{==+==}

{==+==}
Sequences are similar to arrays but of dynamic length which may change
during runtime (like strings). Sequences are implemented as growable arrays,
allocating pieces of memory as items are added. A sequence `S` is always
indexed by integers from 0 to `len(S)-1` and its bounds are checked.
Sequences can be constructed by the array constructor `[]` in conjunction
with the array to sequence operator `@`. Another way to allocate space for a
sequence is to call the built-in `newSeq` procedure.
{==+==}
序列类似于数组，但有动态长度，其长度可能在运行时期间发生变化（如字符串）。 序列实现为可增长的数组，在添加项目时分配内存块。 序列 `S` 的索引为从0到 `len(S)-1`的整数，并检查其边界。 序列可以在序列运算符`@`的帮助下，由数组构造器 `[]` 和数组一起构造。为序列分配空间的另一种方法是调用内置的 `newSeq` 过程。
{==+==}

{==+==}
A sequence may be passed to a parameter that is of type *open array*.
{==+==}
序列可以传递给 *开放数组* 类型的参数
{==+==}

{==+==}
Example:
{==+==}
例如：
{==+==}

{==+==}
  ```nim
  type
    IntArray = array[0..5, int] # an array that is indexed with 0..5
    IntSeq = seq[int] # a sequence of integers
  var
    x: IntArray
    y: IntSeq
  x = [1, 2, 3, 4, 5, 6]  # [] is the array constructor
  y = @[1, 2, 3, 4, 5, 6] # the @ turns the array into a sequence

  let z = [1.0, 2, 3, 4] # the type of z is array[0..3, float]
  ```
{==+==}
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
{==+==}

{==+==}
The lower bound of an array or sequence may be received by the built-in proc
`low()`, the higher bound by `high()`. The length may be
received by `len()`. `low()` for a sequence or an open array always returns
0, as this is the first valid index.
One can append elements to a sequence with the `add()` proc or the `&`
operator, and remove (and get) the last element of a sequence with the
`pop()` proc.
{==+==}
数组或序列的下限可以用内置的过程`low()`获取，上限用`high()`获取。 长度可以用`len()`获取。序列或开放数组的 `low()` 总是返回0，因为这是第一个有效索引。 可以使用 `add()` 过程或 `&` 运算符将元素追加到序列中，并使用 `pop()` 过程删除（并获取）序列的最后一个元素。
{==+==}

{==+==}
The notation `x[i]` can be used to access the i-th element of `x`.
{==+==}
符号 `x[i]` 可用于访问 `x` 的第i个元素。
{==+==}

{==+==}
Arrays are always bounds checked (statically or at runtime). These
checks can be disabled via pragmas or invoking the compiler with the
`--boundChecks:off`:option: command-line switch.
{==+==}
数组始终是边界检查的（静态或运行时）。可以通过编译指示禁用这些检查，或使用 `--boundChecks：off` 命令行开关调用编译器。
{==+==}

{==+==}
An array constructor can have explicit indexes for readability:
{==+==}
数组构造器可以具有可读的显式索引：
{==+==}

{-----}
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
{-----}

{==+==}
If an index is left out, `succ(lastIndex)` is used as the index
value:
{==+==}
如果省略索引，则使用 `succ(lastIndex)` 作为索引值：
{==+==}


{-----}
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
{-----}


{==+==}
Open arrays
-----------
{==+==}
开放数组
--------
{==+==}

{==+==}
Often fixed size arrays turn out to be too inflexible; procedures should
be able to deal with arrays of different sizes. The `openarray`:idx: type
allows this; it can only be used for parameters. Open arrays are always
indexed with an `int` starting at position 0. The `len`, `low`
and `high` operations are available for open arrays too. Any array with
a compatible base type can be passed to an open array parameter, the index
type does not matter. In addition to arrays, sequences can also be passed
to an open array parameter.
{==+==}
通常，固定大小的数组太不灵活了，程序应该能够处理不同大小的数组。 `开放数组` 类型只能用于参数。 开放数组总是从位置0开始用 `int` 索引。 `len`，`low` 和 `high` 操作也可用于开放数组。 具有兼容基类型的任何数组都可以传递给开放数组形参，无关索引类型。 除了数组之外，还可以将序列传递给开放数组参数。
{==+==}

{==+==}
The `openarray` type cannot be nested: multidimensional open arrays are not
supported because this is seldom needed and cannot be done efficiently.
{==+==}
`开放数组`类型不能嵌套： 不支持多维开放数组，因为这种需求很少并且不能有效地完成。
{==+==}

{-----}
  ```nim
  proc testOpenArray(x: openArray[int]) = echo repr(x)

  testOpenArray([1,2,3])  # array[]
  testOpenArray(@[1,2,3]) # seq[]
  ```
{-----}


{==+==}
Varargs
-------
{==+==}
可变参数
--------
{==+==}

{==+==}
A `varargs` parameter is an open array parameter that additionally
allows a variable number of arguments to be passed to a procedure. The compiler
converts the list of arguments to an array implicitly:
{==+==}
`varargs` 参数是一个开放数组参数，它允许将可变数量的参数传递给过程。 编译器隐式地将参数列表转换为数组：
{==+==}

{==+==}
  ```nim
  proc myWriteln(f: File, a: varargs[string]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, "abc", "def", "xyz")
  # is transformed to:
  myWriteln(stdout, ["abc", "def", "xyz"])
  ```
{==+==}
  ```nim
  proc myWriteln(f: File, a: varargs[string]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, "abc", "def", "xyz")
  # 转换成：
  myWriteln(stdout, ["abc", "def", "xyz"])
  ```
{==+==}

{==+==}
This transformation is only done if the `varargs` parameter is the
last parameter in the procedure header. It is also possible to perform
type conversions in this context:
{==+==}
仅当`varargs`参数是最后一个参数时，才会执行此转换。 也可以在此上下文中执行类型转换：
{==+==}

{==+==}
  ```nim
  proc myWriteln(f: File, a: varargs[string, `$`]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, 123, "abc", 4.0)
  # is transformed to:
  myWriteln(stdout, [$123, $"abc", $4.0])
  ```
{==+==}
  ```nim
  proc myWriteln(f: File, a: varargs[string, `$`]) =
    for s in items(a):
      write(f, s)
    write(f, "\n")

  myWriteln(stdout, 123, "abc", 4.0)
  # 转换成：
  myWriteln(stdout, [$123, $"abc", $4.0])
  ```
{==+==}

{==+==}
In this example `$` is applied to any argument that is passed to the
parameter `a`. (Note that `$` applied to strings is a nop.)
{==+==}
在这个例子中， `$` 应用于传递给参数 `a` 的任何参数。 （注意 `$` 对字符串是一个空操作。）
{==+==}

{==+==}
Note that an explicit array constructor passed to a `varargs` parameter is
not wrapped in another implicit array construction:
{==+==}
请注意，传递给 `varargs` 形参的显式数组构造器不会隐式地构造另一个隐式数组：
{==+==}

{==+==}
  ```nim
  proc takeV[T](a: varargs[T]) = discard

  takeV([123, 2, 1]) # takeV's T is "int", not "array of int"
  ```
{==+==}
  ```nim
  proc takeV[T](a: varargs[T]) = discard

  takeV([123, 2, 1]) # takeV的T是"int", 不是"int数组"
  ```
{==+==}


{==+==}
`varargs[typed]` is treated specially: It matches a variable list of arguments
of arbitrary type but *always* constructs an implicit array. This is required
so that the builtin `echo` proc does what is expected:
{==+==}
`varargs[typed]` 被特别对待：它匹配任意类型的参数的变量列表，但*始终*构造一个隐式数组。这是必需的，因而内置的 `echo` 过程能够执行预期的操作：
{==+==}

{==+==}
  ```nim
  proc echo*(x: varargs[typed, `$`]) {...}

  echo @[1, 2, 3]
  # prints "@[1, 2, 3]" and not "123"
  ```
{==+==}
  ```nim
  proc echo*(x: varargs[typed, `$`]) {...}

  echo @[1, 2, 3]
  # 输出 "@[1, 2, 3]" 而不是 "123"
  ```
{==+==}


{==+==}
Unchecked arrays
----------------
{==+==}
未检查数组
----------
{==+==}

{==+==}
The `UncheckedArray[T]` type is a special kind of `array` where its bounds
are not checked. This is often useful to implement customized flexibly sized
arrays. Additionally, an unchecked array is translated into a C array of
undetermined size:
{==+==}
`UncheckedArray[T]` 类型是一种特殊的 `数组` ，编译器不检查它的边界。 这对于实现定制灵活大小的数组通常很有用。 另外，未检查数组可以这样转换为不确定大小的C数组：
{==+==}

{-----}
  ```nim
  type
    MySeq = object
      len, cap: int
      data: UncheckedArray[int]
  ```
{-----}

{==+==}
Produces roughly this C code:
{==+==}
生成的C代码大致是这样的：
{==+==}

{-----}
  ```C
  typedef struct {
    NI len;
    NI cap;
    NI data[];
  } MySeq;
  ```
{-----}

{==+==}
The base type of the unchecked array may not contain any GC'ed memory but this
is currently not checked.
{==+==}
未检查数组的基本类型可能不包含任何GC内存，但目前尚未检查。
{==+==}

{==+==}
**Future directions**: GC'ed memory should be allowed in unchecked arrays and
there should be an explicit annotation of how the GC is to determine the
runtime size of the array.
{==+==}
**未来方向**: 应该在未经检查的数组中允许GC内存，并且应该有一个关于GC如何确定数组的运行时大小的显式注释。
{==+==}


{==+==}
Tuples and object types
-----------------------
{==+==}
元组和对象类型
--------------
{==+==}

{==+==}
A variable of a tuple or object type is a heterogeneous storage
container.
A tuple or object defines various named *fields* of a type. A tuple also
defines a lexicographic *order* of the fields. Tuples are meant to be
heterogeneous storage types with few abstractions. The `()` syntax
can be used to construct tuples. The order of the fields in the constructor
must match the order of the tuple's definition. Different tuple-types are
*equivalent* if they specify the same fields of the same type in the same
order. The *names* of the fields also have to be the same.
{==+==}
元组或对象类型的变量是异构存储容器。 元组或对象定义了一个类型的各类*字段*。 元组还定义了字段的*顺序*。 元组是有很少抽象可能性的异构存储类型。 `()` 可用于构造元组。 构造函数中字段的顺序必须与元组定义的顺序相匹配。 如果它们以相同的顺序指定相同类型的相同字段，则不同的元组类型*等效* 。字段的*名称*也必须相同。
{==+==}

{==+==}
  ```nim
  type
    Person = tuple[name: string, age: int] # type representing a person:
                                           # it consists of a name and an age.
  var person: Person
  person = (name: "Peter", age: 30)
  assert person.name == "Peter"
  # the same, but less readable:
  person = ("Peter", 30)
  assert person[0] == "Peter"
  assert Person is (string, int)
  assert (string, int) is Person
  assert Person isnot tuple[other: string, age: int] # `other` is a different identifier
  ```
{==+==}
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
{==+==}

{==+==}
A tuple with one unnamed field can be constructed with the parentheses and a
trailing comma:
{==+==}
可以使用括号和尾随逗号构造具有一个未命名字段的元组：
{==+==}

{-----}
  ```nim
  proc echoUnaryTuple(a: (int,)) =
    echo a[0]

  echoUnaryTuple (1,)
  ```
{-----}


{==+==}
In fact, a trailing comma is allowed for every tuple construction.
{==+==}
事实上，每个元组结构都允许使用尾随逗号。
{==+==}

{==+==}
The implementation aligns the fields for the best access performance. The alignment
is compatible with the way the C compiler does it.
{==+==}
字段将会对齐，以此获得最佳性能。对齐与C编译器的方式兼容。
{==+==}

{==+==}
For consistency  with `object` declarations, tuples in a `type` section
can also be defined with indentation instead of `[]`:
{==+==}
为了与`object`声明保持一致， `type` 部分中的元组也可以用缩进而不是 `[]` 来定义：
{==+==}

{==+==}
  ```nim
  type
    Person = tuple   # type representing a person
      name: string   # a person consists of a name
      age: Natural   # and an age
  ```
{==+==}
  ```nim
  type
    Person = tuple   # 代表人的类型
      name: string   # 一个人包括名字
      age: Natural   # 和年龄
  ```
{==+==}

{==+==}
Objects provide many features that tuples do not. Objects provide inheritance
and the ability to hide fields from other modules. Objects with inheritance
enabled have information about their type at runtime so that the `of` operator
can be used to determine the object's type. The `of` operator is similar to
the `instanceof` operator in Java.
{==+==}
对象提供了许多元组没有的特性。对象提供继承和对其他模块隐藏字段的能力。启用继承的对象在运行时具有有关其类型的信息，因此可以使用 `of` 运算符来确定对象的类型。`of` 运算符类似于 Java 中的 `instanceof` 运算符。
{==+==}

{==+==}
  ```nim
  type
    Person = object of RootObj
      name*: string   # the * means that `name` is accessible from other modules
      age: int        # no * means that the field is hidden

    Student = ref object of Person # a student is a person
      id: int                      # with an id field

  var
    student: Student
    person: Person
  assert(student of Student) # is true
  assert(student of Person) # also true
  ```
{==+==}
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
{==+==}

{==+==}
Object fields that should be visible from outside the defining module have to
be marked by `*`. In contrast to tuples, different object types are
never *equivalent*, they are nominal types whereas tuples are structural.
Objects that have no ancestor are implicitly `final` and thus have no hidden
type information. One can use the `inheritable` pragma to
introduce new object roots apart from `system.RootObj`.
{==+==}
对模块外部可见的对象字段必须用 `*` 标记。与元组相反，不同的对象类型永远不会 *等价* 。 没有祖先的对象是隐式的 `final` ，因此没有隐藏的类型字段。 可以使用 `inheritable` 编译指示来引入除`system.RootObj`之外的新根对象。
{==+==}

{==+==}
  ```nim
  type
    Person = object # example of a final object
      name*: string
      age: int

    Student = ref object of Person # Error: inheritance only works with non-final objects
      id: int
  ```
{==+==}
  ```nim
  type
    Person = object # final 对象的例子
      name*: string
      age: int

    Student = ref object of Person # 错误: 继承只能用于非final对象
      id: int
  ```
{==+==}


{==+==}
The assignment operator for tuples and objects copies each component.
The methods to override this copying behavior are described `here
<manual.html#procedures-type-bound-operations>`_.
{==+==}
元组和对象的赋值操作符复制每个组件。` 这里 <manual.html#procedures-type-bound-operations>`_ 描述了覆盖这种复制行为的方法。
{==+==}

{==+==}
Object construction
-------------------
{==+==}
对象构造
--------
{==+==}

{==+==}
Objects can also be created with an `object construction expression`:idx: that
has the syntax `T(fieldA: valueA, fieldB: valueB, ...)` where `T` is
an `object` type or a `ref object` type:
{==+==}
对象也可以使用 `object construction expression`:idx: 创建, 即以下语法 `T(fieldA: valueA, fieldB: valueB, ...)` 其中 `T` 是 `object` 类型或 `ref object` 类型：
{==+==}

{==+==}
  ```nim
  type
    Student = object
      name: string
      age: int
    PStudent = ref Student
  var a1 = Student(name: "Anton", age: 5)
  var a2 = PStudent(name: "Anton", age: 5)
  # this also works directly:
  var a3 = (ref Student)(name: "Anton", age: 5)
  # not all fields need to be mentioned, and they can be mentioned out of order:
  var a4 = Student(age: 5)
  ```
{==+==}
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
{==+==}

{==+==}
Note that, unlike tuples, objects require the field names along with their values.
For a `ref object` type `system.new` is invoked implicitly.
{==+==}
请注意，与元组不同，对象需要字段名称及其值。 对于 `ref object` 类型， `system.new` 是隐式调用的。
{==+==}


{==+==}
Object variants
---------------
{==+==}
对象变体
--------
{==+==}

{==+==}
Often an object hierarchy is an overkill in certain situations where simple variant
types are needed. Object variants are tagged unions discriminated via an
enumerated type used for runtime type flexibility, mirroring the concepts of
*sum types* and *algebraic data types (ADTs)* as found in other languages.
{==+==}
在需要简单变体类型的某些情况下，对象层次结构通常有点过了。 对象变体是通过用于运行时类型灵活性的枚举类型区分的标记联合，对照如在其他语言中找到的 *sum类型* 和 *代数数据类型(ADTs)* 的概念。
{==+==}

{==+==}
An example:
{==+==}
一个例子：
{==+==}

{==+==}
  ```nim
  # This is an example of how an abstract syntax tree could be modelled in Nim
  type
    NodeKind = enum  # the different node types
      nkInt,          # a leaf with an integer value
      nkFloat,        # a leaf with a float value
      nkString,       # a leaf with a string value
      nkAdd,          # an addition
      nkSub,          # a subtraction
      nkIf            # an if statement
    Node = ref NodeObj
    NodeObj = object
      case kind: NodeKind  # the `kind` field is the discriminator
      of nkInt: intVal: int
      of nkFloat: floatVal: float
      of nkString: strVal: string
      of nkAdd, nkSub:
        leftOp, rightOp: Node
      of nkIf:
        condition, thenPart, elsePart: Node

  # create a new case object:
  var n = Node(kind: nkIf, condition: nil)
  # accessing n.thenPart is valid because the `nkIf` branch is active:
  n.thenPart = Node(kind: nkFloat, floatVal: 2.0)

  # the following statement raises an `FieldDefect` exception, because
  # n.kind's value does not fit and the `nkString` branch is not active:
  n.strVal = ""

  # invalid: would change the active object branch:
  n.kind = nkInt

  var x = Node(kind: nkAdd, leftOp: Node(kind: nkInt, intVal: 4),
                            rightOp: Node(kind: nkInt, intVal: 2))
  # valid: does not change the active object branch:
  x.kind = nkSub
  ```
{==+==}
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
{==+==}

{==+==}
As can be seen from the example, an advantage to an object hierarchy is that
no casting between different object types is needed. Yet, access to invalid
object fields raises an exception.
{==+==}
从示例中可以看出，对象层次结构的优点是不需要在不同对象类型之间进行转换。 但是，访问无效对象字段会引发异常。
{==+==}

{==+==}
The syntax of `case` in an object declaration follows closely the syntax of
the `case` statement: The branches in a `case` section may be indented too.
{==+==}
在对象声明中的 `case` 语句和标准 `case` 语句语法一致：`case`语句的分支也是如此
{==+==}

{==+==}
In the example, the `kind` field is called the `discriminator`:idx:\: For
safety, its address cannot be taken and assignments to it are restricted: The
new value must not lead to a change of the active object branch. Also, when the
fields of a particular branch are specified during object construction, the
corresponding discriminator value must be specified as a constant expression.
{==+==}
在示例中， `kind` 字段称为 `discriminator`:idx:\:  鉴别字段，为安全起见，不能对其进行地址限制，并且对其赋值进行限制：新值不得导致活动对象分支发生变化。 此外，在对象构造期间指定特定分支的字段时，必须将相应的鉴别字段值指定为常量表达式。
{==+==}

{==+==}
Instead of changing the active object branch, replace the old object in memory
with a new one completely:
{==+==}
与改变活动的对象分支不同，可以将内存中的旧对象换成一个全新的对象。
{==+==}

{==+==}
  ```nim
  var x = Node(kind: nkAdd, leftOp: Node(kind: nkInt, intVal: 4),
                            rightOp: Node(kind: nkInt, intVal: 2))
  # change the node's contents:
  x[] = NodeObj(kind: nkString, strVal: "abc")
  ```
{==+==}
  ```nim
  var x = Node(kind: nkAdd, leftOp: Node(kind: nkInt, intVal: 4),
                            rightOp: Node(kind: nkInt, intVal: 2))
  # 改变节点的内容
  x[] = NodeObj(kind: nkString, strVal: "abc")
  ```
{==+==}


{==+==}
Starting with version 0.20 `system.reset` cannot be used anymore to support
object branch changes as this never was completely memory safe.
{==+==}
从版本0.20开始 `system.reset` 不能再用于支持对象分支的更改，因为这从来就不是完全内存安全的。
{==+==}

{==+==}
As a special rule, the discriminator kind can also be bounded using a `case`
statement. If possible values of the discriminator variable in a
`case` statement branch are a subset of discriminator values for the selected
object branch, the initialization is considered valid. This analysis only works
for immutable discriminators of an ordinal type and disregards `elif`
branches. For discriminator values with a `range` type, the compiler
checks if the entire range of possible values for the discriminator value is
valid for the chosen object branch.
{==+==}
作为一项特殊规则，鉴别字段类型也可以使用 `case` 语句来限制。 如果 `case` 语句分支中的鉴别字段变量的可能值是所选对象分支的鉴别字段值的子集，则初始化被认为是有效的。 此分析仅适用于序数类型的不可变判别符，并忽略 `elif` 分支。对于具有`range`类型的鉴别器值，编译器会检查鉴别器值的整个可能值范围是否对所选对象分支有效。
{==+==}

{==+==}
A small example:
{==+==}
一个小例子：
{==+==}

{==+==}
  ```nim
  let unknownKind = nkSub

  # invalid: unsafe initialization because the kind field is not statically known:
  var y = Node(kind: unknownKind, strVal: "y")

  var z = Node()
  case unknownKind
  of nkAdd, nkSub:
    # valid: possible values of this branch are a subset of nkAdd/nkSub object branch:
    z = Node(kind: unknownKind, leftOp: Node(), rightOp: Node())
  else:
    echo "ignoring: ", unknownKind

  # also valid, since unknownKindBounded can only contain the values nkAdd or nkSub
  let unknownKindBounded = range[nkAdd..nkSub](unknownKind)
  z = Node(kind: unknownKindBounded, leftOp: Node(), rightOp: Node())
  ```
{==+==}
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
{==+==}


{==+==}
cast uncheckedAssign
--------------------
{==+==}
cast uncheckedAssign
--------------------
{==+==}

{==+==}
Some restrictions for case objects can be disabled via a `{.cast(uncheckedAssign).}` section:
{==+==}
case对象的一些限制可以通过 `{.cast(uncheckedAssign).}` 禁用:
{==+==}

{==+==}
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
    # inside the 'cast' section it is allowed to pass 't.kind' to a 'var T' parameter:
    passToVar(t.kind)

    # inside the 'cast' section it is allowed to set field 's' even though the
    # constructed 'kind' field has an unknown value:
    t = Token(kind: t.kind, s: "abc")

    # inside the 'cast' section it is allowed to assign to the 't.kind' field directly:
    t.kind = intLit
  ```
{==+==}
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
{==+==}


{==+==}
Set type
--------
{==+==}
集合类型
--------
{==+==}

{-----}
.. include:: sets_fragment.txt
{-----}

{==+==}
Reference and pointer types
---------------------------
{==+==}
引用和指针类型
--------------
{==+==}

{==+==}
References (similar to pointers in other programming languages) are a
way to introduce many-to-one relationships. This means different references can
point to and modify the same location in memory (also called `aliasing`:idx:).
{==+==}
引用（类似于其他编程语言中的指针）是引入多对一关系的一种方式。 这意味着不同的引用可以指向并修改内存中的相同位置（也称为 `aliasing`:idx: 别名)。
{==+==}

{==+==}
Nim distinguishes between `traced`:idx: and `untraced`:idx: references.
Untraced references are also called *pointers*. Traced references point to
objects of a garbage-collected heap, untraced references point to
manually allocated objects or objects somewhere else in memory. Thus,
untraced references are *unsafe*. However, for certain low-level operations
(accessing the hardware) untraced references are unavoidable.
{==+==}
Nim区分 `traced`:idx: 、`untraced`:idx: 追踪和未追踪引用。 未追踪引用也叫 *指针* 。 追踪引用指向垃圾回收堆中的对象，未追踪引用指向手动分配对象或内存中其它位置的对象。 因此，未追踪引用是 *不安全* 的。 然而对于某些访问硬件的低级操作，未追踪引用是不可避免的。
{==+==}

{==+==}
Traced references are declared with the **ref** keyword, untraced references
are declared with the **ptr** keyword. In general, a `ptr T` is implicitly
convertible to the `pointer` type.
{==+==}
使用**ref**关键字声明追踪引用，使用**ptr**关键字声明未追踪引用。 通常， `ptr T` 可以隐式转换为 `pointer` 类型。
{==+==}

{==+==}
An empty subscript `[]` notation can be used to de-refer a reference,
the `addr` procedure returns the address of an item. An address is always
an untraced reference.
Thus, the usage of `addr` is an *unsafe* feature.
{==+==}
空的下标 `[]` 表示法可以用来取代引用， `addr` 过程返回一个对象的地址。 地址始终是未追踪的引用。 因此， `addr` 的使用是 *不安全的* 功能。
{==+==}

{==+==}
The `.` (access a tuple/object field operator)
and `[]` (array/string/sequence index operator) operators perform implicit
dereferencing operations for reference types:
{==+==}
`.`（访问元组和对象字段运算符）和 `[]`（数组/字符串/序列索引运算符）运算符对引用类型执行隐式解引用操作：
{==+==}

{==+==}
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
  # no need to write n[].data; in fact n[].data is highly discouraged!
  ```
{==+==}
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
{==+==}

{==+==}
Automatic dereferencing can be performed for the first argument of a routine
call, but this is an experimental feature and is described `here
<manual_experimental.html#automatic-dereferencing>`_.
{==+==}
可以对例程调用的第一个参数执行自动取消引用，但这是一个实验性功能，在 `这里 <manual_experimental.html#automatic-dereferencing>`_ 进行了说明。
{==+==}

{==+==}
In order to simplify structural type checking, recursive tuples are not valid:
{==+==}
为了简化结构类型检查，递归元组无效：
{==+==}

{==+==}
  ```nim
  # invalid recursion
  type MyTuple = tuple[a: ref MyTuple]
  ```
{==+==}
  ```nim
  # 无效递归
  type MyTuple = tuple[a: ref MyTuple]
  ```
{==+==}

{==+==}
Likewise `T = ref T` is an invalid type.
{==+==}
同样， `T = ref T` 是无效类型。
{==+==}

{==+==}
As a syntactical extension, `object` types can be anonymous if
declared in a type section via the `ref object` or `ptr object` notations.
This feature is useful if an object should only gain reference semantics:
{==+==}
作为语法扩展，如果在类型部分中通过 `ref object` 或 `ptr object` 符号声明，则`object` 类型可以是匿名的。 如果对象只应获取引用语义，则此功能非常有用：
{==+==}

{-----}
  ```nim
  type
    Node = ref object
      le, ri: Node
      data: int
  ```
{-----}


{==+==}
To allocate a new traced object, the built-in procedure `new` has to be used.
To deal with untraced memory, the procedures `alloc`, `dealloc` and
`realloc` can be used. The documentation of the `system <system.html>`_ module
contains further information.
{==+==}
要分配新的追踪对象，必须使用内置过程 `new` 。 为了处理未追踪的内存，可以使用过程 `alloc` ， `dealloc` 和 `realloc` 。  `system <system.html>`_ 系统模块的文档包含更多信息。
{==+==}


{==+==}
Nil
---
{==+==}
空(Nil)
-------
{==+==}

{==+==}
If a reference points to *nothing*, it has the value `nil`. `nil` is the
default value for all `ref` and `ptr` types. The `nil` value can also be
used like any other literal value. For example, it can be used in an assignment
like `myRef = nil`.
{==+==}
如果一个引用什么都不指向，那么它的值为`nil`。`nil` 是所有 `ref` 和 `ptr` 类型的默认值。`nil` 值也可以像任何其他字面值一样使用。例如，它可以用在像 `my Ref = nil` 这样的赋值中。
{==+==}

{==+==}
Dereferencing `nil` is an unrecoverable fatal runtime error (and not a panic).
{==+==}
取消引用 `nil` 是一个不可恢复的致命运行时错误（而不是panic）。
{==+==}

{==+==}
A successful dereferencing operation `p[]` implies that `p` is not nil. This
can be exploited by the implementation to optimize code like:
{==+==}
成功的解引用操作 `p[]` 意味着 `p` 不是 nil。可以利用它来优化代码，例如：
{==+==}

{==+==}
  ```nim
  p[].field = 3
  if p != nil:
    # if p were nil, `p[]` would have caused a crash already,
    # so we know `p` is always not nil here.
    action()
  ```
{==+==}
  ```nim
  p[].field = 3
  if p != nil:
    # 如果p是nil, 那么 `p[]` 会导致错误
    # 所以我们知道这里`p`永远不会是nil
    action()
  ```
{==+==}

{==+==}
Into:
{==+==}
那么上述代码可以变成：
{==+==}

{-----}
  ```nim
  p[].field = 3
  action()
  ```
{-----}


{==+==}
*Note*: This is not comparable to C's "undefined behavior" for
dereferencing NULL pointers.
{==+==}
*注意*：这与 C 用于取消引用 NULL 指针的 "未定义行为" 不具有可比性。
{==+==}
