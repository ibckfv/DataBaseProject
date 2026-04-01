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
- чтобы улучшить нужно создать индекс CREATE INDEX idx_club_members_member_level ON club_members (member_level);

- <img width="962" height="582" alt="image" src="https://github.com/user-attachments/assets/44b9e526-c180-4dd1-ba5d-061fbae2a3c6" />
<img width="893" height="124" alt="image" src="https://github.com/user-attachments/assets/9e160087-eb6a-45d3-9671-fefb81aeafab" />

