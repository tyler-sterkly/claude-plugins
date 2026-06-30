#!/bin/sh
# sys-planner: Append a structured event to the session ledger.
# Usage: ledger-append.sh <event-type> [<data>]
# Event types: tool_call, phase_update, note, error
# The ledger is machine-written JSONL — never inject raw progress.md in gated/autonomous mode.

set -u

EVENT_TYPE="${1:-note}"
DATA="${2:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd 2>/dev/null)" || SCRIPT_DIR="."

# Resolve plan dir
RESOLVE="${SCRIPT_DIR}/resolve-plan-dir.sh"
PLAN_DIR=""
[ -f "$RESOLVE" ] && PLAN_DIR=$(sh "$RESOLVE" 2>/dev/null)
[ -z "$PLAN_DIR" ] && exit 0

# Determine agent/session ID
AGENT_ID="${CLAUDE_AGENT_ID:-${CLAUDE_SESSION_ID:-default}}"
LEDGER_FILE="${PLAN_DIR}/ledger-${AGENT_ID}.jsonl"

# Timestamp (epoch seconds — avoids Date.now() portability issues)
TS=$(date -u '+%s' 2>/dev/null || echo 0)

# Escape data for JSON (basic)
DATA_ESC=$(printf "%s" "$DATA" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g')

printf '{"ts":%s,"type":"%s","data":"%s"}\n' "$TS" "$EVENT_TYPE" "$DATA_ESC" >> "$LEDGER_FILE"
exit 0
