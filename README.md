# Academic Research Paper Writing Toolkit

A suite of GitHub Copilot custom agents and skills for academic paper writing workflows.

## Overview

This repository provides AI-powered personas that collaborate to help you write, review, and publish academic papers. Papers live in the `papers/` directory, each in its own subfolder.

## Quick Start

The typical workflow from idea to submission:

```
/plan              → jot down rough ideas (creates session plan.md)
@idea-coach        → refine ideas via Socratic questioning + novelty check (writes papers/<name>/plan.md)
@paper papers/name → full pipeline: research → draft → write → polish → compile → review
```

Each step is optional — skip ahead if you already have what you need.

### Starting from scratch

Use `/plan` to sketch rough notes, then hand off to `@idea-coach`. The idea coach asks probing questions, runs a gap analysis against existing literature, and writes a structured `plan.md` to the paper directory.

### Starting from an existing idea

Create the paper directory with optional context files:

```
papers/my-paper/
├── cfp.md            # (optional) Call for Papers text
├── review-guide.md   # (optional) Reviewer guidelines
└── plan.md           # (optional) Paper plan / outline notes
```

Then run `@paper papers/my-paper` — it picks up whatever exists and starts at the right stage.

### Working on an existing paper

```
@paper papers/my-paper — Polish this for submission. Double-blind.
@paper papers/my-paper — Just review against the CFP.
@paper papers/my-paper — Fix the formatting — we're 1 page over the limit.
```

## Pipeline

The `@paper` orchestrator drives the full pipeline automatically:

```
@paper (orchestrator)
  ├─ Stage 1:  @researcher    → literature survey and gap analysis
  ├─ Stage 2:  @drafter       → structured LaTeX draft with sections
  ├─ Stage 3:  @writer        → full paper matching CFP requirements
  ├─ Stage 4:  referencer      → complete and validate all citations   ┐
  ├─ Stage 5:  humanizer       → naturalize prose                      ├─ parallel
  ├─          @illustrator    → generate/refine figures                ┘
  ├─ Stage 6:  anonymizer      → strip identity (if blind review)
  ├─ Stage 7:  compiler        → build PDF + render page images
  ├─ Stage 8:  formatter       → visual inspection + layout fixes
  ├─ Stage 9:  @reviewer       → self-review against CFP
  └─ Stage 10: fix & iterate   → loop back until submission-ready
```

Prerequisite: a `plan.md` must exist in the paper directory (use `@idea-coach` to create one).

Stages 4, 5, and illustration run in parallel — they touch different files (`.bib`, prose, `figures/*.svg`). The orchestrator detects what already exists and skips completed stages.

## Agents

Invoke directly in Copilot chat via `@agent-name`:

| Agent | What it does |
|-------|-------------|
| `@paper` | **Full pipeline orchestrator** — drives all 10 stages from plan to submission |
| `@idea-coach` | Brainstorm and refine research ideas with Socratic questioning and literature gap checks |
| `@researcher` | Literature survey, gap analysis, citation graphs, research positioning |
| `@drafter` | Create a structured paper draft with section outlines and reference placeholders |
| `@writer` | Produce a full paper from a draft + CFP, orchestrating supporting skills |
| `@reviewer` | Review a paper against CFP criteria with citation verification and visual inspection |
| `@illustrator` | Generate publication-quality vector figures and diagrams as SVG |

## Skills

Supporting capabilities invoked by agents or on-demand by the user:

| Skill | What it does |
|-------|-------------|
| `referencer` | Search for relevant papers, validate citations, manage BibTeX entries (Google Scholar + Paper Search MCPs) |
| `gap-analysis` | Novelty checks, coverage gap detection, and positioning analysis against existing literature |
| `research` | Quick reference landscape analysis (lightweight; full research via `@researcher` agent) |
| `compiler` | Build PDF from LaTeX + render page images using Docker (texlive + latexmk + biber) |
| `svg-renderer` | Convert SVG figures to PNG previews and LaTeX-ready PDF files |
| `formatter` | Visually inspect rendered pages and fix layout — resize tables/figures, fix whitespace, eliminate widows/orphans |
| `anonymizer` | Strip author names, self-citations, and acknowledgments for blind review |
| `humanizer` | 3-pass prose naturalization: mechanical fixes → structural variation → voice calibration |
| `statistician` | Hypothesis testing, effect sizes, power analysis using Python/scipy in Docker |
| `data-processor` | Data cleaning, transformation, descriptive statistics using Python/pandas in Docker |

## Prerequisites

- **Docker** — required for compilation, statistics, and data processing
- **Node.js** — required for the Google Scholar MCP server (`npx`)
- **Python 3.10+ / uv** — required for the Paper Search MCP server (`uvx`). Install [uv](https://docs.astral.sh/uv/getting-started/installation/) if not present.

## Setup

Build the Docker image once:

```bash
docker build -t research-latex .
```

### MCP Server Setup

The `.mcp.json` (and `.vscode/mcp.json`) configures two paper search MCP servers:

| Server | Command | Sources |
|--------|---------|---------|
| `paper-search` | `npx paper-search-mcp-nodejs` | arXiv, PubMed, Google Scholar, Web of Science, Scopus, ScienceDirect, Springer, Wiley, CrossRef, and [more](https://github.com/Dianel555/paper-search-mcp-nodejs) |
| `paper-search-py` | `npx @smithery/cli run @openags/paper-search-mcp` | arXiv, PubMed, Semantic Scholar, CrossRef, OpenAlex, CORE, dblp, Zenodo, HAL, SSRN, and [more](https://github.com/openags/paper-search-mcp) |

Optional API keys can be added to `paper-search-py` env vars in `.mcp.json` for better rate limits. All sources work without keys by default.

## Paper Directory Structure

Each paper lives in its own directory under `papers/`:

```
papers/my-paper/
├── main.tex          # Main LaTeX document
├── references.bib    # Bibliography
├── sections/         # Individual sections (optional)
├── figures/          # Figures and images
├── tables/           # Table data or LaTeX table files
├── output/           # Compiled PDF output
├── cfp.md            # (optional) Call for Papers — parsed by @writer and @reviewer
├── review-guide.md   # (optional) Reviewer guidelines — used by @reviewer
└── plan.md           # (optional) Paper plan/outline — written by @idea-coach, used by @drafter
```

## Repository Structure

```
research/
├── .github/
│   ├── agents/                        # Custom Copilot agents
│   ├── skills/                        # Supporting skills
│   └── copilot-instructions.md        # Shared context for all personas
├── papers/                            # Paper directories
│   └── self/                          # Position paper about this toolkit
├── Dockerfile                         # Alpine-based build container (LaTeX + Python)
└── .mcp.json                          # MCP server configuration
```

## Extending

### Adding Papers

Create a new directory under `papers/` and optionally add `cfp.md`, `review-guide.md`, or `plan.md` before invoking agents.

### Adding MCP Servers

Add to `.mcp.json` and update the `referencer` skill's `mcp-servers` field.

### New Skills

Create a new directory under `.github/skills/` with a `SKILL.md` file. Follow the existing skills as examples.

## License

TBD
