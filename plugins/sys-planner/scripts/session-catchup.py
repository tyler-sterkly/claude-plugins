#!/usr/bin/env python3
"""
sys-planner: Context recovery after /clear or compaction.
Scans for active .plans/ directory and prints a structured catchup report.

Usage: python3 session-catchup.py [<project-dir>]
"""

import os
import sys
import re
import json
from pathlib import Path
from datetime import datetime


SLUG_RE = re.compile(r'^[A-Za-z0-9_][A-Za-z0-9._-]*$')


def resolve_plan_dir(base: Path) -> Path | None:
    slug_env = os.environ.get('PLAN_ID', '')
    if slug_env and SLUG_RE.match(slug_env):
        d = base / '.plans' / slug_env
        if d.is_dir():
            return d

    active = base / '.plans' / '.active_plan'
    if active.exists():
        slug = active.read_text().strip()
        if slug and SLUG_RE.match(slug):
            d = base / '.plans' / slug
            if d.is_dir():
                return d

    plans = base / '.plans'
    if plans.is_dir():
        candidates = []
        for d in plans.iterdir():
            if not d.is_dir():
                continue
            if d.name.startswith('.'):
                continue
            if not SLUG_RE.match(d.name):
                continue
            if not (d / 'PLAN.md').exists():
                continue
            candidates.append(d)
        if candidates:
            return max(candidates, key=lambda d: d.stat().st_mtime)

    if (base / '.plans' / 'PLAN.md').exists():
        return base / '.plans'

    return None


def tail(path: Path, n: int = 20) -> str:
    try:
        lines = path.read_text(encoding='utf-8', errors='replace').splitlines()
        return '\n'.join(lines[-n:])
    except Exception:
        return ''


def head(path: Path, n: int = 60) -> str:
    try:
        lines = path.read_text(encoding='utf-8', errors='replace').splitlines()
        return '\n'.join(lines[:n])
    except Exception:
        return ''


def ledger_summary(plan_dir: Path) -> str:
    total = 0
    errors = 0
    phase_updates = 0
    last_note = ''
    last_ts = 0

    for lf in plan_dir.glob('ledger-*.jsonl'):
        for line in lf.read_text(errors='replace').splitlines():
            line = line.strip()
            if not line:
                continue
            try:
                obj = json.loads(line)
                total += 1
                t = obj.get('type', '')
                ts = obj.get('ts', 0)
                if t == 'error':
                    errors += 1
                elif t == 'phase_update':
                    phase_updates += 1
                elif t == 'note' and ts > last_ts:
                    last_ts = ts
                    last_note = obj.get('data', '')
            except json.JSONDecodeError:
                pass

    if total == 0:
        return ''
    parts = [f'{total} ledger events ({phase_updates} phase updates, {errors} errors)']
    if last_note:
        parts.append(f'Last note: {last_note}')
    return '\n'.join(parts)


def main():
    base = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.cwd()
    plan_dir = resolve_plan_dir(base)

    if plan_dir is None:
        print('[sys-planner] No active plan found. Run ext-pnr to write .plans/PLAN.md.')
        return

    print('[sys-planner] === SESSION CATCHUP ===')
    print(f'Plan directory: {plan_dir}')
    print()

    mode_file = plan_dir / '.mode'
    if mode_file.exists():
        print(f'Mode: {mode_file.read_text().strip()}')
    else:
        print('Mode: interactive')

    attest_file = plan_dir / '.attestation'
    if attest_file.exists():
        print(f'Attestation: {attest_file.read_text().strip()}')

    print()
    plan_file = plan_dir / 'PLAN.md'
    if plan_file.exists():
        print('--- PLAN.md (first 60 lines) ---')
        print(head(plan_file, 60))
        print()

    progress_file = plan_dir / 'PROGRESS.md'
    if progress_file.exists():
        print('--- PROGRESS.md (last 20 lines) ---')
        print(tail(progress_file, 20))
        print()

    ledger = ledger_summary(plan_dir)
    if ledger:
        print('--- Ledger ---')
        print(ledger)
        print()

    print('[sys-planner] === END CATCHUP ===')
    print('Continue from where you left off. Update PROGRESS.md as you work.')


if __name__ == '__main__':
    main()
