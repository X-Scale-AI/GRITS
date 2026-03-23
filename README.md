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

## Two frameworks. One standard.

GRITS is structured around two complementary models that are distinct and work together.

### The 5-Layer Zero-Trust Model

Defines **where** controls are applied. Every AI system has 5 attack surfaces that must be governed regardless of autonomy level.

| Layer | Boundary | Threat |
|---|---|---|
| 1 Network | Host firewall / egress policy | System reaches infrastructure it should not |
| 2 Operator | Identity verification | Unauthorized users issue commands |
| 3 Application | Tool permissions / filesystem | Rogue code or tool misuse |
| 4 OS / Secrets | Credential isolation | API keys exposed through workspace access |
| 5 Financial | Cost containment | Unbounded token consumption drains budget |

### The 5 GRITS Pillars

Defines **why** each control exists. Every control in the catalog traces back to one or more pillars.

| Pillar | What it governs |
|---|---|
| Governance | Ownership, accountability, lifecycle gates |
| Risk | Threat modeling, exposure quantification, residual risk |
| Integrity | Configuration drift, immutability, audit trail |
| Trust | Identity, operator verification, chain of custody |
| Security | Technical controls across the 5 layers |

The 21 GRITS controls are the intersection: each control specifies a layer (where it applies) and traces to a pillar (why it matters), with an explicit expectation of what passing looks like.

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
