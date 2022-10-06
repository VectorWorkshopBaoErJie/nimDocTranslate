{==+==}
Case statement
--------------
{==+==}
Case 语句
------------------
{==+==}

{==+==}
Example:
{==+==}
例如:
{==+==}

{==+==}
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
{==+==}
  ```nim
  let line = readline(stdin)
  case line
  of "delete-everything", "restart-computer":
    echo "permission denied"
  of "go-for-a-walk":     echo "please yourself"
  elif line.len == 0:     echo "empty" # optional, must come after `of` branches
  else:                   echo "unknown command" # ditto

  # 允许分支缩进; 
  # 在选择表达式之后的冒号是可选:
  case readline(stdin):
    of "delete-everything", "restart-computer":
      echo "permission denied"
    of "go-for-a-walk":     echo "please yourself"
    else:                   echo "unknown command"
  ```
{==+==}


{==+==}
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
{==+==}
`case` 语句类似于 `if` 语句, 它表示一种多分支选择。
关键字 `case` 后面的表达式进行求值, 如果其值在 *slicelist* 列表中, 则执行 `of` 关键字之后相应语句。
如果其值不在已给定的 *slicelist* 中, 那么所执行的 `elif` 、 `else` 语句部分与 `if` 语句相同, `elif` 的处理就像 `else: if` 。
如果没有 `else` 或 `elif` 部分，并且 `expr` 未能持有所有可能的值,则在 *slicelist* 会发生静态错误。
但这仅适用于序数类型的表达式。 `expr` 的 "所有可能的值" 由 `expr` 的类型决定，为了防止静态错误应该使用 `else: discard`。
{==+==}

{==+==}
For non-ordinal types, it is not possible to list every possible value and so
these always require an `else` part.
An exception to this rule is for the `string` type, which currently doesn't
require a trailing `else` or `elif` branch; it's unspecified whether this will
keep working in future versions.
{==+==}
对于非序数类型, 不可能列出每个可能的值，所以总是需要 `else` 部分。
此规则 `string` 类型是例外，目前，它不需要在后面添加 `else` 或 `elif` 分支，
但在未来版本中不确定。
{==+==}

{==+==}
Because case statements are checked for exhaustiveness during semantic analysis,
the value in every `of` branch must be a constant expression.
This restriction also allows the compiler to generate more performant code.
{==+==}
因为在语义分析期间检查case语句的穷尽性，所以每个 `of` 分支中的值必须是常量表达式。
此限制可以让编译器生成更高性能的代码。
{==+==}

{==+==}
As a special semantic extension, an expression in an `of` branch of a case
statement may evaluate to a set or array constructor; the set or array is then
expanded into a list of its elements:
{==+==}
一种特殊的语义扩展是, case语句 `of` 分支中的表达式可以为集合或数组构造器，
然后将集合或数组扩展为其元素的列表:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
The `case` statement doesn't produce an l-value, so the following example
won't work:
{==+==}
 `case` 语句不会产生左值, 所以下面的示例无效:
{==+==}

{==+==}
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
{==+==}
  ```nim
  type
    Foo = ref object
      x: seq[string]

  proc get_x(x: Foo): var seq[string] =
    # 无效
    case true
    of true:
      x.x
    else:
      x.x

  var foo = Foo(x: @[])
  foo.get_x().add("asd")
  ```
{==+==}

{==+==}
This can be fixed by explicitly using `result` or `return`:
{==+==}
这可以通过显式使用 `result` 或 `return` 来修复:
{==+==}

{==+==}
  ```nim
  proc get_x(x: Foo): var seq[string] =
    case true
    of true:
      result = x.x
    else:
      result = x.x
  ```
{==+==}
  ```nim
  proc get_x(x: Foo): var seq[string] =
    case true
    of true:
      result = x.x
    else:
      result = x.x
  ```
{==+==}

{==+==}
When statement
--------------
{==+==}
When 语句
------------------
{==+==}

{==+==}
Example:
{==+==}
示例:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
The `when` statement is almost identical to the `if` statement with some
exceptions:
{==+==}
 `when` 语句几乎与 `if` 语句相同, 但有一些例外:
{==+==}

{==+==}
* Each condition (`expr`) has to be a constant expression (of type `bool`).
* The statements do not open a new scope.
* The statements that belong to the expression that evaluated to true are
  translated by the compiler, the other statements are not checked for
  semantics! However, each condition is checked for semantics.
{==+==}
* 每个条件 ( `expr` ) 必须是一个类型为 `bool` 的常量表达式。
* 语句不产生新作用域。
* 计算为true的表达式所属语句将由编译器翻译，而只检查每个条件的语义，不检查其他语句语义!
{==+==}

{==+==}
The `when` statement enables conditional compilation techniques. As
a special syntactic extension, the `when` construct is also available
within `object` definitions.
{==+==}
 `when` 语句启用了条件编译技术。一种特殊的语法扩展是，可以在 `object` 定义中使用 `when` 结构。
{==+==}

{==+==}
When nimvm statement
--------------------
{==+==}
When nimvm 语句
------------------------------
{==+==}

{==+==}
`nimvm` is a special symbol that may be used as the expression of a
`when nimvm` statement to differentiate the execution path between
compile-time and the executable.
{==+==}
`nimvm` 是一个特殊标识符, 可用 `when nimvm` 语句表达式来判断路径，编译时或可执行文件之间执行。
{==+==}

{==+==}
Example:
{==+==}
示例:
{==+==}

{==+==}
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
{==+==}
  ```nim
  proc someProcThatMayRunInCompileTime(): bool =
    when nimvm:
      # 编译时采用此分支.
      result = true
    else:
      # 可执行文件中采用此分支.
      result = false
  const ctValue = someProcThatMayRunInCompileTime()
  let rtValue = someProcThatMayRunInCompileTime()
  assert(ctValue == true)
  assert(rtValue == false)
  ```
{==+==}

{==+==}
A `when nimvm` statement must meet the following requirements:
{==+==}
 `when nimvm` 语句必须满足以下要求: 
{==+==}

{==+==}
* Its expression must always be `nimvm`. More complex expressions are not
  allowed.
* It must not contain `elif` branches.
* It must contain an `else` branch.
* Code in branches must not affect semantics of the code that follows the
  `when nimvm` statement. E.g. it must not define symbols that are used in
  the following code.
{==+==}
* 表达式必须是 `nimvm` ，不允许使用的复杂表达式。
* 不得含有 `elif` 分支。
* 必须含有 `else` 分支。
* 分支中的代码不能影响 `when nimvm` 语句之后代码的语义，比如不能定义后续代码中使用的标识符。
{==+==}

{==+==}
Return statement
----------------
{==+==}
Return 语句
----------------------
{==+==}

{==+==}
Example:
{==+==}
比如:
{==+==}

