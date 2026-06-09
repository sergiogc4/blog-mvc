<?php
namespace Blog\Core;

use Blog\Utils\Session;
use Blog\Utils\Flash;

class Controller
{
    protected function render(string $view, array $data = []): void
    {
        extract($data);
        $viewFile = __DIR__ . "/../Views/{$view}.php";
        if (!file_exists($viewFile)) {
            die("Error: Vista no trobada: {$viewFile}");
        }
        ob_start();
        require $viewFile;
        $content = ob_get_clean();
        require __DIR__ . "/../Views/layouts/app.php";
    }

    protected function renderAuth(string $view, array $data = []): void
    {
        extract($data);
        $viewFile = __DIR__ . "/../Views/{$view}.php";
        if (!file_exists($viewFile)) {
            die("Error: Vista no trobada: {$viewFile}");
        }
        ob_start();
        require $viewFile;
        $content = ob_get_clean();
        require __DIR__ . "/../Views/layouts/auth.php";
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
