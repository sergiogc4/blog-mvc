<?php
use Blog\Utils\Flash;
?>
<div class="text-center mb-4">
    <i class="fas fa-sign-in-alt fa-3x text-primary"></i>
    <h2>Iniciar Sessió</h2>
</div>

<?php Flash::display(); ?>

<form method="POST" action="/login">
    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
    
    <div class="mb-3">
        <label for="email" class="form-label">Email</label>
        <input type="email" class="form-control" id="email" name="email" required>
    </div>
    
    <div class="mb-3">
        <label for="password" class="form-label">Contrasenya</label>
        <input type="password" class="form-control" id="password" name="password" required>
    </div>
    
    <button type="submit" class="btn btn-primary w-100">Iniciar Sessió</button>
</form>

<div class="text-center mt-3">
    <p>No tens compte? <a href="/register">Registra't aquí</a></p>
</div>
