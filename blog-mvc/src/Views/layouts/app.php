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
