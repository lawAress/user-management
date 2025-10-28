# Gestor de Usuarios con NestJS

## 1. Objetivo del Proyecto
- Implementar un backend REST para gestionar usuarios (crear, listar, consultar, actualizar, eliminar).
- Proveer autenticación de usuarios mediante JWT y validación de datos.
- Usar SQLite como base de datos para un despliegue sencillo en desarrollo.

## 2. Tecnologías y Librerías Utilizadas
- NestJS 11 (estructura modular, controladores, servicios).
- TypeORM (ORM) con `sqlite3`.
- Autenticación: `@nestjs/jwt`, `@nestjs/passport`, `passport-local`, `passport-jwt`.
- Seguridad: `bcrypt` para hash de contraseñas.
- Validación: `class-validator` y `class-transformer` con `ValidationPipe` global.
- Testing base configurado con Jest (incluye ejemplo e2e por defecto de Nest).

## 3. Arquitectura y Módulos
- `AppModule`: Módulo raíz que integra Users y Auth, y la conexión TypeORM.
- `UsersModule`: Entidad `User`, `UsersService` (lógica), `UsersController` (endpoints CRUD).
- `AuthModule`: `AuthService`, `AuthController`, estrategias `LocalStrategy` y `JwtStrategy`, guards para proteger rutas.
- `config/database.config.ts`: Configuración de TypeORM (SQLite, synchronize en desarrollo).
- `main.ts`: Arranque de Nest y `ValidationPipe` global.

## 4. Funcionalidades / Partes del Proyecto
- Login (autenticación):
  - `POST /auth/login` usando email y password.
  - Devuelve `access_token` (JWT) y datos básicos del usuario.
- Vista principal:
  - `GET /` responde con el mensaje base del proyecto (controlador `AppController`).
- Gestión de usuarios:
  - Crear usuario: `POST /users`.
  - Listar usuarios: `GET /users`.
  - Consultar usuario: `GET /users/:id`.
  - Actualizar usuario: `PATCH /users/:id`.
  - Eliminar usuario: `DELETE /users/:id`.
- Autorización (opcional):
  - Rutas pueden protegerse con `JwtAuthGuard` para requerir token.
  - El payload del JWT incluye `email`, `sub` (id), `role`.

## 5. Modelo de Datos (User)
- Campos:
  - `id` (PK, autoincremental)
  - `name` (string, requerido)
  - `email` (string único, formato válido, requerido)
  - `password` (string, mínimo 6 caracteres, almacenado como hash)
  - `role` (string, opcional)
  - `isActive` (boolean, por defecto `true`)
  - `createdAt`, `updatedAt` (timestamps automáticos)

## 6. Validación y Seguridad
- `ValidationPipe` global:
  - `whitelist: true`: se eliminan propiedades no definidas en el DTO.
  - `forbidNonWhitelisted: true`: se rechazan campos extra.
  - `transform: true`: convierte tipos (ej. `id` de params a número).
- Contraseñas:
  - Se encriptan con `bcrypt` tanto al crear como al actualizar.
- Autenticación:
  - Local: verifica credenciales y, si son válidas, permite login.
  - JWT: protege rutas usando token en `Authorization: Bearer <token>`.

## 7. Endpoints Principales
- Auth
  - `POST /auth/login` Body: `{ email, password }` → `{ user, access_token }`
- Users
  - `POST /users` Body: `{ name, email, password, role? }` → 201 Created
  - `GET /users` → Lista de usuarios
  - `GET /users/:id` → Usuario por id
  - `PATCH /users/:id` Body parcial (ej. `{ name, password }`) → Usuario actualizado
  - `DELETE /users/:id` → 204 No Content

## 8. Flujo de Autenticación
1) El cliente realiza `POST /auth/login` con email y password.
2) `LocalStrategy` valida credenciales con `AuthService.validateUser()`.
3) Si son válidas, `AuthService.login()` firma un JWT con `{ email, sub, role }` y lo devuelve.
4) El cliente usa el token en el header `Authorization: Bearer <token>` para acceder a rutas protegidas.

## 9. Instalación y Ejecución
- Requisitos: Node 18+ y npm.
- Instalación:
  - `npm install`
- Ejecución:
  - Desarrollo: `npm run start:dev` (http://localhost:3000/)
  - Producción: `npm run build` y luego `npm run start:prod`
- Base de datos:
  - Archivo SQLite en `./database.sqlite`.

## 10. Pruebas
- Comandos disponibles:
  - `npm run test` (unitarias)
  - `npm run test:e2e` (end-to-end)

## 11. Ejemplos de Uso (curl)
- Crear usuario:
```
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{ "name": "Juan", "email": "juan@example.com", "password": "secret123", "role": "admin" }'
```
- Login y uso de token:
```
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{ "email": "juan@example.com", "password": "secret123" }'

# Supón que obtienes access_token, úsalo así:
curl http://localhost:3000/users -H "Authorization: Bearer TU_TOKEN"
```

## 12. Consideraciones y Buenas Prácticas
- No usar `synchronize: true` en producción; migraciones recomendadas.
- Mover `jwtConstants.secret` y tiempos de expiración a variables de entorno.
- Proteger rutas sensibles con `JwtAuthGuard` y, si aplica, políticas por `role`.
- Manejo de errores consistente (409 en email duplicado, 404 en id inexistente, 401 en login fallido, 400 en validaciones).

## 13. Roadmap (Mejoras Futuras)
- Roles y permisos por recurso (admin/usuario).
- Paginación y filtros en listado de usuarios.
- Recuperación de contraseña y cambio de contraseña.
- Auditoría de acciones.
- Integración de frontend (vista principal, listado y detalle de clientes/usuarios).