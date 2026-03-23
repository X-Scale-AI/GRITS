# GRITS Core

## What GRITS stands for

**G**overnance, **R**isk, **I**ntegrity, **T**rust, **S**ecurity

These are the 5 GRITS Pillars -- the first principles of the framework. Every control in the catalog must satisfy one or more of these properties or it has no place in the standard. They establish the "why" behind every control.

The 5-Layer Zero-Trust Model is the complementary coverage model. It defines the distinct attack surfaces every AI system presents -- the "how" of ensuring comprehensive coverage. A control catalog that does not address all 5 layers has blind spots by definition.

Every GRITS control traces back to a pillar (the principle that justifies its existence) and maps to a layer (the attack surface it addresses). The 21 controls are the product of that intersection.

## Purpose

GRITS defines an open, implementable framework for security and lifecycle governance of AI agents and LLM systems. It solves two related problems:

1. How to secure and govern individual AI deployments in practice
2. How to govern growing populations of agents over time without losing ownership, trust, or control

## Design principles

- Specification over abstraction: every control has a normative expectation and a corresponding profile field
- Deny-by-default over permissive: agents should have the minimum access required
- Evidence over assertions: governance claims must be backed by measurable posture
- Open vocabulary, commercial implementation: the framework is open, enterprise tooling is available via X Scale AI

## What GRITS is not

- Not a new runtime (use OpenClaw, NemoClaw, or whatever you already run)
- Not a vendor control plane (GRITS is framework-level, not product-level)
- Not a certification program (yet)
- Not a replacement for NIST AI RMF, NIST AI 600-1, OWASP LLM Top 10, or OWASP Agentic Top 10 (it operationalizes what they require but do not prescribe)

## Framework positioning

GRITS sits at the implementation layer beneath NIST and OWASP. Those frameworks name risk categories and direct organizations to apply controls. They do not specify what a passing control looks like at the configuration level for an autonomous agent deployment.

| Framework | What it provides | What it leaves open |
|---|---|---|
| NIST AI RMF (AI 100-1) | Governance functions: GOVERN, MAP, MEASURE, MANAGE | No agentic AI coverage; no pass/fail thresholds; voluntary |
| NIST AI 600-1 (GenAI Profile) | 12 GenAI risk categories; 200+ suggested actions | Content and output focused; no agent network, credential, or tool controls |
| NIST AI Agent Standards Initiative | Directional research; RFI and concept paper (Feb 2026) | No published technical controls; soliciting industry input |
| OWASP LLM Top 10 2025 | 10 LLM risk categories with mitigation patterns | Architectural guidance; no enumerated controls with pass/fail expectations |
| OWASP Agentic Top 10 2026 | 10 agentic-specific risks (ASI01-ASI10) with mitigation guidance | Identifies the threats clearly; still does not specify verifiable control expectations |

GRITS provides what these frameworks require but do not prescribe: 21 controls with layer-specific boundaries, explicit pass/fail expectations, and a governance model that makes compliance auditable. For the complete control-to-framework mapping, see [`docs/nist-owasp-crosswalk.md`](../../docs/nist-owasp-crosswalk.md).

## Structure

| Component | What it defines | Where to find it |
|---|---|---|
| Control Catalog | 21 controls across 5 layers and 5 pillars, with normative expectations | `framework/core/control-catalog.md` |
| Lifecycle Model | States, transitions, and governance gates for agent populations | `framework/lifecycle/agent-lifecycle-model.md` |
| Governance Profiles | Templates for classifying agents and LLM apps and declaring their posture | `profiles/` |
| Compliance Crosswalks | Mappings to NIST AI RMF and OWASP Top 10 for LLM | `docs/nist-owasp-crosswalk.md` |
| Domain Extensions | Sector-specific guidance (financial agents, AI Agent SOC) | `docs/` |

For the runnable implementation of this framework, including scoring, checklists, hardening scripts, and apply guides, see [grits-agent-scanner](https://github.com/X-Scale-AI/grits-agent-scanner).
