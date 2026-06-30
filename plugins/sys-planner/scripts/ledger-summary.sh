#!/bin/sh
# sys-planner: Synthesize ledger files into a structured injection block.
# Usage: ledger-summary.sh [<plan-dir>]
# Reads all ledger-*.jsonl in the plan dir, prints a compact summary.

set -u

PLAN_DIR="${1:-}"
if [ -z "$PLAN_DIR" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd 2>/dev/null)" || SCRIPT_DIR="."
    RESOLVE="${SCRIPT_DIR}/resolve-plan-dir.sh"
    [ -f "$RESOLVE" ] && PLAN_DIR=$(sh "$RESOLVE" 2>/dev/null)
fi

[ -z "$PLAN_DIR" ] && exit 0

TOTAL=0
ERRORS=0
PHASE_UPDATES=0
LAST_NOTE=""
LAST_TS=0

for lf in "${PLAN_DIR}"/ledger-*.jsonl; do
    [ -f "$lf" ] || continue
    lf_count=$(wc -l < "$lf" 2>/dev/null | tr -d '[:space:]')
    lf_count=${lf_count:-0}
    TOTAL=$((TOTAL + lf_count))
    # parse only the last 100 entries for field extraction
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        TYPE=$(printf "%s" "$line" | sed 's/.*"type":"\([^"]*\)".*/\1/')
        TS=$(printf "%s" "$line" | sed 's/.*"ts":\([0-9]*\).*/\1/')
        case "$TYPE" in
            error)        ERRORS=$((ERRORS + 1)) ;;
            phase_update) PHASE_UPDATES=$((PHASE_UPDATES + 1)) ;;
            note)
                if [ "$TS" -gt "$LAST_TS" ] 2>/dev/null; then
                    LAST_TS="$TS"
                    LAST_NOTE=$(printf "%s" "$line" | sed 's/.*"data":"\([^"]*\)".*/\1/')
                fi
                ;;
        esac
    done <<EOF
$(tail -100 "$lf")
EOF
done

printf "ledger events: %d total, %d phase updates, %d errors\n" "$TOTAL" "$PHASE_UPDATES" "$ERRORS"
[ -n "$LAST_NOTE" ] && printf "last note: %s\n" "$LAST_NOTE"
exit 0
