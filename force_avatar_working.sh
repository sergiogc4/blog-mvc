#!/bin/bash

# Reemplazar UserController con un código más depurado
cat > src/Controllers/UserController.php << 'USER'
<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\User;
use Blog\Utils\Session;
use Blog\Utils\Flash;

class UserController extends Controller
{
    public function profile(): void
    {
        $user = $this->getCurrentUser();
        $stats = User::getUserStats($user['id']);
        $this->render('user/profile', ['user' => $user, 'stats' => $stats, 'title' => 'Perfil']);
    }

    public function editProfile(): void
    {
        $this->render('user/edit', ['user' => $this->getCurrentUser(), 'csrf_token' => $this->generateCsrfToken(), 'title' => 'Editar perfil']);
    }

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

    public function uploadAvatar(): void
    {
        // Comprovar token CSRF
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            Flash::error('Token CSRF invàlid');
            $this->redirect('/profile/edit');
        }
        // Comprovar fitxer
        if (!isset($_FILES['avatar']) || $_FILES['avatar']['error'] !== UPLOAD_ERR_OK) {
            Flash::error('No s\'ha rebut cap imatge o error en la pujada. Codi error: ' . ($_FILES['avatar']['error'] ?? 'cap fitxer'));
            $this->redirect('/profile/edit');
        }
        $file = $_FILES['avatar'];
        $allowed = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        if (!in_array($file['type'], $allowed)) {
            Flash::error('Format no permès. Usa JPG, PNG, GIF o WEBP. El teu tipus: ' . $file['type']);
            $this->redirect('/profile/edit');
        }
        if ($file['size'] > 5242880) {
            Flash::error('La imatge no pot superar 5MB');
            $this->redirect('/profile/edit');
        }
        $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = 'avatar_' . $this->getCurrentUser()['id'] . '_' . time() . '.' . $ext;
        $uploadDir = __DIR__ . '/../../storage/uploads/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
        $uploadPath = $uploadDir . $filename;
        if (move_uploaded_file($file['tmp_name'], $uploadPath)) {
            $avatarUrl = '/storage/uploads/' . $filename;
            User::update($this->getCurrentUser()['id'], ['avatar' => $avatarUrl]);
            $user = User::find($this->getCurrentUser()['id']);
            Session::set('user', $user);
            Flash::success('Avatar actualitzat correctament. Nova URL: ' . $avatarUrl);
        } else {
            Flash::error('Error en moure el fitxer. Comprova permisos de storage/uploads. Path: ' . $uploadPath);
        }
        $this->redirect('/profile/edit');
    }
}
USER

# Asegurar que la ruta está en routes.php
if ! grep -q "'/profile/avatar'" config/routes.php; then
    echo "    ['method' => 'POST', 'path' => '/profile/avatar', 'controller' => 'UserController', 'action' => 'uploadAvatar', 'middleware' => 'auth']," >> config/routes.php
fi

# Crear directorio y permisos
mkdir -p storage/uploads
chmod -R 777 storage/uploads  # permisos amplios para asegurar escritura

echo "✅ Sistema d'avatar reinstal·lat amb missatges de depuració."
echo "Reinicia el servidor: /usr/bin/php8.2 -S localhost:8000 -t public"
echo "Després prova de pujar una imatge i mira els missatges flash per detectar errors."
