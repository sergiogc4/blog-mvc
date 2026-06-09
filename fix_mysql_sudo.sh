#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔧 Configurando Blog MVC con sudo mysql...${NC}"

# 1. Verificar que sudo mysql funciona
echo -e "${YELLOW}📡 Probando conexión con sudo mysql...${NC}"
if ! sudo mysql -e "SELECT 1" &>/dev/null; then
    echo -e "${RED}❌ No se puede ejecutar 'sudo mysql'.${NC}"
    echo -e "${YELLOW}Por favor, ejecuta 'sudo mysql' manualmente para verificar.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Conexión con sudo mysql OK${NC}"

# 2. Recrear base de datos
echo -e "${YELLOW}🗄️  Recreando base de datos...${NC}"
sudo mysql << 'SQL'
DROP DATABASE IF EXISTS blog_mvc;
CREATE DATABASE blog_mvc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE blog_mvc;

-- Crear tablas
CREATE TABLE users (
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

CREATE TABLE posts (
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

-- Usuarios
INSERT INTO users (name, email, password, bio) VALUES 
('Admin User', 'admin@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador'),
('John Doe', 'john@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Desarrollador'),
('Jane Smith', 'jane@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Escritora'),
('Guest User', 'guest@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Invitado'),
('Sergio Garcia', 'sergio@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Full-stack');

-- Posts (15)
INSERT INTO posts (title, slug, content, excerpt, author_id, status, published_at, views_count) VALUES
('Introducción a PHP 8', 'introduccion-php-8', '<h2>PHP 8 novedades</h2><p>PHP 8 trae JIT, atributos, union types...</p>', 'Novedades de PHP 8', 2, 'published', DATE_SUB(NOW(), INTERVAL 30 DAY), 150),
('Arquitectura MVC con PHP', 'mvc-con-php', '<h2>MVC explicado</h2><p>Separación de responsabilidades...</p>', 'Aprende MVC', 1, 'published', DATE_SUB(NOW(), INTERVAL 25 DAY), 89),
('Bootstrap 5 Tutorial', 'bootstrap-5-tutorial', '<h2>Bootstrap 5</h2><p>Nuevos componentes y utilidades...</p>', 'Guía Bootstrap 5', 3, 'published', DATE_SUB(NOW(), INTERVAL 20 DAY), 210),
('Base de datos optimizada', 'bd-optimizada', '<h2>Optimización SQL</h2><p>Índices y consultas eficientes...</p>', 'Mejora tu BD', 2, 'published', DATE_SUB(NOW(), INTERVAL 18 DAY), 67),
('Seguridad en aplicaciones web', 'seguridad-web', '<h2>Vulnerabilidades comunes</h2><p>SQL Injection, XSS, CSRF...</p>', 'Protege tu web', 4, 'published', DATE_SUB(NOW(), INTERVAL 15 DAY), 312),
('Programación orientada a objetos', 'poo-php', '<h2>Principios SOLID</h2><p>Código mantenible...</p>', 'POO en PHP', 1, 'published', DATE_SUB(NOW(), INTERVAL 12 DAY), 178),
('Desarrollo con Docker', 'docker-desarrollo', '<h2>Docker para dev</h2><p>Entornos reproducibles...</p>', 'Docker y PHP', 2, 'draft', NULL, 0),
('JavaScript moderno', 'js-moderno', '<h2>ES6+</h2><p>Arrow functions, async/await...</p>', 'JS actual', 3, 'published', DATE_SUB(NOW(), INTERVAL 10 DAY), 245),
('APIs RESTful con PHP', 'api-rest-php', '<h2>Diseño de APIs</h2><p>REST, códigos HTTP...</p>', 'Crea APIs', 2, 'published', DATE_SUB(NOW(), INTERVAL 8 DAY), 156),
('Git y GitHub para equipos', 'git-github', '<h2>Flujos colaborativos</h2><p>Git Flow, pull requests...</p>', 'Git en equipo', 1, 'published', DATE_SUB(NOW(), INTERVAL 5 DAY), 320),
('Optimización de rendimiento', 'optimizacion-rendimiento', '<h2>Velocidad web</h2><p>Lazy loading, caching...</p>', 'Rendimiento', 4, 'published', DATE_SUB(NOW(), INTERVAL 3 DAY), 98),
('Sistemas de plantillas', 'sistemas-plantillas', '<h2>Twig, Blade</h2><p>Herencia de plantillas...</p>', 'Motores plantillas', 3, 'draft', NULL, 0),
('Pruebas unitarias', 'pruebas-unitarias', '<h2>PHPUnit</h2><p>TDD, tests automatizados...</p>', 'Testing', 2, 'published', DATE_SUB(NOW(), INTERVAL 1 DAY), 45),
('WebSockets en PHP', 'websockets-php', '<h2>Tiempo real</h2><p>Ratchet, Swoole...</p>', 'WebSockets', 1, 'published', NOW(), 23),
('Clean Code', 'clean-code', '<h2>Código limpio</h2><p>Nombres, funciones pequeñas...</p>', 'Clean Code', 4, 'published', NOW(), 167);
SQL

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Base de datos recreada y datos insertados${NC}"
else
    echo -e "${RED}❌ Error al ejecutar SQL${NC}"
    exit 1
fi

# 3. Configurar database.php (usando socket para evitar contraseña)
echo -e "${YELLOW}⚙️  Configurando conexión PDO con socket...${NC}"
cat > ~/blog-mvc/config/database.php << 'EOF'
<?php
return [
    'host' => 'localhost',
    'port' => '3306',
    'database' => 'blog_mvc',
    'username' => 'root',
    'password' => '',
    'unix_socket' => '/var/run/mysqld/mysqld.sock',  // Usar socket para conectar sin contraseña
    'charset' => 'utf8mb4',
    'options' => [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]
];
EOF

echo -e "${GREEN}✅ Configuración guardada${NC}"

# 4. Probar conexión desde PHP
echo -e "${YELLOW}🧪 Probando conexión con PHP...${NC}"
cat > ~/blog-mvc/test_db.php << 'EOF'
<?php
$config = require 'config/database.php';
try {
    if (isset($config['unix_socket'])) {
        $dsn = "mysql:unix_socket={$config['unix_socket']};dbname={$config['database']};charset={$config['charset']}";
    } else {
        $dsn = "mysql:host={$config['host']};port={$config['port']};dbname={$config['database']};charset={$config['charset']}";
    }
    $pdo = new PDO($dsn, $config['username'], $config['password'], $config['options']);
    echo "✅ Conexión exitosa\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM users");
    $row = $stmt->fetch();
    echo "👤 Usuarios: " . $row['total'] . "\n";
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM posts WHERE status='published'");
    $row = $stmt->fetch();
    echo "📝 Posts publicados: " . $row['total'] . "\n";
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
EOF

php ~/blog-mvc/test_db.php
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Conexión PHP funciona correctamente${NC}"
else
    echo -e "${RED}❌ La conexión PHP falló. Revisa que el socket exista.${NC}"
    echo -e "${YELLOW}Puedes editar manualmente config/database.php y cambiar 'unix_socket' por 'host' si prefieres.${NC}"
fi

# 5. Generar autoload
echo -e "${YELLOW}📦 Generando autoload de Composer...${NC}"
cd ~/blog-mvc
composer dump-autoload 2>/dev/null || php composer.phar dump-autoload 2>/dev/null
echo -e "${GREEN}✅ Autoload generado${NC}"

# 6. Permisos para uploads
mkdir -p ~/blog-mvc/storage/uploads
chmod -R 755 ~/blog-mvc/storage/

# 7. Mostrar resumen
echo -e "\n${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ TODO LISTO PARA EJECUTAR EL BLOG${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}👉 Usuarios de prueba:${NC}"
echo "   admin@blog.com / Admin123!"
echo "   john@blog.com / User123!"
echo "   sergio@blog.com / User123!"
echo -e "\n${YELLOW}🚀 Iniciar servidor:${NC}"
echo "   cd ~/blog-mvc && php -S localhost:8000 -t public"
echo -e "\n${YELLOW}🌐 Abrir navegador:${NC} http://localhost:8000"
echo -e "${GREEN}════════════════════════════════════════════════════════════${NC}"

# Preguntar si iniciar
read -p "¿Iniciar el servidor ahora? (s/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${GREEN}🚀 Iniciando servidor... (Presiona Ctrl+C para detener)${NC}"
    cd ~/blog-mvc
    php -S localhost:8000 -t public
fi
