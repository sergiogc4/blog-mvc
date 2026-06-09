<div class="d-flex justify-content-between align-items-center mb-4">
    <h2 class="fw-semibold">Els meus articles</h2>
    <a href="/my-posts/create" class="btn btn-primary rounded-pill px-4">+ Nou article</a>
</div>
<?php if (empty($posts['items'])): ?>
    <div class="alert alert-light border text-secondary">No tens cap article. Crea el teu primer article!</div>
<?php else: ?>
    <div class="table-responsive">
        <table class="table align-middle">
            <thead class="table-light">
                <tr><th>Títol</th><th>Estat</th><th>Visualitzacions</th><th>Creat</th><th>Accions</th></tr>
            </thead>
            <tbody>
                <?php foreach ($posts['items'] as $post): ?>
                <tr>
                    <td><strong><?php echo htmlspecialchars($post['title']); ?></strong></td>
                    <td><span class="badge bg-<?php echo $post['status']=='published'?'success':'secondary'; ?>"><?php echo $post['status']; ?></span></td>
                    <td><?php echo $post['views_count']; ?></td>
                    <td><?php echo timeAgo($post['created_at']); ?></td>
                    <td>
                        <a href="/my-posts/<?php echo $post['id']; ?>/edit" class="btn btn-sm btn-outline-warning rounded-pill">Editar</a>
                        <form method="POST" action="/my-posts/<?php echo $post['id']; ?>/publish" style="display:inline-block">
                            <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                            <button type="submit" class="btn btn-sm btn-outline-info rounded-pill"><?php echo $post['status']=='published'?'Despublicar':'Publicar'; ?></button>
                        </form>
                        <form method="POST" action="/my-posts/<?php echo $post['id']; ?>/delete" style="display:inline-block" onsubmit="return confirm('Segur que vols eliminar aquest article?');">
                            <input type="hidden" name="csrf_token" value="<?php echo $_SESSION['csrf_token']; ?>">
                            <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill">Eliminar</button>
                        </form>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
    <?php if ($posts['last_page'] > 1): ?>
        <nav><ul class="pagination justify-content-center"><?php for($i=1;$i<=$posts['last_page'];$i++): ?><li class="page-item <?php echo $i==$posts['current_page']?'active':''; ?>"><a class="page-link" href="?page=<?php echo $i; ?>"><?php echo $i; ?></a></li><?php endfor; ?></ul></nav>
    <?php endif; ?>
<?php endif; ?>
