#!/bin/sh
# sys-planner: Stop hook dispatcher.
# Reads plan dir and mode, runs check-complete.sh in advisory or gate mode.

set -u

[ "${PNR_ENABLED:-}" = "true" ] || exit 0

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd 2>/dev/null)" || SCRIPT_DIR="."
CHECK="${SCRIPT_DIR}/check-complete.sh"
[ -f "$CHECK" ] || exit 0

# Check if gated mode is active
PLAN_DIR=""
SLUG_RE='^[A-Za-z0-9_][A-Za-z0-9._-]*$'
if [ -f ".plans/.active_plan" ]; then
    AP=$(tr -d '\r\n[:space:]' < ".plans/.active_plan" 2>/dev/null)
    printf "%s" "$AP" | grep -Eq "$SLUG_RE" && [ -d ".plans/${AP}" ] && PLAN_DIR=".plans/${AP}"
fi
[ -z "$PLAN_DIR" ] && [ -f ".plans/PLAN.md" ] && PLAN_DIR=".plans"

if [ -n "$PLAN_DIR" ] && [ -f "${PLAN_DIR}/.mode" ] && grep -q 'gate' "${PLAN_DIR}/.mode" 2>/dev/null; then
    sh "$CHECK" --gate
else
    sh "$CHECK"
fi
exit 0
