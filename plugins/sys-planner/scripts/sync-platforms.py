#!/usr/bin/env python3
"""
sys-planner: Sync core skill files to all platform-specific directories.
Run after editing scripts\ or templates\ to keep .cursor, .kiro, .continue, etc. in sync.

Usage: python3 sync-platforms.py [--dry-run]
"""

import os
import sys
import shutil
from pathlib import Path

DRY_RUN = '--dry-run' in sys.argv

SCRIPT_DIR = Path(__file__).parent.resolve()
PLUGIN_DIR = SCRIPT_DIR.parent

# Platform directories to sync into (relative to the project root where .plans/ lives)
# Each platform gets a copy of the skill so its native AI tool can find it.
PLATFORM_DIRS = [
    '.cursor/rules',
    '.kiro/steering',
    '.github/copilot-instructions',
    '.continue/config',
    '.codex',
]

# Files to sync from scripts\ (copied verbatim)
SYNC_SCRIPTS = [
    'inject-plan.sh',
    'check-complete.sh',
    'gate-stop.sh',
    'resolve-plan-dir.sh',
    'ledger-append.sh',
    'ledger-summary.sh',
    'attest-plan.sh',
    'session-catchup.py',
]

# Templates to sync
SYNC_TEMPLATES = [
    'PLAN.md',
    'FINDINGS.md',
    'PROGRESS.md',
]

# Canonical SKILL.md — synced as platform-specific instruction file
SKILL_MD = PLUGIN_DIR / 'SKILL.md'


def sync_file(src: Path, dst: Path) -> None:
    if not src.exists():
        print(f'  SKIP (missing): {src}')
        return
    if dst.exists():
        if src.read_bytes() == dst.read_bytes():
            print(f'  unchanged: {dst.name}')
            return
    if DRY_RUN:
        print(f'  [dry-run] would copy {src.name} -> {dst}')
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)
    print(f'  synced: {dst.name}')


def main():
    # Find project root (the directory above which .plans/ would live)
    # Walk up from PLUGIN_DIR to find a .plans/ or settle for cwd.
    project_root = Path.cwd()
    for parent in [Path.cwd()] + list(Path.cwd().parents):
        if (parent / '.plans').exists():
            project_root = parent
            break

    print(f'sys-planner sync-platforms')
    print(f'  Plugin source: {PLUGIN_DIR}')
    print(f'  Project root:  {project_root}')
    print(f'  Dry run:       {DRY_RUN}')
    print()

    scripts_src = PLUGIN_DIR / 'scripts'
    templates_src = PLUGIN_DIR / 'templates'

    for platform in PLATFORM_DIRS:
        dst_dir = project_root / platform / 'sys-planner'
        print(f'Platform: {platform}')

        # Sync SKILL.md as the platform instruction file
        sync_file(SKILL_MD, dst_dir / 'SKILL.md')

        # Sync scripts
        for name in SYNC_SCRIPTS:
            sync_file(scripts_src / name, dst_dir / 'scripts' / name)

        # Sync templates
        for name in SYNC_TEMPLATES:
            sync_file(templates_src / name, dst_dir / 'templates' / name)

        print()

    print('Done.')


if __name__ == '__main__':
    main()
