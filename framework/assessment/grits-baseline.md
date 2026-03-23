# GRITS Baseline

The GRITS Baseline is the minimum viable security check for any AI agent. It covers the 5 Critical controls -- the ones whose failure directly enables a known attack path. No tooling required. Fill this out manually in 5 minutes.

Passing the Baseline does not mean your agent is fully secured. It means you have eliminated the highest-severity exposures. Use the full [agent profile template](../../profiles/agent-profile-template.yaml) and [scoring methodology](scoring-methodology.md) to assess all 21 controls.

---

## The 5 Critical Controls

### NET-002: Egress restricted to required endpoints

**What this means:** Your agent's outbound traffic is limited to explicitly required destinations only. Default-deny outbound. Any destination not on the list is blocked.

**How to check:**
- Is there an egress firewall rule or outbound policy on the host?
- Does it block all outbound traffic except to named destinations (LLM API endpoints, package repos)?
- Have you tested that an unexpected outbound connection (e.g., to google.com) is blocked?

**Pass:** Default-deny outbound policy exists and is enforced. Allowed destinations are explicit and minimal.

**Fail:** Agent can reach arbitrary internet destinations without restriction.

---

### OPR-001: Operator identity verified

**What this means:** Only verified, known user identities can issue commands to the agent. Platform-level identity verification, not just usernames or display names.

**How to check:**
- Does your agent accept commands only from authenticated user IDs?
- Is the identity verification happening at the platform level (not just trusting a display name)?
- Could a stranger message your agent and have it execute tasks?

**Pass:** Only verified user IDs on an explicit list can command the agent.

**Fail:** Agent accepts commands from any user who can reach it, or relies on unverified display names.

---

### APP-001: Tool scope declared with deny-by-default

**What this means:** A `plugins.allow` or equivalent allowlist exists. Every tool the agent can use is explicitly declared. Tools not on the list are unavailable.

**How to check:**
- Does a tool allowlist configuration file exist?
- Is it set to deny-by-default (everything blocked unless listed)?
- If you add a new tool without updating the list, is it blocked?

**Pass:** Deny-by-default allowlist exists and is actively enforced at runtime.

**Fail:** Agent can use any available tool, or tools are enabled by default and blocked individually.

---

### SEC-001: Secrets isolated from agent filesystem

**What this means:** API keys, tokens, and credentials do not exist in any file that the agent process user can read. The agent has no filesystem path to your secrets.

**How to check:**
- Search the agent's working directory and home directory for `.env` files, config files, or any file containing API keys.
- What user does the agent process run as? Can that user read files outside the working directory?
- Are credentials stored in a file that the agent process can access?

**Pass:** No credential files exist in any path readable by the agent process user.

**Fail:** API keys exist in `.env`, config files, or any location readable by the agent process.

---

### SEC-002: Secrets injected at runtime only

**What this means:** Credentials are delivered to the agent process through a secure injection mechanism at startup, not stored in static files that persist between runs.

**How to check:**
- How does your agent receive its API keys?
- Are they set via `systemd EnvironmentFile`, Docker secrets, a secrets manager (Vault, AWS Secrets Manager), or equivalent?
- Do credential files persist on disk between agent restarts?

**Pass:** Secrets are injected at runtime via a managed mechanism. No static credential files.

**Fail:** API keys are stored in `.env`, hardcoded in config, or in any file that exists before the agent starts.

---

## Scoring your Baseline

| Result | Score |
|---|---|
| All 5 Critical controls pass | Baseline achieved. Proceed to full 21-control assessment. |
| 4 of 5 pass | Do not deploy to production. Address the failing control first. |
| 3 or fewer pass | Immediate remediation required before any production or shared-environment use. |

Critical control failures are not offset by passing other controls. A 95% overall GRITS score with one failing Critical control does not satisfy the Baseline.

---

## Next steps

**Manual full assessment:** Copy [`profiles/agent-profile-template.yaml`](../../profiles/agent-profile-template.yaml), fill in all 21 checks, and calculate your score using the [scoring methodology](scoring-methodology.md).

**Automated scan:** Use [grits-agent-scanner](https://github.com/X-Scale-AI/grits-agent-scanner) to run all checks automatically and generate a posture report.

**Declare your posture:** Add a GRITS score badge to your repo. See the [README](../../README.md) for badge markdown.
