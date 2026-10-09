#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$BASE_DIR/config/settings.conf"

# df -P annab stabiilse formaadi; veerg 5 on Use% (kasutatud protsent).
# Eemaldame sealt vaid %-märgi.
usage=$(df -P / | awk 'NR==2 {gsub("%", "", $5); print $5}')

# Kontroll, et saime päriselt numbri
if ! [[ "$usage" =~ ^[0-9]+$ ]]; then
    echo "Viga: kettakasutust ei õnnestunud lugeda." >&2
    exit 2
fi

echo "Kettakasutus: ${usage}%"

if [ "$usage" -lt "$DISK_LIMIT" ]; then
    echo "OK: kettaruumi kasutus on normis."
    exit 0
else
    echo "HOIATUS: kettaruumi kasutus on liiga suur."
    exit 1
fi
