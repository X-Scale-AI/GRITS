# GRITS

**Governance, Risk, Integrity, Trust, Security**

Open-source AI agent security framework. Score your agent's security posture in 5 minutes. Harden it in 15. Built on DoD/DISA zero-trust principles.

## What this does

GRITS tells you if your AI agent is secure, what is wrong, and how to fix it.

```bash
# 1. Copy the profile template and fill in your agent's details
cp profiles/agent-profile-template.yaml my-agent.yaml

# 2. Score it
python score/grits-report.py my-agent.yaml
```

Output:

```
GRITS Security Report

Agent: My OpenClaw Agent
Profile: Agent | Runtime: openclaw | Environment: production
Scored: 2026-03-20

Overall Posture: Critical (20%)

    ████░░░░░░░░░░░░░░░░ 3/15 controls passing

Findings:
- [CRITICAL] NET-002: Egress restricted to required endpoints
- [CRITICAL] OPR-001: Operator identity verified
- [CRITICAL] APP-001: Tool scope declared with deny-by-default
- [CRITICAL] SEC-001: Secrets isolated from agent filesystem
...

Scored with GRITS v0.1.0 by xScaleAI
```

## Who this is for

**You run an OpenClaw or NemoClaw agent** and want to know if it is actually secure. Most setup guides skip real security. GRITS does not.

**You are building AI agents or LLM apps** and want a clear, practical security standard that does not require reading 200-page PDFs.

**You lead security, platform, or AI governance** and need to understand your agent fleet's posture at scale.

## Quick start

### Option A: Just check your exposure (2 minutes)

Pick the checklist that worries you most:

- [Is your agent network-safe?](checklists/01-network-safety.md)
- [Can someone else command your agent?](checklists/02-operator-identity.md)
- [Do you know what your agent can do?](checklists/03-tool-permissions.md)
- [Are your API keys exposed?](checklists/04-secrets-exposure.md)
- [Is your agent burning money while you sleep?](checklists/05-cost-exposure.md)

### Option B: Full score and harden (15 to 30 minutes)

See [QUICKSTART.md](QUICKSTART.md) for the complete workflow.

### Option C: Automate host hardening

For Docker hosts:

```bash
sudo bash tools/harden-docker.sh
```

For bare-metal or VM hosts:

```bash
sudo bash tools/harden.sh
```

Review the configuration section at the top of each script before running. These are production-grade hardening scripts based on CIS Benchmark and DISA STIG standards.

## What is in this repo

| Folder | What it does | Start here if... |
|---|---|---|
| `checklists/` | 5 quick yes/no security checks, 2 minutes each | you want a fast gut check |
| `profiles/` | Profile templates for agents and LLM apps | you want to score your system |
| `score/` | Scoring scripts that produce JSON and markdown reports | you want a posture score |
| `apply/openclaw/` | 5-Layer Zero-Trust Hardening Guide for OpenClaw | you run OpenClaw and want to fix things |
| `apply/nemoclaw/` | Hardening guidance for NemoClaw (expanding) | you run NemoClaw |
| `tools/` | Host hardening scripts (DoD/DISA grade) | you want automated OS-level hardening |
| `framework/` | GRITS governance framework (control catalog, lifecycle model) | you want the "why" behind the controls |

## The 5-Layer Zero-Trust Model

GRITS secures 5 distinct attack surfaces:

| Layer | Boundary | What GRITS checks |
|---|---|---|
| 1 | Network | Can your agent reach things it should not? |
| 2 | Operator | Can unauthorized people command your agent? |
| 3 | Application | Can your agent use tools you did not approve? |
| 4 | OS / Secrets | Can your agent read your API keys from disk? |
| 5 | Financial | Is your agent burning your API budget unchecked? |

## Why GRITS exists

Most "secure your agent" guides tell you to paste a Telegram token and ask the bot to secure itself. That is not security. GRITS gives you:

- A concrete security standard with 21 controls across 5 layers
- Profile templates so you know what to check
- Scoring tools so you can measure your posture
- A hardening guide with specific remediation steps
- Production-grade scripts based on the same standards used in DoD environments

## The framework beneath

GRITS is built on 5 governance pillars: Governance, Risk, Integrity, Trust, and Security. The control catalog, lifecycle model, and scoring methodology in `framework/` provide the reference specification for teams governing agents at enterprise scale.

For enterprise lifecycle management, fleet governance, and AI Agent SOC capabilities, contact xScaleAI: https://www.xscaleai.com

## Contributing

The most useful contributions right now are:

- Runtime-specific hardening baselines (especially NemoClaw, LangGraph, CrewAI)
- Checklist translations and adaptations for other agent platforms
- Security findings and edge cases from real deployments
- Scoring improvements and additional controls

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

Apache 2.0. See [LICENSE](LICENSE).

---

Created by X Scale AI | https://www.xscaleai.com | https://github.com/X-Scale-AI/GRITS
