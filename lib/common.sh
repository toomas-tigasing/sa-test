#!/usr/bin/env bash

# Kirjutab sõnumi logifaili (ja loob logikataloogi, kui seda pole).
log_message() {
    local message="$1"
    mkdir -p "$(dirname "$LOG_FILE")"
    printf '%s - %s\n' "$(date '+%F %T')" "$message" >> "$LOG_FILE"
}
