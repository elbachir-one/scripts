#!/usr/bin/env bash

# Manually byte-swapping a GUID and formatting
set -euo pipefail

guid="${1:-}"
[[ -z "$guid" ]] && { echo "Usage: $0 <GUID>" >&2; exit 1; }

s=${guid//[\{\}-]/}
s=${s,,}
[[ ${#s} -ne 32 || ! $s =~ ^[0-9a-f]+$ ]] && { echo "Invalid GUID" >&2; exit 1; }

ns() { local x="$1" out=""; for ((i=0;i<${#x};i+=2)); do out+="${x:i+1:1}${x:i:1}"; done; echo "$out"; }

fields=()
fields[0]=$(t=$(ns "${s:0:8}"); echo "${t:6:2}${t:4:2}${t:2:2}${t:0:2}")
fields[1]=$(t=$(ns "${s:8:4}"); echo "${t:2:2}${t:0:2}")
fields[2]=$(t=$(ns "${s:12:4}"); echo "${t:2:2}${t:0:2}")
fields[3]=$(t=$(ns "${s:16:4}"); echo "${t:2:2}${t:0:2}")
fields[4]=$(ns "${s:20:12}")

echo "${fields[*]}" | tr -d ' ' | tr '[:lower:]' '[:upper:]'
