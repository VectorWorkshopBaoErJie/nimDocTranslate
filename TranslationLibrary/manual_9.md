{==+==}
Dynlib pragma for export
------------------------
{==+==}
用于导出的 Dynlib 编译标记
------------------------------------------------
{==+==}

{==+==}
With the `dynlib` pragma, a procedure can also be exported to
a dynamic library. The pragma then has no argument and has to be used in
conjunction with the `exportc` pragma:
{==+==}
一个使用了 `dynlib` 编译标记的过程，也能被导出为一个动态库。
这样的话，那它不需要参数，但必须结合 `exportc` 标记来使用。
{==+==}

{-----}
  ```Nim
  proc exportme(): int {.cdecl, exportc, dynlib.}
  ```
{-----}

{==+==}
This is only useful if the program is compiled as a dynamic library via the
`--app:lib`:option: command-line option.
{==+==}
这个标记只在通过 `--app:lib`:option: 命令行参数，将程序编译为动态库时有用。
{==+==}



{==+==}
Threads
=======
{==+==}
线程
========
{==+==}

{==+==}
To enable thread support the `--threads:on`:option: command-line switch needs to
be used. The system_ module then contains several threading primitives.
See the `channels <channels_builtin.html>`_ modules
for the low-level thread API. There are also high-level parallelism constructs
available. See `spawn <manual_experimental.html#parallel-amp-spawn>`_ for
further details.
{==+==}
开启线程支持，需要启用 `--threads:on`:option: 。
系统_ 模块包含了一系列的线程基元。
要启用线程支持，需要使用 `--threads:on`:option: 命令行开关。system_模块包含几个线程基元。
关于底层的线程API，请参阅 `channels <channels_builtin.html>`_ 模块。也有一些高级可用的并行结构，详情参阅 `spawn <manual_experimental.html#parallel-amp-spawn>`_ 。
{==+==}

{==+==}
Nim's memory model for threads is quite different than that of other common
programming languages (C, Pascal, Java): Each thread has its own (garbage
collected) heap, and sharing of memory is restricted to global variables. This
helps to prevent race conditions. GC efficiency is improved quite a lot,
because the GC never has to stop other threads and see what they reference.
{==+==}
相较于其他的通用编程语言(C, Pascal, Java)，Nim 中线程的内存模型是相当与众不同的：
每个线程都有它自己的(垃圾回收)堆，内存共享也仅限于全局变量。这样有助于防止竞态条件。
因为 GC 永远不必停止其他线程，并查看它们到底引用了什么。故而 GC 的效率也得以被大大提升。
{==+==}

{==+==}
The only way to create a thread is via `spawn` or
`createThread`. The invoked proc must not use `var` parameters nor must
any of its parameters contain a `ref` or `closure` type. This enforces
the *no heap sharing restriction*.
{==+==}
只有通过 `spawn` 或者 `createThread` 才能创建一个线程。被调用的过程不得使用 `var` 声明参数，参数类型也不得包含 `ref` 或 `closure` 。
{==+==}

{==+==}
Thread pragma
-------------
{==+==}
Thread 编译指示
-------------------------------
{==+==}

{==+==}
A proc that is executed as a new thread of execution should be marked by the
`thread` pragma for reasons of readability. The compiler checks for
violations of the `no heap sharing restriction`:idx:\: This restriction implies
that it is invalid to construct a data structure that consists of memory
allocated from different (thread-local) heaps.
{==+==}
出于可读性的考虑，作为新线程执行的程序应该用 `thread` 编译标记进行标记。
编译器会检查是否违反了 `no heap sharing restriction`:idx:\: 
这个限制意味着，无法构造由不同(线程本地)堆分配的内存组成的数据结构。
{==+==}

{==+==}
A thread proc is passed to `createThread` or `spawn` and invoked
indirectly; so the `thread` pragma implies `procvar`.
{==+==}
一个线程过程被传递给 `createThread` 或 `spawn` ，并被间接调用；
因此，`thread` 编译标记等价于 `procvar`。
{==+==}



{==+==}
Threadvar pragma
----------------
{==+==}
Threadvar 编译指示
--------------------------------
{==+==}

{==+==}
A variable can be marked with the `threadvar` pragma, which makes it a
`thread-local`:idx: variable; Additionally, this implies all the effects
of the `global` pragma.
{==+==}
变量可以用 `threadvar` 编译标记来标记，这会使它成为 `线程本地`:idx: 变量；
此外，这意味着 `global` 编译标记的所有效果。
{==+==}

{-----}
  ```nim
  var checkpoints* {.threadvar.}: seq[string]
  ```
{-----}

{==+==}
Due to implementation restrictions, thread-local variables cannot be
initialized within the `var` section. (Every thread-local variable needs to
be replicated at thread creation.)
{==+==}
由于实现的限制，本地线程变量不能在 `var` 块中初始化。(每个线程本地变量都需要在线程创建时复制。)
{==+==}


{==+==}
Threads and exceptions
----------------------
{==+==}
线程和异常
----------------------
{==+==}

{==+==}
The interaction between threads and exceptions is simple: A *handled* exception
in one thread cannot affect any other thread. However, an *unhandled* exception
in one thread terminates the whole *process*.
{==+==}
线程和异常之间的交互很简单:
一个线程中， *被捕获* 了的异常，无法影响其他的线程。
然而，某个线程中 *未捕获* 的异常，会终止整个 *进程* 。
{==+==}


{==+==}
Guards and locks
================
{==+==}
守卫和锁
================
{==+==}

{==+==}
Nim provides common low level concurrency mechanisms like locks, atomic
intrinsics or condition variables.
{==+==}
Nim 提供了诸如锁、原子性内部函数和条件变量这样的常见底层并发机制。
{==+==}

