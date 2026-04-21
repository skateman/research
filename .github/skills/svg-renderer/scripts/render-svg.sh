#!/bin/sh
set -e

# render-svg.sh — Convert SVG to PNG preview and/or PDF for LaTeX
# Runs inside the research-latex Docker container (requires rsvg-convert)
#
# Usage:
#   render-svg.sh <input.svg> [options]
#
# Options:
#   --format png|pdf|both   Output format (default: png)
#   --output <path>         Output file path (default: alongside input)
#   --dpi <value>           DPI for PNG rendering (default: 300)
#   --width <pixels>        Output width in pixels (overrides DPI)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

# Defaults
FORMAT="png"
DPI=300
WIDTH=""
OUTPUT=""

# Parse arguments
INPUT=""
while [ $# -gt 0 ]; do
    case "$1" in
        --format)  FORMAT="$2";  shift 2 ;;
        --output)  OUTPUT="$2";  shift 2 ;;
        --dpi)     DPI="$2";     shift 2 ;;
        --width)   WIDTH="$2";   shift 2 ;;
        -*)        echo "Unknown option: $1" >&2; exit 1 ;;
        *)         INPUT="$1";   shift ;;
    esac
done

if [ -z "$INPUT" ]; then
    echo "Usage: render-svg.sh <input.svg> [--format png|pdf|both] [--dpi N] [--width N] [--output path]" >&2
    exit 1
fi

if [ ! -f "$INPUT" ]; then
    echo "Error: Input file not found: $INPUT" >&2
    exit 1
fi

# Resolve absolute path for Docker mount
INPUT_ABS="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
INPUT_DIR="$(dirname "$INPUT_ABS")"
INPUT_NAME="$(basename "$INPUT" .svg)"

# Determine output path(s)
if [ -n "$OUTPUT" ]; then
    OUTPUT_ABS="$(cd "$(dirname "$OUTPUT")" 2>/dev/null && pwd)/$(basename "$OUTPUT")" 2>/dev/null || OUTPUT_ABS="$OUTPUT"
    OUTPUT_DIR="$(dirname "$OUTPUT_ABS")"
else
    OUTPUT_DIR="$INPUT_DIR"
fi

# Build Docker image if needed
if ! docker image inspect research-latex >/dev/null 2>&1; then
    echo "Building research-latex Docker image..."
    docker build -t research-latex -f "$REPO_ROOT/Dockerfile" "$REPO_ROOT"
fi

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

render_png() {
    local out="${1:-$OUTPUT_DIR/$INPUT_NAME.png}"
    local size_args=""
    if [ -n "$WIDTH" ]; then
        size_args="-w $WIDTH -a"
    else
        size_args="-d $DPI -p $DPI"
    fi

    docker run --rm \
        -v "$INPUT_DIR:/input:ro" \
        -v "$(dirname "$out"):/output" \
        research-latex \
        rsvg-convert \
            $size_args \
            -f png \
            -o "/output/$(basename "$out")" \
            "/input/$(basename "$INPUT_ABS")"

    echo "PNG: $out ($(du -h "$out" | cut -f1))"
}

render_pdf() {
    local out="${1:-$OUTPUT_DIR/$INPUT_NAME.pdf}"

    docker run --rm \
        -v "$INPUT_DIR:/input:ro" \
        -v "$(dirname "$out"):/output" \
        research-latex \
        rsvg-convert \
            -f pdf \
            -o "/output/$(basename "$out")" \
            "/input/$(basename "$INPUT_ABS")"

    echo "PDF: $out ($(du -h "$out" | cut -f1))"
}

echo "=== SVG Renderer ==="
echo "Input: $INPUT_ABS"
echo "Format: $FORMAT"

case "$FORMAT" in
    png)
        render_png "$OUTPUT_ABS"
        ;;
    pdf)
        render_pdf "$OUTPUT_ABS"
        ;;
    both)
        render_png "$OUTPUT_DIR/$INPUT_NAME.png"
        render_pdf "$OUTPUT_DIR/$INPUT_NAME.pdf"
        ;;
    *)
        echo "Error: Unknown format '$FORMAT'. Use png, pdf, or both." >&2
        exit 1
        ;;
esac

echo "=== Done ==="
