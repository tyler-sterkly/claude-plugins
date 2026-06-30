#!/bin/sh
# sys-planner: Test resolve-plan-dir.sh resolution order.
# Usage: sh test-resolve.sh

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd 2>/dev/null)" || SCRIPT_DIR="."
RESOLVE="${SCRIPT_DIR}/../scripts/resolve-plan-dir.sh"
PASS=0; FAIL=0

assert_eq() {
    label="$1"; actual="$2"; expected="$3"
    if [ "$actual" = "$expected" ]; then
        echo "PASS: $label"
        PASS=$((PASS+1))
    else
        echo "FAIL: $label (expected '$expected', got '$actual')"
        FAIL=$((FAIL+1))
    fi
}

assert_empty() {
    label="$1"; output="$2"
    if [ -z "$output" ]; then
        echo "PASS: $label"
        PASS=$((PASS+1))
    else
        echo "FAIL: $label (expected empty, got '$output')"
        FAIL=$((FAIL+1))
    fi
}

TMP=$(mktemp -d 2>/dev/null || echo "/tmp/sys-planner-resolve-test-$$")
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP" || exit 1

# Test 1: Nothing -> empty
out=$(sh "$RESOLVE" 2>&1)
assert_empty "Nothing -> empty" "$out"

# Test 2: .plans/PLAN.md -> .plans
mkdir -p ".plans"
printf "# Plan\n" > ".plans/PLAN.md"
out=$(sh "$RESOLVE" 2>&1)
assert_eq ".plans root" "$out" ".plans"

# Test 3: Named plan dir -> prefer named over root
mkdir -p ".plans/my-task"
printf "# Plan\n" > ".plans/my-task/PLAN.md"
printf "my-task\n" > ".plans/.active_plan"
out=$(sh "$RESOLVE" 2>&1)
assert_eq ".active_plan pointer" "$out" ".plans/my-task"

# Test 4: PLAN_ID env -> prefer PLAN_ID over active_plan
mkdir -p ".plans/other-task"
printf "# Plan\n" > ".plans/other-task/PLAN.md"
out=$(PLAN_ID="other-task" sh "$RESOLVE" 2>&1)
assert_eq "PLAN_ID env" "$out" ".plans/other-task"

# Test 5: .active_plan points to missing dir -> fall through to root
printf "nonexistent\n" > ".plans/.active_plan"
out=$(sh "$RESOLVE" 2>&1)
# Should fall through to newest named plan or root
[ -n "$out" ] && echo "PASS: Missing active_plan falls through" || echo "FAIL: Missing active_plan falls through"
[ -n "$out" ] && PASS=$((PASS+1)) || FAIL=$((FAIL+1))

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" = "0" ] && exit 0 || exit 1
