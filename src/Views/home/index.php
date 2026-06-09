<div class="hero">
    <h1 class="display-5 fw-semibold">Blog MVC</h1>
    <p class="lead text-secondary mt-2">Comparteix coneixement, aprèn i connecta.</p>
    <?php if (!isset($_SESSION['user_id'])): ?>
        <a href="/register" class="btn btn-primary mt-3 px-4">Crea un compte</a>
    <?php else: ?>
        <a href="/my-posts/create" class="btn btn-primary mt-3 px-4">Publica un article</a>
    <?php endif; ?>
</div>

<div class="row justify-content-center mb-5">
    <div class="col-md-6">
        <form action="/search" method="GET" class="d-flex gap-2">
            <input type="search" name="q" class="form-control" placeholder="Cerca articles...">
            <button type="submit" class="btn btn-outline-primary">Cercar</button>
        </form>
    </div>
</div>

<div class="row">
    <?php if (empty($posts['items'])): ?>
        <div class="col-12 text-center py-5 text-secondary">Encara no hi ha articles publicats.</div>
    <?php else: ?>
        <?php foreach ($posts['items'] as $post): ?>
            <div class="col-md-6 col-lg-4 mb-4">
                <div class="card h-100">
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title fw-semibold"><?php echo htmlspecialchars($post['title']); ?></h5>
                        <p class="card-text text-secondary small flex-grow-1"><?php echo truncate(strip_tags($post['excerpt'] ?? $post['content']), 120); ?></p>
                        <div class="d-flex justify-content-between align-items-center mt-3">
                            <div class="small text-secondary">
                                <?php echo htmlspecialchars($post['author_name']); ?><br>
                                <?php echo timeAgo($post['published_at']); ?>
                            </div>
                            <a href="/posts/<?php echo $post['slug']; ?>" class="btn btn-sm btn-outline-primary rounded-pill">Llegir</a>
                        </div>
                    </div>
                </div>
            </div>
        <?php endforeach; ?>
    <?php endif; ?>
</div>

<?php if ($posts['last_page'] > 1): ?>
    <nav class="mt-4">
        <ul class="pagination justify-content-center">
            <?php for ($i = 1; $i <= $posts['last_page']; $i++): ?>
                <li class="page-item <?php echo $i == $posts['current_page'] ? 'active' : ''; ?>">
                    <a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a>
                </li>
            <?php endfor; ?>
        </ul>
    </nav>
<?php endif; ?>
