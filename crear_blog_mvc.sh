#!/bin/bash

echo "🚀 Creando proyecto Blog MVC con PHP OOP..."

# Crear estructura de directorios
mkdir -p blog-mvc/public/assets/{css,js,images}
mkdir -p blog-mvc/src/{Controllers,Models,Views/{layouts,home,auth,posts,user},Core,Middleware,Services,Utils}
mkdir -p blog-mvc/config
mkdir -p blog-mvc/database/{migrations,seeders}
mkdir -p blog-mvc/storage/{uploads,logs}

cd blog-mvc

# Crear composer.json
cat > composer.json << 'EOF'
{
    "name": "blog/mvc",
    "description": "Blog MVC con PHP OOP",
    "type": "project",
    "require": {},
    "autoload": {
        "psr-4": {
            "Blog\\": "src/"
        }
    }
}
EOF

# Crear .htaccess
cat > public/.htaccess << 'EOF'
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^ index.php [QSA,L]

# Seguridad headers
Header set X-Frame-Options "DENY"
Header set X-XSS-Protection "1; mode=block"
Header set X-Content-Type-Options "nosniff"
EOF

# Crear index.php
cat > public/index.php << 'EOF'
<?php
session_start();

require_once __DIR__ . '/../vendor/autoload.php';

use Blog\Core\Router;
use Blog\Core\Database;

// Cargar configuración
$config = require __DIR__ . '/../config/database.php';
$routesConfig = require __DIR__ . '/../config/routes.php';

// Establecer conexión DB
Database::setConfig($config);

// Router
$router = new Router();

// Registrar rutas
foreach ($routesConfig as $route) {
    $router->add($route['method'], $route['path'], $route['controller'], $route['action'], $route['middleware'] ?? null);
}

// Procesar la solicitud
$router->dispatch($_SERVER['REQUEST_METHOD'], $_SERVER['REQUEST_URI']);
EOF

# Crear config/database.php
cat > config/database.php << 'EOF'
<?php
return [
    'host' => 'localhost',
    'port' => '3306',
    'database' => 'blog_mvc',
    'username' => 'root',
    'password' => '',
    'charset' => 'utf8mb4',
    'options' => [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false
    ]
];
EOF

