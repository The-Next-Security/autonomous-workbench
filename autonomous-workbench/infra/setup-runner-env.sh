#!/bin/bash
# Prepara el entorno de ejecución antes de cada sprint de prueba autónoma.
# Ejecutar una vez por VPS o worktree nuevo antes de arrancar issues.
set -e

echo "=== Setup runner env ==="
python3 -m pip install --break-system-packages --quiet pytest ruff numpy
apt-get install -y --quiet shellcheck
echo "pytest:     $(pytest --version)"
echo "ruff:       $(ruff --version)"
echo "shellcheck: $(shellcheck --version | grep version:)"
echo "=== Runner env OK ==="
