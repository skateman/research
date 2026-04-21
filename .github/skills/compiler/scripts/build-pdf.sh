#!/usr/bin/env bash
set -euo pipefail

# Build an academic paper PDF and render page images for visual inspection.
#
# Usage: build-pdf.sh [paper-dir] [main-tex-file] [--pages-only]
#   paper-dir      Path to the paper directory (default: current directory)
#   main-tex-file  Name of the main .tex file (default: main.tex)
#   --pages-only   Skip compilation, only re-render page images from existing PDF
#
# Outputs:
#   <paper-dir>/<name>.pdf          — compiled PDF
#   <paper-dir>/output/pages/*.png  — one PNG per page (150 DPI)
#   <paper-dir>/output/pages.json   — page count and metadata

PAPER_DIR="${1:-.}"
MAIN_TEX="${2:-main.tex}"
PAGES_ONLY=false
for arg in "$@"; do
    [ "$arg" = "--pages-only" ] && PAGES_ONLY=true
done

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_DIR="$(cd "$SCRIPT_DIR/../../../.." 2>/dev/null && pwd || echo "")"
IMAGE_NAME="research-latex"
RENDER_DPI=150

# Resolve absolute path
PAPER_DIR="$(cd "$PAPER_DIR" && pwd)"
PDF_FILE="${MAIN_TEX%.tex}.pdf"
PAGES_DIR="$PAPER_DIR/output/pages"

echo "=== Research Paper Compiler ==="
echo "Paper directory: $PAPER_DIR"
echo "Main file: $MAIN_TEX"

# Check Docker is available
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not in PATH"
    exit 1
fi

# Build image if it doesn't exist
if ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
    if [ -z "$DOCKER_DIR" ] || [ ! -f "$DOCKER_DIR/Dockerfile" ]; then
        echo "ERROR: Docker image '$IMAGE_NAME' not found and cannot locate Dockerfile"
        echo "Build it manually: docker build -t $IMAGE_NAME /path/to/research/"
        exit 1
    fi
    echo "Building Docker image '$IMAGE_NAME'..."
    docker build -t "$IMAGE_NAME" "$DOCKER_DIR"
fi

# --- Step 1: Compile (unless --pages-only) ---
if [ "$PAGES_ONLY" = false ]; then
    echo "Compiling $MAIN_TEX..."
    docker run --rm \
        -v "$PAPER_DIR:/paper" \
        "$IMAGE_NAME" \
        latexmk -pdf -interaction=nonstopmode -halt-on-error "$MAIN_TEX"
fi

if [ ! -f "$PAPER_DIR/$PDF_FILE" ]; then
    echo "ERROR: Expected output $PDF_FILE not found"
    exit 1
fi

# --- Step 2: Render page images ---
echo "Rendering page images at ${RENDER_DPI} DPI..."
mkdir -p "$PAGES_DIR"
rm -f "$PAGES_DIR"/*.png "$PAGES_DIR"/pages.json

docker run --rm \
    -v "$PAPER_DIR:/paper" \
    "$IMAGE_NAME" \
    pdftoppm -png -r "$RENDER_DPI" "/paper/$PDF_FILE" "/paper/output/pages/page"

# --- Step 3: Extract metadata ---
PAGE_COUNT=$(docker run --rm \
    -v "$PAPER_DIR:/paper" \
    "$IMAGE_NAME" \
    pdfinfo "/paper/$PDF_FILE" | grep "Pages:" | awk '{print $2}')

PDF_SIZE=$(du -h "$PAPER_DIR/$PDF_FILE" | cut -f1)
IMG_COUNT=$(ls -1 "$PAGES_DIR"/*.png 2>/dev/null | wc -l | tr -d ' ')

# Write metadata JSON
cat > "$PAGES_DIR/pages.json" <<EOF
{
  "pdf_file": "$PDF_FILE",
  "pdf_size": "$PDF_SIZE",
  "page_count": $PAGE_COUNT,
  "rendered_images": $IMG_COUNT,
  "dpi": $RENDER_DPI,
  "pages_directory": "output/pages/"
}
EOF

echo "=== Success ==="
echo "PDF:    $PDF_FILE ($PDF_SIZE)"
echo "Pages:  $PAGE_COUNT"
echo "Images: $PAGES_DIR/ ($IMG_COUNT PNGs at ${RENDER_DPI} DPI)"
