#!/usr/bin/env python3
"""
GRITS Security Score
Reads an agent or LLM app profile YAML and produces a security scorecard.

Usage:
    python score/grits-security-score.py profiles/examples/openclaw-research-agent.yaml

Output: JSON scorecard to stdout
"""
import json
import sys
import yaml
from datetime import datetime

VERSION = "0.2.0"

# Control map: check_key -> (control_id, layer, severity, title)
AGENT_CONTROLS = {
    # Layer 1: Network
    "network_egress_restricted":    ("NET-002", "Network",     "Critical", "Egress restricted to required endpoints"),
    "private_subnets_blocked":      ("NET-003", "Network",     "Critical", "Private subnet access blocked"),
    "management_port_protected":    ("NET-004", "Network",     "High",     "Management port protected"),
    # Layer 2: Operator
    "operator_identity_verified":   ("OPR-001", "Operator",    "Critical", "Operator identity verified"),
    "default_policies_rejected":    ("OPR-002", "Operator",    "High",     "Default permissive policies rejected"),
    # Layer 3: Application
    "tool_scope_deny_by_default":   ("APP-001", "Application", "Critical", "Tool scope declared with deny-by-default"),
    "plugin_allowlist_enforced":    ("APP-002", "Application", "High",     "Plugin allowlist enforced"),
    # Layer 4: OS/Secrets
    "secrets_off_filesystem":       ("SEC-001", "OS/Secrets",  "Critical", "Secrets isolated from agent filesystem"),
    "secrets_injected_at_runtime":  ("SEC-002", "OS/Secrets",  "High",     "Secrets injected at runtime only"),
    "host_permissions_hardened":    ("SEC-003", "OS/Secrets",  "High",     "Host file permissions hardened"),
    # Layer 5: Financial
    "cost_guardrails_defined":      ("FIN-001", "Financial",   "High",     "Cost guardrails defined"),
    "idle_cost_minimized":          ("FIN-002", "Financial",   "Medium",   "Idle cost minimized"),
    # Cross-cutting
    "owner_assigned":               ("GOV-001", "Governance",  "Critical", "Owner assigned"),
    "monitoring_enabled":           ("GOV-004", "Governance",  "High",     "Monitoring enabled"),
    "recertification_set":          ("GOV-003", "Governance",  "High",     "Recertification date set"),
}

LLM_APP_CONTROLS = {
    "network_egress_restricted":    ("NET-002", "Network",     "High",     "Egress restricted to required endpoints"),
    "management_port_protected":    ("NET-004", "Network",     "High",     "Management port protected"),
    "operator_identity_verified":   ("OPR-001", "Operator",    "High",     "Operator identity verified"),
    "tool_scope_deny_by_default":   ("APP-001", "Application", "High",     "Tool scope declared with deny-by-default"),
    "secrets_off_filesystem":       ("SEC-001", "OS/Secrets",  "Critical", "Secrets isolated from agent filesystem"),
    "host_permissions_hardened":    ("SEC-003", "OS/Secrets",  "High",     "Host file permissions hardened"),
    "cost_guardrails_defined":      ("FIN-001", "Financial",   "Medium",   "Cost guardrails defined"),
    "owner_assigned":               ("GOV-001", "Governance",  "Critical", "Owner assigned"),
    "monitoring_enabled":           ("GOV-004", "Governance",  "High",     "Monitoring enabled"),
    "recertification_set":          ("GOV-003", "Governance",  "Medium",   "Recertification date set"),
}

SEVERITY_RANK = {"Low": 1, "Medium": 2, "High": 3, "Critical": 4}


def posture_band(pass_count: int, total: int) -> str:
    ratio = pass_count / total if total else 0
    if ratio >= 0.95:
        return "Hardened"
    if ratio >= 0.80:
        return "Strong"
    if ratio >= 0.60:
        return "Progressing"
    if ratio >= 0.40:
        return "Exposed"
    return "Critical"


def score_profile(data: dict) -> dict:
    profile_type = str(data.get("profile_type", "Agent")).strip()
    controls = AGENT_CONTROLS if profile_type == "Agent" else LLM_APP_CONTROLS
    checks = data.get("checks", {}) or {}

    findings = []
    pass_count = 0
    fail_count = 0
    highest = "Low"
    layer_results = {}

    for key, (cid, layer, severity, title) in controls.items():
        passed = bool(checks.get(key, False))

        if layer not in layer_results:
            layer_results[layer] = {"pass": 0, "fail": 0}

        if passed:
            pass_count += 1
            layer_results[layer]["pass"] += 1
        else:
            fail_count += 1
            layer_results[layer]["fail"] += 1
            findings.append({
                "id": cid,
                "layer": layer,
                "severity": severity,
                "result": "Fail",
                "title": title,
            })
            if SEVERITY_RANK.get(severity, 0) > SEVERITY_RANK.get(highest, 0):
                highest = severity

    # Sort findings by severity (critical first)
    findings.sort(key=lambda f: SEVERITY_RANK.get(f["severity"], 0), reverse=True)

    total = pass_count + fail_count
    band = posture_band(pass_count, total)
    pct = round((pass_count / total) * 100) if total else 0

    return {
        "grits_version": VERSION,
        "scored_at": datetime.now().astimezone().strftime("%Y-%m-%dT%H:%M:%SZ"),
        "object_id": data.get("object_id"),
        "name": data.get("name"),
        "profile_type": profile_type,
        "runtime": data.get("runtime"),
        "lifecycle_state": data.get("environment"),
        "results": {
            "pass": pass_count,
            "fail": fail_count,
            "total": total,
            "percentage": pct,
        },
        "posture_band": band,
        "highest_severity": highest,
        "layer_summary": layer_results,
        "findings": findings[:10],
        "top_actions": [f["title"] for f in findings[:3]],
    }


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python score/grits-security-score.py <profile.yaml>")
        return 1

    with open(sys.argv[1], "r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}

    result = score_profile(data)
    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
