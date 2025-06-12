# PATCHED v0.1.1 utils/redis_client.py — mock Redis when requested

import os
from functools import lru_cache
import redis
import fakeredis


@lru_cache(maxsize=1)
def get_redis_client() -> redis.Redis:
    if os.environ.get("REDIS_MOCK") == "1":
        return fakeredis.FakeRedis()
    url = os.environ.get("REDIS_URL", "redis://localhost:6379/0")
    return redis.Redis.from_url(url)
