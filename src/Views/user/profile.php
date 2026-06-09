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
