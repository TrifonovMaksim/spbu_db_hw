-- проверка перед вставкой
CREATE OR REPLACE FUNCTION pet_type()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.type NOT IN ('Собака', 'Кошка') THEN
        RAISE EXCEPTION 'Недопустимый тип питомца: %', NEW.type;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_pets
BEFORE INSERT ON pets
FOR EACH ROW
EXECUTE FUNCTION pet_type();

-- после вставки записи добавляем это в лог
CREATE OR REPLACE FUNCTION procedure_insert()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Процедура "%", выполнена для питомца с ID %', NEW.procedure_name, NEW.pet_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_procedures
AFTER INSERT ON procedures
FOR EACH ROW
EXECUTE FUNCTION procedure_insert();

-- количество процедур в лог
CREATE OR REPLACE FUNCTION count_pet_procedures()
RETURNS TRIGGER AS $$
DECLARE
    procedure_count INT;
BEGIN
    SELECT COUNT(*) INTO procedure_count
    FROM procedures
    WHERE pet_id = NEW.pet_id;

    RAISE NOTICE 'Для питомца с ID % выполнено % процедур', NEW.pet_id, procedure_count + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_procedure_log
AFTER INSERT OR DELETE ON procedures
FOR EACH ROW
EXECUTE FUNCTION count_pet_procedures();

-- добавление если корректно
BEGIN;

INSERT INTO owners (name, phone)
VALUES ('Алексей Смирнов', '+79101234567');

WITH last_owner AS (
    SELECT owner_id FROM owners ORDER BY owner_id DESC LIMIT 1
)
INSERT INTO pets (name, type, breed, birth_date, owner_id, last_procedure, last_procedure_date)
SELECT 'Барсик', 'Кошка', 'Британская', '2023-08-15', owner_id, 'Вакцинация', '2023-11-01'
FROM last_owner;

COMMIT;

-- ошибочная транзакция(недопустимый тип)
BEGIN;

INSERT INTO pets (name, type, breed, birth_date, owner_id, last_procedure, last_procedure_date)
VALUES ('Кеша', 'Попугай', 'Обычный', '2023-02-20', 1, 'Вакцинация', '2023-12-01');

COMMIT;
