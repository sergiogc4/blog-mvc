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
