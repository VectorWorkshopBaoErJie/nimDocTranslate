
{==+==}
  ord(north) == 0
  ord(east) == 1
  ord(south) == 2
  ord(west) == 3

  # Also allowed:
  ord(Direction.west) == 3
{==+==}
  ```nim
  ord(north) == 0
  ord(east) == 1
  ord(south) == 2
  ord(west) == 3

  # 也允许:
  ord(Direction.west) == 3
  ```
{==+==}

{==+==}
The `borrow` pragma makes the compiler use the same implementation as
the proc that deals with the distinct type's base type, so no code is
generated.
{==+==}
`borrow` 编译指示会让编译器使用，与处理distinct类型的基类型过程相同的实现，因此不会生成任何代码。
{==+==}

{==+==}
Assignment compatibility
------------------------

An expression `b` can be assigned to an expression `a` iff `a` is an
`l-value` and `isImplicitlyConvertible(b.typ, a.typ)` holds.
{==+==}
赋值兼容
----------------

一个表达式 `b` 可以被赋值给一个表达式 `a` 如果 `a` 是一个 `l-value` 并且保持 `isImplicitlyConvertible(b.typ, a.typ)` 。
{==+==}