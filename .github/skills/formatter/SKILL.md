---
name: formatter
description: Inspect rendered manuscript pages and correct LaTeX layout within the venue's template rules. Use for overflow, unreadable figures, float placement, whitespace, widows/orphans, or page-limit compliance.
---

# Formatter

Improve presentation without changing scientific content or circumventing venue
requirements. A shorter PDF is not compliant if its fonts, margins, or spacing
violate the template.

## 1. Establish the Constraints

Read the CFP and template guidance. Record allowed font sizes, margins, column
layout, package restrictions, and the page-count rule, including whether
references and appendices count. Do not invent a minimum length or pad a short
paper simply to approach the maximum.

Coordinate exclusive ownership of the affected `.tex` files. Do not edit while
the writer, referencer, humanizer, or anonymizer is changing them.

## 2. Obtain Current Page Images

Use `compiler` if sources changed or no verified build is available. Run helper
commands from the repository root:

```bash
.github/skills/compiler/scripts/build-pdf.sh papers/<name> main.tex
```

Read `output/pages/pages.json` inside the paper directory. Check that the PDF
hash matches the inspected artifact and that all expected images are present.
Rendering with `--pages-only` does not establish that the PDF reflects current
LaTeX sources. Never infer freshness from file existence alone.

## 3. Inspect at Publication Size

Inspect every page of the final artifact when image tools are available:

- Content or tables extending outside columns/margins.
- Clipped, overlapping, or illegible figure text and legends.
- Widows/orphans, stranded headings, and nearly empty final pages.
- Float placement relative to the first reference.
- Unexplained whitespace and inappropriate column balancing.
- Captions, equations, and references with inconsistent formatting.

If images cannot be inspected, report a source/log-only assessment. Do not claim
visual verification from a page count or successful compilation.

## 4. Apply Permitted Fixes

Prefer local, template-compatible changes:

- Reflow tables using appropriate column types, wrapping, or `tabularx` where
  allowed; do not shrink table text below the venue's minimum.
- Choose sensible float placement within the class's rules.
- Remove accidental blank lines, forced breaks, or redundant spacing commands.
- Adjust a figure's size only while its labels remain readable at final width.
- Use `microtype`, widow/orphan controls, or balancing tools only when compatible
  with the class and permitted by the venue.

Do **not** change margins, reduce mandated body/caption fonts, compress line or
section spacing, add negative `\vspace`, or use `\enlargethispage` to evade a page
limit. Do not add `caption`, `subcaption`, or `titlesec` blindly to a class that
controls those features. The [snippet reference](templates/formatting-fixes.tex)
is opt-in guidance, not a preamble to import wholesale.

If approved layout changes cannot solve a problem, escalate for content cuts or
figure regeneration rather than distorting the template or removing evidence.

## 5. Rebuild and Confirm

After edits, recompile and inspect the changed pages and affected downstream
pages. Finish with a full visual pass on the final version. Stop after two
unsuccessful layout/content round-trips and report remaining issues; do not
launch another formatter merely because a compiler was run.

## Output

Report changes, the final artifact inspected, total PDF pages, counted pages
under the CFP rule, visual-inspection coverage, and remaining limitations.
Use these escalation flags when applicable:

```text
NEEDS_CONTENT_CUT: true/false
NEEDS_CONTENT_EXPANSION: true/false
NEEDS_REWRITE: true/false
NEEDS_FIGURE_REGEN: true/false
```

For each true flag, give exact section/figure locations and an actionable
description. Expansion is justified only by a genuine content gap or an explicit
minimum, not cosmetic page filling. Do not perform substantive rewrites yourself.
