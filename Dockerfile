# CI image (KiCad, MCP server, virtual display tooling)
FROM docker.io/ubuntu:24.04 AS ci
ARG DEBIAN_FRONTEND=noninteractive
ARG KICAD_PPA=ppa:kicad/kicad-9.0-releases
ARG KICAD_MCP_REF=cbb59a6203997f5e916be7e0480d63fe5519134a

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential make git curl wget ca-certificates sudo procps \
    software-properties-common gnupg locales \
    python3 python3-pip python3-venv nodejs npm \
    xvfb fluxbox x11vnc novnc websockify x11-utils xdotool imagemagick scrot \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# KiCad (incl. kicad-cli and the SWIG pcbnew module in system python)
RUN add-apt-repository -y "$KICAD_PPA" \
    && apt-get update && apt-get install -y --no-install-recommends kicad \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Ubuntu 24.04 ships a default "ubuntu" user at uid 1000; replace it with dev
RUN (userdel -r ubuntu 2>/dev/null || true) \
    && useradd --create-home --uid 1000 --shell /bin/bash dev \
    && usermod --append --groups sudo dev \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/dev \
    && chmod 0440 /etc/sudoers.d/dev

# Default venv: sees system pcbnew (SWIG) and has kipy (IPC API)
RUN python3 -m venv --system-site-packages /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir kicad-python \
    && chown -R dev:dev /opt/venv
ENV VIRTUAL_ENV=/opt/venv
ENV PATH=/opt/venv/bin:$PATH

# MCP server for KiCad (mixelpixx/KiCAD-MCP-Server, pinned)
RUN git clone https://github.com/mixelpixx/KiCAD-MCP-Server /opt/kicad-mcp \
    && cd /opt/kicad-mcp && git checkout "$KICAD_MCP_REF" \
    && npm ci && npm run build \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt \
    && chown -R dev:dev /opt/kicad-mcp

ENV DISPLAY=:99
WORKDIR /workspaces/kicad-pocs

# Devcontainer image (adds developer conveniences)
FROM ci AS dev

USER root
RUN apt-get update && apt-get install -y --no-install-recommends zsh vim jq man \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && chsh -s /bin/zsh dev

USER dev
# oh-my-zsh for dev (zsh-in-docker), git plugin
RUN sh -c "$(curl -fsSL https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
    -p git
