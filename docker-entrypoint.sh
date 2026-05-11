#!/bin/sh
set -e

CCR_CONFIG_PATH="/home/node/.claude-code-router/config.json"

if [ -f "$CCR_CONFIG_PATH" ]; then
  echo "CCR configuration detected. Starting Claude Code Router..."
  # Start CCR and redirect logs to a file for better visibility
  ccr start > /home/node/.claude-code-router/ccr.log 2>&1 &
  
  # Wait for CCR to be ready (up to 10 seconds)
  MAX_RETRIES=10
  RETRY_COUNT=0
  until curl -s http://127.0.0.1:3456 > /dev/null || [ $RETRY_COUNT -eq $MAX_RETRIES ]; do
    echo "Waiting for CCR to be ready... ($((RETRY_COUNT+1))/$MAX_RETRIES)"
    sleep 1
    RETRY_COUNT=$((RETRY_COUNT+1))
  done

  if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "WARNING: CCR failed to start within 10 seconds. Check /home/node/.claude-code-router/ccr.log for details."
  else
    echo "CCR is ready. Exporting ANTHROPIC_BASE_URL."
    export ANTHROPIC_BASE_URL="http://127.0.0.1:3456"
    export CLAUDE_CODE_API_BASE_URL="http://127.0.0.1:3456"
    export ANTHROPIC_API_KEY="sk-ant-ccr-dummy"
  fi
fi

exec "$@"
