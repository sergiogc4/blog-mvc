<?php
return [
    // Rutas públicas
    ['method' => 'GET', 'path' => '/', 'controller' => 'HomeController', 'action' => 'index'],
    ['method' => 'GET', 'path' => '/posts', 'controller' => 'PostController', 'action' => 'index'],
    ['method' => 'GET', 'path' => '/posts/{slug}', 'controller' => 'PostController', 'action' => 'show'],
    ['method' => 'GET', 'path' => '/author/{id}', 'controller' => 'PostController', 'action' => 'byAuthor'],
    ['method' => 'GET', 'path' => '/search', 'controller' => 'HomeController', 'action' => 'search'],
    
    // Rutas de autenticación
    ['method' => 'GET', 'path' => '/login', 'controller' => 'AuthController', 'action' => 'showLogin', 'middleware' => 'guest'],
    ['method' => 'POST', 'path' => '/login', 'controller' => 'AuthController', 'action' => 'login', 'middleware' => 'guest'],
    ['method' => 'GET', 'path' => '/register', 'controller' => 'AuthController', 'action' => 'showRegister', 'middleware' => 'guest'],
    ['method' => 'POST', 'path' => '/register', 'controller' => 'AuthController', 'action' => 'register', 'middleware' => 'guest'],
    ['method' => 'POST', 'path' => '/logout', 'controller' => 'AuthController', 'action' => 'logout', 'middleware' => 'auth'],
    
    // Rutas de gestión de posts (protegidas)
    ['method' => 'GET', 'path' => '/my-posts', 'controller' => 'PostController', 'action' => 'myPosts', 'middleware' => 'auth'],
    ['method' => 'GET', 'path' => '/my-posts/create', 'controller' => 'PostController', 'action' => 'create', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/my-posts', 'controller' => 'PostController', 'action' => 'store', 'middleware' => 'auth'],
    ['method' => 'GET', 'path' => '/my-posts/{id}/edit', 'controller' => 'PostController', 'action' => 'edit', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/my-posts/{id}/update', 'controller' => 'PostController', 'action' => 'update', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/my-posts/{id}/delete', 'controller' => 'PostController', 'action' => 'delete', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/my-posts/{id}/publish', 'controller' => 'PostController', 'action' => 'publish', 'middleware' => 'auth'],
    
    // Rutas de perfil
    ['method' => 'GET', 'path' => '/profile', 'controller' => 'UserController', 'action' => 'profile', 'middleware' => 'auth'],
    ['method' => 'GET', 'path' => '/profile/edit', 'controller' => 'UserController', 'action' => 'editProfile', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/profile/update', 'controller' => 'UserController', 'action' => 'updateProfile', 'middleware' => 'auth'],
    ['method' => 'POST', 'path' => '/profile/avatar', 'controller' => 'UserController', 'action' => 'uploadAvatar', 'middleware' => 'auth'],
];
