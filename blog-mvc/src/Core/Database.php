<?php
namespace Blog\Core;

use PDO;
use PDOException;

class Database
{
    private static ?PDO $connection = null;
    private static array $config = [];

    public static function setConfig(array $config): void
    {
        self::$config = $config;
    }

    public static function getConnection(): PDO
    {
        if (self::$connection === null) {
            try {
                $dsn = sprintf(
                    'mysql:host=%s;port=%s;dbname=%s;charset=%s',
                    self::$config['host'],
                    self::$config['port'],
                    self::$config['database'],
                    self::$config['charset']
                );
                
                self::$connection = new PDO($dsn, self::$config['username'], self::$config['password'], self::$config['options']);
            } catch (PDOException $e) {
                die('Error de conexión a la base de datos: ' . $e->getMessage());
            }
        }
        return self::$connection;
    }
}
