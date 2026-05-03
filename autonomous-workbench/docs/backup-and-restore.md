# Backup y Restore

Procedimiento para respaldar y recuperar el runtime del sistema autónomo.

## Qué se respalda

- `~/.openclaw/` — configuración, memoria, skills locales, cron, agentes.
- `~/.codex/auth.json` — credenciales OAuth de ChatGPT Plus.

Estos dos elementos son la totalidad del estado operativo. Con ellos y
el clon del corredor (desde Git), el sistema se reconstruye completo.

## Qué NO se respalda

- Worktrees del corredor (`worktrees/`): transitorios, reconstruibles.
- Scratch (`scratch/`): desechable.
- Archivos generados por agentes fuera del runtime: cada caso se evalúa
  aparte.

## Destino y rotación

- Ruta: `/var/backups/openclaw/<YYYYMMDD-HHMMSS>.tar.gz.age`.
- Permisos del directorio: 700.
- Permisos del archivo: 600.
- Retención: 7 copias. Las más antiguas se eliminan automáticamente.

## Cifrado

Usamos `age` (modern, keyless, curve25519).

### Setup inicial (una vez)

```
# Generar par de claves en una ubicación FUERA del repo.
mkdir -p /root/.keys
chmod 700 /root/.keys
age-keygen -o /root/.keys/age-identity.txt

# Extraer la clave pública.
grep 'public key' /root/.keys/age-identity.txt
# Copiar el valor de la línea "# public key: age1..." al recipients file.
echo 'age1example...' > /root/.keys/age-recipients.txt
chmod 600 /root/.keys/age-identity.txt /root/.keys/age-recipients.txt
```

Ninguno de estos archivos debe versionarse. El repo incluye únicamente
`infra/backup/.age-recipients.example` como referencia de formato.

## Backup

Manual:

```
/opt/tns-workbench/autonomous-workbench/infra/backup/backup-openclaw.sh
```

Por cron (instalado por operador):

```
0 4 * * * /opt/tns-workbench/autonomous-workbench/infra/backup/backup-openclaw.sh >> /var/log/openclaw-backup.log 2>&1
```

Flags:
- `--dry-run`: reporta acciones sin escribir.

## Restore (modo verificación)

Extrae el backup a un directorio scratch sin tocar el runtime vivo.
Este es el flujo normal para validar integridad:

```
infra/backup/restore-openclaw.sh \
  --archive /var/backups/openclaw/20260425-040000.tar.gz.age
```

El script reporta el directorio donde dejó el contenido y lista los
archivos de nivel raíz para verificación visual.

Opcional, comparar con runtime vivo:

```
diff -qr /tmp/openclaw-restore-<ts>/.openclaw /root/.openclaw
```

## Restore (modo destructivo)

Sobreescribe el runtime vivo desde un backup. Requiere confirmación
interactiva ("YES"):

```
infra/backup/restore-openclaw.sh \
  --archive /var/backups/openclaw/20260425-040000.tar.gz.age \
  --force-runtime
```

Uso típico: recuperación tras pérdida de la VM, corrupción del runtime,
o rollback tras cambio mal aplicado.

Antes de ejecutar en modo destructivo, detener el gateway:

```
systemctl --user stop openclaw-gateway
```

Y reiniciarlo después:

```
systemctl --user start openclaw-gateway
```

## Gate de aceptación para 1.0.0

Como parte del gate del PR 2, se ejecuta este flujo y se adjunta
evidencia al PR:

1. `backup-openclaw.sh` (genera archivo cifrado).
2. `ls -la /var/backups/openclaw/` (muestra archivo con tamaño > 0).
3. `restore-openclaw.sh --archive <archivo>` (en scratch).
4. `ls -la /tmp/openclaw-restore-<ts>/` (lista contenido).
5. `diff -qr /tmp/openclaw-restore-<ts>/.openclaw /root/.openclaw` (sin
   diferencias sustantivas).

Si los 5 pasos corren sin error y el diff es trivial (solo archivos de
logs o timestamps), el criterio "Restore verificable" pasa completamente.
