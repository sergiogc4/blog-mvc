<?php
session_start();

require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../src/Utils/Helpers.php';

use Blog\Core\Router;
use Blog\Core\Database;

$config = require __DIR__ . '/../config/database.php';
$routesConfig = require __DIR__ . '/../config/routes.php';

Database::setConfig($config);

$router = new Router();
foreach ($routesConfig as $route) {
    $router->add($route['method'], $route['path'], $route['controller'], $route['action'], $route['middleware'] ?? null);
}

$router->dispatch($_SERVER['REQUEST_METHOD'], $_SERVER['REQUEST_URI']);
