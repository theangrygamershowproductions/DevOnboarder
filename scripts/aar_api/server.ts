import express from 'express';
import cors from 'cors';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';
import { z } from 'zod';
import { validateAAR, formatValidationErrors } from './lib/aar.zod.js';
import { execFile } from 'child_process';
import { promisify } from 'util';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const execFileAsync = promisify(execFile);

const app = express();
const PORT = parseInt(process.env.AAR_UI_PORT || '3000', 10);
const NODE_ENV = process.env.NODE_ENV || 'development';

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGINS?.split(',') || ['http://localhost:5173', 'http://localhost:5174'],
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));

// Rate limiting middleware for AAR submissions
const rateLimit = new Map<string, { count: number; resetTime: number }>();
const RATE_LIMIT_WINDOW = 15 * 60 * 1000; // 15 minutes
const RATE_LIMIT_MAX = 10; // 10 requests per window

const rateLimitMiddleware = (req: express.Request, res: express.Response, next: express.NextFunction) => {
  const clientId = req.ip || 'unknown';
  const now = Date.now();

  const clientData = rateLimit.get(clientId) || { count: 0, resetTime: now + RATE_LIMIT_WINDOW };

  // Reset if window expired
  if (now > clientData.resetTime) {
    clientData.count = 0;
    clientData.resetTime = now + RATE_LIMIT_WINDOW;
  }

  clientData.count++;
  rateLimit.set(clientId, clientData);

  // Check if limit exceeded
  if (clientData.count > RATE_LIMIT_MAX) {
    return res.status(429).json({
      success: false,
      error: 'Rate limit exceeded',
      message: `Maximum ${RATE_LIMIT_MAX} requests per ${RATE_LIMIT_WINDOW / 60000} minutes`
    });
  }

  next();
};

// Serve static files (built React app) in production
if (NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../public')));
}

// Serve AAR reports
app.use('/reports', express.static(path.join(__dirname, '../docs/AAR/reports')));

// Helper function to generate filename from AAR data
const generateFilename = (aar: any): string => {
  const date = aar.date;
  const title = aar.title
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .trim();
  return `${date}_${title}.aar.json`;
};

// Helper function to ensure directory exists
const ensureDir = async (dirPath: string): Promise<void> => {
  try {
    await fs.access(dirPath);
  } catch {
    await fs.mkdir(dirPath, { recursive: true });
  }
};

// API Routes

// Health check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'AAR API',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// Submit new AAR
app.post('/api/aar/submit', rateLimitMiddleware, async (req, res) => {
  try {
    console.log('Received AAR submission:', req.body.title);

    // Validate AAR data against Zod schema
    const validation = validateAAR(req.body);
    if (!validation.success) {
      // Type assertion for the error case
      const validationError = validation as { success: false; error: z.ZodError };
      const errors = formatValidationErrors(validationError.error);
      console.log('Validation failed:', errors);
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: errors
      });
    }

    // TypeScript assertion - we know validation.success is true here
    const aar = validation.data;

    // Generate filename and ensure directory exists
    const filename = generateFilename(aar);
    const dataDir = path.join(__dirname, '../docs/AAR/data');
    const reportsDir = path.join(__dirname, '../docs/AAR/reports');

    await ensureDir(dataDir);
    await ensureDir(reportsDir);

    // Write AAR JSON data
    const aarPath = path.join(dataDir, filename);
    await fs.writeFile(aarPath, JSON.stringify(aar, null, 2));
    console.log('Saved AAR data:', aarPath);

    // Trigger AAR rendering using existing system
    try {
      const { stdout, stderr } = await execFileAsync('npm', ['run', 'aar:render', aarPath, reportsDir], {
        cwd: path.join(__dirname, '..')
      });
      console.log('AAR rendered successfully');
      if (stdout) console.log('Render output:', stdout);
      if (stderr) console.log('Render warnings:', stderr);
    } catch (renderError) {
      console.error('Render failed, but AAR data was saved:', renderError);
      // Continue - data is saved even if rendering fails
    }

    res.json({
      success: true,
      message: 'AAR submitted successfully',
      filename,
      data: aar
    });

  } catch (error) {
    console.error('AAR submission error:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// List existing AARs
app.get('/api/aar/list', async (req, res) => {
  try {
    const dataDir = path.join(__dirname, '../docs/AAR/data');
    const files = await fs.readdir(dataDir);
    const aarFiles = files
      .filter(f => f.endsWith('.aar.json'))
      .map(f => ({
        filename: f,
        name: f.replace('.aar.json', '').replace(/^\d{4}-\d{2}-\d{2}_/, ''),
        date: f.match(/^(\d{4}-\d{2}-\d{2})/)?.[1] || 'unknown'
      }))
      .sort((a, b) => b.date.localeCompare(a.date));

    res.json({
      success: true,
      aars: aarFiles
    });
  } catch (error) {
    console.error('List AARs error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to list AARs'
    });
  }
});

// Get specific AAR
app.get('/api/aar/:filename', async (req, res) => {
  try {
    const { filename } = req.params;
    if (!filename.endsWith('.aar.json')) {
      return res.status(400).json({
        success: false,
        error: 'Invalid filename format'
      });
    }

    const aarPath = path.join(__dirname, '../docs/AAR/data', filename);
    const data = await fs.readFile(aarPath, 'utf-8');
    const aar = JSON.parse(data);

    res.json({
      success: true,
      data: aar
    });
  } catch (error) {
    console.error('Get AAR error:', error);
    res.status(404).json({
      success: false,
      error: 'AAR not found'
    });
  }
});

// Get rendered AAR report
app.get('/api/aar/:filename/report', async (req, res) => {
  try {
    const { filename } = req.params;
    const baseName = filename.replace('.aar.json', '');
    const reportPath = path.join(__dirname, '../docs/AAR/reports', `${baseName}.md`);

    const report = await fs.readFile(reportPath, 'utf-8');
    res.json({
      success: true,
      report
    });
  } catch (error) {
    console.error('Get report error:', error);
    res.status(404).json({
      success: false,
      error: 'Report not found'
    });
  }
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log('AAR UI Service running on http://0.0.0.0:' + PORT);
  console.log('Health check: http://0.0.0.0:' + PORT + '/api/health');
  console.log('React UI: http://0.0.0.0:' + PORT + '/');
  console.log('Reports: http://0.0.0.0:' + PORT + '/reports/');
  console.log('Environment: ' + NODE_ENV);
});

// Serve React app for all other routes (SPA fallback)
if (NODE_ENV === 'production') {
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../public/index.html'));
  });
}

export default app;
