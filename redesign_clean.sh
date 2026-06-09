#!/bin/bash

# Layout principal (limpio, navbar blanca, sin fondos de color)
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
        body {
            background-color: #ffffff;
            font-family: system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
            color: #1e293b;
            line-height: 1.5;
        }
        .navbar {
            background-color: #ffffff;
            border-bottom: 1px solid #e9ecef;
            padding: 0.75rem 0;
        }
        .navbar-brand {
            font-weight: 600;
            font-size: 1.35rem;
            color: #0f172a;
        }
        .nav-link {
            color: #475569;
            font-weight: 500;
        }
        .nav-link:hover {
            color: #3b82f6;
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
            box-shadow: 0 1px 2px rgba(0,0,0,0.03);
            transition: box-shadow 0.2s ease;
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
        .btn-outline-primary {
            border-radius: 40px;
            border-color: #cbd5e1;
            color: #1e293b;
        }
        .btn-outline-primary:hover {
            background-color: #f8fafc;
            border-color: #94a3b8;
        }
        .form-control, .form-select {
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            padding: 0.6rem 1rem;
        }
        .form-control:focus, .form-select:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 0 3px rgba(59,130,246,0.1);
        }
        footer {
            background-color: #f8fafc;
            border-top: 1px solid #eef2f6;
            padding: 2rem 0;
            margin-top: 4rem;
            color: #475569;
            font-size: 0.875rem;
        }
        .hero {
            text-align: center;
            padding: 3rem 0 2rem 0;
        }
        .badge {
            font-weight: 500;
            border-radius: 30px;
            padding: 0.3rem 0.8rem;
        }
        .pagination .page-link {
            border-radius: 30px;
            margin: 0 4px;
            border: none;
            color: #1e293b;
            background: #f1f5f9;
        }
        .pagination .active .page-link {
            background: #3b82f6;
            color: white;
        }
        h1, h2, h3, h4 {
            font-weight: 600;
            letter-spacing: -0.02em;
        }
        .text-secondary {
            color: #475569 !important;
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
                                <li><a class="dropdown-item" href="/profile">Perfil</a></li>
                                <li><a class="dropdown-item" href="/profile/edit">Editar perfil</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="#" onclick="document.getElementById('logout-form').submit();">Tancar sessió</a></li>
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

# Home (index) – limpia, con hero sutil
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
                        <p class="card-text text-secondary small flex-grow-1"><?php echo truncate(strip_tags($post['excerpt'] ?? $post['content']), 120); ?></p>
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
    <nav class="mt-4"><ul class="pagination justify-content-center"><?php for($i=1;$i<=$posts['last_page'];$i++): ?><li class="page-item <?php echo $i==$posts['current_page']?'active':''; ?>"><a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a></li><?php endfor; ?></ul></nav>
<?php endif; ?>
HOME

# Login – limpio, sin fondo de color, solo tarjeta blanca
cat > src/Views/auth/login.php << 'LOGIN'
<?php use Blog\Utils\Flash; ?>
<div class="row justify-content-center">
    <div class="col-md-5">
        <div class="card border-0 shadow-sm">
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
                    <button type="submit" class="btn btn-primary w-100 py-2 rounded-pill">Accedir</button>
                </form>
                <hr class="my-4">
                <p class="text-center mb-0 text-secondary">No tens compte? <a href="/register" class="text-decoration-none fw-medium">Registra't</a></p>
            </div>
        </div>
    </div>
</div>
LOGIN

# Registro – idéntico estilo limpio
cat > src/Views/auth/register.php << 'REGISTER'
<?php use Blog\Utils\Flash; ?>
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card border-0 shadow-sm">
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
                    <button type="submit" class="btn btn-primary w-100 py-2 rounded-pill">Registrar-se</button>
                </form>
                <hr class="my-4">
                <p class="text-center mb-0 text-secondary">Ja tens compte? <a href="/login" class="text-decoration-none fw-medium">Inicia sessió</a></p>
            </div>
        </div>
    </div>
</div>
REGISTER

# Vista de listado de todos los posts (limpia)
cat > src/Views/posts/index.php << 'POSTS'
<div class="row">
    <div class="col-12">
        <h1 class="mb-4 fw-semibold">Tots els articles</h1>
    </div>
</div>
<div class="row">
    <?php foreach ($posts['items'] as $post): ?>
        <div class="col-md-4 mb-4">
            <div class="card h-100">
                <div class="card-body">
                    <h5 class="card-title fw-semibold"><?php echo htmlspecialchars($post['title']); ?></h5>
                    <p class="card-text text-secondary small"><?php echo truncate(strip_tags($post['content']), 100); ?></p>
                    <a href="/posts/<?php echo $post['slug']; ?>" class="btn btn-sm btn-outline-primary rounded-pill mt-auto">Llegir</a>
                </div>
                <div class="card-footer bg-transparent border-top-0 text-secondary small"><?php echo $post['author_name']; ?> · <?php echo timeAgo($post['published_at']); ?></div>
            </div>
        </div>
    <?php endforeach; ?>
</div>
<?php if ($posts['last_page']>1): ?>
    <nav><ul class="pagination justify-content-center"><?php for($i=1;$i<=$posts['last_page'];$i++): ?><li class="page-item <?php echo $i==$posts['current_page']?'active':''; ?>"><a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a></li><?php endfor; ?></ul></nav>
<?php endif; ?>
POSTS

# Vista de artículo individual
cat > src/Views/posts/show.php << 'SHOW'
<div class="row justify-content-center">
    <div class="col-lg-8">
        <article class="card border-0 shadow-sm">
            <div class="card-body p-4 p-lg-5">
                <h1 class="fw-semibold mb-3"><?php echo htmlspecialchars($post['title']); ?></h1>
                <div class="text-secondary mb-4 pb-2 border-bottom">
                    <?php echo htmlspecialchars($post['author_name']); ?> · <?php echo timeAgo($post['published_at']); ?> · <?php echo $post['views_count']; ?> visualitzacions
                </div>
                <div class="post-content"><?php echo $post['content']; ?></div>
                <div class="mt-5"><a href="/posts" class="btn btn-outline-secondary rounded-pill"><i class="fas fa-arrow-left me-2"></i>Tornar</a></div>
            </div>
        </article>
    </div>
</div>
SHOW

# Mis posts – dashboard limpio
cat > src/Views/posts/my-posts.php << 'MYPOSTS'
<div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="fw-semibold">Els meus articles</h2>
    <a href="/my-posts/create" class="btn btn-primary rounded-pill px-4">+ Nou article</a>
</div>
<?php if (empty($posts['items'])): ?>
    <div class="alert alert-light border text-secondary">No tens cap article. Crea el teu primer article!</div>
<?php else: ?>
    <div class="table-responsive">
        <table class="table align-middle">
            <thead class="table-light">
                <tr><th>Títol</th><th>Estat</th><th>Visualitzacions</th><th>Creat</th><th>Accions</th></tr>
            </thead>
            <tbody>
                <?php foreach ($posts['items'] as $post): ?>
                <tr>
                    <td><strong><?php echo htmlspecialchars($post['title']); ?></strong></td>
                    <td><span class="badge bg-<?php echo $post['status']=='published'?'success':'secondary'; ?>"><?php echo $post['status']; ?></span></td>
                    <td><?php echo $post['views_count']; ?></td>
                    <td><?php echo timeAgo($post['created_at']); ?></td>
                    <td>
                        <a href="/my-posts/<?php echo $post['id']; ?>/edit" class="btn btn-sm btn-outline-warning rounded-pill">Editar</a>
                        <form method="POST" action="/my-posts/<?php echo $post['id']; ?>/publish" style="display:inline-block">
                            <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                            <button type="submit" class="btn btn-sm btn-outline-info rounded-pill"><?php echo $post['status']=='published'?'Despublicar':'Publicar'; ?></button>
                        </form>
                        <form method="POST" action="/my-posts/<?php echo $post['id']; ?>/delete" style="display:inline-block" onsubmit="return confirm('Segur que vols eliminar aquest article?');">
                            <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                            <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill">Eliminar</button>
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

# Crear/Editar post – formularios simples
cat > src/Views/posts/create.php << 'CREATE'
<div class="row justify-content-center">
    <div class="col-md-8">
        <h2 class="mb-4 fw-semibold">Crear article</h2>
        <?php use Blog\Utils\Flash; Flash::display(); ?>
        <form method="POST" action="/my-posts">
            <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
            <div class="mb-3"><label class="form-label fw-medium">Títol</label><input type="text" name="title" class="form-control" required minlength="5"></div>
            <div class="mb-3"><label class="form-label fw-medium">Contingut</label><textarea name="content" rows="10" class="form-control" required minlength="50"></textarea></div>
            <div class="mb-3"><label class="form-label fw-medium">Estat</label><select name="status" class="form-select"><option value="draft">Esborrany</option><option value="published">Publicar</option></select></div>
            <div><button type="submit" class="btn btn-primary rounded-pill px-4">Guardar</button> <a href="/my-posts" class="btn btn-outline-secondary rounded-pill">Cancel·lar</a></div>
        </form>
    </div>
</div>
CREATE

cat > src/Views/posts/edit.php << 'EDIT'
<div class="row justify-content-center">
    <div class="col-md-8">
        <h2 class="mb-4 fw-semibold">Editar article</h2>
        <?php use Blog\Utils\Flash; Flash::display(); ?>
        <form method="POST" action="/my-posts/<?php echo $post['id']; ?>/update">
            <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
            <div class="mb-3"><label class="form-label fw-medium">Títol</label><input type="text" name="title" value="<?php echo htmlspecialchars($post['title']); ?>" class="form-control" required minlength="5"></div>
            <div class="mb-3"><label class="form-label fw-medium">Contingut</label><textarea name="content" rows="10" class="form-control" required minlength="50"><?php echo htmlspecialchars($post['content']); ?></textarea></div>
            <div class="mb-3"><label class="form-label fw-medium">Estat</label><select name="status" class="form-select"><option value="draft" <?php echo $post['status']=='draft'?'selected':''; ?>>Esborrany</option><option value="published" <?php echo $post['status']=='published'?'selected':''; ?>>Publicat</option></select></div>
            <div><button type="submit" class="btn btn-primary rounded-pill px-4">Actualitzar</button> <a href="/my-posts" class="btn btn-outline-secondary rounded-pill">Cancel·lar</a></div>
        </form>
    </div>
</div>
EDIT

# Perfil de usuario – limpio
cat > src/Views/user/profile.php << 'PROFILE'
<div class="row">
    <div class="col-md-4 text-center">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <?php if ($user['avatar']): ?>
                    <img src="<?php echo asset($user['avatar']); ?>" class="avatar-md mb-3">
                <?php else: ?>
                    <i class="fas fa-user-circle fa-5x text-secondary mb-3"></i>
                <?php endif; ?>
                <h3 class="fw-semibold"><?php echo htmlspecialchars($user['name']); ?></h3>
                <p class="text-secondary"><?php echo htmlspecialchars($user['email']); ?></p>
                <a href="/profile/edit" class="btn btn-outline-primary rounded-pill">Editar perfil</a>
            </div>
        </div>
    </div>
    <div class="col-md-8">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-transparent border-0 pt-4"><h5 class="fw-semibold mb-0">Estadístiques</h5></div>
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

# Editar perfil
cat > src/Views/user/edit.php << 'EDITPROFILE'
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card border-0 shadow-sm">
            <div class="card-body p-4">
                <h3 class="mb-4 fw-semibold">Editar perfil</h3>
                <?php use Blog\Utils\Flash; Flash::display(); ?>
                <form method="POST" action="/profile/update">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    <div class="mb-3"><label class="form-label fw-medium">Nom</label><input type="text" name="name" value="<?php echo htmlspecialchars($user['name']); ?>" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label fw-medium">Biografia</label><textarea name="bio" rows="5" class="form-control"><?php echo htmlspecialchars($user['bio']); ?></textarea></div>
                    <button type="submit" class="btn btn-primary rounded-pill px-4">Guardar canvis</button>
                    <a href="/profile" class="btn btn-outline-secondary rounded-pill">Cancel·lar</a>
                </form>
                <hr class="my-4">
                <h5>Canviar avatar</h5>
                <form method="POST" action="/profile/avatar" enctype="multipart/form-data">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    <div class="mb-3"><label class="form-label">Imatge (JPG, PNG, GIF, WEBP, màxim 5MB)</label><input type="file" name="avatar" class="form-control" accept="image/*" required></div>
                    <button type="submit" class="btn btn-outline-primary rounded-pill">Pujar avatar</button>
                </form>
            </div>
        </div>
    </div>
</div>
EDITPROFILE

echo -e "\n✅ Disseny net, professional i coherent aplicat a totes les vistes."
