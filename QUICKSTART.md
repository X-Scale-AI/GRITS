# Quick Start

Score your agent's security in 5 minutes. Harden it in 15.

## Prerequisites

```bash
git clone https://github.com/X-Scale-AI/GRITS.git
cd GRITS
pip install -r requirements.txt
```

## Step 1: Create your agent profile (3 minutes)

```bash
cp profiles/agent-profile-template.yaml my-agent.yaml
```

Open `my-agent.yaml` in your editor. Fill in:

- Your agent's name and purpose
- Your name/email as owner
- The tools your agent uses
- Answer every security check honestly (true or false)

If you are not sure about a check, answer `false`. That is the honest answer.

## Step 2: Score it (30 seconds)

```bash
python score/grits-report.py my-agent.yaml
```

You will get a report showing your overall posture, layer-by-layer breakdown, and prioritized findings.

Save it for your before/after comparison:

```bash
python score/grits-report.py my-agent.yaml > before.md
```

## Step 3: Fix the critical findings (15 to 30 minutes)

Your report lists findings sorted by severity. Start with Critical, then High.

For OpenClaw agents, the hardening guide walks you through each fix:

- [5-Layer Zero-Trust Hardening Guide](apply/openclaw/hardening-baseline.md)

For automated host-level hardening:

- Docker hosts: `sudo bash tools/harden-docker.sh`
- VM/bare-metal: `sudo bash tools/harden.sh`

## Step 4: Update your profile and re-score

After fixing issues, update the checks in `my-agent.yaml` to `true` for each item you addressed.

```bash
python score/grits-report.py my-agent.yaml > after.md
```

Compare your before and after scores.

## Step 5: Set a review date

In your profile, set `recertification_due` to 90 days from today. Security drifts. Come back and re-score.

## For LLM apps (chatbots, copilots, RAG apps)

If your system is not an autonomous agent, use the LLM App template instead:

```bash
cp profiles/llm-app-profile-template.yaml my-app.yaml
```

The scoring works the same way. The LLM App profile has fewer controls because the attack surface is smaller.

## Not ready for a full score?

Start with a 2-minute checklist:

- [Is your agent network-safe?](checklists/01-network-safety.md)
- [Can someone else command your agent?](checklists/02-operator-identity.md)
- [Do you know what your agent can do?](checklists/03-tool-permissions.md)
- [Are your API keys exposed?](checklists/04-secrets-exposure.md)
- [Is your agent burning money?](checklists/05-cost-exposure.md)
