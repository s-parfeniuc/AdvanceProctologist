# Advanced Programming (301AA) — Exam Notes

Notes for the Advanced Programming exam, built from the lecture decks in
[`lecture_notes/`](../lecture_notes/) and the textbook chapters in
[`DOCS/`](../DOCS/).

Two documents govern the notes and are worth reading once before the chapters:

- **[`NOTATION.md`](../NOTATION.md)** — every symbol and term used, with the page
  that establishes it. Consult it whenever a symbol looks ambiguous.
- **[`SOURCES.md`](../SOURCES.md)** — what each source is, which pages are covered,
  and **what material does not exist** (§ gap register).

Every definition, formula and figure in these notes was read off a **rendered page
image**, not off extracted text: three decks and the largest textbook chapter have
broken font encodings, two of which fail silently. `SOURCES.md` documents the
faults; `scripts/check-notation.sh` enforces that no extraction residue survives
into the notes.

---

## Chapters

### Foundations

| | Chapter | Primary source | Pages |
|---|---|---|---|
| 01 | [Foundations: Abstract Machines and Language Stacks](01-foundations-abstract-machines.md) | Gabbrielli–Martini ch.1–2 + lecture transcripts | 430 |
| 02 | [Syntax and Grammars](02-syntax-and-grammars.md) | Parsing deck pp.1–26 | 620 |
| 03 | [Top-Down Parsing](03-top-down-parsing.md) | Parsing deck pp.27–63 | 799 |
| 04 | [Names, Memory Management, Control Abstraction](04-names-memory-control.md) ⚠ | Gabbrielli–Martini ch.4/5/7 — **no deck** | 312 |

### Memory and runtimes

| | Chapter | Primary source | Pages |
|---|---|---|---|
| 05 | [Rust: Ownership, Borrowing, Lifetimes](05-rust-ownership-borrowing.md) | RUST #1–#3 | 1409 |
| 06 | [Python: Memory Management and the GIL](06-python-runtime-gil.md) | Python and the GIL | 348 |

### Type systems

| | Chapter | Primary source | Pages |
|---|---|---|---|
| 07 | [Types and Polymorphism](07-types-and-polymorphism.md) | Types and Polymorphism | 611 |
| 08 | [Java Generics](08-java-generics.md) | Java Generics | 826 |
| 09 | [Haskell: Type Classes and Type Inference](09-haskell-typeclasses.md) | Haskell Type Classes | 1178 |

### Functional programming

| | Chapter | Primary source | Pages |
|---|---|---|---|
| 10 | [Haskell: Laziness, Constructor Classes and Monads](10-haskell-monads.md) | Monads | 1348 |
| 11 | [Java 8: Lambdas and Streams](11-java-lambdas-streams.md) | JLambdas | 1106 |

### Metaprogramming and dynamic languages

| | Chapter | Primary source | Pages |
|---|---|---|---|
| 12 | [Reflection and Annotations in Java](12-java-reflection-annotations.md) | Reflection and Annotations | 1161 |
| 13 | [Python: Functions, Decorators, OOP](13-python-decorators-oop.md) | Python Decorators, OOP | 1149 |

⚠ = textbook-only, no lecture deck exists.

---

## Reading orders

**By dependency.** Chapters 02→03, 07→08, 07→09→10 and 05→06 are the four genuine
sequences; everything else can be read independently.

```
01 ─┬─ 02 ── 03
    ├─ 04
    ├─ 05 ── 06
    ├─ 07 ─┬─ 08
    │      └─ 09 ── 10
    ├─ 11
    ├─ 12
    └─ 13
```

**By theme, if revising a single idea across languages.**

