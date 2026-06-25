# gen-deep-research

Produces a thorough, multi-source research report with adversarially verified claims and inline citations. Fans out web searches, fetches sources, checks for contradictions, then synthesizes a structured report.

## When to trigger

Use this skill when the user asks for:
- Deep research or a detailed report
- Fact-checking on a topic
- A comprehensive investigation of any topic
- "Give me a deep research report on X"
- "Research X thoroughly"
- "Fact-check this claim"
- "Write a detailed investigation into X"

Before invoking, check if the question is specific enough. If underspecified (e.g., "what car to buy" without budget/use-case/region), ask 2-3 clarifying questions to narrow scope. A narrow question produces a better report than a broad one.

## How it works

### Phase 1: Search fan-out

Runs 3-5 parallel web searches using different query angles:
- The direct question
- The question from a skeptical or opposing angle
- Related adjacent topics for context
- Primary sources (official docs, studies, data)
- Recent developments (current year added to surface fresh content)

Collects at minimum 6 distinct sources.

### Phase 2: Source fetch and read

Fetches and reads each search result in full. Extracts:
- Key claims and data points
- Publication date and author/organization
- Whether the source is primary (original research, official docs) or secondary (commentary, aggregation)

Discards paywalled, inaccessible, or clearly low-quality sources.

### Phase 3: Adversarial verification

For each major claim surfaced in Phase 2:
1. Finds at least one confirming source
2. Actively searches for contradicting evidence ("X is false", "X debunked", "problems with X")
3. If contradiction found: notes the disagreement, assesses which source is more authoritative, presents both perspectives
4. If no contradiction found: marks the claim as uncontested

Single-source claims that could not be independently verified are flagged.

### Phase 4: Synthesize report

Writes a structured markdown report:

```
# [Topic]

## Summary
2-3 sentence executive summary.

## Key Findings
- Bullet points of verified facts, each with inline citation

## [Section per major subtopic]
Prose synthesis with inline citations [Source Name](URL).

## Conflicting Evidence
Claims where sources disagree, with both sides cited.

## Sources
Numbered reference list.
```

## Inputs

- A research question or topic (provided by the user)
- Clarifying context if the question was underspecified (budget, region, use case, constraints)

## Outputs

A structured markdown research report with:
- Executive summary
- Key findings with citations
- Per-subtopic prose sections with citations
- Conflicting evidence section (when applicable)
- Full numbered source list

## Rules

- Every factual claim has an inline citation
- Claims supported by only one unverified source are flagged, not stated as fact
- US keyboard characters only (no smart quotes, em dashes, etc.)
- If the topic is too broad to cover thoroughly, the report states what was covered and what was left out
- No editorializing: the report reflects what sources say

## Edge cases and limitations

- Paywalled or inaccessible sources are discarded; the report will note if significant primary sources could not be accessed
- Underspecified questions get clarification questions before any searching begins
- The adversarial verification step may not find contradictions for well-established facts -- that is expected and those claims are marked uncontested
- The quality of the report depends on the quality and availability of web sources

## Related skills

- None directly, but pairs well with `design-frontend-ui` if the report will be turned into a published page
