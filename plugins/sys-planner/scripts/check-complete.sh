#!/bin/sh
# sys-planner: Stop hook gate — check if all plan phases are complete.
# Usage: check-complete.sh [--gate]
# Without --gate: advisory only (prints status, always exits 0).
# With --gate: may emit {"decision":"block"} to prevent Claude from stopping.

set -u

GATE_MODE=0
for arg in "$@"; do
    case "$arg" in --gate) GATE_MODE=1 ;; esac
done

GATE_CAP="${PWF_GATE_CAP:-20}"
SLUG_RE='^[A-Za-z0-9_][A-Za-z0-9._-]*$'

# Resolve plan dir (inline copy of resolve-plan-dir.sh logic)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd 2>/dev/null)" || SCRIPT_DIR="."
PLAN_DIR=""

if [ -n "${PLAN_ID:-}" ] && printf "%s" "$PLAN_ID" | grep -Eq "$SLUG_RE" && [ -d ".plans/${PLAN_ID}" ]; then
    PLAN_DIR=".plans/${PLAN_ID}"
fi
if [ -z "$PLAN_DIR" ] && [ -f ".plans/.active_plan" ]; then
    AP=$(tr -d '\r\n[:space:]' < ".plans/.active_plan" 2>/dev/null)
    if [ -n "$AP" ] && printf "%s" "$AP" | grep -Eq "$SLUG_RE" && [ -d ".plans/${AP}" ]; then
        PLAN_DIR=".plans/${AP}"
    fi
fi
if [ -z "$PLAN_DIR" ] && [ -d ".plans" ]; then
    NEWEST=""; NEWEST_MT=0
    for d in .plans/*/; do
        [ -d "$d" ] || continue
        d="${d%/}"; n=$(basename "$d")
        case "$n" in .*) continue ;; esac
        printf "%s" "$n" | grep -Eq "$SLUG_RE" || continue
        [ -f "$d/PLAN.md" ] || continue
        m=$(stat -c '%Y' "$d" 2>/dev/null || stat -f '%m' "$d" 2>/dev/null || echo 0)
        if [ "$m" -gt "$NEWEST_MT" ] 2>/dev/null; then NEWEST_MT="$m"; NEWEST="$d"; fi
    done
    [ -n "$NEWEST" ] && PLAN_DIR="${NEWEST%/}"
fi
if [ -z "$PLAN_DIR" ] && [ -f ".plans/PLAN.md" ]; then
    PLAN_DIR=".plans"
fi

if [ -z "$PLAN_DIR" ]; then
    [ "$GATE_MODE" = "1" ] && echo '{"decision":"continue"}' && exit 0
    exit 0
fi

PLAN_FILE="${PLAN_FILE:-${PLAN_DIR}/PLAN.md}"
MODE_FILE="${PLAN_DIR}/.mode"
BLOCKS_FILE="${PLAN_DIR}/.stop_blocks"
GATE_LEDGER_FILE="${PLAN_DIR}/.gate_last_ledger"

# Guard 1: mode must be gated
if [ "$GATE_MODE" = "1" ]; then
    if [ ! -f "$MODE_FILE" ] || ! grep -q 'gate' "$MODE_FILE" 2>/dev/null; then
        echo '{"decision":"continue"}'
        exit 0
    fi
fi

# Read PLAN.md for phase status
if [ ! -f "$PLAN_FILE" ]; then
    [ "$GATE_MODE" = "1" ] && echo '{"decision":"continue"}'
    exit 0
fi

IN_PROGRESS=$(grep -c 'Status:.*in_progress' "$PLAN_FILE" 2>/dev/null || echo 0)
COMPLETE=$(grep -c 'Status:.*complete' "$PLAN_FILE" 2>/dev/null || echo 0)
PENDING=$(grep -c 'Status:.*pending' "$PLAN_FILE" 2>/dev/null || echo 0)
IN_PROGRESS_PHASE=$(grep -m1 'Status:.*in_progress' "$PLAN_FILE" 2>/dev/null | sed 's/.*Status:.*//' | head -1 || true)

# Advisory output
echo "[sys-planner] Phase status: ${IN_PROGRESS} in_progress, ${COMPLETE} complete, ${PENDING} pending"
[ -n "$IN_PROGRESS_PHASE" ] && echo "[sys-planner] Active phase: $(grep -B5 'Status:.*in_progress' "$PLAN_FILE" 2>/dev/null | grep '^###' | tail -1 | sed 's/^### //')"

# Guard 2: must have an in_progress phase to block
if [ "$GATE_MODE" != "1" ] || [ "$IN_PROGRESS" = "0" ] 2>/dev/null; then
    [ "$GATE_MODE" = "1" ] && echo '{"decision":"continue"}'
    exit 0
fi

# Guard 3: stop_hook_active in stdin JSON
STDIN_JSON=""
if [ -t 0 ]; then : ; else STDIN_JSON=$(cat 2>/dev/null); fi
if echo "$STDIN_JSON" | grep -q '"stop_hook_active".*true' 2>/dev/null; then
    echo '[sys-planner] Already in forced continuation — allowing stop to prevent loop.'
    echo '{"decision":"continue"}'
    exit 0
fi

# Guard 4: block count below cap
BLOCKS=0
[ -f "$BLOCKS_FILE" ] && BLOCKS=$(tr -d '[:space:]' < "$BLOCKS_FILE" 2>/dev/null | grep -E '^[0-9]+$' || echo 0)
if [ "$BLOCKS" -ge "$GATE_CAP" ] 2>/dev/null; then
    echo "[sys-planner] Gate cap reached (${BLOCKS}/${GATE_CAP}) — allowing stop."
    echo '{"decision":"continue"}'
    exit 0
fi

# Guard 5: stall detection via ledger line count
LEDGER_LINES=0
for lf in "${PLAN_DIR}"/ledger-*.jsonl; do
    [ -f "$lf" ] || continue
    c=$(wc -l < "$lf" 2>/dev/null || echo 0)
    LEDGER_LINES=$((LEDGER_LINES + c))
done
LAST_LEDGER=0
[ -f "$GATE_LEDGER_FILE" ] && LAST_LEDGER=$(tr -d '[:space:]' < "$GATE_LEDGER_FILE" 2>/dev/null | grep -E '^[0-9]+$' || echo 0)
if [ "$LEDGER_LINES" -le "$LAST_LEDGER" ] 2>/dev/null && [ "$BLOCKS" -gt "0" ] 2>/dev/null; then
    echo "[sys-planner] Stall detected (ledger unchanged at ${LEDGER_LINES} lines) — allowing stop."
    echo '{"decision":"continue"}'
    exit 0
fi

# All guards passed: emit block
NEW_BLOCKS=$((BLOCKS + 1))
printf "%s\n" "$NEW_BLOCKS" > "$BLOCKS_FILE" 2>/dev/null
printf "%s\n" "$LEDGER_LINES" > "$GATE_LEDGER_FILE" 2>/dev/null

ACTIVE_PHASE=$(grep -B5 'Status:.*in_progress' "$PLAN_FILE" 2>/dev/null | grep '^###' | tail -1 | sed 's/^### //' || echo "unknown phase")
echo "[sys-planner] Gate blocking stop — '${ACTIVE_PHASE}' is in_progress. Block ${NEW_BLOCKS}/${GATE_CAP}."
printf '{"decision":"block","reason":"Phase \"%s\" is still in_progress. Complete it or update PLAN.md before stopping. (block %d/%d)"}\n' \
    "$ACTIVE_PHASE" "$NEW_BLOCKS" "$GATE_CAP"
exit 0
