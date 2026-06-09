<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\Post;

class HomeController extends Controller
{
    public function index(): void
    {
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        $posts = Post::getPublished($page, 6);
        $this->render('home/index', ['posts' => $posts, 'title' => 'Inici']);
    }

    public function search(): void
    {
        $query = trim($_GET['q'] ?? '');
        $page = isset($_GET['page']) ? (int)$_GET['page'] : 1;
        if (empty($query)) {
            $this->redirect('/');
            return;
        }
        $posts = Post::search($query, $page, 6);
        $this->render('home/search', ['posts' => $posts, 'query' => $query, 'title' => 'Resultats de cerca']);
    }
}
