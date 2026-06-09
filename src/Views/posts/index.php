<div class="row">
    <div class="col-12"><h1 class="mb-4 fw-semibold">Tots els articles</h1></div>
</div>
<div class="row">
    <?php foreach ($posts['items'] as $post): ?>
        <div class="col-md-4 mb-4">
            <div class="card h-100 border-0 shadow-sm rounded-4">
                <div class="card-body">
                    <h5 class="card-title fw-semibold"><?php echo htmlspecialchars($post['title']); ?></h5>
                    <p class="card-text text-secondary"><?php echo truncate(strip_tags($post['content']), 100); ?></p>
                    <a href="/posts/<?php echo $post['slug']; ?>" class="btn btn-sm btn-outline-primary rounded-pill">Llegir</a>
                </div>
                <div class="card-footer bg-transparent border-0 text-secondary small"><?php echo $post['author_name']; ?> · <?php echo timeAgo($post['published_at']); ?></div>
            </div>
        </div>
    <?php endforeach; ?>
</div>
<?php if ($posts['last_page'] > 1): ?>
    <nav><ul class="pagination justify-content-center"><?php for($i=1;$i<=$posts['last_page'];$i++): ?><li class="page-item <?php echo $i==$posts['current_page']?'active':''; ?>"><a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a></li><?php endfor; ?></ul></nav>
<?php endif; ?>
