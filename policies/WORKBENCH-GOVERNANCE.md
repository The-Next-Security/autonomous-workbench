# Workbench Governance Policy

## Purpose
This repository is the clean autonomous workbench for controlled Git -> branch -> push -> PR execution.

## Rules
## Allowed execution corridor

- Allowed autonomous workspace root: `/opt/tns-workbench/autonomous-workbench`
- Allowed isolated worktree root: `/opt/tns-workbench/autonomous-workbench/worktrees`
- Git and GitHub operations for autonomous execution must stay inside that corridor.
- Any Git or GH action outside that corridor must be blocked or escalated.

1. The runtime under /root/.openclaw is not part of this repository.
2. Direct commits to main are not allowed for autonomous work.
3. Autonomous changes must happen only on feature/* or fix/* branches.
4. All autonomous changes must end in a Pull Request.
5. Force push is not allowed.
6. Secrets, runtime state, and local scratch data must never be committed.
7. worktrees/ is reserved for isolated execution branches.
8. scratch/ is disposable and must remain untracked.
9. This repository exists only as a clean corridor for governed autonomous execution.
