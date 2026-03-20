# Hardening Your OpenClaw Agent: The 5-Layer Zero-Trust Guide

Your agent is only as secure as its weakest boundary. Most "secure OpenClaw setup" guides stop at deployment. This guide secures 5 distinct attack surfaces that real-world agent compromises exploit.

Built on the same zero-trust principles used in DoD/DISA environments. Adapted for AI agent hosts by xScaleAI.

## Before you start

You need:

- A running OpenClaw deployment (Docker or bare metal)
- Root/sudo access to the host
- 15 to 30 minutes

You should already have:

- A working SSH key for your host
- Your LLM provider API key(s) ready (do NOT paste them into chat or config files yet)

## The 5 layers

Every layer answers one question: "If this boundary fails, what can the attacker reach?"

| Layer | Boundary | The threat if unprotected | What you will do |
|---|---|---|---|
| 1 | Network | Agent scans or attacks your local infrastructure | Lock outbound traffic to only what the agent needs |
| 2 | Operator | Unauthorized users issue commands to your agent | Verify identity before any command is processed |
| 3 | Application | Agent executes rogue code or uses unwanted tools | Deny all tools by default, allow only what is declared |
| 4 | OS / Secrets | Workspace leakage exposes your API keys | Move keys off the filesystem entirely |
| 5 | Financial | Context bloat or idle loops drain your API budget | Cap costs and offload background tasks to free models |

## Layer 1: Network Boundary

**The problem:** By default, a machine can talk to anything it can route to. If a prompt injection tricks your agent into executing a network scan, it could map your home router, smart devices, or NAS.

**What to do:**

