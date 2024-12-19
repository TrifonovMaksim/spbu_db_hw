CREATE TABLE owners (
    owner_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(12) NOT NULL
);

CREATE TABLE pets (
    pet_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL ,
    type VARCHAR(20) NOT NULL ,
    breed VARCHAR(30) NOT NULL ,
    birth_date DATE NOT NULL ,
    owner_id INT REFERENCES owners(owner_id),
    last_procedure VARCHAR(30) NOT NULL ,
    last_procedure_date DATE NOT NULL
);

CREATE TABLE procedures (
    procedure_id SERIAL PRIMARY KEY,
    pet_id INT REFERENCES pets(pet_id),
    procedure_name VARCHAR(30) NOT NULL,
    procedure_date DATE NOT NULL
);

INSERT INTO owners (name, phone)
VALUES
('Иван Иванов', '+79991234567'),
('Петров Петр', '+79876543210'),
('Владимир Путин', '+79213456789');

INSERT INTO pets (name, type, breed, birth_date, owner_id, last_procedure, last_procedure_date)
VALUES
('Шарик', 'Собака', 'Лабрадор', '2020-06-15', 1, 'Вакцинация', '2023-10-01'),
('Мурка', 'Кошка', 'Сфинкс', '2019-03-22', 2, 'Стерилизация', '2023-09-15'),
('Рекс', 'Собака', 'Овчарка', '2018-11-05', 1, 'Чистка зубов', '2023-11-10'),
('Снежок', 'Кролик', 'Декоративный', '2022-01-12', 3, 'Стерилизация', '2023-12-14');

INSERT INTO procedures (pet_id, procedure_name, procedure_date)
VALUES
(1, 'Вакцинация', '2023-10-01'),
(1, 'Груминг', '2023-08-01'),
(2, 'Стерилизация', '2023-09-15'),
(2, 'Обследование', '2023-07-20'),
(3, 'Чистка зубов', '2023-11-10'),
(3, 'Вакцинация', '2023-05-15'),
(4, 'Стерилизация', '2023-12-14');

SELECT * FROM owners
LIMIT 5;

SELECT pets.name AS pet_name, owners.name AS owner_name, owners.phone
FROM pets
JOIN owners ON pets.owner_id = owners.owner_id
LIMIT 5;

SELECT name, type, last_procedure, last_procedure_date
FROM pets
WHERE last_procedure_date > '2023-11-01'
LIMIT 5;

SELECT procedure_name, procedure_date
FROM procedures
WHERE pet_id = 1
ORDER BY procedure_date DESC
LIMIT 5;

SELECT COUNT(*) AS total_pets
FROM pets
LIMIT 1;

SELECT type, COUNT(*) AS count_by_type
FROM pets
GROUP BY type
LIMIT 5;

SELECT pets.name AS pet_name, COUNT(procedures.procedure_id) AS procedure_count
FROM pets
LEFT JOIN procedures ON pets.pet_id = procedures.pet_id
GROUP BY pets.pet_id, pets.name
LIMIT 5;

SELECT type, MIN(birth_date) AS earliest_birth_date
FROM pets
GROUP BY type
LIMIT 5;

SELECT procedure_name, COUNT(*) AS usage_count
FROM procedures
GROUP BY procedure_name
ORDER BY usage_count DESC
LIMIT 5;