#!/bin/bash

# ============================================================
# INSTALADOR AUTOMÁTICO DEL BLOG MVC - PHP OOP
# Sigue exactamente las especificaciones del PDF
# ============================================================

set -e  # Detener si hay error

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🚀 INSTALADOR DEL BLOG MVC - PHP OOP${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"

# ============================================================
# 1. CREAR ESTRUCTURA DE DIRECTORIOS
# ============================================================
echo -e "\n${YELLOW}📁 Creando estructura de directorios...${NC}"

mkdir -p public/assets/{css,js,images}
mkdir -p src/{Controllers,Models,Views/{layouts,home,auth,posts,user},Core,Middleware,Services,Utils}
mkdir -p config
mkdir -p database/{migrations,seeders}
mkdir -p storage/{uploads,logs}
mkdir -p vendor

echo -e "${GREEN}✅ Estructura creada${NC}"

# ============================================================
# 2. CREAR COMPOSER.JSON CON AUTOLOADING PSR-4
# ============================================================
echo -e "\n${YELLOW}📦 Creando composer.json...${NC}"

cat > composer.json << 'JSON'
{
    "name": "blog/mvc",
    "description": "Blog MVC con PHP OOP - Proyecto completo",
    "type": "project",
    "require": {
        "php": ">=8.0"
    },
    "autoload": {
        "psr-4": {
            "Blog\\": "src/"
        }
    }
}
JSON

echo -e "${GREEN}✅ composer.json creado${NC}"

# ============================================================
# 3. CREAR ARCHIVO .HTACCESS PARA APACHE/REWRITE
# ============================================================
echo -e "\n${YELLOW}🌐 Configurando .htaccess...${NC}"

cat > public/.htaccess << 'HTACCESS'
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^ index.php [QSA,L]

# Headers de seguridad
Header set X-Frame-Options "DENY"
Header set X-XSS-Protection "1; mode=block"
Header set X-Content-Type-Options "nosniff"
HTACCESS

echo -e "${GREEN}✅ .htaccess creado${NC}"

# ============================================================
# 4. CREAR PUNTO DE ENTRADA INDEX.PHP
# ============================================================
echo -e "\n${YELLOW}🚪 Creando public/index.php...${NC}"

cat > public/index.php << 'INDEXPHP'
<?php
session_start();

require_once __DIR__ . '/../vendor/autoload.php';

use Blog\Core\Router;
use Blog\Core\Database;

// Cargar configuración
$config = require __DIR__ . '/../config/database.php';
$routesConfig = require __DIR__ . '/../config/routes.php';

// Configurar base de datos
Database::setConfig($config);

// Router
$router = new Router();

// Registrar rutas
foreach ($routesConfig as $route) {
    $router->add($route['method'], $route['path'], $route['controller'], $route['action'], $route['middleware'] ?? null);
}

// Despachar
$router->dispatch($_SERVER['REQUEST_METHOD'], $_SERVER['REQUEST_URI']);
INDEXPHP

echo -e "${GREEN}✅ index.php creado${NC}"

# ============================================================
# 5. CONFIGURACIÓN DE BASE DE DATOS (con usuario específico)
# ============================================================
echo -e "\n${YELLOW}🗄️  Configurando base de datos...${NC}"

# Verificar si MySQL está instalado
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}❌ MySQL no está instalado. Por favor, instálalo primero.${NC}"
    exit 1
fi

# Intentar crear un usuario específico para el proyecto
echo -e "${YELLOW}Creando usuario 'blog_user' para la aplicación...${NC}"

# Intentar con diferentes métodos de autenticación
MYSQL_CONNECTED=false

# Probar con sudo mysql (sin contraseña)
if sudo mysql -e "SELECT 1" 2>/dev/null; then
    echo -e "${GREEN}Conectado con sudo mysql${NC}"
    sudo mysql << 'SQL'
        CREATE USER IF NOT EXISTS 'blog_user'@'localhost' IDENTIFIED BY 'BlogMVC2024!';
        DROP DATABASE IF EXISTS blog_mvc;
        CREATE DATABASE blog_mvc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        GRANT ALL PRIVILEGES ON blog_mvc.* TO 'blog_user'@'localhost';
        FLUSH PRIVILEGES;
SQL
    MYSQL_CONNECTED=true
    DB_USER="blog_user"
    DB_PASS="BlogMVC2024!"
# Probar con mysql -u root (sin contraseña)
elif mysql -u root -e "SELECT 1" 2>/dev/null; then
    echo -e "${GREEN}Conectado con mysql -u root (sin contraseña)${NC}"
    mysql -u root << 'SQL'
        CREATE USER IF NOT EXISTS 'blog_user'@'localhost' IDENTIFIED BY 'BlogMVC2024!';
        DROP DATABASE IF EXISTS blog_mvc;
        CREATE DATABASE blog_mvc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        GRANT ALL PRIVILEGES ON blog_mvc.* TO 'blog_user'@'localhost';
        FLUSH PRIVILEGES;
SQL
    MYSQL_CONNECTED=true
    DB_USER="blog_user"
    DB_PASS="BlogMVC2024!"
# Probar con mysql -u root -proot
elif mysql -u root -proot -e "SELECT 1" 2>/dev/null; then
    echo -e "${GREEN}Conectado con mysql -u root -proot${NC}"
    mysql -u root -proot << 'SQL'
        CREATE USER IF NOT EXISTS 'blog_user'@'localhost' IDENTIFIED BY 'BlogMVC2024!';
        DROP DATABASE IF EXISTS blog_mvc;
        CREATE DATABASE blog_mvc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        GRANT ALL PRIVILEGES ON blog_mvc.* TO 'blog_user'@'localhost';
        FLUSH PRIVILEGES;
SQL
    MYSQL_CONNECTED=true
    DB_USER="blog_user"
    DB_PASS="BlogMVC2024!"
else
    echo -e "${YELLOW}No se pudo conectar automáticamente. Solicitando contraseña de root...${NC}"
    read -sp "Contraseña de root de MySQL: " MYSQL_ROOT_PASS
    echo
    if mysql -u root -p"$MYSQL_ROOT_PASS" -e "SELECT 1" 2>/dev/null; then
        mysql -u root -p"$MYSQL_ROOT_PASS" << SQL
            CREATE USER IF NOT EXISTS 'blog_user'@'localhost' IDENTIFIED BY 'BlogMVC2024!';
            DROP DATABASE IF EXISTS blog_mvc;
            CREATE DATABASE blog_mvc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
            GRANT ALL PRIVILEGES ON blog_mvc.* TO 'blog_user'@'localhost';
            FLUSH PRIVILEGES;
SQL
        MYSQL_CONNECTED=true
        DB_USER="blog_user"
        DB_PASS="BlogMVC2024!"
    else
        echo -e "${RED}❌ No se pudo conectar a MySQL. Verifica tus credenciales.${NC}"
        exit 1
    fi
fi

if [ "$MYSQL_CONNECTED" = true ]; then
    echo -e "${GREEN}✅ Base de datos 'blog_mvc' creada y usuario 'blog_user' configurado${NC}"
fi

# ============================================================
# 6. CREAR ARCHIVO DE CONFIGURACIÓN DATABASE.PHP
# ============================================================
echo -e "\n${YELLOW}⚙️  Creando config/database.php...${NC}"

cat > config/database.php << EOF
<?php
return [
    'host' => 'localhost',
    'port' => '3306',
    'database' => 'blog_mvc',
    'username' => '$DB_USER',
    'password' => '$DB_PASS',
    'charset' => 'utf8mb4',
    'options' => [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]
];
