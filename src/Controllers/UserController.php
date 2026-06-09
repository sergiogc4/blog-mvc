<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\User;
use Blog\Utils\Session;
use Blog\Utils\Flash;

/**
 * Controlador del perfil d'usuari: visualització, edició i pujada d'avatar.
 *
 * @package Blog\Controllers
 */
class UserController extends Controller
{
    /**
     * Mostra el perfil de l'usuari autenticat.
     *
     * @return void
     */
    public function profile(): void
    {
        $user = $this->getCurrentUser();
        $stats = User::getUserStats($user['id']);
        $this->render('user/profile', ['user' => $user, 'stats' => $stats, 'title' => 'Perfil']);
    }

    /**
     * Mostra el formulari d'edició del perfil.
     *
     * @return void
     */
    public function editProfile(): void
    {
        $this->render('user/edit', ['user' => $this->getCurrentUser(), 'csrf_token' => $this->generateCsrfToken(), 'title' => 'Editar perfil']);
    }

    /**
     * Actualitza el nom i la biografia de l'usuari.
     *
     * @return void
     */
    public function updateProfile(): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/profile/edit');
        }
        $name = trim($_POST['name'] ?? '');
        $bio = trim($_POST['bio'] ?? '');
        $userId = $this->getCurrentUser()['id'];
        if (strlen($name) < 2) {
            Flash::error('El nom és massa curt');
            $this->redirect('/profile/edit');
        }
        User::update($userId, ['name' => $name, 'bio' => $bio]);
        $user = User::find($userId);
        Session::set('user', $user);
        Flash::success('Perfil actualitzat');
        $this->redirect('/profile');
    }

    /**
     * Puja i actualitza l'avatar de l'usuari.
     *
     * @return void
     */
    public function uploadAvatar(): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            Flash::error('Token CSRF invàlid');
            $this->redirect('/profile/edit');
        }
        if (!isset($_FILES['avatar']) || $_FILES['avatar']['error'] !== UPLOAD_ERR_OK) {
            Flash::error('No s\'ha rebut cap imatge o error en la pujada.');
            $this->redirect('/profile/edit');
        }
        $file = $_FILES['avatar'];
        $allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        if (!in_array($file['type'], $allowed)) {
            Flash::error('Format no permès. Usa JPG, PNG, GIF o WEBP.');
            $this->redirect('/profile/edit');
        }
        if ($file['size'] > 5242880) {
            Flash::error('La imatge no pot superar 5MB');
            $this->redirect('/profile/edit');
        }
        $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = 'avatar_' . $this->getCurrentUser()['id'] . '_' . time() . '.' . $ext;
        // Guardar dentro de public/assets/avatars para que sea accesible
        $uploadDir = __DIR__ . '/../../public/assets/avatars/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }
        $uploadPath = $uploadDir . $filename;
        if (move_uploaded_file($file['tmp_name'], $uploadPath)) {
            $avatarUrl = '/assets/avatars/' . $filename;
            User::update($this->getCurrentUser()['id'], ['avatar' => $avatarUrl]);
            $user = User::find($this->getCurrentUser()['id']);
            Session::set('user', $user);
            Flash::success('Avatar actualitzat correctament.');
        } else {
            Flash::error('Error en guardar el fitxer.');
        }
        $this->redirect('/profile/edit');
    }
}
