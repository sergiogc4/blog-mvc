#!/bin/bash

# 1. Asegurar que el método show del PostController funciona
cat > src/Controllers/PostController.php << 'POSTCTRL'
<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\Post;
use Blog\Models\User;
use Blog\Utils\Flash;

class PostController extends Controller
{
    public function index(): void
    {
        $page = $_GET['page'] ?? 1;
        $posts = Post::getPublished((int)$page, 6);
        $this->render('posts/index', ['posts' => $posts, 'title' => 'Tots els articles']);
    }

    public function show(string $slug): void
    {
        $post = Post::findBySlug($slug);
        if (!$post) {
            http_response_code(404);
            echo "<h1>404 - Article no trobat</h1>";
            return;
        }
        Post::incrementViews($post['id']);
        $this->render('posts/show', ['post' => $post, 'title' => $post['title']]);
    }

    public function byAuthor(string $id): void
    {
        $author = User::find((int)$id);
        if (!$author) {
            http_response_code(404);
            echo "<h1>Autor no trobat</h1>";
            return;
        }
        $page = $_GET['page'] ?? 1;
        $posts = Post::getByAuthor((int)$id, (int)$page, 6);
        $this->render('posts/by-author', ['posts' => $posts, 'author' => $author, 'title' => 'Articles de ' . $author['name']]);
    }

    public function myPosts(): void
    {
        $page = $_GET['page'] ?? 1;
        $posts = Post::getMyPosts($this->getCurrentUser()['id'], (int)$page, 10);
        $this->render('posts/my-posts', ['posts' => $posts, 'title' => 'Els meus articles']);
    }

    public function create(): void
    {
        $this->render('posts/create', ['title' => 'Crear article', 'csrf_token' => $this->generateCsrfToken()]);
    }

    public function store(): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/my-posts/create');
        }
        $title = trim($_POST['title'] ?? '');
        $content = trim($_POST['content'] ?? '');
        $status = $_POST['status'] ?? 'draft';
        if (strlen($title) < 5) {
            Flash::error('El títol ha de tenir almenys 5 caràcters');
            $this->redirect('/my-posts/create');
        }
        if (strlen($content) < 50) {
            Flash::error('El contingut ha de tenir almenys 50 caràcters');
            $this->redirect('/my-posts/create');
        }
        $slug = Post::generateSlug($title);
        $excerpt = substr(strip_tags($content), 0, 200);
        Post::create([
            'title' => $title,
            'slug' => $slug,
            'content' => $content,
            'excerpt' => $excerpt,
            'author_id' => $this->getCurrentUser()['id'],
            'status' => $status,
            'published_at' => $status === 'published' ? date('Y-m-d H:i:s') : null
        ]);
        Flash::success('Article creat correctament');
        $this->redirect('/my-posts');
    }

    public function edit(string $id): void
    {
        $post = Post::find((int)$id);
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís');
            $this->redirect('/my-posts');
        }
        $this->render('posts/edit', ['post' => $post, 'title' => 'Editar article', 'csrf_token' => $this->generateCsrfToken()]);
    }

    public function update(string $id): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/my-posts/' . $id . '/edit');
        }
        $post = Post::find((int)$id);
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís');
            $this->redirect('/my-posts');
        }
        $title = trim($_POST['title'] ?? '');
        $content = trim($_POST['content'] ?? '');
        $status = $_POST['status'] ?? 'draft';
        if (strlen($title) < 5) {
            Flash::error('El títol ha de tenir almenys 5 caràcters');
            $this->redirect('/my-posts/' . $id . '/edit');
        }
        if (strlen($content) < 50) {
            Flash::error('El contingut ha de tenir almenys 50 caràcters');
            $this->redirect('/my-posts/' . $id . '/edit');
        }
        $excerpt = substr(strip_tags($content), 0, 200);
        $data = [
            'title' => $title,
            'content' => $content,
            'excerpt' => $excerpt,
            'status' => $status
        ];
        if ($status === 'published' && $post['status'] !== 'published') {
            $data['published_at'] = date('Y-m-d H:i:s');
        }
        Post::update((int)$id, $data);
        Flash::success('Article actualitzat');
        $this->redirect('/my-posts');
    }

    public function delete(string $id): void
    {
        $post = Post::find((int)$id);
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís');
            $this->redirect('/my-posts');
        }
        Post::delete((int)$id);
        Flash::success('Article eliminat');
        $this->redirect('/my-posts');
    }

    public function publish(string $id): void
    {
        $post = Post::find((int)$id);
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís');
            $this->redirect('/my-posts');
        }
        $newStatus = $post['status'] === 'published' ? 'draft' : 'published';
        Post::update((int)$id, [
            'status' => $newStatus,
            'published_at' => $newStatus === 'published' ? date('Y-m-d H:i:s') : null
        ]);
        Flash::success('Estat canviat');
        $this->redirect('/my-posts');
    }
}
POSTCTRL

