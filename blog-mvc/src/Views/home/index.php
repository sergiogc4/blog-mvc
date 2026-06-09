<div class="row">
    <div class="col-12">
        <div class="text-center mb-5">
            <h1 class="display-4">📝 Benvingut al Blog MVC</h1>
            <p class="lead">Comparteix coneixement, aprèn i connecta amb altres desenvolupadors</p>
            <?php if (!isset($_SESSION['user_id'])): ?>
                <a href="/register" class="btn btn-primary btn-lg"><i class="fas fa-user-plus"></i> Crea un compte</a>
            <?php else: ?>
                <a href="/my-posts/create" class="btn btn-primary btn-lg"><i class="fas fa-plus"></i> Crea un post</a>
            <?php endif; ?>
        </div>
    </div>
    
    <div class="col-12 mb-4">
        <form action="/search" method="GET" class="d-flex">
            <input type="search" name="q" class="form-control me-2" placeholder="Cerca posts...">
            <button type="submit" class="btn btn-outline-primary"><i class="fas fa-search"></i> Cercar</button>
        </form>
    </div>
    
    <?php foreach ($posts['items'] as $post): ?>
        <div class="col-md-6 col-lg-4">
            <div class="card post-card h-100">
                <div class="card-body">
                    <h5 class="card-title"><?php echo htmlspecialchars($post['title']); ?></h5>
                    <p class="card-text"><?php echo truncate(strip_tags($post['excerpt'] ?? $post['content']), 120); ?></p>
                    <div class="d-flex justify-content-between align-items-center">
                        <small class="text-muted">
                            <i class="fas fa-user"></i> <?php echo htmlspecialchars($post['author_name']); ?><br>
                            <i class="fas fa-calendar"></i> <?php echo timeAgo($post['published_at']); ?>
                        </small>
                        <a href="/posts/<?php echo $post['slug']; ?>" class="btn btn-sm btn-primary">Llegir més</a>
                    </div>
                </div>
            </div>
        </div>
    <?php endforeach; ?>
    
    <?php if ($posts['last_page'] > 1): ?>
        <div class="col-12">
            <nav>
                <ul class="pagination">
                    <?php for ($i = 1; $i <= $posts['last_page']; $i++): ?>
                        <li class="page-item <?php echo $i == $posts['current_page'] ? 'active' : ''; ?>">
                            <a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a>
                        </li>
                    <?php endfor; ?>
                </ul>
            </nav>
        </div>
    <?php endif; ?>
</div>
