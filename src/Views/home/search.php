<div class="row">
    <div class="col-12"><h2>Resultats: "<?php echo htmlspecialchars($query); ?>"</h2><p><?php echo $posts['total']; ?> resultats</p><a href="/" class="btn btn-secondary mb-4"><i class="fas fa-arrow-left"></i> Tornar</a></div>
    <?php foreach ($posts['items'] as $post): ?>
        <div class="col-md-6 col-lg-4"><div class="card post-card h-100"><div class="card-body"><h5><?php echo htmlspecialchars($post['title']); ?></h5><p><?php echo truncate(strip_tags($post['content']), 120); ?></p><a href="/posts/<?php echo $post['slug']; ?>" class="btn btn-primary">Llegir</a></div></div></div>
    <?php endforeach; ?>
</div>
