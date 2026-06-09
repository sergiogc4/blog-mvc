<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\User;
use Blog\Models\Post;
use Blog\Utils\Session;
use Blog\Utils\Flash;

class UserController extends Controller
{
    public function profile(): void
    {
        $user = $this->getCurrentUser();
        $stats = User::getUserStats($user['id']);
        
        $this->render('user/profile', [
            'user' => $user,
            'stats' => $stats,
            'title' => 'El meu perfil'
        ]);
    }
    
    public function editProfile(): void
    {
        $this->render('user/edit', [
            'user' => $this->getCurrentUser(),
            'title' => 'Editar perfil',
            'csrf_token' => $this->generateCsrfToken()
        ]);
    }
    
    public function updateProfile(): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/profile/edit');
        }
        
        $name = trim($_POST['name'] ?? '');
        $bio = trim($_POST['bio'] ?? '');
        $userId = $this->getCurrentUser()['id'];
        
        if (strlen($name) < 2 || strlen($name) > 100) {
            Flash::error('El nom ha de tenir entre 2 i 100 caràcters');
            $this->redirect('/profile/edit');
        }
        
        User::update($userId, [
            'name' => $name,
            'bio' => $bio
        ]);
        
        // Actualizar sesión
        $user = User::find($userId);
        Session::set('user', $user);
        
        Flash::success('Perfil actualitzat correctament');
        $this->redirect('/profile');
    }
    
    public function uploadAvatar(): void
    {
        if (!isset($_FILES['avatar']) || $_FILES['avatar']['error'] !== UPLOAD_ERR_OK) {
            Flash::error('Error al pujar l\'avatar');
            $this->redirect('/profile/edit');
        }
        
        $file = $_FILES['avatar'];
        $allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
        
        if (!in_array($file['type'], $allowedTypes)) {
            Flash::error('Format no permès. Usa JPG, PNG, GIF o WEBP');
            $this->redirect('/profile/edit');
        }
        
        if ($file['size'] > 5242880) {
            Flash::error('L\'avatar no pot superar els 5MB');
            $this->redirect('/profile/edit');
        }
        
        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = 'avatar_' . $this->getCurrentUser()['id'] . '_' . time() . '.' . $extension;
        $uploadPath = __DIR__ . '/../../storage/uploads/' . $filename;
        
        if (!is_dir(__DIR__ . '/../../storage/uploads')) {
            mkdir(__DIR__ . '/../../storage/uploads', 0777, true);
        }
        
        if (move_uploaded_file($file['tmp_name'], $uploadPath)) {
            $avatarPath = '/storage/uploads/' . $filename;
            User::update($this->getCurrentUser()['id'], ['avatar' => $avatarPath]);
            
            $user = User::find($this->getCurrentUser()['id']);
            Session::set('user', $user);
            
            Flash::success('Avatar actualitzat correctament');
        } else {
            Flash::error('Error al guardar l\'avatar');
        }
        
        $this->redirect('/profile/edit');
    }
}
