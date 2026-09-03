# Style guide for Cambridge course materials (slides + lecture notes)

Derived from analysing `dist-sys/` (Martin Kleppmann's Distributed Systems course:
`dist-sys.tex`, 6,710 lines, 8 lectures, 171 slides, 25 exercises). This document records
everything needed to write new material for the Databases course in the same style without
re-reading the source.

Anything below stated as "always"/"never" was checked against the whole of `dist-sys.tex`.

---

## 1. The core idea: one source, three outputs

**All content lives in a single file** (`databases.tex`, the analogue of `dist-sys.tex`).
Slides and prose are interleaved in that one file, in reading order. Three wrapper documents
`\input` it and select different parts:

| Wrapper | Class | What it keeps | What it drops |
|---|---|---|---|
| `databases-slides.tex` | `beamer` (screen) | `frame` bodies | prose (via `ignorenonframetext`) |
| `databases-handout.tex` | `beamer` + `handout` | `frame` bodies, overlays collapsed | prose; navigation links |
| `databases-notes.tex` | `article` + `beamerarticle` | prose | `frame` bodies (via `\RenewEnviron{frame}{\iffalse\fi}`) |

The notes get the slides back as **images**: `\inlineslide{s:label}{}` embeds the
corresponding page of `databases-handout.pdf`. Hence the build order in the `Makefile`:
`databases-handout.pdf` → `databases-notes.pdf` → `solutions.pdf`.

`solutions.pdf` is generated from `exercises.tex`, which `databases-notes.tex` writes out as a
side effect by redefining `\supervision` to capture both arguments.

**Consequences you must respect when writing:**

* Every `frame` is immediately followed by an `\inlineslide{...}{}` call, otherwise the slide
  never appears in the notes.
* Prose must live *outside* `frame` environments. Text inside a frame appears only on slides.
* Nothing in the notes may depend on being inside a frame, and vice versa.
* The notes are not slide captions — they are continuous prose that reads as a standalone
  textbook chapter, with slides dropped in as figures.

### Files (already scaffolded in `/workspace`, mirroring `dist-sys/`)

```
Makefile              databases.tex          <- all content goes here
setup.tex             databases-slides.tex   databases-handout.tex   databases-notes.tex
solutions.tex         references.bib         exercises.tex (generated, do not edit)
images/               code/                  <- create code/ when first needed
```

Build with `make`. `pdflatex` runs with `-shell-escape` (needed by `minted`/Pygments).

---

## 2. Anatomy of the content file

`databases.tex` is structured as:

1. **Year-dependent macros** at the very top, with a comment saying they change annually
   (`\courseurl`, `\thisyear`, `\mydetails`, and any `\newcommand` for cross-course URLs or
   term names). Never hard-code a year or a URL further down the file — define a macro here.
2. `\fancypagestyle{plain}` for the Creative Commons footer on page 1 of the notes.
3. `\begin{document}`, `\title`/`\subtitle`/`\author`/`\date{}`, `\mode<article>{\maketitle}`,
   `\tableofcontents`, an acknowledgements sentence, `\def\sectionautorefname{Section}` etc.
   The `\mode<article>` guard is a **deliberate divergence from dist-sys**: a bare `\maketitle`
   also fires in presentation mode, so the slides and handout would open with beamer's
   auto-generated title page immediately before the hand-designed `s:title` frame (dist-sys has
   this double title slide). `\tableofcontents` and the acknowledgements need no guard — they
   are non-frame material, which `ignorenonframetext` already drops.
4. `\newpage`, then the content: `\section` per lecture, `\subsection` per topic.
5. Ends with `\footnotesize \bibliographystyle{plainnat} \bibliography{references}{}`
   `\end{document}`.

### Sectioning

* **One `\section` per lecture.** dist-sys has exactly 8 sections for 8 lectures. Databases
  also has 8 lectures (see `syllabus.md`), so: 8 `\section`s.
* 2–5 `\subsection`s per section. `\subsubsection` is available but unused.
* Every heading carries a label: `\section{Broadcast}\label{sec:broadcast}`.
* The last subsection of the last lecture is `\subsection{Wrapping up}` containing a
  "That's all, folks!" summary slide plus a few closing paragraphs of prose.
* `\newpage` is used only 3 times in 6,710 lines — before the first section, and where a
  lecture boundary would otherwise fall badly. Do not sprinkle it.

### Lecture opener frames

Every `\section` after the first is immediately followed by an unlabelled title frame, and
it is **not** followed by `\inlineslide` (it is deliberately absent from the notes):

```latex
\section{Replication}\label{sec:replication}

\begin{frame}
    \begin{center}
        {\Large{\color{darkblue}{Replication}}} \\[2em]
        \mydetails
    \end{center}
\end{frame}

Prose begins here...
```

The first section instead has the full title slide (`\label{s:title}`, `\huge`, course URL,
CC licence in a two-column layout) — copy the existing one in `databases.tex`.

---

