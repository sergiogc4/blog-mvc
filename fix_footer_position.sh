#!/bin/bash

# Arreglar layout principal para que el footer quede siempre abajo
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
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            background-color: #f8f9fa;
            font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;
        }
        main {
            flex: 1;
        }
        .navbar {
            background-color: white;
            border-bottom: 1px solid #dee2e6;
            box-shadow: 0 1px 2px rgba(0,0,0,0.03);
        }
        .navbar-brand {
            font-weight: 600;
            color: #0f172a;
        }
        .avatar-sm {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 6px;
        }
        .avatar-md {
            width: 96px;
            height: 96px;
            border-radius: 50%;
            object-fit: cover;
            border: 1px solid #e2e8f0;
        }
        .card {
            border: 1px solid #eef2f6;
            border-radius: 20px;
            transition: box-shadow 0.2s;
            background: white;
        }
        .card:hover {
            box-shadow: 0 8px 20px rgba(0,0,0,0.05);
        }
        .btn-primary {
            background-color: #3b82f6;
            border-color: #3b82f6;
            border-radius: 40px;
            padding: 0.5rem 1.25rem;
            font-weight: 500;
        }
        .btn-primary:hover {
            background-color: #2563eb;
            border-color: #2563eb;
        }
        .form-control, .form-select {
            border-radius: 12px;
            border: 1px solid #e2e8f0;
        }
        footer {
            background-color: white;
            border-top: 1px solid #eef2f6;
            padding: 1.5rem 0;
            margin-top: 2rem;
            color: #475569;
            font-size: 0.875rem;
        }
        .pagination .page-link {
            border-radius: 30px;
            margin: 0 3px;
            background: #f1f5f9;
            border: none;
            color: #1e293b;
        }
        .pagination .active .page-link {
            background: #3b82f6;
            color: white;
        }
        h1, h2, h3, h4 {
            font-weight: 600;
            letter-spacing: -0.02em;
        }
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

echo "✅ Footer arreglat per a que quedi sempre a baix de la pàgina."
echo "🔄 Reinicia el servidor (Ctrl+C i php -S localhost:8000 -t public)"
