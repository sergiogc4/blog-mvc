#!/bin/bash

# 1. Assegurar que la vista edit.php té el formulari d'avatar
cat > src/Views/user/edit.php << 'EDIT'
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card border-0 shadow-sm">
            <div class="card-body p-4">
                <h3 class="mb-4 fw-semibold">Editar perfil</h3>
                <?php use Blog\Utils\Flash; Flash::display(); ?>
                
                <form method="POST" action="/profile/update">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    <div class="mb-3">
                        <label class="form-label fw-medium">Nom</label>
                        <input type="text" name="name" value="<?php echo htmlspecialchars($user['name']); ?>" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Biografia</label>
                        <textarea name="bio" rows="5" class="form-control"><?php echo htmlspecialchars($user['bio']); ?></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary rounded-pill px-4">Guardar canvis</button>
                    <a href="/profile" class="btn btn-outline-secondary rounded-pill">Cancel·lar</a>
                </form>

                <hr class="my-4">

                <h5 class="mb-3">Canviar avatar</h5>
                <form method="POST" action="/profile/avatar" enctype="multipart/form-data">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    <div class="mb-3">
                        <label class="form-label">Imatge (JPG, PNG, GIF, WEBP, màxim 5MB)</label>
                        <input type="file" name="avatar" class="form-control" accept="image/*" required>
                    </div>
                    <button type="submit" class="btn btn-outline-primary rounded-pill">Pujar avatar</button>
                </form>
            </div>
        </div>
    </div>
</div>
EDIT

# 2. Assegurar que la ruta POST /profile/avatar existeix a routes.php
if ! grep -q "'path' => '/profile/avatar'" config/routes.php; then
    sed -i "/'path' => '\/profile\/update',/a\    ['method' => 'POST', 'path' => '\/profile\/avatar', 'controller' => 'UserController', 'action' => 'uploadAvatar', 'middleware' => 'auth']," config/routes.php
fi

# 3. Assegurar que el mètode uploadAvatar existeix a UserController
cat > src/Controllers/UserController.php << 'USERCTRL'
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
        $this->render('user/profile', ['user' => $user, 'stats' => $stats, 'title' => 'El meu perfil']);
    }

    public function editProfile(): void
    {
        $this->render('user/edit', ['user' => $this->getCurrentUser(), 'title' => 'Editar perfil', 'csrf_token' => $this->generateCsrfToken()]);
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
        User::update($userId, ['name' => $name, 'bio' => $bio]);
        $user = User::find($userId);
        Session::set('user', $user);
        Flash::success('Perfil actualitzat');
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
        $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = 'avatar_' . $this->getCurrentUser()['id'] . '_' . time() . '.' . $ext;
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
USERCTRL

# 4. Crear carpeta storage/uploads i donar permisos
mkdir -p storage/uploads
chmod -R 755 storage/

# 5. Regenerar autoload
composer dump-autoload

echo "✅ Avatar completament funcional. Reinicia el servidor:"
echo "/usr/bin/php8.2 -S localhost:8000 -t public"
