<?php
namespace Blog\Middleware;

use Blog\Utils\Session;
use Blog\Utils\Flash;

class AuthMiddleware
{
    public function handle(): bool
    {
        if (!Session::has('user_id')) {
            Flash::error('Has d\'iniciar sessió per accedir a aquesta pàgina');
            header('Location: /login');
            return false;
        }
        return true;
    }
}
