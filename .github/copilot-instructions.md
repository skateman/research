# Academic Research Paper Writing — Shared Context

You are part of a collaborative academic paper writing toolkit. All agents and skills in this repository share the following conventions and awareness.

## Academic Writing Conventions

- Use formal academic register throughout: precise terminology, hedged claims ("we observe that..." rather than "it is obvious that..."), and evidence-backed assertions
- Follow the IMRaD structure (Introduction, Methods, Results, and Discussion) unless the CFP or venue specifies otherwise
- Every claim should either be supported by a citation or clearly marked as a contribution of the current work
- Use active voice where possible ("We propose..." not "It is proposed that...")
- Avoid filler phrases: "It is worth noting that", "It goes without saying", "In today's world"
- Maintain consistent tense: present for established facts and general truths, past for describing experiments and results

## LaTeX Conventions

- Papers are written in LaTeX, typically compiled with `latexmk` and `biber`
- Use `\cite{}`, `\citet{}`, `\citep{}` for citations (natbib or biblatex style)
- BibTeX entries go in `.bib` files — always prefer DOI-resolvable entries
- Use `\label{}` and `\ref{}` / `\cref{}` for cross-references
- Figures: `\includegraphics` within `figure` environment, always with `\caption` and `\label`. Figures are generated as SVG by the **@illustrator** agent and converted to PDF for inclusion — never write TikZ, PGFPlots, or other inline drawing code in `.tex` files
- Tables: prefer `booktabs` style (`\toprule`, `\midrule`, `\bottomrule`)

## Cross-Persona Awareness

The following agents and skills work together. When delegating or suggesting next steps, reference the appropriate persona:

### Agents (user-facing)
- **@idea-coach** — brainstorming and idea refinement
- **@researcher** — literature survey, gap analysis, research positioning
- **@drafter** — structured draft creation
- **@writer** — full paper production from draft + CFP
- **@reviewer** — paper review against CFP criteria
- **@illustrator** — vector figure generation with visual feedback loop

### Skills (supporting)
- **referencer** — citation search and validation (Google Scholar)
- **compiler** — LaTeX → PDF compilation (Docker)
- **svg-renderer** — SVG → PNG preview / PDF conversion for figures
- **formatter** — layout and typographic adjustments
- **anonymizer** — blind review anonymization
- **humanizer** — prose naturalization
- **research** — quick reference landscape analysis (lightweight; full research via @researcher agent)
- **gap-analysis** — novelty checks, coverage gaps, and positioning analysis
- **statistician** — hypothesis testing, effect sizes, power analysis (Python/scipy in Docker)
- **data-processor** — data cleaning, transformation, descriptive statistics (Python/pandas in Docker)

## Paper Repository Structure

All papers live under the `papers/` directory, each in its own subfolder:
```
papers/
└── my-paper/
    ├── main.tex          # Main LaTeX document
    ├── references.bib    # Bibliography
    ├── sections/         # Individual sections (optional)
    ├── figures/          # Figures and images
    ├── tables/           # Table data or LaTeX table files
    ├── output/           # Compiled PDF output
    ├── cfp.md            # (optional) Call for Papers text or link
    ├── review-guide.md   # (optional) Reviewer guidelines
    └── plan.md           # (optional) Paper plan / outline notes
```

The optional markdown files provide context to agents:
- **cfp.md** — the CFP text (or a link). Used by @writer and @reviewer to align with venue requirements.
- **review-guide.md** — reviewer instructions or rubric. Used by @reviewer for structured evaluation.
- **plan.md** — working notes, outline, or scope decisions. Used by @drafter and @writer.

When working on a paper, agents receive the paper directory path (e.g., `papers/my-paper`) and all paths in scripts and LaTeX are relative to that directory.

## Paper Planning Workflow

The recommended flow from idea to submission-ready paper:

1. **`/plan`** — Use plan mode to jot down rough ideas, topic keywords, or bullet points. This creates a `plan.md` in the session workspace.
2. **`@idea-coach`** — Hand off to the idea coach. It reads the session `plan.md` as a starting point and refines the ideas through Socratic questioning. Once done, it writes a structured `plan.md` to the paper directory (e.g., `papers/my-paper/plan.md`).
3. **`@paper`** — The orchestrator picks up `plan.md` from the paper directory and drives the full pipeline (research → draft → write → polish → compile → review).

Each step is optional — if you already have a structured plan, go straight to `@paper`. If you want to brainstorm without `/plan` first, invoke `@idea-coach` directly with your raw notes.

## Quality Standards

- No orphaned sections (sections with only one paragraph)
- No widow/orphan lines (single lines stranded at page top/bottom)
- All figures and tables must be referenced in the text
- All citations in the text must exist in the bibliography, and vice versa
- Page limits from the CFP must be respected
