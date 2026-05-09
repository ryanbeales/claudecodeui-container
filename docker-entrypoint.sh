#!/bin/sh
set -e

# Patch the cloudcli models to include ANTHROPIC_MODEL if set
if [ -n "$ANTHROPIC_MODEL" ]; then
  cat << 'EOF' > /tmp/patch_models.js
const fs = require('fs');
const file = '/usr/local/lib/node_modules/@cloudcli-ai/cloudcli/dist-server/shared/modelConstants.js';
if (fs.existsSync(file)) {
  let content = fs.readFileSync(file, 'utf8');
  const model = process.env.ANTHROPIC_MODEL;
  if (!content.includes('value: "' + model + '"')) {
    if (content.includes('export const CLAUDE_MODELS = {')) {
      content = content.replace(
        /export const CLAUDE_MODELS = \{\s*(\/\/.*)?\s*OPTIONS:\s*\[/, 
        'export const CLAUDE_MODELS = {\n    OPTIONS: [\n        { value: "' + model + '", label: "Ollama: ' + model + '" },'
      );
      try {
        fs.writeFileSync(file, content);
        console.log('Patched cloudcli models to include: ' + model);
      } catch (e) {
        console.error('Failed to patch model constants: ' + e.message);
      }
    }
  }
}
EOF
  node /tmp/patch_models.js
fi

exec "$@"
