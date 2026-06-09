#!/bin/bash

echo "🔧 Corregint problema de tancament de sessió i vista de detall..."

# 1. CORREGIR LAYOUT PRINCIPAL: afegir logout al dropdown
cat > src/Views/layouts/app.php << 'APP'
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($title ?? 'Blog MVC'); ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f8f9fa; font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif; }
        .navbar { background-color: white; border-bottom: 1px solid #dee2e6; box-shadow: 0 1px 2px rgba(0,0,0,0.03); }
        .navbar-brand { font-weight: 600; color: #0f172a; }
        .avatar-sm { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; margin-right: 6px; }
        .avatar-md { width: 96px; height: 96px; border-radius: 50%; object-fit: cover; border: 1px solid #e2e8f0; }
        .card { border: 1px solid #eef2f6; border-radius: 20px; transition: box-shadow 0.2s; background: white; }
        .card:hover { box-shadow: 0 8px 20px rgba(0,0,0,0.05); }
        .btn-primary { background-color: #3b82f6; border-radius: 40px; padding: 0.5rem 1.25rem; font-weight: 500; }
        .form-control, .form-select { border-radius: 12px; border: 1px solid #e2e8f0; }
        footer { background-color: white; border-top: 1px solid #eef2f6; padding: 2rem 0; margin-top: 3rem; color: #475569; }
        .pagination .page-link { border-radius: 30px; margin: 0 3px; background: #f1f5f9; border: none; color: #1e293b; }
        .pagination .active .page-link { background: #3b82f6; color: white; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg sticky-top">
        <div class="container">
            <a class="navbar-brand" href="/">Blog MVC</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="/">Inici</a></li>
                    <li class="nav-item"><a class="nav-link" href="/posts">Articles</a></li>
                    <?php if (isset($_SESSION['user_id'])): ?>
                        <li class="nav-item"><a class="nav-link" href="/my-posts">Els meus articles</a></li>
                        <li class="nav-item dropdown">
                            <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" data-bs-toggle="dropdown">
                                <?php if ($_SESSION['user']['avatar']): ?>
                                    <img src="<?php echo asset($_SESSION['user']['avatar']); ?>" class="avatar-sm">
                                <?php else: ?>
                                    <i class="fas fa-user-circle fa-lg me-1"></i>
                                <?php endif; ?>
                                <?php echo htmlspecialchars($_SESSION['user']['name']); ?>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="/profile"><i class="fas fa-user me-2"></i>Perfil</a></li>
                                <li><a class="dropdown-item" href="/profile/edit"><i class="fas fa-edit me-2"></i>Editar perfil</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li>
                                    <a class="dropdown-item" href="#" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                                        <i class="fas fa-sign-out-alt me-2"></i>Tancar sessió
                                    </a>
                                </li>
                            </ul>
                        </li>
                    <?php else: ?>
                        <li class="nav-item"><a class="nav-link" href="/login">Iniciar sessió</a></li>
                        <li class="nav-item"><a class="nav-link" href="/register">Registre</a></li>
                    <?php endif; ?>
                </ul>
            </div>
        </div>
    </nav>
    <form id="logout-form" method="POST" action="/logout" style="display: none;">
        <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token'] ?? ''; ?>">
    </form>
    <main class="py-4">
        <div class="container">
            <?php require_once $viewPath; ?>
        </div>
    </main>
    <footer class="text-center">
        <div class="container">
            <p class="mb-0">&copy; <?php echo date('Y'); ?> Blog MVC. Desenvolupat amb PHP i arquitectura MVC.</p>
        </div>
    </footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
APP

# 2. AS SEGURAR QUE LA VISTA DE DETALL DE POST EXISTEIX
cat > src/Views/posts/show.php << 'SHOW'
<div class="row justify-content-center">
    <div class="col-lg-8">
        <article class="card border-0 shadow-sm">
            <div class="card-body p-4 p-lg-5">
                <h1 class="fw-semibold mb-3"><?php echo htmlspecialchars($post['title']); ?></h1>
                <div class="text-secondary mb-4 pb-2 border-bottom">
                    <i class="fas fa-user me-1"></i> <?php echo htmlspecialchars($post['author_name']); ?>
                    <span class="mx-2">·</span>
                    <i class="far fa-calendar-alt me-1"></i> <?php echo timeAgo($post['published_at']); ?>
                    <span class="mx-2">·</span>
                    <i class="fas fa-eye me-1"></i> <?php echo $post['views_count']; ?> visualitzacions
                </div>
                <div class="post-content fs-5">
                    <?php echo $post['content']; ?>
                </div>
                <div class="mt-5">
                    <a href="/posts" class="btn btn-outline-secondary rounded-pill">
                        <i class="fas fa-arrow-left me-2"></i>Tornar als articles
                    </a>
                </div>
            </div>
        </article>
    </div>
</div>
SHOW

# 3. AS SEGURAR QUE EL MÈTODE show DEL PostController FUNCIONA CORRECTAMENT
# Verificar que existeix el mètode show al controlador
if ! grep -q "public function show" src/Controllers/PostController.php; then
    echo "⚠️ El mètode show no existeix al PostController. S'afegirà."
    # Fem una còpia de seguretat
    cp src/Controllers/PostController.php src/Controllers/PostController.php.bak
    # Inserim el mètode show abans del mètode index (per ordre)
    sed -i '/public function index/a\
\
    public function show(string $slug): void\
    {\
        $post = Post::findBySlug($slug);\
        if (!$post) {\
            http_response_code(404);\
            echo "<h1>404 - Post no trobat</h1>";\
            return;\
        }\
        Post::incrementViews($post["id"]);\
        $this->render("posts/show", ["post" => $post, "title" => $post["title"]]);\
    }' src/Controllers/PostController.php
else
    echo "✅ El mètode show ja existeix."
fi

# 4. VERIFICAR QUE LA RUTA /posts/{slug} ESTIGUI DEFINIDA
if ! grep -q "'path' => '/posts/{slug}'" config/routes.php; then
    echo "⚠️ La ruta /posts/{slug} no està definida. Afegint-la..."
    # Inserir ruta després de la línia de /posts
    sed -i "/'path' => '\/posts',/a\    ['method' => 'GET', 'path' => '\/posts\/{slug}', 'controller' => 'PostController', 'action' => 'show']," config/routes.php
else
    echo "✅ Ruta /posts/{slug} ja definida."
fi

# 5. VERIFICAR QUE LA RUTA /logout EXISTEIXI (POST)
if ! grep -q "'path' => '/logout'" config/routes.php; then
    echo "⚠️ Afegint ruta POST /logout..."
    sed -i "/'path' => '\/register',/a\    ['method' => 'POST', 'path' => '\/logout', 'controller' => 'AuthController', 'action' => 'logout', 'middleware' => 'auth']," config/routes.php
fi

echo ""
echo "✅ Correccions aplicades:"
echo "   - Menú d'usuari amb opció 'Tancar sessió' funcionant."
echo "   - Vista de detall de post (individual) creada i accessible via /posts/títol-amb-slug."
echo ""
echo "🚀 Reinicia el servidor si està en marxa:"
echo "   php -S localhost:8000 -t public"
