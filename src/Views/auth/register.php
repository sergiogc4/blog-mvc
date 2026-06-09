<?php use Blog\Utils\Flash; ?>
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4">
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
                        <div class="form-text text-secondary">Mínim 8 caràcters, una majúscula i un número</div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-medium">Confirmar contrasenya</label>
                        <input type="password" name="password_confirm" class="form-control" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 py-2 rounded-pill">Registrar-se</button>
                </form>
                <hr class="my-4">
                <p class="text-center mb-0">Ja tens compte? <a href="/login">Inicia sessió</a></p>
            </div>
        </div>
    </div>
</div>
