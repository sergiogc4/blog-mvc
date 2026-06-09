<?php
session_start();
echo "Session ID: " . session_id() . "\n";
echo "Session data:\n";
print_r($_SESSION);

// Probar AuthService
require_once __DIR__ . '/vendor/autoload.php';

$auth = new App\Services\AuthService();
echo "\nAuthService check: " . ($auth->check() ? 'TRUE' : 'FALSE') . "\n";
echo "User ID in session: " . ($_SESSION['user_id'] ?? 'NO') . "\n";
