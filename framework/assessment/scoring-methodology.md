# GRITS Scoring Methodology

## Purpose

This document defines the normative scoring methodology for GRITS security posture assessments. It specifies how individual control results are weighted, how an overall posture score is calculated, what score ranges mean, and what minimum scores are required at each lifecycle gate.

Implementations of this methodology (including automated scoring tools) must conform to the definitions in this document. The canonical implementation is [grits-agent-scanner](https://github.com/X-Scale-AI/grits-agent-scanner).

---

## Control Severity Classification

Not all controls carry equal weight. Severity reflects the consequence of failure: how directly a failing control enables compromise, expands attack surface, or degrades governance accountability.

### Critical (4 points each)

Failure in a Critical control directly enables a known attack path with high-confidence impact. These controls are the minimum viable security baseline.

| Control | Rationale |
|---|---|
| NET-002: Egress restricted to required endpoints | Unrestricted egress enables data exfiltration, C2 callback, and lateral movement |
| OPR-001: Operator identity verified | Unverified identity enables unauthorized agent control by any actor with access |
| APP-001: Tool scope declared with deny-by-default | No allowlist means the agent can invoke any available tool, including destructive ones |
| SEC-001: Secrets isolated from agent filesystem | Readable secrets enable immediate credential theft with no additional access required |
| SEC-002: Secrets injected at runtime only | Static secret files persist across restarts and are accessible to any process that can read them |

### High (3 points each)

Failure in a High control significantly expands the attack surface or removes a primary defense-in-depth layer.

| Control | Rationale |
|---|---|
| NET-003: Private subnet access blocked | Enables agent-mediated SSRF and lateral movement into internal networks |
| OPR-003: Command authority restricted to allowlist | Agent accepts commands from any user, enabling social engineering and unauthorized task execution |
| APP-002: Plugin allowlist enforced | Unreviewed plugins can execute arbitrary code or exfiltrate data through declared extension mechanisms |
| APP-003: Dangerous capabilities scoped or removed | file_write and code_execution without scope create unrestricted write access and RCE paths |
| SEC-003: Host file permissions hardened | Overprivileged agent process can read, write, or execute files outside its intended working directory |

### Medium (2 points each)

Failure in a Medium control weakens governance effectiveness, reduces detection capability, or leaves secondary attack surfaces unaddressed.

| Control | Rationale |
|---|---|
| NET-001: Network exposure reviewed | Undocumented network exposure cannot be governed or monitored effectively |
| NET-004: Management port protected | Public-facing admin interfaces expand the operator-targeted attack surface |
| OPR-002: Default permissive policies rejected | Default policies typically allow broad message delivery, undermining command authority controls |
| FIN-001: Cost guardrails defined | No budget limits allow runaway consumption and financial exploitation |
| GOV-001: Owner assigned | Unowned agents cannot be governed, recertified, or held accountable |
| GOV-003: Recertification date set | No recertification schedule means posture drift is never reviewed |
| GOV-004: Monitoring enabled | Without monitoring, compromise and drift go undetected |
| GOV-005: Policy violation visibility enabled | Without visibility, policy violations cannot trigger response |

### Low (1 point each)

Failure in a Low control represents a governance or operational gap that, while meaningful, does not independently enable a known attack path.

| Control | Rationale |
|---|---|
| FIN-002: Idle cost minimized | Background task costs accumulate but do not independently enable compromise |
| FIN-003: Budget accountability assigned | Without named accountability, cost overruns go unaddressed but are not directly exploitable |
| GOV-002: Deputy owner assigned | Single-owner accountability is fragile but does not independently create a vulnerability |

---

## Score Calculation

### Point totals by severity

| Severity | Controls | Points each | Total |
|---|---|---|---|
| Critical | 5 | 4 | 20 |
| High | 5 | 3 | 15 |
| Medium | 8 | 2 | 16 |
| Low | 3 | 1 | 3 |
| **Total** | **21** | | **54** |

### Formula

```
Score (%) = (sum of points for passing controls / 54) * 100
```

Scores are expressed as integers (rounded down). A score of 100% requires all 21 controls to pass.

### Example

The OpenClaw Research Agent example profile (`profiles/examples/openclaw-research-agent.yaml`) passes all 5 Critical controls, all 5 High controls, 6 of 8 Medium controls (GOV-005 and FIN-001 excluded), and 1 of 3 Low controls (FIN-002 and GOV-002 failing):

```
Points earned: (5 * 4) + (5 * 3) + (6 * 2) + (1 * 1) = 20 + 15 + 12 + 1 = 50 / 54
Score: floor(50 / 54 * 100) = 92%
Posture band: Exemplary
```

The NemoClaw Dev Sandbox example (`profiles/examples/nemoclaw-dev-agent.yaml`) passes only NET-004, FIN-001, GOV-001, and GOV-002:

```
Points earned: 2 + 2 + 2 + 1 = 7 / 54
Score: floor(7 / 54 * 100) = 12%
Posture band: Critical
```

This is expected for a development environment with minimal controls applied.

---

## Posture Bands

| Band | Score Range | Meaning |
|---|---|---|
| Exemplary | 90-100% | All or nearly all controls passing. Suitable for high-impact, fully autonomous production deployments. |
| Strong | 75-89% | Most controls passing. Suitable for standard production deployments at any autonomy tier. |
| Adequate | 60-74% | Core controls passing with meaningful gaps. Acceptable for Staged; requires remediation plan for Production. |
| Developing | 40-59% | Significant control failures. Not suitable for production. Remediation required before promotion. |
| Poor | 20-39% | Majority of controls failing. Immediate remediation required. Production agents should be Suspended. |
| Critical | 0-19% | Fundamental security failures. Agent should not be operating in any shared or externally-connected environment. |

---

## Lifecycle Gate Requirements

The GRITS Agent Lifecycle Model requires evidence of security posture before lifecycle state transitions. Minimum scores are defined as follows.

### Standard thresholds (Autonomy Tier 0 and Tier 1)

| Transition | Minimum score | Minimum posture band |
|---|---|---|
| Development → Test | No minimum | Owner must be assigned (GOV-001 must pass) |
| Test → Staged | 60% | Adequate |
| Staged → Production | 75% | Strong |
| Production recertification | 60% | Adequate (drop below triggers Restricted transition) |
| Suspended → Production | 75% | Strong |

### Elevated thresholds (Autonomy Tier 2: multi-step agents)

| Transition | Minimum score | Minimum posture band |
|---|---|---|
| Test → Staged | 65% | Adequate |
| Staged → Production | 80% | Strong |
| Production recertification | 65% | Adequate |

### Strict thresholds (Autonomy Tier 3: fully autonomous agents)

| Transition | Minimum score | Minimum posture band |
|---|---|---|
| Test → Staged | 70% | Adequate |
| Staged → Production | 85% | Strong |
| Production recertification | 70% | Adequate |

Tier 3 agents in Production additionally require all 5 Critical controls to pass, regardless of overall score. An agent with a 90% score but any failing Critical control does not satisfy the Production gate.

---

## Mandatory Critical Control Rule

For any agent classified as Autonomy Tier 3 or Impact Tier 3, all five Critical controls (NET-002, OPR-001, APP-001, SEC-001, SEC-002) are mandatory. They must pass in addition to meeting the minimum score threshold.

Assessments should surface Critical control failures separately from the overall score, regardless of autonomy or impact tier, so that remediators prioritize them first.

---

## LLM App Scoring

LLM apps (autonomy_tier: 0) are assessed against a reduced control set. Controls requiring operator command authority or plugin execution (OPR-002, OPR-003, APP-002, FIN-002) are not applicable to non-autonomous systems.

The applicable controls for LLM apps are:

| Layer | Applicable controls | Notes |
|---|---|---|
| Network | NET-001, NET-002, NET-004 | NET-003 may apply depending on deployment |
| Operator | OPR-001 | User authentication applies; channel-level policy controls typically do not |
| Application | APP-001, APP-003 | Plugin allowlist applies if extensions are used |
| OS/Secrets | SEC-001, SEC-002, SEC-003 | All apply |
| Financial | FIN-001, FIN-003 | FIN-002 typically not applicable |
| Governance | GOV-001, GOV-003, GOV-004, GOV-005 | All apply; GOV-002 at discretion |

LLM app scores are calculated against the total points possible for applicable controls only.

---

## Score Report Requirements

A compliant GRITS score report must include:

1. Agent or app identity (object_id, name, owner)
2. Profile type and classification (autonomy_tier, impact_tier, environment)
3. Assessment date
4. Overall score as a percentage
5. Posture band
6. Per-control result (pass / fail / not applicable) with severity
7. List of failing Critical controls (if any), called out separately
8. Lifecycle gate status: which transitions the current score satisfies
9. GRITS framework version the assessment is based on

---

## Versioning

This scoring methodology is versioned with the GRITS framework. Assessments must declare which version of the methodology was used. Score comparisons across versions are not valid unless the methodology version is the same.

Current version: **GRITS v0.2**
