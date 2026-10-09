#!/usr/bin/env bash

service="$1"

# Tühja sisendi kontroll
if [ -z "$service" ]; then
    echo "Kasutus: $0 teenuse_nimi" >&2
    exit 2
fi

# is-active kontrollib, kas teenus HETKEL tegelikult töötab
if systemctl is-active --quiet "$service" 2>/dev/null; then
    echo "Teenus $service töötab."
    exit 0
fi

# Ei tööta: eristame olemasolevat (peatatud) teenust olematust
if systemctl list-unit-files --type=service 2>/dev/null | awk '{print $1}' | grep -qx "${service%.service}.service"; then
    echo "Teenus $service on olemas, kuid ei tööta."
    exit 1
else
    echo "Teenust $service ei leitud."
    exit 2
fi
