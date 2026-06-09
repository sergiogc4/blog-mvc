<?php
// test_conexion.php
define('CONFIG_PATH', __DIR__ . '/config');
$config = require CONFIG_PATH . '/database.php';

try {
    $dsn = "mysql:host={$config['host']};dbname={$config['database']};charset={$config['charset']}";
    $pdo = new PDO($dsn, $config['username'], $config['password'], $config['options']);
    
    echo "✅ Conexión a MySQL exitosa!\n\n";
    
    // Contar usuarios
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM users");
    $users = $stmt->fetch();
    echo "👥 Usuarios en la BD: " . $users['total'] . "\n";
    
    // Contar posts
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM posts");
    $posts = $stmt->fetch();
    echo "📝 Posts en la BD: " . $posts['total'] . "\n";
    
    // Mostrar últimos posts
    echo "\n📰 Últimos posts:\n";
    $stmt = $pdo->query("SELECT p.title, u.name as author, p.status FROM posts p JOIN users u ON p.author_id = u.id ORDER BY p.created_at DESC LIMIT 3");
    foreach ($stmt->fetchAll() as $post) {
        echo "- '{$post['title']}' por {$post['author']} ({$post['status']})\n";
    }
    
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