{==+==}
  ```nim
  return 40 + 2
  ```
{==+==}
  ```nim
  return 40 + 2
  ```
{==+==}

{==+==}
The `return` statement ends the execution of the current procedure.
It is only allowed in procedures. If there is an `expr`, this is syntactic
sugar for:
{==+==}
 `return` 语句将结束当前执行的过程，并只允许在过程中使用。如果这里是一个 `expr` , 将是语法糖:
{==+==}

{==+==}
  ```nim
  result = expr
  return result
  ```
{==+==}
  ```nim
  result = expr
  return result
  ```
{==+==}

{==+==}
`return` without an expression is a short notation for `return result` if
the proc has a return type. The `result`:idx: variable is always the return
value of the procedure. It is automatically declared by the compiler. As all
variables, `result` is initialized to (binary) zero:
{==+==}
如果proc有返回类型，不带表达式的 `return` 是 `return result` 的简短表示.
编译器自动声明的变量 `result`:idx: 始终是过程的返回值。与所有变量一样, `result` 会初始化为(二进制)0:
{==+==}

{==+==}
  ```nim
  proc returnZero(): int =
    # implicitly returns 0
  ```
{==+==}
  ```nim
  proc returnZero(): int =
    # 隐式返回0
  ```
{==+==}

{==+==}
Yield statement
---------------
{==+==}
Yield 语句
--------------------
{==+==}

{==+==}
Example:
{==+==}
示例:
{==+==}

{==+==}
  ```nim
  yield (1, 2, 3)
  ```
{==+==}
  ```nim
  yield (1, 2, 3)
  ```
{==+==}

{==+==}
The `yield` statement is used instead of the `return` statement in
iterators. It is only valid in iterators. Execution is returned to the body
of the for loop that called the iterator. Yield does not end the iteration
process, but the execution is passed back to the iterator if the next iteration
starts. See the section about iterators (`Iterators and the for statement`_)
for further information.
{==+==}
在迭代器中使用 `yield` 语句，而不是 `return` 语句。它只在迭代器中生效。执行后返回给调用迭代器的for循环体。
Yield不会结束迭代过程，但是如果下一次迭代开始，则执行会返回到迭代器。详情参阅 `迭代器和for语句`_ 部分。
{==+==}

{==+==}
Block statement
---------------
{==+==}
Block 语句
--------------------
{==+==}

{==+==}
Example:
{==+==}
示例: 
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
The block statement is a means to group statements to a (named) `block`.
Inside the block, the `break` statement is allowed to leave the block
immediately. A `break` statement can contain a name of a surrounding
block to specify which block is to be left.
{==+==}
block语句是一种将语句分组到命名的 `block` 的方法。在block语句内，允许用 `break` 语句立即跳出。 `break` 语句可以包含围绕的block的名称, 以指定要跳出的层级。
{==+==}

{==+==}
Break statement
---------------
{==+==}
Break 语句
--------------------
{==+==}

{==+==}
Example:
{==+==}
示例:
{==+==}

{==+==}
  ```nim
  break
  ```
{==+==}
  ```nim
  break
  ```
{==+==}

{==+==}
The `break` statement is used to leave a block immediately. If `symbol`
is given, it is the name of the enclosing block that is to be left. If it is
absent, the innermost block is left.
{==+==}
 `break` 语句用于立即跳出block块。如果给出 `symbol` "标识符", 是指定要跳出的闭合的block的名称。如果未给出，则跳出最里面的block。
{==+==}

{==+==}
While statement
---------------
{==+==}
While 语句
--------------------
{==+==}

{==+==}
Example:
{==+==}
示例:
{==+==}

{==+==}
  ```nim
  echo "Please tell me your password:"
  var pw = readLine(stdin)
  while pw != "12345":
    echo "Wrong password! Next try:"
    pw = readLine(stdin)
  ```
{==+==}
  ```nim
  echo "Please tell me your password:"
  var pw = readLine(stdin)
  while pw != "12345":
    echo "Wrong password! Next try:"
    pw = readLine(stdin)
  ```
{==+==}

{==+==}
The `while` statement is executed until the `expr` evaluates to false.
Endless loops are no error. `while` statements open an `implicit block`
so that they can be left with a `break` statement.
{==+==}
`while` 语句执行时直到 `expr` 计算结果为false。无尽的循环不会报告错误。 `while` 语句会打开一个 `implicit block` "隐式块"，因而可以用 `break` 语句跳出。
{==+==}

{==+==}
Continue statement
------------------
{==+==}
Continue 语句
--------------------------
{==+==}

{==+==}
A `continue` statement leads to the immediate next iteration of the
surrounding loop construct. It is only allowed within a loop. A continue
statement is syntactic sugar for a nested block:
{==+==}
 `continue` 语句会使循环结构进行下一次迭代，其只允许在循环中使用。continue语句是嵌套block的语法糖:
{==+==}

{==+==}
  ```nim
  while expr1:
    stmt1
    continue
    stmt2
  ```
{==+==}
  ```nim
  while expr1:
    stmt1
    continue
    stmt2
  ```
{==+==}

{==+==}
Is equivalent to:
{==+==}
等价于:
{==+==}

{==+==}
  ```nim
  while expr1:
    block myBlockName:
      stmt1
      break myBlockName
      stmt2
  ```
{==+==}
  ```nim
  while expr1:
    block myBlockName:
      stmt1
      break myBlockName
      stmt2
  ```
{==+==}

{==+==}
Assembler statement
-------------------
{==+==}
汇编语句
----------------
{==+==}

{==+==}
The direct embedding of assembler code into Nim code is supported
by the unsafe `asm` statement. Identifiers in the assembler code that refer to
Nim identifiers shall be enclosed in a special character which can be
specified in the statement's pragmas. The default special character is `'\`'`:
{==+==}
不安全的 `asm` 语句支持将汇编代码直接嵌入到Nim代码中。在汇编代码中引用Nim的标识符需要包含在特定字符中，该字符可以在语句的编译指示中指定。默认特定字符是 `'\`'` :
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
If the GNU assembler is used, quotes and newlines are inserted automatically:
{==+==}
如果使用GNU汇编器，则会自动插入引号和换行符: 
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
Instead of:
{==+==}
替代:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
Using statement
---------------
{==+==}
Using语句
------------------
{==+==}

{==+==}
The `using` statement provides syntactic convenience in modules where
the same parameter names and types are used over and over. Instead of:
{==+==}
在模块中反复使用相同的参数名称和类型时，`using` 语句提供了语法上的便利，而不必:
{==+==}

{==+==}
  ```nim
  proc foo(c: Context; n: Node) = ...
  proc bar(c: Context; n: Node, counter: int) = ...
  proc baz(c: Context; n: Node) = ...
  ```
{==+==}
  ```nim
  proc foo(c: Context; n: Node) = ...
  proc bar(c: Context; n: Node, counter: int) = ...
  proc baz(c: Context; n: Node) = ...
  ```
{==+==}

