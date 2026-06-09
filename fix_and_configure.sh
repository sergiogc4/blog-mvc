#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🔧 ARREGLANDO CONFIGURACIÓN DEL BLOG MVC${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

# 1. DETECTAR CONFIGURACIÓN DE MYSQL
echo -e "\n${YELLOW}📡 Detectando configuración de MySQL...${NC}"

# Probar diferentes métodos de conexión
MYSQL_CMD=""
MYSQL_PASS=""

# Prueba 1: sudo mysql (sin contraseña)
if sudo mysql -e "SELECT 1" 2>/dev/null; then
    echo -e "${GREEN}✅ Conexión detectada: sudo mysql${NC}"
    MYSQL_CMD="sudo mysql"
    MYSQL_USER="root"
    MYSQL_PASS=""
# Prueba 2: mysql -u root (sin contraseña)
elif mysql -u root -e "SELECT 1" 2>/dev/null; then
    echo -e "${GREEN}✅ Conexión detectada: mysql -u root (sin contraseña)${NC}"
    MYSQL_CMD="mysql -u root"
    MYSQL_USER="root"
    MYSQL_PASS=""
# Prueba 3: mysql -u root -proot
elif mysql -u root -proot -e "SELECT 1" 2>/dev/null; then
    echo -e "${GREEN}✅ Conexión detectada: mysql -u root -proot${NC}"
    MYSQL_CMD="mysql -u root -proot"
    MYSQL_USER="root"
    MYSQL_PASS="root"
# Prueba 4: mysql -u root -p123456
elif mysql -u root -p123456 -e "SELECT 1" 2>/dev/null; then
    echo -e "${GREEN}✅ Conexión detectada: mysql -u root -p123456${NC}"
    MYSQL_CMD="mysql -u root -p123456"
    MYSQL_USER="root"
    MYSQL_PASS="123456"
else
    echo -e "${RED}❌ No se pudo detectar conexión automática.${NC}"
    echo -e "${YELLOW}Creando usuario específico para la aplicación...${NC}"
    
    # Crear usuario específico
    sudo mysql << MYSQL_SCRIPT
    CREATE USER IF NOT EXISTS 'blog_mvc_user'@'localhost' IDENTIFIED BY 'BlogMVC2024!';
    GRANT ALL PRIVILEGES ON blog_mvc.* TO 'blog_mvc_user'@'localhost';
    FLUSH PRIVILEGES;
MYSQL_SCRIPT
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Usuario creado: blog_mvc_user / BlogMVC2024!${NC}"
        MYSQL_CMD="mysql -u blog_mvc_user -pBlogMVC2024!"
        MYSQL_USER="blog_mvc_user"
        MYSQL_PASS="BlogMVC2024!"
    else
        echo -e "${RED}❌ No se pudo configurar la base de datos.${NC}"
        echo -e "${YELLOW}Por favor, ejecuta manualmente: sudo mysql${NC}"
        exit 1
    fi
fi

# 2. RECONSTRUIR BASE DE DATOS
echo -e "\n${YELLOW}🗄️  Reconstruyendo base de datos...${NC}"

$MYSQL_CMD << MYSQL_SCRIPT
DROP DATABASE IF EXISTS blog_mvc;
CREATE DATABASE blog_mvc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE blog_mvc;
MYSQL_SCRIPT

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Base de datos creada correctamente${NC}"
else
    echo -e "${RED}❌ Error al crear la base de datos${NC}"
    exit 1
fi

# 3. IMPORTAR ESQUEMA Y DATOS
echo -e "\n${YELLOW}📥 Importando esquema y datos...${NC}"

$MYSQL_CMD blog_mvc << 'MYSQL_SCRIPT'
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

-- Insertar usuarios (password: User123! para todos, admin: Admin123!)
INSERT INTO users (name, email, password, bio) VALUES 
('Admin User', 'admin@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Administrador del blog'),
('John Doe', 'john@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Desarrollador web y entusiasta de la tecnología'),
('Jane Smith', 'jane@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Escritora y creadora de contenido'),
('Guest User', 'guest@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Usuario invitado'),
('Sergio Garcia', 'sergio@blog.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Desarrollador full-stack');

