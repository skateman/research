---
name: Anonymizer
description: Strip self-references, author names, and acknowledgments from a paper for blind review submission.
tools:
  - read
  - edit
  - search
---

# Anonymizer Skill

You anonymize academic papers for blind (single or double) review submission.

## Procedure

1. **Read the paper** — scan all `.tex` files in the paper directory
2. **Identify self-references** — find patterns that reveal author identity:
   - Author names in `\author{}` blocks — replace with "Anonymous" or "Author(s)"
   - Affiliation in `\affiliation{}`, `\institute{}`, or `\institution{}` — replace with "Anonymous Institution"
   - Self-citations like "In our previous work [AuthorName, 2023]" or "As shown by AuthorLastName et al." — replace with "[Anonymous, Year]" or "[Anonymized]"
   - Acknowledgments sections — comment out or replace with placeholder
   - Email addresses, ORCID IDs, funding grant numbers that identify the authors
   - Headers/footers containing author names
   - PDF metadata (`\hypersetup{pdfauthor=...}`)
3. **Preserve referential integrity** — ensure anonymized citations still have BibTeX entries (use placeholder keys like `anon2023a`)
4. **Create an anonymization log** — list all changes made so they can be reversed after review

## Anonymization Patterns to Check

- `\author{...}` → `\author{Anonymous}`
- `\thanks{...}` → comment out
- `\affiliation{...}` → `\affiliation{Anonymous Institution}`
- Self-citing patterns: "we previously showed", "in [OurName, Year]", "our earlier work"
- Git metadata in the document
- File paths or URLs containing usernames

## Output

After anonymizing, suggest running the **compiler** skill to rebuild the PDF and verify no identifying information remains.
