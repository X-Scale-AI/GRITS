# Are Your API Keys Exposed to Your Agent?

5 questions. 2 minutes. If you answer "no" to any of these, a compromised agent can steal your credentials.

## The check

| # | Question | Yes / No |
|---|---|---|
| 1 | Are your API keys stored outside of any directory the agent process can read? | |
| 2 | Have you removed API keys from openclaw.json, .env files, and docker-compose.yml in the agent workspace? | |
| 3 | Are your secrets injected into the agent process at runtime (via systemd EnvironmentFile or Docker secrets) rather than stored on the accessible filesystem? | |
| 4 | If you try to read the secrets file as the agent's user (not root), does it fail with "Permission denied"? | |
| 5 | Are your API keys absent from any git repository, backup, or snapshot that could be restored or shared? | |

## What "no" means

Every "no" means your API keys are one exploit away from exfiltration. If the agent can read a file containing your keys, and the agent has any outbound network access, it can send those keys anywhere. This is not a hypothetical. Environment variable dumping is a known, trivial attack vector.

"Add keys via environment variables in your Docker manager" is better than pasting them into chat, but it is not enough. If the keys end up in a docker-compose.yml, an .env file, or any file the agent's process user can read, they are exposed.

## How to fix it

See the GRITS 5-Layer Zero-Trust Hardening Guide, Layer 4 (OS and Secrets Boundary):
https://github.com/rizviz/GRITS/blob/main/apply/openclaw/hardening-baseline.md#layer-4-os-and-secrets-boundary

For automated secret isolation using tmpfs and age encryption:
https://github.com/rizviz/GRITS/tree/main/tools

---

Scored with GRITS by xScaleAI | https://github.com/rizviz/GRITS
