import express from 'express';
import cors from 'cors';
import rateLimit from 'express-rate-limit';
import { z } from 'zod';
import { readFileSync, existsSync, readdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Rate limiting middleware
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(limiter);

// CORS configuration
app.use(cors({
  origin: process.env.CORS_ORIGIN || ['http://localhost:5173', 'http://localhost:3000'],
  credentials: true
}));

app.use(express.json());

// Health check endpoint
app.get('/api/health', (_req, res) => {
  res.json({ status: 'ok', service: 'aar-core' });
});

// AAR schema validation
const aarSchema = z.object({
  schema_version: z.string(),
  title: z.string(),
  date: z.string(),
  type: z.enum(['Infrastructure', 'CI', 'Monitoring', 'Documentation', 'Feature', 'Security']),
  priority: z.enum(['Critical', 'High', 'Medium', 'Low']),
  executive_summary: z.object({
    problem: z.string(),
    solution: z.string(),
    outcome: z.string()
  }),
  phases: z.array(z.object({
    name: z.string(),
    duration: z.string(),
    description: z.string(),
    status: z.string()
  })).optional(),
  outcomes: z.object({
    success_metrics: z.array(z.string()),
    challenges_overcome: z.array(z.string())
  }).optional(),
  follow_up: z.object({
    action_items: z.array(z.object({
      task: z.string(),
      owner: z.string(),
      due_date: z.string(),
      status: z.string()
    }))
  }).optional(),
  lessons_learned: z.array(z.string()).optional(),
  references: z.array(z.object({
    title: z.string(),
    url: z.string(),
    type: z.string()
  })).optional()
});

// Input validation helpers
const validateId = (id: string): boolean => {
  // Only allow alphanumeric characters, hyphens, and underscores
  // Prevent path traversal attempts
  if (!id || typeof id !== 'string') {
    return false;
  }

  const sanitizedId = id.replace(/[^a-zA-Z0-9\-_]/g, '');
  return sanitizedId === id && id.length > 0 && id.length <= 100;
};

// Get AAR data directory path
const getAARDataPath = () => {
  const possiblePaths = [
    join(__dirname, '../../../docs/AAR/data'),
    join(process.cwd(), 'docs/AAR/data'),
    '/app/docs/AAR/data' // Docker path
  ];

  for (const path of possiblePaths) {
    if (existsSync(path)) {
      return path;
    }
  }

  throw new Error('AAR data directory not found');
};

// More restrictive rate limiting for file system access endpoints
const fileAccessLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 30, // Limit each IP to 30 file access requests per windowMs
  message: 'Too many file access requests, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

// List all AAR files
app.get('/api/aars', fileAccessLimiter, (_req, res) => {
  try {
    const dataPath = getAARDataPath();
    const files = readdirSync(dataPath)
      .filter(file => file.endsWith('.aar.json'))
      .map(file => {
        const content = JSON.parse(readFileSync(join(dataPath, file), 'utf-8'));
        return {
          id: file.replace('.aar.json', ''),
          title: content.title,
          date: content.date,
          type: content.type,
          priority: content.priority
        };
      })
      .sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    res.json(files);
  } catch (error) {
    console.error('Error listing AARs:', error);
    res.status(500).json({ error: 'Failed to list AAR files' });
  }
});

// Get specific AAR by ID
app.get('/api/aars/:id', fileAccessLimiter, (req, res) => {
  try {
    const { id } = req.params;

    // Validate and sanitize the ID parameter
    if (!validateId(id)) {
      return res.status(400).json({ error: 'Invalid AAR ID format' });
    }

    const dataPath = getAARDataPath();
    const filePath = join(dataPath, `${id}.aar.json`);

    if (!existsSync(filePath)) {
      return res.status(404).json({ error: 'AAR not found' });
    }

    const content = JSON.parse(readFileSync(filePath, 'utf-8'));
    const validatedContent = aarSchema.parse(content);

    return res.json(validatedContent);
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({ error: 'Invalid AAR format', details: error.errors });
    }

    console.error('Error reading AAR:', error);
    return res.status(500).json({ error: 'Failed to read AAR file' });
  }
});

// Validate AAR data
app.post('/api/aars/validate', (req, res) => {
  try {
    const validatedData = aarSchema.parse(req.body);
    return res.json({ valid: true, data: validatedData });
  } catch (error) {
    if (error instanceof z.ZodError) {
      return res.status(400).json({
        valid: false,
        errors: error.errors.map(err => ({
          path: err.path.join('.'),
          message: err.message
        }))
      });
    }

    return res.status(500).json({ error: 'Validation failed' });
  }
});

// Error handling middleware
app.use((error: Error, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
  console.error('Unhandled error:', error);
  res.status(500).json({ error: 'Internal server error' });
});

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

app.listen(PORT, () => {
  console.log(`AAR Core API server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/api/health`);
});
