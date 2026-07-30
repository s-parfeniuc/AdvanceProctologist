# 01 — Foundations: Abstract Machines and Language Stacks

> **Primary:** `DOCS/01-GabrielliMartini-ch1.pdf` — Gabbrielli–Martini ch.1, *Abstract Machines* · `DOCS/02-GM-ch2.pdf` — ch.2, *How to Describe a Programming Language*
> **Lecture record:** `lecture_notes/00 - advanced_prog_intro.md`, `01 - language_stack.md`, `02 - pl_transformation.md`
> **Cited as:** `[GM1 §x.y]`, `[GM2 §x.y]` for the textbook; `[L0]`, `[L1]`, `[L2]` for the three lecture transcripts

> **Source note.** Lectures 00–02 have **no slide deck** — see the gap register in
> [`SOURCES.md`](../SOURCES.md). The formal definitions below therefore come from
> Gabbrielli–Martini, which is the `DOCS/` material assigned to these lessons, and
> the lecture-specific content (examples, demonstrations, course framing) from the
> transcript notes. Where only the transcript supports a claim it is marked
> `[L0]`/`[L1]`/`[L2]`.

---

## 1.1 The course

*From the transcript record of the first lecture.* The course is designed around
the position that the central skill is no longer writing code but
**understanding, analysing and critically evaluating code produced by others**,
including by AI systems [L0]. The stated consequence for assessment is that the
exam is an individual project requiring the student to explore an unfamiliar
language or codebase, use AI tools in the analysis, and then *argue* for the
correctness of the result — followed by an oral examination [L0].

Two technical points from that lecture recur later in these notes:

- **Probabilistic generation.** LLMs sample from a distribution over next tokens,
  with a **temperature** parameter trading determinism against variety. Low
  temperature gives repeatable but conservative output; high temperature explores
  less probable continuations at the cost of coherence [L0]. The relevant
  consequence is that the same prompt need not produce the same program, unlike a
  compiler, which is a function.
- **Behavioural correctness is not syntactic correctness.** Generated code
  compiles far more often than it is right, so the reviewer's task is semantic
  [L0].

The lecture also framed the plurality of languages, borrowing Hofstadter's analogy
from *Gödel, Escher, Bach*: languages are like musical keys, and insisting on one
language is as odd as writing all music in one key [L0]. §1.6 turns that into a
classification.

## 1.2 Abstract machines

The organising concept of the whole course, and the one the textbook develops
first.

> **Definition 1.1 (Abstract Machine).** Assume that we are given a programming
> language, `L`. An **abstract machine** for `L`, denoted by `M_L`, is any set of
> **data structures and algorithms** which can perform the **storage and
> execution** of programs written in `L`. [GM1 Def. 1.1]

Three things to notice. The definition is *relative to a language* — there is no
abstract machine as such, only a machine for `L`. It is stated in terms of data
structures and algorithms, so it is deliberately neutral about whether the machine
is hardware, software, or a mixture. And it requires two capabilities, storage and
execution, which correspond to the machine's two components:

> A generic abstract machine `M_L` is composed of a **store** and an
> **interpreter**. The store serves to store data and programs while the
> interpreter is the component that **executes the instructions** contained in
> programs. [GM1 §1.1]

The interpreter's operations divide into groups [GM1 §1.1.1], of which the two most
important are **operations for processing primitive data** (arithmetic and logical
operations — primitive precisely because the machine performs them directly) and
**operations and structures for sequence control**, which manage the execution flow
and require their own data, such as the address of the next instruction.

> **Definition 1.2 (Machine language).** Given an abstract machine, `M_L`, the
> language `L` "understood" by `M_L`'s interpreter is called the **machine
> language** of `M_L`. [GM1 Def. 1.2]

Programs in the machine language are held in the machine's store, so that they are
not confused with the primitive data the interpreter operates on — and the textbook
adds the observation that matters for [ch.12](12-java-reflection-annotations.md):
*from the interpreter's viewpoint, programs are also a kind of data* [GM1 §1.1].
That identification is the seed of both metaprogramming and reflection.

