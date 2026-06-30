#!/bin/sh
# sys-planner: SHA-256 fingerprint PLAN.md and write .attestation.
# Usage: attest-plan.sh [<plan-dir>]
# If no arg, resolves the active plan dir automatically.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd 2>/dev/null)" || SCRIPT_DIR="."
SLUG_RE='^[A-Za-z0-9_][A-Za-z0-9._-]*$'

# Resolve plan dir
if [ -n "${1:-}" ] && [ -d "$1" ]; then
    PLAN_DIR="$1"
else
    RESOLVE="${SCRIPT_DIR}/resolve-plan-dir.sh"
    if [ -f "$RESOLVE" ]; then
        PLAN_DIR=$(sh "$RESOLVE" 2>/dev/null)
    fi
fi

if [ -z "${PLAN_DIR:-}" ] || [ ! -d "$PLAN_DIR" ]; then
    echo "[sys-planner] Error: no active plan directory found."
    echo "Create .plans/PLAN.md first (ext-pnr writes it when you present a plan)."
    exit 1
fi

PLAN_FILE="${PLAN_DIR}/PLAN.md"
ATTEST_FILE="${PLAN_DIR}/.attestation"

if [ ! -f "$PLAN_FILE" ]; then
    echo "[sys-planner] Error: $PLAN_FILE not found."
    exit 1
fi

# Compute SHA-256
HASH=$( (sha256sum "$PLAN_FILE" 2>/dev/null || shasum -a 256 "$PLAN_FILE" 2>/dev/null) | awk '{print $1}')
if [ -z "$HASH" ]; then
    echo "[sys-planner] Error: could not compute SHA-256 (no sha256sum or shasum found)."
    exit 1
fi

printf "%s\n" "$HASH" > "$ATTEST_FILE"
echo "[sys-planner] Attested: $PLAN_FILE"
echo "  SHA-256: $HASH"
echo "  Written to: $ATTEST_FILE"
echo ""
echo "[sys-planner] Hooks will now block injection if PLAN.md changes unexpectedly."
echo "Re-run /plan-attest after any intentional edit to PLAN.md."
exit 0
