FROM docker.io/cloudflare/sandbox:0.7.20

ENV NODE_VERSION=24.22.1
RUN ARCH="$(dpkg --print-architecture)" \
    && case "${ARCH}" in \
         amd64) NODE_ARCH="x64" ;; \
         arm64) NODE_ARCH="arm64" ;; \
         *) echo "Unsupported architecture: ${ARCH}" >&2; exit 1 ;; \
       esac \
    && apt-get update && apt-get install -y xz-utils ca-certificates \
    && rm -rf /usr/local/lib/node_modules /usr/local/bin/node /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/corepack /usr/local/bin/openclaw \
    && curl -fsSLk https://nodejs.org{NODE_VERSION}/node-v${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz -o /tmp/node.tar.xz \
    && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node.tar.xz \
    && npm install -g npm@12.2.3 \
    && node --version \
    && npm --version

ARG CACHE_BUST=2026-11-19-v2026-11-3
RUN npm uninstall -g openclaw || true \
    && rm -f /usr/bin/openclaw /usr/local/bin/openclaw \
    && npm install -g openclaw@2026.11.3 \
    && openclaw --version

ENV HOME=/home/openclaw
RUN mkdir -p /home/openclaw/.openclaw \
    && mkdir -p /home/openclaw/clawd \
    && mkdir -p /home/openclaw/clawd/skills \
    && ln -s /home/openclaw/.openclaw /root/.openclaw \
    && ln -s /home/openclaw/clawd /root/clawd

COPY start-openclaw.sh /usr/local/bin/start-openclaw.sh
RUN chmod +x /usr/local/bin/start-openclaw.sh

COPY skills/ /home/openclaw/clawd/skills/
RUN chmod -R a+rX /home/openclaw

WORKDIR /home/openclaw/clawd
EXPOSE 18789
