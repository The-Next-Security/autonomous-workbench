# E2E PR Validation

Date: 2026-04-22

Purpose:
Validate the clean autonomous corridor using an isolated Git worktree.

Validation scope:
- dedicated workbench outside runtime
- isolated feature branch
- governed branch -> commit -> push -> PR flow

Notes:
- runtime path is /root/.openclaw
- autonomous workbench path is /opt/tns-workbench/autonomous-workbench
- worktree path is /opt/tns-workbench/autonomous-workbench/worktrees/feature-e2e-pr-validation
