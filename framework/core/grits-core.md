# GRITS Core

## What GRITS stands for

**G**overnance, **R**isk, **I**ntegrity, **T**rust, **S**ecurity

These are the 5 pillars that every GRITS control traces back to.

## Purpose

GRITS defines an open, implementable framework for security and lifecycle governance of AI agents and LLM systems. It solves two related problems:

1. How to secure and govern individual AI deployments in practice
2. How to govern growing populations of agents over time without losing ownership, trust, or control

## Design principles

- Implementation over abstraction: every concept has a corresponding artifact, script, or template
- Deny-by-default over permissive: agents should have the minimum access required
- Evidence over assertions: governance claims must be backed by measurable posture
- Open vocabulary, commercial implementation: the framework is open, enterprise tooling is available via X Scale AI

## What GRITS is not

- Not a new runtime (use OpenClaw, NemoClaw, or whatever you already run)
- Not a vendor control plane (GRITS is framework-level, not product-level)
- Not a certification program (yet)
- Not a replacement for NIST, OWASP, or ATF (it operationalizes what they recommend)

## Structure

| Layer | What it does | Where to find it |
|---|---|---|
| Checklists | Quick exposure checks for social distribution | `checklists/` |
| Profiles | Templates that classify your agent and capture its security posture | `profiles/` |
| Scoring | Scripts that turn profiles into posture scores and reports | `score/` |
| Apply | Runtime-specific hardening guides and remediation | `apply/` |
| Tools | Host-level hardening scripts (DoD/DISA grade) | `tools/` |
| Framework | Control catalog, lifecycle model, governance reference | `framework/` |
