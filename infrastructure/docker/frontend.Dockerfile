# PATCHED v0.1.8 infrastructure/docker/frontend.Dockerfile — Frontend container

FROM node:22-slim
WORKDIR /app
COPY ../.. /app
RUN corepack enable && pnpm install --frozen-lockfile
CMD ["pnpm", "--dir", "frontend", "dev"]
