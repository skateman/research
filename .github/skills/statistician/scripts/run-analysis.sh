#!/usr/bin/env bash
set -euo pipefail

# Usage: run-analysis.sh [paper-dir] [script.py] [--args ...]
# Defaults: current directory, analysis/run.py. Script paths are paper-relative.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../../../scripts/lib/research-container.sh"
research_run_python analysis analysis/run.py "$@"
