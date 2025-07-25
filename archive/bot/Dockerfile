FROM node:22
WORKDIR /usr/src/app
COPY package.json package-lock.json* ./
RUN npm install
COPY tsconfig.json ./
COPY src ./src
COPY ../docs /docs
RUN ln -s /docs /usr/src/docs
RUN npm run build
RUN npm prune --production
CMD ["node", "dist/main.js"]
