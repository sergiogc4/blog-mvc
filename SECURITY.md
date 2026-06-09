# Mesures de seguretat

- **CSRF**: Tots els formularis POST inclouen un token vàlid.
- **SQL Injection**: Ús de prepared statements en totes les consultes.
- **XSS**: `htmlspecialchars()` a totes les sortides de dades.
- **Contrasenyes**: Emmagatzemades amb `password_hash()` (BCrypt).
- **Sessions**: Gestió segura amb `session_start()` i regeneració implícita.
- **Headers**: `.htaccess` amb `X-Frame-Options DENY`, `X-XSS-Protection`, etc.
