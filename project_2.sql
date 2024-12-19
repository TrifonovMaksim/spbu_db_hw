-- создание временной таблицы о процедурах за последние 2 года
CREATE TEMP TABLE recent_procedures AS
SELECT p.pet_id, p.name AS pet_name, pr.procedure_name, pr.procedure_date
FROM pets p
JOIN procedures pr ON p.pet_id = pr.pet_id
WHERE pr.procedure_date >= NOW() - INTERVAL '2 years'
LIMIT 100;

SELECT * FROM recent_procedures
LIMit 100;

-- представление вывода информации о питомцах и их владельцах
CREATE OR REPLACE VIEW pets_and_owners AS
SELECT
    p.name AS pet_name,
    p.type AS pet_type,
    p.breed AS pet_breed,
    o.name AS owner_name,
    o.phone AS owner_phone
FROM pets p
JOIN owners o ON p.owner_id = o.owner_id
LIMIT 1000;

SELECT * FROM pets_and_owners WHERE pet_type = 'Собака'
LIMIT 800;

-- ограничение на тип живаотного
ALTER TABLE pets
ADD CONSTRAINT check_pet_type CHECK (type IN ('Собака', 'Кошка', 'Кролик'));

-- количество процедур для каждого питомца
WITH procedure_counts AS (
    SELECT
        pet_id,
        COUNT(procedure_id) AS total_procedures
    FROM procedures
    GROUP BY pet_id
)
SELECT
    p.name AS pet_name,
    p.type AS pet_type,
    pc.total_procedures
FROM pets p
LEFT JOIN procedure_counts pc ON p.pet_id = pc.pet_id
ORDER BY pc.total_procedures DESC
LIMIT 100;

-- индекс для ускорения поиска по типу животного
CREATE INDEX idx_pets_type ON pets(type);

EXPLAIN ANALYZE
SELECT *
FROM pets
WHERE type = 'Собака';

-- животные старше 1 года
WITH older_than_1_year_pets AS (
    SELECT
        pet_id,
        name AS pet_name,
        type AS pet_type,
        DATE_PART('year', AGE(birth_date)) AS age
    FROM pets
    WHERE DATE_PART('year', AGE(birth_date)) >= 1
)
SELECT
    pet_name,
    pet_type,
    age
FROM older_than_1_year_pets
LIMIT 50;