<?php
namespace App\Services;

class ValidationService
{
    public static function sanitize($data)
    {
        if (is_array($data)) {
            return array_map([self::class, 'sanitize'], $data);
        }
        
        return htmlspecialchars(trim($data), ENT_QUOTES, 'UTF-8');
    }

    public static function validatePost($data)
    {
        $errors = [];
        
        if (empty($data['title']) || strlen($data['title']) < 5 || strlen($data['title']) > 200) {
            $errors['title'] = 'El título debe tener entre 5 y 200 caracteres';
        }
        
        if (empty($data['content']) || strlen($data['content']) < 50 || strlen($data['content']) > 10000) {
            $errors['content'] = 'El contenido debe tener entre 50 y 10000 caracteres';
        }
        
        return $errors;
    }

    public static function validateProfile($data)
    {
        $errors = [];
        
        if (empty($data['name']) || strlen($data['name']) < 2 || strlen($data['name']) > 100) {
            $errors['name'] = 'El nombre debe tener entre 2 y 100 caracteres';
        }
        
        if (!empty($data['bio']) && strlen($data['bio']) > 1000) {
            $errors['bio'] = 'La biografía no puede exceder los 1000 caracteres';
        }
        
        return $errors;
    }

    public static function generateExcerpt($content, $length = 200)
    {
        $content = strip_tags($content);
        $content = preg_replace('/\s+/', ' ', $content);
        
        if (strlen($content) <= $length) {
            return $content;
        }
        
        $excerpt = substr($content, 0, $length);
        $lastSpace = strrpos($excerpt, ' ');
        
        if ($lastSpace !== false) {
            $excerpt = substr($excerpt, 0, $lastSpace);
        }
        
        return $excerpt . '...';
    }
}