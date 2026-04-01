FROM node:24-bookworm-slim

# Install system dependencies & build tools (for native npm modules)
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    jq \
    gnupg \
    apt-transport-https \
    make \
    g++ \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install gh-cli
RUN mkdir -p -m 755 /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -y kubectl && \
    rm -rf /var/lib/apt/lists/*

# Install yq
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
    chmod +x /usr/local/bin/yq

# Install dyff
RUN curl -sL https://github.com/homeport/dyff/releases/download/v1.9.1/dyff_1.9.1_linux_amd64.tar.gz | tar -xz -C /usr/local/bin dyff

# Install agent clis and code ui
RUN npm install -g @anthropic-ai/claude-code @google/gemini-cli @siteboon/claude-code-ui

# Configure workspace
RUN mkdir -p /home/node/workspace && \
    chown -R node:node /home/node/workspace

USER node
ENV HOME=/home/node
ENV WORKSPACE_DIR=/home/node/workspace

EXPOSE 3001

CMD ["cloudcli"]