## 3. Frames (slides)

### Skeleton

```latex
\begin{frame}
    \label{s:fault-tolerance}
    \frametitle{Achieving high availability: fault tolerance}
    ...content...
\end{frame}
\inlineslide{s:fault-tolerance}{}\label{l:fault-tolerance}
```

* `\label` is the **first line inside** the frame, always with prefix `s:`.
* `\frametitle` comes second. 90% of frames have one; frames that are a single full-bleed
  image or a table often omit it.
* `\inlineslide{s:foo}{}` follows on the very next line. Its second argument is a
  side-annotation slot; **it is empty in all 163 uses** — leave it `{}`.
* Add `\label{l:foo}` after `\inlineslide` **only if the prose cross-references the slide.**
  About 85% of slides have one. This label resolves to "Slide *N*" because `\inlineslide`
  steps the `inlineslides` counter.

### Label naming conventions

| Prefix | Attached to | Used by |
|---|---|---|
| `sec:` | `\section` / `\subsection` | `\autoref{sec:broadcast}` → "Section 4" |
| `s:` | inside `\begin{frame}` | `\inlineslide`, `\againframe` |
| `l:` | after `\inlineslide` | `\autoref{l:fifo-broadcast}` → "Slide 42" |
| `q:` | inside `\supervision` | `\autoref{q:fifo-links}` → "Exercise 7" |

Names are lowercase, hyphenated, short, topic-derived (`s:two-generals-applied`,
`l:read-after-write-2`). Multi-part slides on one topic get numeric suffixes:
`s:total-order1`, `s:total-order2`, or `s:raft1` … `s:raft9`.

### Frame options

* `\begin{frame}` — the default, ~94% of frames.
* `\begin{frame}[plain]` — 11 uses: full-bleed images and pseudocode that needs the whole page.
* `\begin{frame}[label=vector-ordering]` + `\againframe<3>{vector-ordering}` — to re-display an
  earlier slide later in the course (2 uses). Note the beamer `label=` option, distinct from
  the `\label{s:...}` command.

### Slide density

Median **~50 words** of visible text per slide (interquartile range 9–80; hard maximum
observed ~150). 15 of 170 frames are pure diagram or image with almost no text.

Slides are **terse and telegraphic**, not sentences:

* Bullet lists of noun phrases and clipped clauses (`\begin{itemize}`, 105 uses).
* Key terms in `\textbf{}` at the start of a line, then an explanation after `\\`:
  `\textbf{Fault tolerance}:\\system as a whole continues working, despite faults`
* Vertical rhythm is controlled manually with `\\[1em]`, `\\[0.5em]`, `\\[1.5em]`,
  `\vspace{1em}` — not with blank lines.
* Abbreviations expanded once with the acronym in bold or parenthesised:
  `\textbf{Service-Level Objective} (SLO)`.
* `\dots` for trailing enumeration (`server, desktop computer, phone, car, sensor, \dots`).
* Rhetorical questions are welcome (`Why NOT make a system distributed?`,
  `what if the service crashes during the function call?`).
* `\footnotesize` / `\scriptsize` declared right after `\frametitle` when the content is dense
  (all pseudocode slides start with `\footnotesize`).

### Overlays / progressive disclosure

Very heavily used: 178 `\pause`, 44 `\uncover`, plus `<n->` specifiers on TikZ elements.

* `\pause` between bullets, placed **at the end of the preceding line**, after any spacing:
  `\item \textbf{For better reliability:}\\even if one node fails\dots\pause`
* `\\[1em]\pause` is the common combination at the end of an `itemize` before follow-on text.
* Inside `columns`, use `\item<1->`, `\item<2->` … instead of `\pause`.
* For text that must appear without reflowing the slide, `\uncover<3->{...}` (typical under a
  diagram: the takeaway sentence is revealed after the diagram is built).
* `\onslide<2->{...}` for larger blocks (rare, 2 uses).
* **Handout suppression:** when a slide shows two alternative versions of the same diagram
  element on different overlays, hide one of them from the handout/notes with a `handout:0`
  clause in the overlay spec, so the composited handout page isn't a mess:
  `\draw<1-5| handout: 0> [bigarrow] ...` / `\draw<6-| handout:0> [bigarrow,darkgreen] ...`
  This is the standard trick for "the wrong ordering, then the corrected one".

### Theme

**No beamer theme is loaded** — no `\usetheme`, `\usecolortheme`, or `\setbeamertemplate`
anywhere. The look is the stock beamer default at `12pt`, with all styling done inline
(`\color{darkblue}`, `fill=red!10`, etc.). `\usefonttheme[onlymath]{serif}` in the wrappers
gives serif maths on sans-serif slides. Do not introduce a theme.

---

## 4. Lecture-notes prose

### Hard formatting rule: one sentence per line

Every sentence starts on a new source line. Paragraphs are separated by a blank line. This is
followed without exception in the prose of `dist-sys.tex` and makes diffs readable — **match
it**. Average sentence: ~21 words.

