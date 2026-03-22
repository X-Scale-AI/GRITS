# GRITS Compliance Crosswalk

## Purpose

This crosswalk maps all 21 GRITS controls to four established frameworks: NIST AI RMF (AI 100-1), NIST AI 600-1 (Generative AI Profile), OWASP Top 10 for LLM Applications 2025, and the OWASP Top 10 for Agentic Applications 2026. It also documents where GRITS provides controls that none of these frameworks yet prescribe at the operational level.

---

## Framework Positioning

GRITS is not a replacement for NIST or OWASP. It is the operational implementation layer that those frameworks require but do not prescribe for agentic AI deployments.

| Framework | Publication | Agentic AI Coverage | Specificity |
|---|---|---|---|
| NIST AI RMF (AI 100-1) | January 2023 | None | Principle-based, voluntary, no pass/fail |
| NIST AI 600-1 (GenAI Profile) | July 2024 | Minimal | Suggested actions, not requirements |
| NIST AI Agent Standards Initiative | February 2026 | RFI and concept paper only | Aspirational, no published controls |
| OWASP LLM Top 10 2025 | 2025 | Partial | Risk categories and mitigation patterns |
| OWASP Agentic Top 10 2026 | December 2025 | Full agentic threat coverage | Architectural patterns, no pass/fail |
| **GRITS** | **2026** | **Full** | **21 controls with explicit pass/fail expectations** |

The NIST AI Agent Standards Initiative, launched February 2026, is in the RFI and concept paper phase. NIST is actively soliciting industry input on what controls should exist for agentic AI. GRITS already specifies 21 of them with layer-specific boundaries and verifiable expectations.

The pattern across all five external frameworks is consistent: they name the risk category and prescribe an architectural direction. None of them specify what a passing control looks like at the configuration level. GRITS fills that gap.

---

## GRITS to NIST AI RMF (AI 100-1)

| GRITS Control | NIST Function | NIST Category | What NIST says | What GRITS adds |
|---|---|---|---|---|
| GOV-001 (Owner assigned) | GOVERN | GV-1: Policies, processes, and roles for risk management | Roles and responsibilities defined | Named, accountable owner required per governed object |
| GOV-002 (Deputy owner assigned) | GOVERN | GV-1: Roles and responsibilities | Continuity of oversight | Backup owner required for production and high-impact systems |
| GOV-003 (Recertification date set) | GOVERN | GV-6: Ongoing monitoring and review | Periodic review established | Specific recertification cadence: 90-day maximum for production |
| GOV-004 (Monitoring enabled) | MEASURE | MS-2: Metrics tracked and assessed | Runtime metrics captured | Monitoring must be active; runtime logs and events required |
| GOV-005 (Policy violation visibility) | MANAGE | MG-3: Risks responded to | Violations surfaced for remediation | Policy violations must be detectable and surfaced operationally |
| NET-002 (Egress restricted) | MAP | MP-4: System boundaries identified | Network boundaries documented | Default-deny outbound; explicit allowlist of required destinations |
| APP-001 (Tool scope deny-by-default) | MAP | MP-2: Capabilities and limitations documented | Agent capabilities declared | Deny-by-default allowlist enforced at runtime |
| APP-003 (Dangerous capabilities scoped) | MANAGE | MG-2: Security controls applied | High-risk capabilities restricted | file_write, code_execution disabled unless explicitly required and scoped |
| SEC-001 (Secrets isolated) | MANAGE | MG-2: Security controls applied | Credential controls in place | Secrets must not exist in any file the agent process user can read |
| SEC-002 (Secrets injected at runtime) | MANAGE | MG-2: Security controls applied | Secure credential delivery | Delivery via systemd EnvironmentFile, Docker secrets, or equivalent only |
| FIN-001 (Cost guardrails defined) | GOVERN | GV-3: Resource allocation governed | Resource controls established | Daily token limits and monthly budget caps in provider billing console |
| FIN-003 (Budget accountability assigned) | GOVERN | GV-1: Roles and responsibilities | Financial accountability defined | Named owner responsible for monitoring and approving API spend |

