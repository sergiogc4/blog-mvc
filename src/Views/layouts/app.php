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
