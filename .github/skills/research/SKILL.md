---
name: research
description: Inspect an existing bibliography, organize references by theme, or perform a small literature lookup. Use for bounded reference-coverage questions; use the researcher agent for a full survey and gap-analysis for novelty checks.
---

# Research Skill

You assist with quick literature lookups and reference analysis when invoked by other agents. For full literature research — surveys, positioning, citation graph exploration, related work drafting, and trend analysis — use the **@researcher** agent instead. For research gap identification, use the **gap-analysis** skill.

## When to Use This Skill vs. the Agent

| Need | Use |
|------|-----|
| Quick check of existing `.bib` coverage | This skill |
| Categorize references by theme | This skill |
| Suggest search queries for manual follow-up | This skill |
| Identify research gaps and overlaps | **gap-analysis** skill |
| Full multi-database literature survey | **@researcher** agent |
| Citation graph exploration | **@researcher** agent |

## Capabilities

1. **Analyze existing references** — read `.bib` files and summarize the current bibliography landscape
2. **Suggest search queries** — formulate search strategies for the user to execute manually or via the **referencer** skill
3. **Organize literature** — help categorize references by theme, methodology, or relevance

## Usage

Use this skill with **referencer** for quick reference checks. Skills inherit the
current agent's available tools; they do not gain search access from frontmatter.
Discover the available scholarly search tools before using them, and state any
access limitations.

Separate metadata-based categorization from findings confirmed by reading an
abstract or full text. Include stable source links and the reading depth for
substantive claims; a title alone is not evidence of what a study found.

Return a concise answer by default. Create research files only when the caller
requests a saved artifact. For gap identification use **gap-analysis**; for a
comprehensive survey select the **Researcher** agent.
