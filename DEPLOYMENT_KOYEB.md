# Guía de Despliegue en Koyeb

## Requisitos Previos

1. **Cuenta en Koyeb**: [https://www.koyeb.com](https://www.koyeb.com) (gratis, con límites)
2. **Cuenta en GitHub**: Tu repositorio debe estar público (o usar deploy token privado)
3. **Base de datos**: Opción A (Postgres administrada por Koyeb) u Opción B (DBaaS externo como Neon, Railway, etc.)

---

## Opción 1: Desplegar desde GitHub (Recomendado)

### Paso 1: Preparar el repositorio en GitHub

1. Asegúrate de que tu repo esté en GitHub (público o privado con autenticación).
2. Haz push de tu rama `main`:
   ```bash
   git add .
   git commit -m "feat: prepare for Koyeb deployment"
   git push origin main
   ```

### Paso 2: Crear servicio en Koyeb

1. Inicia sesión en [Koyeb Dashboard](https://app.koyeb.com/).
2. Haz clic en **"Create Service"**.
3. Selecciona **"GitHub"** como fuente de deployment.
4. Si es la primera vez, autoriza Koyeb para acceder a GitHub y selecciona tu repositorio.
5. Selecciona **"Docker"** como builder (Koyeb detectará el `Dockerfile`).
6. Configura:
   - **Repository**: tu repositorio
   - **Branch**: `main` (o la rama que uses)
   - **Builder**: Docker

### Paso 3: Configurar variables de entorno

En la sección **Environment Variables**, añade (ℹ️ mantener valores en secreto):

```
PORT=3000
NODE_ENV=production
JWT_SECRET=tu_secreto_muy_seguro_aqui_cambiar_antes_de_produccion
JWT_EXPIRES_IN=3600
DATABASE_URL=postgresql://usuario:contraseña@host:5432/basedatos
```

**Importante**: Genera un JWT_SECRET fuerte:
```bash
# En tu máquina local, ejecuta:
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Paso 4: Configurar la base de datos

#### Opción A: Usar PostgreSQL administrada de Koyeb (más simple)

1. En el dashboard de Koyeb, selecciona **"Managed PostgreSQL"** o **"Databases"**.
2. Crea una base de datos llamada `appdb`.
3. Obtén la cadena de conexión (DATABASE_URL) y pégala en el paso 3.

#### Opción B: Usar servicio externo (Neon, Railway, Supabase, etc.)

1. Crea una base de datos en tu proveedor preferido.
2. Obtén la cadena de conexión PostgreSQL.
3. Pégala en la variable `DATABASE_URL` en Koyeb.

**Ejemplo de DATABASE_URL:**
```
postgresql://myuser:mypassword@pg.example.com:5432/myappdb
```

### Paso 5: Configurar Health Check (Opcional pero recomendado)

En **Settings > Health Check**:
- **Protocol**: HTTP
- **Port**: 3000
- **Path**: `/` (o cualquier endpoint que devuelva 200)
- **Interval**: 30 segundos
- **Timeout**: 5 segundos

### Paso 6: Desplegar

1. Revisa la configuración y haz clic en **"Deploy"**.
2. Koyeb comenzará a construir la imagen Docker y desplegar automáticamente.
3. Monitorea el progreso en la pestaña **"Logs"** o **"Activity"**.

**Tiempo de deployment**: 3-5 minutos normalmente.

### Paso 7: Verificar la aplicación

Una vez deployada, Koyeb te proporcionará una URL pública. Prueba los endpoints:

```bash
# Obtener la URL desde Koyeb dashboard
export KOYEB_URL="https://tu-app-xxxx.koyeb.app"

# Crear usuario
curl -X POST "${KOYEB_URL}/users" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'

# Login
curl -X POST "${KOYEB_URL}/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Listar usuarios
curl "${KOYEB_URL}/users"
```

---

## Opción 2: Desplegar con Docker Registry (Docker Hub)

Si prefieres controlar la imagen Docker:

### Paso 1: Construir y publicar imagen en Docker Hub

```bash
# 1. Iniciar sesión en Docker Hub
docker login

# 2. Construir imagen
docker build -t tu_usuario/user-management:latest .

# 3. Publicar
docker push tu_usuario/user-management:latest
```

### Paso 2: Crear servicio en Koyeb desde Docker Hub

1. En Koyeb, selecciona **"Create Service" > "Docker"**.
2. Inicia sesión con Docker Hub (si es privado).
3. Ingresa la imagen: `tu_usuario/user-management:latest`.
4. Configura variables de entorno igual que en Opción 1, Paso 3.
5. Despliega.

---

## Opción 3: Automatizar con GitHub Actions (CI/CD)

Crear un workflow que compile, pruebe y publique en Docker Hub automáticamente:

### Crear archivo `.github/workflows/deploy.yml`:

```yaml
name: Build and Deploy to Docker Hub

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ${{ secrets.DOCKER_USERNAME }}/user-management:latest,${{ secrets.DOCKER_USERNAME }}/user-management:${{ github.sha }}

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Koyeb
        run: |
          # Usar Koyeb API (necesita KOYEB_API_KEY en secrets)
          echo "Deployment triggered at Koyeb (manual redeploy desde dashboard)"
```

### Configurar secrets en GitHub:

1. Ve a tu repositorio **Settings > Secrets and variables > Actions**.
2. Añade:
   - `DOCKER_USERNAME`: tu usuario de Docker Hub
   - `DOCKER_PASSWORD`: tu token de acceso de Docker Hub (no contraseña)
   - `KOYEB_API_KEY`: (opcional, para automatizar redeploy)

---

## Troubleshooting

### Error: "Build failed" o "Dockerfile not found"
- Verifica que `Dockerfile` esté en la raíz del repositorio.
- Asegúrate de hacer push del Dockerfile a GitHub.

### Error: "DATABASE_URL is invalid"
- Verifica el formato: `postgresql://usuario:contraseña@host:puerto/base_de_datos`
- Prueba localmente con `docker-compose.yml` primero (ver README.md).

### Error: "Can't connect to database"
- Comprueba que el host de la BD es accesible desde Koyeb (no está bloqueado por firewall).
- Si usas BD local o privada, expón el puerto o usa DBaaS.

### App funciona pero endpoints devuelven 500
- Revisa los **Logs** en Koyeb dashboard para ver errores detallados.
- Verifica que `DATABASE_URL` sea correcta.
- Asegúrate de que JWT_SECRET esté configurado.

### El servicio se reinicia constantemente
- Revisa el health check (puede estar fallo).
- Verisa logs para ver si hay crashes.
- Aumenta el timeout en health check.

---

## Actualizar la aplicación después del despliegue

### Con GitHub (automático):
1. Haz cambios en tu rama `main`.
2. Haz push: `git push origin main`.
3. Koyeb reconstruirá y redeployará automáticamente (configurado con webhook).

### Con Docker Hub (manual):
1. Haz cambios localmente.
2. Reconstruye y publica:
   ```bash
   docker build -t tu_usuario/user-management:latest .
   docker push tu_usuario/user-management:latest
   ```
3. En Koyeb, redeploy manualmente o espera a que detecte nueva imagen (puede tardar hasta 1 hora).

---

## Costos y Límites en Koyeb (Free Tier)

- **Instancias**: 2 gratuitamente (cada una pequeña)
- **BD PostgreSQL**: No incluida, usa servicio externo gratis (Neon, Render, etc.)
- **Límites**: ~0.5 GB RAM, shared CPU, ~20 GB almacenamiento BD
- **Uptime**: Sin SLA en free tier, puede dormir si no hay tráfico

Para producción serio, considera plan de pago o usar multi-cloud (Koyeb + Neon + otros).

---

## Pasos rápidos resumidos

1. **Push a GitHub**: `git push origin main`
2. **Koyeb**: Create Service > GitHub > Docker > Config env vars > Deploy
3. **Prueba**: `curl https://tu-app.koyeb.app/users`
4. **Actualizar**: `git push` para CI/CD automático, o redeploy manual en dashboard

¡Listo!
