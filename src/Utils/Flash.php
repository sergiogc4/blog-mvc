<?php
namespace Blog\Utils;

class Flash
{
    public static function set(string $type, string $message): void
    {
        Session::set('flash_' . $type, $message);
    }

    public static function success(string $message): void
    {
        self::set('success', $message);
    }

    public static function error(string $message): void
    {
        self::set('error', $message);
    }

    public static function get(string $type): ?string
    {
        $key = 'flash_' . $type;
        $message = Session::get($key);
        Session::remove($key);
        return $message;
    }

    public static function has(string $type): bool
    {
        return Session::has('flash_' . $type);
    }

    public static function display(): void
    {
        if (self::has('success')) {
            echo '<div class="alert alert-success alert-dismissible fade show">' . htmlspecialchars(self::get('success')) . '<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>';
        }
        if (self::has('error')) {
            echo '<div class="alert alert-danger alert-dismissible fade show">' . htmlspecialchars(self::get('error')) . '<button type="button" class="btn-close" data-bs-dismiss="alert"></button></div>';
        }
    }
}
