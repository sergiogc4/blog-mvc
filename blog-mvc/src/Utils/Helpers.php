<?php
function asset(string $path): string
{
    return '/assets/' . ltrim($path, '/');
}

function url(string $path = ''): string
{
    return 'http://localhost:8000' . $path;
}

function truncate(string $text, int $length = 150, string $suffix = '...'): string
{
    if (strlen($text) <= $length) return $text;
    return substr($text, 0, strpos($text, ' ', $length)) . $suffix;
}

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
