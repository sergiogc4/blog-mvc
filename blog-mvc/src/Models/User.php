<?php
namespace Blog\Models;

use Blog\Core\Model;
use Blog\Core\Database;
use PDO;

class User extends Model
{
    protected static string $table = 'users';
    
    public static function findByEmail(string $email): ?array
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT * FROM users WHERE email = :email");
        $stmt->execute(['email' => $email]);
        return $stmt->fetch() ?: null;
    }
    
    public static function getUserStats(int $userId): array
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("
            SELECT 
                COUNT(*) as total_posts,
                SUM(views_count) as total_views
            FROM posts 
            WHERE author_id = :user_id AND status = 'published'
        ");
        $stmt->execute(['user_id' => $userId]);
        return $stmt->fetch();
    }
    
    public static function updateLastLogin(int $userId): void
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("UPDATE users SET last_login_at = NOW() WHERE id = :id");
        $stmt->execute(['id' => $userId]);
    }
}