```latex
Each of the computers in a distributed system is called a \emph{node}.
Here, ``computer'' is interpreted quite broadly: nodes might be desktop computers, servers in datacenters, mobile devices, internet-connected cars, industrial control systems, sensors, or many other types of device.
In this course we don't distinguish them: a node can be any type of communicating computing device.
```

Do not hard-wrap at a column width; let lines run long.

### Volume

~33,000 words of prose across 8 lectures ≈ **4,000 words per lecture**, ≈ 190 sentences per
lecture, interleaved with ~21 slides. Roughly 2–5 sentences of prose between consecutive
slides, occasionally a whole page.

### Voice and register

* **First person plural** for the intellectual journey: "we will examine", "we can arrange
  these into a hierarchy", "let's start with", "as we shall see", "recall from".
* **Second person** for the student's experience: "you use every day", "if you want to send a
  very large message", "many of you will end up working on such systems".
* Contractions are used freely ("don't", "doesn't", "it's", "let's").
* Present tense throughout; future ("we will see") for forward references.
* Warm, direct, occasionally wry — but never jokey at the expense of clarity. Examples of the
  register: "Some distributed system engineers believe that if you can solve a problem on a
  single computer, it is basically easy! Though, in fairness to our colleagues in other areas
  of computer science, this is probably not true." / "I am not a fan of this militaristic
  analogy, but unfortunately the problem is well known under the name…"
* Explicitly flags what is and is not examinable, and what is simplified: "only material
  covered in the lectures and these notes is examinable"; "The details of the language are not
  important for this course."
* Honest about messiness: parenthetical caveats and "confusingly, these terms are also used
  with a different meaning in other contexts".
* Motivation before mechanism. A concept is introduced by a concrete everyday example (loading
  a web page, paying by card) before it is formalised.
* Closes each concept by naming the trade-off rather than declaring a winner:
  "No one right way, just trade-offs".

### Relationship between prose and slides

The prose is self-sufficient: a reader who ignored the slide images would still follow the
argument. Typical patterns:

* Prose *sets up* the next slide: "…as shown on \autoref{l:payment-rpc}."
* Prose *unpacks* the slide just shown: after a pseudocode slide, a paragraph names each state
  variable and explains what each block does.
* Prose *adds* material not on the slides at all: extra caveats, historical notes, parenthetical
  asides — often a whole paragraph in parentheses.
* Never "This slide shows…". Refer to slides by `\autoref` as you would to a figure.

### British spelling

`behaviour`, `focussed`, `organisation`, `analysing`, `centre`, `-ise`/`-isation` endings.
Exceptions kept for established technical terms: **linearizability**, **serializability**
(z), and US spellings inside quoted names/code.

### Cross-references

`\autoref` (170 uses), never a bare `\ref` with a hand-written word. Forms:

* `\autoref{l:fifo-broadcast}` → "Slide 42" — the workhorse.
* `\autoref{sec:consensus}` → "Section 7".
* `\autoref{q:hb-three-cases}` → "Exercise 12".
* Consecutive slides: `\autoref{l:total-order1} and \ref{l:total-order2}` — plain `\ref` for
  the second so the word "Slide" is not repeated (5 uses).

### Blocked notes

For a genuine aside that would derail the paragraph, use `mdframed` (2 uses, both terminology
warnings):

```latex
\begin{mdframed}
Note: confusingly, these terms are also used with a different meaning in other contexts.
...
\end{mdframed}
```

### Source comments

`%`-comments in the content file carry TODOs, rejected alternatives, sources for images and
numbers, and even the Python used to compute a table's values. Keep this habit — it is how
the file stays maintainable year to year. Commented-out `\supervision` and `\begin{frame}`
blocks are left in place rather than deleted.

---

## 5. Exercises

```latex
\supervision{\label{q:broadcast-strength}
    Prove that causal broadcast also satisfies the requirements of FIFO broadcast, and that
    FIFO-total order broadcast also satisfies the requirements of causal broadcast.
}{
    To prove that causal broadcast is stronger than FIFO broadcast, assume an execution of
    causal broadcast containing at least two broadcast messages $m_1$ and $m_2$.
    ...
}
```

* Argument 1 = the question (appears in the notes as "Exercise *N*"); argument 2 = the
  solution notes (appear only in `solutions.pdf`).
* `\label{q:...}` goes at the start of argument 1, and only if referenced elsewhere.
* Placed **in the prose flow**, immediately after the material they test — not collected at the
  end of a section.
* ~3 per lecture (range 1–9; 25 total). Aim for 2–4 per lecture.
* Question length: 1–4 sentences. Solutions are generous — often several paragraphs, an
  `itemize` of considerations, or a full code listing. Solutions teach; they are not answer keys.
* Where a question comes from a past paper, cite it inline:
  `[\href{https://www.cl.cam.ac.uk/teaching/exams/pastpapers/y2020p5q8.pdf}{2020 Paper 5 Question 8}]`
