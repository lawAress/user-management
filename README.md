<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456
[circleci-url]: https://circleci.com/gh/nestjs/nest

  <p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>
    <p align="center">
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>
<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>
<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>
<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>
<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>
  <a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg" alt="Donate us"/></a>
    <a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>
  <a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow" alt="Follow us on Twitter"></a>
</p>
  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)
  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->

## Description

API de gestión de usuarios y autenticación construida con NestJS, TypeORM y SQLite.

**Funcionalidades principales:**
-  CRUD de usuarios (crear, listar, obtener, actualizar, eliminar)
-  Autenticación con email/contraseña
-  Generación y validación de JWT tokens
-  Contraseñas hasheadas con bcrypt
-  Validaciones automáticas (class-validator)

## Project Setup

```bash
# Instalar dependencias
npm install

# (Opcional) Crear .env con configuración
cp .env.example .env
```

## Running the Project

```bash
# Modo desarrollo (con auto-recarga)
npm run start:dev

# Modo producción
npm run build
npm run start:prod
```

## Running Tests

```bash
# unit tests
npm run test

# e2e tests
npm run test:e2e

# test coverage
npm run test:cov
```

## Endpoints

### Usuarios

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/users` | Crear nuevo usuario |
| GET | `/users` | Listar todos los usuarios |
| GET | `/users/:id` | Obtener usuario por ID |
| PATCH | `/users/:id` | Actualizar usuario |
| DELETE | `/users/:id` | Eliminar usuario |

#### Ejemplo: Crear usuario
```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "password": "password123"
  }'
```

### Autenticación

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/auth/login` | Login y obtener JWT token |

#### Ejemplo: Login
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "juan@example.com",
    "password": "password123"
  }'
```

**Respuesta:**
```json
{
  "user": {
    "id": 1,
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "role": null
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## Estructura del Proyecto

```
src/
├── auth/                 # Autenticación (Passport, JWT)
├── users/                # Gestión de usuarios (CRUD)
├── config/               # Configuración (Base de datos)
├── app.module.ts         # Módulo principal
└── main.ts               # Punto de entrada
```

## Configuración

- **Base de datos**: SQLite (`database.sqlite`)
- **Puerto**: 3000 (configurable via `.env` o `process.env.PORT`)
- **JWT Secret**: `src/auth/constants.ts` (usar `.env` en producción)
- **Node Version**: >= 18.16.1

## Despliegue en Koyeb

**Lee la guía completa en [`DEPLOYMENT_KOYEB.md`](./DEPLOYMENT_KOYEB.md)** para instrucciones detalladas.

### Resumen rápido:

1. Haz push a GitHub: `git push origin main`
2. En Koyeb: **Create Service > GitHub > Docker** (detecta `Dockerfile` automáticamente)
3. Configura variables de entorno (ver `DEPLOYMENT_KOYEB.md`):
   - `PORT=3000`
   - `NODE_ENV=production`
   - `JWT_SECRET` = tu secreto (usa `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"` para generar)
   - `DATABASE_URL` = conexión a Postgres (usa Neon, Railway, Supabase o BD administrada de Koyeb)
4. Despliega y revisa logs

### Probar localmente con Postgres (docker-compose)

Antes de desplegar en Koyeb, prueba con Postgres localmente:

```bash
docker-compose up --build
```

Accede a `http://localhost:3000`. El archivo `docker-compose.yml` incluye:
- Base de datos PostgreSQL
- Aplicación NestJS con hot-reload en modo desarrollo

Detener:
```bash
docker-compose down
```

Limpiar volúmenes (reiniciar BD):
```bash
docker-compose down -v
```

### CI/CD automático (GitHub Actions)

Este proyecto incluye workflow automático (`.github/workflows/deploy.yml`) que:
- Ejecuta tests en cada push a `main`
- Compila y publica imagen Docker en Docker Hub (requiere configurar secrets)

Para activarlo:
1. Genera token en Docker Hub (Access Tokens)
2. En GitHub repo: **Settings > Secrets > New secret**
   - `DOCKER_USERNAME` = tu usuario
   - `DOCKER_PASSWORD` = tu token
3. Haz push a `main` → GitHub Actions construirá y publicará automáticamente


## Seguridad (TODO)

 Mejoras pendientes para producción:
- [ ] Mover JWT secret a `.env`
- [ ] Deshabilitar `synchronize: true`
- [ ] Rate limiting
- [ ] HTTPS
- [ ] Refresh tokens
- [ ] Roles y permisos

## Recursos

- [NestJS Documentation](https://docs.nestjs.com)
- [TypeORM Documentation](https://typeorm.io)
- [Passport.js](https://www.passportjs.org/)

## License

UNLICENSED
