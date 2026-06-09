#!/bin/bash

# 1. Actualitzar el layout (app.php) perquè l'avatar siga menut i es veja bé
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
        body { background: #f8f9fa; font-family: system-ui; }
        .navbar { background: white; border-bottom: 1px solid #dee2e6; }
        /* Avatar petit per la navbar */
        .avatar-nav {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 8px;
        }
        /* Avatar mitjà per al perfil */
        .avatar-profile {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            margin-bottom: 1rem;
            border: 3px solid white;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .card { border: 1px solid #eef2f6; border-radius: 20px; }
        .btn-primary { background-color: #3b82f6; border-radius: 40px; }
        footer { background: white; border-top: 1px solid #eef2f6; margin-top: 2rem; }
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
                                <?php if (!empty($_SESSION['user']['avatar'])): ?>
                                    <img src="<?php echo $_SESSION['user']['avatar']; ?>" class="avatar-nav" alt="avatar">
                                <?php else: ?>
                                    <i class="fas fa-user-circle fa-lg me-1"></i>
                                <?php endif; ?>
                                <?php echo htmlspecialchars($_SESSION['user']['name']); ?>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="/profile">Perfil</a></li>
                                <li><a class="dropdown-item" href="/profile/edit">Editar perfil</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="#" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">Tancar sessió</a></li>
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
            <?php echo $content ?? '<div class="alert alert-danger">Error: contingut no disponible</div>'; ?>
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

# 2. Actualitzar la vista de perfil perquè use la classe .avatar-profile
cat > src/Views/user/profile.php << 'PROFILE'
<div class="row">
    <div class="col-md-4 text-center">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <?php if (!empty($user['avatar'])): ?>
                    <img src="<?php echo $user['avatar']; ?>" class="avatar-profile" alt="Avatar">
                <?php else: ?>
                    <i class="fas fa-user-circle fa-5x text-secondary mb-3"></i>
                <?php endif; ?>
                <h3 class="fw-semibold mt-2"><?php echo htmlspecialchars($user['name']); ?></h3>
                <p class="text-secondary"><?php echo htmlspecialchars($user['email']); ?></p>
                <a href="/profile/edit" class="btn btn-outline-primary rounded-pill">Editar perfil</a>
            </div>
        </div>
    </div>
    <div class="col-md-8">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-transparent border-0 pt-4">
                <h5 class="fw-semibold mb-0">Estadístiques</h5>
            </div>
            <div class="card-body">
                <p><strong>Total d'articles:</strong> <?php echo $stats['total_posts']; ?></p>
                <p><strong>Visualitzacions totals:</strong> <?php echo $stats['total_views']; ?></p>
                <p><strong>Membre des de:</strong> <?php echo date('d/m/Y', strtotime($user['created_at'])); ?></p>
                <?php if ($user['bio']): ?>
                    <hr><h6>Biografia</h6><p class="text-secondary"><?php echo nl2br(htmlspecialchars($user['bio'])); ?></p>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>
PROFILE

echo "✅ Estils d'avatar corregits. Ara es veurà menut a la navbar i de mida adequada al perfil."
echo "🔄 Reinicia el servidor: /usr/bin/php8.2 -S localhost:8000 -t public"
