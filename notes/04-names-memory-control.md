# 04 — Names, Memory Management, Control Abstraction

> **Primary:** none — **there is no slide deck for lessons 05–06.**
> **Textbook only:** `DOCS/05-GM-ch4.pdf` (Gabbrielli–Martini ch.4, *Names and The Environment*) · `DOCS/06-GM-ch5.pdf` (ch.5, *Memory Management*) · `DOCS/05-GM-ch7.pdf` (ch.7, *Control Abstraction*)
> **Cited as:** `[GM4 …]`, `[GM5 …]`, `[GM7 …]`

> **Scope of this chapter.** Lessons 05 and 06 have no deck — see the gap register
> in [`SOURCES.md`](../SOURCES.md). This is therefore a **brief background
> chapter** covering the definitions from the assigned textbook chapters that the
> rest of the notes rely on, rather than a full treatment of 84 textbook pages. The
> topics recur with primary-source coverage elsewhere: scope rules in
> [ch.13 §13.3](13-python-decorators-oop.md#133-namespaces-and-scopes), the stack
> and heap in [ch.05 §5.4](05-rust-ownership-borrowing.md#54-memory-management-and-raii),
> garbage collection in [ch.06](06-python-runtime-gil.md), higher-order functions
> in [ch.11](11-java-lambdas-streams.md) and
> [ch.13 §13.1](13-python-decorators-oop.md#functions-are-objects).

---

## 4.1 Names and the environment

A **name** is a sequence of characters used to represent something else, and names
are what let a language abstract away from the physical machine — a name may denote
a memory location (abstraction of data) or a set of commands (abstraction of
control) [GM4 intro].

> **Definition 4.1 (Environment).** The set of associations between **names** and
> **denotable objects** which exist at runtime at a specific **point in the
> program** and at a specific **time during execution**, is called the
> **(referencing) environment**. [GM4 Def. 4.1]

Both qualifications matter. The environment depends on *where* you are in the
program text and on *when* during execution — which is why §4.2's two scope
disciplines differ, one resolving the first coordinate and one the second.

> The environment is that component of the **abstract machine** which, for every
> name introduced by the programmer and at every point in the program, allows the
> determination of what the correct association is. Note that **the environment
> does not exist at the level of the physical machine.** [GM4 §4.1]

This connects to [ch.01 §1.2](01-foundations-abstract-machines.md#12-abstract-machines):
the environment is one of the data structures Definition 1.1 speaks of, present in
the abstract machine for a high-level language and absent from the hardware, so it
must be *simulated* by the implementation. §4.3 is how.

> **Definition 4.2 (Block).** A **block** is a **textual region** of the program,
> identified by a start sign and an end sign, which can contain **declarations
> local** to that region (that is, which appear within the region). [GM4 Def. 4.2]

The start- and end-block constructs vary by language — `{ }` in C and Java,
`begin`/`end` in Pascal, indentation in Python.

> **Definition 4.3 (Type of environment).** The environment associated with a block
> is formed of the following components [GM4 Def. 4.3]:
>
> - **Local environment** — the set of associations for names **declared locally**
>   to the block. In the case of a procedure block, the local environment also
>   contains the associations for the **formal parameters**, since as far as the
>   environment is concerned they can be seen as locally declared variables.
> - **Non-local environment** — the associations for names which are **visible from
>   inside** a block but which have **not been declared locally**.
> - **Global environment** — the associations created when the program's execution
>   began.
>
> The **global environment is part of the non-local environment.** [GM4 §4.2.2]

The three-way split is the textbook counterpart of Python's LEGB rule
([ch.13 §13.3](13-python-decorators-oop.md#133-namespaces-and-scopes)): *local* is
L, *non-local* covers E, and *global* is G.

### Entering and leaving a block

On leaving a block the environment is modified as follows [GM4 §4.2.3]:

1. The associations for names **declared locally** to the block, and the objects
   they denote, are **destroyed**.
2. The associations are **reactivated** between names that existed external to the
   block and which were **redefined** inside it.

Step 2 is what makes shadowing work: an inner declaration does not overwrite the
outer association but *deactivates* it for the duration of the block. Compare
Java's rule that a lambda body opens **no** new block for this purpose, so names
collide instead of shadowing
([ch.11 §11.2](11-java-lambdas-streams.md#blocks-locals-and-scope)).

## 4.2 Scope rules

The visibility rules admit **two different interpretations** where the non-local
environment is concerned [GM4 §4.3], and the two give genuinely different answers.

> **Definition 4.4 (Static Scope).** The **static scope rule**, or the rule of
> **nearest nested scope**, is defined by the following three rules [GM4 Def. 4.4]:
>
> **(i)** The **declarations local** to a block define the local environment of that
> block. The local declarations of a block include only those present in the block
> and **not** those possibly present in blocks **nested inside** it.
>
> **(ii)** If a name is used inside a block, the valid association is the one present
> in the **environment local to the block**, if it exists. If no association exists
> locally, the associations in the environment local to the **immediately
> containing** block are considered; if found there, that is the valid one,
> otherwise the search continues with the containing blocks, **from the nearest to
> the furthest**. If the outermost block is reached and contains no association, the
> association is looked up in the language's **predefined environment**. If no
> association exists there, **there is an error**.
>
> **(iii)** A block can be assigned a **name**, in which case the name is part of the
> local environment of the block which **immediately includes** it. This is the case
> also for blocks associated with **procedures**.

> In a language with **static (or lexical) scope**, the environment in force at any
> point of the program and at any point during execution depends **uniquely on the
> syntactic structure of the program itself**. Such an environment can then be
> determined **completely by the compiler**, hence the term "static". [GM4 §4.3.1]

Introduced in ALGOL 60 and retained, with few modifications, by Ada, Pascal and Java
[GM4 §4.3.1].

Rule (ii) is the outward search that every modern language implements — and it is
exactly Python's LEGB chain, with the "predefined environment" being Python's
builtins. Rule (i) is easy to overlook but essential: a nested block's declarations
are *not* part of the enclosing block's local environment, which is why
`do_local`'s `spam` is invisible to `scope_test` in
[ch.13 §13.3](13-python-decorators-oop.md#the-scoping-example).

> **Definition 4.5 (Dynamic Scope).** According to the rule of **dynamic scope**,
> the valid association for a name `X`, at any point `P` of a program, is the **most
> recent (in the temporal sense)** association created for `X` which is **still
> active** when control flow arrives at `P`. [GM4 Def. 4.5]

Dynamic scope was introduced in APL, some versions of LISP, SNOBOL and PERL, mainly
to **simplify runtime environment management**: static scope imposes a fairly
complicated runtime regime, because the non-local environments are involved in a way
that **does not reflect the normal flow of activation and deactivation of blocks**
[GM4 §4.3.2].

The contrast is worth stating precisely, because it is the same distinction as
[ch.07 §7.4](07-types-and-polymorphism.md#74-binding-time) applied to names rather
than to methods:

| | Determined by | Resolvable by |
|---|---|---|
| **Static (lexical)** scope | the **syntactic nesting** of blocks | the **compiler** |
| **Dynamic** scope | the **call history** at runtime | only at **execution time** |

Under static scope a procedure's non-local names mean whatever they meant *where the
procedure was written*; under dynamic scope, whatever they mean *where it was
called*. The first supports the closures of
[ch.11 §11.2](11-java-lambdas-streams.md#variable-capture); the second makes a
procedure's behaviour depend on its caller, which is why it has largely been
abandoned. Note also the connection to
[ch.07 §7.1](07-types-and-polymorphism.md#strong-static-dynamic): "languages with
dynamic binding are dynamically typed", because a name whose meaning is fixed only
at runtime has no compile-time type either.

## 4.3 Memory management

Chapter 5 covers **static and dynamic management**, **activation records**, the
**system stack** and the **heap**, plus the data structures used to **implement
scope rules** [GM5 intro]. Garbage collection is deferred by the textbook to its
§8.12, after data types and pointers.

### Static management

> **Static memory management** is performed by the **compiler** before execution
> starts. Statically allocated memory objects reside in a **fixed zone** of memory
> (determined by the compiler) and **remain there for the entire duration** of the
> program's execution. [GM5 §5.2]

Typical statically allocated objects are **global variables** — they can be placed
at a fixed address precisely because they are visible throughout the program — and
the **object code instructions** produced by the compiler [GM5 §5.2].

This is the mechanism behind Python's static-variable capture rule: a static field
outlives every method call, so a lambda may mutate it, whereas a local may not
([ch.11 §11.2](11-java-lambdas-streams.md#variable-capture)).

### Dynamic management with a stack

Space for the information local to each block is allocated using a **stack**
[GM5 §5.3].

> The set of information relating to an **activation** of a procedure is called the
> **activation record**, or **frame**. [GM5 §5.3.2]

The stack discipline works because block and procedure activations **nest**: the
most recently entered is the first to be left, so last-in-first-out allocation
matches the control flow exactly. Activation records are covered for in-line blocks
[GM5 §5.3.1], for procedures [GM5 §5.3.2], and with the mechanics of pushing and
popping them [GM5 §5.3.3].

The chapter then treats **dynamic management using a heap** for **fixed-length**
and **variable-length** blocks [GM5 §5.4], the heap being needed exactly when
lifetime does *not* follow the nesting of blocks.

Stack/heap is the division [ch.05 §5.4](05-rust-ownership-borrowing.md#54-memory-management-and-raii)
assumes when it says Rust "uses a STACK of activation records, and a HEAP for
dynamically allocated data structures" and **favours stack allocation** with **no
implicit boxing** — `Box::new` being the explicit request for the heap.

### Implementing scope rules

Section 5.5 is the payoff for §4.1's observation that the environment does not exist
on the physical machine: it gives the data structures that implement **static
scope** [GM5 §5.5.1–5.5.2] and **dynamic scope** [GM5 §5.5.3]. This is where the
"fairly complicated runtime regime" of [GM4 §4.3.2] is made concrete — static scope
needs links that follow the *lexical* nesting, which does not coincide with the
stack's *dynamic* chain of activations.

## 4.4 Control abstraction

Chapter 7's argument opens by generalising the theme of
[ch.01](01-foundations-abstract-machines.md): *"to abstract" means simply to hide
something*, and abstraction is what allows a phenomenon to be described without
listing all its data — otherwise a description "would be like a geographical map of
scale 1:1, extremely precise" and useless [GM7 intro]. Abstract machines were the
first instance; subprograms are the second.

### Subprograms and parameter passing

**Functional abstraction** [GM7 §7.1.1] is the mechanism: a subprogram names a
computation, so callers use *what* it does without *how*. **Parameter passing**
[GM7 §7.1.2] is the interface, and the mode chosen determines what the callee can
observe and affect.

Two consequences appear elsewhere in these notes. Python "parameters are passed by
object reference" ([ch.13 §13.1](13-python-decorators-oop.md)); and Rust's default
is a **move** of ownership, with `&` and `&mut` as the two borrowing modes
([ch.05 §5.5–5.6](05-rust-ownership-borrowing.md#55-the-ownership-system)) — a
parameter-passing design driven entirely by memory safety.

The **calling convention** question of
[ch.01 §1.4](01-foundations-abstract-machines.md#14-neither-pure-the-continuum) —
whether caller or callee cleans the stack — is the implementation counterpart, and
it is settled by the activation-record layout of §4.3.

### Higher-order functions

> Chapter 7 treats **functions as parameters** [GM7 §7.2.1] and **functions as
> results** [GM7 §7.2.2].

The asymmetry between the two is the substantive point, and it is what
[ch.07 §7.2](07-types-and-polymorphism.md#72-subroutine-types) classifies as
second- versus first-class subroutines. Passing a function *inward* is compatible
with a stack discipline, since the passed function cannot outlive the frame that
supplied it. Returning a function *outward* is not: the returned function may
survive its defining frame, and if it refers to that frame's locals — a **closure**
— those locals cannot live on the stack.

That is precisely the problem Java avoids by requiring captured locals to be
effectively final, so a **copy** suffices and "closures are not necessary"
([ch.11 §11.2](11-java-lambdas-streams.md#variable-capture)); and the problem Python
solves with heap-allocated cells, visible through `__closure__`
([ch.13 §13.1](13-python-decorators-oop.md#higher-order-functions)).

### Exceptions

**Exceptions** [GM7 §7.3] are the chapter's third form of control abstraction, with
their **implementation** in §7.3.1 — an abstraction over non-local transfer of
control, requiring the runtime to unwind activation records until a handler is
found. The classification of error kinds a compiler can and cannot detect is in
[ch.03 §3.9](03-top-down-parsing.md#39-error-handling); Rust's alternative of
`Option<T>`/`Result` instead of exceptions is in
[ch.05 §5.2](05-rust-ownership-borrowing.md#52-null-pointers), and Haskell's
`Maybe`-as-exception in
[ch.10 §10.4](10-haskell-monads.md#the-standard-monads).

---

## Summary

| Concept | Statement | Source |
|---|---|---|
| Environment | associations between **names** and **denotable objects** at a point in the program and a time in execution | GM4 Def. 4.1 |
| Not physical | the environment **does not exist** at the physical machine level — it must be simulated | GM4 §4.1 |
| Block | a **textual region** with a start and end sign, which may contain local declarations | GM4 Def. 4.2 |
| Three environments | **local**, **non-local**, **global**; global ⊆ non-local | GM4 Def. 4.3 |
| Leaving a block | local associations **destroyed**; outer ones **reactivated** | GM4 §4.2.3 |
| **Static scope** | nearest nested scope: search local, then containing blocks nearest-to-furthest, then predefined, then error | GM4 Def. 4.4 |
| Why "static" | depends **only on syntactic structure** → determined completely by the compiler | GM4 §4.3.1 |
| Rule (i) | a nested block's declarations are **not** part of the enclosing local environment | GM4 Def. 4.4 |
| **Dynamic scope** | the **most recent still-active** association for the name | GM4 Def. 4.5 |
| Why used | simplifies runtime environment management | GM4 §4.3.2 |
| Static management | done by the **compiler**; fixed zone, whole program duration; globals and code | GM5 §5.2 |
| Activation record | the information relating to **one activation** of a procedure; also called **frame** | GM5 §5.3.2 |
| Why a stack works | block and procedure activations **nest** — LIFO matches control flow | GM5 §5.3 |
| Heap | needed when lifetime does **not** follow block nesting | GM5 §5.4 |
| Implementing scope | static scope needs links following **lexical** nesting, not the stack's dynamic chain | GM5 §5.5 |
| To abstract | "means simply to hide something" | GM7 intro |
| Functions inward | compatible with a stack discipline | GM7 §7.2.1 |
| Functions outward | may outlive their frame → **closures** → captured locals cannot live on the stack | GM7 §7.2.2 |
| Exceptions | abstraction over non-local transfer of control; unwinds activation records | GM7 §7.3 |

## Exam-style checks

1. State Definition 4.1 and explain why *both* "point in the program" and "time
   during execution" appear in it.
2. Why does the environment not exist at the level of the physical machine, and what
   follows for an implementation?
3. Give the three components of Definition 4.3 and map them onto Python's LEGB rule.
4. State the static scope rule. What does clause (i) exclude, and why does that
   matter?
5. State the dynamic scope rule, and give a program fragment whose result differs
   under the two disciplines.
6. Why can static scope be resolved by the compiler while dynamic scope cannot? Link
   your answer to binding time.
7. Which objects are typically allocated statically, and what property of theirs
   makes it possible?
8. What is an activation record? Why is a **stack** the right structure for them, and
   when is a heap needed instead?
9. Passing a function as a parameter is compatible with a stack; returning one is
   not. Explain, and name the two different solutions adopted by Java and Python.
