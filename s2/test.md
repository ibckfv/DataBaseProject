## 1 Задание

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, shop_id, total_sum, sold_at
FROM store_checks
WHERE shop_id = 77
  AND sold_at >= TIMESTAMP '2025-02-14 00:00:00'
  AND sold_at < TIMESTAMP '2025-02-15 00:00:00';
```

<img width="968" height="315" alt="image" src="https://github.com/user-attachments/assets/71d5e201-7112-4073-9bbb-728cc625d51e" />

- тип сканирования: Seq Scan
- не помогают: idx_store_checks_payment_type, idx_store_checks_total_sum_hash
- помтому что нет индекса по столбцу sold_at

CREATE INDEX idx_store_checks_sold_at ON store_checks (sold_at);

<img width="974" height="449" alt="image" src="https://github.com/user-attachments/assets/8ff68794-811c-4adb-9276-9a3dbf2dd97a" />

- изменился тип сканирования на Bitmap Heap scan, потому что теперь есть индекс по столбцу sold_at
- выполнять analyze нужно, как минимум чтобы проверить работает ли индекс и насколько стало лучше или хуже

## 2 Задание

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT m.id, m.member_level, v.spend, v.visit_at
FROM club_members m
JOIN club_visits v ON v.member_id = m.id
WHERE m.member_level = 'premium'
  AND v.visit_at >= TIMESTAMP '2025-02-01 00:00:00'
  AND v.visit_at < TIMESTAMP '2025-02-10 00:00:00';
```

<img width="950" height="593" alt="image" src="https://github.com/user-attachments/assets/3bf24d1d-1ab8-4e18-85c9-182be236d304" />
<img width="944" height="124" alt="image" src="https://github.com/user-attachments/assets/0f114c05-b257-41df-add3-d9bbd81c8d4a" />


- использован Hash join
- idx_club_members_full_name бесполезен, idx_club_visits_visit_at полезен слабо
- чтобы улучшить нужно создать индекс CREATE INDEX idx_club_members_member_level ON club_members USING HASH (member_level);

<img width="954" height="579" alt="image" src="https://github.com/user-attachments/assets/b9423178-a68c-454a-aa5f-fd424fc835b4" />
<img width="956" height="132" alt="image" src="https://github.com/user-attachments/assets/efb7425a-48b9-4d5e-8877-e307a1226ba1" />

- план улучшился, засчет хеш индекса на member_level

## 3 Задание

```sql
SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;
```

<img width="535" height="145" alt="image" src="https://github.com/user-attachments/assets/4a607f42-e4ea-4246-980c-b4a0643f8d17" />

```sql
SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;
```

```sql
UPDATE warehouse_items
SET stock = stock - 2
WHERE id = 1;
```

```sql
SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;
```

<img width="533" height="134" alt="image" src="https://github.com/user-attachments/assets/d76c8be2-ad4d-4729-b097-202c18688b05" />

- у строки где делалось обновление изменился xmin и ctid

```sql
DELETE FROM warehouse_items
WHERE id = 3;
```

```sql
SELECT xmin, xmax, ctid, id, title, stock
FROM warehouse_items
ORDER BY id;
```

<img width="535" height="117" alt="image" src="https://github.com/user-attachments/assets/de163ff0-eb95-4956-95cb-84035f2a9976" />

- после удаления строка стала помечена "мертвой" селект не выводит такие строки

- VACUUM: не блокирует таблицу, не возвращает память ос
- autovacuum: выполняется в фоне, не блокирует таблицу, не возвращает память ос
- VACUUM FULL: блокирует таблицу полностью перестраивает ее, возвращает память ос
- полностью блокировать таблицу может VACUUM FULL

## 4 Задание

В сессии `A` выполните:

```sql
BEGIN;
SELECT * FROM booking_slots WHERE id = 1 FOR KEY SHARE;
```

<img width="418" height="76" alt="image" src="https://github.com/user-attachments/assets/b6dbebd0-2a3b-46f3-832d-1aa5a7066824" />

В сессии `B` выполните:

```sql
DELETE FROM booking_slots
WHERE id = 1;
```

<img width="957" height="311" alt="Снимок экрана 2026-04-01 112224" src="https://github.com/user-attachments/assets/7f2c7a58-bc7d-4638-9088-e3ff650de39a" />

После наблюдения результата завершите сессию `A`:

```sql
ROLLBACK;
```

<img width="483" height="75" alt="Снимок экрана 2026-04-01 112236" src="https://github.com/user-attachments/assets/e1eee055-f754-4e36-b7d6-3056ef2ae05f" />

Затем повторите эксперимент.

В сессии `A` выполните:

```sql
BEGIN;
SELECT * FROM booking_slots WHERE id = 1 FOR NO KEY UPDATE;
```
<img width="456" height="123" alt="image" src="https://github.com/user-attachments/assets/8a9c9737-813d-40b4-8e98-a2d7acbba475" />

В сессии `B` выполните:

```sql
UPDATE booking_slots
SET reserved_count = reserved_count + 1
WHERE id = 1;
```

<img width="456" height="123" alt="image" src="https://github.com/user-attachments/assets/1266e20c-2d1b-4a13-818b-73c14a3edd50" />

После наблюдения результата завершите сессию `A`:

```sql
ROLLBACK;
```

<img width="433" height="112" alt="image" src="https://github.com/user-attachments/assets/fb5f47ad-e99b-49a6-a4ac-37d29b7546ff" />

- в случае с delete он ждет конца транзакции сессии А, в случае с update выполняется сразу

## 5 Задание 

```sql
CREATE TABLE shipment_stats (
    region_code TEXT NOT NULL,
    shipped_on DATE NOT NULL,
    packages INTEGER NOT NULL,
    avg_weight NUMERIC(8,2)
) PARTITION BY LIST (region_code);

CREATE TABLE shipment_stats_north PARTITION OF shipment_stats
    FOR VALUES IN ('north');

CREATE TABLE shipment_stats_south PARTITION OF shipment_stats
    FOR VALUES IN ('south');

CREATE TABLE shipment_stats_west PARTITION OF shipment_stats
    FOR VALUES IN ('west');

CREATE TABLE shipment_default PARTITION OF shipment_stats DEFAULT;
```

<img width="227" height="351" alt="image" src="https://github.com/user-attachments/assets/9f47f879-3975-4430-86fa-41ceee7730ca" />

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT region_code, shipped_on, packages
FROM shipment_stats
WHERE region_code = 'north';
```

- partition proning есть
- в плане 1 секция

<img width="971" height="186" alt="image" src="https://github.com/user-attachments/assets/45a6f3e0-a949-47ce-8a86-7a2102bd8e85" />

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT region_code, shipped_on, packages
FROM shipment_stats
WHERE shipped_on >= DATE '2025-02-10'
  AND shipped_on < DATE '2025-02-15';
```

- partition proning нет
- в плане 4 секции
  
<img width="948" height="408" alt="image" src="https://github.com/user-attachments/assets/4f511819-2f37-48e5-ab20-a9b08abb29a6" />
<img width="949" height="72" alt="image" src="https://github.com/user-attachments/assets/1b6d0d06-74b5-4c72-90e5-7e940755decb" />

- планировщик отсечет секции если они сделаны по столбцу который использован в фильтре
- Ответьте, связан ли pruning напрямую с наличием обычного индекса: нет
- Кратко объясните, зачем в этом задании нужна секция DEFAULT туда попадают данные, не подходящие не под одно условие секционирования
