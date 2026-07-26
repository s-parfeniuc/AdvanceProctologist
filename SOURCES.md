# Source inventory

Everything the notes are built from, with the extraction faults that affect each
source. Sources in `lecture_notes/` and `DOCS/` are never modified.

Run `scripts/extract.sh` to regenerate `build/text/` and `build/pages/`
(996 page renders at 150 DPI, ~180 MB; disposable).

## The one rule that matters

**`build/text/` is a drafting aid and a grep index. It is not evidence.**

Three of the twelve decks and the largest textbook chapter have broken font
encodings, and two of them fail *silently* — the extracted text is wrong but
still reads as plausible English or plausible mathematics. Every definition,
formula, symbol and figure in the notes must be read off the corresponding
`build/pages/<source>/page-NNN.png` render.

## Citation convention

Cite by **PDF page number**, e.g. `[Parsing p.45]`.

Printed slide numbers drift from PDF page numbers because the decks contain
hidden and animation-build slides. In the Parsing deck PDF pages 1–40 match the
printed numbers, but PDF p.45 prints "48"; JLambdas PDF p.40 prints "47";
Reflection PDF p.40 prints "43". The drift is not a constant per deck, so it
cannot be tabulated reliably — cite the PDF page, which is what
`build/pages/…/page-045.png` and any PDF reader agree on.

## Extraction faults

### A. Symbol-font substitution — silent, mathematically dangerous

Affects **`03-AP-25-09-25-Parsing.pdf`** (215 occurrences) and lightly
`17-AP25-Haskell-TypeClasses.pdf` (7).

Greek letters and operators are set in Symbol font and extract as ordinary Latin
letters, so the result is *readable but wrong*:

| Extracted | Actual | | Extracted | Actual |
|---|---|---|---|---|
| `®` | `→` | | `a` | `α` |
| `Î` | `∈` | | `b` | `β` |
| `È` | `∪` | | `g` | `γ` |
| `Þ` | `⇒` | | `e` | `ε` |

Worked example — Parsing p.45, the definition of FOLLOW:

```
build/text/ says:   for all (B ® a A b) Î P do  /  add FIRST(b)\{e} to FOLLOW(A)
the page says:      for all (B → α A β) ∈ P do  /  add FIRST(β)\{ε} to FOLLOW(A)
```

Nothing in the extracted form looks broken. This is the fault the whole
verification process exists to catch.

### B. Missing ToUnicode CMap — total, loud failure

Affects **`DOCS/03-ALSU-ch4.pdf`** (Aho/Lam/Sethi/Ullman, *Syntax Analysis*,
112 pp) — the authoritative reference for parsing notation.

Every font is a subset CID font with `Identity-H` encoding and no ToUnicode
table (`pdffonts` reports `uni: no` for all of them). Extraction yields ~660 K
characters of Myanmar/Tibetan-range glyphs. `mutool` fails identically; no OCR
engine is installed. The renders are pristine, so this chapter is used
**visually only**. `build/text/03-ALSU-ch4.txt` is worthless — ignore it.

Parsing deck pp.42 and 49 are pasted fragments *of this book* and carry the same
breakage. They are treated as figures, not text.

### C. `ti` ligature to digit — silent, cosmetic

Affects `15-AP25-10-27-Types-Polymorphism.pdf`, `16-AP25-JavaGenerics.pdf`,
`25-AP25-Reflection_Annotations_in_Java.pdf`, and 4 spots in `DOCS/03-ALSU-ch4`.

The `ti` ligature extracts as `4`, `5`, `0` or `?`, and `fi`/`fl` extract as the
precomposed `ﬁ`/`ﬂ` codepoints:

`applica4on` → application · `Sta5cally` → statically · `Primi?ve` → primitive ·
`func0ons` → functions · `Reﬂec'on` → reflection · `Limita=ons` → limitations

Baseline counts, for `scripts/check-notation.sh`: 24 / 8 / 18 digit-in-word hits
in decks 15 / 16 / 25, and 12 / 0 / 75 precomposed ligatures.

