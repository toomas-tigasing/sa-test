#!/usr/bin/env bash

username="$1"

# Tühja sisendi kontroll
if [ -z "$username" ]; then
    echo "Kasutus: $0 kasutajanimi" >&2
    exit 2
fi

# getent passwd otsib täpselt selle nimega kasutajakontot
if getent passwd "$username" > /dev/null; then
    echo "Kasutaja $username eksisteerib."
    exit 0
else
    echo "Kasutajat $username ei leitud."
    exit 1
fi
