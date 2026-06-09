#!/bin/bash

# 1. Asegurar que Controller.php define $viewPath correctamente
cat > src/Core/Controller.php << 'CONTROLLER'
<?php
namespace Blog\Core;

use Blog\Utils\Session;
use Blog\Utils\Flash;

class Controller
{
    protected function render(string $view, array $data = []): void
    {
        extract($data);
        $viewPath = __DIR__ . "/../Views/{$view}.php";
        if (!file_exists($viewPath)) {
            die("Error: la vista '$view' no existeix a: " . $viewPath);
        }
        require_once __DIR__ . "/../Views/layouts/app.php";
    }

    protected function renderAuth(string $view, array $data = []): void
    {
        extract($data);
        $viewPath = __DIR__ . "/../Views/{$view}.php";
        if (!file_exists($viewPath)) {
            die("Error: la vista '$view' no existeix a: " . $viewPath);
        }
        require_once __DIR__ . "/../Views/layouts/auth.php";
    }

    protected function redirect(string $url): void
    {
        header("Location: {$url}");
        exit;
    }

    protected function isAuthenticated(): bool
    {
        return Session::has('user_id');
    }

    protected function getCurrentUser(): ?array
    {
        return Session::get('user');
    }

    protected function generateCsrfToken(): string
    {
        $token = bin2hex(random_bytes(32));
        Session::set('csrf_token', $token);
        return $token;
    }

    protected function verifyCsrfToken(?string $token): bool
    {
        if (!$token || $token !== Session::get('csrf_token')) {
            Flash::error('Token CSRF inválido');
            return false;
        }
        return true;
    }
}
CONTROLLER

# 2. Añadir una comprobación en el layout por si acaso (opcional)
# pero el layout actual ya usa $viewPath, con el Controller arreglado basta.

echo "✅ Controller reparado. Ahora las vistas deberían cargar sin error."
echo "🔄 Reinicia el servidor: php -S localhost:8000 -t public"
