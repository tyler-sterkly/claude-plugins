#!/bin/sh
# sys-planner: Test inject-plan.sh behavior.
# Usage: sh test-inject.sh
# Tests: PNR_ENABLED gate, missing PLAN.md, successful injection, pretool skip in interactive mode.

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd 2>/dev/null)" || SCRIPT_DIR="."
INJECT="${SCRIPT_DIR}/../scripts/inject-plan.sh"
PASS=0; FAIL=0

assert_empty() {
    label="$1"; output="$2"
    if [ -z "$output" ]; then
        echo "PASS: $label"
        PASS=$((PASS+1))
    else
        echo "FAIL: $label (expected empty, got: $output)"
        FAIL=$((FAIL+1))
    fi
}

assert_contains() {
    label="$1"; output="$2"; needle="$3"
    if printf "%s" "$output" | grep -q "$needle" 2>/dev/null; then
        echo "PASS: $label"
        PASS=$((PASS+1))
    else
        echo "FAIL: $label (expected '$needle' in output)"
        FAIL=$((FAIL+1))
    fi
}

# Setup tmp dir
TMP=$(mktemp -d 2>/dev/null || echo "/tmp/sys-planner-test-$$")
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP" || exit 1

# Test 1: PNR_ENABLED not set -> silent exit
out=$(PNR_ENABLED="" sh "$INJECT" --context=userprompt 2>&1)
assert_empty "PNR_ENABLED not set -> silent" "$out"

# Test 2: PNR_ENABLED=false -> silent exit
out=$(PNR_ENABLED="false" sh "$INJECT" --context=userprompt 2>&1)
assert_empty "PNR_ENABLED=false -> silent" "$out"

# Test 3: PNR_ENABLED=true but no .plans/PLAN.md -> silent exit
out=$(PNR_ENABLED="true" sh "$INJECT" --context=userprompt 2>&1)
assert_empty "No PLAN.md -> silent" "$out"

# Test 4: PLAN.md exists -> injection fires
mkdir -p ".plans"
printf "# Plan: Test\n\n## Phase 1\n- **Status:** in_progress\n" > ".plans/PLAN.md"
out=$(PNR_ENABLED="true" sh "$INJECT" --context=userprompt 2>&1)
assert_contains "PLAN.md exists -> injects" "$out" "sys-planner"
assert_contains "Plan content injected" "$out" "Phase 1"

# Test 5: pretool context without .mode -> silent (interactive mode)
out=$(PNR_ENABLED="true" sh "$INJECT" --context=pretool 2>&1)
assert_empty "pretool + no .mode -> silent" "$out"

# Test 6: pretool context with .mode=gated -> injects
printf "autonomous gate\n" > ".plans/.mode"
out=$(PNR_ENABLED="true" sh "$INJECT" --context=pretool 2>&1)
assert_contains "pretool + gated mode -> injects" "$out" "Phase 1"

# Test 7: precompact -> flush reminder
out=$(PNR_ENABLED="true" sh "$INJECT" --context=precompact 2>&1)
assert_contains "precompact -> flush reminder" "$out" "PreCompact"

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" = "0" ] && exit 0 || exit 1
