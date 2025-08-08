# Multi-stage build for AAR UI service
FROM node:22-alpine AS build

# Build React UI
WORKDIR /app/ui
COPY app/aar-ui/package*.json ./
RUN npm ci --only=production
COPY app/aar-ui/ ./
RUN npm run build

# Build Express API
WORKDIR /app/api
COPY package.json ./
COPY scripts/aar_api/ ./
RUN npm install express cors zod @types/express @types/cors
RUN npx tsc server.ts --outDir dist --target es2022 --module es2022 --moduleResolution node --esModuleInterop

# Production image
FROM node:22-alpine

WORKDIR /app

# Install production dependencies
COPY package.json ./
RUN npm install express cors zod --only=production

# Copy built assets
COPY --from=build /app/ui/dist ./public
COPY --from=build /app/api/dist ./api

# Copy AAR system components
COPY docs/AAR/ ./docs/AAR/
COPY scripts/render_aar.js ./scripts/
COPY scripts/test_aar_golden.js ./scripts/
COPY scripts/migrate_aar.js ./scripts/

# Create necessary directories
RUN mkdir -p logs docs/AAR/data docs/AAR/reports

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/api/health || exit 1

EXPOSE 3000

# Serve both UI and API
CMD ["node", "api/server.js"]