### D. Vector figures — `pdfimages` does not work

Slide diagrams are PowerPoint/Keynote vector drawings, not embedded rasters.
`pdfimages` reports 44 "images" in the Parsing deck, but they are almost all
2×3-pixel artifacts; only pp.8 and 25 hold a real bitmap. Figures are therefore
produced by cropping page renders — see `scripts/crop.sh`.

## Lecture material (`lecture_notes/`) — primary

The numeric prefix is the course's own ordering. It is not the lecturer's lesson
number: the RUST #1 title slide reads "Lesson 08 – 6/10/2025" while the file is
prefixed `07`. Prefixes are used here purely as source identifiers.

| Prefix | Source | Pages | Topic | Faults |
|---|---|---|---|---|
| 00 | `00 - advanced_prog_intro.md` | — | course framing, AI-assisted programming | transcript paraphrase; no deck exists |
| 01 | `01 - language_stack.md` | — | language stacks, compiled vs interpreted, runtimes | transcript paraphrase; no deck exists |
| 02 | `02 - pl_transformation.md` | — | metaprogramming, compiler pipeline, IR/VMs, automata | transcript paraphrase; no deck exists |
| 03 | `03-AP-25-09-25-Parsing.pdf` | 63 | grammars → LL(1) parsing → error recovery | **A**, **B** (pp.42, 49), Italian excerpt p.8 |
| 03 | `03 - top_down_parsing.md` | — | same lecture, transcript view | transcript paraphrase |
| 04 | `04 - predictive_parsing_whitespace.md` | — | FIRST/FOLLOW + **Whitespace compiler case study** | transcript paraphrase; case study exists nowhere else |
| 07 | `07-AP25-10-06-RUST-1.pdf` | 24 | Rust intro, memory safety, ownership | clean |
| 08 | `08-AP25-10-08-RUST-2.pdf` | 18 | borrowing, lifetimes | clean |
| 09 | `09-AP25-10-13-RUST-3.pdf` | 17 | smart pointers, unsafe, safe concurrency | clean |
| 10 | `10-AP25-10-15-Python_and_GIL.pdf` | 11 | CPython memory management, the GIL | clean |
| 15 | `15-AP25-10-27-Types-Polymorphism.pdf` | 23 | type systems, polymorphism classification | **C** |
| 16 | `16-AP25-JavaGenerics.pdf` | 29 | generics, variance, wildcards, erasure | **C** |
| 17 | `17-AP25-Haskell-TypeClasses.pdf` | 65 | type classes, dictionaries, type inference | **A** (light) |
| 21 | `21-AP25-Monads.pdf` | 61 | laziness, constructor classes, monads, IO | clean |
| 24 | `24-AP25-JLambdas.pdf` | 43 | Java 8 lambdas, method refs, Stream API | clean |
| 25 | `25-AP25-Reflection_Annotations_in_Java.pdf` | 53 | reflection, annotations | **C** |
| 26 | `26-AP25-Python-Decorators-OOP.pdf` | 40 | first-class functions, decorators, OOP model | clean |

## Reference material (`DOCS/`) — supporting

| Prefix | Source | Pages | Content | Faults |
|---|---|---|---|---|
| 01 | `01-GabrielliMartini-ch1.pdf` | 25 | Gabbrielli–Martini ch.1, *Abstract Machines* | clean |
| 02 | `02-GM-ch2.pdf` | 29 | ch.2, *How to Describe a Programming Language* | clean |
| 03 | `03-ALSU-ch4.pdf` | 112 | Aho et al. ch.4, *Syntax Analysis* | **B** — visual only |
| 03 | `03-Scott-ch2.pdf` | 70 | Scott ch.2, *Programming Language Syntax* | clean |
| 05 | `05-GM-ch4.pdf` | 24 | ch.4, *Names and the Environment* | clean |
| 05 | `05-GM-ch7.pdf` | 32 | ch.7, *Control Abstraction* | clean |
| 06 | `06-GM-ch5.pdf` | 28 | ch.5, *Memory Management* | clean |
| 15 | `15-Mitchell-CPL-Ch6.pdf` | 35 | Mitchell ch.6, *Type Systems, Type Inference, Polymorphism* | clean |
| 17 | `17-Mitchell-CPL-Ch7.pdf` | 21 | Mitchell ch.7, *Type Classes* | clean |
| 25 | `25-MonadsInJava_by_MarioFusco.pdf` | 73 | Mario Fusco, *Monadic Java* talk (slide deck) | clean; image-heavy, sparse text |

