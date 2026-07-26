#!/usr/bin/env bash
# Extract a text layer and page renders for every source PDF.
#
# Text goes to build/text/<name>.txt and is a DRAFTING AID AND GREP INDEX ONLY.
# Several sources have broken font encodings (see SOURCES.md), so the page
# renders in build/pages/<name>/ are the source of truth for every definition,
# formula and figure. Never transcribe notation from build/text/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DPI="${DPI:-150}"

mkdir -p "$ROOT/build/text" "$ROOT/build/pages"

for pdf in "$ROOT"/lecture_notes/*.pdf "$ROOT"/DOCS/*.pdf; do
    name="$(basename "$pdf" .pdf)"
    echo "==> $name"

    pdftotext -q -layout "$pdf" "$ROOT/build/text/$name.txt"

    outdir="$ROOT/build/pages/$name"
    mkdir -p "$outdir"
    # -r $DPI verified legible for both slide decks and ALSU body text.
    pdftoppm -q -png -r "$DPI" "$pdf" "$outdir/page"

    pages=$(pdfinfo "$pdf" | awk '/^Pages/ {print $2}')
    printf '    %s pages, %s renders, %s chars of text\n' \
        "$pages" \
        "$(find "$outdir" -name 'page*.png' | wc -l)" \
        "$(wc -c < "$ROOT/build/text/$name.txt")"
done

echo
echo "Done. Text: build/text/  Renders: build/pages/  (${DPI} DPI)"