# Crear config/routes.php
cat > config/routes.php << 'EOF'
<?php
return [
    // Rutas públicas
    ['method' => 'GET', 'path' => '/', 'controller' => 'HomeController', 'action' => 'index'],
    ['method' => 'GET', 'path' => '/posts', 'controller' => 'PostController', 'action' => 'index'],
    ['method' => 'GET', 'path' => '/posts/{slug}', 'controller' => 'PostController', 'action' => 'show'],
    ['method' => 'GET', 'path' => '/author/{id}', 'controller' => 'PostController', 'action' => 'byAuthor'],
    ['method' => 'GET', 'path' => '/search', 'controller' => 'HomeController', 'action' => 'search'],
    
    // Rutas de autenticación
    ['method' => 'GET', 'path' => '/login', 'controller' => 'AuthController', 'action' => 'showLogin', 'middleware' => 'guest'],
    ['method' => 'POST', 'path' => '/login', 'controller' => 'AuthController', 'action' => 'login', 'middleware' => 'guest'],
    ['method' => 'GET', 'path' => '/register', 'controller' => 'AuthController', 'action' => 'showRegister', 'middleware' => 'guest'],
    ['method' => 'POST', 'path' => '/register', 'controller' => 'AuthController', 'action' => 'register', 'middleware' => 'guest'],
    ['method' => 'POST', 'path' => '/logout', 'controller' => 'AuthController', 'action' => 'logout', 'middleware' => 'auth'],
    
    // Rutas de gestión de posts (protegidas)
    ['method' => 'GET', 'path' => '/my-posts', 'controller' => 'PostController', 'action' => 'myPosts', 'middleware' => 'auth'],
    ['method' => 'GET', 'path' => '/my-posts/create', 'controller' => 'PostController', 'action' => 'create', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/my-posts', 'controller' => 'PostController', 'action' => 'store', 'middleware' => 'auth'],
    ['method' => 'GET', 'path' => '/my-posts/{id}/edit', 'controller' => 'PostController', 'action' => 'edit', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/my-posts/{id}/update', 'controller' => 'PostController', 'action' => 'update', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/my-posts/{id}/delete', 'controller' => 'PostController', 'action' => 'delete', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/my-posts/{id}/publish', 'controller' => 'PostController', 'action' => 'publish', 'middleware' => 'auth'],
    
    // Rutas de perfil
    ['method' => 'GET', 'path' => '/profile', 'controller' => 'UserController', 'action' => 'profile', 'middleware' => 'auth'],
    ['method' => 'GET', 'path' => '/profile/edit', 'controller' => 'UserController', 'action' => 'editProfile', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/profile/update', 'controller' => 'UserController', 'action' => 'updateProfile', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/profile/avatar', 'controller' => 'UserController', 'action' => 'uploadAvatar', 'middleware' => 'auth'],
];
EOF

# Crear Core/Router.php
cat > src/Core/Router.php << 'EOF'
<?php
namespace Blog\Core;

class Router
{
    private array $routes = [];
    private array $params = [];

    public function add(string $method, string $path, string $controller, string $action, ?string $middleware = null): void
    {
        $path = preg_replace('/\{([a-z]+)\}/', '(?P<$1>[^/]+)', $path);
        $path = '#^' . $path . '$#';
        
        $this->routes[] = [
            'method' => $method,
            'pattern' => $path,
            'controller' => $controller,
            'action' => $action,
            'middleware' => $middleware
        ];
    }

    public function dispatch(string $method, string $uri): void
    {
        $uri = parse_url($uri, PHP_URL_PATH);
        
        foreach ($this->routes as $route) {
            if ($route['method'] !== $method) continue;
            
            if (preg_match($route['pattern'], $uri, $matches)) {
                $this->params = array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);
                
                // Verificar middleware
                if ($route['middleware']) {
                    $middlewareClass = "Blog\\Middleware\\" . ucfirst($route['middleware']) . "Middleware";
                    if (class_exists($middlewareClass)) {
                        $middleware = new $middlewareClass();
                        if (!$middleware->handle()) {
                            return;
                        }
                    }
                }
                
                $controllerClass = "Blog\\Controllers\\" . $route['controller'];
                if (class_exists($controllerClass)) {
                    $controller = new $controllerClass();
                    if (method_exists($controller, $route['action'])) {
                        call_user_func_array([$controller, $route['action']], $this->params);
                        return;
                    }
                }
            }
        }
        
        http_response_code(404);
        echo "<h1>404 - Página no encontrada</h1>";
    }
}
EOF

# Crear Core/Database.php
cat > src/Core/Database.php << 'EOF'
<?php
namespace Blog\Core;

use PDO;
use PDOException;

class Database
{
    private static ?PDO $connection = null;
    private static array $config = [];

    public static function setConfig(array $config): void
    {
        self::$config = $config;
    }

    public static function getConnection(): PDO
    {
        if (self::$connection === null) {
            try {
                $dsn = sprintf(
                    'mysql:host=%s;port=%s;dbname=%s;charset=%s',
                    self::$config['host'],
                    self::$config['port'],
                    self::$config['database'],
                    self::$config['charset']
                );
                
                self::$connection = new PDO($dsn, self::$config['username'], self::$config['password'], self::$config['options']);
            } catch (PDOException $e) {
                die('Error de conexión a la base de datos: ' . $e->getMessage());
            }
        }
        return self::$connection;
    }
}
EOF

# Crear Core/Controller.php
cat > src/Core/Controller.php << 'EOF'
<?php
namespace Blog\Core;

use Blog\Utils\Session;
use Blog\Utils\Flash;

class Controller
{
    protected function render(string $view, array $data = []): void
    {
        extract($data);
        $viewPath = __DIR__ . "/../Views/{$view}.php";
        
        if (file_exists($viewPath)) {
            require_once __DIR__ . "/../Views/layouts/app.php";
        } else {
            die("Vista no encontrada: {$view}");
        }
    }
    
    protected function renderAuth(string $view, array $data = []): void
    {
        extract($data);
        $viewPath = __DIR__ . "/../Views/{$view}.php";
        
        if (file_exists($viewPath)) {
            require_once __DIR__ . "/../Views/layouts/auth.php";
        } else {
            die("Vista no encontrada: {$view}");
        }
    }
    
    protected function redirect(string $url): void
    {
        header("Location: {$url}");
        exit;
    }
    
    protected function json(array $data, int $status = 200): void
    {
        http_response_code($status);
        header('Content-Type: application/json');
        echo json_encode($data);
        exit;
    }
    
    protected function isAuthenticated(): bool
    {
        return Session::has('user_id');
    }
    
    protected function getCurrentUser(): ?array
    {
        return Session::get('user');
    }
    
    protected function generateCsrfToken(): string
    {
        $token = bin2hex(random_bytes(32));
        Session::set('csrf_token', $token);
        return $token;
    }
    
    protected function verifyCsrfToken(?string $token): bool
    {
        if (!$token || $token !== Session::get('csrf_token')) {
            Flash::error('Token CSRF inválido');
            return false;
        }
        return true;
    }
}
EOF

# Crear Core/Model.php
cat > src/Core/Model.php << 'EOF'
<?php
namespace Blog\Core;

use PDO;

abstract class Model
{
    protected static string $table;
    protected static string $primaryKey = 'id';
    
    public static function all(): array
    {
        $db = Database::getConnection();
        $stmt = $db->query("SELECT * FROM " . static::$table . " ORDER BY created_at DESC");
        return $stmt->fetchAll();
    }
    
    public static function find(int $id): ?array
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT * FROM " . static::$table . " WHERE " . static::$primaryKey . " = :id");
        $stmt->execute(['id' => $id]);
        return $stmt->fetch() ?: null;
    }
    
    public static function where(string $column, $value): array
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT * FROM " . static::$table . " WHERE {$column} = :value");
        $stmt->execute(['value' => $value]);
        return $stmt->fetchAll();
    }
    
    public static function whereFirst(string $column, $value): ?array
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT * FROM " . static::$table . " WHERE {$column} = :value LIMIT 1");
        $stmt->execute(['value' => $value]);
        return $stmt->fetch() ?: null;
    }
    
    public static function create(array $data): int
    {
        $db = Database::getConnection();
        $columns = implode(', ', array_keys($data));
        $placeholders = ':' . implode(', :', array_keys($data));
        
        $stmt = $db->prepare("INSERT INTO " . static::$table . " ({$columns}) VALUES ({$placeholders})");
        $stmt->execute($data);
        return (int)$db->lastInsertId();
    }
    
    public static function update(int $id, array $data): bool
    {
        $db = Database::getConnection();
        $set = [];
        foreach (array_keys($data) as $column) {
            $set[] = "{$column} = :{$column}";
        }
        $set = implode(', ', $set);
        $data['id'] = $id;
        
        $stmt = $db->prepare("UPDATE " . static::$table . " SET {$set} WHERE " . static::$primaryKey . " = :id");
        return $stmt->execute($data);
    }
    
    public static function delete(int $id): bool
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("DELETE FROM " . static::$table . " WHERE " . static::$primaryKey . " = :id");
        return $stmt->execute(['id' => $id]);
    }
    
    public static function paginate(int $page = 1, int $perPage = 10, string $where = '', array $params = []): array
    {
        $db = Database::getConnection();
        $offset = ($page - 1) * $perPage;
        
        $whereClause = $where ? "WHERE {$where}" : "";
        
        $stmt = $db->prepare("SELECT * FROM " . static::$table . " {$whereClause} ORDER BY created_at DESC LIMIT :limit OFFSET :offset");
        foreach ($params as $key => $value) {
            $stmt->bindValue(":{$key}", $value);
        }
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $items = $stmt->fetchAll();
        
        $countStmt = $db->query("SELECT COUNT(*) as total FROM " . static::$table . " {$whereClause}");
        if ($params) {
            foreach ($params as $key => $value) {
                $countStmt->bindValue(":{$key}", $value);
            }
        }
        $countStmt->execute();
        $total = $countStmt->fetch()['total'];
        
        return [
            'items' => $items,
            'current_page' => $page,
            'per_page' => $perPage,
            'total' => $total,
            'last_page' => ceil($total / $perPage)
        ];
    }
}
EOF

