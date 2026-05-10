#!/bin/sh
set -e

CCR_CONFIG_PATH="/home/node/.claude-code-router/config.json"

if [ -f "$CCR_CONFIG_PATH" ]; then
  echo "CCR configuration detected. Starting Claude Code Router..."
  ccr start &
  export ANTHROPIC_BASE_URL="http://127.0.0.1:3456"
  export CLAUDE_CODE_API_BASE_URL="http://127.0.0.1:3456"
  export ANTHROPIC_API_KEY="sk-ant-ccr-dummy"
fi

exec "$@"
