# Multi-stage build for AAR UI service
FROM node:22-alpine AS build

# Build React UI
WORKDIR /app/ui
COPY app/aar-ui/package*.json ./
RUN npm ci
COPY app/aar-ui/ ./
RUN npm run build

# Build Express API
WORKDIR /app/api
COPY app/aar-core/package*.json ./
RUN npm ci
COPY app/aar-core/ ./
RUN npm run build

# Production image
FROM node:22-alpine

WORKDIR /app

# Install production dependencies for API
COPY app/aar-core/package*.json ./
RUN npm ci --only=production

# Copy built assets
COPY --from=build /app/ui/dist ./public
COPY --from=build /app/api/dist ./api

# Copy AAR system components
COPY docs/AAR/ ./docs/AAR/

# Create necessary directories
RUN mkdir -p logs docs/AAR/data docs/AAR/reports

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/api/health || exit 1

EXPOSE 3000

# Serve both UI and API
CMD ["node", "api/server.js"]
