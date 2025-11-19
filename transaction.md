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

<img width="357" height="111" alt="Снимок экрана 2025-11-19 085047" src="https://github.com/user-attachments/assets/06282bbe-1a4a-40ac-aff2-eaebd8b36cb0" />


``` sql
COMMIT;
```

**Второй пример**

Терминал 1

``` sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT COUNT(*) FROM cargos;
```

Терминал 2

``` sql
BEGIN;

INSERT INTO cargos(order_id, description, weight, package_type, price)
VALUES (23, 'Новый груз', 15.0, 'Коробка', 2000);

COMMIT;
```

Терминал 1

``` sql
SELECT COUNT(*) FROM cargos;
```

# SERIALIZABLE

**Первый пример**

Терминал 1

``` sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO clients(name) VALUES ('ConflictClient');
```

Терминал 2

``` sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO clients(name) VALUES ('ConflictClient');
```

Терминал 1

``` sql
COMMIT;
```

Терминал 2

``` sql
Ошибка
```

Терминал 2 - Без ошибки

``` sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO clients(name) VALUES ('ConflictClient');  

ROLLBACK; 
```

# SAVEPOINT

**Первый пример**

``` sql
BEGIN;

INSERT INTO payments(order_id, amount, payment_date, method, status)
VALUES (1, 1000, CURRENT_DATE, 'Карта', 'Проведён');

INSERT INTO payments(order_id, amount, payment_date, method, status)
VALUES (1, 2000, CURRENT_DATE, 'Наличные', 'Проведён');

SAVEPOINT s1;
```

Вставка, дающая ошибку

``` sql
INSERT INTO payments(payment_id, order_id, amount, payment_date, method, status)
VALUES (1, 1, 9999, CURRENT_DATE, 'Карта', 'Проведён');
```

Откат

``` sql
ROLLBACK TO SAVEPOINT s1;
```

Завершение

``` sql
COMMIT;
```

**Второй пример**

``` sql
BEGIN;

INSERT INTO cargos(order_id, description, weight, package_type, price)
VALUES (21, 'X', 10, 'Коробка', 100);

SAVEPOINT p1;

INSERT INTO cargos(order_id, description, weight, package_type, price)
VALUES (21, 'Y', 20, 'Коробка', 200);

SAVEPOINT p2;

INSERT INTO cargos(order_id, description, weight, package_type, price)
VALUES (21, 'Z', 30, 'Коробка', 300);
```

Откат на p2

``` sql
ROLLBACK TO SAVEPOINT p2;
```

Отменяется только вставка Z.

Откат на p1

``` sql
ROLLBACK TO SAVEPOINT p1;
```

Отменяется вставка Y.
X остаётся.

Завершение:

``` sql
COMMIT;
```
