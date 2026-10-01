---
name: referencer
description: Find and verify academic references, check whether sources support manuscript claims, and maintain BibTeX. Use for missing citations, DOI/metadata checks, duplicate entries, or bibliography cleanup.
---

# Referencer

Keep bibliographic identity and evidentiary support separate: resolving a DOI
proves neither that a paper supports a claim nor that its findings are reliable.

## Tools and Access

Prefer the configured `paper-search` and `paper-search-py` MCP servers. Discover
the available tools and their schemas before calling them; server names and
published feature lists do not guarantee that a tool or database is available.
This skill neither provisions MCP servers nor declares tool pre-approvals.

- Use available scholarly indexes such as Crossref, Semantic Scholar, arXiv,
  PubMed, or Google Scholar as appropriate to the topic.
- If a provider fails, record the failure and try another available source.
  Publisher pages, DOI landing pages, and institutional repositories are useful
  verification fallbacks through the host's web tools.
- Do not invent tool names, silently substitute a different database, or claim
  access to unavailable subscription services.
- Retrieve full text only through legitimate open-access or authorized routes.
  Do not use shadow libraries or bypass access controls.
- Keep queries limited to public topic terms. Do not upload unpublished
  manuscripts, confidential reviewer comments, credentials, or private datasets.

## Procedure

1. **Establish scope.** Identify the paper directory, entry file, included
   sources, bibliography files, citation package, and whether the task is an
   audit or permits edits. In review/audit mode, return findings without changing
   `.tex` or `.bib` files.
2. **Check local integrity.** Follow the manuscript's included files and citation
   commands, including biblatex/natbib variants and `\nocite`. Account for
   `crossref`, `xdata`, shared bibliographies, and intentional uncited entries.
   Flag apparently unused records; never prune them automatically.
3. **Search proportionately.** Start with a few targeted queries; broaden if
   evidence is insufficient. Record provider, query, retrieval date, and stable
   identifiers. Prefer appropriate primary sources, not citation counts alone.
4. **Verify metadata.** Match title, authors, year, publication version, and
   venue against authoritative records. Prefer a DOI when one exists; legitimate
   books, standards, datasets, and software may use other identifiers. Check
   available correction/retraction notices for central evidence.
5. **Verify support.** Read the relevant abstract or full-text passage. Record
   the location and whether support is direct, partial, contradictory, or not
   assessed. Titles and search snippets are discovery aids, not claim validation.
   Do not imply a full-text check when only metadata or an abstract was accessible.
6. **Edit only within authorization.** Preserve stable citation keys and the
   existing bibliography style. Resolve duplicates carefully, updating all
   consumers if a key changes. Prefer the version actually supporting the cited
   finding; distinguish preprints from peer-reviewed publications.
7. **Check the result.** Ensure new citation keys resolve, required entry fields
   match their entry types, special characters are escaped correctly, and any
   unresolved claims remain explicitly marked.

## Coordination

For bibliography-only work, write only the assigned `.bib` file and return
proposed prose/citation changes to the caller. If authorized to edit `.tex`,
serialize with `humanizer`, `writer`, `formatter`, and `anonymizer`. Changing
different parts of one file is not safe parallel ownership.

Use `% TODO: source needed for ...` for unresolved claims in a draft; do not
create fictitious bibliography records or `\cite{TODO:...}` keys. Preserve and
resolve existing placeholders without disguising them as verified references.

## Output

Return sources added/corrected, stable links or DOIs, claim-support findings with
reading depth, unresolved citation keys, possible unused records, and search
coverage limitations. Persist a search/evidence log in the paper's `research/`
directory only when the requested workflow calls for a saved research artifact.
