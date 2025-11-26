FROM node:18-alpine

WORKDIR /app

# Instalar dependencias del sistema (por si acaso)
RUN apk add --no-cache python3 make g++

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar todas las dependencias (incluyendo dev para compilar)
RUN npm install

# Copiar código fuente
COPY . .

# Compilar
RUN npm run build

# Remover node_modules y reinstalar solo producción
RUN rm -rf node_modules && npm install --only=production

# Configurar ambiente
ENV NODE_ENV=production
EXPOSE 3000

# Ejecutar la app compilada
CMD ["node", "dist/main"]
