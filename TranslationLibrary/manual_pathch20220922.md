{====}
**Note**: The experimental features of Nim are
covered [here](manual_experimental.html).
{====}

{====} 

{====}
**Note**: Assignments, moves, and destruction are specified in
the [destructors](destructors.html) document.
{====}

{====}

{====}
To learn how to compile Nim programs and generate documentation see
the [Compiler User Guide](nimc.html) and the [DocGen Tools Guide](docgen.html).
{====}

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

{====}

{====}
A `panic`:idx: is an error that the implementation detects
and reports at runtime. The method for reporting such errors is via
*raising exceptions* or *dying with a fatal error*. However, the implementation
provides a means to disable these `runtime checks`:idx:. See the section
[Pragmas] for details.
{====}

{====}

{====}
The `Rune` type can represent any Unicode character.
`Rune` is declared in the [unicode module](unicode.html).
{====}

{====}

{====}
See also [custom numeric literals].
{====}

{====}

{====}
This section lists Nim's standard syntax. How the parser handles
the indentation is already described in the [Lexical Analysis] section.
{====}

{====}

{====}
  ```nim
  echo(1, 2) # pass 1 and 2 to echo
  ```

  ```nim
  echo (1, 2) # pass the tuple (1, 2) to echo
  ```
{====}



{====}
`int`
: the generic signed integer type; its size is platform-dependent and has the
  same size as a pointer. This type should be used in general. An integer
  literal that has no type suffix is of this type if it is in the range
  `low(int32)..high(int32)` otherwise the literal's type is `int64`.
{====}

{====}

{====}
`int`\ XX
: additional signed integer types of XX bits use this naming scheme
  (example: int16 is a 16-bit wide integer).
  The current implementation supports `int8`, `int16`, `int32`, `int64`.
  Literals of these types have the suffix 'iXX.
{====}

{====}

{====}
`uint`
: the generic `unsigned integer`:idx: type; its size is platform-dependent and
  has the same size as a pointer. An integer literal with the type
  suffix `'u` is of this type.
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

{====}

{====}
For further details, see [Convertible relation].
{====}

{====}
`float`
: the generic floating-point type; its size used to be platform-dependent,
  but now it is always mapped to `float64`.
  This type should be used in general.
{====}

{====}

{====}
`float`\ XX
: an implementation may define additional floating-point types of XX bits using
  this naming scheme (example: `float64` is a 64-bit wide float). The current
  implementation supports `float32` and `float64`. Literals of these types
  have the suffix 'fXX.
{====}

{====}
Automatic type conversion in expressions with different kinds of floating-point
types is performed: See [Convertible relation] for further details. Arithmetic
performed on floating-point types follows the IEEE standard. Integer types are
not converted to floating-point types automatically and vice versa.
{====}

{====}

{====}
The `Rune` type is used for Unicode characters, it can represent any Unicode
character. `Rune` is declared in the [unicode module](unicode.html).
{====}

{====}

{====}
Enum value names are overloadable, much like routines. If both of the enums
`T` and `U` have a member named `foo`, then the identifier `foo` corresponds
to a choice between `T.foo` and `U.foo`. During overload resolution,
the correct type of `foo` is decided from the context. If the type of `foo` is
ambiguous, a static error will be produced.
{====}

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

{====}
To implement bit fields with enums see [Bit fields].
{====}

{====}

{====}
Per convention, all strings are UTF-8 strings, but this is not enforced. For
example, when reading strings from binary files, they are merely a sequence of
bytes. The index operation `s[i]` means the i-th *char* of `s`, not the
i-th *unichar*. The iterator `runes` from the [unicode module](unicode.html)
can be used for iteration over all Unicode characters.
{====}

{====}

{====}
`cstring` values may also be used in case statements like strings.
{====}

{====}


{====}
The assignment operator for tuples and objects copies each component.
The methods to override this copying behavior are described [here][type
bound operators].
{====}

{====}

