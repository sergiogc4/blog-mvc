#!/bin/bash

# Crear vista de detalle simple y limpia
cat > src/Views/posts/show.php << 'SHOW'
<div class="row justify-content-center">
    <div class="col-lg-8">
        <article class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4 p-lg-5">
                <h1 class="fw-bold mb-3"><?php echo htmlspecialchars($post['title']); ?></h1>
                <div class="text-secondary mb-4 pb-2 border-bottom">
                    <i class="fas fa-user me-1"></i> <?php echo htmlspecialchars($post['author_name']); ?>
                    <span class="mx-2">·</span>
                    <i class="far fa-calendar-alt me-1"></i> <?php echo timeAgo($post['published_at']); ?>
                    <span class="mx-2">·</span>
                    <i class="fas fa-eye me-1"></i> <?php echo $post['views_count']; ?> visualitzacions
                </div>
                <div class="fs-5 lh-base mb-5">
                    <?php echo $post['content']; ?>
                </div>
                <a href="/posts" class="btn btn-outline-secondary rounded-pill px-4">
                    <i class="fas fa-arrow-left me-2"></i>Tornar als articles
                </a>
            </div>
        </article>
    </div>
</div>
SHOW

echo "✅ Vista de detalle simple creada/actualizada."
echo "🔄 Reinicia el servidor si es necesario y prueba un post."
