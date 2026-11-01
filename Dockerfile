# AIHOT (KKKKhazix/AIHOT, MIT) packaged for Railway: api + worker + web in one container.
FROM node:24-trixie-slim AS src
RUN apt-get update && apt-get install -y --no-install-recommends git ca-certificates && rm -rf /var/lib/apt/lists/*
RUN git clone https://github.com/KKKKhazix/AIHOT /src && cd /src && git checkout edfa18fbb121f5028707ffb2c3fa9ae66487e5e6 && rm -rf .git

FROM node:24-trixie-slim AS base
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends postgresql-client ca-certificates tini && rm -rf /var/lib/apt/lists/*

FROM base AS build
COPY --from=src /src /app
RUN npm ci --no-audit --no-fund && npm run build -w @aihot/web && npm prune --omit=dev --no-audit --no-fund

FROM base
ENV NODE_ENV=production AIHOT_DATA_DIR=/data API_HOST=127.0.0.1 API_PORT=3001 API_BASE_URL=http://127.0.0.1:3001 \
    WEB_HOST=0.0.0.0 PORT=3000 TRUST_PROXY=true INGEST_RATE_LIMIT=10 \
    LLM_BASE_URL=https://api.deepseek.com/v1 LLM_MODEL=deepseek-flash \
    FEISHU_CONTENT_PUSH_ENABLED=false FEISHU_INTERNAL_ENABLED=false
COPY --from=build --chown=node:node /app /app
COPY railway/start.sh /usr/local/bin/aihot-start
RUN chmod +x /usr/local/bin/aihot-start && mkdir -p /data && chown node:node /data
EXPOSE 3000
ENTRYPOINT ["tini","--"]
CMD ["aihot-start"]
