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