1. Enable UFW (or your host firewall) with a default-deny outbound policy
2. Allow outbound HTTPS (port 443) to your LLM provider and any APIs the agent legitimately needs
3. Block all outbound traffic to private IP ranges (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
4. Allow inbound SSH only from your specific subnet or VPN
5. Allow inbound on your agent's application port only from your subnet or VPN

**Why this matters:** The blast radius of any agent compromise is caged to the VM. It cannot reach your physical network.

**Quick check:**

- Can your agent reach your router's admin page? If yes, you are exposed.
- Can your agent reach other machines on your LAN? If yes, you are exposed.
- Is your agent's management port open to the internet? If yes, you are exposed.

**Reference implementation:** See `tools/harden-docker.sh` Phase 2 (Firewall) and `tools/harden.sh` Phase 4 (Firewall) for production-ready UFW configurations.

## Layer 2: Operator Boundary

**The problem:** If your agent is exposed on a platform like Telegram, anyone who finds the username can start interacting with it. Default OpenClaw channel policies (dmPolicy, groupPolicy) are permissive. Your agent will respond to strangers by default.

**What to do:**

1. Reject default permissive channel policies. Inside `openclaw.json`, set both `dmPolicy` and `groupPolicy` to `allowlist` (not the defaults)
2. Hardcode your specific user ID into the allowlist. For Telegram, this is your numeric Telegram User ID, not your username.
3. If the platform supports it, require cryptographic identity verification (Telegram's user ID is server-verified)
4. Test by sending a message from a different account. The agent should ignore it completely.

**Why this matters:** The gateway drops unauthorized messages at the door. The LLM never even sees them. Zero token cost, zero risk of prompt injection from strangers.

**Quick check:**

- Can a stranger send your agent a message and get a response? If yes, you are exposed.
- Is your agent using default dmPolicy/groupPolicy? If yes, you are exposed.
- Do you know your own platform user ID (not username)? If no, your allowlist is probably wrong.

## Layer 3: Application Boundary

**The problem:** OpenClaw's power comes from tools (web search, file reading, code execution). If left with a permissive tool policy, the LLM decides when and how to use them. A prompt injection could instruct the agent to read sensitive files, delete data, or execute arbitrary code.

**What to do:**

1. Unset any generic `tools.policy` that defaults to "allow all"
2. Create a hardcoded `plugins.allow` array listing ONLY the tools your agent needs
3. Set extensions to allow only explicitly defined ones (e.g., `telegram`, `openclaw-freerouter`, `openclaw-tavily`)
4. Never grant `file_write` or `code_execution` unless your use case absolutely requires it, and if it does, scope it to specific directories
5. Test by asking the agent to use a tool not in the allow list. It should refuse.

**Why this matters:** We do not rely on the LLM's system prompt to decide what tools to use. We physically remove access to tools it should not have. The LLM cannot use what does not exist in its environment.

**Quick check:**

- Does your agent have access to tools you have not explicitly reviewed? If yes, you are exposed.
- Can your agent execute arbitrary code on the host? If yes, you are exposed.
- Is your tool policy "allow by default" or "deny by default"? If allow, you are exposed.

## Layer 4: OS and Secrets Boundary

**The problem:** Standard setups leave API keys (OpenRouter, Anthropic, Tavily, etc.) sitting in plain text JSON configuration files inside the user's home directory or the agent's workspace. If the agent reads its own workspace, or if a script goes rogue, your credentials are stolen.

**What to do:**

1. Remove all API keys from any file the agent can read. No `.env` files in the workspace. No keys in `openclaw.json`.
2. Store keys in a root-owned secrets file (e.g., `/etc/openclaw/secrets.env`) with strict file permissions (mode 600, owned by root)
3. Use systemd's `EnvironmentFile` directive to inject secrets into the agent's process memory at startup. The agent gets the keys in its environment but cannot read them from the filesystem.
4. If you are on Docker, use Docker secrets or mount the secrets file as read-only with restricted permissions.
5. Verify by trying to `cat` the secrets file as the agent's user. It should fail with "Permission denied."

**Why this matters:** The agent has the authorization it needs at runtime, but the keys do not exist in any file the agent can access. A compromised agent cannot exfiltrate what it cannot read.

**Quick check:**

- Are your API keys in a file inside the agent's workspace or home directory? If yes, you are exposed.
- Can the agent's process user read the secrets file directly? If yes, you are exposed.
- Are your keys in environment variables set in a docker-compose.yml checked into git? If yes, you are exposed.

**Reference implementation:** See `tools/harden.sh` Phase 10 (Application Directory and Secrets) for tmpfs-based secret mounting and age encryption patterns.

## Layer 5: Financial Boundary

**The problem:** A capable agent carrying a large workspace context (18,000+ tokens) into every API call will burn through your budget fast. Default heartbeat functions ping expensive APIs continuously just to keep the agent alive. One bad prompt loop can cost hundreds of dollars overnight.

**What to do:**

1. Strip the workspace context to essentials. Use static files and prompt caching (Anthropic supports this) to drop redundant context by up to 90% on subsequent turns.
2. Point background/heartbeat tasks to a free, local model. Run Ollama with a small model (e.g., llama3.2:3b) locally and route the `heartbeat_model` configuration to it. Heavy reasoning goes to Claude/GPT. Maintenance tasks cost zero.
3. Set explicit daily token limits and monthly budget caps in your LLM provider's console.
4. Disable auto-reload/auto-topup on your API billing account.
5. Set up cost alerts at 50% and 80% of your monthly budget.

**Why this matters:** Heavy-hitter reasoning costs pennies per task. Background maintenance costs zero dollars. Runaway loops hit a ceiling before they drain your account.

**Quick check:**

- Do you have a monthly spending limit set with your LLM provider? If no, you are exposed.
- Is your agent using an expensive model for heartbeat/keepalive tasks? If yes, you are burning money.
- Have you calculated your agent's daily token cost at current usage? If no, you do not know your exposure.

## After hardening

Once you have addressed all 5 layers:

1. Fill out a GRITS agent profile for your deployment: `profiles/agent-profile-template.yaml`
2. Run the GRITS security score: `python score/grits-security-score.py your-profile.yaml`
3. Review your scorecard and address any remaining findings
4. Re-score to confirm improvement

## What this guide does NOT cover

This guide covers host and agent boundary hardening. It does not cover:

- Multi-agent orchestration governance
- Lifecycle management for agent fleets
- Enterprise registry and ownership tracking
- Runtime behavioral monitoring

These are addressed in the GRITS governance framework: see `framework/` for the reference specifications, or contact xScaleAI for enterprise implementation guidance.

---

Built on DoD/DISA zero-trust principles. Open-sourced by xScaleAI as part of the GRITS framework.

https://github.com/rizviz/GRITS | https://www.xscaleai.com
