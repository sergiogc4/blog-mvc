<?php $this->setLayout('app'); ?>

<div class="text-center py-5">
    <h1 class="display-1">500</h1>
    <h2 class="mb-4">Error del Servidor</h2>
    <p class="lead mb-4">Ha ocurrido un error interno en el servidor.</p>
    
    <?php if ($this->config['debug'] && isset($error)): ?>
        <div class="alert alert-danger text-start mb-4">
            <h5>Detalles del error:</h5>
            <pre class="mb-0"><?= $this->escape($error) ?></pre>
        </div>
    <?php endif; ?>
    
    <a href="<?= $this->url() ?>" class="btn btn-primary">Volver al inicio</a>
</div>