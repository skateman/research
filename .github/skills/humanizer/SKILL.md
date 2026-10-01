---
name: humanizer
description: Edit academic prose for clarity, natural rhythm, and the author's voice. Use for polishing repetitive or formulaic writing without altering evidence, technical meaning, citations, or required AI-use disclosures.
---

# Humanizer

Improve readability, not perceived authorship. Word choice cannot establish
whether text was AI-generated; do not promise detector evasion, an "AI-free"
score, or that a reviewer cannot distinguish the authoring process.

## Before Editing

- Read the assigned passages, nearby context, and venue/style requirements.
  Respect the manuscript's language; do not translate unless requested.
- Agree on file ownership with the caller. Reference editing, rewriting,
  anonymization, and formatting can all modify the same `.tex` files, even when
  they target different sentences or commands. Do not run them concurrently.
- Preserve the author's argument and register. Make no change when the existing
  wording is already precise and readable.

## Pass 1: Clarity

Remove empty framing such as "It is worth noting that" when it adds no meaning.
Prefer direct verbs over unnecessary nominalizations and specify a mechanism
instead of vague praise.

Treat words such as "robust", "significant", "novel", "landscape", and "paradigm"
as **context-dependent**, not banned words. They may be technical terms or part
of a quotation. Clarify an unqualified claim only from evidence already present;
otherwise flag it for the author instead of inventing a measurement or citation.

Keep epistemic qualifications that reflect the evidence: changing "may",
"suggests", "is associated with", or "in this sample" can materially overstate a
finding. Do not convert association into causation.

## Pass 2: Structure

- Give paragraphs a clear main point and a logical connection to the argument.
- Split overloaded sentences; combine choppy ones when the ideas belong together.
- Vary repetitive openings and transitions where it improves flow, not to satisfy
  sentence-length quotas or a prescribed number of items in a list.
- Preserve genuine contribution lists and disciplinary conventions.
- Avoid forced fragments, contractions, informality, or rhetorical flourishes
  when they do not match the author's voice or venue.

## Pass 3: Voice

Prefer the author's specific observations to generic commentary. Use existing
examples, results, and terminology consistently. Never add a plausible-sounding
failed experiment, numerical result, personal experience, or methodological
detail merely to make the writing feel natural.

Keep required AI-use disclosures and attribution. Flag substantive uncertainties
for the author rather than editing them away.

## Protected Content

Do not change:

- Direct quotations or their attribution.
- Numbers, units, effect directions, statistical results, mathematical statements,
  hypotheses, or the scope of a claim.
- Citation commands/keys, labels, cross-references, URLs, bibliography records,
  macros, package declarations, or document structure.
- Math, code, algorithms, tables, and verbatim environments.

If improving a passage requires one of these changes, report it for the relevant
specialist instead. A grammar edit around a citation must preserve what that
citation supports.

## Verification and Output

Review the diff, not just the resulting prose. Confirm that protected content is
unchanged and that no evidence or qualifications were lost. Pattern searches may
locate repetitive phrasing, but neither zero matches nor a lower word count is a
quality criterion. Avoid blind regular-expression substitutions across LaTeX.

Report the passages changed, the meaningful readability improvements, and any
substantive issues left for the author. Let the caller compile after all source
edits have landed; when working independently, use `compiler` if LaTeX changes
could affect the build.
