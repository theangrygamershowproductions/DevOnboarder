// PATCHED v1.1.5 auth-server/src/index.ts — Express auth server skeleton
import express from 'express';
import authRouter from './routes/auth';

export function createApp() {
  const app = express();
  app.use(express.json());

  app.use('/api', authRouter);

  app.get('/healthz', (_req, res) => {
    res.json({ status: 'ok' });
  });

  return app;
}

if (require.main === module) {
  const port = Number(process.env.PORT || 4000);
  createApp().listen(port, () => {
    console.log(`Auth server listening on ${port}`);
  });
}
