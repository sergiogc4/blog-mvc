<?php
use Blog\Utils\Flash;
?>
<div class="text-center mb-4">
    <i class="fas fa-user-plus fa-3x text-primary"></i>
    <h2>Registre d'Usuari</h2>
</div>

<?php Flash::display(); ?>

<form method="POST" action="/register">
    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
    
    <div class="mb-3">
        <label for="name" class="form-label">Nom complet</label>
        <input type="text" class="form-control" id="name" name="name" required minlength="2" maxlength="50">
    </div>
    
    <div class="mb-3">
        <label for="email" class="form-label">Email</label>
        <input type="email" class="form-control" id="email" name="email" required>
    </div>
    
    <div class="mb-3">
        <label for="password" class="form-label">Contrasenya</label>
        <input type="password" class="form-control" id="password" name="password" required minlength="8">
        <div class="form-text">Mínim 8 caràcters, 1 majúscula i 1 número</div>
    </div>
    
    <div class="mb-3">
        <label for="password_confirm" class="form-label">Confirmar contrasenya</label>
        <input type="password" class="form-control" id="password_confirm" name="password_confirm" required>
    </div>
    
    <button type="submit" class="btn btn-primary w-100">Registrar-se</button>
</form>

<div class="text-center mt-3">
    <p>Ja tens compte? <a href="/login">Inicia sessió</a></p>
</div>