{==+==}
One can tell the compiler about the convention that a parameter of
name `c` should default to type `Context`, `n` should default to
`Node` etc.:
{==+==}
你可以告知编译器一个名为 `c` 的参数默认类型为 `Context` , `n`的默认类型为 `Node` :
{==+==}

{==+==}
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
{==+==}
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
    # 'x' 和 'y' 是 'int' 类型。
  ```
{==+==}

{==+==}
The `using` section uses the same indentation based grouping syntax as
a `var` or `let` section.
{==+==}
 `using` 部分使用缩进的分组语法，与 `var` 或 `let` 部分相同。
{==+==}

{==+==}
Note that `using` is not applied for `template` since the untyped template
parameters default to the type `system.untyped`.
{==+==}
注意, `using` 在 `template` 不适用，因为untyped模板参数默认是 `system.untyped` 类型。
{==+==}

{==+==}
Mixing parameters that should use the `using` declaration with parameters
that are explicitly typed is possible and requires a semicolon between them.
{==+==}
使用 `using` 声明和显式类型的参数混合时，它们之间需要分号。
{==+==}

{==+==}
If expression
-------------
{==+==}
If 表达式
------------------
{==+==}

{==+==}
An `if` expression is almost like an if statement, but it is an expression.
This feature is similar to *ternary operators* in other languages.
Example:
{==+==}
`if` 表达式与if语句非常相似，但它是一个表达式。这个特性类似于其他语言中的 *三元操作符* 。
示例: 
{==+==}

{==+==}
  ```nim
  var y = if x > 8: 9 else: 10
  ```
{==+==}
  ```nim
  var y = if x > 8: 9 else: 10
  ```
{==+==}

{==+==}
An if expression always results in a value, so the `else` part is
required. `Elif` parts are also allowed.
{==+==}
if表达式总是会产生一个值，所以必需有 `else` 部分。也可以使用`Elif` 部分。
{==+==}

{==+==}
When expression
---------------
{==+==}
When表达式
--------------------
{==+==}

{==+==}
Just like an `if` expression, but corresponding to the `when` statement.
{==+==}
和 `if` 表达式相似，与 `when` 语句对应。
{==+==}

{==+==}
Case expression
---------------
{==+==}
Case表达式
--------------------
{==+==}

{==+==}
The `case` expression is again very similar to the case statement:
{==+==}
 `case` 表达式与case语句非常相似:
{==+==}

{==+==}
  ```nim
  var favoriteFood = case animal
    of "dog": "bones"
    of "cat": "mice"
    elif animal.endsWith"whale": "plankton"
    else:
      echo "I'm not sure what to serve, but everybody loves ice cream"
      "ice cream"
  ```
{==+==}
  ```nim
  var favoriteFood = case animal
    of "dog": "bones"
    of "cat": "mice"
    elif animal.endsWith"whale": "plankton"
    else:
      echo "I'm not sure what to serve, but everybody loves ice cream"
      "ice cream"
  ```
{==+==}

{==+==}
As seen in the above example, the case expression can also introduce side
effects. When multiple statements are given for a branch, Nim will use
the last expression as the result value.
{==+==}
如上例所示，case表达式也可以引入副作用。当分支给出多个语句时，Nim将使用最后一个表达式作为结果值。
{==+==}

{==+==}
Block expression
----------------
{==+==}
Block表达式
----------------------
{==+==}

{==+==}
A `block` expression is almost like a block statement, but it is an expression
that uses the last expression under the block as the value.
It is similar to the statement list expression, but the statement list expression
does not open a new block scope.
{==+==}
 `block` 表达式几乎和block语句相同，但它是一个表达式，它使用block的最后一个表达式作为值。它类似于语句列表表达式，但语句列表表达式不会创建新的block作用域。
{==+==}

{==+==}
  ```nim
  let a = block:
    var fib = @[0, 1]
    for i in 0..10:
      fib.add fib[^1] + fib[^2]
    fib
  ```
{==+==}
  ```nim
  let a = block:
    var fib = @[0, 1]
    for i in 0..10:
      fib.add fib[^1] + fib[^2]
    fib
  ```
{==+==}

{==+==}
Table constructor
-----------------
{==+==}
表构造器
--------------------
{==+==}

{==+==}
A table constructor is syntactic sugar for an array constructor:
{==+==}
表构造器是数组构造器的语法糖: 
{==+==}

{==+==}
  ```nim
  {"key1": "value1", "key2", "key3": "value2"}

  # is the same as:
  [("key1", "value1"), ("key2", "value2"), ("key3", "value2")]
  ```
{==+==}
  ```nim
  {"key1": "value1", "key2", "key3": "value2"}

  # 等同于:
  [("key1", "value1"), ("key2", "value2"), ("key3", "value2")]
  ```
{==+==}

{==+==}
The empty table can be written `{:}` (in contrast to the empty set
which is `{}`) which is thus another way to write the empty array
constructor `[]`. This slightly unusual way of supporting tables
has lots of advantages:
{==+==}
空表可以写成 `{:}` (对比 `{}` 空集合)，这是另一种写为空数组构造器 `[]` 的方法。这种略微不同寻常的书写表的方式有很多优点:
{==+==}

{==+==}
* The order of the (key,value)-pairs is preserved, thus it is easy to
  support ordered dicts with for example `{key: val}.newOrderedTable`.
* A table literal can be put into a `const` section and the compiler
  can easily put it into the executable's data section just like it can
  for arrays and the generated data section requires a minimal amount
  of memory.
* Every table implementation is treated equally syntactically.
* Apart from the minimal syntactic sugar, the language core does not need to
  know about tables.
{==+==}
* 保留了(键, 值)对的顺序, 因此更容易支持有序的字典，例如 `{key: val}.newOrderedTable` 。
* 表字面值可以放入 `const` 部分，编译器可以更容易地将它放入可执行文件的数据部分，就像数组一样，生成的数据部分占用更少的内存。
* 每个表的实现在语法上一样。
* 除了这个最低限度的语法糖, 语言核心不需要关心表。
{==+==}

{==+==}
Type conversions
----------------
{==+==}
类型转换
----------------
{==+==}

{==+==}
Syntactically a *type conversion* is like a procedure call, but a
type name replaces the procedure name. A type conversion is always
safe in the sense that a failure to convert a type to another
results in an exception (if it cannot be determined statically).
{==+==}
从语法上来说， *类型转换* 类似于过程调用，只是用一个类型名替换了过程名。类型转换总是安全的，将类型转换失败会导致异常(如果不能静态确定)。
{==+==}

{==+==}
Ordinary procs are often preferred over type conversions in Nim: For instance,
`$` is the `toString` operator by convention and `toFloat` and `toInt`
can be used to convert from floating-point to integer or vice versa.
{==+==}
普通的procs通常比Nim中的类型转换更友好: 例如, `$` 是 `toString` 运算符, 而 `toFloat` 和 `toInt` 可从浮点数转换为整数,反之亦然。
{==+==}

{==+==}
Type conversion can also be used to disambiguate overloaded routines:
{==+==}
类型转换也可用于消除重载例程的歧义:
{==+==}

{==+==}
  ```nim
  proc p(x: int) = echo "int"
  proc p(x: string) = echo "string"

  let procVar = (proc(x: string))(p)
  procVar("a")
  ```
{==+==}
  ```nim
  proc p(x: int) = echo "int"
  proc p(x: string) = echo "string"

  let procVar = (proc(x: string))(p)
  procVar("a")
  ```
{==+==}

{==+==}
Since operations on unsigned numbers wrap around and are unchecked so are
type conversions to unsigned integers and between unsigned integers. The
rationale for this is mostly better interoperability with the C Programming
language when algorithms are ported from C to Nim.
{==+==}
由于对无符号数的操作会环绕，且不会检查，因而到无符号整数的类型转换以及无符号整数之间的类型转换也会这样。
这样做的原因是，当算法从C移植到Nim时，可以更好地与C语言进行互操作。
{==+==}

{==+==}
Exception: Values that are converted to an unsigned type at compile time
are checked so that code like `byte(-1)` does not compile.
{==+==}
例外: 将检查在编译时转换为无符号类型的值, 以使 `byte(-1)` 之类代码无法编译。
{==+==}

{==+==}
**Note**: Historically the operations
were unchecked and the conversions were sometimes checked but starting with
the revision 1.0.4 of this document and the language implementation the
conversions too are now *always unchecked*.
{==+==}
**注意**: 历史版本中不检查运算，有时会检查转换，但从1.0.4语言版本实现开始，转换 *总是未检查* 。
{==+==}

{==+==}
Type casts
----------
{==+==}
类型强转
----------------
{==+==}

{==+==}
*Type casts* are a crude mechanism to interpret the bit pattern of an expression
as if it would be of another type. Type casts are only needed for low-level
programming and are inherently unsafe.
{==+==}
 *类型强转* 是一种粗暴的机制，对于表达式按位模式解释，就好像它就是另一种类型。类型强转仅用于低层编程，并且本质上是不安全的。
{==+==}

{==+==}
  ```nim
  cast[int](x)
  ```
{==+==}
  ```nim
  cast[int](x)
  ```
{==+==}

{==+==}
The target type of a cast must be a concrete type, for instance, a target type
that is a type class (which is non-concrete) would be invalid:
{==+==}
强制转换的目标类型必须是具体类型，例如，非具体的类型类目标将是无效的:
{==+==}

{==+==}
  ```nim
  type Foo = int or float
  var x = cast[Foo](1) # Error: cannot cast to a non concrete type: 'Foo'
  ```
{==+==}
  ```nim
  type Foo = int or float
  var x = cast[Foo](1) # Error: 不能转换为非具体类型: 'Foo'
  ```
{==+==}

{==+==}
Type casts should not be confused with *type conversions,* as mentioned in the
prior section. Unlike type conversions, a type cast cannot change the underlying
bit pattern of the data being cast (aside from that the size of the target type
may differ from the source type). Casting resembles *type punning* in other
languages or C++'s `reinterpret_cast`:cpp: and `bit_cast`:cpp: features.
{==+==}
类型强转不应与 *类型转换* 混淆, 如前所述，与类型转换不同，类型强转不能更改被转换数据的底层位模式(除了目标类型的大小可能与源类型不同之外)。强制转换类似于其他语言中的 *类型双关* 或c++的 `reinterpret_cast`:cpp: 和 `bit_cast`:cpp: 特性。
{==+==}

{==+==}
The addr operator
-----------------
{==+==}
addr操作符
--------------------
{==+==}

{==+==}
The `addr` operator returns the address of an l-value. If the type of the
location is `T`, the `addr` operator result is of the type `ptr T`. An
address is always an untraced reference. Taking the address of an object that
resides on the stack is **unsafe**, as the pointer may live longer than the
object on the stack and can thus reference a non-existing object. One can get
the address of variables. For easier interoperability with other compiled languages
such as C, retrieving the address of a `let` variable, a parameter,
or a `for` loop variable can be accomplished too:
{==+==}
 `addr` 运算符返回左值的地址。如果地址的类型是 `T`, 则 `addr` 运算符结果的类型为 `ptr T` 。地址总是一个未追踪引用的值。获取驻留在堆栈上的对象的地址是 **不安全的** , 因为指针可能比堆栈中的对象存在更久, 因此可以引用不存在的对象。我们得到变量的地址，是为了更容易与其他编译语言互操作(如C)，也可以做到检索 `let` 变量、参数或 `for` 循环变量的地址:
{==+==}

{==+==}
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
{==+==}
  ```nim
  let t1 = "Hello"
  var
    t2 = t1
    t3 : pointer = addr(t2)
  echo repr(addr(t2))
  # --> ref 0x7fff6b71b670 --> 0x10bb81050"Hello"
  echo cast[ptr string](t3)[]
  # --> Hello
  # 下面这行代码也可以使用
  echo repr(addr(t1))
  ```
{==+==}

{==+==}
The unsafeAddr operator
-----------------------
{==+==}
unsafeAddr操作符
--------------------------------
{==+==}

{==+==}
The `unsafeAddr` operator is a deprecated alias for the `addr` operator:
{==+==}
`unsafeAddr` 操作符是 `addr` 操作符已弃用的别名:
{==+==}

{==+==}
  ```nim
  let myArray = [1, 2, 3]
  foreignProcThatTakesAnAddr(unsafeAddr myArray)
  ```
{==+==}
  ```nim
  let myArray = [1, 2, 3]
  foreignProcThatTakesAnAddr(unsafeAddr myArray)
  ```
{==+==}

{==+==}
Procedures
==========
{==+==}
过程
========
{==+==}

{==+==}
What most programming languages call `methods`:idx: or `functions`:idx: are
called `procedures`:idx: in Nim. A procedure
declaration consists of an identifier, zero or more formal parameters, a return
value type and a block of code. Formal parameters are declared as a list of
identifiers separated by either comma or semicolon. A parameter is given a type
by `: typename`. The type applies to all parameters immediately before it,
until either the beginning of the parameter list, a semicolon separator, or an
already typed parameter, is reached. The semicolon can be used to make
separation of types and subsequent identifiers more distinct.
{==+==}
大多数编程语言中称之为 `methods`:idx "方法"或 `functions`:idx "函数"，在Nim中则称为 `procedures`:idx "过程"。过程声明由标识符、零个或多个形参、返回值类型和代码块组成，形参声明为由逗号或分号分隔的标识符列表。形参由 `: typename` 给出一个类型。该类型适用于紧接其之前的所有参数，直到参数列表的开头的分号分隔符或已经键入的参数。
分号可使类型和后续标识符的分隔更加清晰。
{==+==}

{==+==}
  ```nim
  # Using only commas
  proc foo(a, b: int, c, d: bool): int

  # Using semicolon for visual distinction
  proc foo(a, b: int; c, d: bool): int

  # Will fail: a is untyped since ';' stops type propagation.
  proc foo(a; b: int; c, d: bool): int
  ```
{==+==}
  ```nim
  # 只使用逗号
  proc foo(a, b: int, c, d: bool): int

  # 使用分号进行显式的区分
  proc foo(a, b: int; c, d: bool): int

  # 会失败: a是无类型的, 因为 ';' 为停止类型传播
  proc foo(a; b: int; c, d: bool): int
  ```
{==+==}

{==+==}
A parameter may be declared with a default value which is used if the caller
does not provide a value for the argument. The value will be reevaluated
every time the function is called.
{==+==}
可以使用默认值声明参数，如果调用者没有为参数提供值，则使用该默认值，每次调用函数时，都会重新计算该值。
{==+==}

{==+==}
  ```nim
  # b is optional with 47 as its default value.
  proc foo(a: int, b: int = 47): int
  ```
{==+==}
  ```nim
  # b是可选的, 默认值为47。
  proc foo(a: int, b: int = 47): int
  ```
{==+==}


{==+==}
Just as the comma propagates the types from right to left until the
first parameter or until a semicolon is hit, it also propagates the
default value starting from the parameter declared with it.
{==+==}
正如逗号从右到左传播类型，直到遇到第一个参数或分号，默认值也会从其声明的参数开始传播。
{==+==}

{==+==}
  ```nim
  # Both a and b are optional with 47 as their default values.
  proc foo(a, b: int = 47): int
  ```
{==+==}
  ```nim
  # a和b都是可选的，默认值为47。
  proc foo(a, b: int = 47): int
  ```
{==+==}

{==+==}
Parameters can be declared mutable and so allow the proc to modify those
arguments, by using the type modifier `var`.
{==+==}
参数可以声明为可变的，过程允许通过类型修饰符 `var` 来修饰参数。
{==+==}

{==+==}
  ```nim
  # "returning" a value to the caller through the 2nd argument
  # Notice that the function uses no actual return value at all (ie void)
  proc foo(inp: int, outp: var int) =
    outp = inp + 47
  ```
{==+==}
  ```nim
  # 通过第二个参数 "返回" 一个值给调用者
  # 请注意, 该函数实际没有使用真实的返回值(即void)
  proc foo(inp: int, outp: var int) =
    outp = inp + 47
  ```
{==+==}

{==+==}
If the proc declaration doesn't have a body, it is a `forward`:idx: declaration.
If the proc returns a value, the procedure body can access an implicitly declared
variable named `result`:idx: that represents the return value. Procs can be
overloaded. The overloading resolution algorithm determines which proc is the
best match for the arguments. Example:
{==+==}
如果proc声明没有过程体, 则是 `forward`:idx: "前置"声明。如果proc返回一个值，那么过程体可以访问一个名为 `result`:idx: 的隐式变量。过程可能会重载，重载解析算法会确定哪个proc是参数的最佳匹配。
示例: 
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
Calling a procedure can be done in many ways:
{==+==}
调用过程可以通过多种方式完成: 
{==+==}

{==+==}
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
{==+==}
  ```nim
  proc callme(x, y: int, s: string = "", c: char, b: bool = false) = ...

  # 带位置参数的调用                   # 参数绑定:
  callme(0, 1, "abc", '\t', true)       # (x=0, y=1, s="abc", c='\t', b=true)
  # 使用命名参数和位置参数调用:
  callme(y=1, x=0, "abd", '\t')         # (x=0, y=1, s="abd", c='\t', b=false)
  # 带命名参数的调用(顺序无关):
  callme(c='\t', y=1, x=0)              # (x=0, y=1, s="", c='\t', b=false)
  # 作为命令语句调用:不需要():
  callme 0, 1, "abc", '\t'              # (x=0, y=1, s="abc", c='\t', b=false)
  ```
{==+==}

{==+==}
A procedure may call itself recursively.
{==+==}
过程可以递归地调用自身。
{==+==}

{==+==}
`Operators`:idx: are procedures with a special operator symbol as identifier:
{==+==}
`Operators`:idx: "操作符"是将特定运算符作为标识符的过程:
{==+==}

{==+==}
  ```nim
  proc `$` (x: int): string =
    # converts an integer to a string; this is a prefix operator.
    result = intToStr(x)
  ```
{==+==}
  ```nim
  proc `$` (x: int): string =
    # 将整数转换为字符串;这是一个前缀操作符。
    result = intToStr(x)
  ```
{==+==}

{==+==}
Operators with one parameter are prefix operators, operators with two
parameters are infix operators. (However, the parser distinguishes these from
the operator's position within an expression.) There is no way to declare
postfix operators: all postfix operators are built-in and handled by the
grammar explicitly.
{==+==}
具有一个参数的操作符是前缀操作符，有两个参数的运算符是中缀操作符。(但是, 解析器将这些与操作符在表达式中的位置区分开来。) 无法声明后缀运算符，所有后缀运算符都是内置的，由语法明确指出。
{==+==}

{==+==}
Any operator can be called like an ordinary proc with the \`opr\`
notation. (Thus an operator can have more than two parameters):
{==+==}
任何操作符都可以像普通的proc一样用 \`opr\` 表示法调用。(因此操作符可以有两个以上的参数):
{==+==}

{==+==}
  ```nim
  proc `*+` (a, b, c: int): int =
    # Multiply and add
    result = a * b + c

  assert `*+`(3, 4, 6) == `+`(`*`(a, b), c)
  ```
{==+==}
  ```nim
  proc `*+` (a, b, c: int): int =
    # 乘 和 加
    result = a * b + c

  assert `*+`(3, 4, 6) == `+`(`*`(a, b), c)
  ```
{==+==}

{==+==}
Export marker
-------------
{==+==}
导出标记
----------------
{==+==}

{==+==}
If a declared symbol is marked with an `asterisk`:idx: it is exported from the
current module:
{==+==}
如果声明的标识符有 `asterisk`:idx: "星号"标记，表示从当前模块导出:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
Method call syntax
------------------
{==+==}
方法调用语法
------------------------
{==+==}

{==+==}
For object-oriented programming, the syntax `obj.methodName(args)` can be used
instead of `methodName(obj, args)`. The parentheses can be omitted if
there are no remaining arguments: `obj.len` (instead of `len(obj)`).
{==+==}
对于面向对象的编程，可以用 `obj.methodName(args)` 语法，取代 `methodName(obj, args)` 。
如果没有多余的参数，则可以省略括号: `obj.len` (取代 `len(obj)` )。
{==+==}

{==+==}
This method call syntax is not restricted to objects, it can be used
to supply any type of first argument for procedures:
{==+==}
此方法调用语法不限于对象，可用于为过程提供任意类型的第一个参数:
{==+==}

{==+==}
  ```nim
  echo "abc".len # is the same as echo len "abc"
  echo "abc".toUpper()
  echo {'a', 'b', 'c'}.card
  stdout.writeLine("Hallo") # the same as writeLine(stdout, "Hallo")
  ```
{==+==}
  ```nim
  echo "abc".len # 等同于 echo len "abc"
  echo "abc".toUpper()
  echo {'a', 'b', 'c'}.card
  stdout.writeLine("Hallo") # 等同于 writeLine(stdout, "Hallo")
  ```
{==+==}

{==+==}
Another way to look at the method call syntax is that it provides the missing
postfix notation.
{==+==}
另一种看待方法调用语法的方式是，它是提供缺失的后缀表示法。
{==+==}

{==+==}
The method call syntax conflicts with explicit generic instantiations:
`p[T](x)` cannot be written as `x.p[T]` because `x.p[T]` is always
parsed as `(x.p)[T]`.
{==+==}
方法调用语法与显式泛型实例化冲突: `p[T](x)` 不能写为 `x.p[T]` 因为 `x.p[T]` 总是被解析为 `(x.p)[T]` 。
{==+==}

{==+==}
See also: `Limitations of the method call syntax
<#templates-limitations-of-the-method-call-syntax>`_.
{==+==}
详见: `方法调用语法的限制 <#templates-limitations-of-the-method-call-syntax>`_ 。
{==+==}

