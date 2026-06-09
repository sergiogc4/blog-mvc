<?php
namespace Blog\Controllers;

use Blog\Core\Controller;
use Blog\Models\User;
use Blog\Utils\Session;
use Blog\Utils\Flash;

/**
 * Controlador d'autenticació: registre, inici de sessió i tancament de sessió.
 *
 * @package Blog\Controllers
 */
class AuthController extends Controller
{
    /**
     * Mostra el formulari d'inici de sessió.
     *
     * @return void
     */
    public function showLogin(): void
    {
        $this->render('auth/login', ['title' => 'Iniciar Sessió', 'csrf_token' => $this->generateCsrfToken()]);
    }

    /**
     * Processa les credencials i inicia la sessió.
     *
     * @return void
     */
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

    /**
     * Mostra el formulari de registre.
     *
     * @return void
     */
    public function showRegister(): void
    {
        $this->render('auth/register', ['title' => 'Registre', 'csrf_token' => $this->generateCsrfToken()]);
    }

    /**
     * Registra un nou usuari amb validacions i contrasenya xifrada.
     *
     * @return void
     */
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

    /**
     * Tanca la sessió de l'usuari.
     *
     * @return void
     */
    public function logout(): void
    {
        Session::destroy();
        Flash::success('Has tancat sessió');
        $this->redirect('/');
    }
}
