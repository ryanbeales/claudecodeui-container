# Claude Code UI Container

This repository contains a containerized version of [Claude Code UI](https://github.com/siteboon/claudecodeui), exposing Claude Code, Gemini, Codex, and other AI agents via a web interface.

It includes a complete set of command-line tools commonly used alongside these agents, such as `gh`, `kubectl`, `jq`, `yq`, and `dyff`. The repository also provides a Helm chart to deploy the application easily into a Kubernetes environment with persistent storage for agent configuration files.

## Features
- **Docker Image**: Bundles `node`, `siteboon/claudecodeui`, Anthropic's `claude-code`, Google's `gemini` cli, GitHub CLI, and various system utilities.
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

## Development

- Local tests exist for verifying Docker image integrity (`tests/test_docker.sh`).
- Use `helm lint charts/claudecodeui` to verify chart correctness.
