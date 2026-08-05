#!/bin/bash
# backup-obsidian.sh — Backup del vault de Obsidian

VAULT_PATH="$HOME/obsidian-vault"
BACKUP_PATH="$HOME/backups/obsidian"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_PATH"

# Backup con rsync
rsync -av --delete "$VAULT_PATH/" "$BACKUP_PATH/vault_$DATE/"

# Tambien comprimido
tar -czf "$BACKUP_PATH/vault_$DATE.tar.gz" -C "$VAULT_PATH" .

# Mantener solo ultimos 10 backups
ls -t "$BACKUP_PATH"/vault_*.tar.gz | tail -n +11 | xargs -r rm

echo "Backup completado: $BACKUP_PATH/vault_$DATE.tar.gz"
