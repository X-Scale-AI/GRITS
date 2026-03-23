# GRITS

**Governance, Risk, Integrity, Trust, Security**

You are deploying AI agents. No one has told you what "secure" looks like for them. GRITS does.

GRITS is the open standard for AI agent security and governance. It defines 21 controls across 5 zero-trust layers, a lifecycle model with explicit governance gates, and compliance mappings to NIST AI RMF, NIST AI 600-1, OWASP LLM Top 10 2025, and OWASP Agentic Top 10 2026. Built on DoD/DISA zero-trust principles.

**Start in 5 minutes:** [GRITS Baseline](framework/assessment/grits-baseline.md) -- the 5 Critical controls every agent must satisfy before anything else.

**Run automated scans:** [grits-agent-scanner](https://github.com/X-Scale-AI/grits-agent-scanner) -- the full scan-score-remediate implementation of this framework.

---

## The 5-Layer Zero-Trust Model

| Layer | Boundary | Threat |
|---|---|---|
| 1 Network | Host firewall / egress policy | Agent scans or attacks local infrastructure |
| 2 Operator | Identity verification | Unauthorized users command the agent |
| 3 Application | Tool permissions / filesystem | Agent executes rogue code |
| 4 OS / Secrets | Credential isolation | Workspace leakage exposes API keys |
| 5 Financial | Cost containment | Context bloat or idle loops drain budget |

21 controls. 5 layers. Explicit pass/fail expectations for each.

## Declare your posture

Once you have scored your agent, add a badge to your repo:

```markdown
![GRITS Score](https://img.shields.io/badge/GRITS-87%25%20Strong-green?logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyTDMgN3YxMGw5IDUgOS01VjdsLTktNXoiLz48L3N2Zz4=)
```

Replace `87%25%20Strong` with your score and band. Badge colors:

| Posture band | Score | Badge color |
|---|---|---|
| Exemplary | 90-100% | `brightgreen` |
| Strong | 75-89% | `green` |
| Adequate | 60-74% | `yellowgreen` |
| Developing | 40-59% | `yellow` |
| Poor | 20-39% | `orange` |
| Critical | 0-19% | `red` |

See [`framework/assessment/scoring-methodology.md`](framework/assessment/scoring-methodology.md) for the full scoring spec.

## Who this is for

| If you are... | GRITS gives you... |
|---|---|
| Building or deploying AI agents | A concrete control catalog with pass/fail expectations to build against |
| Leading AI governance or security | An auditable standard with crosswalks to NIST and OWASP |
| Running OpenClaw, NemoClaw, or similar runtimes | The normative baseline the scanner enforces |
| Evaluating enterprise AI risk | The lifecycle model, profile templates, and compliance mappings |

## What is in this repo

| Path | What it contains |
|---|---|
| `framework/core/` | Control catalog (21 controls), core principles, pillar definitions |
| `framework/lifecycle/` | Agent Lifecycle Model: states, transitions, governance gates |
| `framework/assessment/` | Scoring methodology, posture bands, lifecycle gate thresholds, GRITS Baseline |
| `profiles/` | Profile templates with 21 checks aligned to the control catalog |
| `docs/` | Reference implementations, compliance crosswalks, domain-specific guidance |

## The 5 GRITS Pillars

Every control maps to one or more pillars:

- **Governance** - Ownership, accountability, lifecycle gates
- **Risk** - Threat modeling, exposure quantification, residual risk
- **Integrity** - Configuration drift, immutability, audit trail
- **Trust** - Identity, operator verification, chain of custody
- **Security** - Technical controls across the 5 layers

## Compliance crosswalks

All 21 GRITS controls are mapped to:

- NIST AI Risk Management Framework (AI 100-1)
- NIST AI 600-1 (Generative AI Profile)
- OWASP Top 10 for LLM Applications 2025
- OWASP Top 10 for Agentic Applications 2026 (ASI01-ASI10)

GRITS provides what these frameworks require but do not prescribe: controls with explicit pass/fail expectations and a scoring model that makes compliance auditable. See [`docs/nist-owasp-crosswalk.md`](docs/nist-owasp-crosswalk.md).

## Contributing

Useful contributions to the framework:

- Additional controls for emerging agent architectures
- Compliance mappings (DORA, SOC 2, HIPAA, EU AI Act)
- Lifecycle model extensions for multi-agent systems
- Domain-specific profile templates

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

Apache 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

---

Created by X Scale AI | https://www.xscaleai.com | https://github.com/X-Scale-AI/GRITS
