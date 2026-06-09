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
        
        if (file_exists($viewPath)) {
            require_once __DIR__ . "/../Views/layouts/app.php";
        } else {
            die("Vista no encontrada: {$view}");
        }
    }
    
    protected function renderAuth(string $view, array $data = []): void
    {
        extract($data);
        $viewPath = __DIR__ . "/../Views/{$view}.php";
        
        if (file_exists($viewPath)) {
            require_once __DIR__ . "/../Views/layouts/auth.php";
        } else {
            die("Vista no encontrada: {$view}");
        }
    }
    
    protected function redirect(string $url): void
    {
        header("Location: {$url}");
        exit;
    }
    
    protected function json(array $data, int $status = 200): void
    {
        http_response_code($status);
        header('Content-Type: application/json');
        echo json_encode($data);
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