-- Insertar posts
INSERT INTO posts (title, slug, content, excerpt, author_id, status, published_at, views_count) VALUES
('Introducción a PHP 8', 'introduccion-php-8', '<h2>PHP 8 llega con muchas novedades</h2><p>PHP 8 es una de las versiones más importantes en años, trayendo características como JIT, atributos, union types, match expression y mucho más.</p><p>El compilador JIT (Just In Time) puede mejorar significativamente el rendimiento en ciertos escenarios. Los atributos permiten añadir metadatos a las clases sin necesidad de docblocks.</p>', 'Descubre todas las novedades de PHP 8, la última versión del popular lenguaje de programación', 2, 'published', DATE_SUB(NOW(), INTERVAL 30 DAY), 150),
('Arquitectura MVC con PHP', 'mvc-con-php', '<h2>¿Qué es MVC?</h2><p>MVC (Model-View-Controller) es un patrón de arquitectura que separa la aplicación en tres componentes principales.</p><p>El Modelo maneja los datos y la lógica de negocio, la Vista presenta la interfaz de usuario y el Controlador maneja las peticiones del usuario.</p>', 'Aprende a implementar el patrón MVC en tus aplicaciones PHP de forma profesional', 1, 'published', DATE_SUB(NOW(), INTERVAL 25 DAY), 89),
('Bootstrap 5 Tutorial', 'bootstrap-5-tutorial', '<h2>Bootstrap 5: La última versión</h2><p>Bootstrap 5 trae cambios importantes como la eliminación de jQuery, nuevos componentes y utilidades CSS.</p><p>El sistema de grid sigue siendo potente y ahora incluye soporte para CSS Grid Layout.</p>', 'Guía completa de Bootstrap 5 para crear interfaces responsive modernas', 3, 'published', DATE_SUB(NOW(), INTERVAL 20 DAY), 210),
('Base de datos optimizada', 'bd-optimizada', '<h2>Consejos para optimizar tu base de datos</h2><p>La optimización de consultas SQL es fundamental para el rendimiento de tu aplicación.</p><p>Los índices bien diseñados pueden acelerar las consultas drásticamente.</p>', 'Mejora el rendimiento de tu aplicación con estas técnicas de optimización de BD', 2, 'published', DATE_SUB(NOW(), INTERVAL 18 DAY), 67),
('Seguridad en aplicaciones web', 'seguridad-web', '<h2>Las 5 vulnerabilidades más comunes</h2><p>SQL Injection, XSS, CSRF son algunas de las amenazas más frecuentes en aplicaciones web.</p><p>Implementar medidas de seguridad como prepared statements y CSRF tokens es esencial.</p>', 'Protege tu aplicación web contra las vulnerabilidades más comunes', 4, 'published', DATE_SUB(NOW(), INTERVAL 15 DAY), 312),
('Programación orientada a objetos', 'poo-php', '<h2>Principios SOLID</h2><p>La programación orientada a objetos permite crear código más mantenible y reutilizable.</p><p>Los principios SOLID son fundamentales para un buen diseño OOP.</p>', 'Domina la POO en PHP con ejemplos prácticos y principios SOLID', 1, 'published', DATE_SUB(NOW(), INTERVAL 12 DAY), 178),
('Desarrollo con Docker', 'docker-desarrollo', '<h2>Docker para entornos de desarrollo</h2><p>Docker permite crear entornos de desarrollo reproducibles y aislados.</p><p>Con Docker Compose puedes definir aplicaciones multi-contenedor fácilmente.</p>', 'Aprende a usar Docker para tus proyectos PHP y MySQL', 2, 'draft', NULL, 0),
('JavaScript moderno', 'js-moderno', '<h2>ES6 y más allá</h2><p>JavaScript ha evolucionado muchísimo con características como arrow functions, destructuring, spread operator y async/await.</p><p>TypeScript añade tipado estático al ecosistema JavaScript.</p>', 'Actualiza tus conocimientos de JavaScript con las últimas características', 3, 'published', DATE_SUB(NOW(), INTERVAL 10 DAY), 245),
('APIs RESTful con PHP', 'api-rest-php', '<h2>Diseñando APIs REST</h2><p>Las APIs RESTful siguen principios arquitectónicos que las hacen escalables y mantenibles.</p><p>Los códigos de estado HTTP y los métodos REST son fundamentales.</p>', 'Guía para construir APIs RESTful profesionales con PHP', 2, 'published', DATE_SUB(NOW(), INTERVAL 8 DAY), 156),
('Git y GitHub para equipos', 'git-github', '<h2>Flujos de trabajo colaborativos</h2><p>Git Flow y GitHub Flow son estrategias populares para manejar el control de versiones en equipo.</p><p>Las pull requests facilitan la revisión de código entre compañeros.</p>', 'Domina Git y GitHub para trabajar eficientemente en equipo', 1, 'published', DATE_SUB(NOW(), INTERVAL 5 DAY), 320),
('Optimización de rendimiento', 'optimizacion-rendimiento', '<h2>Mejorando la velocidad de tu sitio</h2><p>La optimización del rendimiento web incluye técnicas como minificación, lazy loading y caching.</p><p>Las Core Web Vitals son métricas importantes para SEO.</p>', 'Técnicas avanzadas para mejorar el rendimiento de tu sitio web', 4, 'published', DATE_SUB(NOW(), INTERVAL 3 DAY), 98),
('Sistemas de plantillas', 'sistemas-plantillas', '<h2>Twig, Blade y Smarty</h2><p>Los motores de plantillas ayudan a separar la lógica de la presentación.</p><p>La herencia de plantillas y los componentes son características clave.</p>', 'Comparativa de los mejores motores de plantillas para PHP', 3, 'draft', NULL, 0),
('Pruebas unitarias', 'pruebas-unitarias', '<h2>PHPUnit para testing</h2><p>Las pruebas automatizadas son esenciales para el desarrollo de software de calidad.</p><p>TDD (Test-Driven Development) es una metodología que pone las pruebas primero.</p>', 'Aprende a escribir tests unitarios para tu código PHP con PHPUnit', 2, 'published', DATE_SUB(NOW(), INTERVAL 1 DAY), 45),
('WebSockets en PHP', 'websockets-php', '<h2>Aplicaciones en tiempo real</h2><p>Ratchet y Swoole son opciones populares para implementar WebSockets en PHP.</p><p>Las aplicaciones de chat y notificaciones en tiempo real se benefician de esta tecnología.</p>', 'Implementa comunicación en tiempo real en tus aplicaciones PHP', 1, 'published', NOW(), 23),
('Clean Code', 'clean-code', '<h2>Escribiendo código limpio</h2><p>El código limpio es fácil de leer, entender y mantener.</p><p>Nombres descriptivos, funciones pequeñas y comentarios útiles son prácticas clave.</p>', 'Mejora la calidad de tu código con principios de Clean Code', 4, 'published', NOW(), 167);

