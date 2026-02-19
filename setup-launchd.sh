#!/bin/bash
# Setup script for People Swarm launchd service
# Serves particle-swarm.html via Python http.server on port 8420

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_NAME="com.peopleswarm.server.plist"
PLIST_SRC="$SCRIPT_DIR/$PLIST_NAME"
PLIST_DST="$HOME/Library/LaunchAgents/$PLIST_NAME"
PORT=8420

echo "=== People Swarm — launchd Setup ==="
echo ""
echo "Project directory: $SCRIPT_DIR"
echo "Port:             $PORT"
echo "URL:              http://localhost:$PORT/particle-swarm.html"
echo ""

# Unload existing service if present
if launchctl list 2>/dev/null | grep -q "com.peopleswarm.server"; then
    echo "Stopping existing service..."
    launchctl unload "$PLIST_DST" 2>/dev/null || true
fi

# Create plist with correct working directory
mkdir -p "$HOME/Library/LaunchAgents"
sed "s|WORKING_DIR_PLACEHOLDER|$SCRIPT_DIR|g" "$PLIST_SRC" > "$PLIST_DST"

echo "Installed plist to: $PLIST_DST"

# Load the service
launchctl load "$PLIST_DST"

echo "Service loaded and running."
echo ""

# Wait a moment then verify
sleep 1
if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/particle-swarm.html" | grep -q "200"; then
    echo "Verified: http://localhost:$PORT/particle-swarm.html is live."
else
    echo "Warning: Server may still be starting. Check http://localhost:$PORT/particle-swarm.html in a moment."
fi

echo ""
echo "To open in browser:  open http://localhost:$PORT/particle-swarm.html"
echo "To stop:             launchctl unload ~/Library/LaunchAgents/$PLIST_NAME"
echo "To restart:          launchctl unload ~/Library/LaunchAgents/$PLIST_NAME && launchctl load ~/Library/LaunchAgents/$PLIST_NAME"
echo "Logs:                /tmp/peopleswarm.log and /tmp/peopleswarm.err"
