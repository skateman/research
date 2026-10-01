#!/usr/bin/env bash
set -euo pipefail

# Usage: render-svg.sh input.svg [--format png|pdf|both] [--output path]
#        [--dpi positive-integer] [--width positive-integer]
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../../../../scripts/lib/research-container.sh"

FORMAT=png
DPI=300
WIDTH=""
OUTPUT=""
INPUT=""
while [ "$#" -gt 0 ]; do
    case "$1" in
        --format|--output|--dpi|--width)
            [ "$#" -ge 2 ] && [ -n "$2" ] || research_error "Missing value for $1"
            case "$1" in
                --format) FORMAT="$2" ;;
                --output) OUTPUT="$2" ;;
                --dpi) DPI="$2" ;;
                --width) WIDTH="$2" ;;
            esac
            shift 2
            ;;
        -*) research_error "Unknown option: $1" ;;
        *)
            [ -z "$INPUT" ] || research_error "Expected one input SVG, got another argument: $1"
            INPUT="$1"
            shift
            ;;
    esac
done

[ -n "$INPUT" ] || research_error "Usage: render-svg.sh input.svg [--format png|pdf|both] [--output path]"
[ -f "$INPUT" ] || research_error "Input SVG not found: $INPUT"
case "$FORMAT" in
    png|pdf|both) ;;
    *) research_error "Unknown format: $FORMAT (expected png, pdf, or both)" ;;
esac
[[ "$DPI" =~ ^[1-9][0-9]*$ ]] || research_error "DPI must be a positive integer"
if [ -n "$WIDTH" ]; then
    [[ "$WIDTH" =~ ^[1-9][0-9]*$ ]] || research_error "Width must be a positive integer"
fi

INPUT_DIR="$(cd "$(dirname "$INPUT")" && pwd -P)"
INPUT_ABS="$INPUT_DIR/$(basename "$INPUT")"
INPUT_STEM="$(basename "$INPUT" .svg)"
if [ -z "$OUTPUT" ]; then
    OUTPUT="$INPUT_DIR/$INPUT_STEM"
    [ "$FORMAT" = both ] || OUTPUT="$OUTPUT.$FORMAT"
fi
if [ "$FORMAT" != both ] && [[ "$OUTPUT" != *."$FORMAT" ]]; then
    research_error "Output file must have a .$FORMAT extension"
fi
research_ensure_image
mkdir -p "$(dirname "$OUTPUT")"
OUTPUT_DIR="$(cd "$(dirname "$OUTPUT")" && pwd -P)"
OUTPUT_ABS="$OUTPUT_DIR/$(basename "$OUTPUT")"
[ "$OUTPUT_ABS" != "$INPUT_ABS" ] || research_error "Output must not overwrite the source SVG"

render() {
    local format="$1" out="$2"
    local render_args=(rsvg-convert -f "$format")
    if [ "$format" = png ]; then
        if [ -n "$WIDTH" ]; then
            render_args+=(-w "$WIDTH" -a)
        else
            render_args+=(-d "$DPI" -p "$DPI")
        fi
    fi
    docker run --rm \
        --user "$(id -u):$(id -g)" -e HOME=/tmp \
        -v "$INPUT_DIR:/input:ro" \
        -v "$OUTPUT_DIR:/output" \
        "$RESEARCH_IMAGE" \
        "${render_args[@]}" \
        -o "/output/$(basename "$out")" "/input/$(basename "$INPUT_ABS")"
    [ -s "$out" ] || research_error "Renderer did not produce a nonempty output: $out"
    printf '%s: %s\n' "$format" "$out"
}

if [ "$FORMAT" = both ]; then
    OUTPUT_STEM="$OUTPUT_ABS"
    case "$OUTPUT_STEM" in
        *.png|*.pdf) OUTPUT_STEM="${OUTPUT_STEM%.*}" ;;
    esac
    render png "$OUTPUT_STEM.png"
    render pdf "$OUTPUT_STEM.pdf"
else
    render "$FORMAT" "$OUTPUT_ABS"
fi
