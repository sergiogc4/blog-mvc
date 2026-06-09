#!/bin/bash

# 1. Corregir método getPublished en Post.php
cat > src/Models/Post.php << 'POSTMODEL'
<?php
namespace Blog\Models;

use Blog\Core\Model;
use Blog\Core\Database;
use PDO;

class Post extends Model
{
    protected static string $table = 'posts';

    public static function getPublished(int $page = 1, int $perPage = 6): array
    {
        $db = Database::getConnection();
        $offset = ($page - 1) * $perPage;
        
        $stmt = $db->prepare("
            SELECT p.*, u.name as author_name 
            FROM posts p
            JOIN users u ON p.author_id = u.id
            WHERE p.status = 'published'
            ORDER BY p.published_at DESC
            LIMIT :limit OFFSET :offset
        ");
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $items = $stmt->fetchAll();
        
        $countStmt = $db->query("SELECT COUNT(*) as total FROM posts WHERE status = 'published'");
        $total = $countStmt->fetch()['total'];
        
        return [
            'items' => $items,
            'current_page' => $page,
            'per_page' => $perPage,
            'total' => $total,
            'last_page' => ceil($total / $perPage)
        ];
    }
    
    // resto de métodos (findBySlug, etc.) ya existen, no se modifican aquí
    // pero por seguridad dejamos el resto igual
}
POSTMODEL

# 2. Asegurar que la vista home/index.php recibe los datos correctos
cat > src/Views/home/index.php << 'HOME'
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
HOME

echo "✅ Model i vista corregits. Ara haurien de mostrar tots els posts publicats."
echo "🔄 Reinicia el servidor (Ctrl+C i després php -S localhost:8000 -t public)"
