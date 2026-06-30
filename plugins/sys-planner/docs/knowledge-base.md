# sys-planner — Knowledge Base

Design rationale, platform behavior differences, and operational notes.

---

## Why PNR_ENABLED is the gate (not a slash command)

The original planning-with-files required running init-session.sh before every task to activate
context injection. PNR_ENABLED is already in settings.json and ext-pnr already writes PLAN.md —
so the trigger is implicit. You asked for a plan, PNR wrote it, injection is now live. Nothing
extra to remember.

The only time you need an explicit command is for gated or autonomous mode (init-session.sh), and
for named plans when working on multiple parallel tasks.

---

## Turn-start vs PreToolUse injection

**Turn-start (UserPromptSubmit):** fires once when you send a message. Claude sees the plan head
and recent progress at the top of each turn. This is enough for interactive sessions where you are
actively directing the work.

**PreToolUse:** fires before every individual tool call within a turn. In a long unattended run,
Claude might make 50+ tool calls in a single turn. Turn-start injection gets one hit at the start;
if the plan context fades mid-turn, PreToolUse re-anchors it before each call.

Token cost of PreToolUse: ~68% increase in token usage measured in the upstream plugin. This is
real. Off by default in interactive mode. Activates only when .mode file is present
(gated or autonomous).

---

## Why .plans/ not project root

The original wrote task_plan.md directly to the repo root. Root clutter is noise — planning state
has nothing to do with the shipped project. .plans/ groups all planning state together, is
gitignored by the global dot-prefix rule, and works regardless of repo structure.

.plans/.cache/ stores timestamped PLAN.md archives. .cache/ is also dot-prefixed, so it is also
gitignored. The global gitignore rule covers all dot-prefix directories recursively.

---

## All-uppercase file names

PLAN.md, FINDINGS.md, PROGRESS.md, REPORT.md — uppercase matches the PNR convention. ext-pnr
writes PLAN.md and REPORT.md, sys-planner reads them. Consistent casing avoids the ambiguity
between task_plan.md (upstream) and our files.

---

## What REPORT.md is for

REPORT.md contains the same content as PLAN.md at the time ext-pnr writes it. It is not injected
into context — it exists as a snapshot for review, not for active planning. There is no timestamped
cache copy of REPORT.md (only PLAN.md gets the cache treatment).

---

## Gated mode — platform behavior differences

The hard gate works by returning {"decision":"block"} from the Stop hook event. This is a Claude
Code-specific protocol.

| Platform tier | Examples | Gate behavior |
|---|---|---|
| Tier 1: hard block | Claude Code, Codex CLI | {"decision":"block"} prevents turn end — true gate |
| Tier 2: soft nudge | Cursor, Kiro, Pi | follow-up message injected after stop; Claude has already stopped but gets nudged to restart |
| Tier 3: notify only | OpenCode, Gemini CLI | system message printed; no enforcement whatsoever |

Tier 2 is not a true gate. The stop has already occurred by the time the nudge fires. Claude may or
may not restart depending on the tool's loop behavior. Do not rely on Tier 2 enforcement for
unattended critical tasks.

Tier 3 is notification only. There is no workaround that produces true gate behavior on Tier 3
platforms. Use Tier 1 (Claude Code) for anything that requires reliable gate enforcement.

---

## Gate decision table — all five guards must pass to block

| Guard | Check | Fails (allows stop) when |
|---|---|---|
| 1 | .mode contains "gate" | .mode absent or does not contain "gate" |
| 2 | phase with Status: in_progress exists | no in_progress phases in PLAN.md |
| 3 | stop_hook_active not true in hook JSON | hook system is already in forced continuation |
| 4 | .stop_blocks below cap (default 20) | cap reached (configurable via PWF_GATE_CAP env) |
| 5 | ledger line count advanced since last block | no progress since last block (stall detected) |

Guard 5 prevents infinite loops. If Claude is blocked but making no progress (ledger unchanged),
the gate allows stop after two consecutive stall checks. This avoids Claude being permanently stuck
on a broken task with no escape.

---

## Attestation and why it matters for unattended runs

In a long unattended loop, PLAN.md is injected before every turn. If anything writes to PLAN.md
outside of Claude (another process, a tool output accidentally written there, a prompt-injected
response that tries to update the plan maliciously), that content gets injected repeatedly.

Attestation SHA-256 fingerprints PLAN.md at approval time. The hook verifies the hash on every
injection. If the file changed without re-attest, injection is blocked with [PLAN TAMPERED] and the
expected vs actual hashes are printed.

For interactive sessions: opt-in. Run /plan-attest after finalising the plan.
For gated/autonomous mode: required. The hook enforces this — it will block injection and warn if
no .attestation file exists.

Re-run /plan-attest after any intentional edit to PLAN.md.

---

## Nonce delimiters

Without nonces, the plan content is wrapped in static delimiters (===BEGIN PLAN DATA===). A
malicious fetched page or crafted input could end the delimiter prematurely and inject content
as if it were outside the plan block.

Nonces make the delimiter unpredictable per session. They are generated by init-session.sh using
openssl/python and stored in .plans/.nonce. The hook reads the nonce and wraps plan content in
===BEGIN-PLAN-DATA-<nonce>=== delimiters. An adversary cannot predict the nonce without reading the
local filesystem.

---

## Ledger vs PROGRESS.md

PROGRESS.md is a human-readable session log written by Claude. In gated/autonomous mode, injecting
the raw PROGRESS.md tail is risky — anything Claude writes there could contain fetched content or
instructions, which get re-injected every turn and amplified.

ledger-*.jsonl files are machine-written, append-only JSONL logs (one per agent session). They
contain only structured typed events with no free text. ledger-summary.sh synthesizes them into a
compact, cache-stable block for injection in gated/autonomous mode.

The gate's stall detector reads ledger line count, not PROGRESS.md. This keeps the stall signal
clean and unmanipulable.

---

## sync-platforms.py

The upstream plugin ships skill files for 10+ AI tools (.cursor, .kiro, .continue, .codex, etc.).
Editing SKILL.md, scripts, and templates in 10 places manually is error-prone. sync-platforms.py
reads the canonical scripts/ and templates/ and propagates them to each platform directory,
applying any path or format transforms needed per platform.

Run sync-platforms.py after any change to SKILL.md or the scripts/templates directories.

---

## session-catchup.py

When you run /clear or after context compaction, Claude loses all in-session memory. The plan file
still exists on disk, but Claude does not know where to look or what happened before.

Run `python3 scripts/session-catchup.py` from the project directory. It resolves the active plan
dir, prints the plan head, recent progress, and ledger summary — giving Claude enough context to
continue without re-reading the full conversation history.

---

## Exiting gated mode

- Mark the in_progress phase complete in PLAN.md — guard 2 fails on next stop — stop allowed.
- Delete .plans/.mode — gate disables immediately regardless of phase status.
- Cap exhaustion (PWF_GATE_CAP blocks, default 20) — guard 4 fails — stop allowed automatically.
- Stall detection (ledger unchanged) — guard 5 fails — stop allowed automatically.

There is no "force stop" command. Use one of the above.
