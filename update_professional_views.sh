#!/bin/bash

# Actualizar layout principal (app.php) - sin emoticonos
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
        :root { --primary: #2c3e50; --secondary: #3498db; --light: #ecf0f1; }
        body { background-color: #f8f9fa; font-family: 'Segoe UI', Roboto, sans-serif; }
        .navbar { background-color: var(--primary) !important; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .navbar-brand { font-weight: 600; letter-spacing: -0.5px; }
        .post-card { transition: all 0.2s ease; border: none; box-shadow: 0 1px 3px rgba(0,0,0,0.05); margin-bottom: 1.5rem; }
        .post-card:hover { transform: translateY(-3px); box-shadow: 0 4px 12px rgba(0,0,0,0.1); }
        .avatar-sm { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; margin-right: 8px; }
        .avatar-md { width: 100px; height: 100px; border-radius: 50%; object-fit: cover; margin-bottom: 1rem; }
        .btn-primary { background-color: var(--secondary); border-color: var(--secondary); }
        .btn-primary:hover { background-color: #2980b9; border-color: #2980b9; }
        footer { background-color: var(--primary); color: white; padding: 1.5rem 0; margin-top: 3rem; }
        .breadcrumb { background: transparent; padding: 0.5rem 0; }
        .alert { border-radius: 0; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark">
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
    <main class="container my-4">
        <?php require_once $viewPath; ?>
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

# Actualizar home/index.php (sin emoticonos, más profesional)
cat > src/Views/home/index.php << 'HOME'
<div class="row">
    <div class="col-12 text-center mb-5">
        <h1 class="display-5 fw-normal">Blog MVC</h1>
        <p class="lead">Comparteix coneixement, aprèn i connecta amb altres professionals.</p>
        <?php if (!isset($_SESSION['user_id'])): ?>
            <a href="/register" class="btn btn-primary btn-lg">Crea un compte</a>
        <?php else: ?>
            <a href="/my-posts/create" class="btn btn-primary btn-lg">Publica un article</a>
        <?php endif; ?>
    </div>
    <div class="col-12 mb-4">
        <form action="/search" method="GET" class="d-flex">
            <input type="search" name="q" class="form-control me-2" placeholder="Cerca articles...">
            <button type="submit" class="btn btn-outline-secondary">Cercar</button>
        </form>
    </div>
    <?php if (empty($posts['items'])): ?>
        <div class="col-12"><div class="alert alert-info">Encara no hi ha articles publicats.</div></div>
    <?php else: ?>
        <?php foreach ($posts['items'] as $post): ?>
            <div class="col-md-6 col-lg-4">
                <div class="card post-card h-100">
                    <div class="card-body">
                        <h5 class="card-title"><?php echo htmlspecialchars($post['title']); ?></h5>
                        <p class="card-text text-muted"><?php echo truncate(strip_tags($post['excerpt'] ?? $post['content']), 120); ?></p>
                        <div class="d-flex justify-content-between align-items-center">
                            <small class="text-secondary">
                                <?php echo htmlspecialchars($post['author_name']); ?><br>
                                <?php echo timeAgo($post['published_at']); ?>
                            </small>
                            <a href="/posts/<?php echo $post['slug']; ?>" class="btn btn-sm btn-outline-primary">Llegir</a>
                        </div>
                    </div>
                </div>
            </div>
        <?php endforeach; ?>
    <?php endif; ?>
    <?php if ($posts['last_page'] > 1): ?>
        <nav class="mt-4"><ul class="pagination justify-content-center"><?php for($i=1;$i<=$posts['last_page'];$i++): ?><li class="page-item <?php echo $i==$posts['current_page']?'active':''; ?>"><a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a></li><?php endfor; ?></ul></nav>
    <?php endif; ?>
</div>
HOME

# Actualizar auth/login.php
cat > src/Views/auth/login.php << 'LOGIN'
<?php use Blog\Utils\Flash; ?>
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card shadow-sm">
            <div class="card-header bg-white py-3"><h4 class="mb-0">Iniciar sessió</h4></div>
            <div class="card-body">
                <?php Flash::display(); ?>
                <form method="POST" action="/login">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    <div class="mb-3"><label class="form-label">Correu electrònic</label><input type="email" name="email" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">Contrasenya</label><input type="password" name="password" class="form-control" required></div>
                    <button type="submit" class="btn btn-primary w-100">Accedir</button>
                </form>
                <hr class="my-4">
                <p class="text-center mb-0">No tens compte? <a href="/register">Registra't</a></p>
            </div>
        </div>
    </div>
</div>
LOGIN

# Actualizar auth/register.php
cat > src/Views/auth/register.php << 'REGISTER'
<?php use Blog\Utils\Flash; ?>
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card shadow-sm">
            <div class="card-header bg-white py-3"><h4 class="mb-0">Registre d'usuari</h4></div>
            <div class="card-body">
                <?php Flash::display(); ?>
                <form method="POST" action="/register">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    <div class="mb-3"><label class="form-label">Nom complet</label><input type="text" name="name" class="form-control" required minlength="2" maxlength="50"></div>
                    <div class="mb-3"><label class="form-label">Correu electrònic</label><input type="email" name="email" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">Contrasenya</label><input type="password" name="password" class="form-control" required minlength="8"><small class="text-muted">Mínim 8 caràcters, una majúscula i un número</small></div>
                    <div class="mb-3"><label class="form-label">Confirmar contrasenya</label><input type="password" name="password_confirm" class="form-control" required></div>
                    <button type="submit" class="btn btn-primary w-100">Registrar-se</button>
                </form>
                <hr class="my-4">
                <p class="text-center mb-0">Ja tens compte? <a href="/login">Inicia sessió</a></p>
            </div>
        </div>
    </div>
</div>
REGISTER

# Actualizar posts/my-posts.php (eliminar emoticonos, mejorar tabla)
cat > src/Views/posts/my-posts.php << 'MYPOSTS'
<div class="d-flex justify-content-between align-items-center mb-4">
    <h2>Els meus articles</h2>
    <a href="/my-posts/create" class="btn btn-primary">+ Nou article</a>
</div>
<?php if (empty($posts['items'])): ?>
    <div class="alert alert-info">No tens cap article. Crea el teu primer article!</div>
<?php else: ?>
    <div class="table-responsive">
        <table class="table table-hover align-middle">
            <thead class="table-light">
                <tr><th>Títol</th><th>Estat</th><th>Visualitzacions</th><th>Creat</th><th>Accions</th></tr>
            </thead>
            <tbody>
                <?php foreach ($posts['items'] as $post): ?>
                <tr>
                    <td><?php echo htmlspecialchars($post['title']); ?></td>
                    <td><span class="badge bg-<?php echo $post['status']=='published'?'success':'secondary'; ?>"><?php echo $post['status']; ?></span></td>
                    <td><?php echo $post['views_count']; ?></td>
                    <td><?php echo timeAgo($post['created_at']); ?></td>
                    <td>
                        <a href="/my-posts/<?php echo $post['id']; ?>/edit" class="btn btn-sm btn-outline-warning">Editar</a>
                        <form method="POST" action="/my-posts/<?php echo $post['id']; ?>/publish" style="display:inline-block">
                            <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                            <button type="submit" class="btn btn-sm btn-outline-info"><?php echo $post['status']=='published'?'Despublicar':'Publicar'; ?></button>
                        </form>
                        <form method="POST" action="/my-posts/<?php echo $post['id']; ?>/delete" style="display:inline-block" onsubmit="return confirm('Segur que vols eliminar aquest article?');">
                            <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                            <button type="submit" class="btn btn-sm btn-outline-danger">Eliminar</button>
                        </form>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
    <?php if ($posts['last_page'] > 1): ?>
        <nav><ul class="pagination justify-content-center"><?php for($i=1;$i<=$posts['last_page'];$i++): ?><li class="page-item <?php echo $i==$posts['current_page']?'active':''; ?>"><a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a></li><?php endfor; ?></ul></nav>
    <?php endif; ?>
<?php endif; ?>
MYPOSTS

# Actualizar posts/create.php y edit.php (sin emoticonos)
cat > src/Views/posts/create.php << 'CREATE'
<div class="row justify-content-center">
    <div class="col-md-8">
        <h2 class="mb-4">Crear article</h2>
        <?php use Blog\Utils\Flash; Flash::display(); ?>
        <form method="POST" action="/my-posts">
            <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
            <div class="mb-3"><label class="form-label">Títol</label><input type="text" name="title" class="form-control" required minlength="5"></div>
            <div class="mb-3"><label class="form-label">Contingut</label><textarea name="content" rows="10" class="form-control" required minlength="50"></textarea></div>
            <div class="mb-3"><label class="form-label">Estat</label><select name="status" class="form-select"><option value="draft">Esborrany</option><option value="published">Publicar</option></select></div>
            <button type="submit" class="btn btn-primary">Guardar</button>
            <a href="/my-posts" class="btn btn-secondary">Cancel·lar</a>
        </form>
    </div>
</div>
CREATE

cat > src/Views/posts/edit.php << 'EDIT'
<div class="row justify-content-center">
    <div class="col-md-8">
        <h2 class="mb-4">Editar article</h2>
        <?php use Blog\Utils\Flash; Flash::display(); ?>
        <form method="POST" action="/my-posts/<?php echo $post['id']; ?>/update">
            <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
            <div class="mb-3"><label class="form-label">Títol</label><input type="text" name="title" value="<?php echo htmlspecialchars($post['title']); ?>" class="form-control" required minlength="5"></div>
            <div class="mb-3"><label class="form-label">Contingut</label><textarea name="content" rows="10" class="form-control" required minlength="50"><?php echo htmlspecialchars($post['content']); ?></textarea></div>
            <div class="mb-3"><label class="form-label">Estat</label><select name="status" class="form-select"><option value="draft" <?php echo $post['status']=='draft'?'selected':''; ?>>Esborrany</option><option value="published" <?php echo $post['status']=='published'?'selected':''; ?>>Publicat</option></select></div>
            <button type="submit" class="btn btn-primary">Actualitzar</button>
            <a href="/my-posts" class="btn btn-secondary">Cancel·lar</a>
        </form>
    </div>
</div>
EDIT

# Actualizar perfil (user/profile.php)
cat > src/Views/user/profile.php << 'PROFILE'
<div class="row">
    <div class="col-md-4">
        <div class="card shadow-sm text-center">
            <div class="card-body">
                <?php if ($user['avatar']): ?>
                    <img src="<?php echo asset($user['avatar']); ?>" class="avatar-md">
                <?php else: ?>
                    <i class="fas fa-user-circle fa-5x text-secondary"></i>
                <?php endif; ?>
                <h3 class="mt-2"><?php echo htmlspecialchars($user['name']); ?></h3>
                <p class="text-muted"><?php echo htmlspecialchars($user['email']); ?></p>
                <a href="/profile/edit" class="btn btn-outline-primary">Editar perfil</a>
            </div>
        </div>
    </div>
    <div class="col-md-8">
        <div class="card shadow-sm">
            <div class="card-header bg-white"><h5 class="mb-0">Estadístiques</h5></div>
            <div class="card-body">
                <p><strong>Total d'articles:</strong> <?php echo $stats['total_posts']; ?></p>
                <p><strong>Visualitzacions totals:</strong> <?php echo $stats['total_views']; ?></p>
                <p><strong>Membre des de:</strong> <?php echo date('d/m/Y', strtotime($user['created_at'])); ?></p>
                <?php if ($user['bio']): ?>
                    <hr><h6>Biografia</h6><p><?php echo nl2br(htmlspecialchars($user['bio'])); ?></p>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>
PROFILE

echo -e "\n✅ Vistes actualitzades amb disseny professional."