## Coverage log

Pages deliberately not cited by any chapter. Everything else in a source's page
range is accounted for.

| Source | Pages skipped | Reason |
|---|---|---|
| `03-AP-25-09-25-Parsing.pdf` | 1 | title slide |
| | 29–31, 33–35 | animation build-up frames of the predictive-parse trace; frames 4 and 8 (pp.32, 36) are reproduced and the range is cited as pp.29–36 in [ch.03 §3.1](notes/03-top-down-parsing.md) |
| | 63 | "Conclusions…" — the slide has no content |
| `07-AP25-10-06-RUST-1.pdf` | 1–2 | title and outline slides |
| `08-AP25-10-08-RUST-2.pdf` | 1–2 | title and outline slides |
| | 3 | marked RECAP on the slide — repeats the ownership rules of R1 p.20 |
| | 18 | System Traits, superseded by the fuller version on R3 p.3 (which adds "requires `Clone`" to `Copy`) |
| `09-AP25-10-13-RUST-3.pdf` | 1–2 | title and outline slides |
| `10-AP25-10-15-Python_and_GIL.pdf` | 1 | title slide |
| | 7 | "Concurrency in Python…" — section divider, no content |
| `15-AP25-10-27-Types-Polymorphism.pdf` | 1 | title slide |
| `16-AP25-JavaGenerics.pdf` | 1 | title slide |
| `17-AP25-Haskell-TypeClasses.pdf` | 1–2 | title slide and "Core Haskell" outline |
| | 51, 53, 58, 60 | animation build-up frames of the appendix parse-tree examples; the informative frames of each sequence are reproduced |
| `21-AP25-Monads.pdf` | 1 | title slide |
| | 26 | "Contaminating Haskell with side effects" — section divider, no content |
| `24-AP25-JLambdas.pdf` | 1 | title slide |
| | 41 | "MONADS IN JAVA…." — section divider, no content |
| `25-AP25-Reflection_Annotations_in_Java.pdf` | 1 | title slide |
| | 42 | "ANNOTATIONS IN JAVA" — section divider, no content |
| `26-AP25-Python-Decorators-OOP.pdf` | 1 | title slide |

Every other page of every deck is cited by a chapter. The `DOCS/` textbook chapters
are supporting material and are cited by section rather than exhaustively; ch.04 is
explicitly a brief selection from three of them (84 pages), not full coverage.

## Gap register

Material that does not exist in this repository. Nothing in the notes may be
invented to fill these — a gap is recorded as a gap.

| Prefix | Status | Consequence for the notes |
|---|---|---|
| 00, 01, 02 | transcript `.md` only, no deck, but GM ch.1/ch.2 cover the theory | ch.01 is anchored on Gabbrielli–Martini for notation, with lecture-specific content (demos, course framing) kept from the transcripts |
| 04 | transcript `.md` only | folded into ch.03; the Whitespace compiler case study survives only here |
| 05, 06 | **no slides**, textbook chapters only | ch.04 is a deliberately brief background chapter, flagged as textbook-only |
| 11, 12, 13, 14 | **nothing at all** | not covered. Unknown topics |
| 18, 19, 20 | **nothing at all** | not covered. Sits between Haskell type classes (17) and monads (21), so probably further Haskell |
| 22, 23 | **nothing at all** | not covered. Sits between monads (21) and Java lambdas (24) |

If you obtain any of these decks, drop them in `lecture_notes/`, re-run
`scripts/extract.sh`, and the new chapter slots straight into `notes/`.
