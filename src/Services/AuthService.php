<?php
namespace App\Services;

use App\Models\User;

class AuthService
{
    private $userModel;
    private $session;
    
    public function __construct()
    {
        $this->userModel = new User();
        
        // Inicializar sesión
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        
        $sessionClass = 'App\\Utils\\Session';
        if (class_exists($sessionClass)) {
            $this->session = $sessionClass::getInstance();
        } else {
            $this->session = new class {
                public function get($k, $d = null) { return $_SESSION[$k] ?? $d; }
                public function set($k, $v) { $_SESSION[$k] = $v; }
                public function has($k) { return isset($_SESSION[$k]); }
                public function remove($k) { unset($_SESSION[$k]); }
                public function flash($m, $t = 'info') { 
                    $this->set('flash_message', $m);
                    $this->set('flash_type', $t);
                }
                public function destroy() { 
                    $_SESSION = [];
                    if (session_id() !== '') {
                        session_destroy();
                    }
                }
            };
        }
    }
    
    public function attempt($email, $password)
    {
        // 1. Validación MUY ESTRICTA
        if (!is_string($email) || !is_string($password)) {
            return false;
        }
        
        $email = trim($email);
        $password = trim($password);
        
        // NO aceptar nada vacío
        if ($email === '' || $password === '') {
            return false;
        }
        
        // 2. Email debe ser válido
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return false;
        }
        
        // 3. Buscar usuario
        $user = $this->userModel->findByEmail($email);
        
        // Si NO hay usuario
        if (!$user) {
            return false;
        }
        
        // 4. Verificar que el usuario tenga contraseña
        if (empty($user['password'])) {
            return false;
        }
        
        // 5. Verificar contraseña
        if (!password_verify($password, $user['password'])) {
            return false;
        }
        
        // 6. ÉXITO - Guardar en sesión
        unset($user['password']);
        $this->session->set('user', $user);
        $this->session->set('user_id', $user['id']);
        
        // Actualizar último login
        $this->userModel->updateLastLogin($user['id']);
        
        return true;
    }
    
    public function register($data)
    {
        // Validar datos
        if (!isset($data['name'], $data['email'], $data['password'])) {
            return false;
        }
        
        $name = trim($data['name']);
        $email = trim($data['email']);
        $password = $data['password'];
        
        if ($name === '' || $email === '' || $password === '') {
            return false;
        }
        
        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return false;
        }
        
        // Verificar si email ya existe
        if ($this->userModel->findByEmail($email)) {
            return false;
        }
        
        // Crear usuario
        $userData = [
            'name' => $name,
            'email' => $email,
            'password' => password_hash($password, PASSWORD_DEFAULT)
        ];
        
        $userId = $this->userModel->create($userData);
        
        if ($userId) {
            // Iniciar sesión automáticamente
            $user = $this->userModel->find($userId);
            unset($user['password']);
            
            $this->session->set('user', $user);
            $this->session->set('user_id', $userId);
            
            return true;
        }
        
        return false;
    }
    
    public function logout()
    {
        $this->session->destroy();
    }
    
    public function user()
    {
        return $this->session->get('user');
    }
    
    public function check()
    {
        return $this->session->has('user_id');
    }
    
    public function id()
    {
        return $this->session->get('user_id');
    }
    
    public function emailExists($email)
    {
        $email = trim($email);
        if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return false;
        }
        return $this->userModel->findByEmail($email) !== false;
    }
}