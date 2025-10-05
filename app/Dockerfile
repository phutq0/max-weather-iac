# syntax=docker/dockerfile:1

FROM node:18-alpine AS base
WORKDIR /app
RUN apk add --no-cache curl

FROM base AS deps
COPY package*.json ./
RUN npm install --only=production

FROM base AS runner
USER node
WORKDIR /app
COPY --chown=node:node --from=deps /app/node_modules ./node_modules
COPY --chown=node:node package.json ./package.json
COPY --chown=node:node app.js ./app.js
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 CMD curl -f http://localhost:3000/health || exit 1
CMD ["node", "app.js"]

