# REPEATABLE READ

**Первый пример**

Терминал 1

``` sql
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;

SELECT order_id, status FROM orders ORDER BY order_id;
```

<img width="358" height="109" alt="Снимок экрана 2025-11-19 085003" src="https://github.com/user-attachments/assets/642f12b0-61fc-4415-8ab4-75bfa9d4db1d" />


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

<img width="131" height="79" alt="Снимок экрана 2025-11-19 085528" src="https://github.com/user-attachments/assets/52350f76-5370-4e55-bc29-93f8e2e20a4b" />


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

<img width="128" height="82" alt="Снимок экрана 2025-11-19 090050" src="https://github.com/user-attachments/assets/220f8964-54b0-4f5d-be6b-df5d0118c0a0" />


# SERIALIZABLE

**Первый пример**

Терминал 1

``` sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

INSERT INTO clients(name) VALUES ('ConflictClient');
```

<img width="412" height="96" alt="Снимок экрана 2025-11-19 090348" src="https://github.com/user-attachments/assets/a4cedc8b-5a18-4e16-aec8-1910d6384f57" />


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

**Второй пример**

Терминал 1

``` sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT * FROM orders WHERE total_cost > 1000;
```

Терминал 2

BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

``` sql
INSERT INTO orders (tariff_id, status, client_id, total_cost)
VALUES (21, 'Новый', 1, 2000);

COMMIT;
```

Терминал 1 - Ошибка

``` sql
SELECT * FROM orders WHERE total_cost > 1000;
```

Терминал 1 - Откат

``` sql
ROLLBACK;
```

Терминал 1 - По правильному

``` sql
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SELECT * FROM orders WHERE total_cost > 1000;

COMMIT;
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

<img width="417" height="90" alt="Снимок экрана 2025-11-19 090955" src="https://github.com/user-attachments/assets/ebf3cd13-814d-4122-afd7-dcc34114aa39" />


Вставка, дающая ошибку

``` sql
INSERT INTO payments(payment_id, order_id, amount, payment_date, method, status)
VALUES (1, 1, 9999, CURRENT_DATE, 'Карта', 'Проведён');
```

<img width="788" height="115" alt="Снимок экрана 2025-11-19 091029" src="https://github.com/user-attachments/assets/a1450e57-cf7a-4f52-81dd-b0be1436d931" />


Откат

``` sql
ROLLBACK TO SAVEPOINT s1;
```

<img width="401" height="86" alt="Снимок экрана 2025-11-19 091044" src="https://github.com/user-attachments/assets/cdcbc7bc-12e6-4644-af6c-94a24ddc9d2e" />


Завершение

``` sql
COMMIT;
```

<img width="391" height="103" alt="Снимок экрана 2025-11-19 091114" src="https://github.com/user-attachments/assets/bceaf32a-946a-4d1b-89ec-9597d54947a7" />


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

<img width="404" height="94" alt="Снимок экрана 2025-11-19 091322" src="https://github.com/user-attachments/assets/96f8d208-0e7d-4719-91b5-e13b2bc8a3b3" />


Откат на p2

``` sql
ROLLBACK TO SAVEPOINT p2;
```

<img width="403" height="88" alt="Снимок экрана 2025-11-19 091347" src="https://github.com/user-attachments/assets/d73d404e-86b5-45e7-97ec-05bc5cfccd27" />


Отменяется только вставка Z.

Откат на p1

``` sql
ROLLBACK TO SAVEPOINT p1;
```

<img width="400" height="89" alt="Снимок экрана 2025-11-19 091358" src="https://github.com/user-attachments/assets/ece31077-b0bd-47ad-8a61-b0fffbdcde66" />


Отменяется вставка Y.
X остаётся.

Завершение:

``` sql
COMMIT;
```

<img width="410" height="83" alt="Снимок экрана 2025-11-19 091414" src="https://github.com/user-attachments/assets/48cd20ce-bbcb-4575-8eb6-de7d679ca440" />
