-- MySQL 8.0
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    avatar VARCHAR(255) DEFAULT NULL,
    bio TEXT DEFAULT NULL,
    email_verified_at TIMESTAMP NULL DEFAULT NULL,
    last_login_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email)
);

CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL UNIQUE,
    content TEXT NOT NULL,
    excerpt VARCHAR(500) DEFAULT NULL,
    featured_image VARCHAR(255) DEFAULT NULL,
    author_id INT NOT NULL,
    status ENUM('draft', 'published', 'archived') DEFAULT 'published',
    views_count INT DEFAULT 0,
    published_at TIMESTAMP NULL DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_author (author_id),
    INDEX idx_status (status),
    INDEX idx_published_at (published_at),
    FULLTEXT idx_search (title, content)
);

-- Datos de prueba (mínimo 5 usuarios y 15 posts)
-- Passwords: Admin123! para admin, User123! para los demás (hash generado con password_hash)
INSERT INTO users (name, email, password, bio) VALUES
('Admin User', 'admin@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador'),
('John Doe', 'john@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Desarrollador web'),
('Jane Smith', 'jane@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Escritora'),
('Guest User', 'guest@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Invitado'),
('Sergio Garcia', 'sergio@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Full-stack developer');

-- 15 posts de prueba
INSERT INTO posts (title, slug, content, excerpt, author_id, status, published_at, views_count) VALUES
('Introducción a PHP 8', 'introduccion-php-8', '<h2>PHP 8 llega con muchas novedades</h2><p>PHP 8 es una de las versiones más importantes...</p>', 'Novedades de PHP 8', 2, 'published', DATE_SUB(NOW(), INTERVAL 30 DAY), 150),
('Arquitectura MVC con PHP', 'mvc-con-php', '<h2>¿Qué es MVC?</h2><p>MVC separa la aplicación en tres componentes...</p>', 'Aprende MVC en PHP', 1, 'published', DATE_SUB(NOW(), INTERVAL 25 DAY), 89),
('Bootstrap 5 Tutorial', 'bootstrap-5-tutorial', '<h2>Bootstrap 5</h2><p>Bootstrap 5 trae cambios importantes...</p>', 'Guía de Bootstrap 5', 3, 'published', DATE_SUB(NOW(), INTERVAL 20 DAY), 210),
('Base de datos optimizada', 'bd-optimizada', '<h2>Optimización de BD</h2><p>La optimización de SQL es fundamental...</p>', 'Consejos de optimización', 2, 'published', DATE_SUB(NOW(), INTERVAL 18 DAY), 67),
('Seguridad en aplicaciones web', 'seguridad-web', '<h2>Vulnerabilidades comunes</h2><p>SQL Injection, XSS, CSRF...</p>', 'Protege tu web', 4, 'published', DATE_SUB(NOW(), INTERVAL 15 DAY), 312),
('Programación orientada a objetos', 'poo-php', '<h2>Principios SOLID</h2><p>La POO permite código mantenible...</p>', 'POO en PHP', 1, 'published', DATE_SUB(NOW(), INTERVAL 12 DAY), 178),
('Desarrollo con Docker', 'docker-desarrollo', '<h2>Docker para desarrollo</h2><p>Entornos reproducibles...</p>', 'Docker y PHP', 2, 'draft', NULL, 0),
('JavaScript moderno', 'js-moderno', '<h2>ES6 y más</h2><p>Arrow functions, async/await...</p>', 'JS actual', 3, 'published', DATE_SUB(NOW(), INTERVAL 10 DAY), 245),
('APIs RESTful con PHP', 'api-rest-php', '<h2>Diseño de APIs</h2><p>RESTful, códigos HTTP...</p>', 'Crea APIs REST', 2, 'published', DATE_SUB(NOW(), INTERVAL 8 DAY), 156),
('Git y GitHub', 'git-github', '<h2>Flujos colaborativos</h2><p>Git Flow, pull requests...</p>', 'Git en equipo', 1, 'published', DATE_SUB(NOW(), INTERVAL 5 DAY), 320),
('Optimización de rendimiento', 'optimizacion-rendimiento', '<h2>Velocidad web</h2><p>Lazy loading, caching...</p>', 'Rendimiento web', 4, 'published', DATE_SUB(NOW(), INTERVAL 3 DAY), 98),
('Sistemas de plantillas', 'sistemas-plantillas', '<h2>Twig, Blade</h2><p>Herencia de plantillas...</p>', 'Motores de plantillas', 3, 'draft', NULL, 0),
('Pruebas unitarias', 'pruebas-unitarias', '<h2>PHPUnit</h2><p>TDD, tests automatizados...</p>', 'Testing en PHP', 2, 'published', DATE_SUB(NOW(), INTERVAL 1 DAY), 45),
('WebSockets en PHP', 'websockets-php', '<h2>Tiempo real</h2><p>Ratchet, Swoole...</p>', 'WebSockets con PHP', 1, 'published', NOW(), 23),
('Clean Code', 'clean-code', '<h2>Código limpio</h2><p>Nombres descriptivos, funciones pequeñas...</p>', 'Clean Code', 4, 'published', NOW(), 167);
