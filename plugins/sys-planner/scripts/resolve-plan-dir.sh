#!/bin/sh
# sys-planner: resolve and print the active .plans/ directory.
# Prints the resolved path (no trailing slash) or nothing if no plan found.
# Exit 0 always.

set -u

SLUG_RE='^[A-Za-z0-9_][A-Za-z0-9._-]*$'
RESOLVED=""

# 1. PLAN_ID env
if [ -n "${PLAN_ID:-}" ] && printf "%s" "$PLAN_ID" | grep -Eq "$SLUG_RE" && [ -d ".plans/${PLAN_ID}" ]; then
    RESOLVED=".plans/${PLAN_ID}"
fi

# 2. .active_plan pointer
if [ -z "$RESOLVED" ] && [ -f ".plans/.active_plan" ]; then
    AP=$(tr -d '\r\n[:space:]' < ".plans/.active_plan" 2>/dev/null)
    if [ -n "$AP" ] && printf "%s" "$AP" | grep -Eq "$SLUG_RE" && [ -d ".plans/${AP}" ]; then
        RESOLVED=".plans/${AP}"
    fi
fi

# 3. Newest .plans/<slug>/ with PLAN.md
if [ -z "$RESOLVED" ] && [ -d ".plans" ]; then
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
    [ -n "$NEWEST" ] && RESOLVED="${NEWEST%/}"
fi

# 4. .plans root
if [ -z "$RESOLVED" ] && [ -f ".plans/PLAN.md" ]; then
    RESOLVED=".plans"
fi

[ -n "$RESOLVED" ] && printf "%s\n" "$RESOLVED"
exit 0
