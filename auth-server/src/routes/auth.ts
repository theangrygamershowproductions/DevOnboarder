// PATCHED v1.0.0 auth-server/src/routes/auth.ts — login and logout routes
import { Router, Request, Response } from 'express';
import express from 'express';
import jwt from 'jsonwebtoken';
import { randomUUID } from 'crypto';
import validateJwt from '../middleware/validateJwt';
import { db } from '../services/db';
import redisClient, { memoryAdd } from '../services/redis';

const router = Router();

/**
 * GET /api/auth/user
 * Return fresh user data from the database using the `sub` from the JWT.
 */
router.get(
  '/auth/user',
  validateJwt,
  async (req: Request, res: Response): Promise<void> => {
    const sub = (req as any).jwt?.sub;
    if (!sub) {
      res.status(400).json({ message: 'Missing JWT subject' });
      return;
    }

    const user = await db.getUserById(sub);
    if (!user) {
      res.status(404).json({ message: 'User not found' });
      return;
    }

    res.json({
      user: {
        id: user.id,
        username: user.username,
        avatar: user.avatar,
        isAdmin: user.isAdmin,
        isVerified: user.isVerified,
        verificationType: user.verificationType,
      },
    });
  },
);

// simple in-memory credential check
const USER = { id: '1', username: 'demo', password: 'password' };

router.post(
  '/auth/login',
  express.urlencoded({ extended: false }),
  (req: Request, res: Response): void => {
    const { username, password } = req.body;
    if (username !== USER.username || password !== USER.password) {
      res.status(401).json({ error: 'Invalid credentials' });
      return;
    }
    const jti = randomUUID();
    const token = jwt.sign(
      { sub: USER.id, jti },
      process.env.JWT_SECRET!,
      {
        algorithm: 'HS256',
        issuer: process.env.JWT_ISSUER,
        audience: process.env.JWT_AUDIENCE,
        expiresIn: '1m',
      },
    );
    res.json({ access_token: token });
  },
);

router.post('/auth/logout', validateJwt, async (req: Request, res: Response) => {
  const auth = req.header('Authorization') as string;
  const token = auth.slice(7);
  const payload = jwt.decode(token) as jwt.JwtPayload | null;
  const jti = payload?.jti as string | undefined;
  const exp = payload?.exp as number | undefined;
  if (!jti || !exp) {
    res.status(400).json({ message: 'Malformed token' });
    return;
  }
  const ttl = exp - Math.floor(Date.now() / 1000);
  if (ttl > 0) {
    if (redisClient.isReady) {
      await redisClient.setEx(jti, ttl, '1');
    } else {
      memoryAdd(jti, ttl);
    }
  }
  res.json({ detail: 'logged out' });
});

export default router;
