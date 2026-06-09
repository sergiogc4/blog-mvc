<?php
namespace Blog\Core;

use PDO;

abstract class Model
{
    protected static string $table;
    protected static string $primaryKey = 'id';

    public static function all(): array
    {
        $db = Database::getConnection();
        $stmt = $db->query("SELECT * FROM " . static::$table . " ORDER BY created_at DESC");
        return $stmt->fetchAll();
    }

    public static function find(int $id): ?array
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT * FROM " . static::$table . " WHERE " . static::$primaryKey . " = :id");
        $stmt->execute(['id' => $id]);
        return $stmt->fetch() ?: null;
    }

    public static function where(string $column, $value): array
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("SELECT * FROM " . static::$table . " WHERE {$column} = :value");
        $stmt->execute(['value' => $value]);
        return $stmt->fetchAll();
    }

    public static function create(array $data): int
    {
        $db = Database::getConnection();
        $columns = implode(', ', array_keys($data));
        $placeholders = ':' . implode(', :', array_keys($data));
        $stmt = $db->prepare("INSERT INTO " . static::$table . " ({$columns}) VALUES ({$placeholders})");
        $stmt->execute($data);
        return (int)$db->lastInsertId();
    }

    public static function update(int $id, array $data): bool
    {
        $db = Database::getConnection();
        $set = [];
        foreach (array_keys($data) as $col) {
            $set[] = "{$col} = :{$col}";
        }
        $set = implode(', ', $set);
        $data['id'] = $id;
        $stmt = $db->prepare("UPDATE " . static::$table . " SET {$set} WHERE " . static::$primaryKey . " = :id");
        return $stmt->execute($data);
    }

    public static function delete(int $id): bool
    {
        $db = Database::getConnection();
        $stmt = $db->prepare("DELETE FROM " . static::$table . " WHERE " . static::$primaryKey . " = :id");
        return $stmt->execute(['id' => $id]);
    }
}
