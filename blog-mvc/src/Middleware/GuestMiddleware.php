<?php
namespace Blog\Middleware;

use Blog\Utils\Session;

class GuestMiddleware
{
    public function handle(): bool
    {
        if (Session::has('user_id')) {
            header('Location: /');
            return false;
        }
        return true;
    }
}