* Solution text may use `\autoref{q:...}` to refer to other exercises.

---

## 6. Diagrams (TikZ)

**All figures are drawn in TikZ in the source** (75 `tikzpicture` environments, 673 `\node`,
595 `\draw`). No external vector files. Diagrams live inside frames; the notes show them via
the embedded slide image.

### Shared styles (defined in `setup.tex`)

```latex
bigarrow        very thick, Classical TikZ Rightarrow, length 2mm   % a message
revbigarrow     same, reversed
doublebigarrow  double-headed                                      % bidirectional channel
messageloss     very thick, red "Rays" tip                         % a lost message
crash           red "Rays" tip                                     % a crashed node
leftloop / rightloop   self-loop for broadcast-to-self
op              white rectangle, rotate=270, \footnotesize          % client operation box
\storageSymbol  a small cylinder (a replica / database)
```

Colours: `darkblue` (0,0,0.7), `darkgreen` (0,0.7,0), `lightgrey` (0.95 grey).

### The recurring visual vocabulary

| Meaning | Encoding |
|---|---|
| a node / process / actor | `\node [rectangle,fill=red!10,draw]` |
| a passive resource (city, memory, target) | `\node [circle,fill=blue!10,draw]` or `fill=blue!10` rectangle |
| a container (one machine, a datacenter) | `\draw [black!50, fill=black!5] ... rectangle`, labelled `\node [black!50, anchor=north west, font=\scriptsize]` |
| time | flows **top to bottom**; each node has a vertical lifeline `\draw (node) -- (x,0);` |
| a message | `bigarrow` sloped downward, label `node [above,sloped] {…}` |
| a lost message | `messageloss` arrow stopping partway |
| an operation's duration | `op`-styled box on the lifeline |
| a state machine | `\node [circle,fill=lightgrey,draw,minimum width=2.1cm]`, edges `-Stealth,very thick` |
| a highlight / correction | `red` text plus a thick `-Stealth,red,line width=4pt` pointer |
| the "good" alternative | `darkgreen` arrow |
| an annotation on a diagram | `ellipse callout, callout relative pointer={(-1,-0.6)}, draw, fill=green!10` |
| a brace grouping table rows | `decorate,decoration={brace,amplitude=6pt}` over a `fit=` of the rows |
| a circle round a table cell | `draw,thick,ellipse,fit=(mark)` on a cell named by `mark:` |

**Brace direction is set by the path direction**, and the bulge is the direction of travel
rotated 90 degrees anticlockwise. Both cases were established by measuring the drawn path,
so take them as given: for a brace to the **right** of rows, draw **top to bottom**; for a
brace **under** a column, draw **right to left**. Draw them the other way and the brace
opens away from the content.

* Local styles are declared with `\tikzstyle{name}=[...]` **inside** the `tikzpicture` when
  only that figure needs them (`cpu`, `memory`, `machine`, `algo`, `transition`, `entry`).
* Canvas is roughly 9 units wide (matching the 9cm slide width used by `\inlineslide`); node
  x-coordinates are typically 0, 4, 8 for three nodes, or 0 and 8 for two.
* Diagrams are usually wrapped in `\begin{center}…\end{center}`; end the environment with `%`
  before following `\uncover` text to avoid a stray space.
* Overlay-aware drawing: `\draw<2->`, `\node<3>`, `\node<2->` — build the diagram up step by
  step in the same order the lecturer narrates it.
* To pin something to the whole page (a callout arrow onto a code listing, an annotation
  outside the text block): `\begin{tikzpicture}[remember picture,overlay]` with coordinates
  relative to `current page.center`.
* Full-bleed image: `\begin{frame}[plain]` +
  `\begin{tikzpicture}[remember picture,overlay] \node at (current page.center) {\includegraphics[height=\paperheight]{...}};`

### Diagram idioms specific to databases (adapt, don't invent)

The dist-sys vocabulary maps naturally: replicas → tables; message arrows → query/result
flow; the `op` box → a transaction's duration; the state machine style → an ER diagram or a
query plan. Keep the same colour semantics (red!10 for the active/agent thing, blue!10 for
the passive thing, black!5 for enclosures, green!10 for annotations).

---

## 7. Pseudocode

25 `algorithmic` blocks. `algorithm` + `algpseudocode` are loaded; `setup.tex` adds two custom
blocks that you must copy across (see §11):

```latex
\algblockdefx{On}{EndOn}[1]{\textbf{on} #1 \textbf{do}}{\textbf{end on}}
\algblockdefx{Periodically}{EndPeriodically}[1]{\textbf{periodically} #1 \textbf{do}}{\textbf{end do}}
```

Conventions:

* Pseudocode is **event-driven**: a sequence of `\On{...} ... \EndOn` handlers, starting with
  `\On{initialisation}` which declares all node state.
