-- Создаем базу
CREATE DATABASE hw1;


-- Подключаемся к базе
\CONNECT hw1


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
CREATE TABLE math (
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
    LIMIT 6
)
INSERT INTO math (student_id, grade, grade_str)
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

-- Создаем таблицу English
CREATE TABLE english (
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
    LIMIT 6
)
INSERT INTO english (student_id, grade, grade_str)
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

-- Создаем таблицу PE
CREATE TABLE pe (
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
    LIMIT 6
)
INSERT INTO pe (student_id, grade, grade_str)
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

-- Создаем таблицу Russian
CREATE TABLE russian (
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
    LIMIT 6
)
INSERT INTO russian (student_id, grade, grade_str)
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

-- Создаем промежуточную таблицу student_courses
CREATE TABLE student_courses (
    id SERIAL PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    UNIQUE (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

INSERT INTO student_courses (student_id, course_id)
SELECT id, unnest(courses_ids) AS course_id
FROM students;

-- Создаем промежуточную таблицу group_courses
CREATE TABLE group_courses (
    id SERIAL PRIMARY KEY,
    group_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    UNIQUE (group_id, course_id),
    FOREIGN KEY (group_id) REFERENCES groups(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

INSERT INTO group_courses (group_id, course_id)
SELECT DISTINCT
    students.group_id,
    student_courses.course_id
FROM
    students
JOIN
    student_courses  ON students.id = student_courses.student_id
LIMIT 100
ON CONFLICT (group_id, course_id) DO NOTHING;

--Удаляем неактуальные поля
ALTER TABLE students DROP COLUMN courses_ids;

--Добавляем уникальное ограничение на поле name
ALTER TABLE courses
ADD UNIQUE (name);

--Создаем индекс на поле group_id
CREATE INDEX group_id_idx
ON students (group_id);
--Индекс усоряет поиск, при частых запросах с фильтрацией по group_id

--Сделаем запрос для списка всех студентов с их курсами
SELECT
    student_courses.student_id,
    students.first_name,
    students.last_name,
    student_courses.course_id,
    courses.name
FROM
    student_courses
JOIN
    students ON student_courses.student_id = students.id
JOIN
    courses ON student_courses.course_id = courses.id
LIMIT 100;

--Найдем студентов у которых средняя оценка по курсам выше
WITH average_grades AS (
    SELECT
        s.id,
        s.first_name,
        s.last_name,
        s.group_id,
        (m.grade + e.grade + pe.grade + r.grade) / 4.0 AS average_grade
    FROM
        students s
    LEFT JOIN
        math m ON s.id = m.student_id
    LEFT JOIN
        english e ON s.id = e.student_id
    LEFT JOIN
        pe ON s.id = pe.student_id
    LEFT JOIN
        russian r ON s.id = r.student_id
)
SELECT
    ag.first_name,
    ag.last_name,
    ag.group_id,
    ag.average_grade
FROM
    average_grades ag
WHERE
    ag.average_grade > (
        SELECT
            MAX(average_grade)
        FROM
            average_grades ag2
        WHERE
            ag2.group_id = ag.group_id
            AND ag2.id != ag.id
    )
LIMIT 100;

--Подсчитаем количество студентов на каждом курсе
SELECT
    c.name,
    COUNT(s_c.student_id) AS student_count
FROM
    student_courses AS s_c
JOIN
    courses c ON s_c.course_id = c.id
GROUP BY
    s_c.course_id, c.name
LIMIT 100;

--Найдем среднюю оценку на каждом курсе
SELECT
    'Russian' AS course_name,
    AVG(grade) AS average_grade
FROM
    russian
UNION ALL
SELECT
    'mMath' AS course_name,
    AVG(grade) AS average_grade
FROM
    math
UNION ALL
SELECT
    'English' AS course_name,
    AVG(grade) AS average_grade
FROM
    english
UNION ALL
SELECT
    'Physical Education' AS course_name,
    AVG(grade) AS average_grade
FROM
    pe
LIMIT 100;