# Crear Middlewares
mkdir -p src/Middleware

cat > src/Middleware/AuthMiddleware.php << 'EOF'
<?php
namespace Blog\Middleware;

use Blog\Utils\Session;
use Blog\Utils\Flash;

class AuthMiddleware
{
    public function handle(): bool
    {
        if (!Session::has('user_id')) {
            Flash::error('Has d\'iniciar sessió per accedir a aquesta pàgina');
            header('Location: /login');
            return false;
        }
        return true;
    }
}
EOF

cat > src/Middleware/GuestMiddleware.php << 'EOF'
<?php
namespace Blog\Middleware;

use Blog\Utils\Session;

class GuestMiddleware
{
    public function handle(): bool
    {
        if (Session::has('user_id')) {
            header('Location: /');
            return false;
        }
        return true;
    }
}
EOF

# Crear Models
mkdir -p src/Models

cat > src/Models/User.php << 'EOF'
<?php
namespace Blog\Models;

use Blog\Core\Model;
use Blog\Core\Database;
use PDO;

class User extends Model
{
    protected static string $table = 'users';
    
    public static function findByEmail(string $email): ?array
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT * FROM users WHERE email = :email");
        $stmt->execute(['email' => $email]);
        return $stmt->fetch() ?: null;
    }
    
    public static function getUserStats(int $userId): array
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("
            SELECT 
                COUNT(*) as total_posts,
                SUM(views_count) as total_views
            FROM posts 
            WHERE author_id = :user_id AND status = 'published'
        ");
        $stmt->execute(['user_id' => $userId]);
        return $stmt->fetch();
    }
    
    public static function updateLastLogin(int $userId): void
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("UPDATE users SET last_login_at = NOW() WHERE id = :id");
        $stmt->execute(['id' => $userId]);
    }
}
EOF

cat > src/Models/Post.php << 'EOF'
<?php
namespace Blog\Models;

use Blog\Core\Model;
use Blog\Core\Database;
use PDO;

class Post extends Model
{
    protected static string $table = 'posts';
    
