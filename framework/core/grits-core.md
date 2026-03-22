# GRITS Core

## What GRITS stands for

**G**overnance, **R**isk, **I**ntegrity, **T**rust, **S**ecurity

These are the 5 pillars that every GRITS control traces back to.

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
- Not a replacement for NIST, OWASP, or ATF (it operationalizes what they recommend)

## Structure

| Component | What it defines | Where to find it |
|---|---|---|
| Control Catalog | 21 controls across 5 layers and 5 pillars, with normative expectations | `framework/core/control-catalog.md` |
| Lifecycle Model | States, transitions, and governance gates for agent populations | `framework/lifecycle/agent-lifecycle-model.md` |
| Governance Profiles | Templates for classifying agents and LLM apps and declaring their posture | `profiles/` |
| Compliance Crosswalks | Mappings to NIST AI RMF and OWASP Top 10 for LLM | `docs/nist-owasp-crosswalk.md` |
| Domain Extensions | Sector-specific guidance (financial agents, AI Agent SOC) | `docs/` |

For the runnable implementation of this framework, including scoring, checklists, hardening scripts, and apply guides, see [grits-agent-scanner](https://github.com/X-Scale-AI/grits-agent-scanner).
