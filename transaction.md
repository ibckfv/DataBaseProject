# REPEATABLE READ

**Первый пример**

Терминал 1

``` sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT order_id, status FROM orders ORDER BY order_id;
```

Терминал 2

``` sql
BEGIN;

UPDATE orders
SET status = 'Доставлен'
WHERE order_id = 21;

COMMIT;
```

Терминал 1

``` sql
SELECT order_id, status FROM orders ORDER BY order_id;
```

``` sql
COMMIT;
```
