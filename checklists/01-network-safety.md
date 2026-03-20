# Is Your Agent Network-Safe?

5 questions. 2 minutes. If you answer "no" to any of these, your agent can reach things it should not.

## The check

| # | Question | Yes / No |
|---|---|---|
| 1 | Is your host firewall (UFW/iptables) enabled with a default-deny outbound policy? | |
| 2 | Have you explicitly blocked outbound traffic to private IP ranges (192.168.x.x, 10.x.x.x, 172.16-31.x.x)? | |
| 3 | Is your agent's management port (dashboard/web UI) restricted to your VPN or local subnet only? | |
| 4 | Have you tested whether your agent can ping or curl your router's admin page? | |
| 5 | If your agent is on Docker, have you disabled inter-container communication (icc=false) for containers that do not need it? | |

## What "no" means

Every "no" means your agent has network access it does not need. A single prompt injection could turn that access into reconnaissance of your home network, your NAS, your smart devices, or other machines on your LAN.

Running 5 Mac Minis does not fix this. If all 5 have the same default network policy, you have 5 attack surfaces instead of 1. One properly firewalled VM with deny-by-default outbound is more secure than 5 unsegmented machines.

## How to fix it

See the GRITS 5-Layer Zero-Trust Hardening Guide, Layer 1 (Network Boundary):
https://github.com/X-Scale-AI/GRITS/blob/main/apply/openclaw/hardening-baseline.md#layer-1-network-boundary

For automated hardening scripts based on DoD/DISA standards:
https://github.com/X-Scale-AI/GRITS/tree/main/tools

---

Scored with GRITS by X Scale AI | https://github.com/X-Scale-AI/GRITS
