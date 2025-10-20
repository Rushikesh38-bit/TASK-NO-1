#!/usr/bin/env bash
# scan-local.sh — helper for local network port discovery (safe defaults)
# Usage: ./scan-local.sh <cidr-or-ip> [preset]
# Presets: quick (default), discover, full
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <target-cidr-or-ip> [quick|discover|full]"
  exit 1
fi

TARGET="$1"
PRESET="${2:-quick}"
TS=$(date +"%Y%m%dT%H%M%S")
OUT_PREFIX="recon-${TARGET//\//_}-$TS"

case "$PRESET" in
  quick)
    SCAN_ARGS=("-sS" "--top-ports" "1000" "-T4" "-sV")
    ;;
  discover)
    SCAN_ARGS=("-sn" "-T4")
    ;;
  full)
    SCAN_ARGS=("-sS" "-sU" "-p" "1-65535" "-sV" "--script=default,safe" "-T4")
    ;;
  *)
    echo "Unknown preset: $PRESET"
    exit 1
    ;;
esac

echo "Running nmap ${SCAN_ARGS[*]} on ${TARGET} -> ${OUT_PREFIX}"
# Use sudo for SYN scan if available
if [ "${SCAN_ARGS[0]}" = "-sS" ] && [ "$(id -u)" -ne 0 ]; then
  echo "Note: SYN scan requires privileges; falling back to connect scan (-sT)"
  SCAN_ARGS[0]="-sT"
fi

nmap "${SCAN_ARGS[@]}" -oA "${OUT_PREFIX}" "$TARGET" || echo "nmap finished with non-zero exit code"
echo "Saved outputs: ${OUT_PREFIX}.nmap ${OUT_PREFIX}.gnmap ${OUT_PREFIX}.xml"