{==+==}
The `[: ]` notation has been designed to mitigate this issue: `x.p[:T]`
is rewritten by the parser to `p[T](x)`, `x.p[:T](y)` is rewritten to
`p[T](x, y)`. Note that `[: ]` has no AST representation, the rewrite
is performed directly in the parsing step.
{==+==}
`[: ]` 符号是为了缓解这个问题: `x.p[:T]` 由解析器重写为 `p[T](x)` , `x.p[:T](y)` 被重写为 `p[T](x, y)` . 注意 `[: ]` 没有AST表示, 直接在解析步骤中进行重写。
{==+==}

{==+==}
Properties
----------
{==+==}
属性
--------
{==+==}

{==+==}
Nim has no need for *get-properties*: Ordinary get-procedures that are called
with the *method call syntax* achieve the same. But setting a value is
different; for this, a special setter syntax is needed:
{==+==}
Nim不需要 *get-properties* : 使用 *方法调用语法* 调用的普通get-procedure达到相同目的。但set值是不同的; 因而需要一个特殊的setter语法: 
{==+==}

{==+==}
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
{==+==}
  ```nim
  #  asocket 模块
  type
    Socket* = ref object of RootObj
      host: int # cannot be accessed from the outside of the module

  proc `host=`*(s: var Socket, value: int) {.inline.} =
    ## hostAddr的setter.
    ## 它访问 'host' 字段并且不是对 `host =` 的递归调用, 如果内置的点访问方法可用, 则首选点访问:
    s.host = value

  proc host*(s: Socket): int {.inline.} =
    ##hostAddr的getter
    ## This accesses the 'host' field and is not a recursive call to
    ## 它访问 'host' 字段并且不是对 `host` 的递归调用, 如果内置的点访问方法可用, 则首选点访问:
    s.host
  ```
{==+==}

