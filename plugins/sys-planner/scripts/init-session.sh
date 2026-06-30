#!/bin/sh
# sys-planner: Initialize a planning session.
# Usage: init-session.sh [--gated | --autonomous] [<name>]
# Creates .plans/<slug>/ for named plans, or uses .plans/ root for unnamed.
# Writes .mode, generates .nonce, resets block counter.

set -u

MODE_ARG=""
NAME=""

for arg in "$@"; do
    case "$arg" in
        --gated)     MODE_ARG="autonomous gate" ;;
        --autonomous) MODE_ARG="autonomous" ;;
        -*)          echo "[sys-planner] Unknown option: $arg" ;;
        *)           NAME="$arg" ;;
    esac
done

# Derive slug from name, or auto-generate one
if [ -n "$NAME" ]; then
    SLUG=$(printf "%s" "$NAME" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/[^a-z0-9]/-/g' \
        | sed 's/--*/-/g' \
        | sed 's/^-//; s/-$//')
else
    SLUG=$(awk 'BEGIN{
        srand()
        split("fluffy sleepy purring whiskered fuzzy nimble curious cozy silky playful velvet striped sneaky bouncy zoomie feral chaotic smol tiny nya baka kawaii sugoi chibi doki", adj, " ")
        split("whisker mittens biscuit mochi floof kitten napper purrbox catnip pawbean tabby yawn loaf scruff socks mrow boi dayo gremlin void chan senpai nani ara neko", nou, " ")
        print adj[int(rand()*25)+1] "-" nou[int(rand()*25)+1]
    }' 2>/dev/null)
    [ -z "$SLUG" ] && SLUG="plan-$(date '+%m%d-%H%M' 2>/dev/null || echo 'unnamed')"
fi
PLAN_DIR=".plans/${SLUG}"

# Create directories
mkdir -p "${PLAN_DIR}" 2>/dev/null || { echo "[sys-planner] Error: cannot create ${PLAN_DIR}"; exit 1; }
mkdir -p ".plans/.cache" 2>/dev/null

# Write .mode if set
if [ -n "$MODE_ARG" ]; then
    printf "%s\n" "$MODE_ARG" > "${PLAN_DIR}/.mode"
    echo "[sys-planner] Mode: ${MODE_ARG}"
else
    rm -f "${PLAN_DIR}/.mode" 2>/dev/null
    echo "[sys-planner] Mode: interactive (no gate)"
fi

# Generate nonce for delimiter security
NONCE=""
if command -v openssl >/dev/null 2>&1; then
    NONCE=$(openssl rand -hex 16 2>/dev/null)
elif command -v python3 >/dev/null 2>&1; then
    NONCE=$(python3 -c "import secrets; print(secrets.token_hex(16))" 2>/dev/null)
elif command -v python >/dev/null 2>&1; then
    NONCE=$(python -c "import os,binascii; print(binascii.hexlify(os.urandom(16)).decode())" 2>/dev/null)
fi
if [ -n "$NONCE" ]; then
    printf "%s\n" "$NONCE" > "${PLAN_DIR}/.nonce"
    echo "[sys-planner] Nonce generated"
fi

# Reset block counter
printf "0\n" > "${PLAN_DIR}/.stop_blocks"
rm -f "${PLAN_DIR}/.gate_last_ledger" 2>/dev/null

# Remove stale attestation (plan may have changed since last session)
rm -f "${PLAN_DIR}/.attestation" 2>/dev/null

# Set .active_plan pointer
printf "%s\n" "$SLUG" > ".plans/.active_plan"
echo "[sys-planner] Active plan: ${SLUG}  ->  ${PLAN_DIR}/"

# Copy templates if plan files don't exist yet
TEMPLATES_DIR="${PLAN_DIR}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd 2>/dev/null)" || SCRIPT_DIR="."
TMPL_DIR="${SCRIPT_DIR}/../templates"

for f in PLAN.md FINDINGS.md PROGRESS.md; do
    if [ ! -f "${PLAN_DIR}/${f}" ] && [ -f "${TMPL_DIR}/${f}" ]; then
        cp "${TMPL_DIR}/${f}" "${PLAN_DIR}/${f}" 2>/dev/null && echo "[sys-planner] Created ${PLAN_DIR}/${f} from template"
    fi
done

if [ -n "$MODE_ARG" ]; then
    echo "[sys-planner] Run /plan-attest after finalising PLAN.md (required in ${MODE_ARG} mode)."
fi
echo "[sys-planner] Done."
exit 0
