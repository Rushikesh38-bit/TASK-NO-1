#!/usr/bin/env bash
# Simple, documented wrapper for nmap recon scans.
# Use only on targets you own or have explicit permission to test.

set -euo pipefail

print_help() {
  cat <<'EOF'
scan.sh — simple nmap recon wrapper

Usage:
  ./scan.sh [options] <target>

Options:
  -p <ports>    Comma-separated ports or port ranges (default: top-1000)
  -o <prefix>   Output file prefix (default: recon-<target>-<timestamp>)
  -s <preset>   Preset: quick | full | discover (default: quick)
  -h            Show this help

Examples:
  ./scan.sh 192.0.2.1
  ./scan.sh -p 1-1000 -s full example.com

Safety:
  Only run against authorized targets.

EOF
}

timestamp() {
  date +"%Y%m%dT%H%M%S"
}

# Defaults
PORTS=""
PRESET="quick"
OUT_PREFIX=""
TARGETS=()

while getopts "p:o:s:h" opt; do
  case "$opt" in
    p) PORTS="$OPTARG" ;;
    o) OUT_PREFIX="$OPTARG" ;;
    s) PRESET="$OPTARG" ;;
    h) print_help; exit 0 ;;
    *) print_help; exit 1 ;;
  esac
done
shift $((OPTIND-1))

if [ $# -lt 1 ]; then
  echo "Error: missing target"
  print_help
  exit 1
fi

TARGETS=("$@")

# Build nmap args by preset
NMAP_ARGS=()
case "$PRESET" in
  quick)
    # SYN scan (requires privileges for -sS), version detection, default scripts
    NMAP_ARGS+=("-sS" "-Pn" "-sV" "-O" "--top-ports" "1000" "--open" "-T4")
    ;;
  discover)
    # Just discovery + service probe
    NMAP_ARGS+=("-sn" "-PS" "-PA" "-T4")
    ;;
  full)
    # More aggressive and thorough (longer)
    NMAP_ARGS+=("-sS" "-sU" "-p" "1-65535" "-sV" "-O" "--script=default,safe" "-T4")
    ;;
  *)
    echo "Unknown preset: $PRESET"
    exit 1
    ;;
esac

# Apply user ports if provided
if [ -n "$PORTS" ]; then
  # Remove --top-ports etc. and use -p
  NMAP_ARGS=("${NMAP_ARGS[@]//*--top-ports*}")
  NMAP_ARGS=("${NMAP_ARGS[@]//-p}")
  NMAP_ARGS+=("-p" "$PORTS")
fi

for tgt in "${TARGETS[@]}"; do
  TS="$(timestamp)"
  PREFIX="${OUT_PREFIX:-recon-${tgt}-${TS}}"
  echo "Starting nmap recon on ${tgt} -> ${PREFIX}"
  # Create outputs: normal, greppable, xml
  nmap "${NMAP_ARGS[@]}" -oN "${PREFIX}.txt" -oG "${PREFIX}.gnmap" -oX "${PREFIX}.xml" "$tgt" || {
    echo "nmap returned a non-zero exit code for target ${tgt}"
  }
  echo "Outputs: ${PREFIX}.txt ${PREFIX}.gnmap ${PREFIX}.xml"
done