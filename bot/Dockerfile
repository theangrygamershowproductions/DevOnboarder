FROM node:20
WORKDIR /usr/src/app
COPY package.json package-lock.json* ./
RUN npm install
COPY tsconfig.json ./
COPY src ./src
RUN npm run build
RUN npm prune --production
CMD ["node", "dist/main.js"]
