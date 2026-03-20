# Do You Know What Your Agent Can Do?

5 questions. 2 minutes. If you answer "no" to any of these, your agent has capabilities you have not reviewed.

## The check

| # | Question | Yes / No |
|---|---|---|
| 1 | Is your agent's tool policy set to deny-by-default (not allow-by-default)? | |
| 2 | Do you have an explicit plugins.allow list that names every permitted tool? | |
| 3 | Have you removed or disabled file_write and code_execution if your use case does not require them? | |
| 4 | Have you tested by asking the agent to use a tool NOT on the allow list to confirm it refuses? | |
| 5 | If you installed skills/plugins from a community hub, did you audit the code before enabling them? | |

## What "no" means

Every "no" means your agent can do things you did not explicitly approve. A prompt injection or hallucination could cause the agent to delete files, execute code, access APIs, or install plugins without your knowledge.

"Ask the bot to review the plugin's security" is not an audit. You are asking the potentially compromised system to evaluate its own attack surface. That is like asking the fox to inspect the henhouse.

## How to fix it

See the GRITS 5-Layer Zero-Trust Hardening Guide, Layer 3 (Application Boundary):
https://github.com/X-Scale-AI/GRITS/blob/main/apply/openclaw/hardening-baseline.md#layer-3-application-boundary

---

Scored with GRITS by X Scale AI | https://github.com/X-Scale-AI/GRITS