* `\State` alone on a line inserts a blank line between handlers.
* Frame starts with `\footnotesize` (and `[plain]` if it needs the full page).
* Assignment is `:=`. Multiple assignments on one line separated by `;\;`.
* Variables: `\mathit{sendSeq}`, `\mathit{delivered}` (636 uses of `\mathit`).
  Constants, message types, field names and enum values: `\mathsf{VoteRequest}`,
  `\mathsf{follower}`, `\mathsf{null}`, `\mathsf{true}`, `\mathsf{msg}`, `\mathsf{length}`
  (360 uses of `\mathsf`).
* Functions: `\Function`/`\EndFunction`, called with `\Call{ReplicateLog}{$args$}`; referred
  to in prose as `\textsc{ReplicateLog}`.
* Control flow: `\If`/`\ElsIf`/`\Else`/`\EndIf`, `\For{each $x \in S$}`, `\While{...}`.
  Short conditionals are inlined instead:
  `\State \textbf{if} $c$ \textbf{then} $x := 1$; \textbf{end if}`
* Sets `\{\}`, sequences/vectors `\langle 0,0,\dots,0 \rangle`, quorum size
  `\left\lceil (|\mathit{nodes}|+1)/2 \right\rceil`.
* Prose-level operations stay in words: `\State send $(i, \mathit{sendSeq}, m)$ via reliable broadcast`,
  `\State deliver $m$ to the application`, `\State start election timer`.
* A long algorithm is split across numbered slides with a descriptive subtitle each:
  `\frametitle{Raft (3/9): collecting votes}`, and the prose walks through them one by one.
  A comment block above the first slide records deviations from the published version.

---

## 8. Code listings

* `minted` (Pygments) only — 14 `\inputminted`, zero inline `minted` environments.
* **Listings live in separate files under `code/`**, one snippet per file, named
  `<topic>.<ext>` (`payment-rpc.java`, `payment-rpc.json`, `lamport-broadcast.js`).
  Do not inline code in `databases.tex`.
* Plain: `\inputminted{java}{code/payment-rpc.java}`
* Dense: `\inputminted[fontsize=\scriptsize]{protobuf}{code/payment-rpc.proto}`
* Boxed data (e.g. a JSON message inside a diagram):
  `\inputminted[fontsize=\scriptsize,frame=single,bgcolor=lightgrey]{json}{code/payment-rpc.json}`
* Snippets are **short** (10–20 lines), heavily elided (`/*...*/`), and written to be read
  aloud. Comments inside the snippet do the teaching.
* For SQL/Cypher/Datalog in the databases course, use lexers `sql`, `cypher`, `prolog`
  (Datalog has no dedicated Pygments lexer; `prolog` renders it well).
* Because `_minted-*/` caching is used, commit the generated `_minted-*` directories if you
  want the document to build without Pygments (see the comment in `setup.tex`).

### Inline code: use `\code{...}`

Identifiers and code fragments in prose and on slides go in `\code{...}`, defined in
`setup.tex` as `\texttt{\detokenize{#1}}`. It takes its argument **literally**, so write
`\code{has_genre}`, never `\texttt{has\_genre}`:

```latex
The primary key of \code{has_position} is \code{(movie_id, person_id, position)}.
```

Why not the obvious alternatives:

* **`\texttt{a\_b}`** — renders identically (see below), but needs escaping and reads badly
  in the source. dist-sys used it (77 uses) because it had few underscores; a database
  course is full of them.
* **`\verb|a_b|`** — the appearance is right, but it **fails inside a beamer frame**
  (beamer re-reads frame bodies to build overlays, which destroys verbatim's catcodes; the
  frame would need `\begin{frame}[fragile]`). It also cannot appear inside the argument of
  any other command — not `\sbox`, not a `\node` label, not a table cell macro.

`\code` has neither problem. Its limits: braces inside must balance, and it cannot contain
another command, since the argument is detokenised. So the rare case that mixes code and
markup stays `\texttt`, e.g. `\texttt{PRIMARY KEY (\dots)}` — one such in `databases.tex`.

**The underscore glyph, and why the document uses T1.** `setup.tex` loads
`\usepackage[T1]{fontenc}` with `\usepackage{lmodern}`, and the reason is underscores.

Under OT1, the text fonts have **no underscore glyph**. Slot 95 holds a dot accent instead
(cmss: 2.78pt wide, 6.79pt high, zero depth — it sits *above* the baseline), so LaTeX draws
`\_` as a rule, `\kern.06em\vbox{\hrule width.3em}`. Measured with a descender-free string
`\textbf{A\_B}`, OT1 gives depth **0.0pt** in roman, sans and typewriter alike: the rule
never descends below the baseline, which is exactly why it looked wrong. Only the OT1
*typewriter* font has a real underscore in the font, at 5.25pt — which is why `\verb` and
minted looked right while `\texttt{has\_genre}` did not.

T1 has a real underscore in every family. The same test gives depth 2.33pt in sans-bold,
2.40pt in typewriter and 1.63pt in roman — glyphs that properly descend. That fixes the
bold table names in the schema diagram too, which a monospace-only workaround could not,
since no amount of redefinition can conjure a glyph the OT1 font does not contain.

