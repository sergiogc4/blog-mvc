#!/bin/bash

# Reemplazar login.php
cat > src/Views/auth/login.php << 'LOGIN'
<?php use Blog\Utils\Flash; ?>
<div class="row justify-content-center align-items-center min-vh-50">
    <div class="col-md-5">
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4 p-md-5">
                <h2 class="text-center mb-4 fw-semibold">Iniciar sessió</h2>
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

# Reemplazar register.php
cat > src/Views/auth/register.php << 'REGISTER'
<?php use Blog\Utils\Flash; ?>
<div class="row justify-content-center align-items-center min-vh-50">
    <div class="col-md-6">
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4 p-md-5">
                <h2 class="text-center mb-4 fw-semibold">Registre d'usuari</h2>
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

echo "✅ Vistes de login i registre corregides (disseny net i centrat)."
echo "🔄 Reinicia el servidor si està en marxa (Ctrl+C i php -S localhost:8000 -t public)"