{==+==}
  ```nim
  # module B
  import asocket
  var s: Socket
  new s
  s.host = 34  # same as `host=`(s, 34)
  ```
{==+==}
  ```nim
  # 模块 B
  import asocket
  var s: Socket
  new s
  s.host = 34  # same as `host=`(s, 34)
  ```
{==+==}

{==+==}
A proc defined as `f=` (with the trailing `=`) is called
a `setter`:idx:. A setter can be called explicitly via the common
backticks notation:
{==+==}
定义为 `f=` 的proc(后面跟 `=` )被称为 `setter`:idx: 。
可以通过常见的反引号表示法显式调用setter: 
{==+==}


{==+==}
  ```nim
  proc `f=`(x: MyObject; value: string) =
    discard

  `f=`(myObject, "value")
  ```
{==+==}
  ```nim
  proc `f=`(x: MyObject; value: string) =
    discard

  `f=`(myObject, "value")
  ```
{==+==}


{==+==}
`f=` can be called implicitly in the pattern
`x.f = value` if and only if the type of `x` does not have a field
named `f` or if `f` is not visible in the current module. These rules
ensure that object fields and accessors can have the same name. Within the
module `x.f` is then always interpreted as field access and outside the
module it is interpreted as an accessor proc call.
{==+==}
 `f=` 可以在 `x.f = value` 模式中隐式调用，当且仅当 `x` 的类型没有名为 `f` 的字段或 `f` 在当前模块中不可见时。
 此规则确保对象字段和访问器可以有相同的名字。在模块内 `x.f` 总是被解释为字段访问，在模块外则被解释为访问器过程调用。
{==+==}