`lmodern` supplies T1-encoded Type 1 outlines; without it, T1 falls back to bitmapped EC
fonts, which look poor on screen and bloat the PDF. Latin Modern is metrically identical to
Computer Modern for this document: after the switch the table on `s:moviedb-tables` measured
258.46pt, exactly as before, the row pitch stayed 15.60pt, the brace geometry was unchanged
to the last decimal, and all four PDFs kept their page counts (28/11/6/2) with no overfull
boxes. If a build ever shows bitmapped fonts, `lmodern` is missing, not `fontenc`.

So `\code` is a **source-readability** convention, not a rendering fix: `\texttt{has\_genre}`
now looks just as good. Prefer `\code` because the source is easier to read and write.

**Generated tables keep `\texttt`.** `examples/render.py` wraps `tt:` columns in
`\texttt{}` and escapes the content (§11). Do not "fix" that to `\code`: the values come
from the database and may contain braces, backslashes or percent signs, which escaping
handles safely and `\detokenize` would not. The rendered result is identical either way.

---

## 9. Tables

12 tables, all on slides, all following one of two shapes.

**Comparison table** (two columns, `p{5cm}` each, header row in bold, zebra striping,
progressive reveal):

```latex
\rowcolors[]{2}{}{blue!10}
\renewcommand{\arraystretch}{1.3}
\begin{tabular}{p{5cm}|p{5cm}}
    \hline
    \textbf{shared memory} & \textbf{distributed system} \\\hline
    hardware fails \newline$\Rightarrow$ all threads stop & one machine fails \newline$\Rightarrow$ others continue running \pause\\
    reliable communication\newline between CPU cores & unreliable network \pause\\
    ...
\end{tabular}
```

**Truth/outcome table** (centred columns):

```latex
\begin{tabular}{c|c|c}
    \hline
    \textbf{army 1} & \textbf{army 2} & \textbf{outcome} \\\hline
    does not attack & does not attack & nothing happens \\
    ...\\\hline
\end{tabular}
```

Notes:
* `\rowcolors[]{2}{}{blue!10}` (needs the `xcolor={table}` class option, already set) shades
  alternate rows starting from row 2. Re-issue it before each table.
* `\renewcommand{\arraystretch}{1.3}` for breathing room.
* `\hline` at top, after the header, and at the bottom — no interior rules.
* `\newline` inside a `p{}` cell for a manual line break.
* `\pause` at the end of a row (before `\\`) reveals row by row.
* Ragged-right paragraph columns: `>{\raggedright}p{5cm}|>{\raggedright\arraybackslash}p{5cm}`
  (note `\arraybackslash` on the last column only).

---

## 10. Notation, typography, citations, images

### Mathematical notation

* Variables and identifiers: `\mathit{}`. Literals, constructors, operation and message names:
  `\mathsf{}`. This distinction is used consistently — respect it.
* Nodes are `$A$`, `$B$`, `$C$` or `$N_i$`; messages `$m_1$, $m_2$`; timestamps `$t_1$`.
* Happens-before `\rightarrow` (101 uses); concurrency `\parallel`; ordering `\prec`;
  implication `\Longrightarrow`; `\sqcup` for join/merge; `\vdash`/`\dashv` for interval bounds.
* Operations are typeset as `$\mathsf{set}(x,v_1)$` and `$\mathsf{get}(x) \rightarrow v_1$`.
* No numbered equations at all: zero `equation`/`align` environments. Maths is inline or
  displayed as part of a slide line.

### Typography

* Quotation marks: LaTeX style ``` ``like this'' ``` (140 uses). Used for scare-quoted or
  informally-defined terms: ``consistent'', ``reliable'', ``five nines''.
* First introduction of a technical term: `\emph{}`. Slides use `\textbf{}` for the same job.
  **This split is near-absolute: 256 `\emph` vs 13 `\textbf` in the prose; 303 `\textbf` vs 15
  `\emph` inside frames.** Never bold prose; never italicise a slide keyword.
* `e.g.\ ` and `i.e.\ ` — always with the trailing `\ ` to keep the inter-word space
  (34 and 15 uses). Likewise `Dr.\ `, `Andrew S.\ Tanenbaum`, `etc.\ `.
* Em-dash aside: `~--` (thin space + en-dash), e.g.
  `the network protocols, informally known as the \emph{bytes on the wire}~-- because…`
* Ellipsis: `\dots`, never `...`.
* Units: `100~ms`, `50~TB`, non-breaking space before the unit.
* `{\textsterling}3.99`, `\textdegree` via `textcomp`.
* URLs: `\url{...}` for bare links, `\href{url}{text}` for anchored ones. `\urlstyle{sf}`.
  Links render `darkblue` (set via `hyperref` options in `setup.tex`).
