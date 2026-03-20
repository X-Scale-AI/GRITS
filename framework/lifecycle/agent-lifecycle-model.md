# Agent Lifecycle Model

## Purpose

The GRITS Agent Lifecycle Model defines how an agent or LLM application is governed from creation through retirement. Every governed object exists in exactly one lifecycle state at any time.

## Lifecycle States

| State | Meaning | Who typically uses this |
|---|---|---|
| Draft | Agent is being designed or configured. Not running. No governance obligations yet. | Builders during initial setup |
| Development | Agent is running in a dev/sandbox environment. Minimal governance required. Owner must be assigned. | Builders testing locally |
| Test | Agent is under structured testing. Security posture review should be completed before promotion. | Teams validating before production |
| Staged | Agent is ready for production but awaiting final approval or review. | Governance or security reviewers |
| Production | Agent is live and operational. Full governance obligations apply. Recertification clock starts. | Operators and owners |
| Suspended | Agent is temporarily halted due to a finding, incident, or policy violation. Must be remediated before returning to Production. | Security or governance teams |
| Restricted | Agent is running with reduced scope or permissions. Used when full suspension is not warranted but trust is degraded. | Owners responding to drift or findings |
| Retired | Agent is permanently decommissioned. Credentials revoked, record preserved for audit. | End of useful life |

## Transition Rules

Movement between states follows a principle: promotion requires evidence, demotion requires justification.

| From | To | What is required |
|---|---|---|
| Draft | Development | Owner assigned, business purpose declared |
| Development | Test | Profile completed, initial security posture check |
| Test | Staged | Security score meets minimum threshold, findings addressed |
| Staged | Production | Final review, recertification date set, monitoring confirmed |
| Production | Suspended | Incident, policy violation, or critical finding identified |
| Production | Restricted | Non-critical finding, trust degradation, or scope concern |
| Suspended | Production | Root cause addressed, re-scored, reviewer approval |
| Restricted | Production | Scope corrected, re-scored |
| Any | Retired | Credentials revoked, record preserved, owner confirms |

## Recertification

Production agents must be recertified on a regular cadence. Recommended: every 90 days. Recertification involves re-running the security score, reviewing findings, and confirming the agent's purpose and scope are still valid.

If recertification lapses, the agent should transition to Restricted until review is completed.

## Enterprise Implementation

The open specification above defines the vocabulary and rules for lifecycle governance. Enterprise teams managing fleets of agents require additional capabilities including automated state transition enforcement, fleet-wide recertification tracking, orphan agent detection, trust decay modeling, and integration with enterprise identity and change management systems.

Enterprise lifecycle implementation guidance and tooling are available through X Scale AI: https://www.xscaleai.com