{==+==}
Command invocation syntax
-------------------------
{==+==}
命令调用语法
------------------------
{==+==}

{==+==}
Routines can be invoked without the `()` if the call is syntactically
a statement. This command invocation syntax also works for
expressions, but then only a single argument may follow. This restriction
means `echo f 1, f 2` is parsed as `echo(f(1), f(2))` and not as
`echo(f(1, f(2)))`. The method call syntax may be used to provide one
more argument in this case:
{==+==}
如果调用在语法上是一个语句，则可以在没有 `()` 的情况下调用例程。此命令调用语法也适用于表达式。但之后只能有一个参数。这种限制意味着 `echo f 1, f 2` 被解析为 `echo(f(1), f(2))` 而不是 `echo(f(1, f(2)))` 。
在这种情况下, 方法调用语法可以用来提供更多的参数。
{==+==}

{==+==}
  ```nim
  proc optarg(x: int, y: int = 0): int = x + y
  proc singlearg(x: int): int = 20*x

  echo optarg 1, " ", singlearg 2  # prints "1 40"

  let fail = optarg 1, optarg 8   # Wrong. Too many arguments for a command call
  let x = optarg(1, optarg 8)  # traditional procedure call with 2 arguments
  let y = 1.optarg optarg 8    # same thing as above, w/o the parenthesis
  assert x == y
  ```
{==+==}
  ```nim
  proc optarg(x: int, y: int = 0): int = x + y
  proc singlearg(x: int): int = 20*x

  echo optarg 1, " ", singlearg 2  # 打印 "1 40"

  let fail = optarg 1, optarg 8   # 错误。命令调用的参数太多
  let x = optarg(1, optarg 8)     # 传统过程调用2个参数
  let y = 1.optarg optarg 8       # 与上面相同, 没有括号
  assert x == y
  ```
{==+==}