# 2. Crear una vista de detalle ultra simple y que funcione
cat > src/Views/posts/show.php << 'SHOW'
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
SHOW

# 3. Asegurar que Post::findBySlug existe
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
        $stmt = $db->prepare("SELECT p.*, u.name as author_name FROM posts p JOIN users u ON p.author_id = u.id WHERE p.status = 'published' ORDER BY p.published_at DESC LIMIT :limit OFFSET :offset");
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $items = $stmt->fetchAll();
        $totalStmt = $db->query("SELECT COUNT(*) as total FROM posts WHERE status = 'published'");
        $total = $totalStmt->fetch()['total'];
        return ['items' => $items, 'current_page' => $page, 'per_page' => $perPage, 'total' => $total, 'last_page' => ceil($total / $perPage)];
    }

    public static function findBySlug(string $slug): ?array
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT p.*, u.name as author_name FROM posts p JOIN users u ON p.author_id = u.id WHERE p.slug = :slug AND p.status = 'published'");
        $stmt->execute(['slug' => $slug]);
        $post = $stmt->fetch();
        return $post ?: null;
    }

    public static function getByAuthor(int $authorId, int $page = 1, int $perPage = 6): array
    {
        $db = Database::getConnection();
        $offset = ($page - 1) * $perPage;
        $stmt = $db->prepare("SELECT p.*, u.name as author_name FROM posts p JOIN users u ON p.author_id = u.id WHERE p.author_id = :author_id AND p.status = 'published' ORDER BY p.published_at DESC LIMIT :limit OFFSET :offset");
        $stmt->bindValue(':author_id', $authorId, PDO::PARAM_INT);
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $items = $stmt->fetchAll();
        $countStmt = $db->prepare("SELECT COUNT(*) as total FROM posts WHERE author_id = :author_id AND status = 'published'");
        $countStmt->execute(['author_id' => $authorId]);
        $total = $countStmt->fetch()['total'];
        return ['items' => $items, 'current_page' => $page, 'per_page' => $perPage, 'total' => $total, 'last_page' => ceil($total / $perPage)];
    }

    public static function getMyPosts(int $userId, int $page = 1, int $perPage = 10): array
    {
        $db = Database::getConnection();
        $offset = ($page - 1) * $perPage;
        $stmt = $db->prepare("SELECT * FROM posts WHERE author_id = :author_id ORDER BY created_at DESC LIMIT :limit OFFSET :offset");
        $stmt->bindValue(':author_id', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $items = $stmt->fetchAll();
        $countStmt = $db->prepare("SELECT COUNT(*) as total FROM posts WHERE author_id = :author_id");
        $countStmt->execute(['author_id' => $userId]);
        $total = $countStmt->fetch()['total'];
        return ['items' => $items, 'current_page' => $page, 'per_page' => $perPage, 'total' => $total, 'last_page' => ceil($total / $perPage)];
    }

    public static function incrementViews(int $postId): void
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("UPDATE posts SET views_count = views_count + 1 WHERE id = :id");
        $stmt->execute(['id' => $postId]);
    }

    public static function search(string $query, int $page = 1, int $perPage = 6): array
    {
        $db = Database::getConnection();
        $offset = ($page - 1) * $perPage;
        $searchTerm = "%{$query}%";
        $stmt = $db->prepare("SELECT p.*, u.name as author_name FROM posts p JOIN users u ON p.author_id = u.id WHERE p.status = 'published' AND (p.title LIKE :search OR p.content LIKE :search) ORDER BY p.published_at DESC LIMIT :limit OFFSET :offset");
        $stmt->bindValue(':search', $searchTerm);
        $stmt->bindValue(':limit', $perPage, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();
        $items = $stmt->fetchAll();
        $countStmt = $db->prepare("SELECT COUNT(*) as total FROM posts WHERE status = 'published' AND (title LIKE :search OR content LIKE :search)");
        $countStmt->execute(['search' => $searchTerm]);
        $total = $countStmt->fetch()['total'];
        return ['items' => $items, 'current_page' => $page, 'per_page' => $perPage, 'total' => $total, 'last_page' => ceil($total / $perPage)];
    }

    public static function generateSlug(string $title): string
    {
        $slug = strtolower(trim(preg_replace('/[^a-z0-9-]/', '-', $title)));
        $slug = preg_replace('/-+/', '-', $slug);
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT COUNT(*) as count FROM posts WHERE slug = :slug");
        $stmt->execute(['slug' => $slug]);
        $count = $stmt->fetch()['count'];
        return $count > 0 ? $slug . '-' . ($count + 1) : $slug;
    }
}
POSTMODEL

echo "✅ Tot arreglat: controlador, model i vista de detalle."
echo "🔄 Reinicia el servidor (Ctrl+C i després php -S localhost:8000 -t public)"
echo "▶️ Prova fent clic a 'Llegir' en qualsevol article."
