#!/bin/bash

# Layout principal (app.php) - versión profesional con navbar fijo y footer
cat > src/Views/layouts/app.php << 'APP'
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($title ?? 'Blog MVC'); ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,300;14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background-color: #f5f7fa; color: #1e293b; line-height: 1.5; }
        .navbar { background-color: #ffffff !important; box-shadow: 0 1px 3px rgba(0,0,0,0.05), 0 1px 2px rgba(0,0,0,0.03); padding: 0.85rem 0; }
        .navbar-brand { font-weight: 700; font-size: 1.4rem; color: #0f172a !important; letter-spacing: -0.3px; }
        .nav-link { color: #475569 !important; font-weight: 500; transition: color 0.2s; }
        .nav-link:hover { color: #3b82f6 !important; }
        .dropdown-menu { border: none; box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.02); border-radius: 12px; margin-top: 0.5rem; }
        .avatar-sm { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; margin-right: 8px; border: 1px solid #e2e8f0; }
        .avatar-md { width: 100px; height: 100px; border-radius: 50%; object-fit: cover; border: 3px solid white; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); }
        .card { border: none; border-radius: 16px; box-shadow: 0 1px 3px rgba(0,0,0,0.05), 0 1px 2px rgba(0,0,0,0.03); transition: transform 0.2s, box-shadow 0.2s; background: white; }
        .card:hover { transform: translateY(-2px); box-shadow: 0 10px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.02); }
        .btn-primary { background-color: #3b82f6; border-color: #3b82f6; font-weight: 500; padding: 0.5rem 1.25rem; border-radius: 10px; transition: all 0.2s; }
        .btn-primary:hover { background-color: #2563eb; border-color: #2563eb; transform: translateY(-1px); }
        .btn-outline-secondary { border-color: #cbd5e1; color: #475569; border-radius: 10px; font-weight: 500; }
        .btn-outline-secondary:hover { background-color: #f1f5f9; border-color: #94a3b8; color: #1e293b; }
        footer { background-color: white; border-top: 1px solid #eef2f6; color: #64748b; padding: 2rem 0; margin-top: 3rem; font-size: 0.9rem; }
        .hero { background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%); padding: 3rem 0; margin-bottom: 2rem; border-bottom: 1px solid #e2e8f0; }
        .form-control, .form-select { border-radius: 10px; border: 1px solid #e2e8f0; padding: 0.6rem 1rem; font-size: 0.95rem; }
        .form-control:focus, .form-select:focus { border-color: #3b82f6; box-shadow: 0 0 0 3px rgba(59,130,246,0.1); }
        .alert { border-radius: 12px; border: none; background-color: white; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
        .badge { font-weight: 500; padding: 0.35em 0.8em; border-radius: 30px; }
        .pagination .page-link { border-radius: 8px; margin: 0 3px; color: #475569; border: none; background: white; box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
        .pagination .active .page-link { background-color: #3b82f6; color: white; }
        h1, h2, h3, h4 { font-weight: 600; letter-spacing: -0.02em; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg sticky-top">
        <div class="container">
            <a class="navbar-brand" href="/">BlogMVC</a>
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
                                    <img src="<?php echo asset($_SESSION['user']['avatar']); ?>" class="avatar-sm me-1">
                                <?php else: ?>
                                    <i class="fas fa-user-circle me-1 fs-5"></i>
                                <?php endif; ?>
                                <?php echo htmlspecialchars($_SESSION['user']['name']); ?>
                            </a>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="/profile"><i class="fas fa-user me-2"></i>Perfil</a></li>
                                <li><a class="dropdown-item" href="/profile/edit"><i class="fas fa-pen me-2"></i>Editar perfil</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="#" onclick="document.getElementById('logout-form').submit();"><i class="fas fa-sign-out-alt me-2"></i>Tancar sessió</a></li>
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
    <main>
        <?php require_once $viewPath; ?>
    </main>
    <footer class="text-center">
        <div class="container">
            <p class="mb-0">&copy; <?php echo date('Y'); ?> BlogMVC. Creat amb PHP i arquitectura MVC.</p>
        </div>
    </footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
APP

# Home (index) profesional con hero
cat > src/Views/home/index.php << 'HOME'
<div class="hero">
    <div class="container text-center">
        <h1 class="display-4 fw-bold mb-3">BlogMVC</h1>
        <p class="lead text-secondary mb-4">Comparteix coneixement, aprèn i connecta amb altres professionals.</p>
        <?php if (!isset($_SESSION['user_id'])): ?>
            <a href="/register" class="btn btn-primary btn-lg px-4">Crea un compte</a>
        <?php else: ?>
            <a href="/my-posts/create" class="btn btn-primary btn-lg px-4">Publica un article</a>
        <?php endif; ?>
    </div>
</div>
<div class="container">
    <div class="row justify-content-center mb-5">
        <div class="col-md-6">
            <form action="/search" method="GET" class="d-flex gap-2">
                <input type="search" name="q" class="form-control" placeholder="Cerca articles...">
                <button type="submit" class="btn btn-outline-secondary">Cercar</button>
            </form>
        </div>
    </div>
    <div class="row">
        <?php if (empty($posts['items'])): ?>
            <div class="col-12 text-center py-5"><div class="alert alert-light">Encara no hi ha articles publicats.</div></div>
        <?php else: ?>
            <?php foreach ($posts['items'] as $post): ?>
                <div class="col-md-6 col-lg-4 mb-4">
                    <div class="card h-100">
                        <div class="card-body d-flex flex-column">
                            <h5 class="card-title fw-semibold"><?php echo htmlspecialchars($post['title']); ?></h5>
                            <p class="card-text text-secondary small flex-grow-1"><?php echo truncate(strip_tags($post['excerpt'] ?? $post['content']), 120); ?></p>
                            <div class="d-flex justify-content-between align-items-center mt-3">
                                <div class="small text-secondary">
                                    <i class="fas fa-user me-1"></i><?php echo htmlspecialchars($post['author_name']); ?><br>
                                    <i class="far fa-calendar-alt me-1"></i><?php echo timeAgo($post['published_at']); ?>
                                </div>
                                <a href="/posts/<?php echo $post['slug']; ?>" class="btn btn-sm btn-outline-primary">Llegir</a>
                            </div>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        <?php endif; ?>
    </div>
    <?php if ($posts['last_page'] > 1): ?>
        <nav class="mt-4"><ul class="pagination justify-content-center"><?php for($i=1;$i<=$posts['last_page'];$i++): ?><li class="page-item <?php echo $i==$posts['current_page']?'active':''; ?>"><a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a></li><?php endfor; ?></ul></nav>
    <?php endif; ?>
</div>
HOME

# Login profesional
cat > src/Views/auth/login.php << 'LOGIN'
<?php use Blog\Utils\Flash; ?>
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="card shadow-sm border-0">
                <div class="card-body p-4 p-md-5">
                    <h3 class="text-center mb-4 fw-semibold">Iniciar sessió</h3>
                    <?php Flash::display(); ?>
                    <form method="POST" action="/login">
                        <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                        <div class="mb-3">
                            <label class="form-label fw-medium">Correu electrònic</label>
                            <input type="email" name="email" class="form-control" required autofocus>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-medium">Contrasenya</label>
                            <input type="password" name="password" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 py-2">Accedir</button>
                    </form>
                    <hr class="my-4">
                    <p class="text-center mb-0 text-secondary">No tens compte? <a href="/register" class="text-primary fw-medium text-decoration-none">Registra't</a></p>
                </div>
            </div>
        </div>
    </div>
</div>
LOGIN

# Registro profesional
cat > src/Views/auth/register.php << 'REGISTER'
<?php use Blog\Utils\Flash; ?>
<div class="container py-5">
    <div class="row justify-content-center">
        <div class="col-md-6">
            <div class="card shadow-sm border-0">
                <div class="card-body p-4 p-md-5">
                    <h3 class="text-center mb-4 fw-semibold">Registre d'usuari</h3>
                    <?php Flash::display(); ?>
                    <form method="POST" action="/register">
                        <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                        <div class="mb-3">
                            <label class="form-label fw-medium">Nom complet</label>
                            <input type="text" name="name" class="form-control" required minlength="2" maxlength="50">
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-medium">Correu electrònic</label>
                            <input type="email" name="email" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-medium">Contrasenya</label>
                            <input type="password" name="password" class="form-control" required minlength="8">
                            <div class="form-text text-secondary small">Mínim 8 caràcters, una majúscula i un número</div>
                        </div>
                        <div class="mb-4">
                            <label class="form-label fw-medium">Confirmar contrasenya</label>
                            <input type="password" name="password_confirm" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 py-2">Registrar-se</button>
                    </form>
                    <hr class="my-4">
                    <p class="text-center mb-0 text-secondary">Ja tens compte? <a href="/login" class="text-primary fw-medium text-decoration-none">Inicia sessió</a></p>
                </div>
            </div>
        </div>
    </div>
</div>
REGISTER

# Mejora también la lista de posts y demás (por consistencia)
cat > src/Views/posts/index.php << 'POSTSINDEX'
<div class="container py-4">
    <h1 class="mb-4 fw-semibold">Tots els articles</h1>
    <div class="row">
        <?php foreach ($posts['items'] as $post): ?>
            <div class="col-md-4 mb-4">
                <div class="card h-100">
                    <div class="card-body">
                        <h5 class="card-title fw-semibold"><?php echo htmlspecialchars($post['title']); ?></h5>
                        <p class="card-text text-secondary small"><?php echo truncate(strip_tags($post['content']), 100); ?></p>
                        <div class="mt-auto"><a href="/posts/<?php echo $post['slug']; ?>" class="btn btn-sm btn-outline-primary">Llegir</a></div>
                    </div>
                    <div class="card-footer bg-transparent border-top-0 text-secondary small"><?php echo $post['author_name']; ?> · <?php echo timeAgo($post['published_at']); ?></div>
                </div>
            </div>
        <?php endforeach; ?>
    </div>
    <?php if ($posts['last_page']>1): ?>
        <nav><ul class="pagination justify-content-center"><?php for($i=1;$i<=$posts['last_page'];$i++): ?><li class="page-item <?php echo $i==$posts['current_page']?'active':''; ?>"><a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a></li><?php endfor; ?></ul></nav>
    <?php endif; ?>
</div>
POSTSINDEX

# show post
cat > src/Views/posts/show.php << 'SHOW'
<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <article class="card border-0 shadow-sm">
                <div class="card-body p-4 p-lg-5">
                    <h1 class="fw-bold mb-3"><?php echo htmlspecialchars($post['title']); ?></h1>
                    <div class="text-secondary mb-4 pb-2 border-bottom">
                        <i class="fas fa-user me-1"></i> <?php echo htmlspecialchars($post['author_name']); ?>
                        <span class="mx-2">·</span>
                        <i class="far fa-calendar-alt me-1"></i> <?php echo timeAgo($post['published_at']); ?>
                        <span class="mx-2">·</span>
                        <i class="fas fa-eye me-1"></i> <?php echo $post['views_count']; ?> visualitzacions
                    </div>
                    <div class="post-content fs-5"><?php echo $post['content']; ?></div>
                    <div class="mt-5"><a href="/posts" class="btn btn-outline-secondary"><i class="fas fa-arrow-left me-2"></i>Tornar als articles</a></div>
                </div>
            </article>
        </div>
    </div>
</div>
SHOW

echo -e "\n✅ Disseny professional aplicat a totes les vistes."
