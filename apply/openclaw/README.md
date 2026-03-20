# Securing Your OpenClaw Agent with GRITS

You have an OpenClaw agent running. This folder tells you exactly what to do.

## Step 1: Know your exposure (5 minutes)

Copy the agent profile template and fill it in honestly:

```bash
cp profiles/agent-profile-template.yaml my-agent.yaml
# Edit my-agent.yaml with your agent's details
# Answer every check honestly (true/false)
```

## Step 2: Score it (1 minute)

```bash
python score/grits-security-score.py my-agent.yaml
```

Or get a human-readable report:

```bash
python score/grits-report.py my-agent.yaml
```

## Step 3: Fix what matters (15 to 30 minutes)

Read the hardening guide and work through the layers where you scored "Fail":

- [Hardening Baseline: 5-Layer Zero-Trust Guide](hardening-baseline.md)

The guide covers 5 boundaries: Network, Operator, Application, OS/Secrets, and Financial. Each section tells you what to do, why it matters, and how to verify it worked.

## Step 4: Automate the hardening (optional)

For host-level hardening based on DoD/DISA STIG standards:

- Docker hosts: `tools/harden-docker.sh`
- Bare metal / VM hosts: `tools/harden.sh`

Review the configuration section at the top of each script and adjust to your environment before running.

## Step 5: Re-score

```bash
python score/grits-report.py my-agent.yaml
```

Your posture band should improve. If you addressed all critical and high findings, you should be at "Strong" or "Hardened."

## Quick self-checks

Not ready to score yet? Start with one of these 2-minute checklists:

- [Is your agent network-safe?](../../checklists/01-network-safety.md)
- [Can someone else command your agent?](../../checklists/02-operator-identity.md)
- [Do you know what your agent can do?](../../checklists/03-tool-permissions.md)
- [Are your API keys exposed?](../../checklists/04-secrets-exposure.md)
- [Is your agent burning money?](../../checklists/05-cost-exposure.md)
