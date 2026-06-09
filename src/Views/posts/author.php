<?php $this->setLayout('app'); ?>

<div class="row">
    <div class="col-lg-8">
        <div class="d-flex align-items-center mb-4">
            <img src="<?= $author['avatar'] ? $this->url("storage/uploads/{$author['avatar']}") : 
                      $this->asset('images/default-avatar.png') ?>" 
                 alt="<?= $this->escape($author['name']) ?>" 
                 class="rounded-circle me-3" width="80" height="80">
            <div>
                <h1><?= $this->escape($author['name']) ?></h1>
                <?php if ($author['bio']): ?>
                    <p class="text-muted mb-0"><?= $this->escape($author['bio']) ?></p>
                <?php endif; ?>
            </div>
        </div>
        
        <h2 class="mb-4">Posts de <?= $this->escape($author['name']) ?></h2>
        
        <?php if (empty($posts['data'])): ?>
            <div class="alert alert-info">
                Este autor no ha publicado ningún post aún.
            </div>
        <?php else: ?>
            <?php foreach ($posts['data'] as $post): ?>
                <div class="card mb-4">
                    <?php if ($post['featured_image']): ?>
                        <img src="<?= $this->url("storage/uploads/{$post['featured_image']}") ?>" 
                             class="card-img-top" alt="<?= $this->escape($post['title']) ?>">
                    <?php endif; ?>
                    <div class="card-body">
                        <h3 class="card-title">
                            <a href="<?= $this->url("posts/{$post['slug']}") ?>" class="text-decoration-none">
                                <?= $this->escape($post['title']) ?>
                            </a>
                        </h3>
                        
                        <p class="card-text">
                            <?= truncate(strip_tags($post['content']), 200) ?>
                        </p>
                        
                        <div class="d-flex justify-content-between align-items-center">
                            <small class="text-muted">
                                <i class="far fa-calendar me-1"></i>
                                <?= format_date($post['published_at'] ?? $post['created_at']) ?>
                                <i class="far fa-eye ms-3 me-1"></i>
                                <?= $post['views_count'] ?> vistas
                            </small>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
            
            <!-- Paginación -->
            <?php if ($posts['last_page'] > 1): ?>
                <nav aria-label="Page navigation">
                    <ul class="pagination justify-content-center">
                        <?php for ($i = 1; $i <= $posts['last_page']; $i++): ?>
                            <li class="page-item <?= $i == $posts['current_page'] ? 'active' : '' ?>">
                                <a class="page-link" href="?page=<?= $i ?>"><?= $i ?></a>
                            </li>
                        <?php endfor; ?>
                    </ul>
                </nav>
            <?php endif; ?>
            
        <?php endif; ?>
    </div>
    
    <div class="col-lg-4">
        <!-- Información del autor -->
        <div class="card mb-4">
            <div class="card-header">
                <h5 class="mb-0">Sobre el autor</h5>
            </div>
            <div class="card-body">
                <div class="text-center mb-3">
                    <img src="<?= $author['avatar'] ? $this->url("storage/uploads/{$author['avatar']}") : 
                              $this->asset('images/default-avatar.png') ?>" 
                         alt="<?= $this->escape($author['name']) ?>" 
                         class="rounded-circle mb-3" width="120" height="120">
                    <h4><?= $this->escape($author['name']) ?></h4>
                </div>
                
                <?php if ($author['bio']): ?>
                    <p><?= $this->escape($author['bio']) ?></p>
                <?php endif; ?>
                
                <hr>
                
                <div class="row text-center">
                    <div class="col-6">
                        <h5><?= $posts['total'] ?></h5>
                        <small class="text-muted">Posts</small>
                    </div>
                    <div class="col-6">
                        <h5><?= date('Y') - date('Y', strtotime($author['created_at'])) ?></h5>
                        <small class="text-muted">Años en la plataforma</small>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>