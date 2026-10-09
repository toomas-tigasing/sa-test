#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/config/settings.conf"
source "$BASE_DIR/lib/common.sh"

DATE=$(date '+%Y%m%d_%H%M%S')
ARCHIVE="$BACKUP_DIR/backup_$DATE.tar.gz"

# Allikakataloog peab olemas olema
if [ ! -d "$BACKUP_SOURCE" ]; then
    echo "Viga: allikakataloogi $BACKUP_SOURCE ei ole." >&2
    log_message "backup: allikat puudub: $BACKUP_SOURCE"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

echo "Varukoopia loomine..."

# Loome päris tihendatud tar-arhiivi (-C: pakime kataloogi sisu, mitte täispikki teid)
if ! tar -czf "$ARCHIVE" -C "$BACKUP_SOURCE" . 2>/dev/null; then
    echo "Varukoopia ebaõnnestus (tar viga)."
    rm -f "$ARCHIVE"
    log_message "backup: tar ebaõnnestus"
    exit 1
fi

# Kontrollime, et arhiiv on päriselt loetav, mitte ainult olemas
if tar -tzf "$ARCHIVE" > /dev/null 2>&1; then
    # Loeme ainult failid (kataloogide read lõpevad märgiga /)
    count=$(tar -tzf "$ARCHIVE" | grep -vc '/$')
# -v "grep -vc" all tähendab, et ta leiab read, mis ei vasta mustrile
    echo "Varukoopia valmis: $ARCHIVE"
    echo "Failide arv: $count"
    log_message "backup: valmis $ARCHIVE ($count faili)"
    exit 0
else
    echo "Varukoopia on rikutud arhiiv."
    rm -f "$ARCHIVE"
    log_message "backup: arhiiv ei ole loetav"
    exit 1
fi
