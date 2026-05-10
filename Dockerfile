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
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.36/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.36/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && apt-get install -y kubectl && \
    rm -rf /var/lib/apt/lists/*

# Install yq
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
    chmod +x /usr/local/bin/yq

# Install dyff
RUN curl -sL https://github.com/homeport/dyff/releases/download/v1.12.0/dyff_1.12.0_linux_amd64.tar.gz | tar -xz -C /usr/local/bin dyff

# Install agent clis and code ui
RUN npm install -g @anthropic-ai/claude-code@latest @google/gemini-cli@latest @cloudcli-ai/cloudcli@latest @musistudio/claude-code-router@latest task-master-ai



COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER node
ENV HOME=/home/node

EXPOSE 3001

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["cloudcli"]