{==+==}
Nim significantly improves on the safety of these features via additional
pragmas:
{==+==}
Nim 通过附带编译指示，显著地提高了这些功能的安全性:
{==+==}

{==+==}
1) A `guard`:idx: annotation is introduced to prevent data races.
2) Every access of a guarded memory location needs to happen in an
   appropriate `locks`:idx: statement.
{==+==}
1) 引入 `guard`:idx: 注释，以防止数据竞争；
2) 每次访问受保护的内存位置，都需要在适当的 `locks`:idx: 语句中进行。
{==+==}


{==+==}
Guards and locks sections
-------------------------
{==+==}
守卫和锁块
-------------------------
{==+==}

{==+==}
### Protecting global variables
{==+==}
### 受保护的全局变量
{==+==}

{==+==}
Object fields and global variables can be annotated via a `guard` pragma:
{==+==}
对象字段和全局变量都可以使用 `guard` 编译指令进行标注:
{==+==}

{-----}
  ```nim
  import std/locks

  var glock: Lock
  var gdata {.guard: glock.}: int
  ```
{-----}


{==+==}
The compiler then ensures that every access of `gdata` is within a `locks`
section:
{==+==}
然后，编译器会确保每次访问 `gdata` 都在 `locks` 块中:
{==+==}

{-----}
  ```nim
  proc invalid =
    # invalid: unguarded access:
    echo gdata

  proc valid =
    # valid access:
    {.locks: [glock].}:
      echo gdata
  ```
{-----}

{==+==}
Top level accesses to `gdata` are always allowed so that it can be initialized
conveniently. It is *assumed* (but not enforced) that every top level statement
is executed before any concurrent action happens.
{==+==}
为了能够方便地初始化，始终允许了对 `gdata` 的顶级访问。
这样 *假设* (但不强制)的前提是，所有顶级语句都执行在未发生并发操作之前。
{==+==}

{==+==}
The `locks` section deliberately looks ugly because it has no runtime
semantics and should not be used directly! It should only be used in templates
that also implement some form of locking at runtime:
{==+==}
我们故意让 `locks` 块看起来很丑，因为它没有运行时的语意，不应该被直接使用！
它应该只在运行时中，同时能够实现某种形式的锁定的模板里使用:
{==+==}

{-----}
  ```nim
  template lock(a: Lock; body: untyped) =
    pthread_mutex_lock(a)
    {.locks: [a].}:
      try:
        body
      finally:
        pthread_mutex_unlock(a)
  ```
{-----}


{==+==}
The guard does not need to be of any particular type. It is flexible enough to
model low level lockfree mechanisms:
{==+==}
守卫不需要属于任何特定类型。它足够灵活到可以对低级无锁机制进行建模:
{==+==}

{-----}
  ```nim
  var dummyLock {.compileTime.}: int
  var atomicCounter {.guard: dummyLock.}: int

  template atomicRead(x): untyped =
    {.locks: [dummyLock].}:
      memoryReadBarrier()
      x

  echo atomicRead(atomicCounter)
  ```
{-----}


{==+==}
The `locks` pragma takes a list of lock expressions `locks: [a, b, ...]`
in order to support *multi lock* statements. Why these are essential is
explained in the `lock levels <#guards-and-locks-lock-levels>`_ section.
{==+==}
为了支持 *多锁* 语句，`locks` 编译指令采用了锁表达式 `locks: [a, b, ...]` 。
在 `lock levels <#guards-and-locks-lock-levels>`_ 章节中对这样做的原因进行了解释。
{==+==}


{==+==}
### Protecting general locations
{==+==}
### 保护一般位置
{==+==}

{==+==}
The `guard` annotation can also be used to protect fields within an object.
The guard then needs to be another field within the same object or a
global variable.
{==+==}
`guard` 标注也可以用于保护对象中的字段。然后，需要用同一个对象或者全局变量中的另一个字段作为守卫。
{==+==}

{==+==}
Since objects can reside on the heap or on the stack, this greatly enhances
the expressiveness of the language:
{==+==}
由于对象可以驻留在堆上或堆栈上，这么做大大地增强了语言的表现力:
{==+==}

{-----}
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
{-----}


{==+==}
The access to field `x.v` is allowed since its guard `x.L`  is active.
After template expansion, this amounts to:
{==+==}
允许访问字段 `x.v` ，因为它守卫的 `x.L` 处于活动状态。当模板扩展后，就相当于:
{==+==}

{-----}
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
{-----}


{==+==}
There is an analysis that checks that `counters[i].L` is the lock that
corresponds to the protected location `counters[i].v`. This analysis is called
`path analysis`:idx: because it deals with paths to locations
like `obj.field[i].fieldB[j]`.
{==+==}
有一个分析器，可以检查 `counters[i].L` 是否是对应受保护位置 `counters[i].v` 的锁。
因为这个分析器能够处理像 `obj.field[i].fieldB[j]` 这样的位置的路径，所以我们叫它 `path analysis`:idx: 。
{==+==}

{==+==}
The path analysis is **currently unsound**, but that doesn't make it useless.
Two paths are considered equivalent if they are syntactically the same.
{==+==}
路径分析器 **目前不健全** ，但它不是不能用。如果两条路径在语法上相同，则会被认为相互等效。
{==+==}

{==+==}
This means the following compiles (for now) even though it really should not:
{==+==}
(目前来说)这意味着如下的编译，哪怕实在不应该这么做:
{==+==}

{-----}
  ```nim
  {.locks: [a[i].L].}:
    inc i
    access a[i].v
  ```
{-----}