    public static function getPublished(int $page = 1, int $perPage = 10): array
    {
        $db = Database::getConnection();
        $offset = ($page - 1) * $perPage;
        
        $stmt = $db->prepare("
            SELECT p.*, u.name as author_name, u.email as author_email, u.avatar as author_avatar
            FROM posts p
            JOIN users u ON p.author_id = u.id
            WHERE p.status = 'published'
            ORDER BY p.published_at DESC
            LIMIT :limit OFFSET :offset
        ");
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $items = $stmt->fetchAll();
        
        $countStmt = $db->query("SELECT COUNT(*) as total FROM posts WHERE status = 'published'");
        $total = $countStmt->fetch()['total'];
        
        return [
            'items' => $items,
            'current_page' => $page,
            'per_page' => $perPage,
            'total' => $total,
            'last_page' => ceil($total / $perPage)
        ];
    }
    
    public static function findBySlug(string $slug): ?array
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("
            SELECT p.*, u.name as author_name, u.email as author_email, u.avatar as author_avatar, u.bio as author_bio
            FROM posts p
            JOIN users u ON p.author_id = u.id
            WHERE p.slug = :slug AND p.status = 'published'
        ");
        $stmt->execute(['slug' => $slug]);
        return $stmt->fetch() ?: null;
    }
    
    public static function getByAuthor(int $authorId, int $page = 1, int $perPage = 10): array
    {
        $db = Database::getConnection();
        $offset = ($page - 1) * $perPage;
        
        $stmt = $db->prepare("
            SELECT p.*, u.name as author_name
            FROM posts p
            JOIN users u ON p.author_id = u.id
            WHERE p.author_id = :author_id AND p.status = 'published'
            ORDER BY p.published_at DESC
            LIMIT :limit OFFSET :offset
        ");
        $stmt->bindValue(':author_id', $authorId, PDO::PARAM_INT);
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $items = $stmt->fetchAll();
        
        $countStmt = $db->prepare("SELECT COUNT(*) as total FROM posts WHERE author_id = :author_id AND status = 'published'");
        $countStmt->execute(['author_id' => $authorId]);
        $total = $countStmt->fetch()['total'];
        
        return [
            'items' => $items,
            'current_page' => $page,
            'per_page' => $perPage,
            'total' => $total,
            'last_page' => ceil($total / $perPage)
        ];
    }
    
    public static function getMyPosts(int $userId, int $page = 1, int $perPage = 10): array
    {
        $db = Database::getConnection();
        $offset = ($page - 1) * $perPage;
        
        $stmt = $db->prepare("
            SELECT * FROM posts
            WHERE author_id = :author_id
            ORDER BY created_at DESC
            LIMIT :limit OFFSET :offset
        ");
        $stmt->bindValue(':author_id', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $items = $stmt->fetchAll();
        
        $countStmt = $db->prepare("SELECT COUNT(*) as total FROM posts WHERE author_id = :author_id");
        $countStmt->execute(['author_id' => $userId]);
        $total = $countStmt->fetch()['total'];
        
        return [
            'items' => $items,
            'current_page' => $page,
            'per_page' => $perPage,
            'total' => $total,
            'last_page' => ceil($total / $perPage)
        ];
    }
    
    public static function incrementViews(int $postId): void
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("UPDATE posts SET views_count = views_count + 1 WHERE id = :id");
        $stmt->execute(['id' => $postId]);
    }
    
    public static function search(string $query, int $page = 1, int $perPage = 10): array
    {
        $db = Database::getConnection();
        $offset = ($page - 1) * $perPage;
        $searchTerm = "%{$query}%";
        
        $stmt = $db->prepare("
            SELECT p.*, u.name as author_name
            FROM posts p
            JOIN users u ON p.author_id = u.id
            WHERE p.status = 'published' AND (p.title LIKE :search OR p.content LIKE :search)
            ORDER BY p.published_at DESC
            LIMIT :limit OFFSET :offset
        ");
        $stmt->bindValue(':search', $searchTerm);
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $items = $stmt->fetchAll();
        
        $countStmt = $db->prepare("
            SELECT COUNT(*) as total 
            FROM posts 
            WHERE status = 'published' AND (title LIKE :search OR content LIKE :search)
        ");
        $countStmt->execute(['search' => $searchTerm]);
        $total = $countStmt->fetch()['total'];
        
        return [
            'items' => $items,
            'current_page' => $page,
            'per_page' => $perPage,
            'total' => $total,
            'last_page' => ceil($total / $perPage)
        ];
    }
    
    public static function generateSlug(string $title): string
    {
        $slug = strtolower(trim($title));
        $slug = preg_replace('/[^a-z0-9-]/', '-', $slug);
        $slug = preg_replace('/-+/', '-', $slug);
        
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT COUNT(*) as count FROM posts WHERE slug = :slug");
        $stmt->execute(['slug' => $slug]);
        $count = $stmt->fetch()['count'];
        
        if ($count > 0) {
            $slug .= '-' . ($count + 1);
        }
        
        return $slug;
    }
}
EOF

# Crear Utils
mkdir -p src/Utils

cat > src/Utils/Session.php << 'EOF'
<?php
namespace Blog\Utils;

class Session
{
    public static function start(): void
    {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
    }
    
    public static function set(string $key, $value): void
    {
        $_SESSION[$key] = $value;
    }
    
    public static function get(string $key, $default = null)
    {
        return $_SESSION[$key] ?? $default;
    }
    
    public static function has(string $key): bool
    {
        return isset($_SESSION[$key]);
    }
    
    public static function remove(string $key): void
    {
        unset($_SESSION[$key]);
    }
    
    public static function destroy(): void
    {
        $_SESSION = [];
        session_destroy();
    }
}
EOF

cat > src/Utils/Flash.php << 'EOF'
<?php
namespace Blog\Utils;

class Flash
{
    public static function set(string $type, string $message): void
    {
        Session::set('flash_' . $type, $message);
    }
    
    public static function success(string $message): void
    {
        self::set('success', $message);
    }
    
    public static function error(string $message): void
    {
        self::set('error', $message);
    }
    
    public static function get(string $type): ?string
    {
        $key = 'flash_' . $type;
        $message = Session::get($key);
        Session::remove($key);
        return $message;
    }
    
    public static function has(string $type): bool
    {
        return Session::has('flash_' . $type);
    }
    
    public static function display(): void
    {
        if (self::has('success')) {
            echo '<div class="alert alert-success alert-dismissible fade show" role="alert">' . htmlspecialchars(self::get('success')) . '<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>';
        }
        if (self::has('error')) {
            echo '<div class="alert alert-danger alert-dismissible fade show" role="alert">' . htmlspecialchars(self::get('error')) . '<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>';
        }
    }
}
EOF

cat > src/Utils/Helpers.php << 'EOF'
<?php
function asset(string $path): string
{
    return '/assets/' . ltrim($path, '/');
}

function url(string $path = ''): string
{
    return 'http://localhost:8000' . $path;
}

function truncate(string $text, int $length = 150, string $suffix = '...'): string
{
    if (strlen($text) <= $length) return $text;
    return substr($text, 0, strpos($text, ' ', $length)) . $suffix;
}

function timeAgo(string $datetime): string
{
    $timestamp = strtotime($datetime);
    $diff = time() - $timestamp;
    
    if ($diff < 60) return 'fa uns segons';
    if ($diff < 3600) return 'fa ' . floor($diff / 60) . ' minuts';
    if ($diff < 86400) return 'fa ' . floor($diff / 3600) . ' hores';
    if ($diff < 2592000) return 'fa ' . floor($diff / 86400) . ' dies';
    
    return date('d/m/Y', $timestamp);
}
EOF

# Crear Controllers
mkdir -p src/Controllers

cat > src/Controllers/HomeController.php << 'EOF'
<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\Post;

class HomeController extends Controller
{
    public function index(): void
    {
        $page = $_GET['page'] ?? 1;
        $posts = Post::getPublished((int)$page, 6);
        
        $this->render('home/index', [
            'posts' => $posts,
            'title' => 'Inicio'
        ]);
    }
    
    public function search(): void
    {
        $query = $_GET['q'] ?? '';
        $page = $_GET['page'] ?? 1;
        
        if (empty($query)) {
            $this->redirect('/');
        }
        
        $posts = Post::search($query, (int)$page, 6);
        
        $this->render('home/search', [
            'posts' => $posts,
            'query' => $query,
            'title' => 'Resultados de búsqueda'
        ]);
    }
}
EOF

cat > src/Controllers/AuthController.php << 'EOF'
<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\User;
use Blog\Utils\Session;
use Blog\Utils\Flash;

class AuthController extends Controller
{
    public function showLogin(): void
    {
        $this->renderAuth('auth/login', [
            'title' => 'Iniciar Sesión',
            'csrf_token' => $this->generateCsrfToken()
        ]);
    }
    
    public function login(): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/login');
        }
        
        $email = $_POST['email'] ?? '';
        $password = $_POST['password'] ?? '';
        
        if (empty($email) || empty($password)) {
            Flash::error('Tots els camps són obligatoris');
            $this->redirect('/login');
        }
        
        $user = User::findByEmail($email);
        
        if (!$user || !password_verify($password, $user['password'])) {
            Flash::error('Credencials incorrectes');
            $this->redirect('/login');
        }
        
        Session::set('user_id', $user['id']);
        Session::set('user', $user);
        User::updateLastLogin($user['id']);
        
        Flash::success('Benvingut/da ' . $user['name']);
        $this->redirect('/');
    }
    
    public function showRegister(): void
    {
        $this->renderAuth('auth/register', [
            'title' => 'Registre',
            'csrf_token' => $this->generateCsrfToken()
        ]);
    }
    
    public function register(): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/register');
        }
        
        $name = trim($_POST['name'] ?? '');
        $email = trim($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';
        $passwordConfirm = $_POST['password_confirm'] ?? '';
        
        // Validaciones
        if (strlen($name) < 2 || strlen($name) > 50) {
            Flash::error('El nom ha de tenir entre 2 i 50 caràcters');
            $this->redirect('/register');
        }
        
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            Flash::error('Email invàlid');
            $this->redirect('/register');
        }
        
        if (strlen($password) < 8) {
            Flash::error('La contrasenya ha de tenir almenys 8 caràcters');
            $this->redirect('/register');
        }
        
        if (!preg_match('/[A-Z]/', $password) || !preg_match('/[0-9]/', $password)) {
            Flash::error('La contrasenya ha de contenir almenys una majúscula i un número');
            $this->redirect('/register');
        }
        
        if ($password !== $passwordConfirm) {
            Flash::error('Les contrasenyes no coincideixen');
            $this->redirect('/register');
        }
        
        if (User::findByEmail($email)) {
            Flash::error('Aquest email ja està registrat');
            $this->redirect('/register');
        }
        
        $userId = User::create([
            'name' => $name,
            'email' => $email,
            'password' => password_hash($password, PASSWORD_BCRYPT)
        ]);
        
        Flash::success('Registre completat! Ara pots iniciar sessió');
        $this->redirect('/login');
    }
    
    public function logout(): void
    {
        Session::destroy();
        Flash::success('Has tancat sessió');
        $this->redirect('/');
    }
}
EOF

cat > src/Controllers/PostController.php << 'EOF'
<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\Post;
use Blog\Models\User;
use Blog\Utils\Session;
use Blog\Utils\Flash;

class PostController extends Controller
{
    public function index(): void
    {
        $page = $_GET['page'] ?? 1;
        $posts = Post::getPublished((int)$page, 12);
        
        $this->render('posts/index', [
            'posts' => $posts,
            'title' => 'Todos los posts'
        ]);
    }
    
