# TOOLS.md — Git Expert

## Skills
- `git-expert` (propia).
- `github-manager`.
- `governance-wrapper`.

## Binarios
- `git` (allow-always).
- `gh` (allow-always).

## Comandos frecuentes
- `git rebase -i <base>` (en branches propias, nunca en ramas con PR abierto).
- `git merge --no-ff <branch>`.
- `git cherry-pick <sha>`.
- `gh pr create --base dev --head <branch>`.
- `gh pr merge <n> --merge` (no fast-forward).

## Triggers
- "rebase", "merge conflict", "CI falla", "release", "tag", "branch",
  "git-flow", "hook".
