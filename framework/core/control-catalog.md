# GRITS Control Catalog

## How to read this catalog

Every control has three attributes:

- **Layer**: the implementation surface where you apply it (Network, Operator, Application, OS/Secrets, Financial, or Cross-cutting)
- **Pillar**: the GRITS governance principle it serves (Governance, Risk, Integrity, Trust, Security)
- **Expectation**: what "passing" looks like in practice

Controls prefixed with NET, OPR, APP, SEC, FIN map to the 5-Layer Zero-Trust hardening model. Controls prefixed with GOV are cross-cutting governance controls that apply regardless of layer.

## Layer 1: Network Controls

| ID | Title | Pillar(s) | Expectation |
|---|---|---|---|
| NET-001 | Network exposure reviewed | Security, Risk | Reachable services and management paths have been deliberately reviewed and documented |
| NET-002 | Egress restricted to required endpoints | Security | Outbound traffic is limited to explicitly required destinations (LLM APIs, package repos). Default-deny outbound. |
| NET-003 | Private subnet access blocked | Risk | Agent host cannot initiate connections to private IP ranges (192.168.x.x, 10.x.x.x, 172.16-31.x.x) |
| NET-004 | Management port protected | Security | Agent dashboard/web UI accessible only from operator's subnet or VPN, not the public internet |

## Layer 2: Operator Controls

| ID | Title | Pillar(s) | Expectation |
|---|---|---|---|
| OPR-001 | Operator identity verified | Governance, Trust | Only verified user IDs can issue commands to the agent. Platform-level identity (not just usernames). |
| OPR-002 | Default permissive policies rejected | Governance | Default channel policies (dmPolicy, groupPolicy) have been overridden with restrictive settings |
| OPR-003 | Command authority restricted to allowlist | Trust | Agent ignores messages from user IDs not on the allowlist. Tested with an unauthorized account. |

## Layer 3: Application Controls

| ID | Title | Pillar(s) | Expectation |
|---|---|---|---|
| APP-001 | Tool scope declared with deny-by-default | Integrity, Security | A plugins.allow or equivalent allowlist exists. Tools not listed are unavailable. |
| APP-002 | Plugin allowlist enforced | Integrity | Only declared extensions/plugins can be loaded. No dynamic plugin installation without review. |
| APP-003 | Dangerous capabilities scoped or removed | Risk, Security | file_write, code_execution, and similar high-risk tools are disabled unless explicitly required and scoped to specific directories |

## Layer 4: OS and Secrets Controls

| ID | Title | Pillar(s) | Expectation |
|---|---|---|---|
| SEC-001 | Secrets isolated from agent filesystem | Security | API keys do not exist in any file the agent process user can read |
| SEC-002 | Secrets injected at runtime only | Security, Risk | Credentials are delivered to the agent process via systemd EnvironmentFile, Docker secrets, or equivalent. Not via static files. |
| SEC-003 | Host file permissions hardened | Security | Agent process runs as an unprivileged user. OS file permissions prevent access outside the agent's working directory. |

## Layer 5: Financial Controls

| ID | Title | Pillar(s) | Expectation |
|---|---|---|---|
| FIN-001 | Cost guardrails defined | Risk, Governance | Daily token limits and/or monthly budget caps are set in the LLM provider's billing console |
| FIN-002 | Idle cost minimized | Risk | Heartbeat, keepalive, and background maintenance tasks are routed to a free or local model (e.g., Ollama) |
| FIN-003 | Budget accountability assigned | Governance | An owner is responsible for monitoring and approving API spend for this agent |

## Cross-cutting Governance Controls

| ID | Title | Pillar(s) | Expectation |
|---|---|---|---|
| GOV-001 | Owner assigned | Governance | Every governed agent or LLM app has a named, accountable owner |
| GOV-002 | Deputy owner assigned | Governance, Trust | Production or high-impact systems have a backup owner for continuity |
| GOV-003 | Recertification date set | Governance | Active systems have a future review date. Recommended: 90 days. |
| GOV-004 | Monitoring enabled | Trust, Risk | Runtime logs, events, or telemetry are captured for the governed system |
| GOV-005 | Policy violation visibility enabled | Integrity, Trust | Material policy or scope violations can be detected and surfaced |

## Totals

| Layer | Controls | IDs |
|---|---|---|
| Network | 4 | NET-001 through NET-004 |
| Operator | 3 | OPR-001 through OPR-003 |
| Application | 3 | APP-001 through APP-003 |
| OS/Secrets | 3 | SEC-001 through SEC-003 |
| Financial | 3 | FIN-001 through FIN-003 |
| Cross-cutting | 5 | GOV-001 through GOV-005 |
| **Total** | **21** | |

## GRITS Pillar Coverage

| Pillar | Controls that serve it |
|---|---|
| Governance | OPR-001, OPR-002, FIN-001, FIN-003, GOV-001, GOV-002, GOV-003 |
| Risk | NET-001, NET-003, APP-003, SEC-002, FIN-001, FIN-002, GOV-004 |
| Integrity | APP-001, APP-002, GOV-005 |
| Trust | OPR-001, OPR-003, GOV-002, GOV-004, GOV-005 |
| Security | NET-001, NET-002, NET-004, APP-001, APP-003, SEC-001, SEC-002, SEC-003 |