### The physical machine is an instance

Mapping Definition 1.1 onto real hardware [GM1 §1.2]: the operations for
processing primitive data are the usual arithmetic and logical operations,
implemented by the **ALU**; sequence control is the **program counter** and the
fetch–execute cycle; the store is memory and registers.

This is the point the second lecture made about the compiled/interpreted
distinction: **a CPU is an interpreter** — it repeatedly fetches an instruction and
executes it, which is exactly the interpreter of Definition 1.1 [L1]. Any account
that treats interpretation as the exotic case has the hierarchy upside down.

## 1.3 Implementing a language

Given a machine `M_Lo` that runs `Lo`, and a language `L` we want to use, there are
two pure strategies.

> **Definition 1.3 (Interpreter).** An interpreter for language `L`, written in
> language `Lo`, is a program which implements a **partial function**
>
>     I_L^Lo : (Prog_L × D) → D
>
> such that
>
>     I_L^Lo (P_L, Input) = P_L(Input)
>
> [GM1 Def. 1.3, eq. 1.1]

> **Definition 1.4 (Compiler).** A compiler from `L` to `Lo` is a program which
> implements a function
>
>     C_L,Lo : Prog_L → Prog_Lo
>
> such that, given a program `P_L`, if
>
>     C_L,Lo (P_L) = Pc_Lo                                    (1.2)
>
> then, for every `Input ∈ D`:
>
>     P_L(Input) = Pc_Lo(Input)                               (1.3)
>
> [GM1 Def. 1.4]

The two definitions are worth comparing symbol by symbol, because the difference
between them is entirely in the *types*:

| | takes | returns |
|---|---|---|
| Interpreter | a **program and its input** | the **result** |
| Compiler | a **program** | another **program** |

An interpreter's domain includes the data, so it cannot run without them; its
output is an answer. A compiler's domain is programs alone, and its output is a
program — which is why, as the textbook notes, *the translation phase (1.2) is
separate from the execution phase (1.3)*, and the compiled program **can be
executed at any time we want** [GM1 §1.2.3].

The equations state what correctness means in each case: the interpreter must
produce what the program means, and the compiled program must compute the same
function as the source, for **every** input. Note that the interpreter implements a
*partial* function — a program that does not terminate has no result.

