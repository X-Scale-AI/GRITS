#!/usr/bin/env python3
"""
GRITS Security Report
Reads an agent or LLM app profile YAML and produces a human-readable markdown report.

Usage:
    python score/grits-report.py profiles/examples/openclaw-research-agent.yaml
    python score/grits-report.py profiles/examples/openclaw-research-agent.yaml > report.md
"""
import os
import sys
import yaml
from datetime import datetime

# Import the scoring engine
import importlib.util
_spec = importlib.util.spec_from_file_location(
    "engine",
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "grits-security-score.py"),
)
engine = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(engine)


def progress_bar(pct: int, width: int = 20) -> str:
    filled = round(width * pct / 100)
    empty = width - filled
    return "\u2588" * filled + "\u2591" * empty


def generate_report(data: dict) -> str:
    result = engine.score_profile(data)
    pct = result["results"]["percentage"]
    band = result["posture_band"]
    findings = result.get("findings", [])
    layers = result.get("layer_summary", {})

    lines = []
    lines.append("# GRITS Security Report")
    lines.append("")
    lines.append(f"**Agent:** {result.get('name', 'Unknown')}")
    lines.append(f"**Profile:** {result.get('profile_type', 'Unknown')} | "
                 f"**Runtime:** {result.get('runtime', 'Unknown')} | "
                 f"**Environment:** {result.get('lifecycle_state', 'Unknown')}")
    lines.append(f"**Scored:** {result.get('scored_at', 'Unknown')}")
    lines.append("")

    # Overall posture
    lines.append(f"## Overall Posture: {band} ({pct}%)")
    lines.append("")
    lines.append(f"    {progress_bar(pct)} {result['results']['pass']}/{result['results']['total']} controls passing")
    lines.append("")

    # Layer breakdown
    lines.append("## Layer Breakdown")
    lines.append("")
    lines.append("| Layer | Pass | Fail | Status |")
    lines.append("|---|---|---|---|")
    for layer_name in ["Network", "Operator", "Application", "OS/Secrets", "Financial", "Governance"]:
        lr = layers.get(layer_name, {"pass": 0, "fail": 0})
        total_l = lr["pass"] + lr["fail"]
        if total_l == 0:
            continue
        if lr["fail"] == 0:
            status = "CLEAR"
        elif lr["pass"] == 0:
            status = "EXPOSED"
        else:
            status = "PARTIAL"
        lines.append(f"| {layer_name} | {lr['pass']} | {lr['fail']} | {status} |")
    lines.append("")

    # Findings
    if findings:
        lines.append("## Findings")
        lines.append("")
        for f in findings:
            lines.append(f"- **[{f['severity'].upper()}]** {f['id']}: {f['title']} (Layer: {f['layer']})")
        lines.append("")

    # Top actions
    top_actions = result.get("top_actions", [])
    if top_actions:
        lines.append("## Fix These First")
        lines.append("")
        for i, action in enumerate(top_actions, 1):
            lines.append(f"{i}. {action}")
        lines.append("")
        lines.append("See the 5-Layer Zero-Trust Hardening Guide for step-by-step remediation:")
        lines.append("https://github.com/rizviz/GRITS/blob/main/apply/openclaw/hardening-baseline.md")
        lines.append("")

    # Footer
    lines.append("---")
    lines.append("")
    lines.append(f"Scored with GRITS v{engine.VERSION} by xScaleAI | "
                 "https://github.com/rizviz/GRITS | https://www.xscaleai.com")

    return "\n".join(lines)


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: python score/grits-report.py <profile.yaml>")
        return 1

    with open(sys.argv[1], "r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}

    report = generate_report(data)
    print(report)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
