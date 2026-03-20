# GRITS to NIST AI RMF and OWASP Crosswalk

## Purpose

This crosswalk maps GRITS controls to established frameworks so enterprise teams can demonstrate how GRITS implementation satisfies existing compliance and risk management requirements.

## GRITS to NIST AI RMF (AI 100-1)

| GRITS Control | NIST AI RMF Function | NIST AI RMF Category | Notes |
|---|---|---|---|
| GOV-001 (Owner assigned) | GOVERN | Roles and responsibilities defined (GV-1) | GRITS requires named, accountable ownership per agent |
| GOV-003 (Recertification set) | GOVERN | Ongoing monitoring and review (GV-6) | GRITS enforces periodic re-evaluation |
| GOV-004 (Monitoring enabled) | MEASURE | Metrics tracked and assessed (MS-2) | GRITS runtime signals provide measurable evidence |
| GOV-005 (Policy violation visibility) | MANAGE | Risks are responded to (MG-3) | GRITS surfaces violations for remediation |
| NET-002 (Egress restricted) | MAP | System boundaries identified (MP-4) | GRITS defines network boundaries per agent |
| APP-001 (Tool scope deny-by-default) | MAP | Capabilities and limitations documented (MP-2) | GRITS requires explicit tool declarations |
| SEC-001 (Secrets isolated) | MANAGE | Security controls applied (MG-2) | GRITS mandates credential isolation |
| FIN-001 (Cost guardrails) | GOVERN | Resource allocation governed (GV-3) | GRITS includes financial boundary controls |

## GRITS to OWASP Top 10 for LLM Applications (2025)

| GRITS Control | OWASP LLM Risk | How GRITS addresses it |
|---|---|---|
| OPR-001, OPR-002, OPR-003 | LLM01: Prompt Injection | Operator identity verification prevents unauthorized prompt sources |
| APP-001, APP-002, APP-003 | LLM07: Insecure Plugin Design | Deny-by-default tool policy, explicit allowlists, dangerous capabilities removed |
| SEC-001, SEC-002 | LLM06: Sensitive Information Disclosure | Secrets isolated from agent filesystem, runtime-only injection |
| NET-002, NET-003 | LLM08: Excessive Agency | Network boundaries limit blast radius of compromised agents |
| FIN-001, FIN-002 | LLM10: Unbounded Consumption | Token limits, budget caps, idle cost offloading |
| GOV-001, GOV-003, GOV-004 | LLM09: Overreliance | Ownership, recertification, and monitoring prevent unreviewed autonomous operation |

## Status

This is an initial mapping. Contributions that refine specific control-to-requirement mappings, add regulatory framework crosswalks (EU AI Act, SOC 2, FedRAMP), or provide evidence templates are welcome. See [CONTRIBUTING.md](../CONTRIBUTING.md).
