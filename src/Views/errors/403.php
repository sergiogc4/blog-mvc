<?php $this->setLayout('app'); ?>

<div class="text-center py-5">
    <h1 class="display-1">403</h1>
    <h2 class="mb-4">Acceso Denegado</h2>
    <p class="lead mb-4">No tienes permiso para acceder a esta página.</p>
    <div class="d-flex justify-content-center gap-3">
        <a href="<?= $this->url() ?>" class="btn btn-primary">Volver al inicio</a>
        <a href="javascript:history.back()" class="btn btn-outline-primary">Volver atrás</a>
    </div>
</div>