* Emoji are included as PDF images at text size:
  `\raisebox{-2pt}{\includegraphics[height=12pt]{images/1f62d.pdf}}` — file named after the
  Unicode codepoint. `\thumbsup` is a shorthand for one such.
* `\hyphenation{...}` in `setup.tex` for words LaTeX breaks badly.

### Citations

* `natbib` + `plainnat`, `\bibliography{references}` at the end of the content file, preceded by
  `\footnotesize`.
* `\citep{Lamport:1982}` in prose (33 uses) — "these are given in square brackets" per the
  notes' own explanation to students. `\citet{Codd1970}` when the authors are the sentence
  subject (2 uses).
* **Citations appear in prose only, never on slides** (33 `\citep` in prose, 0 inside frames).
  Slides put a bare URL in `\scriptsize` under the figure instead.
* Keys are `Surname:Year` + optional suffix (`Dwork:1988dr`, `Waldo:1994wx`, `Codd1970`).
* Entries include `doi` and/or a `url` to a freely readable copy; a `%`-comment above the entry
  often records where the PDF was found. 34 entries for 8 lectures.
* The notes tell students explicitly that references are non-examinable background.

### Images

* `images/` holds photos (`.jpg`), screenshots (`.png`), and emoji/icons (`.pdf`).
* **Provenance is recorded in a `%`-comment** next to the `\includegraphics`, or the source URL
  is printed on the slide in `\scriptsize\url{...}`. Licence-clean sources only (Wikimedia
  public domain, Pixabay royalty-free, vendor docs) — the whole work is CC BY-SA.
* Sizing: `height=5cm` / `width=4cm` for inline figures, `height=\paperheight` for full-bleed,
  `width=\textwidth` inside a `column`.
* Photos are used generously to break up theory — a quartz crystal, a shark-bitten cable, an
  atomic clock. They earn their place by being memorable, not decorative.

### Two-column slides

```latex
\begin{columns}
    \begin{column}{0.5\textwidth}
        \begin{itemize} \item ... \end{itemize}
    \end{column}
    \begin{column}{0.5\textwidth}
        \includegraphics[width=\textwidth]{images/quartz-crystal.jpg}\\[1em]
        \scriptsize\url{https://...}
    \end{column}
\end{columns}
```

Splits: `0.5/0.5`, `0.4/0.6`, `0.2/0.75`. Used for text-beside-photo and
diagram-beside-commentary (the latter with `\item<n->` reveals synchronised to the diagram).

---

## 11. Data derived from the example database

The course uses one example database of movies (`moviedb-2025/movies.sqlite`, built by
`moviedb-generator/make_databases.py`). Its **contents change every year; its schema does
not.** That split decides where a fact belongs:

* **Schema-derived** — the `s:moviedb-schema` diagram, the `CREATE TABLE` listings in
  `code/movies-*.sql`, the primary keys on `s:moviedb-shapes`. **Hard-code these in
  `databases.tex`.** They are stable, and drawing them from a live database would add
  machinery for nothing.
* **Content-derived** — row counts, averages, distinct column values, any actual rows shown
  as an example. **Never hard-code these.** Every one goes through `examples/`.

### How the pipeline works

One query per file in `examples/*.sql`. `examples/render.py` runs it and writes a LaTeX
fragment beside it:

```
python3 examples/render.py moviedb-2025/movies.sqlite examples/kid-movies.sql
   -> examples/kid-movies.tex
```

`databases.tex` pulls the fragment in with `\input{examples/kid-movies.tex}` at the point
where the result is shown. The `Makefile` renders all of them (`make examples`), the PDFs
depend on them, and `make refresh` re-runs every query from scratch.

**Refreshing for a new year:**

```bash
make refresh MOVIEDB=moviedb-2027/movies.sqlite
git diff examples/          # review exactly what changed in the data
make
```

The generated `examples/*.tex` **are committed** — `.gitignore` excludes `/moviedb-2025`, so
without them nobody could build the PDFs from a fresh clone. Committing them also makes
`git diff examples/` the yearly review step.

### Formatting directives

Set with `-- key: value` comments at the top of the `.sql` file. Full list in the
`examples/render.py` docstring; the ones that matter in practice:

| Directive | Effect |
|---|---|
| `format: table` | a complete `tabular` (default for multi-cell results) |
| `format: scalar` | just the value, for `\input` inline in a sentence (default for 1×1) |
| `format: list` | comma-separated inline list, with `conjunction: or` |
| `format: macros` | `\newcommand`s from a (name, value) result, named with `prefix:` |
| `tt: col, col` | wrap those columns in `\texttt{}` |
| `thousands: col` | group digits — **opt-in per column**, so years stay `1921`, not `1,921` |
| `align: llrlr` | override the default (`r` for numeric columns, `l` otherwise) |
| `maxrows: 6` | truncate, adding a row of `$\vdots$`, so a slide cannot silently overflow |
| `mark: col=pfx` | wrap that column's cells in `\tikzmarknode`, naming the header `pfx0` and the data rows `pfx1` upwards, so an overlay can draw on them |
| `allow-empty: yes` | permit an empty result |

