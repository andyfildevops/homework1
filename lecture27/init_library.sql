-- Створення бази даних
CREATE DATABASE IF NOT EXISTS library;
USE library;

-- Таблиця авторів
CREATE TABLE IF NOT EXISTS authors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(255)
);

-- Таблиця книг
CREATE TABLE IF NOT EXISTS books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author_id INT,
    genre VARCHAR(50),
    FOREIGN KEY (author_id) REFERENCES authors(id)
);

-- Таблиця статусу читання
CREATE TABLE IF NOT EXISTS reading_status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT,
    status ENUM('reading', 'completed', 'planned') NOT NULL,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(id)
);

-- Вставка авторів
INSERT INTO authors (name, country) VALUES 
('George Orwell', 'United Kingdom'),
('J.K. Rowling', 'United Kingdom'),
('Haruki Murakami', 'Japan');

-- Вставка книг
INSERT INTO books (title, author_id, genre) VALUES 
('1984', 1, 'Dystopian'),
('Harry Potter and the Philosopher\'s Stone', 2, 'Fantasy'),
('Kafka on the Shore', 3, 'Magical realism');

-- Вставка статусу читання
INSERT INTO reading_status (book_id, status) VALUES 
(1, 'reading');