SELECT '✅ Datos importados correctamente' as status;
MYSQL_SCRIPT

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Datos importados correctamente${NC}"
else
    echo -e "${RED}❌ Error al importar datos${NC}"
    exit 1
fi

# 4. ACTUALIZAR CONFIGURACIÓN DE PHP
echo -e "\n${YELLOW}⚙️  Configurando archivo database.php...${NC}"

cat > ~/blog-mvc/config/database.php << EOF
<?php
return [
    'host' => 'localhost',
    'port' => '3306',
    'database' => 'blog_mvc',
    'username' => '$MYSQL_USER',
    'password' => '$MYSQL_PASS',
    'charset' => 'utf8mb4',
    'options' => [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]
];
EOF

echo -e "${GREEN}✅ Configuración guardada en config/database.php${NC}"

# 5. CREAR SCRIPT DE PRUEBA
echo -e "\n${YELLOW}🧪 Creando script de prueba...${NC}"

cat > ~/blog-mvc/test_connection.php << 'EOF'
<?php
echo "════════════════════════════════════════════════════════════\n";
echo "🧪 TEST DE CONEXIÓN A LA BASE DE DATOS\n";
echo "════════════════════════════════════════════════════════════\n\n";

$config = require 'config/database.php';

try {
    $dsn = "mysql:host={$config['host']};port={$config['port']};dbname={$config['database']};charset={$config['charset']}";
    $pdo = new PDO($dsn, $config['username'], $config['password'], $config['options']);
    
    echo "✅ Conexión exitosa a la base de datos!\n\n";
    
    // Probar consulta
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM users");
    $users = $stmt->fetch();
    echo "📊 Usuarios en la base de datos: " . $users['total'] . "\n";
    
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM posts");
    $posts = $stmt->fetch();
    echo "📝 Posts en la base de datos: " . $posts['total'] . "\n\n";
    
    echo "✅ Todo funciona correctamente!\n";
    
} catch (PDOException $e) {
    echo "❌ Error de conexión: " . $e->getMessage() . "\n";
    exit(1);
}
EOF

