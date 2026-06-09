#!/bin/bash

# Asegurar que Helpers.php tiene todas las funciones
cat > src/Utils/Helpers.php << 'HELPERS'
<?php
/**
 * Funciones globales de ayuda para vistas
 */

if (!function_exists('asset')) {
    function asset(string $path): string
    {
        return '/assets/' . ltrim($path, '/');
    }
}

if (!function_exists('url')) {
    function url(string $path = ''): string
    {
        return 'http://localhost:8000' . $path;
    }
}

if (!function_exists('truncate')) {
    function truncate(string $text, int $length = 150, string $suffix = '...'): string
    {
        if (strlen($text) <= $length) return $text;
        $cut = substr($text, 0, $length);
        $lastSpace = strrpos($cut, ' ');
        if ($lastSpace !== false) {
            $cut = substr($cut, 0, $lastSpace);
        }
        return $cut . $suffix;
    }
}

if (!function_exists('timeAgo')) {
    function timeAgo(string $datetime): string
    {
        $timestamp = strtotime($datetime);
        $diff = time() - $timestamp;
        if ($diff < 60) return 'fa uns segons';
        if ($diff < 3600) return 'fa ' . floor($diff / 60) . ' minuts';
        if ($diff < 86400) return 'fa ' . floor($diff / 3600) . ' hores';
        if ($diff < 2592000) return 'fa ' . floor($diff / 86400) . ' dies';
        return date('d/m/Y', $timestamp);
    }
}
HELPERS

# Asegurar que index.php incluye Helpers.php
if ! grep -q "Helpers.php" public/index.php; then
    sed -i '/require_once __DIR__ . "\/..\/vendor\/autoload.php";/a require_once __DIR__ . "/../src/Utils/Helpers.php";' public/index.php
    echo "✅ Helpers.php incluido en index.php"
else
    echo "✅ Helpers.php ya estaba incluido."
fi

# Regenerar autoload de Composer
composer dump-autoload

echo "✅ Todo listo. Ahora reinicia el servidor."
