# Is Your Agent Burning Money While You Sleep?

5 questions. 2 minutes. If you answer "no" to any of these, you could wake up to a surprise bill.

## The check

| # | Question | Yes / No |
|---|---|---|
| 1 | Have you set a hard monthly spending limit in your LLM provider's billing console (not just a soft alert)? | |
| 2 | Is auto-reload / auto-topup disabled on your API billing account? | |
| 3 | Do you know your agent's average daily token cost at current usage? | |
| 4 | Is your agent's heartbeat/keepalive function routed to a free local model (like Ollama) instead of your paid API? | |
| 5 | Have you set task retry limits and runtime limits to prevent infinite prompt loops? | |

## What "no" means

Every "no" means your agent can spend money without a ceiling. A prompt loop, a bloated workspace context, or a misconfigured heartbeat can burn through API credits in hours. Default heartbeat functions on some setups ping your paid API continuously, 24/7, even when no one is using the agent.

Running your agent's background maintenance on Claude or GPT-4 is like leaving a taxi meter running overnight. Route heartbeats to a local model (Ollama + llama3.2:3b is free) and reserve expensive models for actual reasoning tasks.

## What this costs you

Quick math for a typical always-on OpenClaw agent:

| Scenario | Estimated monthly cost |
|---|---|
| Heartbeat on Claude 3.5, 18K context, default config | $50 to $200+ depending on frequency |
| Heartbeat on local Ollama, reasoning on Claude only when needed | $5 to $15 |
| No limits, prompt loop overnight | Potentially unbounded |

## How to fix it

See the GRITS 5-Layer Zero-Trust Hardening Guide, Layer 5 (Financial Boundary):
https://github.com/X-Scale-AI/GRITS/blob/main/apply/openclaw/hardening-baseline.md#layer-5-financial-boundary

---

Scored with GRITS by X Scale AI | https://github.com/X-Scale-AI/GRITS
