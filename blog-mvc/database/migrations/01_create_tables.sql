-- Crear base de datos
CREATE DATABASE IF NOT EXISTS blog_mvc;
USE blog_mvc;

-- Tabla de usuarios
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

-- Tabla de posts
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

-- Insertar usuarios de prueba (password: User123! para todos excepto admin que es Admin123!)
INSERT INTO users (name, email, password, bio) VALUES 
('Admin User', 'admin@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador del blog'),
('John Doe', 'john@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Desarrollador web y entusiasta de la tecnología'),
('Jane Smith', 'jane@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Escritora y creadora de contenido'),
('Guest User', 'guest@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Usuario invitado'),
('Sergio Garcia', 'sergio@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Desarrollador full-stack');

-- Insertar posts de prueba
INSERT INTO posts (title, slug, content, excerpt, author_id, status, published_at, views_count) VALUES
('Introducción a PHP 8', 'introduccion-php-8', '<h2>PHP 8 llega con muchas novedades</h2><p>PHP 8 es una de las versiones más importantes en años, trayendo características como JIT, atributos, union types, match expression y mucho más.</p><p>El compilador JIT (Just In Time) puede mejorar significativamente el rendimiento en ciertos escenarios. Los atributos permiten añadir metadatos a las clases sin necesidad de docblocks.</p>', 'Descubre todas las novedades de PHP 8, la última versión del popular lenguaje de programación', 2, 'published', NOW() - INTERVAL 30 DAY, 150),
('Arquitectura MVC con PHP', 'mvc-con-php', '<h2>¿Qué es MVC?</h2><p>MVC (Model-View-Controller) es un patrón de arquitectura que separa la aplicación en tres componentes principales.</p><p>El Modelo maneja los datos y la lógica de negocio, la Vista presenta la interfaz de usuario y el Controlador maneja las peticiones del usuario.</p>', 'Aprende a implementar el patrón MVC en tus aplicaciones PHP de forma profesional', 1, 'published', NOW() - INTERVAL 25 DAY, 89),
('Bootstrap 5 Tutorial', 'bootstrap-5-tutorial', '<h2>Bootstrap 5: La última versión</h2><p>Bootstrap 5 trae cambios importantes como la eliminación de jQuery, nuevos componentes y utilidades CSS.</p><p>El sistema de grid sigue siendo potente y ahora incluye soporte para CSS Grid Layout.</p>', 'Guía completa de Bootstrap 5 para crear interfaces responsive modernas', 3, 'published', NOW() - INTERVAL 20 DAY, 210),
('Base de datos optimizada', 'bd-optimizada', '<h2>Consejos para optimizar tu base de datos</h2><p>La optimización de consultas SQL es fundamental para el rendimiento de tu aplicación.</p><p>Los índices bien diseñados pueden acelerar las consultas drásticamente.</p>', 'Mejora el rendimiento de tu aplicación con estas técnicas de optimización de BD', 2, 'published', NOW() - INTERVAL 18 DAY, 67),
('Seguridad en aplicaciones web', 'seguridad-web', '<h2>Las 5 vulnerabilidades más comunes</h2><p>SQL Injection, XSS, CSRF son algunas de las amenazas más frecuentes en aplicaciones web.</p><p>Implementar medidas de seguridad como prepared statements y CSRF tokens es esencial.</p>', 'Protege tu aplicación web contra las vulnerabilidades más comunes', 4, 'published', NOW() - INTERVAL 15 DAY, 312),
('Programación orientada a objetos', 'poo-php', '<h2>Principios SOLID</h2><p>La programación orientada a objetos permite crear código más mantenible y reutilizable.</p><p>Los principios SOLID son fundamentales para un buen diseño OOP.</p>', 'Domina la POO en PHP con ejemplos prácticos y principios SOLID', 1, 'published', NOW() - INTERVAL 12 DAY, 178),
('Desarrollo con Docker', 'docker-desarrollo', '<h2>Docker para entornos de desarrollo</h2><p>Docker permite crear entornos de desarrollo reproducibles y aislados.</p><p>Con Docker Compose puedes definir aplicaciones multi-contenedor fácilmente.</p>', 'Aprende a usar Docker para tus proyectos PHP y MySQL', 2, 'draft', NULL, 0),
('JavaScript moderno', 'js-moderno', '<h2>ES6 y más allá</h2><p>JavaScript ha evolucionado muchísimo con características como arrow functions, destructuring, spread operator y async/await.</p><p>TypeScript añade tipado estático al ecosistema JavaScript.</p>', 'Actualiza tus conocimientos de JavaScript con las últimas características', 3, 'published', NOW() - INTERVAL 10 DAY, 245),
('APIs RESTful con PHP', 'api-rest-php', '<h2>Diseñando APIs REST</h2><p>Las APIs RESTful siguen principios arquitectónicos que las hacen escalables y mantenibles.</p><p>Los códigos de estado HTTP y los métodos REST son fundamentales.</p>', 'Guía para construir APIs RESTful profesionales con PHP', 2, 'published', NOW() - INTERVAL 8 DAY, 156),
('Git y GitHub para equipos', 'git-github', '<h2>Flujos de trabajo colaborativos</h2><p>Git Flow y GitHub Flow son estrategias populares para manejar el control de versiones en equipo.</p><p>Las pull requests facilitan la revisión de código entre compañeros.</p>', 'Domina Git y GitHub para trabajar eficientemente en equipo', 1, 'published', NOW() - INTERVAL 5 DAY, 320),
('Optimización de rendimiento', 'optimizacion-rendimiento', '<h2>Mejorando la velocidad de tu sitio</h2><p>La optimización del rendimiento web incluye técnicas como minificación, lazy loading y caching.</p><p>Las Core Web Vitals son métricas importantes para SEO.</p>', 'Técnicas avanzadas para mejorar el rendimiento de tu sitio web', 4, 'published', NOW() - INTERVAL 3 DAY, 98),
('Sistemas de plantillas', 'sistemas-plantillas', '<h2>Twig, Blade y Smarty</h2><p>Los motores de plantillas ayudan a separar la lógica de la presentación.</p><p>La herencia de plantillas y los componentes son características clave.</p>', 'Comparativa de los mejores motores de plantillas para PHP', 3, 'draft', NULL, 0),
('Pruebas unitarias', 'pruebas-unitarias', '<h2>PHPUnit para testing</h2><p>Las pruebas automatizadas son esenciales para el desarrollo de software de calidad.</p><p>TDD (Test-Driven Development) es una metodología que pone las pruebas primero.</p>', 'Aprende a escribir tests unitarios para tu código PHP con PHPUnit', 2, 'published', NOW() - INTERVAL 1 DAY, 45),
('WebSockets en PHP', 'websockets-php', '<h2>Aplicaciones en tiempo real</h2><p>Ratchet y Swoole son opciones populares para implementar WebSockets en PHP.</p><p>Las aplicaciones de chat y notificaciones en tiempo real se benefician de esta tecnología.</p>', 'Implementa comunicación en tiempo real en tus aplicaciones PHP', 1, 'published', NOW(), 23),
('Clean Code', 'clean-code', '<h2>Escribiendo código limpio</h2><p>El código limpio es fácil de leer, entender y mantener.</p><p>Nombres descriptivos, funciones pequeñas y comentarios útiles son prácticas clave.</p>', 'Mejora la calidad de tu código con principios de Clean Code', 4, 'published', NOW(), 167);
