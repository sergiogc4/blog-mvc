# Esquema de base de dades

## Taula `users`
id, name, email, password, avatar, bio, email_verified_at, last_login_at, created_at, updated_at

## Taula `posts`
id, title, slug, content, excerpt, featured_image, author_id, status, views_count, published_at, created_at, updated_at

## Relació
Un usuari té molts posts (clau forana `author_id` amb `ON DELETE CASCADE`).