### Rules when adding an example

1. **`ORDER BY` in every multi-row query.** Without it, row order can shift between database
   builds and produce spurious diffs. `render.py` warns if it is missing.
2. **Select by natural predicate, not by ID**: `WHERE title = 'The Kid' AND year = 1921`,
   not `WHERE movie_id = 'tt0012349'`. IMDb keys are stable in practice, but the predicate
   also documents what the query is for.
3. **An empty result is an error.** `render.py` exits non-zero if a query returns nothing,
   so a dropped movie or renamed person fails the build instead of silently emptying a slide.
4. **No LaTeX inside the `.sql`.** The renderer escapes everything it reads from the database
   (`&` → `\&`, `%` → `\%`, …), so markup written into a query would be escaped too. Put the
   markup in `databases.tex`: `\input{examples/null-jobs.tex}\%`.
5. **Rounding for prose belongs in SQL**, where it is visible: `count(*) / 100 * 100` gives
   the "roughly 2,900 movies" figure in `examples/db-approx.sql`.
6. **`mark:` couples the slide to the query's row order.** The overlay refers to cells by
   index (`fkm3` is the third data row), so a changed `ORDER BY` — or next year's data —
   can silently move a circle onto the wrong value. Where a slide joins equal values, pin
   the rows with an explicit `WHERE ... IN (...)`, choose an `ORDER BY` that puts the
   linked values on the facing edges of adjacent tables, and say so in a comment in the
   `.sql`. Prefixes are global TeX node names, so give each slide its own (`pkm`, `fkm`)
   even when two slides show the same rows.
7. Prefer `format: macros` for a family of related numbers (all seven row counts come from
   one `table-sizes.sql`), so editorial text such as the "one row per…" column stays in
   `databases.tex` where it can be edited.

### Terminology

The course says **movie**, not *film*, matching the example database's `movies` table. This
is the one deliberate Americanism in otherwise British-English prose; consistency with the
schema students are querying wins.

---

## 12. Gaps in the current `/workspace` scaffold

The scaffold is a faithful copy of `dist-sys/`, but three things need attention before writing
content:

1. **`setup.tex` is missing the tail of the dist-sys version.** Copy these across if you use
   pseudocode, storage symbols, or emoji:
   * `\algblockdefx{On}{EndOn}` and `\algblockdefx{Periodically}{EndPeriodically}`
     — *required* by every pseudocode block.
   * `\newcommand{\storageSymbol}` — the database/replica cylinder.
   * `\newcommand{\thumbsup}` and the `\hyphenation{...}` line.
2. **`databases.tex` title frame still says** "The second half of \emph{Concurrent and
   Distributed Systems}" — a leftover from dist-sys. Databases is a Part IA course in its own
   right; replace that line.
3. **`images/` contains only `creative-commons.png`.** (`code/` now exists, holding the
   extracted `CREATE TABLE` listings.)

Also note `Makefile` has no `examples1.pdf` target (dist-sys had an examples-class handout,
`examples1.tex`, written in a much looser standalone style — a plain `article` with `minted`
blocks and `\parskip` set. Follow that looser style only if an equivalent handout is wanted;
it is explicitly *not* the style of the slides and notes.)

---

## 13. Checklist for a new lecture

1. `\section{Title}\label{sec:slug}` + unlabelled `\Large darkblue` opener frame (no
   `\inlineslide`).
2. 2–5 `\subsection`s, each labelled `sec:`.
3. ~20 frames, ~4,000 words of prose, 2–4 `\supervision` exercises interleaved.
4. Open with a concrete, everyday motivating example before any formalism.
5. Every frame: `\label{s:…}` first line, `\frametitle` second, `\inlineslide{s:…}{}` right
   after `\end{frame}`, plus `\label{l:…}` if cross-referenced.
6. Prose: one sentence per line, blank line between paragraphs, British spelling, `\emph` for
   new terms, `\autoref` for every cross-reference.
7. Diagrams in TikZ using the shared styles and the colour vocabulary; build them up with
   `<n->` overlays; add `handout:0` to any element that shouldn't survive into the notes.
8. Code snippets as separate files in `code/`, pulled in with `\inputminted`; identifiers
   inline in prose or on a slide in `\code{...}`, written literally (§10).
9. Any number or example row that comes from the example database goes through
   `examples/*.sql` + `\input` (§11), never typed into `databases.tex` by hand.
10. New references into `references.bib` with a DOI and a free-to-read URL; cite with `\citep`
   in prose only.
11. Record image provenance in a comment or on the slide.
12. Leave `%`-comments for TODOs, rejected ideas, and the derivation of any computed numbers.
13. Close the final lecture with `\subsection{Wrapping up}`, a summary slide, and a few
    reflective closing paragraphs.
14. `make` and check all four PDFs; the notes need the handout built first.
