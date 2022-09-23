.. default-role:: code
.. include:: ../rstcommon.rst

通过 `var T` 返回的内存安全,由简单的借用规则来保证:
如果 `result` 不指向指向堆的地址(即在 `result = X` 中， `X` 关系到 `ptr` 或 `ref` 访问)，那么它必须来自例程的第一个参数。

  ```nim
  proc forward[T](x: var T): var T =
    result = x # 可以, 来自第一个参数。

  proc p(param: var int): var int =
    var x: int
    # 我们知道 'forward' 提供了一个从其第一个参数 'x' 得出的地址的视图
    result = forward(x) # 错误: 地址来自 `x` ，
                        # 其不是p的第一个参数，
                        # 并且存活在栈上。
  ```

换句话说， `result` 所指向的生命周期与第一个参数的生命周期相关联，这就足以验证调用位置的内存安全。