| Theme | Chapters |
|---|---|
| Memory safety | [05 §5.1–5.3](05-rust-ownership-borrowing.md#51-what-rust-is-for) · [06 §6.2](06-python-runtime-gil.md#62-memory-safety) · [04 §4.3](04-names-memory-control.md#43-memory-management) |
| Scope and closures | [04 §4.2](04-names-memory-control.md#42-scope-rules) · [11 §11.2](11-java-lambdas-streams.md#112-lambda-syntax) · [13 §13.3](13-python-decorators-oop.md#133-namespaces-and-scopes) |
| Ad hoc polymorphism | [07 §7.5](07-types-and-polymorphism.md#75-overloading-ad-hoc-polymorphism) · [09](09-haskell-typeclasses.md) · [13 §13.5](13-python-decorators-oop.md#135-special-methods) |
| Parametric polymorphism | [07 §7.3](07-types-and-polymorphism.md#73-what-polymorphism-is) · [08](08-java-generics.md) · [05 §5.8](05-rust-ownership-borrowing.md#traits) |
| Laziness | [10 §10.1](10-haskell-monads.md#101-laziness) · [11 §11.5](11-java-lambdas-streams.md#115-streams) · [13 §13.1](13-python-decorators-oop.md#higher-order-functions) |
| Monads | [10](10-haskell-monads.md) · [11 §11.9](11-java-lambdas-streams.md#119-monads-in-java) |
| Concurrency | [05 §5.11](05-rust-ownership-borrowing.md#511-safe-concurrency) · [06 §6.5](06-python-runtime-gil.md#65-the-global-interpreter-lock) · [11 §11.7](11-java-lambdas-streams.md#117-infinite-streams-and-parallelism) |
| Metaprogramming | [12](12-java-reflection-annotations.md) · [13 §13.2](13-python-decorators-oop.md#132-decorators) · [01 §1.7](01-foundations-abstract-machines.md#17-the-compiler-pipeline-and-metaprogramming) |
| Binding time | [07 §7.4](07-types-and-polymorphism.md#74-binding-time) · [04 §4.2](04-names-memory-control.md#42-scope-rules) · [12 §12.2](12-java-reflection-annotations.md#122-the-wider-metaprogramming-landscape) |

---

## Notation quick reference

Full contract in [`NOTATION.md`](../NOTATION.md). The rule that catches most
mistakes:

> `→` and `⇒` are **grammar** notation. `->` and `=>` are **source code**, verbatim.
> Never convert between them.

### Grammars and parsing ([ch.02](02-syntax-and-grammars.md), [ch.03](03-top-down-parsing.md))

| Symbol | Meaning |
|---|---|
| `G = (N, T, P, S)` | grammar — **nonterminals first** |
| `a, b, c` ∈ `T` | terminals |
| `A, B, C` ∈ `N` | nonterminals |
| `X, Y, Z` ∈ `(N∪T)` | grammar symbols |
| `u, v, w, x, y, z` ∈ `T*` | strings of terminals |
| `α, β, γ, δ` ∈ `(N∪T)*` | strings of grammar symbols |
| `η` | the string after `A` in `A ⇒⁺ A η` |
| `A → α` | production |
| `γ α δ ⇒ γ β δ` | one-step derivation |
| `⇒ₗₘ`, `⇒ᵣₘ` | leftmost, rightmost |
| `⇒*`, `⇒⁺` | transitive, positive closure |
| `ε` | empty string · `$` end of input |
| `L(G)` | language of `G` = `{ w ∈ T* \| S ⇒⁺ w }` |
| `ℒ(T)` | **class** of languages of grammar type `T` |
| `A_R`, `E_R`, `T_R` | nonterminals introduced by grammar transformation |

### Rules with labels

Memorise these by their tags — the lectures use them as shorthand.

| Tag | Statement | Chapter |
|---|---|---|
| `[O1]` | every value is owned by a variable | [05 §5.5](05-rust-ownership-borrowing.md#55-the-ownership-system) |
| `[O2]` | each value has **at most one owner** at a time | 〃 |
| `[O3]` | when the owner goes out of scope, the value is reclaimed | 〃 |
| `[B1]` | at most **one mutable reference** at any time | [05 §5.6](05-rust-ownership-borrowing.md#56-borrowing) |
| `[B2]` | if there is a mutable reference, no immutable ones may exist | 〃 |
| `[B3]` | with no mutable reference, several immutable ones may exist | 〃 |
| `[B4]` | owner cannot free or mutate while **immutably** borrowed | 〃 |
| `[B5]` | owner cannot even **read** while **mutably** borrowed | 〃 |
| `[R1]`–`[R3]` | lifetime elision: distinct by default; one input → all outputs; `&self` wins | [05 §5.7](05-rust-ownership-borrowing.md#57-lifetimes) |

### Types

| Notation | Meaning | Chapter |
|---|---|---|
| `S <: T` | `S` is a subtype of `T` | [07 §7.7](07-types-and-polymorphism.md#77-inclusion-polymorphism) |
| `<T extends B>` | Java bounded type parameter | [08 §8.2](08-java-generics.md#82-bounded-type-parameters) |
| `? extends T` / `? super T` | Java use-site covariance / contravariance | [08 §8.6](08-java-generics.md#86-wildcards) |
| `C a => T` | Haskell qualified type | [09 §9.4](09-haskell-typeclasses.md#94-type-classes-proper) |
| `∀α. α → α` | polymorphic type | [09 §9.8](09-haskell-typeclasses.md#six-kinds-of-type-inference) |

> **The `Monad` class** is used in the deck's pre-2015 form throughout ch.10:
> `return`, `>>=`, `>>`. Modern GHC has `Applicative` as a superclass and
> `return = pure`.

---

## Central definitions

The ones most likely to be asked for verbatim.

| Definition | Chapter |
|---|---|
| Abstract machine; machine language; interpreter; compiler | [01 §1.2–1.3](01-foundations-abstract-machines.md#12-abstract-machines) |
| Grammar; derivation; parse tree; yield; ambiguous | [02 §2.3–2.6](02-syntax-and-grammars.md#23-grammars) |
| FIRST; FOLLOW; LL(1); left recursion; left factoring | [03 §3.2–3.6](03-top-down-parsing.md#32-first) |
| Environment; block; static scope; dynamic scope; activation record | [04 §4.1–4.3](04-names-memory-control.md#41-names-and-the-environment) |
| RAII; ownership `[O1]`–`[O3]`; borrowing `[B1]`–`[B5]`; lifetime | [05 §5.4–5.7](05-rust-ownership-borrowing.md#54-memory-management-and-raii) |
| Reference counting; the GIL | [06 §6.1, §6.5](06-python-runtime-gil.md#61-garbage-collection-in-cpython) |
| Type system; strongly/statically/dynamically typed; ad hoc vs universal polymorphism; binding time | [07 §7.1–7.4](07-types-and-polymorphism.md#71-types-in-programming-languages) |
| Invariance; covariance; contravariance; type erasure; PECS | [08 §8.3–8.6](08-java-generics.md#83-generics-and-subtyping) |
| Type class; instance; qualified type; dictionary translation | [09 §9.4–9.5](09-haskell-typeclasses.md#94-type-classes-proper) |
| Laziness; call by need; Functor; Monad; monad laws | [10 §10.1–10.4, §10.9](10-haskell-monads.md#101-laziness) |
| Functional interface; default method; stream properties; PECS in practice | [11 §11.3–11.5](11-java-lambdas-streams.md#113-functional-interfaces) |
| Introspection; intercession; reification; annotation; retention policy | [12 §12.1, §12.7](12-java-reflection-annotations.md#121-what-reflection-is) |
| Namespace; scope; LEGB; decorator; name mangling | [13 §13.2–13.3, §13.6](13-python-decorators-oop.md#132-decorators) |

---

## What is not covered

From the gap register in [`SOURCES.md`](../SOURCES.md) — material that **does not
exist** in this repository:

| Course slot | Status |
|---|---|
| 04 | transcript only; folded into ch.03. The **Whitespace compiler** case study appears nowhere else — see [ch.03 §3.10](03-top-down-parsing.md#310-lecture-addendum-the-whitespace-compiler) |
| 05, 06 | **no slides**; textbook only → the brief [ch.04](04-names-memory-control.md) |
| 11, 12, 13, 14 | **nothing at all** — topics unknown |
| 18, 19, 20 | **nothing at all** — sits between Haskell type classes (17) and monads (21), so probably further Haskell |
| 22, 23 | **nothing at all** — sits between monads (21) and Java lambdas (24) |

Also **not lectured**, and marked as such in the notes: the Hindley–Milner type
inference algorithm, [ch.09 §9.9](09-haskell-typeclasses.md#99-appendix-type-inference-not-lectured)
(slide 37 of the deck says so explicitly).

If you obtain any missing deck, drop it in `lecture_notes/`, re-run
`scripts/extract.sh`, and the new chapter slots into this index.

---

## Regenerating and checking

```sh
scripts/extract.sh          # text + 150 DPI page renders for all 22 PDFs → build/
scripts/crop.sh <src> <page> <slug> [X Y W H]   # crop a figure into notes/assets/
scripts/check-notation.sh   # fail on extraction residue and broken image embeds
```

`build/` is disposable (~180 MB). `notes/` and `notes/assets/` are the deliverable;
`lecture_notes/` and `DOCS/` are never modified.
