#!/usr/bin/env bash
# Launch KiCad on the virtual display and save a screenshot. Usage: screenshot.sh out.png
set -euo pipefail
OUT="${1:-kicad.png}"
export DISPLAY="${DISPLAY:-:99}"
"$(dirname "$0")/novnc.sh" start
kicad >/tmp/kicad-shot.log 2>&1 &
KPID=$!
sleep 15
import -window root "$OUT"
kill "$KPID" 2>/dev/null || true
test -s "$OUT"
echo "saved $OUT"
