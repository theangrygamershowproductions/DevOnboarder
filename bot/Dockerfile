FROM node:18
WORKDIR /usr/src/app
COPY package.json package-lock.json* ./
RUN npm install --production
COPY tsconfig.json ./
COPY src ./src
RUN npm run build
CMD ["node", "dist/main.js"]
