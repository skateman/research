---
description: Academic prose, citations, LaTeX, and submission requirements for manuscript source files.
applyTo: "papers/**/*.tex,papers/**/*.bib"
---

# Manuscript Conventions

- Use the manuscript's language and formal disciplinary register. Follow IMRaD
  when appropriate; surveys, position papers, legal scholarship, and venue
  templates may require a different structure.
- State a clear main point for each paragraph and connect it to the argument.
  Prefer precise, direct prose without filler. Preserve justified qualifications,
  technical terms, quotations, numbers, units, and statistical interpretations.
- Use present tense for established knowledge and past tense for completed
  experiments. Proposals and planned analyses must not read as completed work.
- Support external factual claims with appropriate evidence. A declared
  contribution still needs the actual methodology/results that substantiate it.
- Preserve citation package and style: natbib and biblatex use different
  commands/backends. Keep BibTeX keys stable; prefer verified DOI records where
  available and suitable identifiers for books, software, standards, and data.
- Check citation commands across included sources, including `\nocite`, and
  respect bibliography `crossref`/`xdata` relationships. Flag unused entries;
  do not automatically remove shared or intentionally retained references.
- Use `% TODO: source needed for ...` or `% FIGURE: ...` comments for unresolved
  work. Do not fabricate references or add broken `\includegraphics` targets to
  a draft that is meant to compile.
- Use the supplied document class, engine, margins, fonts, and citation backend.
  Do not impose IEEE formatting on an unspecified or unrelated venue.
- Use `\label` and `\ref`/`\cref` consistently. Figures and tables need captions,
  labels, and textual references; prefer `booktabs` where the template permits it.
- Create publication figures as SVG through Illustrator, then convert to PDF.
  Reproducible statistical plotting may export SVG first. Do not add TikZ or
  PGFPlots drawings to `.tex` sources.
- Inspect figures and tables at actual publication size. Resolve overflow,
  widows/orphans, stranded headings, and poor float placement where feasible
  without changing the venue's required typography.
- Apply the CFP's page-count rule, including references/appendices as specified.
  Shorten content rather than shrinking mandated fonts, margins, or spacing.
  Do not pad a paper to reach an invented minimum.
- Anonymize authors only when the confirmed policy requires it, reversibly.
  Keep real self-citations in third person unless the venue explicitly requires
  masking. Exclude identifying logs/backups from submission artifacts.
- Keep required AI-use disclosures and attribution. Prose polishing must not
  disguise missing evidence or promise detector evasion.
