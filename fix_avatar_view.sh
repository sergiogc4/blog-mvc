#!/bin/bash

# 1. Asegurar que la vista de edición de perfil tiene el formulario de avatar
cat > src/Views/user/edit.php << 'EDITPROFILE'
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card border-0 shadow-sm">
            <div class="card-body p-4">
                <h3 class="mb-4 fw-semibold">Editar perfil</h3>
                <?php use Blog\Utils\Flash; Flash::display(); ?>
                <form method="POST" action="/profile/update">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    <div class="mb-3">
                        <label class="form-label fw-medium">Nom</label>
                        <input type="text" name="name" value="<?php echo htmlspecialchars($user['name']); ?>" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Biografia</label>
                        <textarea name="bio" rows="5" class="form-control"><?php echo htmlspecialchars($user['bio']); ?></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary rounded-pill px-4">Guardar canvis</button>
                    <a href="/profile" class="btn btn-outline-secondary rounded-pill">Cancel·lar</a>
                </form>

                <hr class="my-4">

                <h5 class="mb-3">Canviar avatar</h5>
                <form method="POST" action="/profile/avatar" enctype="multipart/form-data">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    <div class="mb-3">
                        <label class="form-label">Imatge (JPG, PNG, GIF, WEBP, màxim 5MB)</label>
                        <input type="file" name="avatar" class="form-control" accept="image/*" required>
                    </div>
                    <button type="submit" class="btn btn-outline-primary rounded-pill">Pujar avatar</button>
                </form>
            </div>
        </div>
    </div>
</div>
EDITPROFILE

# 2. Asegurar que la vista de perfil (profile.php) muestra el avatar correctamente
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

echo "✅ Vistes de perfil actualitzades. Ara el formulari d'avatar es veurà correctament."
echo "🔄 Reinicia el servidor (Ctrl+C i després /usr/bin/php8.2 -S localhost:8000 -t public)"