    public function show(string $slug): void
    {
        $post = Post::findBySlug($slug);
        
        if (!$post) {
            http_response_code(404);
            echo "<h1>404 - Post no encontrado</h1>";
            return;
        }
        
        Post::incrementViews($post['id']);
        
        $this->render('posts/show', [
            'post' => $post,
            'title' => $post['title']
        ]);
    }
    
    public function byAuthor(string $id): void
    {
        $author = User::find((int)$id);
        
        if (!$author) {
            http_response_code(404);
            echo "<h1>404 - Autor no encontrado</h1>";
            return;
        }
        
        $page = $_GET['page'] ?? 1;
        $posts = Post::getByAuthor((int)$id, (int)$page, 6);
        
        $this->render('posts/by-author', [
            'posts' => $posts,
            'author' => $author,
            'title' => 'Posts de ' . $author['name']
        ]);
    }
    
    public function myPosts(): void
    {
        $page = $_GET['page'] ?? 1;
        $posts = Post::getMyPosts($this->getCurrentUser()['id'], (int)$page, 10);
        
        $this->render('posts/my-posts', [
            'posts' => $posts,
            'title' => 'Els meus posts'
        ]);
    }
    
    public function create(): void
    {
        $this->render('posts/create', [
            'title' => 'Crear nuevo post',
            'csrf_token' => $this->generateCsrfToken()
        ]);
    }
    
