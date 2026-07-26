#!/usr/bin/env bash
# Grep the finished notes for extraction residue that must never appear.
#
# These are the signatures of the two font-encoding faults documented in
# SOURCES.md. A hit means a formula or word was transcribed from build/text/
# instead of being read off the rendered page.
#
#   Symbol-font residue   ® Î È Þ Ï      -> should be  → ∈ ∪ ⇒ ⊇
#   Ligature residue      ﬁ ﬂ ﬀ ﬃ       -> should be  fi fl ff ffi
#   ti-as-digit residue   applica4on     -> should be  application
#
# Also flags the transcript markers carried by the original lecture .md files.
#
# A line may quote broken extraction on purpose (an aside explaining the fault).
# Append the marker <!--raw--> to exempt that single line.
#
# Usage: scripts/check-notation.sh [path ...]        (default: notes/)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
targets=("${@:-$ROOT/notes}")

fail=0

report() {
    local label="$1" pattern="$2" flags="$3"
    local hits
    hits=$(grep -rn $flags -- "$pattern" "${targets[@]}" \
             --include='*.md' 2>/dev/null | grep -v '<!--raw-->')
    if [[ -n "$hits" ]]; then
        printf '\n[FAIL] %s\n' "$label"
        printf '%s\n' "$hits" | sed 's/^/    /'
        fail=1
    else
        printf '[ ok ] %s\n' "$label"
    fi
}

echo "Checking: ${targets[*]}"
echo

report "Symbol-font residue (® Î È Þ Ï)"        '®\|Î\|È\|Þ\|Ï'                 ''
report "Ligature residue (ﬁ ﬂ ﬀ ﬃ)"            'ﬁ\|ﬂ\|ﬀ\|ﬃ'                    ''
report "ti-as-digit residue (applica4on)"       '\b[A-Za-z]{2,}[0-9][A-Za-z]{2,}\b' '-E'
report "transcript markers (【..†..】)"          '【'                             ''

# Every embedded asset must resolve.
echo
missing=0
while IFS= read -r ref; do
    file="${ref%%:*}"; rest="${ref#*:}"
    asset="${rest##*(}"; asset="${asset%%)*}"
    [[ "$asset" == http* ]] && continue
    dir="$(dirname "$file")"
    if [[ ! -e "$dir/$asset" ]]; then
        printf '    %s -> %s\n' "$file" "$asset"
        missing=1
    fi
done < <(grep -rno '!\[[^]]*\]([^)]*)' "${targets[@]}" --include='*.md' 2>/dev/null | cut -d: -f1,3-)

if [[ $missing -eq 1 ]]; then
    echo "[FAIL] broken image embeds (listed above)"
    fail=1
else
    echo "[ ok ] all image embeds resolve"
fi

echo
if [[ $fail -eq 0 ]]; then
    echo "PASS"
else
    echo "FAIL — fix by re-reading the cited page in build/pages/"
fi
exit $fail
