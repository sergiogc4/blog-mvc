#!/bin/bash

# 1. Asegurar que el directorio de avatares existe en public
mkdir -p public/assets/avatars

# 2. Modificar UserController para que guarde los avatares en public/assets/avatars
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
USER

# 3. Actualizar la vista de perfil para mostrar el avatar con la ruta correcta
cat > src/Views/user/profile.php << 'PROFILE'
<div class="row">
    <div class="col-md-4 text-center">
        <div class="card border-0 shadow-sm">
            <div class="card-body">
                <?php if (!empty($user['avatar'])): ?>
                    <img src="<?php echo $user['avatar']; ?>" class="avatar-md mb-3" alt="Avatar">
                <?php else: ?>
                    <i class="fas fa-user-circle fa-5x text-secondary mb-3"></i>
                <?php endif; ?>
                <h3 class="fw-semibold"><?php echo htmlspecialchars($user['name']); ?></h3>
                <p class="text-secondary"><?php echo htmlspecialchars($user['email']); ?></p>
                <a href="/profile/edit" class="btn btn-outline-primary rounded-pill">Editar perfil</a>
            </div>
        </div>
    </div>
    <div class="col-md-8">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-transparent border-0 pt-4">
                <h5 class="fw-semibold mb-0">Estadístiques</h5>
            </div>
            <div class="card-body">
                <p><strong>Total d'articles:</strong> <?php echo $stats['total_posts']; ?></p>
                <p><strong>Visualitzacions totals:</strong> <?php echo $stats['total_views']; ?></p>
                <p><strong>Membre des de:</strong> <?php echo date('d/m/Y', strtotime($user['created_at'])); ?></p>
                <?php if ($user['bio']): ?>
                    <hr><h6>Biografia</h6><p class="text-secondary"><?php echo nl2br(htmlspecialchars($user['bio'])); ?></p>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>
PROFILE

# 4. Actualizar la barra de navegación (layout) para que muestre el avatar desde la nueva ruta
# El layout ya usa asset($avatar) que funciona con rutas /assets/... así que no hace falta cambiar.

# 5. Mover los avatares antiguos (si los hay) a la nueva ubicación
if [ -d storage/uploads ]; then
    cp -f storage/uploads/avatar_* public/assets/avatars/ 2>/dev/null
fi

# 6. Actualizar las rutas de avatar en la base de datos (si había imágenes en storage/uploads)
mysql -u blog_user -pBlogMVC2024! blog_mvc -e "UPDATE users SET avatar = REPLACE(avatar, '/storage/uploads/', '/assets/avatars/') WHERE avatar LIKE '/storage/uploads/%';" 2>/dev/null

echo "✅ Avatar arreglat. Ara les imatges es guarden a public/assets/avatars i són accessibles."
echo "🔄 Reinicia el servidor: /usr/bin/php8.2 -S localhost:8000 -t public"
