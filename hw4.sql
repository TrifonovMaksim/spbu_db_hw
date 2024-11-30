CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    manager_id INT REFERENCES employees(employee_id)
);

-- Пример данных
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);


SELECT * FROM employees LIMIT 5;

CREATE TABLE IF NOT EXISTS sales(
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);

-- Пример данных
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (2, 1, 20, '2024-10-15'),
    (2, 2, 15, '2024-10-16'),
    (3, 1, 10, '2024-10-17'),
    (3, 3, 5, '2024-10-20'),
    (4, 2, 8, '2024-10-21'),
    (2, 1, 12, '2024-11-01');

SELECT * FROM sales LIMIT 5;


CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- Пример данных
INSERT INTO products (name, price)
VALUES
    ('Product A', 150.00),
    ('Product B', 200.00),
    ('Product C', 100.00);



--
--
-- Триггеры
--
--

CREATE OR REPLACE FUNCTION function_name()
RETURNS TRIGGER AS $$
BEGIN
    -- Логика действия

    -- RETURN NEW;  -- Для триггеров BEFORE (вставка/обновление) и AFTER INSERT/UPDATE
    -- RETURN OLD;  -- Для триггеров DELETE или если нужно сохранить старые данные
END;
$$ LANGUAGE plpgsql;

-- CREATE TRIGGER trigger_name
-- {BEFORE | AFTER | INSTEAD OF} {INSERT | UPDATE | DELETE | TRUNCATE}
-- ON table_name
-- [FOR EACH ROW | FOR EACH STATEMENT]
-- [WHEN (condition)]  -- Условие (опционально)
-- EXECUTE FUNCTION function_name();



--- {BEFORE | AFTER | INSTEAD OF}
--- BEFORE - перед событием. Позволяет модифицировать данные.
--- AFTER - после события. Используется, если данные уже изменились
--- INSTEAD OF - применяется для представлений (VIEW), чтобы переопределить действие

-- Функция для проверки зарплаты
CREATE OR REPLACE FUNCTION check_salary()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.salary < 25000 THEN
        RAISE EXCEPTION 'Зарплата должна быть больше минимальной';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Триггер, вызывающий эту функцию
CREATE TRIGGER salary_check_trigger
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
WHEN (NEW.salary IS NOT NULL)  -- Условие: срабатывает только если указана зарплата
EXECUTE FUNCTION check_salary();

--- Задание 1. Добавьте нового сотрудника с минимальной зарплатой 15000 рублей. Что произойдет? Как изменится результат,
--  если в 1 запрос положить сотрудника подходящего по условию и не подходящего. Влияет ли порядок записей на исполнение?
---






























INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 15000, NULL),
    ('X', 'Manager', 'Sales', 35000, NULL);


SELECT * FROM employees LIMIT 200;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
     ('X', 'Manager', 'Sales', 35000, NULL),
    ('Alice Johnson', 'Manager', 'Sales', 15000, NULL);

SELECT * FROM employees LIMIT 200;





