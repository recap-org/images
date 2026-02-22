#!/bin/bash

PORT=10000
DISPLAY_NUM=100

echo ""
echo "🚀 RECAP Stata GUI"
echo ""
echo "Stata is starting..."
echo ""
echo "Open the following URL in your browser:"
echo ""
echo "    http://localhost:${PORT}"
echo ""
echo "Press Ctrl+C to stop the server."
echo ""

# Clean up stale sessions
pkill xpra 2>/dev/null || true
pkill Xvfb 2>/dev/null || true
rm -rf /tmp/xpra ~/.xpra 2>/dev/null || true

# Start xpra in foreground
exec xpra start :${DISPLAY_NUM} \
  --bind-tcp=0.0.0.0:${PORT} \
  --html=on \
  --daemon=no \
  --webcam=no \
  --dpi=96 \
  --notifications=no \
  --mdns=no \
  --audio=no \
  --ssh=no \
  --dbus=no \
  --keyboard-layout=auto \
  --start="xstata-mp"