    public function store(): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/my-posts/create');
        }
        
        $title = trim($_POST['title'] ?? '');
        $content = trim($_POST['content'] ?? '');
        $status = $_POST['status'] ?? 'draft';
        
        if (strlen($title) < 5) {
            Flash::error('El títol ha de tenir almenys 5 caràcters');
            $this->redirect('/my-posts/create');
        }
        
        if (strlen($content) < 50) {
            Flash::error('El contingut ha de tenir almenys 50 caràcters');
            $this->redirect('/my-posts/create');
        }
        
        $slug = Post::generateSlug($title);
        $excerpt = substr(strip_tags($content), 0, 200);
        
        $postId = Post::create([
            'title' => $title,
            'slug' => $slug,
            'content' => $content,
            'excerpt' => $excerpt,
            'author_id' => $this->getCurrentUser()['id'],
            'status' => $status,
            'published_at' => $status === 'published' ? date('Y-m-d H:i:s') : null
        ]);
        
        Flash::success('Post creat correctament');
        $this->redirect('/my-posts');
    }
    
    public function edit(string $id): void
    {
        $post = Post::find((int)$id);
        
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís per editar aquest post');
            $this->redirect('/my-posts');
        }
        
        $this->render('posts/edit', [
            'post' => $post,
            'title' => 'Editar post',
            'csrf_token' => $this->generateCsrfToken()
        ]);
    }
    
    public function update(string $id): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/my-posts/' . $id . '/edit');
        }
        
        $post = Post::find((int)$id);
        
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís per editar aquest post');
            $this->redirect('/my-posts');
        }
        
        $title = trim($_POST['title'] ?? '');
        $content = trim($_POST['content'] ?? '');
        $status = $_POST['status'] ?? 'draft';
        
        if (strlen($title) < 5) {
            Flash::error('El títol ha de tenir almenys 5 caràcters');
            $this->redirect('/my-posts/' . $id . '/edit');
        }
        
        if (strlen($content) < 50) {
            Flash::error('El contingut ha de tenir almenys 50 caràcters');
            $this->redirect('/my-posts/' . $id . '/edit');
        }
        
        $excerpt = substr(strip_tags($content), 0, 200);
        $updateData = [
            'title' => $title,
            'content' => $content,
            'excerpt' => $excerpt,
            'status' => $status
        ];
        
        if ($status === 'published' && $post['status'] !== 'published') {
            $updateData['published_at'] = date('Y-m-d H:i:s');
        }
        
        Post::update((int)$id, $updateData);
        
        Flash::success('Post actualitzat correctament');
        $this->redirect('/my-posts');
    }
    
    public function delete(string $id): void
    {
        $post = Post::find((int)$id);
        
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís per eliminar aquest post');
            $this->redirect('/my-posts');
        }
        
        Post::delete((int)$id);
        
        Flash::success('Post eliminat correctament');
        $this->redirect('/my-posts');
    }
    
    public function publish(string $id): void
    {
        $post = Post::find((int)$id);
        
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís per modificar aquest post');
            $this->redirect('/my-posts');
        }
        
        $newStatus = $post['status'] === 'published' ? 'draft' : 'published';
        
        Post::update((int)$id, [
            'status' => $newStatus,
            'published_at' => $newStatus === 'published' ? date('Y-m-d H:i:s') : null
        ]);
        
        Flash::success('Estat del post actualitzat');
        $this->redirect('/my-posts');
    }
}
EOF

cat > src/Controllers/UserController.php << 'EOF'
<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\User;
use Blog\Models\Post;
use Blog\Utils\Session;
use Blog\Utils\Flash;

class UserController extends Controller
{
    public function profile(): void
    {
        $user = $this->getCurrentUser();
        $stats = User::getUserStats($user['id']);
        
        $this->render('user/profile', [
            'user' => $user,
            'stats' => $stats,
            'title' => 'El meu perfil'
        ]);
    }
    
    public function editProfile(): void
    {
        $this->render('user/edit', [
            'user' => $this->getCurrentUser(),
            'title' => 'Editar perfil',
            'csrf_token' => $this->generateCsrfToken()
        ]);
    }
    
    public function updateProfile(): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/profile/edit');
        }
        
        $name = trim($_POST['name'] ?? '');
        $bio = trim($_POST['bio'] ?? '');
        $userId = $this->getCurrentUser()['id'];
        
        if (strlen($name) < 2 || strlen($name) > 100) {
            Flash::error('El nom ha de tenir entre 2 i 100 caràcters');
            $this->redirect('/profile/edit');
        }
        
        User::update($userId, [
            'name' => $name,
            'bio' => $bio
        ]);
        
        // Actualizar sesión
        $user = User::find($userId);
        Session::set('user', $user);
        
        Flash::success('Perfil actualitzat correctament');
        $this->redirect('/profile');
    }
    
    public function uploadAvatar(): void
    {
        if (!isset($_FILES['avatar']) || $_FILES['avatar']['error'] !== UPLOAD_ERR_OK) {
            Flash::error('Error al pujar l\'avatar');
            $this->redirect('/profile/edit');
        }
        
        $file = $_FILES['avatar'];
        $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        
        if (!in_array($file['type'], $allowedTypes)) {
            Flash::error('Format no permès. Usa JPG, PNG, GIF o WEBP');
            $this->redirect('/profile/edit');
        }
        
        if ($file['size'] > 5242880) {
            Flash::error('L\'avatar no pot superar els 5MB');
            $this->redirect('/profile/edit');
        }
        
        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = 'avatar_' . $this->getCurrentUser()['id'] . '_' . time() . '.' . $extension;
        $uploadPath = __DIR__ . '/../../storage/uploads/' . $filename;
        
        if (!is_dir(__DIR__ . '/../../storage/uploads')) {
            mkdir(__DIR__ . '/../../storage/uploads', 0777, true);
        }
        
        if (move_uploaded_file($file['tmp_name'], $uploadPath)) {
            $avatarPath = '/storage/uploads/' . $filename;
            User::update($this->getCurrentUser()['id'], ['avatar' => $avatarPath]);
            
            $user = User::find($this->getCurrentUser()['id']);
            Session::set('user', $user);
            
            Flash::success('Avatar actualitzat correctament');
        } else {
            Flash::error('Error al guardar l\'avatar');
        }
        
        $this->redirect('/profile/edit');
    }
}
EOF

