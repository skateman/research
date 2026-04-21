#!/usr/bin/env bash
set -euo pipefail

# Run a statistical analysis Python script inside the research-latex Docker container.
#
# Usage: run-analysis.sh [paper-dir] [script.py] [--args ...]
#   paper-dir   Path to the paper directory (default: current directory)
#   script.py   Python script to execute (relative to paper-dir)
#   --args      Additional arguments passed to the Python script
#
# Outputs go to <paper-dir>/output/analysis/ (the script should write there)

PAPER_DIR="${1:-.}"
SCRIPT="${2:-analysis/run.py}"
shift 2 2>/dev/null || true

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOCKER_DIR="$(cd "$SCRIPT_DIR/../../../.." 2>/dev/null && pwd || echo "")"
IMAGE_NAME="research-latex"

PAPER_DIR="$(cd "$PAPER_DIR" && pwd)"

echo "=== Statistician: Running Analysis ==="
echo "Paper directory: $PAPER_DIR"
echo "Script: $SCRIPT"

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not in PATH"
    exit 1
fi

# Build image if needed
if ! docker image inspect "$IMAGE_NAME" &> /dev/null; then
    if [ -z "$DOCKER_DIR" ] || [ ! -f "$DOCKER_DIR/Dockerfile" ]; then
        echo "ERROR: Docker image '$IMAGE_NAME' not found and cannot locate Dockerfile"
        exit 1
    fi
    echo "Building Docker image '$IMAGE_NAME'..."
    docker build -t "$IMAGE_NAME" "$DOCKER_DIR"
fi

# Ensure output directory exists
mkdir -p "$PAPER_DIR/output/analysis"

# Run the script
docker run --rm \
    -v "$PAPER_DIR:/paper" \
    -w /paper \
    "$IMAGE_NAME" \
    python3 "/paper/$SCRIPT" "$@"

echo "=== Analysis Complete ==="
echo "Results: $PAPER_DIR/output/analysis/"
