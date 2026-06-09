# T9 - JWT Avançat + Jerarquia de Rols

Projecte d'autenticació avançada amb Node.js, MongoDB i JWT. Implementa un sistema de rols jeràrquics amb herència de permisos, delegació temporal, refresh tokens, blacklist, rate limiting i auditoria.

## Funcionalitats

- **JWT Avançat**: Access Token (15 min) + Refresh Token (7 dies)
- **Token Blacklist**: Logout segur
- **Jerarquia de Rols**: SUPER_ADMIN > ADMIN > MANAGER > USER > VIEWER (amb herència)
- **Delegació temporal** de permisos
- **Rate limiting** per rol (1000,500,200,100,50 req/min)
- **Auditoria avançada** (canvis, IP, userAgent, export CSV)
- **Recuperació de contrasenya**

## Instal·lació

1. Clona el repositori
2. `npm install`
3. Copia `.env.example` a `.env` i configura les teves credencials
4. Assegura que MongoDB està funcionant
5. `npm run dev`

L'usuari administrador per defecte és:
- **Email**: `admin@system.com`
- **Contrasenya**: `Admin123!`

## Endpoints principals (51 en total)

### Autenticació
- `POST /api/auth/register`
- `POST /api/auth/login` (retorna accessToken + refreshToken)
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `POST /api/auth/forgot-password`
- `POST /api/auth/reset-password/:token`

### Usuaris (requereix token)
- `GET /api/users`
- `GET /api/users/:id`
- `PUT /api/users/:id`
- `DELETE /api/users/:id`
- `GET /api/users/:id/permissions`

### Rols
- `GET /api/roles`
- `GET /api/roles/:id`
- `POST /api/roles`
- `PUT /api/roles/:id`
- `DELETE /api/roles/:id`
- `GET /api/roles/:id/hierarchy`
- `GET /api/roles/:id/permissions`

### Permisos
- `GET /api/permissions`
- `GET /api/permissions/:id`
- `POST /api/permissions`
- `PUT /api/permissions/:id`
- `DELETE /api/permissions/:id`

### Delegació
- `GET /api/delegations`
- `GET /api/delegations/:id`
- `POST /api/delegations`
- `DELETE /api/delegations/:id`
- `GET /api/delegations/user/:userId`

### Auditoria
- `GET /api/audit/logs`
- `GET /api/audit/logs?action=...`
- `GET /api/audit/logs?userId=...`
- `GET /api/audit/stats`
- `GET /api/audit/export?format=csv`

### Tasques (exemple)
- `GET /api/tasks`
- `POST /api/tasks`
- `GET /api/tasks/:id`
- `PUT /api/tasks/:id`
- `DELETE /api/tasks/:id`

### Proves
- Script automàtic: `./test_api.sh` (executa les 51 proves)
- Col·lecció Postman: `T9-JWT-Avancat-Jerarquia.postman_collection.json`

## Seguretat
- Contrasenyes xifrades amb bcrypt
- JWT amb secrets separats
- Blacklist de tokens revocats
- Rate limiting per rol
- Helmet, CORS, validacions

## Tecnologies
- Node.js, Express
- MongoDB, Mongoose
- JSON Web Token, bcryptjs
- express-rate-limit, helmet, cors

## Llicència
MIT

## Autor
Sergio Gómez
