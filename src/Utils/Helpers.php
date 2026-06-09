<?php
/**
 * Funciones globales de ayuda
 */

if (!function_exists('truncate')) {
    function truncate($text, $length = 150, $suffix = '...') {
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
    function timeAgo($datetime) {
        $timestamp = strtotime($datetime);
        $diff = time() - $timestamp;
        if ($diff < 60) return 'fa uns segons';
        if ($diff < 3600) return 'fa ' . floor($diff / 60) . ' minuts';
        if ($diff < 86400) return 'fa ' . floor($diff / 3600) . ' hores';
        if ($diff < 2592000) return 'fa ' . floor($diff / 86400) . ' dies';
        return date('d/m/Y', $timestamp);
    }
}

if (!function_exists('asset')) {
    function asset($path) {
        return '/assets/' . ltrim($path, '/');
    }
}
