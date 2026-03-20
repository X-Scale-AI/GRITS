# Securing Your NemoClaw Agent with GRITS

NemoClaw provides container-level sandboxing and declarative YAML policies for AI agents. GRITS adds governance layers on top: identity verification, secret isolation, cost controls, lifecycle management, and continuous posture scoring.

## Start here

The GRITS scoring and hardening workflow is the same regardless of runtime:

1. Copy `profiles/agent-profile-template.yaml` and fill in your agent's details
2. Run `python score/grits-report.py your-agent.yaml`
3. Address findings using the guidance below

## What NemoClaw provides vs. what GRITS adds

| Concern | NemoClaw coverage | GRITS adds |
|---|---|---|
| Container isolation | Sandbox via Docker/k3s | Host-level firewall hardening, private subnet blocking |
| Tool policy | Declarative YAML allowlists | Deny-by-default verification, posture scoring |
| Credential handling | Environment variable injection | Filesystem isolation, runtime-only injection, exfiltration prevention |
| Identity and access | Single-player mode (no native RBAC) | Operator identity verification, allowlist enforcement |
| Cost controls | Not addressed | Token limits, budget caps, idle cost offloading |
| Audit and monitoring | Terminal UI, local logs | Structured event model, evidence requirements, SIEM-ready signals |
| Lifecycle governance | Not addressed | State tracking, recertification, ownership accountability |
| Posture measurement | Not addressed | 21-control scorecard, severity-ranked findings, remediation priority |

## NemoClaw-specific hardening guidance

Expanding. The 5-Layer Zero-Trust model applies to NemoClaw environments with the following adaptations:

- **Layer 1 (Network):** NemoClaw's network policies control sandbox egress but do not address host-level firewall rules. Apply host firewall hardening in addition to sandbox policies.
- **Layer 2 (Operator):** NemoClaw is currently single-player with no native RBAC. Operator identity must be enforced at the application or gateway layer.
- **Layer 3 (Application):** NemoClaw's YAML policy engine handles tool scoping. Verify that policies are deny-by-default and test with unauthorized tool requests.
- **Layer 4 (OS/Secrets):** NemoClaw injects credentials as environment variables. Evaluate whether your setup prevents the agent from dumping its own environment.
- **Layer 5 (Financial):** Not addressed by NemoClaw. Apply cost guardrails at the LLM provider level.

For the full hardening guide (written for OpenClaw but applicable in principle):
[5-Layer Zero-Trust Hardening Guide](../openclaw/hardening-baseline.md)

## Contribute

If you are running NemoClaw in production or testing, your hardening experience is valuable. See [CONTRIBUTING.md](../../CONTRIBUTING.md).