---- Другие разновидности триггеров
CREATE TABLE IF NOT EXISTS employees_archive (
    archive_id SERIAL PRIMARY KEY,
    employee_id INT,
    name VARCHAR(50),
    position VARCHAR(50),
    department VARCHAR(50),
    salary NUMERIC(10, 2),
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE FUNCTION archive_employee()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO employees_archive (employee_id, name, position, department, salary)
    VALUES (OLD.employee_id, OLD.name, OLD.position, OLD.department, OLD.salary);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_archive_employee
BEFORE DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION archive_employee();

DELETE FROM employees WHERE employee_id = 120;

SELECT * FROM employees WHERE employee_id = 120;

SELECT * FROM employees_archive WHERE employee_id = 120;




--- Задание 2. Напишите свой собственный триггер

















-- Отладочное сообщение
-- RAISE NOTICE 'Ваше сообщение: %', значение1 [, значение2, ...];



CREATE OR REPLACE FUNCTION update_salary_on_position_change()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Position changed: % -> %', OLD.position, NEW.position;
    IF NEW.position = 'Manager' THEN
        NEW.salary = 100000;
    ELSIF NEW.position = 'Developer' THEN
        NEW.salary = 80000;
    ELSE
        NEW.salary = 60000;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_update_salary
BEFORE UPDATE ON employees
FOR EACH ROW
WHEN (OLD.position IS DISTINCT FROM NEW.position)
EXECUTE FUNCTION update_salary_on_position_change();



-- Задание 3. Добавьте в свой триггер RAISE NOTICE, посмотрите: где отобразился вывод

















INSERT INTO employees (name, position, department, salary)
VALUES
    ('Test', 'Tester', 'QA', 30000);


SELECT * FROM employees WHERE name = 'Test' LIMIT 5;

UPDATE employees
SET name = 'Test2'
WHERE name = 'Test';

SELECT * FROM employees WHERE name = 'Test2' LIMIT 5;

UPDATE employees
SET position = 'Manager'
WHERE name = 'Test2';

SELECT * FROM employees WHERE name = 'Test2' LIMIT 5;

DELETE FROM employees WHERE name ILIKE '%Test%';



-- Уровни сообщений RAISE
-- DEBUG: Для детальной отладки. Используется при разработке и решении сложных проблем.
-- LOG: Записывает сообщения в журнал PostgreSQL, но не выводит их клиенту.
-- NOTICE: Информационные сообщения, видимые пользователю (наиболее часто используется для отладки).
-- WARNING: Предупреждения, которые не прерывают выполнение, но требуют внимания.
-- EXCEPTION: Вызывает ошибку, прерывает выполнение и откатывает текущую транзакцию.





-- Транзакции

BEGIN;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('X', 'Manager', 'Sales', 35000, NULL);



INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('Alice Johnson', 'Manager', 'Sales', 15000, NULL);

-- Подтверждаем транзакцию
COMMIT;

-- Откат транзакции
ROLLBACK;


-- Домашнее задание
-- 1. Создать триггеры со всеми возможными ключевыми словами, а также рассмотреть операционные триггеры
CREATE OR REPLACE FUNCTION track_salary_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.salary <> OLD.salary THEN
        RAISE NOTICE 'Зарплата сотрудника % изменилась на %', OLD.name, NEW.salary;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_salary_update
BEFORE UPDATE ON employees
FOR EACH ROW
WHEN (OLD.salary IS DISTINCT FROM NEW.salary)
EXECUTE FUNCTION track_salary_changes();

CREATE OR REPLACE FUNCTION log_new_sales()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'новая продажа: ID = %, продукт = %, количество = %, сотрудник = %',
        NEW.sale_id, NEW.product_id, NEW.quantity, NEW.employee_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_sale_insert
AFTER INSERT ON sales
FOR EACH ROW
EXECUTE FUNCTION log_new_sales();
-- 2. Попрактиковаться в созданиях транзакций (привести пример успешной и фейл транзакции, объяснить в комментариях почему она зафейлилась)
BEGIN;
INSERT INTO employees (name, position, department, salary, manager_id) VALUES ('Test Employee', 'Tester', 'QA', 40000, NULL);
INSERT INTO sales (employee_id, product_id, quantity, sale_date) VALUES (1, 1, 10, '2024-12-01');
COMMIT;

BEGIN;
INSERT INTO sales (employee_id, products_id, quantity, sale_date) VALUES (1, 2, 5, '2024-12-02');


ROLLBACK;
--Столбец products_id не существует

-- 3. Использовать RAISE для логирования
DO $$
BEGIN
    RAISE NOTICE 'Проверка продуктов';

    IF EXISTS (SELECT 1 FROM products WHERE price > 100) THEN
        RAISE NOTICE 'Найдены продукты с ценой выше 100';
    ELSE
        RAISE WARNING 'Нет продуктов с ценой выше 100';
    END IF;

    RAISE NOTICE 'Проверка завершена';
END;
$$;