# Crear Views
mkdir -p src/Views/{layouts,home,auth,posts,user}

# Layouts
cat > src/Views/layouts/app.php << 'EOF'
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($title ?? 'Blog MVC'); ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f5f5f5; }
        .post-card { transition: transform 0.3s; margin-bottom: 20px; }
        .post-card:hover { transform: translateY(-5px); }
        .avatar-sm { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; }
        .avatar-md { width: 100px; height: 100px; border-radius: 50%; object-fit: cover; }
        .navbar-brand { font-weight: bold; }
        .post-content img { max-width: 100%; height: auto; }
        .pagination { justify-content: center; margin-top: 30px; }
        footer { margin-top: 50px; padding: 20px 0; background: #343a40; color: white; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="/">📝 Blog MVC</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="/"><i class="fas fa-home"></i> Inici</a></li>
                    <li class="nav-item"><a class="nav-link" href="/posts"><i class="fas fa-newspaper"></i> Posts</a></li>
                    <?php if (isset($_SESSION['user_id'])): ?>
                        <li class="nav-item"><a class="nav-link" href="/my-posts"><i class="fas fa-edit"></i> Els meus posts</a></li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                                <?php if ($_SESSION['user']['avatar']): ?>
                                    <img src="<?php echo asset($_SESSION['user']['avatar']); ?>" class="avatar-sm">
                                <?php else: ?>
                                    <i class="fas fa-user-circle"></i>
                                <?php endif; ?>
                                <?php echo htmlspecialchars($_SESSION['user']['name']); ?>
                            </a>
                            <ul class="dropdown-menu">
                                <li><a class="dropdown-item" href="/profile"><i class="fas fa-id-card"></i> Perfil</a></li>
                                <li><a class="dropdown-item" href="/profile/edit"><i class="fas fa-user-edit"></i> Editar perfil</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="#" onclick="document.getElementById('logout-form').submit();"><i class="fas fa-sign-out-alt"></i> Tancar sessió</a></li>
                            </ul>
                        </li>
                    <?php else: ?>
                        <li class="nav-item"><a class="nav-link" href="/login"><i class="fas fa-sign-in-alt"></i> Iniciar sessió</a></li>
                        <li class="nav-item"><a class="nav-link" href="/register"><i class="fas fa-user-plus"></i> Registre</a></li>
                    <?php endif; ?>
                </ul>
            </div>
        </div>
    </nav>
    
    <form id="logout-form" method="POST" action="/logout" style="display: none;">
        <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token'] ?? ''; ?>">
    </form>

    <main class="container my-4">
        <?php require_once $viewPath; ?>
    </main>

    <footer class="text-center">
        <div class="container">
            <p>&copy; <?php echo date('Y'); ?> Blog MVC - Creat amb PHP OOP i MVC</p>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
EOF

cat > src/Views/layouts/auth.php << 'EOF'
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($title ?? 'Blog MVC'); ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
        .auth-card { max-width: 500px; margin: 50px auto; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.1); }
        .auth-card .card-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 15px 15px 0 0; padding: 20px; text-align: center; }
        .auth-card .card-body { padding: 30px; background: white; border-radius: 0 0 15px 15px; }
        .btn-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; }
        .btn-primary:hover { opacity: 0.9; transform: translateY(-2px); }
    </style>
</head>
<body>
    <div class="container">
        <div class="row">
            <div class="col-md-8 mx-auto auth-card">
                <div class="card">
                    <div class="card-header">
                        <h3><i class="fas fa-blog"></i> <?php echo htmlspecialchars($title ?? 'Blog MVC'); ?></h3>
                    </div>
                    <div class="card-body">
                        <?php require_once $viewPath; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
EOF

