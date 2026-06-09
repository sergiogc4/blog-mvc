<?php
require_once __DIR__ . '/../../vendor/autoload.php';

use App\Core\Database;
use App\Models\User;
use App\Models\Post;

$db = Database::getInstance();

// Limpiar tablas
echo "Limpiando tablas...\n";
$db->query("SET FOREIGN_KEY_CHECKS = 0");
$db->query("TRUNCATE TABLE posts");
$db->query("TRUNCATE TABLE users");
$db->query("SET FOREIGN_KEY_CHECKS = 1");

// Crear usuarios
echo "Creando usuarios...\n";

$users = [
    [
        'name' => 'Admin User',
        'email' => 'admin@blog.com',
        'password' => password_hash('Admin123!', PASSWORD_DEFAULT),
        'bio' => 'Administrador del blog. Me encanta escribir sobre tecnología y programación.',
    ],
    [
        'name' => 'John Doe',
        'email' => 'john@blog.com',
        'password' => password_hash('User123!', PASSWORD_DEFAULT),
        'bio' => 'Escritor y desarrollador web. Apasionado por el open source.',
    ],
    [
        'name' => 'Jane Smith',
        'email' => 'jane@blog.com',
        'password' => password_hash('User123!', PASSWORD_DEFAULT),
        'bio' => 'Diseñadora UX/UI y escritora técnica.',
    ],
    [
        'name' => 'Bob Wilson',
        'email' => 'bob@blog.com',
        'password' => password_hash('User123!', PASSWORD_DEFAULT),
        'bio' => 'Entusiasta del marketing digital y SEO.',
    ],
    [
        'name' => 'Alice Johnson',
        'email' => 'alice@blog.com',
        'password' => password_hash('User123!', PASSWORD_DEFAULT),
        'bio' => 'Fotógrafa y bloguera de viajes.',
    ],
];

$userModel = new User();
$userIds = [];

foreach ($users as $userData) {
    $userId = $userModel->create($userData);
    $userIds[] = $userId;
    echo "Usuario creado: {$userData['name']}\n";
}

// Crear posts
echo "Creando posts...\n";

$posts = [
    [
        'title' => 'Introducción a PHP 8',
        'content' => '<p>PHP 8 trae muchas características nuevas y mejoras de rendimiento. En este artículo exploraremos las principales novedades como los atributos, union types, match expression y más.</p>
                     <h2>Novedades principales</h2>
                     <ul>
                         <li>JIT Compiler para mejor rendimiento</li>
                         <li>Atributos (anteriormente conocidos como anotaciones)</li>
                         <li>Union Types para mayor flexibilidad</li>
                         <li>Match Expression como alternativa a switch</li>
                     </ul>',
        'author_id' => $userIds[0],
        'status' => 'published',
    ],
    [
        'title' => 'Patrón MVC en PHP',
        'content' => '<p>El patrón Model-View-Controller (MVC) es fundamental para desarrollar aplicaciones web organizadas y mantenibles. Este artículo explica cómo implementarlo correctamente en PHP.</p>
                     <h2>Componentes del MVC</h2>
                     <p><strong>Model:</strong> Maneja la lógica de negocio y acceso a datos.</p>
                     <p><strong>View:</strong> Presenta la información al usuario.</p>
                     <p><strong>Controller:</strong> Recibe las peticiones y coordina Model y View.</p>',
        'author_id' => $userIds[1],
        'status' => 'published',
    ],
    // Agregar más posts aquí...
];

$postModel = new Post();

for ($i = 0; $i < 15; $i++) {
    $postData = [
        'title' => "Post de ejemplo {$i} - " . ['PHP', 'JavaScript', 'Bootstrap', 'MySQL', 'Laravel'][$i % 5],
        'content' => '<p>Este es el contenido del post número ' . ($i + 1) . '. Aquí iría el contenido real del artículo sobre el tema correspondiente.</p>
                     <p>Este contenido es solo para propósitos de demostración y prueba del sistema de blog.</p>',
        'author_id' => $userIds[$i % count($userIds)],
        'status' => $i % 3 == 0 ? 'draft' : 'published',
        'published_at' => $i % 3 == 0 ? null : date('Y-m-d H:i:s', strtotime("-{$i} days")),
    ];
    
    $postData['slug'] = $postModel->createSlug($postData['title']);
    $postData['excerpt'] = \App\Services\ValidationService::generateExcerpt($postData['content']);
    
    $postModel->create($postData);
    echo "Post creado: {$postData['title']}\n";
}

echo "\n¡Base de datos poblada exitosamente!\n";
echo "Total usuarios: " . count($userIds) . "\n";
echo "Total posts: 15\n";