# API de rutes

## Públiques
- `GET /` – Llista d'articles
- `GET /posts/{slug}` – Detall d'article
- `GET /search?q=...` – Cerca

## Autenticació
- `GET /login`, `POST /login`
- `GET /register`, `POST /register`
- `POST /logout`

## Usuari autenticat
- `GET /my-posts`, `GET /my-posts/create`, `POST /my-posts`
- `GET /my-posts/{id}/edit`, `POST /my-posts/{id}/update`
- `POST /my-posts/{id}/delete`, `POST /my-posts/{id}/publish`
- `GET /profile`, `GET /profile/edit`, `POST /profile/update`, `POST /profile/avatar`
