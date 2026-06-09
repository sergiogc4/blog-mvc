#!/bin/bash

echo "Verificant dades de prova a la base de dades..."

# Comprova si existeix l'usuari admin
USERS_COUNT=$(mysql -u blog_user -pBlogMVC2024! -N -e "SELECT COUNT(*) FROM blog_mvc.users" 2>/dev/null)
POSTS_COUNT=$(mysql -u blog_user -pBlogMVC2024! -N -e "SELECT COUNT(*) FROM blog_mvc.posts" 2>/dev/null)

if [ -z "$USERS_COUNT" ]; then
    echo "❌ No s'ha pogut connectar a la base de dades amb blog_user."
    echo "   Prova amb root:"
    mysql -u root -p -e "SELECT COUNT(*) FROM blog_mvc.users"
    exit 1
fi

echo "📊 Estat actual: $USERS_COUNT usuaris, $POSTS_COUNT posts"

if [ "$USERS_COUNT" -lt 5 ] || [ "$POSTS_COUNT" -lt 15 ]; then
    echo "⚠️ Faltes dades de prova. S'afegiran les que falten..."
    
    # Insereix usuaris que faltin (evita duplicats)
    mysql -u blog_user -pBlogMVC2024! blog_mvc << 'SQL'
INSERT IGNORE INTO users (name, email, password, bio) VALUES
('Admin User', 'admin@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador'),
('John Doe', 'john@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Desenvolupador'),
('Jane Smith', 'jane@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Escriptora'),
('Guest User', 'guest@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Convidat'),
('Sergio Garcia', 'sergio@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Full-stack');

-- Assegurar que hi ha com a mínim 15 posts
INSERT IGNORE INTO posts (title, slug, content, excerpt, author_id, status, published_at, views_count) VALUES
('Introducció a PHP 8', 'introduccio-php-8', '<h2>PHP 8 novetats</h2><p>PHP 8 inclou JIT, atributs, union types...</p>', 'Novedats PHP 8', 2, 'published', DATE_SUB(NOW(), INTERVAL 30 DAY), 150),
('Arquitectura MVC amb PHP', 'mvc-amb-php', '<h2>MVC explicat</h2><p>Separació de responsabilitats...</p>', 'Aprèn MVC', 1, 'published', DATE_SUB(NOW(), INTERVAL 25 DAY), 89),
('Bootstrap 5 Tutorial', 'bootstrap-5', '<h2>Bootstrap 5</h2><p>Nous components i utilitats...</p>', 'Guia Bootstrap 5', 3, 'published', DATE_SUB(NOW(), INTERVAL 20 DAY), 210),
('Base de dades optimitzada', 'bd-optimitzada', '<h2>Optimització SQL</h2><p>Índexs i consultes eficients...</p>', 'Millora la BD', 2, 'published', DATE_SUB(NOW(), INTERVAL 18 DAY), 67),
('Seguretat en aplicacions web', 'seguretat-web', '<h2>Vulnerabilitats comunes</h2><p>SQL Injection, XSS, CSRF...</p>', 'Protegeix la web', 4, 'published', DATE_SUB(NOW(), INTERVAL 15 DAY), 312),
('Programació orientada a objectes', 'poo-php', '<h2>Principis SOLID</h2><p>Codi mantenible...</p>', 'POO en PHP', 1, 'published', DATE_SUB(NOW(), INTERVAL 12 DAY), 178),
('Desenvolupament amb Docker', 'docker-desenvolupament', '<h2>Docker per a desenvolupament</h2><p>Entorns reproduïbles...</p>', 'Docker i PHP', 2, 'draft', NULL, 0),
('JavaScript modern', 'js-modern', '<h2>ES6+</h2><p>Arrow functions, async/await...</p>', 'JS actual', 3, 'published', DATE_SUB(NOW(), INTERVAL 10 DAY), 245),
('APIs RESTful amb PHP', 'api-rest-php', '<h2>Disseny d APIs</h2><p>RESTful, codis HTTP...</p>', 'Crea APIs', 2, 'published', DATE_SUB(NOW(), INTERVAL 8 DAY), 156),
('Git i GitHub per a equips', 'git-github-equips', '<h2>Fluxos col·laboratius</h2><p>Git Flow, pull requests...</p>', 'Git en equip', 1, 'published', DATE_SUB(NOW(), INTERVAL 5 DAY), 320),
('Optimització de rendiment', 'optimitzacio-rendiment', '<h2>Velocitat web</h2><p>Lazy loading, caching...</p>', 'Rendiment web', 4, 'published', DATE_SUB(NOW(), INTERVAL 3 DAY), 98),
('Sistemes de plantilles', 'sistemes-plantilles', '<h2>Twig, Blade</h2><p>Herència de plantilles...</p>', 'Motors de plantilles', 3, 'draft', NULL, 0),
('Proves unitàries', 'proves-unitaries', '<h2>PHPUnit</h2><p>TDD, tests automatitzats...</p>', 'Testing en PHP', 2, 'published', DATE_SUB(NOW(), INTERVAL 1 DAY), 45),
('WebSockets en PHP', 'websockets-php', '<h2>Temps real</h2><p>Ratchet, Swoole...</p>', 'WebSockets amb PHP', 1, 'published', NOW(), 23),
('Clean Code', 'clean-code', '<h2>Codi net</h2><p>Noms descriptius, funcions petites...</p>', 'Clean Code', 4, 'published', NOW(), 167);
SQL

    echo "✅ Dades de prova inserides (o ja existien)."
else
    echo "✅ Ja hi ha prou dades de prova."
fi

# Mostrar resum
echo ""
echo "📋 Resum actual:"
mysql -u blog_user -pBlogMVC2024! -e "SELECT COUNT(*) as usuaris FROM blog_mvc.users; SELECT COUNT(*) as posts FROM blog_mvc.posts;" blog_mvc
echo ""
echo "👤 Usuaris:"
mysql -u blog_user -pBlogMVC2024! -e "SELECT id, name, email FROM blog_mvc.users;" blog_mvc
echo ""
echo "📝 Posts (mostrant 5):"
mysql -u blog_user -pBlogMVC2024! -e "SELECT id, title, status FROM blog_mvc.posts LIMIT 5;" blog_mvc