# Home views
cat > src/Views/home/index.php << 'EOF'
<div class="row">
    <div class="col-12">
        <div class="text-center mb-5">
            <h1 class="display-4">📝 Benvingut al Blog MVC</h1>
            <p class="lead">Comparteix coneixement, aprèn i connecta amb altres desenvolupadors</p>
            <?php if (!isset($_SESSION['user_id'])): ?>
                <a href="/register" class="btn btn-primary btn-lg"><i class="fas fa-user-plus"></i> Crea un compte</a>
            <?php else: ?>
                <a href="/my-posts/create" class="btn btn-primary btn-lg"><i class="fas fa-plus"></i> Crea un post</a>
            <?php endif; ?>
        </div>
    </div>
    
    <div class="col-12 mb-4">
        <form action="/search" method="GET" class="d-flex">
            <input type="search" name="q" class="form-control me-2" placeholder="Cerca posts...">
            <button type="submit" class="btn btn-outline-primary"><i class="fas fa-search"></i> Cercar</button>
        </form>
    </div>
    
    <?php foreach ($posts['items'] as $post): ?>
        <div class="col-md-6 col-lg-4">
            <div class="card post-card h-100">
                <div class="card-body">
                    <h5 class="card-title"><?php echo htmlspecialchars($post['title']); ?></h5>
                    <p class="card-text"><?php echo truncate(strip_tags($post['excerpt'] ?? $post['content']), 120); ?></p>
                    <div class="d-flex justify-content-between align-items-center">
                        <small class="text-muted">
                            <i class="fas fa-user"></i> <?php echo htmlspecialchars($post['author_name']); ?><br>
                            <i class="fas fa-calendar"></i> <?php echo timeAgo($post['published_at']); ?>
                        </small>
                        <a href="/posts/<?php echo $post['slug']; ?>" class="btn btn-sm btn-primary">Llegir més</a>
                    </div>
                </div>
            </div>
        </div>
    <?php endforeach; ?>
    
    <?php if ($posts['last_page'] > 1): ?>
        <div class="col-12">
            <nav>
                <ul class="pagination">
                    <?php for ($i = 1; $i <= $posts['last_page']; $i++): ?>
                        <li class="page-item <?php echo $i == $posts['current_page'] ? 'active' : ''; ?>">
                            <a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a>
                        </li>
                    <?php endfor; ?>
                </ul>
            </nav>
        </div>
    <?php endif; ?>
</div>
EOF

cat > src/Views/home/search.php << 'EOF'
<div class="row">
    <div class="col-12">
        <h2>Resultats de cerca: "<?php echo htmlspecialchars($query); ?>"</h2>
        <p>S'han trobat <?php echo $posts['total']; ?> resultats</p>
        <a href="/" class="btn btn-secondary mb-4"><i class="fas fa-arrow-left"></i> Tornar</a>
    </div>
    
    <?php foreach ($posts['items'] as $post): ?>
        <div class="col-md-6 col-lg-4">
            <div class="card post-card h-100">
                <div class="card-body">
                    <h5 class="card-title"><?php echo htmlspecialchars($post['title']); ?></h5>
                    <p class="card-text"><?php echo truncate(strip_tags($post['excerpt'] ?? $post['content']), 120); ?></p>
                    <a href="/posts/<?php echo $post['slug']; ?>" class="btn btn-primary">Llegir més</a>
                </div>
            </div>
        </div>
    <?php endforeach; ?>
</div>
EOF

# Auth views
cat > src/Views/auth/login.php << 'EOF'
<?php
use Blog\Utils\Flash;
?>
<div class="text-center mb-4">
    <i class="fas fa-sign-in-alt fa-3x text-primary"></i>
    <h2>Iniciar Sessió</h2>
</div>

<?php Flash::display(); ?>

<form method="POST" action="/login">
    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
    
    <div class="mb-3">
        <label for="email" class="form-label">Email</label>
        <input type="email" class="form-control" id="email" name="email" required>
    </div>
    
    <div class="mb-3">
        <label for="password" class="form-label">Contrasenya</label>
        <input type="password" class="form-control" id="password" name="password" required>
    </div>
    
    <button type="submit" class="btn btn-primary w-100">Iniciar Sessió</button>
</form>

<div class="text-center mt-3">
    <p>No tens compte? <a href="/register">Registra't aquí</a></p>
</div>
EOF

cat > src/Views/auth/register.php << 'EOF'
<?php
use Blog\Utils\Flash;
?>
<div class="text-center mb-4">
    <i class="fas fa-user-plus fa-3x text-primary"></i>
    <h2>Registre d'Usuari</h2>
</div>

<?php Flash::display(); ?>

<form method="POST" action="/register">
    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
    
    <div class="mb-3">
        <label for="name" class="form-label">Nom complet</label>
        <input type="text" class="form-control" id="name" name="name" required minlength="2" maxlength="50">
    </div>
    
    <div class="mb-3">
        <label for="email" class="form-label">Email</label>
        <input type="email" class="form-control" id="email" name="email" required>
    </div>
    
    <div class="mb-3">
        <label for="password" class="form-label">Contrasenya</label>
        <input type="password" class="form-control" id="password" name="password" required minlength="8">
        <div class="form-text">Mínim 8 caràcters, 1 majúscula i 1 número</div>
    </div>
    
    <div class="mb-3">
        <label for="password_confirm" class="form-label">Confirmar contrasenya</label>
        <input type="password" class="form-control" id="password_confirm" name="password_confirm" required>
    </div>
    
    <button type="submit" class="btn btn-primary w-100">Registrar-se</button>
</form>

<div class="text-center mt-3">
    <p>Ja tens compte? <a href="/login">Inicia sessió</a></p>
</div>
EOF

# Crear script SQL
cat > database/migrations/01_create_tables.sql << 'EOF'
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
EOF

echo ""
echo "✅ Proyecto creado correctamente!"
echo ""
echo "📋 Pasos a seguir:"
echo "1. cd blog-mvc"
echo "2. composer dump-autoload"
echo "3. mysql -u root -p < database/migrations/01_create_tables.sql"
echo "4. php -S localhost:8000 -t public"
echo ""
echo "👤 Usuarios de prueba:"
echo "   admin@blog.com / Admin123!"
echo "   john@blog.com / User123!"
echo "   jane@blog.com / User123!"
echo "   sergio@blog.com / User123!"
echo ""

