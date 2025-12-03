# Триггеры с NEW

**Первый пример**

Автозаполнение total_cost, если оно NULL

``` sql
CREATE FUNCTION trg_fill_cost()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.total_cost IS NULL THEN
        NEW.total_cost := 0;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_fill_cost
BEFORE INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_fill_cost();
```

**Второй пример**

Логирование создания заказа

``` sql
CREATE FUNCTION trg_log_new_order()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_logs(order_id, action, user_name)
    VALUES (NEW.order_id, 'Создан заказ', CURRENT_USER);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_log_order
AFTER INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_log_new_order();
```

# Триггеры с OLD

**Первый пример**

Архивируем удаляемый заказ

``` sql
CREATE FUNCTION trg_archive_order()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO orders_archive(order_id, old_status, old_cost)
    VALUES (OLD.order_id, OLD.status, OLD.total_cost);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_delete_archive_order
BEFORE DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_archive_order();
```

**Второй пример**

Логирование удаления

``` sql
CREATE FUNCTION trg_log_delete_order()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_logs(order_id, action, user_name)
    VALUES (OLD.order_id, 'Удалён заказ', CURRENT_USER);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_delete_log_order
AFTER DELETE ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_log_delete_order();
```

# BEFORE триггеры

**Первый пример**

Нельзя менять стоимость доставленного заказа

``` sql
CREATE FUNCTION trg_block_update_delivered()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.status = 'Доставлен' THEN
        RAISE EXCEPTION 'Нельзя менять доставленный заказ';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_update_block_delivered
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_block_update_delivered();
```

**Второй пример**

Проверка корректности веса

``` sql
CREATE FUNCTION trg_check_weight()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.weight <= 0 THEN
        RAISE EXCEPTION 'Вес груза должен быть положительным';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_check_weight
BEFORE INSERT ON cargos
FOR EACH ROW
EXECUTE FUNCTION trg_check_weight();
```

# AFTER триггеры

**Первый пример**

Логирование обновления статуса

``` sql
CREATE FUNCTION trg_log_status_change()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_logs(order_id, action, user_name)
    VALUES (NEW.order_id, 'Изменён статус: ' || NEW.status, CURRENT_USER);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_update_log_status
AFTER UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION trg_log_status_change();
```

AFTER INSERT: создание документа после счёта (invoice)

``` sql
CREATE OR REPLACE FUNCTION trg_create_invoice_document()
RETURNS trigger AS $$
BEGIN
    INSERT INTO documents(order_id, issued_date, document_type)
    VALUES (NEW.order_id, CURRENT_DATE, 'invoice');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_invoice_doc
AFTER INSERT ON invoices
FOR EACH ROW
EXECUTE FUNCTION trg_create_invoice_document();
```

# Row level

Проверка веса груза

``` sql
CREATE OR REPLACE FUNCTION trg_check_cargo_weight()
RETURNS trigger AS $$
BEGIN
    IF NEW.weight <= 0 THEN
        RAISE EXCEPTION 'Weight must be positive';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cargo_weight
BEFORE INSERT OR UPDATE ON cargos
FOR EACH ROW
EXECUTE FUNCTION trg_check_cargo_weight();
```

Авто-обновление mileage машины при поездке

``` sql
CREATE OR REPLACE FUNCTION trg_update_vehicle_mileage()
RETURNS trigger AS $$
DECLARE dist NUMERIC;
BEGIN
    SELECT distance_km INTO dist FROM routes WHERE route_id = NEW.route_id;

    UPDATE vehicles SET mileage = mileage + dist
    WHERE vehicle_id = NEW.vehicle_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_trip_update_vehicle
AFTER INSERT ON trips
FOR EACH ROW
EXECUTE FUNCTION trg_update_vehicle_mileage();
```

# statement level

Логирование массового обновления таблицы orders

``` sql
CREATE TABLE order_mass_update_log(
    updated_at TIMESTAMP DEFAULT now(),
    user_name TEXT
);

CREATE OR REPLACE FUNCTION trg_log_mass_update_orders()
RETURNS trigger AS $$
BEGIN
    INSERT INTO order_mass_update_log(user_name)
    VALUES (current_user);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_orders_mass_update
AFTER UPDATE ON orders
FOR EACH STATEMENT
EXECUTE FUNCTION trg_log_mass_update_orders();
```

Логирование массового удаления из cargos

``` sql
CREATE TABLE cargo_delete_batch_log(
    deleted_at TIMESTAMP DEFAULT now(),
    info TEXT
);

CREATE OR REPLACE FUNCTION trg_cargo_mass_delete()
RETURNS trigger AS $$
BEGIN
    INSERT INTO cargo_delete_batch_log(info)
    VALUES ('Mass delete on cargos table');
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_cargo_mass_delete_log
AFTER DELETE ON cargos
FOR EACH STATEMENT
EXECUTE FUNCTION trg_cargo_mass_delete();
```

# Запрос на просмотр триггеров

``` sql
SELECT event_object_table,
       trigger_name,
       event_manipulation,
       action_timing,
       action_statement
FROM information_schema.triggers
ORDER BY event_object_table;
```

1. 
<img width="780" height="269" alt="image" src="https://github.com/user-attachments/assets/6e7a1184-56e5-435e-bea1-1a582f0d4dda" />

<img width="905" height="315" alt="Снимок экрана 2025-12-02 в 23 46 29" src="https://github.com/user-attachments/assets/bcbd0460-9235-4356-bbfa-5f46a332e194" />
