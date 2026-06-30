#!/bin/sh
# sys-planner: Switch the active plan pointer.
# Usage: set-active-plan.sh <slug>
# Writes <slug> to .plans/.active_plan.

set -u

SLUG="${1:-}"
if [ -z "$SLUG" ]; then
    echo "Usage: set-active-plan.sh <slug>"
    echo "Available plans:"
    for d in .plans/*/; do
        [ -d "$d" ] || continue
        n=$(basename "$d")
        case "$n" in .*) continue ;; esac
        [ -f "$d/PLAN.md" ] && echo "  $n"
    done
    exit 1
fi

SLUG_RE='^[A-Za-z0-9_][A-Za-z0-9._-]*$'
if ! printf "%s" "$SLUG" | grep -Eq "$SLUG_RE"; then
    echo "[sys-planner] Error: invalid slug '$SLUG'"
    exit 1
fi

if [ ! -d ".plans/${SLUG}" ]; then
    echo "[sys-planner] Error: .plans/${SLUG}/ does not exist"
    exit 1
fi

printf "%s\n" "$SLUG" > ".plans/.active_plan"
echo "[sys-planner] Active plan set to: $SLUG  (.plans/${SLUG}/)"
exit 0
