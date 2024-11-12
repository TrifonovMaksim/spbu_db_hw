-- Создаем базу
CREATE DATABASE hw1;


-- Подключаемся к базе
\c hw1


-- Создаем таблицу courses
CREATE TABLE courses (
    id SERIAL PRIMARY KEY ,
    name VARCHAR(50) NOT NULL,
    is_exam BOOLEAN NOT NULL,
    min_grade INTEGER,
    max_grade INTEGER
);

-- Заполняем таблицу
INSERT INTO  courses (name, is_exam, min_grade, max_grade) VALUES
('Math', TRUE, 0, 100),
('English', TRUE, 0, 100),
('PE', FALSE, 60, 100),
('Russian', FALSE, 60, 100);

SELECT * FROM courses;

-- Создаем таблицу students
CREATE TABLE students (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    group_id INTEGER,
    courses_ids INTEGER[]
);

-- Заполняем таблицу
INSERT INTO  students (first_name, last_name, group_id, courses_ids)  VALUES
('Ivan', 'Ivanov', 1, '{1,2,3,4}'),
('Petr', 'Petrov', 2, '{1,2,3}'),
('Sergey', 'Sergeev', 2, '{1,2,3}'),
('Anton', 'Antonov', 1, '{1,2,3,4}'),
('Viktor', 'Viktorov', 1, '{1,2,3,4}'),
('Semen', 'Semenov', 2, '{1,2,3}');

-- Создаем таблицу groups
CREATE TABLE groups (
    id SERIAL PRIMARY KEY ,
    full_name VARCHAR(100) NOT NULL,
    short_name VARCHAR(25) NOT NULL,
    students_ids INTEGER[]
);

-- Заполняем таблицу
INSERT INTO  groups (full_name, short_name, students_ids)  VALUES
('Энергетика и электротехника 2024 год', 'ЭЭ-24', '{1,4,5}'),
('Прикладная математика 2024 год', 'ПМ-24', '{2,3,6}');

-- Создаем таблицу math
CREATE TABLE Math (
    student_id INTEGER,
    grade INTEGER,
    grade_str VARCHAR(1)
);

-- Заполняем таблицу
WITH random_grades AS (
    SELECT
        students.id,
        (FLOOR(RANDOM() * 101))::INTEGER AS grade
    FROM students
)
INSERT INTO Math (student_id, grade, grade_str)
SELECT
    random_grades.id,
    random_grades.grade,
    CASE
        WHEN random_grades.grade < 60 THEN 'D'
        WHEN random_grades.grade >= 60 AND random_grades.grade < 80 THEN 'C'
        WHEN random_grades.grade >= 80 AND random_grades.grade < 90 THEN 'B'
        ELSE 'A'
    END AS grade_str
FROM random_grades;