{==+==}
The command invocation syntax also can't have complex expressions as arguments.
For example: (`anonymous procs <#procedures-anonymous-procs>`_), `if`,
`case` or `try`. Function calls with no arguments still need () to
distinguish between a call and the function itself as a first-class value.
{==+==}
命令调用语法也不能将复杂表达式作为参数。例如: ( `anonymous procs <#procedures-anonymous-procs>`_ "匿名过程"), `if` , `case` 或 `try` 。没有参数的函数调用仍需要()来区分调用和函数本身，作为首先的类型值。
{==+==}

{==+==}
Closures
--------
{==+==}
闭包
--------
{==+==}

{==+==}
Procedures can appear at the top level in a module as well as inside other
scopes, in which case they are called nested procs. A nested proc can access
local variables from its enclosing scope and if it does so it becomes a
closure. Any captured variables are stored in a hidden additional argument
to the closure (its environment) and they are accessed by reference by both
the closure and its enclosing scope (i.e. any modifications made to them are
visible in both places). The closure environment may be allocated on the heap
or on the stack if the compiler determines that this would be safe.
{==+==}
过程可以出现在模块的顶层，也可以出现在其他作用域中，在这种情况下，称为嵌套过程。
嵌套过程可以从其封闭的作用域访问局部变量，这就变成了一个闭包。
任何捕获的变量都存储在闭包(它的环境)隐藏附加参数中，并且通过闭包及其封闭作用域的引用来访问它们(即, 对它们进行的任意修改在两个地方都是可见的)。
如果编译器确定这是安全的，则会在堆或栈上分配闭包环境。
{==+==}

{==+==}
### Creating closures in loops
{==+==}
### 在循环中创建闭包
{==+==}

{==+==}
Since closures capture local variables by reference it is often not wanted
behavior inside loop bodies. See `closureScope
<system.html#closureScope.t,untyped>`_ and `capture
<sugar.html#capture.m,varargs[typed],untyped>`_ for details on how to change this behavior.
{==+==}
由于闭包通过引用捕获局部变量，所以在循环体中通常不需要这种行为。有关如何更改此行为的详细信息,
请参阅 `闭包作用域 <system.html#closureScope.t,untyped>`_ 和 `捕获 <sugar.html#capture.m,varargs[typed],untyped>`_ 。
{==+==}

{==+==}
Anonymous procedures
--------------------
{==+==}
匿名过程
----------------
{==+==}

{==+==}
Unnamed procedures can be used as lambda expressions to pass into other
procedures:
{==+==}
未命名过程可以用lambda表达式传递给其他过程:
{==+==}

{==+==}
  ```nim
  var cities = @["Frankfurt", "Tokyo", "New York", "Kyiv"]

  cities.sort(proc (x, y: string): int =
    cmp(x.len, y.len))
  ```
{==+==}
  ```nim
  var cities = @["Frankfurt", "Tokyo", "New York", "Kyiv"]

  cities.sort(proc (x, y: string): int =
    cmp(x.len, y.len))
  ```
{==+==}

{==+==}
Procs as expressions can appear both as nested procs and inside top-level
executable code. The  `sugar <sugar.html>`_ module contains the `=>` macro
which enables a more succinct syntax for anonymous procedures resembling
lambdas as they are in languages like JavaScript, C#, etc.
{==+==}
作为表达式的过程既可以作为嵌套过程出现，也可以出现在顶层可执行代码中。 `sugar <sugar.html>`_ 模块包含 `=>` 宏，该宏为类似lambdas的匿名过程提供了更简洁的语法，就像JavaScript、c#等语言中那样。
{==+==}

{==+==}
Do notation
-----------
{==+==}
Do 标记
--------------
{==+==}

{==+==}
As a special convenience notation that keeps most elements of a
regular proc expression, the `do` keyword can be used to pass
anonymous procedures to routines:
{==+==}
作为一种特殊的简洁表示法， `do` 关键字可以用来将匿名过程传递给过程:
{==+==}

{==+==}
  ```nim
  var cities = @["Frankfurt", "Tokyo", "New York", "Kyiv"]

  sort(cities) do (x, y: string) -> int:
    cmp(x.len, y.len)

  # Less parentheses using the method plus command syntax:
  cities = cities.map do (x: string) -> string:
    "City of " & x
  ```
{==+==}
  ```nim
  var cities = @["Frankfurt", "Tokyo", "New York", "Kyiv"]

  sort(cities) do (x, y: string) -> int:
    cmp(x.len, y.len)

  # 使用方法加命令语法减少括号:
  cities = cities.map do (x: string) -> string:
    "City of " & x
  ```
{==+==}

{==+==}
`do` is written after the parentheses enclosing the regular proc params.
The proc expression represented by the `do` block is appended to the routine
call as the last argument. In calls using the command syntax, the `do` block
will bind to the immediately preceding expression rather than the command call.
{==+==}
`do` 写在包含常规过程参数的括号之后。由 `do` 块表示的过程表达式作为最后一个参数附加给例程调用。
在使用命令语法的调用中, `do` 块将绑定到紧接的前面表达式，而不是命令调用。
{==+==}

{==+==}
`do` with a parameter list or pragma list corresponds to an anonymous `proc`,
however `do` without parameters or pragmas is treated as a normal statement
list. This allows macros to receive both indented statement lists as an
argument in inline calls, as well as a direct mirror of Nim's routine syntax.
{==+==}
带参数列表或编译指示列表的 `do` 对应于匿名的 `proc` ,但是不带参数或编译指示中的 `do` 被视为常规语句列表。
这允许宏接收缩进语句列表作为内联调用的参数，以及Nim例程语法的直接镜像。
{==+==}

{==+==}
  ```nim
  # Passing a statement list to an inline macro:
  macroResults.add quote do:
    if not `ex`:
      echo `info`, ": Check failed: ", `expString`
  
  # Processing a routine definition in a macro:
  rpc(router, "add") do (a, b: int) -> int:
    result = a + b
  ```
{==+==}
  ```nim
  # 将语句列表传递给内联宏:
  macroResults.add quote do:
    if not `ex`:
      echo `info`, ": Check failed: ", `expString`
  
  # 在宏中处理例程定义:
  rpc(router, "add") do (a, b: int) -> int:
    result = a + b
  ```
{==+==}

{==+==}
Func
----
{==+==}
函数
--------
{==+==}

{==+==}
The `func` keyword introduces a shortcut for a `noSideEffect`:idx: proc.
{==+==}
 `func` 关键字是引入 `noSideEffect` 过程的快捷方式。
{==+==}

{==+==}
  ```nim
  func binarySearch[T](a: openArray[T]; elem: T): int
  ```
{==+==}
  ```nim
  func binarySearch[T](a: openArray[T]; elem: T): int
  ```
{==+==}

