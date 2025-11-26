FROM node:18-alpine AS builder

WORKDIR /app

# Copiar package.json e instalar dependencias completas para build
COPY package*.json ./
RUN npm ci

# Copiar el código fuente y compilar
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app

# Solo dependencias de producción
COPY package*.json ./
RUN npm ci --only=production

# Copiar los artefactos compilados
COPY --from=builder /app/dist ./dist

ENV NODE_ENV=production
EXPOSE 3000
CMD ["node", "dist/main"]
