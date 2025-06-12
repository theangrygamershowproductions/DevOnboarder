# PATCHED v0.1.0 discord-bot/Dockerfile — Container for Discord bot

FROM node:22-slim
WORKDIR /app
COPY package.json ./
RUN npm install --omit=dev
COPY . .
CMD ["npm", "start"]
