<div class="row justify-content-center">
    <div class="col-lg-8">
        <div class="card border-0 shadow-sm">
            <div class="card-body p-4 p-lg-5">
                <h1><?php echo htmlspecialchars($post['title']); ?></h1>
                <div class="text-secondary mb-4">
                    <?php echo htmlspecialchars($post['author_name']); ?> · 
                    <?php echo date('d/m/Y H:i', strtotime($post['published_at'])); ?> · 
                    <?php echo $post['views_count']; ?> visualitzacions
                </div>
                <div class="mb-4">
                    <?php echo $post['content']; ?>
                </div>
                <a href="/posts" class="btn btn-outline-secondary">← Tornar</a>
            </div>
        </div>
    </div>
</div>
