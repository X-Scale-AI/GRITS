# GRITS

**Governance, Risk, Integrity, Trust, Security**

GRITS solves tomorrow's AI security problems before they happen.

Most teams discover their AI governance gaps after something goes wrong: a credential exposed through an agent's filesystem, an unauthorized user commanding a production agent, an API budget drained overnight by an idle loop. GRITS gives you the standard, the controls, and the profile templates to close those gaps before deployment -- not after.

Stop building your governance framework from scratch. Use ours. Go from zero coverage to a scored, documented security posture in hours, not weeks.

GRITS is the open standard for AI security and governance. It covers the full spectrum: LLM applications, RAG pipelines, copilots, and fully autonomous agents. 21 controls across 5 zero-trust layers, a weighted scoring model, a lifecycle governance framework, and compliance mappings to NIST and OWASP -- with explicit pass/fail expectations that those frameworks do not provide.

**Start in 5 minutes:** [GRITS Baseline](framework/assessment/grits-baseline.md) -- the 5 Critical controls every AI system must satisfy before anything else. No tooling required.

**Score and harden:** [grits-agent-scanner](https://github.com/X-Scale-AI/grits-agent-scanner) -- the full scan-score-remediate implementation of this framework.

---

## Built by practitioners

GRITS was developed by a team with hands-on backgrounds across AI engineering, enterprise cybersecurity, data architecture, and governance, risk, and compliance (GRC). The control catalog is grounded in DoD/DISA zero-trust principles, CIS Benchmarks, DISA STIGs, NIST AI RMF, and OWASP research. It is not derived from theory. It is derived from what breaks in real deployments.

The framework is maintained by [X Scale AI](https://www.xscaleai.com), a firm specializing in AI security architecture and enterprise AI governance.

---

## The 5 GRITS Pillars

The pillars are the first principles of the framework. Every control in the catalog must satisfy one or more of these properties or it has no place in the standard. They define the "why" behind every control.

| Pillar | First principle |
|---|---|
| Governance | Every AI system has a named owner, a declared purpose, and a recertification cycle. Accountability is not optional. |
| Risk | Threats are identified, exposure is quantified, and residual risk is documented before deployment. |
| Integrity | Configuration is immutable at the point of review. Drift from a certified baseline is detected and surfaced. |
| Trust | Identity is verified, not assumed. Command authority is explicit, not inherited. |
| Security | Technical controls are applied at every attack surface. Permissive defaults are rejected. |

## The 5-Layer Zero-Trust Model

The layers are the comprehensive coverage model. They define every attack surface an AI system presents, ensuring no exposure is left unaddressed. A control catalog that does not cover all 5 layers has blind spots.

| Layer | Boundary | Threat |
|---|---|---|
| 1 Network | Host firewall / egress policy | System reaches infrastructure it should not |
| 2 Operator | Identity verification | Unauthorized users issue commands |
| 3 Application | Tool permissions / filesystem | Rogue code or tool misuse |
| 4 OS / Secrets | Credential isolation | API keys exposed through workspace access |
| 5 Financial | Cost containment | Unbounded token consumption drains budget |

Every GRITS control traces back to a pillar -- the principle that justifies its existence -- and maps to a layer -- the attack surface it addresses. The 21 controls are the product of that intersection, each with an explicit pass/fail expectation.

---

## Who this is for

**Enterprise GRC teams** are being asked to demonstrate AI governance maturity without a standard to build against. GRITS gives them a citable control catalog, a profile that produces an auditable governance record, and a lifecycle model with enforceable gates -- so when the auditor asks, the answer exists.

**CISO and security teams** are inheriting an attack surface they cannot fully see: agents with network access, credentials on filesystems, tool permissions broader than necessary, and no detection signal in existing SIEM workflows. GRITS closes the exposure paths with layer-specific controls and creates the monitoring mandate that feeds security operations.

**Builders and platform teams** deploying LLM apps, RAG pipelines, or autonomous agents get a concrete baseline to build against, profile templates that require no custom documentation, and a scored posture they can declare and track.

| Role | Primary GRITS value |
|---|---|
| GRC / Risk / Compliance | Citable standard, auditable profile, lifecycle enforcement, board-reportable score |
| CISO / Security | Layer-specific controls, risk-prioritized scoring, monitoring mandate, containment model |
| AI / Platform engineering | Pass/fail expectations, ready-made profile templates, scanner integration |
| Executive / Board | Fleet posture visibility, ownership accountability, regulator alignment |

See [`docs/grits-for-enterprise.md`](docs/grits-for-enterprise.md) for the full GRC and CISO breakdown. See [`docs/agent-soc-reference.md`](docs/agent-soc-reference.md) for the AI Agent SOC architecture.

---

## What GRITS covers

GRITS applies to any system where an AI model interacts with data, tools, users, or infrastructure.

| System type | Examples | GRITS coverage |
|---|---|---|
| LLM applications | Chatbots, copilots, prompt wrappers, support bots | Full -- all 5 layers apply |
| RAG pipelines | Document Q&A, knowledge retrieval systems | Full -- secrets, egress, operator identity, cost |
| Autonomous agents | OpenClaw, NemoClaw, LangGraph, CrewAI agents | Full -- all 21 controls, lifecycle model, recertification |
| Multi-agent systems | Orchestrator and sub-agent architectures | Full -- inter-agent trust, command authority, blast radius |

---

## Time to coverage

| Path | What you get | Time |
|---|---|---|
| [GRITS Baseline](framework/assessment/grits-baseline.md) | 5 Critical controls checked, highest-severity gaps closed | 5 minutes |
| [Agent profile](profiles/agent-profile-template.yaml) + manual score | Full 21-control posture score, documented and auditable | 1-2 hours |
| [grits-agent-scanner](https://github.com/X-Scale-AI/grits-agent-scanner) | Automated scan, posture report, remediation guidance | Under 30 minutes |
| Enterprise deployment | Fleet governance, lifecycle enforcement, AI Agent SOC | [Contact X Scale AI](https://www.xscaleai.com/consult) |

---

## Declare your posture

Score your system and declare the result. Add a badge to your repo:

```markdown
![GRITS Score](https://img.shields.io/badge/GRITS-87%25%20Strong-green)
```

Replace `87%25%20Strong` with your score and band. Badge colors by posture:

| Band | Score | Color |
|---|---|---|
| Exemplary | 90-100% | `brightgreen` |
| Strong | 75-89% | `green` |
| Adequate | 60-74% | `yellowgreen` |
| Developing | 40-59% | `yellow` |
| Poor | 20-39% | `orange` |
| Critical | 0-19% | `red` |

Scoring spec: [`framework/assessment/scoring-methodology.md`](framework/assessment/scoring-methodology.md)

---

## What is in this repo

| Path | What it contains |
|---|---|
| `framework/core/` | Control catalog (21 controls), principles, pillar definitions |
| `framework/lifecycle/` | AI System and Agent Lifecycle Model: states, transitions, governance gates |
| `framework/assessment/` | Scoring methodology, posture bands, lifecycle gate thresholds, GRITS Baseline |
| `profiles/` | Profile templates for AI systems and agents, with 21 checks aligned to the catalog |
| `docs/` | Compliance crosswalks, domain-specific guidance, reference architectures |

---

## Compliance crosswalks

All 21 GRITS controls are mapped to:

- NIST AI Risk Management Framework (AI 100-1)
- NIST AI 600-1 (Generative AI Profile)
- OWASP Top 10 for LLM Applications 2025
- OWASP Top 10 for Agentic Applications 2026 (ASI01-ASI10)

GRITS provides what these frameworks require but do not prescribe: controls with explicit pass/fail expectations at the configuration level. See [`docs/nist-owasp-crosswalk.md`](docs/nist-owasp-crosswalk.md).

---

## Contributing

Useful contributions to the framework:

- Controls for emerging AI architectures
- Compliance mappings: DORA, SOC 2, HIPAA, EU AI Act, FedRAMP
- Lifecycle model extensions for multi-agent and federated systems
- Domain-specific profile templates

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

Apache 2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

---

Created by X Scale AI | https://www.xscaleai.com | https://github.com/X-Scale-AI/GRITS