{====}
Automatic dereferencing can be performed for the first argument of a routine
call, but this is an experimental feature and is described [here](
manual_experimental.html#automatic-dereferencing).
{====}

{====}

{====}
To allocate a new traced object, the built-in procedure `new` has to be used.
To deal with untraced memory, the procedures `alloc`, `dealloc` and
`realloc` can be used. The documentation of the [system](system.html) module
contains further information.
{====}

{====}


{====}
`nimcall`:idx:
:   is the default convention used for a Nim **proc**. It is the
    same as `fastcall`, but only for C compilers that support `fastcall`.
{====}

{====}

{====}
`closure`:idx:
:   is the default calling convention for a **procedural type** that lacks
    any pragma annotations. It indicates that the procedure has a hidden
    implicit parameter (an *environment*). Proc vars that have the calling
    convention `closure` take up two machine words: One for the proc pointer
    and another one for the pointer to implicitly passed environment.
{====}

{====}

{====}
`stdcall`:idx:
:   This is the stdcall convention as specified by Microsoft. The generated C
    procedure is declared with the `__stdcall` keyword.
{====}

{====}

{====}
`cdecl`:idx:
:   The cdecl convention means that a procedure shall use the same convention
    as the C compiler. Under Windows the generated C procedure is declared with
    the `__cdecl` keyword.
{====}

{====}

{====}
`safecall`:idx:
:   This is the safecall convention as specified by Microsoft. The generated C
    procedure is declared with the `__safecall` keyword. The word *safe*
    refers to the fact that all hardware registers shall be pushed to the
    hardware stack.
{====}

{====}

{====}
`inline`:idx:
:   The inline convention means the caller should not call the procedure,
    but inline its code directly. Note that Nim does not inline, but leaves
    this to the C compiler; it generates `__inline` procedures. This is
    only a hint for the compiler: it may completely ignore it, and
    it may inline procedures that are not marked as `inline`.
{====}

{====}

{====}
`fastcall`:idx:
:   Fastcall means different things to different C compilers. One gets whatever
    the C `__fastcall` means.
{====}

{====}

{====}
`thiscall`:idx:
:   This is the thiscall calling convention as specified by Microsoft, used on
    C++ class member functions on the x86 architecture.
{====}

{====}

{====}
`syscall`:idx:
:   The syscall convention is the same as `__syscall`:c: in C. It is used for
    interrupts.
{====}

{====}

{====}
`noconv`:idx:
:   The generated C code will not have any explicit calling convention and thus
    use the C compiler's default calling convention. This is needed because
    Nim's default calling convention for procedures is `fastcall` to
    improve speed.
{====}

{====}

{====}
But it seems all this boilerplate code needs to be repeated for the `Euro`
currency. This can be solved with [templates].
{====}

{====}

{====}
Now we have compile-time checking against SQL injection attacks. Since
`"".SQL` is transformed to `SQL("")` no new syntax is needed for nice
looking `SQL` string literals. The hypothetical `SQL` type actually
exists in the library as the [SqlQuery type](db_common.html#SqlQuery) of
modules like [db_sqlite](db_sqlite.html).
{====}

{====}

{====}
**Note**: One of the above pointer-indirections is required for assignment from
a subtype to its parent type to prevent "object slicing".
{====}

{====}

{====}
See [Varargs].
{====}

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

{====}

{====}
See [Constants and Constant Expressions] for details.
{====}

{====}

{====}
There are limitations on what Nim code can be executed at compile time;
see [Restrictions on Compile-Time Execution] for details.
It's a static error if the compiler cannot execute the block at compile
time.
{====}

{====}

{====}
Only ordinal types, floats, strings and cstrings are allowed as values
in case statements.
{====}

{====}

{====}
The `yield` statement is used instead of the `return` statement in
iterators. It is only valid in iterators. Execution is returned to the body
of the for loop that called the iterator. Yield does not end the iteration
process, but the execution is passed back to the iterator if the next iteration
starts. See the section about iterators ([Iterators and the for statement])
for further information.
{====}

{====}

{====}
[Limitations of the method call syntax].
{====}

{====}

{====}
The command invocation syntax also can't have complex expressions as arguments.
For example: [anonymous procedures], `if`,
`case` or `try`. Function calls with no arguments still need () to
distinguish between a call and the function itself as a first-class value.
{====}

{====}

{====}
Since closures capture local variables by reference it is often not wanted
behavior inside loop bodies. See [closureScope](
system.html#closureScope.t,untyped) and [capture](
sugar.html#capture.m,varargs[typed],untyped) for details on how to change this behavior.
{====}

{====}

{====}
Procs as expressions can appear both as nested procs and inside top-level
executable code. The  [sugar](sugar.html) module contains the `=>` macro
which enables a more succinct syntax for anonymous procedures resembling
lambdas as they are in languages like JavaScript, C#, etc.
{====}

{====}

{====}
`do` is written after the parentheses enclosing the regular proc parameters.
The proc expression represented by the `do` block is appended to the routine
call as the last argument. In calls using the command syntax, the `do` block
will bind to the immediately preceding expression rather than the command call.
{====}

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

{====}

{====}
A type bound operator is a `proc` or `func` whose name starts with `=` but isn't an operator
(i.e. containing only symbols, such as `==`). These are unrelated to setters
(see [Properties]), which instead end in `=`.
A type bound operator declared for a type applies to the type regardless of whether
the operator is in scope (including if it is private).
{====}

{====}

{====}
For more details on some of those procs, see
[Lifetime-tracking hooks](destructors.html#lifetimeminustracking-hooks).
{====}

{====}

{====}
The following built-in procs cannot be overloaded for reasons of implementation
simplicity (they require specialized semantic checking)::

  declared, defined, definedInScope, compiles, sizeof,
  is, shallowCopy, getAst, astToStr, spawn, procCall
{====}

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

{====}

{====}
See also [iterable] for passing iterators to templates and macros.
{====}

{====}

{====}
A converter is like an ordinary proc except that it enhances
the "implicitly convertible" type relation (see [Convertible relation]):
{====}

{====}

{====}
Any statements following the `defer` will be considered
to be in an implicit try block in the current block:
{====}

{====}

{====}
The exception tree is defined in the [system](system.html) module.
Every exception inherits from `system.Exception`. Exceptions that indicate
programming bugs inherit from `system.Defect` (which is a subtype of `Exception`)
and are strictly speaking not catchable as they can also be mapped to an operation
that terminates the whole process. If panics are turned into exceptions, these
exceptions inherit from `Defect`.
{====}

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

{====}

{====}
`ProcType2` is a subtype of `ProcType1`. Unlike with the `tags` pragma, the parent context - the
function which calls other functions with forbidden effects - doesn't inherit the forbidden list of effects.
{====}

{====}

{====}
As a special semantic rule, the built-in [debugEcho](
system.html#debugEcho,varargs[typed,]) pretends to be free of side effects
so that it can be used for debugging routines marked as `noSideEffect`.
{====}

{====}

{====}
- [Shared heap memory management](mm.html).
{====}

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