NIST AI RMF controls not mapped above (NET-001, NET-003, NET-004, OPR-001, OPR-002, OPR-003, APP-002, SEC-003, FIN-002) address threat surfaces that the AI RMF does not specifically cover, particularly agent network lateral movement, operator command authority, and idle cost containment. These are GRITS-native controls with no direct NIST AI RMF equivalent.

---

## GRITS to NIST AI 600-1 (Generative AI Profile)

NIST AI 600-1 defines 12 risk categories for generative AI systems. Most address content and model output risks (hallucination, bias, CBRN content, misinformation). The categories most relevant to agentic security are Information Security (Risk 9), Value Chain and Component Integration (Risk 12), Data Privacy (Risk 4), Human-AI Configuration (Risk 7), and Environmental Impacts (Risk 5).

| GRITS Control | NIST 600-1 Risk Category | Notes |
|---|---|---|
| NET-001, NET-002, NET-003, NET-004 | Information Security (IS-9) | NIST names information security as a GenAI risk; GRITS specifies the network-layer controls |
| SEC-001, SEC-002, SEC-003 | Information Security (IS-9) | NIST flags credential and data exposure; GRITS specifies exact isolation and injection requirements |
| APP-001, APP-002 | Value Chain and Component Integration (VC-12) | NIST flags supply chain and component risks; GRITS specifies deny-by-default plugin allowlist enforcement |
| APP-003 | Value Chain and Component Integration (VC-12) | GRITS removes high-risk tool capabilities unless explicitly required |
| GOV-001, GOV-002, GOV-003 | Human-AI Configuration (HAC-7) | NIST flags automation bias and over-reliance; GRITS requires named ownership and recertification to enforce human accountability |
| GOV-004, GOV-005 | Human-AI Configuration (HAC-7) | Monitoring and violation visibility ensure humans remain informed and able to intervene |
| FIN-001, FIN-002, FIN-003 | Environmental Impacts (EI-5) | NIST flags computational resource consumption; GRITS specifies cost guardrails and idle offloading |
| OPR-001, OPR-002, OPR-003 | Information Security (IS-9) | Operator identity and command authority are not explicitly covered by 600-1 but map to its information security risk category |

The majority of NIST 600-1 risk categories (confabulation, harmful content, bias, intellectual property, obscene content, misinformation, CBRN) address model output safety, not agent security posture. GRITS does not cover model output safety. These are separate concerns with separate tooling.

---

## GRITS to OWASP Top 10 for LLM Applications 2025

| GRITS Control | OWASP LLM Risk | How GRITS addresses it |
|---|---|---|
| OPR-001, OPR-002, OPR-003 | LLM01: Prompt Injection | Operator identity verification and command authority allowlisting prevent unauthorized prompt sources from commanding the agent |
| APP-001, APP-002, APP-003 | LLM07: System Prompt Leakage | Deny-by-default tool policy and plugin allowlist prevent undeclared capabilities from being invoked |
| APP-001, APP-002, APP-003 | LLM03: Supply Chain | Plugin allowlist enforced at runtime prevents loading of unreviewed or compromised extensions |
| SEC-001, SEC-002 | LLM02: Sensitive Information Disclosure | Secrets isolated from agent filesystem and injected at runtime only |
| NET-002, NET-003 | LLM06: Excessive Agency | Network boundaries limit blast radius; egress restriction prevents lateral movement |
| APP-003, SEC-003 | LLM05: Improper Output Handling | Dangerous capabilities scoped or removed; host permissions prevent agent from acting on rogue outputs |
| FIN-001, FIN-002 | LLM10: Unbounded Consumption | Daily token limits, budget caps, and idle cost offloading bound resource consumption |
| GOV-001, GOV-003, GOV-004 | LLM09: Misinformation | Ownership, recertification, and monitoring prevent unreviewed autonomous operation that could propagate errors |

OWASP LLM04 (Data and Model Poisoning), LLM08 (Vector and Embedding Weaknesses), and LLM09 (Misinformation) are model and data pipeline concerns outside the scope of GRITS agent security posture controls.

---

## GRITS to OWASP Top 10 for Agentic Applications 2026

Released December 2025. This is the most operationally relevant external framework for GRITS, covering threats that are specific to autonomous agent deployments.

