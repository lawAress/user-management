FROM node:18-alpine AS builder

WORKDIR /app

# Instalar dependencias del sistema necesarias para compilar
RUN apk add --no-cache python3 make g++ build-base

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar todas las dependencias (incluyendo dev)
RUN npm ci

# Copiar código fuente
COPY . .

# Compilar
RUN npm run build

# =======================
# Stage de producción
# =======================
FROM node:18-alpine

WORKDIR /app

# Instalar solo dependencias de runtime necesarias
RUN apk add --no-cache python3 make g++ build-base

# Copiar package.json
COPY package*.json ./

# Instalar solo dependencias de producción
RUN npm ci --omit=dev

# Copiar archivos compilados desde el builder
COPY --from=builder /app/dist ./dist

# Configurar ambiente
ENV NODE_ENV=production
EXPOSE 3000

# Ejecutar la app compilada
CMD ["node", "dist/main"]
