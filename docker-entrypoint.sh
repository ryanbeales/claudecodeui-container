#!/bin/sh
set -e

CCR_CONFIG_PATH="/home/node/.claude-code-router/config.json"

if [ -f "$CCR_CONFIG_PATH" ]; then
  echo "CCR configuration detected. Starting Claude Code Router..."
  
  # Diagnostic: Print config and check directory structure
  echo "Current configuration in $CCR_CONFIG_PATH:"
  cat "$CCR_CONFIG_PATH"
  echo "Directory structure of /home/node/.claude-code-router:"
  ls -la /home/node/.claude-code-router
  
  # Start CCR and redirect logs to a file for better visibility
  ccr start > /home/node/.claude-code-router/ccr.log 2>&1 &
  
  # Wait for CCR to be ready (up to 10 seconds)
  MAX_RETRIES=10
  RETRY_COUNT=0
  # Try both 127.0.0.1 and localhost to be sure
  until curl -s http://localhost:3456 > /dev/null || curl -s http://127.0.0.1:3456 > /dev/null || [ $RETRY_COUNT -eq $MAX_RETRIES ]; do
    echo "Waiting for CCR to be ready... ($((RETRY_COUNT+1))/$MAX_RETRIES)"
    sleep 1
    RETRY_COUNT=$((RETRY_COUNT+1))
  done

  if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "WARNING: CCR failed to start within 10 seconds. Check /home/node/.claude-code-router/ccr.log and /home/node/.claude-code-router/claude-code-router.log for details."
    # List logs to see if they exist
    ls -l /home/node/.claude-code-router/*.log
  else
    echo "CCR is ready. Exporting ANTHROPIC_BASE_URL."
    export ANTHROPIC_BASE_URL="http://127.0.0.1:3456"
    export CLAUDE_CODE_API_BASE_URL="http://127.0.0.1:3456"
    export ANTHROPIC_API_KEY="sk-ant-ccr-dummy"
  fi
fi

exec "$@"
