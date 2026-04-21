---
name: Compiler
description: Build a PDF from LaTeX source, render page images for visual inspection, and report page count for CFP compliance.
tools:
  - shell
  - read
  - vision
---

# Compiler Skill

You compile LaTeX academic papers into PDF, render each page as a PNG image for visual inspection, and report page count metadata. All work happens inside an ephemeral Docker container.

## Prerequisites

- Docker must be installed and running on the host machine
- The paper directory should contain a `main.tex` file (or specify the entry point)

## Outputs

After a successful build, the following are produced:

| Output | Location | Purpose |
|--------|----------|---------|
| Compiled PDF | `<paper-dir>/<name>.pdf` | The final paper |
| Page images | `<paper-dir>/output/pages/page-*.png` | One PNG per page at 150 DPI for visual review |
| Page metadata | `<paper-dir>/output/pages/pages.json` | Page count, PDF size, rendering info |

## Procedure

### 1. Locate the Paper

Identify the paper root directory containing `main.tex` (or the specified entry `.tex` file).

### 2. Build the Docker Image (if needed)

Check if the `research-latex` image exists. If not, build it:

```bash
docker build -t research-latex -f /path/to/research/Dockerfile /path/to/research/
```

### 3. Compile and Render

Use the build script which handles compilation, page rendering, and metadata extraction in one step:

```bash
.github/skills/compiler/scripts/build-pdf.sh [paper-dir] [main-tex-file]
```

This will:
1. Compile the LaTeX document with `latexmk -pdf`
2. Convert each PDF page to a PNG image using `pdftoppm` (150 DPI)
3. Extract page count and file size via `pdfinfo`
4. Write `output/pages/pages.json` with metadata

To re-render page images without recompiling (e.g., after manual PDF changes):
```bash
.github/skills/compiler/scripts/build-pdf.sh [paper-dir] [main-tex-file] --pages-only
```

### 4. Check Page Count Against CFP Limits

After compilation, read `output/pages/pages.json` and compare the page count against the CFP requirements:

- **Mandatory maximum**: if `page_count > max_pages`, the paper MUST be shortened
- **Optional minimum**: if `page_count < min_pages`, warn that the paper may appear thin

Report this clearly:
```
Page count: 9 / 10 max (CFP limit) ✓
```
or:
```
Page count: 12 / 10 max (CFP limit) ✗ — 2 pages over limit!
```

### 5. Visual Inspection

The rendered page images in `output/pages/` can be viewed to visually verify:
- Overall layout and spacing
- Figure and table placement
- Widow/orphan lines
- Margin compliance
- Any visual artifacts

The **formatter** skill uses these images to identify layout problems that aren't apparent from LaTeX source or log files alone.

### 6. Handle Errors

If compilation fails:
1. **Read the log** — check `main.log` for errors
2. **Common issues:**
   - Missing packages → likely need to update the Dockerfile
   - Undefined references → run compilation twice (latexmk handles this automatically)
   - BibTeX errors → check `.bib` file syntax
   - Missing files → verify all `\input{}` and `\includegraphics{}` paths
3. **Report the error** with the relevant log excerpt and suggest fixes
