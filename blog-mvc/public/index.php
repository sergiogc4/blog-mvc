<?php
session_start();

require_once __DIR__ . '/../vendor/autoload.php';

use Blog\Core\Router;
use Blog\Core\Database;

// Cargar configuración
$config = require __DIR__ . '/../config/database.php';
$routesConfig = require __DIR__ . '/../config/routes.php';

// Establecer conexión DB
Database::setConfig($config);

// Router
$router = new Router();

// Registrar rutas
foreach ($routesConfig as $route) {
    $router->add($route['method'], $route['path'], $route['controller'], $route['action'], $route['middleware'] ?? null);
}

// Procesar la solicitud
$router->dispatch($_SERVER['REQUEST_METHOD'], $_SERVER['REQUEST_URI']);
