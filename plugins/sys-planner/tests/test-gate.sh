#!/bin/sh
# sys-planner: Test check-complete.sh gate decision table.
# Usage: sh test-gate.sh

set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd 2>/dev/null)" || SCRIPT_DIR="."
CHECK="${SCRIPT_DIR}/../scripts/check-complete.sh"
PASS=0; FAIL=0

assert_contains() {
    label="$1"; output="$2"; needle="$3"
    if printf "%s" "$output" | grep -q "$needle" 2>/dev/null; then
        echo "PASS: $label"
        PASS=$((PASS+1))
    else
        echo "FAIL: $label (expected '$needle', got: $output)"
        FAIL=$((FAIL+1))
    fi
}

assert_not_contains() {
    label="$1"; output="$2"; needle="$3"
    if printf "%s" "$output" | grep -q "$needle" 2>/dev/null; then
        echo "FAIL: $label (did not expect '$needle', got: $output)"
        FAIL=$((FAIL+1))
    else
        echo "PASS: $label"
        PASS=$((PASS+1))
    fi
}

TMP=$(mktemp -d 2>/dev/null || echo "/tmp/sys-planner-gate-test-$$")
mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT
cd "$TMP" || exit 1

# Shared PLAN.md with one in_progress phase
mkdir -p ".plans"
cat > ".plans/PLAN.md" << 'EOF'
# Plan: Test

### Phase 1: Build
- [ ] Do thing
- **Status:** in_progress

### Phase 2: Ship
- [ ] Do other thing
- **Status:** pending
EOF
printf "autonomous gate\n" > ".plans/.mode"
printf "0\n" > ".plans/.stop_blocks"

# Test 1: Guard 1 — no .mode -> continue
rm ".plans/.mode"
out=$(sh "$CHECK" --gate 2>&1)
assert_contains "No .mode -> continue" "$out" '"decision":"continue"'
assert_not_contains "No .mode -> no block" "$out" '"decision":"block"'
printf "autonomous gate\n" > ".plans/.mode"

# Test 2: Guard 2 — no in_progress phases -> continue
cat > ".plans/PLAN.md" << 'EOF'
# Plan: Test

### Phase 1: Build
- **Status:** complete
EOF
out=$(sh "$CHECK" --gate 2>&1)
assert_contains "No in_progress -> continue" "$out" '"decision":"continue"'
cat > ".plans/PLAN.md" << 'EOF'
# Plan: Test

### Phase 1: Build
- **Status:** in_progress
EOF

# Test 3: Guard 3 — stop_hook_active=true -> continue
out=$(printf '{"stop_hook_active":true}' | sh "$CHECK" --gate 2>&1)
assert_contains "stop_hook_active=true -> continue" "$out" '"decision":"continue"'

# Test 4: Guard 4 — cap reached -> continue
printf "20\n" > ".plans/.stop_blocks"
out=$(sh "$CHECK" --gate 2>&1)
assert_contains "Cap reached -> continue" "$out" '"decision":"continue"'
printf "0\n" > ".plans/.stop_blocks"

# Test 5: All guards pass -> block
out=$(sh "$CHECK" --gate 2>&1)
assert_contains "All guards pass -> block" "$out" '"decision":"block"'

# Test 6: Advisory mode (no --gate) -> never blocks
cat > ".plans/PLAN.md" << 'EOF'
# Plan: Test

### Phase 1: Build
- **Status:** in_progress
EOF
out=$(sh "$CHECK" 2>&1)
assert_not_contains "Advisory -> no block decision" "$out" '"decision":"block"'

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" = "0" ] && exit 0 || exit 1
