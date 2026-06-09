<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\Post;

class HomeController extends Controller
{
    public function index(): void
    {
        $page = $_GET['page'] ?? 1;
        $posts = Post::getPublished((int)$page, 6);
        
        $this->render('home/index', [
            'posts' => $posts,
            'title' => 'Inicio'
        ]);
    }
    
    public function search(): void
    {
        $query = $_GET['q'] ?? '';
        $page = $_GET['page'] ?? 1;
        
        if (empty($query)) {
            $this->redirect('/');
        }
        
        $posts = Post::search($query, (int)$page, 6);
        
        $this->render('home/search', [
            'posts' => $posts,
            'query' => $query,
            'title' => 'Resultados de búsqueda'
        ]);
    }
}
