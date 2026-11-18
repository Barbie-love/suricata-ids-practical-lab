#!/usr/bin/env bash
set -euo pipefail
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <SURICATA_IP>"
  exit 1
fi
target="$1"
echo "Sending fixed lab payload to ${target}:9999"
printf 'SURICATA-LAB-TEST\n' | nc -nv -w 3 "$target" 9999
echo "Traffic attempt completed. Check the listener and Suricata logs."