| OWASP Agentic Risk | GRITS Controls | How GRITS addresses it |
|---|---|---|
| ASI01: Agent Goal Hijack | OPR-001, OPR-002, OPR-003 | Operator identity verification and command authority allowlisting prevent unauthorized sources from redirecting agent objectives |
| ASI02: Tool Misuse and Exploitation | APP-001, APP-002, APP-003 | Deny-by-default tool scope, enforced plugin allowlist, and removal of dangerous capabilities limit the tools available for misuse |
| ASI03: Identity and Privilege Abuse | OPR-001, OPR-003, SEC-001, SEC-002 | Verified operator identity and credential isolation prevent privilege escalation through inherited sessions or exposed keys |
| ASI04: Agentic Supply Chain Vulnerabilities | APP-001, APP-002 | Deny-by-default plugin policy and enforced allowlist block loading of unreviewed or compromised extensions at runtime |
| ASI05: Unexpected Code Execution | APP-003, SEC-003 | Dangerous capabilities (code_execution, file_write) removed or scoped; OS-level permissions restrict what the agent process can execute |
| ASI06: Memory and Context Poisoning | GOV-004, GOV-005 | Runtime monitoring and policy violation visibility enable detection of anomalous behavior patterns including memory or context manipulation |
| ASI07: Insecure Inter-Agent Communication | OPR-001, OPR-003, NET-002 | Identity verification and command authority controls apply to inter-agent messages; egress restriction limits communication paths |
| ASI08: Cascading Failures | NET-002, NET-003, GOV-005 | Egress restriction and private subnet blocking contain blast radius; policy violation visibility surfaces cascade signals |
| ASI09: Human-Agent Trust Exploitation | OPR-001, OPR-002, OPR-003 | Operator identity verification and allowlist-based command authority prevent agents from accepting commands from manipulated or spoofed human-facing interfaces |
| ASI10: Rogue Agents | GOV-001, GOV-003, GOV-004, GOV-005 | Named ownership, recertification cycles, runtime monitoring, and policy violation visibility create the governance infrastructure to detect and respond to rogue agent behavior |

### Coverage gaps

GRITS does not currently specify controls for:
- Cryptographic memory integrity verification (ASI06 mitigation recommended by OWASP)
- Goal consistency validation across sessions (ASI01 / ASI10 mitigation)
- Inter-agent message signing and authentication protocols (ASI07 mitigation)

These are candidate areas for future GRITS control extensions, particularly as multi-agent architectures become more common.

---

## Controls with no external framework equivalent

The following GRITS controls address threats that none of the current external frameworks prescribe at the control level. They are GRITS-native.

| GRITS Control | Threat addressed | Framework status |
|---|---|---|
| NET-003 (Private subnet access blocked) | Agent lateral movement to internal network via RFC 1918 ranges | Not specified by NIST or OWASP at configuration level |
| NET-004 (Management port protected) | Unauthorized access to agent dashboard or web UI | Not addressed by any current external framework |
| OPR-002 (Default permissive policies rejected) | Default channel policies enabling unauthorized commands | Not addressed by any current external framework |
| OPR-003 (Command authority restricted to allowlist) | Agent accepts commands from unverified user IDs | OWASP ASI01/ASI09 name the threat; no external framework specifies an allowlist control |
| FIN-002 (Idle cost minimized) | Background and heartbeat tasks consuming paid model budget | Not addressed by any current external framework |
| SEC-003 (Host file permissions hardened) | Agent process accesses files beyond its working directory | OWASP ASI05 names RCE; no framework specifies OS permission hardening at this level |
| GOV-002 (Deputy owner assigned) | Loss of accountability when primary owner is unavailable | Not addressed by any current external framework |

---

## Status

This crosswalk covers GRITS v0.2. Planned extensions:

- EU AI Act mapping (Articles 9, 17 on risk management systems and technical documentation)
- SOC 2 Trust Services Criteria mapping (CC6, CC7, CC9)
- DORA (Digital Operational Resilience Act) mapping for financial sector deployments
- HIPAA Security Rule mapping for healthcare agent deployments
- FedRAMP control mapping for US federal deployments

Contributions that refine mappings, correct errors, or add regulatory crosswalks are welcome. See [CONTRIBUTING.md](../CONTRIBUTING.md).