{==+==}
Is short for:
{==+==}
是它的简写:
{==+==}

{==+==}
  ```nim
  proc binarySearch[T](a: openArray[T]; elem: T): int {.noSideEffect.}
  ```
{==+==}
  ```nim
  proc binarySearch[T](a: openArray[T]; elem: T): int {.noSideEffect.}
  ```
{==+==}

{==+==}
Routines
--------
{==+==}
例程
--------
{==+==}

{==+==}
A routine is a symbol of kind: `proc`, `func`, `method`, `iterator`, `macro`, `template`, `converter`.
{==+==}
例程是一类标识符: `proc`, `func`, `method`, `iterator`, `macro`, `template`, `converter` 。
{==+==}

{==+==}
Type bound operators
--------------------
{==+==}
类型绑定操作符
----------------------------
{==+==}

{==+==}
A type bound operator is a `proc` or `func` whose name starts with `=` but isn't an operator
(i.e. containing only symbols, such as `==`). These are unrelated to setters
(see `properties <manual.html#procedures-properties>`_), which instead end in `=`.
A type bound operator declared for a type applies to the type regardless of whether
the operator is in scope (including if it is private).
{==+==}
类型绑定操作符是名称以 `=` 开始的 `proc` 或 `func` ， 但不是操作符(即只包含符号，如 `==` )。
这些与 `=` 结尾的setter无关(参见 `properties <manual.html#procedures-properties>`_ )。
为类型声明的类型绑定操作符将应用于该类型，无论操作符是否在作用域中(包括是否私有)。
{==+==}

{==+==}
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
{==+==}
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
  # 在退出作用域时仍然会被调用
  doAssert witness == 3
  ```
{==+==}

{==+==}
Type bound operators are:
`=destroy`, `=copy`, `=sink`, `=trace`, `=deepcopy`.
{==+==}
类型绑定操作符: `=destroy `, `=copy` , `=sink` , `=trace` , `=deepcopy` 。
{==+==}

{==+==}
These operations can be *overridden* instead of *overloaded*. This means that
the implementation is automatically lifted to structured types. For instance,
if the type `T` has an overridden assignment operator `=`, this operator is
also used for assignments of the type `seq[T]`.
{==+==}
这些操作被 *overridden* "重写", 而不是 *overloaded* "重载"。这意味着实现会自动提升为结构化类型。
例如，如果类型 `T` 有一个重写的赋值运算符 `=` ,这个操作符也可用于类型 `seq[T]` 的赋值。
{==+==}

{==+==}
Since these operations are bound to a type, they have to be bound to a
nominal type for reasons of simplicity of implementation; this means an
overridden `deepCopy` for `ref T` is really bound to `T` and not to `ref T`.
This also means that one cannot override `deepCopy` for both `ptr T` and
`ref T` at the same time, instead a distinct or object helper type has to be
used for one pointer type.
{==+==}
由于这些操作被绑定到一个类型，为了实现的简单性，它们必须绑定到一个名义上的类型; 这意味着一个被重写的 `deepCopy` 的 `ref T` 是真正绑定到 `T` 而不是 `ref T` 。
这也意味着，不能同时重写 `deepCopy` 的 `ptr T` 和 `ref T` ，相反，必须为一种指针类型使用distinct或object辅助类型。
{==+==}

{==+==}
For more details on some of those procs, see
`Lifetime-tracking hooks <destructors.html#lifetimeminustracking-hooks>`_.
{==+==}
有关这些过程的更多细节, 请参阅 `生命周期追踪钩子 <destructors.html#lifetimeminustracking-hooks>`_ 。
{==+==}

{==+==}
Nonoverloadable builtins
------------------------
{==+==}
Nonoverloadable 内置命令
------------------------------------------------
{==+==}

{==+==}
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
{==+==}
出于实现简单性的原因, 以下内置procs不能重载(它们需要专门的语义检查)::

  declared, defined, definedInScope, compiles, sizeof,
  is, shallowCopy, getAst, astToStr, spawn, procCall

因此，它们更像是关键字，而不是普通的标识符。然而，与关键字不同的是，重定义可能会 `shadow`:idx: system_ 模块中的定义。
从这个列表中，以下内容不应该用句点法表示 `x` 。因为 `x` 在传递给 `F` 之前不能进行类型检查::

  declared, defined, definedInScope, compiles, getAst, astToStr
{==+==}


{==+==}
Var parameters
--------------
{==+==}
Var 参数
----------------
{==+==}

{==+==}
The type of a parameter may be prefixed with the `var` keyword:
{==+==}
参数的类型可以使用 var 关键字作为前缀:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
In the example, `res` and `remainder` are `var parameters`.
Var parameters can be modified by the procedure and the changes are
visible to the caller. The argument passed to a var parameter has to be
an l-value. Var parameters are implemented as hidden pointers. The
above example is equivalent to:
{==+==}
在示例中, `res` 和 `remainder` 是 `var parameters` 。可以通过过程修改Var形参，且调用者可以拿到更改。
传递给var形参的实参必须是左值。Var形参的实现为隐藏指针。上面的例子相当于:
{==+==}

{==+==}
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
{==+==}
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
{==+==}

{==+==}
In the examples, var parameters or pointers are used to provide two
return values. This can be done in a cleaner way by returning a tuple:
{==+==}
在示例中，var形参或指针用来提供两个返回值。这可以通过返回一个元组这种更简洁的方式来完成:
{==+==}

{==+==}
  ```nim
  proc divmod(a, b: int): tuple[res, remainder: int] =
    (a div b, a mod b)

  var t = divmod(8, 5)

  assert t.res == 1
  assert t.remainder == 3
  ```
{==+==}
  ```nim
  proc divmod(a, b: int): tuple[res, remainder: int] =
    (a div b, a mod b)

  var t = divmod(8, 5)

  assert t.res == 1
  assert t.remainder == 3
  ```
{==+==}

{==+==}
One can use `tuple unpacking`:idx: to access the tuple's fields:
{==+==}
可以使用 `tuple unpacking` 来访问元组的字段:
{==+==}

{==+==}
  ```nim
  var (x, y) = divmod(8, 5) # tuple unpacking
  assert x == 1
  assert y == 3
  ```
{==+==}
  ```nim
  var (x, y) = divmod(8, 5) # tuple unpacking
  assert x == 1
  assert y == 3
  ```
{==+==}

{==+==}
**Note**: `var` parameters are never necessary for efficient parameter
passing. Since non-var parameters cannot be modified the compiler is always
free to pass arguments by reference if it considers it can speed up execution.
{==+==}
**注意**: 对于高效的参数传递来说， `var` 形参不是必需的。
因为非var形参不能修改，所以编译器在认为可以加快执行速度的情况下，会更自由地通过引用传递参数。
{==+==}
