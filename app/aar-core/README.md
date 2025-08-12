# DevOnboarder AAR Core API

Express.js API server for the DevOnboarder After Action Report (AAR) system.

## Overview

The AAR Core API provides RESTful endpoints for:

- Listing AAR documents
- Retrieving specific AAR documents
- Validating AAR data against JSON schema
- Health checks for monitoring

## Architecture

This service follows DevOnboarder's modular design pattern:

- `app/aar-core/` - Express API server
- `app/aar-ui/` - React frontend UI
- Shared data in `docs/AAR/data/` directory

## API Endpoints

### Health Check

- `GET /api/health` - Service health status

### AAR Management

- `GET /api/aars` - List all AAR documents
- `GET /api/aars/:id` - Get specific AAR document
- `POST /api/aars/validate` - Validate AAR data structure

## Development

```bash
# Install dependencies
cd app/aar-core
npm ci

# Development with hot reload
npm run dev

# Build for production
npm run build

# Start production server
npm start
```

## Configuration

Environment variables:

- `PORT` - Server port (default: 3000)
- `CORS_ORIGIN` - Allowed CORS origins (default: localhost:5173,3000)

## Dependencies

- **Express** - Web framework
- **CORS** - Cross-origin resource sharing
- **Zod** - Runtime type validation
- **TypeScript** - Type safety
- **TSX** - TypeScript execution

## Integration

Works with:

- `app/aar-ui` React frontend
- DevOnboarder AAR schema system
- Docker containerization
- CI/CD workflows