A subtlety the textbook draws out: if `Lo` is the only language available, the
compiler must itself be written in `Lo` — but this is not necessary in general. A
compiler may run on one machine and **produce code for another** [GM1 §1.2.3],
which is cross-compilation, and also why `rustc` could be rewritten from OCaml into
Rust ([ch.05 §5.13](05-rust-ownership-borrowing.md#513-brief-history)).

### The trade-off

> As far as the purely interpreted implementation is concerned, the main
> disadvantage is its **low efficiency**. […] given that there is no translation
> phase, in order to execute the program `P_L`, the interpreter must perform a
> **decoding** of `L`'s constructs *while it executes*. [GM1 §1.2.3]

The textbook's illustration: to execute

```
P1: for (I = 1, I<=n, I=I+1) C;
```

an interpreter whose own language lacks `for` must, at runtime, decode the command
and perform the operations that a loop amounts to:

```
P2:
   R1 = 1
   R2 = n
L1: if R1 > R2 then goto L2
   translation of C
   ...
   R1 = R1 + 1
   goto L1
L2: ...
```

with the crucial caveat: *the interpreter does not generate code* — this listing
describes what it does, not what it emits. And the cost compounds, because **the
command `C` inside the loop must be decoded `n` times** [GM1 §1.2.3]. Decoding
work that a compiler does once, an interpreter repeats on every execution of every
occurrence.

> As often happens, the disadvantages in terms of efficiency are compensated for by
> advantages in terms of **flexibility**. Indeed, interpreting the constructs at
> runtime allows **direct interaction** with whatever is running the program. This
> is particularly important […] because it makes defining program **debugging
> tools** relatively easy. In general, moreover, the development of an interpreter
> is **simpler** than the development of a compiler. [GM1 §1.2.3]

The same trade-off — flexibility and tooling against speed — reappears as
compile-time macros versus runtime reflection in
[ch.12 §12.2](12-java-reflection-annotations.md#122-the-wider-metaprogramming-landscape),
and as early versus late binding in
[ch.07 §7.4](07-types-and-polymorphism.md#74-binding-time).

## 1.4 Neither pure: the continuum

The second lecture's central claim is that **pure interpreters and pure compilers
are both rare**, and that compilation and interpretation are ends of a
**continuum** rather than a dichotomy [L1]. Three kinds of evidence were given.

**Hybrid implementations.** Java compiles to **bytecode** which a virtual machine
then executes — a compiler followed by an interpreter, with the intermediate
language chosen to make both halves easy [L1]. **Transpilers** such as
TypeScript → JavaScript are compilers whose target is another high-level language.

**Compiled languages depend on a runtime.** The worked example is `printf` in C
[L1]. Compiling `printf("Hello, world!\n")` does *not* translate `printf` — the
compiler emits code that prepares the arguments and issues a `CALL` to an
implementation supplied by the **C runtime library**, linked separately. So even
the canonical "fully compiled" language executes code that the user's compiler
never saw.

That example carries a second lesson about **calling conventions**. `printf` takes
a *variable* number of arguments, so the callee cannot know how many were pushed —
therefore only the **caller** can clean the stack. This is exactly the C
convention, and it differs from Pascal-style conventions where the callee cleans up
[L1]. The variadic feature and the calling convention are not independent choices.

**Interpreted languages compile.** Interpreters routinely preprocess source into
an optimised intermediate form before execution [L1] — CPython compiles to
bytecode, as [ch.06 §6.5](06-python-runtime-gil.md#65-the-global-interpreter-lock)
assumes when it speaks of threads "executing Python bytecodes".

### Hierarchies of abstract machines

The textbook's resolution of all this is that machines **stack** [GM1 §1.3]: an
abstract machine for `L` is implemented on a machine for `Lo`, which may itself be
abstract and implemented on a third, until some level is realised in hardware. The
Java stack is the standard illustration — source, bytecode, JVM, native
instructions, microarchitecture — and each level is a machine in the sense of
Definition 1.1, complete with its own machine language by Definition 1.2.

This is why the question "is Java compiled or interpreted?" has no answer: it is
compiled at one level of the hierarchy and interpreted at the next.

## 1.5 Runtime systems

Beyond translation, a language needs **services** at execution time [L1]:

- memory management, including garbage collection
- input/output libraries
- networking and concurrency support

Historical examples cited: the **C runtime**, the **Java Virtual Machine**, and
Microsoft's **.NET Universal Runtime (URT)**, conceived as a "modern C runtime"
integrating garbage collection, networking and graphics [L1].

Runtimes are what blur the boundary of §1.4, since they embed interpretation and
services inside environments that would otherwise be called compiled. The size of
the runtime is also a real design axis, and the rest of these notes give the two
extremes: Rust advertises **no runtime required — no GC, no dynamic typing or
binding** ([ch.05 §5.1](05-rust-ownership-borrowing.md#51-what-rust-is-for)),
while CPython's runtime does reference counting, cycle collection and interpreter
locking ([ch.06](06-python-runtime-gil.md)).

## 1.6 Describing a language: three levels

> In a study which has now become a classic in linguistics, **Morris** studied the
> various levels at which a description of a language can occur. He identified
> three major areas: **grammar, semantics and pragmatics**. [GM2 §2.1]
>
> **Grammar** is that part of the description of the language which answers the
> question: **which phrases are correct?** [GM2 §2.1]

The Parsing deck states the same triple as **syntax, semantics and pragmatics**
([ch.02 §2.2](02-syntax-and-grammars.md#22-syntax-semantics-pragmatics)) —
Gabbrielli–Martini say *grammar* where the lecture says *syntax*. The three levels
are then developed as: grammar and syntax, including context-free grammars
[GM2 §2.2]; **contextual syntactic constraints** — the checks a context-free
grammar cannot express [GM2 §2.3]; compilers [GM2 §2.4]; semantics [GM2 §2.5];
and pragmatics [GM2 §2.6].

The contextual-constraints section is the textbook counterpart of
[ch.02 §2.7](02-syntax-and-grammars.md#not-everything-is-context-free): rules like
"variables must be declared before use" are part of a language's definition but
not of its grammar, and are enforced during semantic analysis.

## 1.7 The compiler pipeline and metaprogramming

*From the third lecture's transcript record* [L2]; the same pipeline is given
authoritatively by the Parsing deck and reproduced as
[Figure 2.1](02-syntax-and-grammars.md#21-where-syntax-sits-the-compiler-pipeline).

The lecture-specific themes were:

- **Metaprogramming** — programs that manipulate programs, which Definition 1.2's
  observation ("programs are also a kind of data") already licenses. Developed in
  [ch.12](12-java-reflection-annotations.md).
- **Intermediate representations and virtual machines** — the middle levels of
  §1.4's hierarchy, and why they exist: an IR decouples the number of source
  languages from the number of target machines.
- **Automata and regular languages**, and **tokenizers** — the lexical half of
  the two-grammar split, treated properly in
  [ch.02 §2.7–2.8](02-syntax-and-grammars.md#27-the-syntax-of-programming-languages-two-grammars).
- **Determinism and safety in language processing** — the requirement that a
  compiler be a *function*, which is what §1.1's remark about LLM temperature was
  contrasting against.

## 1.8 Types, as first introduced

The second lecture's treatment of types [L1], given properly in
[ch.07](07-types-and-polymorphism.md). A type was characterised in the two ways
that chapter later separates as the *denotational* and *abstraction-based* views
([ch.07 §7.1](07-types-and-polymorphism.md#extensible-type-systems)):

- a **set of values** (integers, strings)
- a set of **operations** permissible on those values

with the classifications that
[ch.07 §7.1](07-types-and-polymorphism.md#strong-static-dynamic) states formally:

- **strongly typed** languages (Java, Haskell) prevent operations on incompatible
  types; **weakly typed** ones (C, C++) permit unsafe operations such as pointer
  casts, placing responsibility on the programmer
- **statically typed** languages (C, Java) check at compile time; **dynamically
  typed** ones (Python, JavaScript) at runtime

The lecture stressed that the cases are **hybrid**. Java checks statically but
needs a **runtime** check for downcasting — casting a `Control` to a `Button` — and
generics reduce but do not remove such checks, because **type erasure** means some
verification necessarily happens at runtime [L1]. That is the subject of
[ch.08 §8.5](08-java-generics.md#type-erasure).

**Duck typing** was introduced here: in dynamically typed languages an operation is
permitted if the object provides the expected methods, regardless of declared type
— "if it quacks like a duck" [L1]. This is what
[ch.13 §13.1](13-python-decorators-oop.md#positional-keyword-and-default-parameters)
identifies as one of the three things compensating for Python's lack of
overloading.

### Type constructors

An axis the lecture added to the standard ones: whether a language provides **type
constructors**, the ability to define new composite types [L1]. Java and C++ do;
JavaScript, Lua and early Lisp dialects do not, relying instead on flexible
object/dictionary models.

JavaScript is the instructive case. It has a `class` keyword, but the underlying
model is objects and dictionaries, with `a.b` as sugar for `a["b"]` giving the
appearance of class-based structure; and `this` binds dynamically to the calling
context [L1]. Compare
[ch.13 §13.4](13-python-decorators-oop.md#134-classes-as-namespaces), where Python
classes *are* namespaces implemented as dictionaries and attributes can be added at
runtime — the same underlying model, but with genuine type construction on top.

The composite type constructors themselves — product, sum, function space — are
catalogued in
[ch.07 §7.1](07-types-and-polymorphism.md#composite-types).

## 1.9 Classifying a language

The framework the second lecture offered for approaching an unfamiliar language
[L1] — four questions, each an axis:

- To what extent is it **compiled or interpreted**?
- Is it **statically or dynamically** typed?
- Is it **strongly or weakly** typed?
- Does it support **type constructors**?

with examples:

| Language | Compiled/interpreted | Typing discipline | Strength | Type constructors |
|---|---|---|---|---|
| Rust | compiled | static | strong | yes |
| Python | interpreted | dynamic | weak | no traditional ones |
| JavaScript | interpreted | dynamic | — | limited, via objects |

> These categories are **idealizations**, and most real languages occupy hybrid
> positions along a spectrum. [L1]

The caveat is the same one §1.4 established, now applied to all four axes at once.
The value of the framework is not that it sorts languages into boxes but that it
gives four specific questions to ask — and the rest of these notes answer them for
the languages the course covers: Rust in [ch.05](05-rust-ownership-borrowing.md),
Java in [ch.08](08-java-generics.md) and [ch.11](11-java-lambdas-streams.md),
Haskell in [ch.09](09-haskell-typeclasses.md) and
[ch.10](10-haskell-monads.md), Python in [ch.06](06-python-runtime-gil.md) and
[ch.13](13-python-decorators-oop.md).

---

## Summary

| Concept | Statement | Source |
|---|---|---|
| Abstract machine | for `L`: any set of **data structures and algorithms** performing storage and execution of `L` programs | GM1 Def. 1.1 |
| Components | a **store** and an **interpreter** | GM1 §1.1 |
| Interpreter's operations | primitive data processing; **sequence control** | GM1 §1.1.1 |
| Machine language | the language `L` understood by `M_L`'s interpreter | GM1 Def. 1.2 |
| Programs as data | from the interpreter's viewpoint, programs are a kind of data | GM1 §1.1 |
| Physical machine | ALU = primitive operations, program counter = sequence control | GM1 §1.2 |
| CPU is an interpreter | the fetch–execute cycle is Definition 1.1's interpreter | L1 |
| **Interpreter** | `I_L^Lo : (Prog_L × D) → D`, partial, with `I(P,Input) = P(Input)` | GM1 Def. 1.3 |
| **Compiler** | `C_L,Lo : Prog_L → Prog_Lo`, with `P_L(Input) = Pc_Lo(Input)` | GM1 Def. 1.4 |
| The difference | interpreter takes program **+ data** and returns a result; compiler takes a **program** and returns a program | GM1 Defs. 1.3–1.4 |
| Compilation is separable | translation (1.2) is separate from execution (1.3) — run it whenever | GM1 §1.2.3 |
| Interpreter cost | **decoding at runtime**, repeated for every occurrence and every iteration | GM1 §1.2.3 |
| Interpreter benefit | flexibility, direct interaction, easier debugging tools, simpler to build | GM1 §1.2.3 |
| Continuum | pure interpreters and pure compilers are both rare | L1 |
| `printf` | not compiled by the user's compiler — supplied by the **C runtime**, linked separately | L1 |
| Calling convention | C's **caller** cleans the stack, because variadic callees cannot know the count | L1 |
| Hierarchies | machines stack: source → bytecode → JVM → native → hardware | GM1 §1.3 |
| Runtime system | memory management, I/O, networking, concurrency | L1 |
| Three levels | **grammar** (syntax), **semantics**, **pragmatics** — after Morris | GM2 §2.1 |
| Contextual constraints | rules a context-free grammar cannot express | GM2 §2.3 |
| Type, two views | a set of values; a set of permissible operations | L1 |
| Four axes | compiled/interpreted, static/dynamic, strong/weak, type constructors | L1 |
| Duck typing | an operation is allowed if the object provides the methods | L1 |

## Exam-style checks

1. State Definition 1.1 (**abstract machine**) and identify its two components.
2. Give Definitions 1.3 and 1.4 (**interpreter** and **compiler**), and explain the
   difference purely in terms of the **domain and codomain** of the two functions.
3. Why is an interpreter a **partial** function while a compiler is total?
4. The textbook says the interpreter "does not generate code" although it shows a
   code listing. What is the listing for?
5. Explain why an interpreter must decode the body `C` of a loop `n` times, and what
   a compiler does instead.
6. Give three reasons why the compiled/interpreted distinction is a continuum, one
   for each kind of evidence in §1.4 (*neither pure*).
7. `printf` shows that C is not purely compiled. Explain how, and derive the C
   calling convention from the fact that `printf` is variadic.
8. What is a hierarchy of abstract machines? Locate the JVM in one.
9. Name Morris's three levels of description, and say which of them "variables must
   be declared before use" belongs to.
10. Java is statically typed yet needs runtime checks. Give two examples and the
    reason for each.
11. Classify Rust, Python and JavaScript on the four axes of §1.9 (*classifying a
    language*), and say why the answers are idealisations.

<details>
<summary>Answers</summary>

1. **Definition 1.1.** Given a language `L`, an **abstract machine** `M_L` is any
   set of **data structures and algorithms** which can perform the **storage and
   execution** of programs written in `L` [GM1 Def. 1.1]. Its two components are
   the **store**, which holds data and programs, and the **interpreter**, which
   executes the instructions contained in programs [GM1 §1.1].

2. Definition 1.3 (**interpreter**): `I_L^Lo : (Prog_L × D) → D`, a partial
   function, such that `I_L^Lo (P_L, Input) = P_L(Input)`. Definition 1.4
   (**compiler**): `C_L,Lo : Prog_L → Prog_Lo`, such that if
   `C_L,Lo (P_L) = Pc_Lo` then `P_L(Input) = Pc_Lo(Input)` for every
   `Input ∈ D` [GM1 Defs. 1.3–1.4]. The difference is entirely in domain and
   codomain: the interpreter's domain is `Prog_L × D` — it takes a **program and
   its input together** — and its codomain is `D`, a **result**. The compiler's
   domain is `Prog_L` alone — a **program**, with no data — and its codomain is
   `Prog_Lo`, another **program**.

3. The interpreter's function is partial because a program that does not
   terminate has no result — `I_L^Lo(P_L, Input)` is simply undefined for such an
   `Input`, since the interpreter's job is to actually run `P_L` on `Input`
   [GM1 §1.2]. The compiler is total in the relevant sense because translation
   (1.2) is a syntactic transformation, separate from execution (1.3): the
   compiler produces `Pc_Lo` regardless of whether `P_L` would ever terminate on
   any given input — it never runs the program, only rewrites it [GM1 §1.2.3].

4. The listing (`P2`, the `R1`/`R2`/`goto` sequence) is **not code the
   interpreter generates or emits**. It describes, in the reader's terms, the
   sequence of primitive-data and sequence-control operations the interpreter
   *performs internally* each time it decodes and executes the `for` loop `P1`
   — i.e., what decoding `P1` amounts to, not an artifact produced by the
   interpreter [GM1 §1.2.3].

5. With no translation phase, the interpreter must decode `L`'s constructs
   *while it executes*. Each of the `n` iterations of `P1`'s loop re-enters the
   body, and on every entry the interpreter must again decode the command `C` —
   work like recognising `C`'s construct and dispatching to the right
   operations — because nothing from the previous iteration's decoding is
   retained. A compiler instead performs that decoding **once**, at translation
   time, producing something like the `P2` listing directly as target code; the
   `n` executions then run already-decoded instructions, only the `goto L1`
   loop overhead repeating, not the decoding of `C` itself [GM1 §1.2.3].

6. (i) **Hybrid implementations**: Java compiles to bytecode which the JVM then
   interprets — a compiler followed by an interpreter — and transpilers such as
   TypeScript → JavaScript are compilers whose target is itself a high-level
   language, not a "final" machine language [L1]. (ii) **Compiled languages
   depend on a runtime**: compiling `printf("Hello, world!\n")` does not
   translate `printf` — the compiler emits a `CALL` to an implementation
   supplied by the C runtime library, linked separately, so even C executes
   code its compiler never saw [L1]. (iii) **Interpreted languages compile**:
   interpreters routinely preprocess source into an optimised intermediate form
   before execution, e.g. CPython compiles to bytecode before the interpreter
   runs it [L1].

7. Compiling a call to `printf` does not translate `printf` itself; the
   compiler emits code that prepares the arguments and issues a `CALL` to an
   implementation supplied by the **C runtime library**, linked in separately
   — so C, the canonical "fully compiled" language, still executes code its own
   compiler never processed [L1]. Deriving the calling convention: `printf`
   takes a **variable** number of arguments, so at the point of `CALL` the
   callee has no way to know how many arguments the caller pushed onto the
   stack. Only the **caller** knows that count, so only the caller can be
   responsible for cleaning the stack afterward — which is exactly the C
   convention (**caller cleans up**), and it is precisely why Pascal-style
   conventions, where the callee cleans up, could never support a variadic
   `printf` [L1].

8. A **hierarchy of abstract machines** is the resolution of the
   compiled/interpreted dichotomy [GM1 §1.3]: an abstract machine for `L` is
   itself implemented on a machine for `Lo`, which may itself be abstract and
   implemented on a further machine, and so on, until some level is realised in
   hardware. Each level is a machine in the sense of Definition 1.1, with its
   own machine language by Definition 1.2. In the Java stack — source →
   bytecode → JVM → native instructions → microarchitecture — the **JVM**
   occupies the level that is the *interpreter* for the bytecode machine
   language: bytecode is compiled *to* by `javac`, but the JVM level then
   interprets that bytecode, and is itself implemented on (compiled down to)
   native instructions. This is why "is Java compiled or interpreted?" has no
   single answer — compiled at one level, interpreted at the next.

9. Morris's three levels are **grammar, semantics and pragmatics**
   [GM2 §2.1]. "Variables must be declared before use" is **not** part of
   grammar — a context-free grammar cannot express it — and the chapter states
   explicitly that such contextual constraints "are part of a language's
   definition but not of its grammar, and are enforced during semantic
   analysis" — so it belongs to **semantics**.

10. Two examples, both from §1.8. (i) **Downcasting**: casting a `Control` to a
    `Button` is checked statically only up to what the declared types allow;
    whether the actual object *is* a `Button` can only be known at runtime, so
    Java inserts a runtime check — because static typing verifies against
    declared types, not actual runtime identities. (ii) **Generics under type
    erasure**: generic type parameters are erased at compile time
    ([ch.08 §8.5](08-java-generics.md#type-erasure)), so the compile-time
    generic check cannot be the whole story — some verification necessarily
    happens at runtime, because the erased bytecode no longer carries the
    type-parameter information the compiler used.

11. | Language | Compiled/interpreted | Typing discipline | Strength | Type constructors |
    |---|---|---|---|---|
    | Rust | compiled | static | strong | yes |
    | Python | interpreted | dynamic | weak | no traditional ones |
    | JavaScript | interpreted | dynamic | — | limited, via objects |

    These are **idealisations** because, per §1.4, pure compilation and pure
    interpretation are both rare and the axes are themselves a continuum: Rust
    needs no runtime and no GC ([ch.05 §5.1](05-rust-ownership-borrowing.md#51-what-rust-is-for))
    but that is the extreme end, not proof no other language could be placed
    there too; Python still compiles to bytecode before its interpreter runs it
    ([ch.06 §6.5](06-python-runtime-gil.md#65-the-global-interpreter-lock)); and
    JavaScript has a `class` keyword sitting on top of an object/dictionary
    model with no genuine type constructors underneath, which is why its
    "type constructors" cell reads "limited" rather than yes/no. As stated
    directly: "these categories are idealizations, and most real languages
    occupy hybrid positions along a spectrum" [L1].

</details>
