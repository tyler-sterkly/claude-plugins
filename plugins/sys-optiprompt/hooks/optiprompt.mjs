import { createRequire } from "node:module";

const input = JSON.parse(await new Promise(r => {
  let d = "";
  process.stdin.on("data", c => d += c);
  process.stdin.on("end", () => r(d));
}));

const raw = input?.prompt ?? "";

// Only activate when user appends --optimize
if (!/--optimize\b/i.test(raw)) process.exit(0);

// Strip the flag before doing anything
const prompt = raw.replace(/\s*--optimize\b/gi, "").trim();

const apiKey = process.env.ANTHROPIC_API_KEY;
if (!apiKey) {
  process.stdout.write(JSON.stringify({ transformedPrompt: prompt }));
  process.exit(0);
}

const SYSTEM = `You are a prompt editor. Rewrite the user's prompt to be clearer and more direct. Remove filler words, redundancy, and weak phrasing. Preserve the original intent exactly. Return only the rewritten prompt text with no explanation, preamble, or quotes.`;

try {
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": apiKey,
      "anthropic-version": "2023-06-01",
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: "claude-haiku-4-5-20251001",
      max_tokens: 1024,
      system: SYSTEM,
      messages: [{ role: "user", content: prompt }],
    }),
  });

  if (!res.ok) {
    process.stdout.write(JSON.stringify({ transformedPrompt: prompt }));
    process.exit(0);
  }

  const data = await res.json();
  const optimized = data?.content?.[0]?.text?.trim();

  if (!optimized || optimized === prompt) {
    process.stdout.write(JSON.stringify({ transformedPrompt: prompt }));
    process.exit(0);
  }

  // If >90% word overlap, no meaningful change
  const origWords = new Set(prompt.toLowerCase().split(/\s+/).filter(Boolean));
  const optWords = new Set(optimized.toLowerCase().split(/\s+/).filter(Boolean));
  const intersection = [...origWords].filter(w => optWords.has(w)).length;
  const similarity = intersection / Math.max(origWords.size, optWords.size);
  if (similarity > 0.9) {
    process.stdout.write(JSON.stringify({ transformedPrompt: prompt }));
    process.exit(0);
  }

  const note = `[SYSTEM NOTE: The user requested prompt optimization. Show both versions below and ask which they want to use. Wait for their choice before acting on either.]

ORIGINAL PROMPT:
${prompt}

OPTIMIZED PROMPT:
${optimized}`;

  process.stdout.write(JSON.stringify({ transformedPrompt: note }));
} catch {
  process.stdout.write(JSON.stringify({ transformedPrompt: prompt }));
  process.exit(0);
}
