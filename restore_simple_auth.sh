#!/bin/bash

# 1. MODIFICAR AuthController para que use el layout normal (app.php) en lugar de auth.php
cat > src/Controllers/AuthController.php << 'AUTHCTRL'
<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\User;
use Blog\Utils\Session;
use Blog\Utils\Flash;

class AuthController extends Controller
{
    public function showLogin(): void
    {
        $this->render('auth/login', ['title' => 'Iniciar Sessió', 'csrf_token' => $this->generateCsrfToken()]);
    }

    public function login(): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/login');
        }
        $email = $_POST['email'] ?? '';
        $password = $_POST['password'] ?? '';
        if (empty($email) || empty($password)) {
            Flash::error('Tots els camps són obligatoris');
            $this->redirect('/login');
        }
        $user = User::findByEmail($email);
        if (!$user || !password_verify($password, $user['password'])) {
            Flash::error('Credencials incorrectes');
            $this->redirect('/login');
        }
        Session::set('user_id', $user['id']);
        Session::set('user', $user);
        User::updateLastLogin($user['id']);
        Flash::success('Benvingut/da ' . $user['name']);
        $this->redirect('/');
    }

    public function showRegister(): void
    {
        $this->render('auth/register', ['title' => 'Registre', 'csrf_token' => $this->generateCsrfToken()]);
    }

    public function register(): void
    {
        if (!$this->verifyCsrfToken($_POST['csrf_token'] ?? null)) {
            $this->redirect('/register');
        }
        $name = trim($_POST['name'] ?? '');
        $email = trim($_POST['email'] ?? '');
        $password = $_POST['password'] ?? '';
        $passwordConfirm = $_POST['password_confirm'] ?? '';
        if (strlen($name) < 2 || strlen($name) > 50) {
            Flash::error('El nom ha de tenir entre 2 i 50 caràcters');
            $this->redirect('/register');
        }
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            Flash::error('Email invàlid');
            $this->redirect('/register');
        }
        if (strlen($password) < 8 || !preg_match('/[A-Z]/', $password) || !preg_match('/[0-9]/', $password)) {
            Flash::error('La contrasenya ha de tenir mínim 8 caràcters, una majúscula i un número');
            $this->redirect('/register');
        }
        if ($password !== $passwordConfirm) {
            Flash::error('Les contrasenyes no coincideixen');
            $this->redirect('/register');
        }
        if (User::findByEmail($email)) {
            Flash::error('Aquest email ja està registrat');
            $this->redirect('/register');
        }
        User::create([
            'name' => $name,
            'email' => $email,
            'password' => password_hash($password, PASSWORD_BCRYPT)
        ]);
        Flash::success('Registre completat! Ara pots iniciar sessió');
        $this->redirect('/login');
    }

    public function logout(): void
    {
        Session::destroy();
        Flash::success('Has tancat sessió');
        $this->redirect('/');
    }
}
AUTHCTRL

# 2. VISTA LOGIN (simple, centrada, sin fondos de color)
cat > src/Views/auth/login.php << 'LOGIN'
<?php use Blog\Utils\Flash; ?>
<div class="row justify-content-center">
    <div class="col-md-5">
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4">
                <h3 class="text-center mb-4 fw-semibold">Iniciar sessió</h3>
                <?php Flash::display(); ?>
                <form method="POST" action="/login">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    <div class="mb-3">
                        <label class="form-label fw-medium">Correu electrònic</label>
                        <input type="email" name="email" class="form-control" required autofocus>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-medium">Contrasenya</label>
                        <input type="password" name="password" class="form-control" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 py-2 rounded-pill">Accedir</button>
                </form>
                <hr class="my-4">
                <p class="text-center mb-0">No tens compte? <a href="/register">Registra't</a></p>
            </div>
        </div>
    </div>
</div>
LOGIN

# 3. VISTA REGISTER (simple, centrada, sin fondos de color)
cat > src/Views/auth/register.php << 'REGISTER'
<?php use Blog\Utils\Flash; ?>
<div class="row justify-content-center">
    <div class="col-md-6">
        <div class="card border-0 shadow-sm rounded-4">
            <div class="card-body p-4">
                <h3 class="text-center mb-4 fw-semibold">Registre d'usuari</h3>
                <?php Flash::display(); ?>
                <form method="POST" action="/register">
                    <input type="hidden" name="csrf_token" value="<?php echo $csrf_token; ?>">
                    <div class="mb-3">
                        <label class="form-label fw-medium">Nom complet</label>
                        <input type="text" name="name" class="form-control" required minlength="2" maxlength="50">
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Correu electrònic</label>
                        <input type="email" name="email" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label fw-medium">Contrasenya</label>
                        <input type="password" name="password" class="form-control" required minlength="8">
                        <div class="form-text text-secondary">Mínim 8 caràcters, una majúscula i un número</div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-medium">Confirmar contrasenya</label>
                        <input type="password" name="password_confirm" class="form-control" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100 py-2 rounded-pill">Registrar-se</button>
                </form>
                <hr class="my-4">
                <p class="text-center mb-0">Ja tens compte? <a href="/login">Inicia sessió</a></p>
            </div>
        </div>
    </div>
</div>
REGISTER

# 4. OPCIONAL: asegurar que layouts/auth.php no se usa (pero lo dejamos por si acaso, sin gradiente)
cat > src/Views/layouts/auth.php << 'AUTHLAYOUT'
<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo htmlspecialchars($title ?? 'Blog MVC'); ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background: #f8f9fa; font-family: system-ui; }
        .navbar { background: white; border-bottom: 1px solid #dee2e6; }
        footer { background: white; border-top: 1px solid #dee2e6; margin-top: 3rem; padding: 1.5rem 0; }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg">
        <div class="container">
            <a class="navbar-brand" href="/">Blog MVC</a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item"><a class="nav-link" href="/login">Iniciar sessió</a></li>
                    <li class="nav-item"><a class="nav-link" href="/register">Registre</a></li>
                </ul>
            </div>
        </div>
    </nav>
    <main class="container my-4">
        <?php require_once $viewPath; ?>
    </main>
    <footer class="text-center">
        <div class="container">&copy; <?php echo date('Y'); ?> Blog MVC</div>
    </footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
AUTHLAYOUT

echo ""
echo "✅ Login y registro restaurados al diseño simple y profesional (sin fondo azul)."
echo "🔄 Reinicia el servidor: php -S localhost:8000 -t public"
