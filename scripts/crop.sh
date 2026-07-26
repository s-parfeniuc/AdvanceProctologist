#!/usr/bin/env bash
# Crop a figure region out of a source PDF page straight into notes/assets/.
#
# Uses pdftoppm's native crop flags, so there is no ImageMagick dependency.
# Coordinates are in pixels at the render DPI, measured from the top-left of the
# page as it appears in build/pages/<source>/page-NNN.png.
#
# Usage:
#   scripts/crop.sh <source-name> <pdf-page> <slug> [X Y W H]
#
# Omit X/Y/W/H to render the whole page (useful when the slide *is* the figure).
#
# Example:
#   scripts/crop.sh 03-AP-25-09-25-Parsing 30 predictive-trace-step2 200 300 1600 500
#   -> notes/assets/fig-03-AP-25-09-25-Parsing-p30-predictive-trace-step2.png
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DPI="${DPI:-150}"

if [[ $# -lt 3 ]]; then
    sed -n '2,17p' "${BASH_SOURCE[0]}" >&2
    exit 2
fi

name="$1"; page="$2"; slug="$3"; shift 3

pdf=""
for cand in "$ROOT/lecture_notes/$name.pdf" "$ROOT/DOCS/$name.pdf"; do
    [[ -f "$cand" ]] && pdf="$cand"
done
if [[ -z "$pdf" ]]; then
    echo "error: no such source PDF: $name" >&2
    exit 1
fi

mkdir -p "$ROOT/notes/assets"
out="$ROOT/notes/assets/fig-$name-p$page-$slug"

crop=()
if [[ $# -eq 4 ]]; then
    crop=(-x "$1" -y "$2" -W "$3" -H "$4")
elif [[ $# -ne 0 ]]; then
    echo "error: give all four of X Y W H, or none" >&2
    exit 1
fi

pdftoppm -q -png -r "$DPI" -f "$page" -l "$page" "${crop[@]}" "$pdf" "$out"

# pdftoppm appends the page number; normalise to a stable filename.
for f in "$out"-*.png; do
    [[ -e "$f" ]] || continue
    mv "$f" "$out.png"
done

echo "wrote notes/assets/$(basename "$out.png")"
