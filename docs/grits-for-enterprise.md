# GRITS for Enterprise: GRC and Security Leadership

## The problem AI is creating for enterprise governance and security

AI systems and agents are being deployed across business units faster than governance and security teams can respond. The builders move fast. The risk accumulates silently.

By the time a GRC team is asked to demonstrate AI governance maturity, or a CISO is asked to explain the blast radius of a compromised agent, the systems are already in production -- ungoverned, unscored, and unauditable.

GRITS exists to close that window.

---

## For Enterprise GRC Teams

### The care-abouts

**Audit exposure.** AI systems are being deployed without going through formal risk assessment. When an auditor asks for an AI system inventory, control evidence, or a risk register entry, most organizations have nothing to show. The gap is not intentional -- there has been no standard to build against.

**Policy without enforceability.** Writing an AI governance policy takes a week. Making it measurable and enforceable across a growing population of AI systems is the actual problem. A policy that says "AI systems must be secure" is not an auditable control.

**No citable standard.** NIST AI RMF is voluntary and principle-based. The NIST AI Agent Standards Initiative is still in the RFI phase as of 2026. There is no ISO 27001 equivalent for AI systems yet. GRC teams are being asked to govern against a standard that does not fully exist.

**Recertification and drift.** A system reviewed at deployment may look nothing like it does six months later. Tool permissions change. Owners change. Monitoring lapses. With no recertification mechanism, drift goes undetected until it becomes an incident.

**Ownership gaps.** AI systems get deployed, the builder moves on, and no named individual is accountable for security posture, cost, or compliance. Shadow AI at machine speed.

**Board and regulator pressure.** Regulators are beginning to ask about AI governance maturity. Boards are asking CISOs and Chief Risk Officers to demonstrate that AI risk is managed. The question is real; the answer, for most organizations, is not ready.

### How GRITS addresses it

| GRC concern | GRITS response |
|---|---|
| Nothing to cite | 21-control catalog grounded in NIST AI RMF, NIST AI 600-1, OWASP LLM Top 10, and OWASP Agentic Top 10 |
| Policy without enforcement | Controls have explicit pass/fail expectations -- assessable, not interpretable |
| No audit artifact | The GRITS profile YAML is a governance record: owner, classification, posture checks, review dates |
| Drift and recertification | GOV-003 mandates a recertification date; lifecycle model enforces governance gates at each state transition |
| Ownership gaps | GOV-001 and GOV-002 require named primary and deputy owners per governed system |
| Board reporting | Posture score is a number -- trackable, trendable, and reportable at the portfolio level |
| Regulator alignment | Crosswalks to NIST AI RMF, NIST AI 600-1, OWASP LLM Top 10, and OWASP Agentic Top 10 in a single document |

### What GRC teams get from GRITS

- A citable standard with a version number they can reference in policies and audit responses
- A profile template that produces an auditable record per AI system -- no custom documentation required
- A lifecycle model with explicit governance gates that can be embedded into change management and deployment approval workflows
- A scoring model that enables risk prioritization across an AI system portfolio
- Coverage in hours, not weeks -- fill out a profile, score it, and have an auditable posture record the same day

---

## For CISO and Cybersecurity Teams

### The care-abouts

**Attack surface without visibility.** Agents have network access, filesystem access, credentials, and tool execution capability. Most security teams have no inventory of what agents exist, what they can do, or how they are configured. You cannot protect what you cannot see.

**Credential sprawl.** Every AI system has API keys. Where those keys are stored, who can read them, how they are rotated, and whether the agent process can access them directly is usually undefined. One exposed `.env` file is all it takes.

**Excessive agency.** Agents with broader tool permissions than their task requires create an outsized blast radius. An agent that can write files, execute code, and reach internal networks is a significant lateral movement risk if compromised or manipulated.

**No detection signal.** Agents do not emit the telemetry that endpoint and user behavioral analytics are built to consume. Anomalous agent behavior -- unusual tool invocations, unexpected egress, cost spikes -- does not surface in existing SIEM workflows without explicit instrumentation.

**Supply chain exposure.** Plugins, extensions, and MCP servers are loaded into agent runtimes with no vetting or allowlist enforcement. A compromised extension has the full permission set of the agent.

**Lateral movement.** An agent host with unrestricted egress can reach internal subnets, cloud metadata endpoints, and adjacent services that security teams assumed were segmented. SSRF through an agent is a real and underappreciated attack path.

**Incident response gaps.** When an agent behaves anomalously or is confirmed compromised, the runbook does not exist. Containment, scope assessment, and remediation processes for AI systems are undefined in most organizations.

### How GRITS addresses it

| Security concern | GRITS controls |
|---|---|
| Network lateral movement | NET-002 (default-deny egress), NET-003 (private subnet blocking), NET-004 (management port protection) |
| Credential exposure | SEC-001 (secrets off filesystem), SEC-002 (runtime injection only), SEC-003 (host permission hardening) |
| Excessive agency | APP-001 (deny-by-default tool scope), APP-002 (plugin allowlist), APP-003 (dangerous capabilities scoped) |
| Unauthorized command execution | OPR-001 (operator identity verified), OPR-003 (command authority allowlist) |
| No detection signal | GOV-004 (monitoring required), GOV-005 (policy violation visibility required) |
| Supply chain | APP-002 (plugin allowlist enforced -- no unreviewed extensions) |
| Incident containment | Lifecycle Suspended and Restricted states with defined re-entry requirements |
| Risk prioritization | Severity-weighted scoring: Critical controls (4pts each) surface highest-risk gaps first |

### What security teams get from GRITS

- A technical control baseline purpose-built for AI attack surfaces, not retrofitted from endpoint or application security frameworks
- Critical control classification that identifies the 5 controls whose failure directly enables a known attack path -- remediation priority is unambiguous
- A scoring model that enables risk ranking across an AI system portfolio: lowest-scored systems get security attention first
- Monitoring and violation visibility requirements that create the signal feed for SIEM and SOC workflows
- The foundation for an AI Agent SOC capability -- see [`agent-soc-reference.md`](agent-soc-reference.md)

---

## The joint value proposition

GRC and security leadership want the same outcome from different angles: **evidence that AI systems are under control.**

GRC needs the paper trail. Security needs the technical controls. GRITS provides both in a single framework. The profile is the governance artifact. The control catalog is the technical standard. The score is the shared language between them.

A GRITS score gives a GRC team something to report. It gives a security team something to act on. It gives a board something to understand.

---

## Getting started

| Starting point | Path |
|---|---|
| Establish a baseline immediately | [GRITS Baseline](../framework/assessment/grits-baseline.md) -- 5 Critical controls, 5 minutes, no tooling |
| Assess a specific system | [Agent profile template](../profiles/agent-profile-template.yaml) or [LLM app profile](../profiles/llm-app-profile-template.yaml) |
| Automate assessment across your fleet | [grits-agent-scanner](https://github.com/X-Scale-AI/grits-agent-scanner) |
| Enterprise governance and AI Agent SOC | [X Scale AI](https://www.xscaleai.com/consult) |
