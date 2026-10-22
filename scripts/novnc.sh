#!/usr/bin/env bash
# Start Xvfb + fluxbox + x11vnc + noVNC. Usage: novnc.sh start|stop
set -euo pipefail
D="${DISPLAY:-:99}"
RUN=/tmp/kicad-pocs-novnc
PORT="${NOVNC_PORT:-6080}"
RES="${NOVNC_RES:-1600x900x24}"
mkdir -p "$RUN"

start_bg() { # name cmd...
  local n=$1; shift
  nohup "$@" >"$RUN/$n.log" 2>&1 &
  echo $! >"$RUN/$n.pid"
}

case "${1:-start}" in
  start)
    [ -e "$RUN/xvfb.pid" ] && kill -0 "$(cat "$RUN/xvfb.pid")" 2>/dev/null && { echo "already running"; exit 0; }
    start_bg xvfb Xvfb "$D" -screen 0 "$RES" -nolisten tcp
    for _ in $(seq 50); do xdpyinfo -display "$D" >/dev/null 2>&1 && break; sleep 0.2; done
    start_bg fluxbox env DISPLAY="$D" fluxbox
    start_bg x11vnc x11vnc -display "$D" -forever -shared -nopw -rfbport 5900 -localhost
    NOVNC_ROOT=/usr/share/novnc
    start_bg novnc websockify --web "$NOVNC_ROOT" "$PORT" localhost:5900
    for _ in $(seq 50); do curl -fs "http://localhost:$PORT/vnc.html" >/dev/null && break; sleep 0.2; done
    echo "noVNC ready: http://localhost:$PORT/vnc.html?autoconnect=1"
    ;;
  stop)
    for n in novnc x11vnc fluxbox xvfb; do
      [ -e "$RUN/$n.pid" ] && kill "$(cat "$RUN/$n.pid")" 2>/dev/null || true
    done
    rm -rf "$RUN"
    echo stopped
    ;;
  *) echo "usage: $0 start|stop"; exit 2;;
esac
