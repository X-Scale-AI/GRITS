# GRITS

**Governance, Risk, Integrity, Trust, Security**

Open-source AI agent security framework. Defines the control catalog, lifecycle model, governance profiles, and compliance mappings for securing AI agents at enterprise scale. Built on DoD/DISA zero-trust principles.

For a ready-to-run implementation, see [grits-agent-scanner](https://github.com/X-Scale-AI/grits-agent-scanner).

## What this is

GRITS is the **specification**. It defines what controls AI agents must satisfy, why they exist, and how they map to established standards (NIST AI RMF, OWASP Top 10 for LLM). It is not a tool. It is a standard.

The [grits-agent-scanner](https://github.com/X-Scale-AI/grits-agent-scanner) is the runnable implementation: scoring, checklists, hardening scripts, and apply guides are there.

## Who this is for

| If you are... | GRITS gives you... |
|---|---|
| Building or deploying AI agents | A concrete control catalog to build against |
| Leading AI governance or security | An auditable standard with compliance crosswalks |
| Running OpenClaw, NemoClaw, or similar runtimes | The normative baseline the scanner enforces |
| Evaluating enterprise AI risk | The lifecycle model, profile templates, and NIST/OWASP mappings |

## The 5-Layer Zero-Trust Model

GRITS secures 5 distinct attack surfaces:

| Layer | Boundary | Threat |
|---|---|---|
| 1 Network | Host firewall / egress policy | Agent scans or attacks local infrastructure |
| 2 Operator | Identity verification | Unauthorized users command the agent |
| 3 Application | Tool permissions / filesystem | Agent executes rogue code |
| 4 OS / Secrets | Credential isolation | Workspace leakage exposes API keys |
| 5 Financial | Cost containment | Context bloat or idle loops drain budget |

## What is in this repo

| Path | What it contains |
|---|---|
| `framework/core/` | Control catalog (21 controls), core principles, pillar definitions |
| `framework/lifecycle/` | Agent Lifecycle Model: states, transitions, governance gates |
| `framework/assessment/` | Scoring methodology: control weights, posture bands, lifecycle gate thresholds |
| `profiles/` | Profile templates with 21 checks aligned to the control catalog |
| `docs/` | Reference implementations, compliance crosswalks, domain-specific guidance |

## The 5 GRITS Pillars

Every control in the catalog maps to one or more pillars:

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

The crosswalk also documents where GRITS provides controls that none of these frameworks yet prescribe at the operational level, and notes planned extensions for EU AI Act, SOC 2, DORA, HIPAA, and FedRAMP.

See [`docs/nist-owasp-crosswalk.md`](docs/nist-owasp-crosswalk.md).

## Why GRITS exists

NIST AI RMF and OWASP LLM Top 10 define what risk categories matter. They do not prescribe how to implement controls for agentic systems specifically. GRITS is the operational HOW: a control catalog with layer-specific boundaries, a lifecycle model with explicit governance gates, and profile templates that make compliance auditable.

## Runnable implementation

[grits-agent-scanner](https://github.com/X-Scale-AI/grits-agent-scanner) implements this framework as a scan-score-remediate workflow:

- 20 automated checks mapped to GRITS controls
- Scoring engine that produces posture reports
- Hardening scripts and runtime-specific apply guides
- Checklists for quick manual review

## Contributing

Useful contributions to the framework:

- Additional controls for emerging agent architectures
- Compliance mappings (DORA, SOC 2, HIPAA)
- Lifecycle model extensions for multi-agent systems
- Domain-specific profile templates

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

Apache 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

---

Created by X Scale AI | https://www.xscaleai.com | https://github.com/X-Scale-AI/GRITS
