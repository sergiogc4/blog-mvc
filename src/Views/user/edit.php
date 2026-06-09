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
