# Can Someone Else Command Your Agent?

5 questions. 2 minutes. If you answer "no" to any of these, strangers can talk to your agent and it will obey.

## The check

| # | Question | Yes / No |
|---|---|---|
| 1 | Have you changed the default dmPolicy and groupPolicy away from the permissive defaults? | |
| 2 | Is your agent's command channel (Telegram, Discord, etc.) restricted to an allowlist of specific user IDs? | |
| 3 | Are you using numeric platform user IDs (not usernames) in your allowlist? | |
| 4 | Have you tested by sending a message from a different account to confirm the agent ignores it? | |
| 5 | If your agent has a web dashboard, is it behind authentication that you control (not just a shared gateway token)? | |

## What "no" means

Every "no" means an unauthorized person can interact with your agent. They can issue prompts, trigger tool use, and potentially exfiltrate data or burn your API budget. This is not theoretical. OpenClaw's default channel policies accept messages from anyone.

If you set up your agent using a guide that said "paste the Telegram BotFather token and you are done," you are exposed. The BotFather token authenticates the bot to Telegram. It does not authenticate users to the bot.

## How to fix it

See the GRITS 5-Layer Zero-Trust Hardening Guide, Layer 2 (Operator Boundary):
https://github.com/rizviz/GRITS/blob/main/apply/openclaw/hardening-baseline.md#layer-2-operator-boundary

---

Scored with GRITS by xScaleAI | https://github.com/rizviz/GRITS
