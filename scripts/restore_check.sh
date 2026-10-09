#!/usr/bin/env bash
# Kontrollib, et uusim varukoopia on päriselt taastatav:
# pakib selle ajutisse kataloogi lahti ja võrdleb algallikaga.

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/config/settings.conf"
source "$BASE_DIR/lib/common.sh"

# Uusim arhiiv (nimes on kuupäev, seega sorteerimine töötab)
latest=$(ls -1 "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | sort | tail -n 1)

if [ -z "$latest" ]; then
    echo "Varukoopiaid ei leitud kataloogis $BACKUP_DIR." >&2
    exit 2
fi

# Ajutine kataloog, mis kustutatakse skripti lõppedes alati
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

echo "Kontrollin arhiivi: $latest"

if ! tar -xzf "$latest" -C "$tmp" 2>/dev/null; then
    echo "VIGA: arhiivi ei saa lahti pakkida."
    log_message "restore_check: lahtipakkimine ebaõnnestus ($latest)"
    exit 1
fi

# diff -r võrdleb kõiki faile ja nende sisu (ka tühikuga nimedega)
if diff -r "$BACKUP_SOURCE" "$tmp" > /dev/null; then
    echo "OK: varukoopia on taastatav ja sisu on identne allikaga."
    log_message "restore_check: OK ($latest)"
    exit 0
else
    echo "VIGA: taastatud sisu erineb allikast."
    log_message "restore_check: erinevused ($latest)"
    exit 1
fi
