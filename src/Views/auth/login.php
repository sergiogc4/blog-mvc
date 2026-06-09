<?php use Blog\Utils\Flash; ?>
<div class="row justify-content-center">
    <div class="col-md-5">
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4">
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
                <p class="text-center mb-0">No tens compte? <a href="/register">Registra't</a></p>
            </div>
        </div>
    </div>
</div>
