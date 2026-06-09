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
        $this->renderAuth('auth/login', [
            'title' => 'Iniciar Sesión',
            'csrf_token' => $this->generateCsrfToken()
        ]);
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
        $this->renderAuth('auth/register', [
            'title' => 'Registre',
            'csrf_token' => $this->generateCsrfToken()
        ]);
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
        
        // Validaciones
        if (strlen($name) < 2 || strlen($name) > 50) {
            Flash::error('El nom ha de tenir entre 2 i 50 caràcters');
            $this->redirect('/register');
        }
        
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            Flash::error('Email invàlid');
            $this->redirect('/register');
        }
        
        if (strlen($password) < 8) {
            Flash::error('La contrasenya ha de tenir almenys 8 caràcters');
            $this->redirect('/register');
        }
        
        if (!preg_match('/[A-Z]/', $password) || !preg_match('/[0-9]/', $password)) {
            Flash::error('La contrasenya ha de contenir almenys una majúscula i un número');
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
        
        $userId = User::create([
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
