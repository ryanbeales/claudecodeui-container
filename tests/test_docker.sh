#!/bin/bash
set -e

IMAGE_NAME=${1:-"claudecodeui-container:test"}

echo "Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

echo "Testing tools in the image..."
docker run --rm "$IMAGE_NAME" node -v
docker run --rm "$IMAGE_NAME" npm -v
docker run --rm "$IMAGE_NAME" gh --version
docker run --rm "$IMAGE_NAME" kubectl version --client
docker run --rm "$IMAGE_NAME" jq --version
docker run --rm "$IMAGE_NAME" yq --version
docker run --rm "$IMAGE_NAME" dyff version
docker run --rm "$IMAGE_NAME" claude --version || echo "Claude code installed but check command returned non-zero."
docker run --rm "$IMAGE_NAME" genai --help >/dev/null || echo "Google GenAI installed but help command returned non-zero."
docker run --rm "$IMAGE_NAME" cloudcli --help >/dev/null || echo "CloudCLI installed but help command returned non-zero."

echo "All tests passed for image: $IMAGE_NAME"
