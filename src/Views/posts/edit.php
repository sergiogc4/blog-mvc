<div class="row justify-content-center">
    <div class="col-md-8">
        <h2 class="mb-4 fw-semibold">Editar article</h2>
        <?php use Blog\Utils\Flash; Flash::display(); ?>
        <form method="POST" action="/my-posts/<?php echo $post['id']; ?>/update">
            <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
            <div class="mb-3"><label class="form-label fw-medium">Títol</label><input type="text" name="title" value="<?php echo htmlspecialchars($post['title']); ?>" class="form-control" required minlength="5"></div>
            <div class="mb-3"><label class="form-label fw-medium">Contingut</label><textarea name="content" rows="10" class="form-control" required minlength="50"><?php echo htmlspecialchars($post['content']); ?></textarea></div>
            <div class="mb-3"><label class="form-label fw-medium">Estat</label><select name="status" class="form-select"><option value="draft" <?php echo $post['status']=='draft'?'selected':''; ?>>Esborrany</option><option value="published" <?php echo $post['status']=='published'?'selected':''; ?>>Publicat</option></select></div>
            <div><button type="submit" class="btn btn-primary rounded-pill px-4">Actualitzar</button> <a href="/my-posts" class="btn btn-outline-secondary rounded-pill">Cancel·lar</a></div>
        </form>
    </div>
</div>
