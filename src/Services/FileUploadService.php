<?php
namespace App\Services;

class FileUploadService
{
    private $config;
    private $errors = [];

    public function __construct()
    {
        $this->config = require CONFIG_PATH . '/app.php';
    }

    public function uploadAvatar($file, $userId)
    {
        if ($file['error'] !== UPLOAD_ERR_OK) {
            $this->errors[] = 'Error al subir el archivo';
            return false;
        }

        // Validar tamaño
        if ($file['size'] > $this->config['uploads']['max_size']) {
            $this->errors[] = 'El archivo es demasiado grande. Máximo: ' . 
                            ($this->config['uploads']['max_size'] / 1024 / 1024) . 'MB';
            return false;
        }

        // Validar tipo
        $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        if (!in_array($extension, $this->config['uploads']['allowed_types'])) {
            $this->errors[] = 'Tipo de archivo no permitido. Solo se permiten: ' . 
                            implode(', ', $this->config['uploads']['allowed_types']);
            return false;
        }

        // Validar que sea una imagen
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mime = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);
        
        if (!str_starts_with($mime, 'image/')) {
            $this->errors[] = 'El archivo no es una imagen válida';
            return false;
        }

        // Crear directorio si no existe
        $uploadPath = $this->config['uploads']['path'] . '/avatars';
        if (!is_dir($uploadPath)) {
            mkdir($uploadPath, 0755, true);
        }

        // Generar nombre único
        $filename = 'avatar_' . $userId . '_' . time() . '.' . $extension;
        $destination = $uploadPath . '/' . $filename;

        // Mover archivo
        if (move_uploaded_file($file['tmp_name'], $destination)) {
            return 'avatars/' . $filename;
        }

        $this->errors[] = 'Error al guardar el archivo';
        return false;
    }

    public function uploadFeaturedImage($file, $postId)
    {
        if ($file['error'] !== UPLOAD_ERR_OK) {
            return null; // No es obligatorio
        }

        // Validar tamaño
        if ($file['size'] > $this->config['uploads']['max_size']) {
            $this->errors[] = 'La imagen es demasiado grande';
            return false;
        }

        // Validar tipo
        $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        if (!in_array($extension, $this->config['uploads']['allowed_types'])) {
            $this->errors[] = 'Tipo de imagen no permitido';
            return false;
        }

        // Crear directorio si no existe
        $uploadPath = $this->config['uploads']['path'] . '/posts';
        if (!is_dir($uploadPath)) {
            mkdir($uploadPath, 0755, true);
        }

        // Generar nombre único
        $filename = 'post_' . $postId . '_' . time() . '.' . $extension;
        $destination = $uploadPath . '/' . $filename;

        // Mover archivo
        if (move_uploaded_file($file['tmp_name'], $destination)) {
            return 'posts/' . $filename;
        }

        $this->errors[] = 'Error al guardar la imagen';
        return false;
    }

    public function getErrors()
    {
        return $this->errors;
    }
}