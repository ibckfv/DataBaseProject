# Триггеры с NEW

**Первый пример**

Автозаполнение total_cost, если оно NULL

``` sql
CREATE OR REPLACE FUNCTION trg_fill_cost()
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
CREATE OR REPLACE FUNCTION trg_log_new_order()
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
