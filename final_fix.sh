#!/bin/bash

# 1. Asegurar que Helpers.php tiene las funciones y se incluye correctamente
cat > src/Utils/Helpers.php << 'HELPERS'
<?php
/**
 * Funciones globales de ayuda
 */

if (!function_exists('truncate')) {
    function truncate($text, $length = 150, $suffix = '...') {
        if (strlen($text) <= $length) return $text;
        $cut = substr($text, 0, $length);
        $lastSpace = strrpos($cut, ' ');
        if ($lastSpace !== false) {
            $cut = substr($cut, 0, $lastSpace);
        }
        return $cut . $suffix;
    }
}

if (!function_exists('timeAgo')) {
    function timeAgo($datetime) {
        $timestamp = strtotime($datetime);
        $diff = time() - $timestamp;
        if ($diff < 60) return 'fa uns segons';
        if ($diff < 3600) return 'fa ' . floor($diff / 60) . ' minuts';
        if ($diff < 86400) return 'fa ' . floor($diff / 3600) . ' hores';
        if ($diff < 2592000) return 'fa ' . floor($diff / 86400) . ' dies';
        return date('d/m/Y', $timestamp);
    }
}

if (!function_exists('asset')) {
    function asset($path) {
        return '/assets/' . ltrim($path, '/');
    }
}
HELPERS

# 2. Forzar la inclusión en public/index.php
cat > public/index.php << 'INDEXPHP'
<?php
session_start();

require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../src/Utils/Helpers.php'; // funciones globales

use Blog\Core\Router;
use Blog\Core\Database;

$config = require __DIR__ . '/../config/database.php';
$routesConfig = require __DIR__ . '/../config/routes.php';

Database::setConfig($config);

$router = new Router();
foreach ($routesConfig as $route) {
    $router->add($route['method'], $route['path'], $route['controller'], $route['action'], $route['middleware'] ?? null);
}

$router->dispatch($_SERVER['REQUEST_METHOD'], $_SERVER['REQUEST_URI']);
INDEXPHP

# 3. Reemplazar vista home/index.php (versión simple y robusta)
cat > src/Views/home/index.php << 'HOME'
<div class="hero">
    <h1 class="display-5 fw-semibold">Blog MVC</h1>
    <p class="lead text-secondary mt-2">Comparteix coneixement, aprèn i connecta.</p>
    <?php if (!isset($_SESSION['user_id'])): ?>
        <a href="/register" class="btn btn-primary mt-3 px-4">Crea un compte</a>
    <?php else: ?>
        <a href="/my-posts/create" class="btn btn-primary mt-3 px-4">Publica un article</a>
    <?php endif; ?>
</div>

<div class="row justify-content-center mb-5">
    <div class="col-md-6">
        <form action="/search" method="GET" class="d-flex gap-2">
            <input type="search" name="q" class="form-control" placeholder="Cerca articles...">
            <button type="submit" class="btn btn-outline-primary">Cercar</button>
        </form>
    </div>
</div>

<div class="row">
    <?php if (empty($posts['items'])): ?>
        <div class="col-12 text-center py-5 text-secondary">Encara no hi ha articles publicats.</div>
    <?php else: ?>
        <?php foreach ($posts['items'] as $post): ?>
            <div class="col-md-6 col-lg-4 mb-4">
                <div class="card h-100">
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title fw-semibold"><?php echo htmlspecialchars($post['title']); ?></h5>
                        <p class="card-text text-secondary small flex-grow-1">
                            <?php 
                            $excerpt = $post['excerpt'] ?? $post['content'];
                            echo truncate(strip_tags($excerpt), 120);
                            ?>
                        </p>
                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <div class="small text-secondary">
                                <?php echo htmlspecialchars($post['author_name']); ?><br>
                                <?php echo timeAgo($post['published_at']); ?>
                            </div>
                            <a href="/posts/<?php echo $post['slug']; ?>" class="btn btn-sm btn-outline-primary rounded-pill">Llegir</a>
                        </div>
                    </div>
                </div>
            </div>
        <?php endforeach; ?>
    <?php endif; ?>
</div>

<?php if ($posts['last_page'] > 1): ?>
    <nav class="mt-4">
        <ul class="pagination justify-content-center">
            <?php for ($i = 1; $i <= $posts['last_page']; $i++): ?>
                <li class="page-item <?php echo $i == $posts['current_page'] ? 'active' : ''; ?>">
                    <a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a>
                </li>
            <?php endfor; ?>
        </ul>
    </nav>
<?php endif; ?>
HOME

# 4. Reemplazar HomeController para asegurar la paginación
cat > src/Controllers/HomeController.php << 'HOMECTRL'
<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\Post;

class HomeController extends Controller
{
    public function index(): void
    {
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        if ($page < 1) $page = 1;
        
        $posts = Post::getPublished($page, 6);
        
        $this->render('home/index', [
            'posts' => $posts,
            'title' => 'Inici'
        ]);
    }
    
    public function search(): void
    {
        $query = trim($_GET['q'] ?? '');
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        if (empty($query)) {
            $this->redirect('/');
            return;
        }
        $posts = Post::search($query, $page, 6);
        $this->render('home/search', [
            'posts' => $posts,
            'query' => $query,
            'title' => 'Resultats de cerca'
        ]);
    }
}
HOMECTRL

# 5. Regenerar autoload y reiniciar
composer dump-autoload

echo "✅ Todos los archivos corregidos."
echo "▶️ Ahora reinicia el servidor: php -S localhost:8000 -t public"
