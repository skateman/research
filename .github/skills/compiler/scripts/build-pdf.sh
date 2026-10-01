#!/usr/bin/env bash
set -euo pipefail

# Usage: build-pdf.sh [paper-dir] [main.tex] [--pages-only]
#        [--engine pdflatex|lualatex]
# The entry file is in paper-dir; outputs are name.pdf and output/pages/.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../../../scripts/lib/research-container.sh"

PAPER_DIR="."
MAIN_TEX=main.tex
PAGES_ONLY=false
ENGINE=pdflatex
POSITIONAL=0
while [ "$#" -gt 0 ]; do
    case "$1" in
        --pages-only) PAGES_ONLY=true; shift ;;
        --engine)
            [ "$#" -ge 2 ] || research_error "Missing value for --engine"
            ENGINE="$2"
            shift 2
            ;;
        -*) research_error "Unknown option: $1" ;;
        *)
            case "$POSITIONAL" in
                0) PAPER_DIR="$1" ;;
                1) MAIN_TEX="$1" ;;
                *) research_error "Unexpected argument: $1" ;;
            esac
            POSITIONAL=$((POSITIONAL + 1))
            shift
            ;;
    esac
done
case "$ENGINE" in
    pdflatex) LATEX_MODE=-pdf ;;
    lualatex) LATEX_MODE=-lualatex ;;
    *) research_error "Unsupported engine: $ENGINE (expected pdflatex or lualatex)" ;;
esac
[[ "$MAIN_TEX" == *.tex && "$MAIN_TEX" != */* && "$MAIN_TEX" != -* ]] ||
    research_error "Entry must be a .tex filename in the paper directory"
PAPER_DIR="$(research_paper_dir "$PAPER_DIR")"
PDF_FILE="${MAIN_TEX%.tex}.pdf"

# A failed rebuild must not leave a manifest that appears to certify this run.
rm -f "$PAPER_DIR/output/pages/pages.json"
if [ "$PAGES_ONLY" = true ]; then
    [ -f "$PAPER_DIR/$PDF_FILE" ] || research_error "PDF not found: $PAPER_DIR/$PDF_FILE"
else
    [ -f "$PAPER_DIR/$MAIN_TEX" ] || research_error "LaTeX entry not found: $PAPER_DIR/$MAIN_TEX"
fi
research_ensure_image
if [ "$PAGES_ONLY" = false ]; then
    mkdir -p "$PAPER_DIR/output/texmf-cache"
    printf 'Compiling %s with %s...\n' "$MAIN_TEX" "$ENGINE"
    research_container "$PAPER_DIR" \
        latexmk -g "$LATEX_MODE" -interaction=nonstopmode -halt-on-error "$MAIN_TEX"
fi
[ -s "$PAPER_DIR/$PDF_FILE" ] || research_error "Expected nonempty PDF not found: $PDF_FILE"
research_container "$PAPER_DIR" python3 - "$PDF_FILE" 150 "$PAGES_ONLY" \
    < "$SCRIPT_DIR/render-pages.py"
printf 'PDF: %s/%s\nPage metadata: %s/output/pages/pages.json\n' "$PAPER_DIR" "$PDF_FILE" "$PAPER_DIR"
