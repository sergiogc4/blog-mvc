<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\Post;
use Blog\Models\User;
use Blog\Utils\Flash;

/**
 * Controlador per a la gestió completa de posts (CRUD, publicació, edició, eliminació).
 *
 * @package Blog\Controllers
 */
class PostController extends Controller
{
    /**
     * Llista tots els posts publicats (paginats).
     *
     * @return void
     */
    public function index(): void
    {
        $page = $_GET['page'] ?? 1;
        $posts = Post::getPublished((int)$page, 6);
        $this->render('posts/index', ['posts' => $posts, 'title' => 'Tots els articles']);
    }

    /**
     * Mostra un post individual pel seu slug i incrementa les visualitzacions.
     *
     * @return void
     */
    public function show(string $slug): void
    {
        $post = Post::findBySlug($slug);
        if (!$post) {
            http_response_code(404);
            echo "<h1>404 - Article no trobat</h1>";
            return;
        }
        Post::incrementViews($post['id']);
        $this->render('posts/show', ['post' => $post, 'title' => $post['title']]);
    }

    /**
     * Llista els posts d'un autor específic.
     *
     * @return void
     */
    public function byAuthor(string $id): void
    {
        $author = User::find((int)$id);
        if (!$author) {
            http_response_code(404);
            echo "<h1>Autor no trobat</h1>";
            return;
        }
        $page = $_GET['page'] ?? 1;
        $posts = Post::getByAuthor((int)$id, (int)$page, 6);
        $this->render('posts/by-author', ['posts' => $posts, 'author' => $author, 'title' => 'Articles de ' . $author['name']]);
    }

    /**
     * Llista els posts de l'usuari autenticat (tots els estats).
     *
     * @return void
     */
    public function myPosts(): void
    {
        $page = $_GET['page'] ?? 1;
        $posts = Post::getMyPosts($this->getCurrentUser()['id'], (int)$page, 10);
        $this->render('posts/my-posts', ['posts' => $posts, 'title' => 'Els meus articles']);
    }

    /**
     * Mostra el formulari per crear un nou post.
     *
     * @return void
     */
    public function create(): void
    {
        $this->render('posts/create', ['title' => 'Crear article', 'csrf_token' => $this->generateCsrfToken()]);
    }

    /**
     * Guarda un nou post (valida, genera slug i excerpt).
     *
     * @return void
     */
    public function store(): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/my-posts/create');
        }
        $title = trim($_POST['title'] ?? '');
        $content = trim($_POST['content'] ?? '');
        $status = $_POST['status'] ?? 'draft';
        if (strlen($title) < 5) {
            Flash::error('El títol ha de tenir almenys 5 caràcters');
            $this->redirect('/my-posts/create');
        }
        if (strlen($content) < 50) {
            Flash::error('El contingut ha de tenir almenys 50 caràcters');
            $this->redirect('/my-posts/create');
        }
        $slug = Post::generateSlug($title);
        $excerpt = substr(strip_tags($content), 0, 200);
        Post::create([
            'title' => $title,
            'slug' => $slug,
            'content' => $content,
            'excerpt' => $excerpt,
            'author_id' => $this->getCurrentUser()['id'],
            'status' => $status,
            'published_at' => $status === 'published' ? date('Y-m-d H:i:s') : null
        ]);
        Flash::success('Article creat correctament');
        $this->redirect('/my-posts');
    }

    /**
     * Mostra el formulari d'edició d'un post (només autor).
     *
     * @return void
     */
    public function edit(string $id): void
    {
        $post = Post::find((int)$id);
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís');
            $this->redirect('/my-posts');
        }
        $this->render('posts/edit', ['post' => $post, 'title' => 'Editar article', 'csrf_token' => $this->generateCsrfToken()]);
    }

    /**
     * Actualitza un post existent (només autor).
     *
     * @return void
     */
    public function update(string $id): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/my-posts/' . $id . '/edit');
        }
        $post = Post::find((int)$id);
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís');
            $this->redirect('/my-posts');
        }
        $title = trim($_POST['title'] ?? '');
        $content = trim($_POST['content'] ?? '');
        $status = $_POST['status'] ?? 'draft';
        if (strlen($title) < 5) {
            Flash::error('El títol ha de tenir almenys 5 caràcters');
            $this->redirect('/my-posts/' . $id . '/edit');
        }
        if (strlen($content) < 50) {
            Flash::error('El contingut ha de tenir almenys 50 caràcters');
            $this->redirect('/my-posts/' . $id . '/edit');
        }
        $excerpt = substr(strip_tags($content), 0, 200);
        $data = [
            'title' => $title,
            'content' => $content,
            'excerpt' => $excerpt,
            'status' => $status
        ];
        if ($status === 'published' && $post['status'] !== 'published') {
            $data['published_at'] = date('Y-m-d H:i:s');
        }
        Post::update((int)$id, $data);
        Flash::success('Article actualitzat');
        $this->redirect('/my-posts');
    }

    /**
     * Elimina un post (només autor).
     *
     * @return void
     */
    public function delete(string $id): void
    {
        $post = Post::find((int)$id);
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís');
            $this->redirect('/my-posts');
        }
        Post::delete((int)$id);
        Flash::success('Article eliminat');
        $this->redirect('/my-posts');
    }

    /**
     * Commuta l'estat del post entre esborrany i publicat.
     *
     * @return void
     */
    public function publish(string $id): void
    {
        $post = Post::find((int)$id);
        if (!$post || $post['author_id'] != $this->getCurrentUser()['id']) {
            Flash::error('No tens permís');
            $this->redirect('/my-posts');
        }
        $newStatus = $post['status'] === 'published' ? 'draft' : 'published';
        Post::update((int)$id, [
            'status' => $newStatus,
            'published_at' => $newStatus === 'published' ? date('Y-m-d H:i:s') : null
        ]);
        Flash::success('Estat canviat');
        $this->redirect('/my-posts');
    }
}