echo -e "${GREEN}✅ Script de prueba creado${NC}"

# 6. GENERAR AUTOLOAD
echo -e "\n${YELLOW}📦 Generando autoload de Composer...${NC}"
cd ~/blog-mvc
composer dump-autoload 2>/dev/null || php composer.phar dump-autoload 2>/dev/null
echo -e "${GREEN}✅ Autoload generado${NC}"

# 7. CREAR DIRECTORIO DE UPLOADS Y DAR PERMISOS
echo -e "\n${YELLOW}🔐 Configurando permisos...${NC}"
mkdir -p ~/blog-mvc/storage/uploads
chmod -R 755 ~/blog-mvc/storage/
echo -e "${GREEN}✅ Permisos configurados${NC}"

# 8. MOSTRAR RESULTADOS
echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ CONFIGURACIÓN COMPLETADA CON ÉXITO!${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

echo -e "\n${YELLOW}📋 Credenciales de la base de datos:${NC}"
echo -e "   Usuario: ${GREEN}$MYSQL_USER${NC}"
echo -e "   Contraseña: ${GREEN}$MYSQL_PASS${NC}"
echo -e "   Base de datos: ${GREEN}blog_mvc${NC}"

echo -e "\n${YELLOW}👤 Usuarios de prueba:${NC}"
echo -e "   ┌─────────────────────────────────────────────┐"
echo -e "   │ Email                      │ Contraseña     │"
echo -e "   ├─────────────────────────────────────────────┤"
echo -e "   │ admin@blog.com             │ Admin123!      │"
echo -e "   │ john@blog.com              │ User123!       │"
echo -e "   │ jane@blog.com              │ User123!       │"
echo -e "   │ sergio@blog.com            │ User123!       │"
echo -e "   │ guest@blog.com             │ User123!       │"
echo -e "   └─────────────────────────────────────────────┘"

echo -e "\n${YELLOW}🚀 Para iniciar el servidor:${NC}"
echo -e "   ${GREEN}cd ~/blog-mvc && php -S localhost:8000 -t public${NC}"
echo -e "\n${YELLOW}🌐 Abre en tu navegador:${NC}"
echo -e "   ${GREEN}http://localhost:8000${NC}"

echo -e "\n${YELLOW}🧪 Probar conexión a la base de datos:${NC}"
echo -e "   ${GREEN}php ~/blog-mvc/test_connection.php${NC}"

echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"

# 9. PREGUNTAR SI QUIERE INICIAR EL SERVIDOR
echo -e "\n${YELLOW}¿Quieres iniciar el servidor ahora? (s/n)${NC}"
read -r respuesta
if [[ "$respuesta" == "s" || "$respuesta" == "S" || "$respuesta" == "si" || "$respuesta" == "SI" ]]; then
    echo -e "\n${GREEN}🚀 Iniciando servidor...${NC}"
    echo -e "${YELLOW}Presiona Ctrl+C para detener el servidor${NC}\n"
    cd ~/blog-mvc
    php -S localhost:8000 -t public
else
    echo -e "\n${GREEN}Puedes iniciar el servidor manualmente con:${NC}"
    echo -e "cd ~/blog-mvc && php -S localhost:8000 -t public"
fi
