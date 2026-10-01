#!/usr/bin/env bash
set -euo pipefail

# Usage: run-processing.sh [paper-dir] [script.py] [--args ...]
# Defaults: current directory, analysis/process.py. Raw data is never rewritten.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../../../scripts/lib/research-container.sh"
research_run_python processing analysis/process.py "$@"
