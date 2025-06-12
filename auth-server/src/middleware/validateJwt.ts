// PATCHED v1.1.6 auth-server/src/middleware/validateJwt.ts — verify JWT claims
import { Request, Response, NextFunction } from 'express';
import jwt, { JwtPayload } from 'jsonwebtoken';
import redisClient, { memoryGet } from '../services/redis';

const ISSUER = process.env.JWT_ISSUER;
const AUDIENCE = process.env.JWT_AUDIENCE;
const PUBLIC_KEY = process.env.JWT_PUBLIC_KEY;
const SECRET = process.env.JWT_SECRET || '';

export default async function validateJwt(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  const auth = req.header('Authorization');
  if (!auth || !auth.startsWith('Bearer ')) {
    res.status(401).json({ error: 'missing Authorization header' });
    return;
  }
  const token = auth.slice(7);
  try {
    const options: jwt.VerifyOptions = {
      algorithms: PUBLIC_KEY ? ['RS256'] : ['HS256'],
      issuer: ISSUER,
      audience: AUDIENCE,
    };
    const key = PUBLIC_KEY || SECRET;
    const payload = jwt.verify(token, key, options) as JwtPayload;
    if (payload.exp && Date.now() >= payload.exp * 1000) {
      throw new Error('expired');
    }
    if (payload.jti) {
      if (redisClient.isReady) {
        const exists = await redisClient.get(payload.jti);
        if (exists) {
          throw new Error('revoked');
        }
      } else if (memoryGet(payload.jti)) {
        throw new Error('revoked');
      }
    }
    (req as any).jwt = { sub: payload.sub as string };
    next();
    return;
  } catch {
    res.status(401).json({ error: 'invalid token' });
    return;
  }
}
