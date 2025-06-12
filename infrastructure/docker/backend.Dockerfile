# PATCHED v0.1.8 infrastructure/docker/backend.Dockerfile — Backend container

FROM python:3.13-slim
WORKDIR /app
COPY ../.. /app
RUN pip install --no-cache-dir -r backend/requirements.txt
CMD ["python", "backend/main.py"]
