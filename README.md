# Claude Code UI Container

This repository contains a containerized version of [Claude Code UI](https://github.com/siteboon/claudecodeui), exposing Claude Code, Gemini, Codex, and other AI agents via a web interface.

It includes a complete set of command-line tools commonly used alongside these agents, such as `gh`, `kubectl`, `jq`, `yq`, and `dyff`. The repository also provides a Helm chart to deploy the application easily into a Kubernetes environment with persistent storage for agent configuration files.

## Features
- **Docker Image**: Bundles `node`, `@cloudcli-ai/cloudcli`, Anthropic's `claude-code`, Google's `gemini` cli, GitHub CLI, and various system utilities.
- **Helm Chart**: Ready-to-use chart for deploying to Kubernetes (`k3s`).
- **CI/CD**: Fully automated Nightly & Release pipelines via GitHub Actions.
- **Rootless & Secure**: Designed with best practices, avoiding Alpine in favor of `node:22-bookworm-slim` for broader compatibility, and utilizing read-only ServiceAccounts for `kubectl`.

## Deployment

The provided Helm chart makes deployment simple.

### Example `values.yaml`

```yaml
replicaCount: 1

image:
  repository: ghcr.io/ryanbeales/claudecodeui-container
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""

ccr:
  enabled: true
  providers:
    - name: "ollama-local"
      url: "http://ollama.ai-services.svc.cluster.local:11434/v1/chat/completions"
      apiKey: "ollama"
      models: ["gemma4:34b", "llama3:70b"]
  routing:
    - uiModel: "opus"
      targetProvider: "ollama-local"
      targetModel: "llama3:70b"
    - uiModel: "sonnet"
      targetProvider: "ollama-local"
      targetModel: "gemma4:34b"

persistence:
  enabled: true
  size: 1Gi
  # storageClassName: "local-path" # adjust depending on your k8s cluster

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: claudecodeui.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific

serviceAccount:
  create: true
  rbac:
    enabled: true  # Creates read-only cluster role for kubectl commands from the agent
```

### Installation

```bash
helm install claudecodeui oci://ghcr.io/ryanbeales/charts/claudecodeui -f values.yaml
```
*(Or clone this repository and run `helm install claudecodeui ./charts/claudecodeui -f values.yaml`)*

### Example Implementation

A complete working example of this chart being deployed can be found in my [personal-k8s-config repo](https://github.com/ryanbeales/personal-k8s-config/tree/main/ai-services/claudecodeui).

## Local Docker Testing with CCR

You can run the container locally with Docker and use the Claude Code Router (CCR) to proxy requests to your local Ollama instances.

1. Download the example configurations from the `examples/` directory.
2. Run the container, volume mounting the examples directory to `/home/node/.claude-code-router`:

```bash
docker run -d \
  --name claudecodeui \
  -p 3001:3001 \
  -v $(pwd)/examples:/home/node/.claude-code-router \
  ghcr.io/ryanbeales/claudecodeui-container:latest
```

The entrypoint script will detect the `config.json` inside the mounted directory, automatically start the CCR proxy in the background, and direct the UI to use it. You can edit `examples/config.json` and `examples/custom-router.js` to point to your specific models.

## Development

- Local tests exist for verifying Docker image integrity (`tests/test_docker.sh`).
- Use `helm lint charts/claudecodeui` to verify chart correctness.
