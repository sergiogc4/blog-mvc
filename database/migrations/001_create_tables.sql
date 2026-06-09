-- Crear base de datos
CREATE DATABASE IF NOT EXISTS `blog_mvc` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `blog_mvc`;

-- Tabla de usuarios
CREATE TABLE `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `avatar` VARCHAR(255) DEFAULT NULL,
    `bio` TEXT DEFAULT NULL,
    `email_verified_at` TIMESTAMP NULL DEFAULT NULL,
    `last_login_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla de posts
CREATE TABLE `posts` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `slug` VARCHAR(255) NOT NULL UNIQUE,
    `content` TEXT NOT NULL,
    `excerpt` VARCHAR(500) DEFAULT NULL,
    `featured_image` VARCHAR(255) DEFAULT NULL,
    `author_id` INT NOT NULL,
    `status` ENUM('draft', 'published', 'archived') DEFAULT 'published',
    `views_count` INT DEFAULT 0,
    `published_at` TIMESTAMP NULL DEFAULT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`author_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_author` (`author_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_published_at` (`published_at`),
    FULLTEXT `idx_search` (`title`, `content`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;