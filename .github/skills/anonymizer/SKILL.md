---
name: anonymizer
description: Prepare an author-anonymous submission when the venue requires it. Check author blocks, identifying prose, acknowledgments, supplements, and PDF metadata while preserving real citations and a reversible source.
---

# Anonymizer

Apply the venue's actual author-anonymity policy. Single-blind review normally
hides reviewers' identities, not authors': do not anonymize merely because a CFP
uses the word "blind". If the policy is missing or ambiguous, ask before editing.

## Procedure

1. Read the CFP and the manuscript's entry file, included sources, bibliography,
   supplements, and template options. Identify the exact submission artifacts.
2. Preserve an identifiable source through the template's anonymous/review mode
   where available. Otherwise prepare a separate submission copy or an explicitly
   approved reversible edit. Do not overwrite the only identifiable version.
3. Remove or suppress information the policy prohibits:
   - Author names, affiliations, emails, ORCIDs, identifying headers and footers.
   - Acknowledgments, author contributions, and identifying grant information.
   - Identifying repository, artifact, preregistration, and project URLs.
   - Names in figure labels, image metadata, supplementary files, and PDF metadata.
4. Rewrite revealing self-reference in neutral third person: "In our previous
   work..." becomes a factual description followed by the **real citation**.
   Keep the real authors, title, DOI, and bibliography key. Only mask a reference
   when the venue explicitly requires it, using the venue's prescribed method.
   Never invent an "Anonymous, Year" publication or silently remove relevant work.
5. Keep any identity mapping or restoration log outside the submission artifacts,
   in a user-approved private location. Do not repeat removed identities in the
   public-facing report.
6. Use the `compiler` skill to rebuild the anonymous variant. Inspect visible page
   content, extracted PDF text, and `pdfinfo` metadata; also check the actual
   supplementary files and archive contents that will be submitted.

## Boundaries

- Do not claim anonymity from a source-only search. Inspect the final PDF and
  report anything that could not be inspected.
- Do not guarantee that identity cannot be inferred from the research topic,
  public preprints, or distinctive artifacts.
- Do not delete citations, results, or methodological detail to hide identity.
- Do not place backups, identifying logs, or the non-anonymous PDF in the
  submission package.
- Perform this stage after manuscript edits finish, not concurrently with them.

## Output

Report the anonymous artifact path, the policy applied, categories changed,
checks completed, and remaining risks. Describe how to restore the author
version without exposing the identity mapping.
