---
name: svg-renderer
description: Convert an existing SVG to a PNG preview or vector PDF using Docker. Use for figure inspection and LaTeX inclusion, including custom output names, DPI, and preview widths.
---

# SVG Renderer Skill

You convert SVG vector graphics to raster previews (PNG) and print-ready formats (PDF). This skill powers the fast visual feedback loop used by the **@illustrator** agent: generate SVG → render PNG → inspect with vision → iterate.

## Prerequisites

- Docker must be installed and running on the host machine
- The `research-latex` Docker image must be built (it includes `rsvg-convert`)

The helper builds the image if missing and reports an unavailable Docker daemon
explicitly. Run commands from the repository root; input/output paths below are
relative to that root. The bundled helper is [render-svg.sh](scripts/render-svg.sh).

## Outputs

| Output | Format | Purpose |
|--------|--------|---------|
| PNG preview | `figures/<name>.png` | Fast visual inspection via model vision |
| PDF figure | `figures/<name>.pdf` | LaTeX inclusion with `\includegraphics` |

## Procedure

### 1. Render a Preview (Fast Loop)

To convert an SVG to a PNG preview for visual inspection:

```bash
.github/skills/svg-renderer/scripts/render-svg.sh <input.svg> --format png
```

This produces a PNG at 300 DPI by default. Override with `--dpi <value>`.

Use this for the **fast feedback loop**: the @illustrator generates SVG, you render the PNG, the model inspects it with vision, and the cycle repeats until the figure looks right. Each cycle takes seconds — no LaTeX compilation needed.

### 2. Render for LaTeX (PDF)

To produce a PDF suitable for `\includegraphics`:

```bash
.github/skills/svg-renderer/scripts/render-svg.sh <input.svg> --format pdf
```

The PDF output preserves vector quality and can be included in LaTeX:

```latex
\begin{figure}[t]
  \centering
  \includegraphics[width=\columnwidth]{figures/architecture.pdf}
  \caption{System architecture overview.}
  \label{fig:architecture}
\end{figure}
```

### 3. Render Both Formats

To produce both PNG preview and PDF for LaTeX in one step:

```bash
.github/skills/svg-renderer/scripts/render-svg.sh <input.svg> --format both
```

### 4. Custom Output Path

By default, output goes alongside the input file. Override with `--output`:

```bash
.github/skills/svg-renderer/scripts/render-svg.sh papers/<name>/figures/arch.svg --format png --output papers/<name>/output/preview.png
```

Missing output directories are created. With `--format both`, `--output` sets the
shared output stem: `--output papers/<name>/figures/custom` writes `custom.png`
and `custom.pdf` (an optional `.png` or `.pdf` suffix is stripped first).

### 5. Custom Dimensions

Control the output width (height scales proportionally):

```bash
.github/skills/svg-renderer/scripts/render-svg.sh <input.svg> --format png --width 800
```

## Integration with LaTeX

SVG files cannot be included directly in LaTeX with `pdflatex`. Always convert to PDF first using this skill, then use `\includegraphics` on the PDF output.

The recommended workflow:
1. Keep the source `.svg` file in `figures/` (version-controlled, editable)
2. Convert to `.pdf` for LaTeX inclusion
3. The compiler skill will pick up the PDF automatically

## Error Handling

- **Missing `rsvg-convert`** — rebuild the Docker image; its `rsvg-convert` package must be installed
- **Malformed SVG** — check for unclosed tags, invalid attributes, or encoding issues
- **Blank output** — verify the SVG has visible content (not just a `<defs>` block) and uses explicit dimensions or a `viewBox` attribute
- **Invalid size** — DPI and width must be positive integers; single-format output filenames must have the corresponding `.png` or `.pdf` extension
- **No image-viewing tool** — report that the conversion ran but visual quality was not inspected; do not invent a vision tool or claim a visual check
