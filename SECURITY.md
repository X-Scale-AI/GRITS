# Security Policy

GRITS is a framework repository, not a production service. Security issues in this repo are most likely to relate to starter scripts, example configurations, unsafe defaults in contributed baselines, or secrets accidentally committed to examples.

## Reporting

Please report suspected security issues privately to the maintainers before opening a public issue if the report involves an exploitable script defect, a dangerous default likely to mislead users, or an example that exposes sensitive data patterns.

Contact: https://www.xscaleai.com

## Scope

GRITS does not claim that following a document in this repo is sufficient to make an agent or runtime safe. Local runtime context, identity, data boundaries, tooling, network posture, and operator trust assumptions still matter. Always review hardening scripts before running them and test in a non-production environment first.
