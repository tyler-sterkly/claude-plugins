---
name: gen-deep-research
description: Deep research harness -- fan-out web searches, fetch sources, adversarially verify claims, synthesize a cited report. Use when the user wants a deep, multi-source, fact-checked research report on any topic. BEFORE invoking, check if the question is specific enough to research directly -- if underspecified (e.g. "what car to buy" without budget/use-case/region), ask 2-3 clarifying questions to narrow scope. Triggers when the user asks for deep research, a detailed report, fact-checking, or a comprehensive investigation of any topic.
version: 1.0.0
license: MIT
---

# Deep Research

Produce a thorough, multi-source research report with adversarially verified claims and inline citations.

## Before Starting

If the question is underspecified (no budget/region/use-case/constraints), ask 2-3 clarifying questions before searching. A narrow question produces a better report than a broad one.

## Phase 1 -- Search Fan-Out

Run 3-5 parallel web searches using different query angles:
- The direct question
- The question from a skeptical or opposing angle
- Related adjacent topics that provide context
- Primary sources (official docs, studies, data)
- Recent developments (add the current year to surface fresh content)

Collect at minimum 6 distinct sources.

## Phase 2 -- Source Fetch and Read

For each search result, fetch and read the full source page. Extract:
- Key claims and data points
- Publication date and author/organization
- Whether the source is primary (original research, official docs) or secondary (commentary, aggregation)

Discard sources that are paywalled, inaccessible, or clearly low-quality.

## Phase 3 -- Adversarial Verification

For each major claim surfaced in Phase 2:
1. Find at least one source that confirms it
2. Actively search for contradicting evidence ("X is false", "X debunked", "problems with X")
3. If contradiction is found: note the disagreement, assess which source is more authoritative, and present both perspectives
4. If no contradiction found after searching: mark the claim as uncontested

Flag any claims that rest on a single unverified source.

## Phase 4 -- Synthesize Report

Write a structured markdown report:

```
# [Topic]

## Summary
2-3 sentence executive summary of the key finding.

## Key Findings
- Bullet points of the most important verified facts
- Each claim linked to its source inline

## [Section per major subtopic]
Prose synthesis with inline citations [Source Name](URL).

## Conflicting Evidence
Note any claims where sources disagree, with both sides cited.

## Sources
Numbered reference list of all sources used.
```

## Rules

- Every factual claim must have an inline citation
- Never state something as fact if only one unverified source supports it
- Use plain US-keyboard characters only (no smart quotes, em dashes, etc.)
- If the topic is too broad to cover thoroughly, state what was covered and what was left out
- Do not editorialize -- report what the sources say
