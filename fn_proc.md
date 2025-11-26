# Процедуры 3 шт + запрос просмотра всех процедур

**Первый пример**

Добавить новый заказ

``` sql
CREATE PROCEDURE add_new_order(
    p_client_id INT,
    p_tariff_id INT,
    p_status VARCHAR DEFAULT 'Новый'
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO orders (client_id, tariff_id, status)
    VALUES (p_client_id, p_tariff_id, p_status);

    INSERT INTO tracking (order_id, status)
    VALUES (currval('orders_order_id_seq'), 'В пути');
END;
$$;
```

**Второй пример**

Обновить статус автомобиля

``` sql
CREATE PROCEDURE update_vehicle_status(
    p_vehicle_id INT,
    p_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE vehicles
    SET status = p_status
    WHERE vehicle_id = p_vehicle_id;
END;
$$;
```

**Третий пример**

Увеличить вместимость склада

``` sql
CREATE PROCEDURE increase_warehouse_capacity(
    p_warehouse_id INT,
    p_delta NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE warehouses
    SET capacity = COALESCE(capacity, 0) + p_delta
    WHERE warehouse_id = p_warehouse_id;
END;
$$;
```

# Запрос просмотра всех процедур

``` sql
SELECT proname AS procedure_name
FROM pg_proc
WHERE prokind = 'p';
```

<img width="280" height="142" alt="Снимок экрана 2025-11-25 212731" src="https://github.com/user-attachments/assets/d8f1ad25-3838-4e3f-9a9c-9b23660deb3b" />


# Функции 3 шт + запрос просмотра всех процедур

**Первый пример**

Получить сумму стоимости заказов клиента

``` sql
CREATE FUNCTION get_client_total_cost(p_client_id INT)
RETURNS NUMERIC AS $$
BEGIN
    RETURN (
        SELECT SUM(total_cost)
        FROM orders
        WHERE client_id = p_client_id
    );
END;
$$ LANGUAGE plpgsql;
```

**Второй пример**

Получить количество грузов по заказу

``` sql
CREATE FUNCTION count_cargos_for_order(p_order_id INT)
RETURNS INT AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM cargos
        WHERE order_id = p_order_id
    );
END;
$$ LANGUAGE plpgsql;
```

**Третий пример**

Получить вес груза по ID

``` sql
CREATE FUNCTION get_cargo_weight(p_cargo_id INT)
RETURNS DOUBLE PRECISION AS $$
BEGIN
    RETURN (
        SELECT weight
        FROM cargos
        WHERE cargo_id = p_cargo_id
    );
END;
$$ LANGUAGE plpgsql;
```

# Запрос просмотра всех функций

``` sql
select routine_name, routine_type
from information_schema.routines
where routine_type = 'FUNCTION' and routine_schema = 'public'
```


<img width="388" height="238" alt="image" src="https://github.com/user-attachments/assets/888e67b6-4220-40b1-9640-b4328dfcf1a8" />

# Функции с переменными 3 шт

**Первый пример**

Итоговая цена груза

``` sql
CREATE FUNCTION calculate_cargo_price(p_cargo_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_weight DOUBLE PRECISION;
    v_price_per_kg NUMERIC;
BEGIN
    SELECT weight INTO v_weight FROM cargos WHERE cargo_id = p_cargo_id;

    SELECT price_per_kg INTO v_price_per_kg
    FROM tariffs
    JOIN orders o ON o.tariff_id = tariffs.tariff_id
    JOIN cargos c ON c.order_id = o.order_id
    WHERE c.cargo_id = p_cargo_id;

    RETURN v_weight * v_price_per_kg;
END;
$$ LANGUAGE plpgsql;
```

**Второй пример**

Проверить доступность автомобиля

``` sql
CREATE FUNCTION is_vehicle_available(p_vehicle_id INT)
RETURNS BOOLEAN AS $$
DECLARE
    v_status VARCHAR;
BEGIN
    SELECT status INTO v_status
    FROM vehicles
    WHERE vehicle_id = p_vehicle_id;

    RETURN v_status = 'Доступен';
END;
$$ LANGUAGE plpgsql;
```

**Третий пример**

Сколько заказов в маршруте

``` sql
CREATE FUNCTION count_orders_in_trip(p_trip_id INT)
RETURNS INT AS $$
DECLARE
    v_cnt INT;
BEGIN
    SELECT COUNT(*) INTO v_cnt
    FROM orders
    WHERE trip_id = p_trip_id;

    RETURN v_cnt;
END;
$$ LANGUAGE plpgsql;
```

# Блок DO 3 шт

**Первый пример**

Поднять вместимость всех складов на 10%

``` sql
DO $$
BEGIN
    UPDATE warehouses
    SET capacity = capacity * 1.1;
END $$;
```

**Второй пример**

Создать первый заказ, если нет ни одного

``` sql
DO $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count FROM orders;

    IF v_count = 0 THEN
        INSERT INTO orders (client_id, status)
        VALUES (1, 'Новый');
    END IF;
END $$;
```

**Третий пример**

Удалить все грузы весом меньше 1 кг

``` sql
DO $$
BEGIN
    DELETE FROM cargos
    WHERE weight < 1;
END $$;
```
