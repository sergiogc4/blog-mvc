<?php
namespace Blog\Core;

class Router
{
    private array $routes = [];

    public function add(string $method, string $path, string $controller, string $action, ?string $middleware = null): void
    {
        $pattern = preg_replace('/\{([a-z]+)\}/', '(?P<$1>[^/]+)', $path);
        $pattern = '#^' . $pattern . '$#';
        $this->routes[] = [
            'method' => $method,
            'pattern' => $pattern,
            'controller' => $controller,
            'action' => $action,
            'middleware' => $middleware
        ];
    }

    public function dispatch(string $method, string $uri): void
    {
        $uri = parse_url($uri, PHP_URL_PATH);
        foreach ($this->routes as $route) {
            if ($route['method'] !== $method) continue;
            if (preg_match($route['pattern'], $uri, $matches)) {
                $params = array_filter($matches, 'is_string', ARRAY_FILTER_USE_KEY);
                if ($route['middleware']) {
                    $middlewareClass = "Blog\\Middleware\\" . ucfirst($route['middleware']) . "Middleware";
                    if (class_exists($middlewareClass)) {
                        $middleware = new $middlewareClass();
                        if (!$middleware->handle()) return;
                    }
                }
                $controllerClass = "Blog\\Controllers\\" . $route['controller'];
                if (class_exists($controllerClass)) {
                    $controller = new $controllerClass();
                    if (method_exists($controller, $route['action'])) {
                        call_user_func_array([$controller, $route['action']], $params);
                        return;
                    }
                }
            }
        }
        http_response_code(404);
        echo "<h1>404 - Página no encontrada</h1>";
    }
}
