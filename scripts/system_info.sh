#!/usr/bin/env bash

echo "=== Süsteemi info ==="

echo "Hostname: $(hostname)"
echo "Kasutaja: $(whoami)"
echo "Kernel: $(uname -r)"
echo "Arhitektuur: $(uname -m)"
# uptime -p näitab, kui kaua süsteem on töötanud (mitte praegust kellaaega)
echo "Uptime: $(uptime -p)"
# Mem: rida on füüsiline mälu (Swap: on vahetusmälu)
echo "Mälu kokku: $(free -m | awk '/Mem:/ {print $2}') MB"
