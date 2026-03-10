## 1. Поиск заказов с определенными метаданными (GIN на jsonb)

```sql
CREATE INDEX idx_orders_metadata_gin ON orders USING GIN (metadata);

SELECT order_id, client_id, status, metadata
FROM orders
WHERE metadata @> '{"source": "web"}';
```

### Результат
<img width="664" height="239" alt="image" src="https://github.com/user-attachments/assets/11a799a2-04b1-4fc0-9ec8-ced5f902ce24" />

## 2. Поиск грузов с определенными условиями хранения (GIN на массиве)

```sql
CREATE INDEX idx_cargos_storage_gin ON cargos USING GIN (storage_conditions);

SELECT cargo_id, description, storage_conditions
FROM cargos
WHERE storage_conditions @> ARRAY['Температурный режим', 'Хрупкое'];
```

### Результат
<img width="638" height="236" alt="image" src="https://github.com/user-attachments/assets/841a6d63-2532-41df-9140-c18f0da397f5" />

## 3. Полнотекстовый поиск по описанию груза (GIN на tsvector)

```sql
CREATE INDEX idx_cargos_description_fts ON cargos USING GIN (to_tsvector('russian', coalesce(description, '')));

SELECT cargo_id, description
FROM cargos
WHERE to_tsvector('russian', coalesce(description, '')) @@ to_tsquery('russian', 'Сборный & груз');
```

### Результат
<img width="286" height="238" alt="image" src="https://github.com/user-attachments/assets/7ce27c2e-3e93-4d37-9a6b-312f7ebb02a6" />

## 4. Поиск платежей с определенной банковской информацией (GIN на jsonb)

```sql
CREATE INDEX idx_payments_bank_info_gin ON payments USING GIN (bank_info);

SELECT payment_id, amount, method, bank_info
FROM payments
WHERE bank_info @> '{"bank": "Сбербанк"}';
```

### Результат
<img width="866" height="235" alt="image" src="https://github.com/user-attachments/assets/b9c86ce7-7474-4eea-825c-9efd9d1ab02d" />

## 5. Проверка наличия ключей в метаданных (GIN, оператор ?)
```sql
SELECT order_id, client_id, metadata
FROM orders
WHERE metadata ? 'app_version';
```

### Результат
<img width="577" height="233" alt="image" src="https://github.com/user-attachments/assets/6056e64e-ac30-4b34-bd7c-1a5b7e815e5f" />

## 1. Поиск ближайших грузов по координатам (GiST на point)
```sql
CREATE INDEX idx_cargos_coordinates_gist ON cargos USING GiST (coordinates);

SELECT cargo_id, description, coordinates
FROM cargos
WHERE coordinates IS NOT NULL
ORDER BY coordinates <-> point '(55.7887, 49.1221)'
LIMIT 5;
```

### Результат
<img width="407" height="201" alt="image" src="https://github.com/user-attachments/assets/bca0ae6c-0b85-4566-838e-1ab5f94908c0" />

## 2. Поиск заказов с доставкой в определенном диапазоне (GiST на daterange)
```sql
CREATE INDEX IF NOT EXISTS idx_orders_delivery_range_gist ON orders USING GiST (delivery_range);

SELECT order_id, client_id, delivery_range
FROM orders
WHERE delivery_range && daterange('[2022-03-01, 2022-04-01)');
```

### Результат
<img width="448" height="235" alt="image" src="https://github.com/user-attachments/assets/21c2b504-8ba0-4b7a-bc3e-6e362af2b390" />

## 3. Поиск грузов внутри радиуса от склада (GiST на point, оператор <@)
```sql
SELECT cargo_id, description, coordinates
FROM cargos
WHERE coordinates <@ circle '( (55.7887,49.1221), 1.1 )'; -- ~110 км от Казани
```

### Результат
<img width="397" height="140" alt="image" src="https://github.com/user-attachments/assets/8fb2ca07-09db-4e9e-9e34-1337c74380c0" />

## 4. Поиск платежей по временному окну (GiST на tstzrange)
```sql
SELECT payment_id, amount, payment_window
FROM payments
WHERE payment_window @> '2022-03-10 14:30:00+03'::timestamptz;
```

### Результат
<img width="397" height="140" alt="image" src="https://github.com/user-attachments/assets/8fb2ca07-09db-4e9e-9e34-1337c74380c0" />

## 5. Поиск пересекающихся маршрутов
```sql
SELECT payment_id, amount, payment_window
FROM payments
WHERE payment_window @> '2022-03-10 14:30:00+03'::timestamptz;
```

### Результат
<img width="397" height="140" alt="image" src="https://github.com/user-attachments/assets/8fb2ca07-09db-4e9e-9e34-1337c74380c0" />

## 1. Информация о заказах с клиентами и грузами
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    o.order_id,
    c.name AS client_name,
    COUNT(cg.cargo_id) AS cargos_count,
    SUM(cg.weight) AS total_weight,
    o.total_cost
FROM orders o
JOIN clients c ON o.client_id = c.client_id
LEFT JOIN cargos cg ON o.order_id = cg.order_id
GROUP BY o.order_id, c.name, o.total_cost
LIMIT 20;
```

### Результат
```sql
"Limit  (cost=24973.62..24979.72 rows=20 width=62) (actual time=440.354..467.898 rows=20 loops=1)"
"  Buffers: shared hit=8750 read=687, temp read=1112 written=1265"
"  ->  GroupAggregate  (cost=24973.62..101190.14 rows=250000 width=62) (actual time=440.350..467.891 rows=20 loops=1)"
"        Group Key: o.order_id, c.name"
"        Buffers: shared hit=8750 read=687, temp read=1112 written=1265"
"        ->  Incremental Sort  (cost=24973.62..96190.14 rows=250000 width=58) (actual time=440.336..467.863 rows=21 loops=1)"
"              Sort Key: o.order_id, c.name"
"              Presorted Key: o.order_id"
"              Full-sort Groups: 1  Sort Method: quicksort  Average Memory: 27kB  Peak Memory: 27kB"
"              Buffers: shared hit=8750 read=687, temp read=1112 written=1265"
"              ->  Nested Loop  (cost=24973.37..84940.14 rows=250000 width=58) (actual time=437.917..467.834 rows=33 loops=1)"
"                    Buffers: shared hit=8750 read=687, temp read=1112 written=1265"
"                    ->  Gather Merge  (cost=24972.94..54089.56 rows=250000 width=28) (actual time=435.314..462.851 rows=33 loops=1)"
"                          Workers Planned: 2"
"                          Workers Launched: 2"
"                          Buffers: shared hit=8621 read=684, temp read=1112 written=1265"
"                          ->  Sort  (cost=23972.92..24233.34 rows=104167 width=28) (actual time=316.189..316.292 rows=791 loops=3)"
"                                Sort Key: o.order_id"
"                                Sort Method: external merge  Disk: 3936kB"
"                                Buffers: shared hit=8621 read=684, temp read=1112 written=1265"
"                                Worker 0:  Sort Method: external merge  Disk: 3248kB"
"                                Worker 1:  Sort Method: external merge  Disk: 2912kB"
"                                ->  Parallel Hash Right Join  (cost=7046.75..12795.86 rows=104167 width=28) (actual time=160.072..258.663 rows=83333 loops=3)"
"                                      Hash Cond: (cg.order_id = o.order_id)"
"                                      Buffers: shared hit=8549 read=684"
"                                      ->  Parallel Seq Scan on cargos cg  (cost=0.00..5475.67 rows=104167 width=16) (actual time=0.031..33.226 rows=83333 loops=3)"
"                                            Buffers: shared hit=4133 read=301"
"                                      ->  Parallel Hash  (cost=5744.67..5744.67 rows=104167 width=16) (actual time=156.458..156.460 rows=83333 loops=3)"
"                                            Buckets: 262144  Batches: 1  Memory Usage: 15392kB"
"                                            Buffers: shared hit=4320 read=383"
"                                            ->  Parallel Seq Scan on orders o  (cost=0.00..5744.67 rows=104167 width=16) (actual time=0.097..71.645 rows=83333 loops=3)"
"                                                  Buffers: shared hit=4320 read=383"
"                    ->  Memoize  (cost=0.43..0.49 rows=1 width=38) (actual time=0.150..0.150 rows=1 loops=33)"
"                          Cache Key: o.client_id"
"                          Cache Mode: logical"
"                          Hits: 0  Misses: 33  Evictions: 0  Overflows: 0  Memory Usage: 5kB"
"                          Buffers: shared hit=129 read=3"
"                          ->  Index Scan using clients_pkey on clients c  (cost=0.42..0.48 rows=1 width=38) (actual time=0.112..0.112 rows=1 loops=33)"
"                                Index Cond: (client_id = o.client_id)"
"                                Buffers: shared hit=129 read=3"
"Planning:"
"  Buffers: shared hit=106 read=18"
"Planning Time: 25.674 ms"
"Execution Time: 471.582 ms"
```

## 2. Активные рейсы с водителями и транспортом
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    t.trip_id,
    r.departure_city,
    r.arrival_city,
    d.license_number,
    v.plate_number,
    v.type AS vehicle_type
FROM trips t
JOIN routes r ON t.route_id = r.route_id
JOIN drivers d ON t.driver_id = d.driver_id
JOIN vehicles v ON d.vehicle_id = v.vehicle_id
WHERE t.departure_datetime > NOW() - INTERVAL '7 days';
```

### Результат
```sql
"Nested Loop  (cost=0.43..30.40 rows=1 width=734) (actual time=2.239..2.242 rows=0 loops=1)"
"  Buffers: shared read=5"
"  ->  Nested Loop  (cost=0.29..30.22 rows=1 width=562) (actual time=2.239..2.241 rows=0 loops=1)"
"        Buffers: shared read=5"
"        ->  Nested Loop  (cost=0.14..22.01 rows=1 width=444) (actual time=2.238..2.240 rows=0 loops=1)"
"              Buffers: shared read=5"
"              ->  Seq Scan on trips t  (cost=0.00..13.75 rows=1 width=12) (actual time=2.237..2.238 rows=0 loops=1)"
"                    Filter: (departure_datetime > (now() - '7 days'::interval))"
"                    Rows Removed by Filter: 500"
"                    Buffers: shared read=5"
"              ->  Index Scan using routes_pkey on routes r  (cost=0.14..8.16 rows=1 width=440) (never executed)"
"                    Index Cond: (route_id = t.route_id)"
"        ->  Index Scan using drivers_pkey on drivers d  (cost=0.15..8.17 rows=1 width=126) (never executed)"
"              Index Cond: (driver_id = t.driver_id)"
"  ->  Index Scan using vehicles_pkey on vehicles v  (cost=0.14..0.18 rows=1 width=180) (never executed)"
"        Index Cond: (vehicle_id = d.vehicle_id)"
"Planning:"
"  Buffers: shared hit=155 read=8"
"Planning Time: 11.475 ms"
"Execution Time: 2.291 ms"
```

## 3. Финансовый отчет по клиентам
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    cl.client_id,
    cl.name,
    COUNT(DISTINCT o.order_id) AS orders_count,
    SUM(p.amount) AS total_paid,
    AVG(p.amount) AS avg_payment
FROM clients cl
LEFT JOIN orders o ON cl.client_id = o.client_id
LEFT JOIN payments p ON o.order_id = p.order_id
WHERE p.status = 'Проведён'
GROUP BY cl.client_id, cl.name
ORDER BY total_paid DESC NULLS LAST
LIMIT 10;
```

### Результат
```sql
"Limit  (cost=58363.12..58363.15 rows=10 width=110) (actual time=809.572..821.908 rows=10 loops=1)"
"  Buffers: shared hit=8179 read=2985"
"  ->  Sort  (cost=58363.12..58799.62 rows=174600 width=110) (actual time=809.570..821.904 rows=10 loops=1)"
"        Sort Key: (sum(p.amount)) DESC NULLS LAST"
"        Sort Method: top-N heapsort  Memory: 26kB"
"        Buffers: shared hit=8179 read=2985"
"        ->  GroupAggregate  (cost=18913.09..54590.08 rows=174600 width=110) (actual time=363.095..792.650 rows=76375 loops=1)"
"              Group Key: cl.client_id"
"              Buffers: shared hit=8176 read=2985"
"              ->  Merge Join  (cost=18913.09..50661.58 rows=174600 width=50) (actual time=362.928..665.273 rows=175045 loops=1)"
"                    Merge Cond: (o.client_id = cl.client_id)"
"                    Buffers: shared hit=8176 read=2985"
"                    ->  Gather Merge  (cost=18903.63..39238.68 rows=174600 width=16) (actual time=362.874..437.075 rows=175045 loops=1)"
"                          Workers Planned: 2"
"                          Workers Launched: 2"
"                          Buffers: shared hit=8169 read=191"
"                          ->  Sort  (cost=17903.61..18085.48 rows=72750 width=16) (actual time=321.955..327.567 rows=58348 loops=3)"
"                                Sort Key: o.client_id, o.order_id"
"                                Sort Method: quicksort  Memory: 3727kB"
"                                Buffers: shared hit=8169 read=191"
"                                Worker 0:  Sort Method: quicksort  Memory: 3856kB"
"                                Worker 1:  Sort Method: quicksort  Memory: 3769kB"
"                                ->  Parallel Hash Join  (cost=7046.75..12028.81 rows=72750 width=16) (actual time=199.683..281.345 rows=58348 loops=3)"
"                                      Hash Cond: (p.order_id = o.order_id)"
"                                      Buffers: shared hit=8097 read=191"
"                                      ->  Parallel Seq Scan on payments p  (cost=0.00..4791.08 rows=72750 width=12) (actual time=0.110..37.517 rows=58348 loops=3)"
"                                            Filter: ((status)::text = 'Проведён'::text)"
"                                            Rows Removed by Filter: 24985"
"                                            Buffers: shared hit=3489"
"                                      ->  Parallel Hash  (cost=5744.67..5744.67 rows=104167 width=8) (actual time=195.779..195.780 rows=83333 loops=3)"
"                                            Buckets: 262144  Batches: 1  Memory Usage: 11872kB"
"                                            Buffers: shared hit=4512 read=191"
"                                            ->  Parallel Seq Scan on orders o  (cost=0.00..5744.67 rows=104167 width=8) (actual time=0.062..113.595 rows=83333 loops=3)"
"                                                  Buffers: shared hit=4512 read=191"
"                    ->  Index Scan using clients_pkey on clients cl  (cost=0.42..8617.42 rows=250000 width=38) (actual time=0.043..157.673 rows=249990 loops=1)"
"                          Buffers: shared hit=7 read=2794"
"Planning:"
"  Buffers: shared hit=44 read=1"
"Planning Time: 1.617 ms"
"Execution Time: 822.199 ms"
```

## 4. Трекинг грузов в пути с информацией о местоположении
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    t.tracking_id,
    o.order_id,
    t.status AS tracking_status,
    t.updated_at,
    w.name AS warehouse_name,
    t.location_point
FROM tracking t
JOIN orders o ON t.order_id = o.order_id
LEFT JOIN warehouses w ON t.location = w.warehouse_id
WHERE t.status = 'В пути'
  AND t.updated_at > NOW() - INTERVAL '24 hours';
```

### Результат
```sql
"Nested Loop Left Join  (cost=1000.42..7050.61 rows=12 width=562) (actual time=220.227..254.744 rows=0 loops=1)"
"  Join Filter: (t.location = w.warehouse_id)"
"  Buffers: shared read=3046"
"  ->  Gather  (cost=1000.42..7019.44 rows=12 width=50) (actual time=220.225..254.737 rows=0 loops=1)"
"        Workers Planned: 1"
"        Workers Launched: 1"
"        Buffers: shared read=3046"
"        ->  Nested Loop  (cost=0.42..6018.24 rows=7 width=50) (actual time=190.837..190.840 rows=0 loops=2)"
"              Buffers: shared read=3046"
"              ->  Parallel Seq Scan on tracking t  (cost=0.00..5987.18 rows=7 width=50) (actual time=190.835..190.836 rows=0 loops=2)"
"                    Filter: (((status)::text = 'В пути'::text) AND (updated_at > (now() - '24:00:00'::interval)))"
"                    Rows Removed by Filter: 125000"
"                    Buffers: shared read=3046"
"              ->  Index Only Scan using orders_pkey on orders o  (cost=0.42..4.44 rows=1 width=4) (never executed)"
"                    Index Cond: (order_id = t.order_id)"
"                    Heap Fetches: 0"
"  ->  Materialize  (cost=0.00..11.65 rows=110 width=520) (never executed)"
"        ->  Seq Scan on warehouses w  (cost=0.00..11.10 rows=110 width=520) (never executed)"
"Planning:"
"  Buffers: shared hit=87 read=3"
"Planning Time: 5.927 ms"
"Execution Time: 254.813 ms"
```

## 5. Детальная информация о заказе
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT 
    o.order_id,
    o.created_at,
    o.status,
    c.name AS client_name,
    cc.phone AS client_phone,
    t.type AS tariff_type,
    t.price_per_km,
    t.price_per_kg,
    COUNT(cg.cargo_id) AS cargos_count,
    STRING_AGG(DISTINCT cg.package_type, ', ') AS package_types
FROM orders o
JOIN clients c ON o.client_id = c.client_id
LEFT JOIN client_contacts cc ON c.client_id = cc.client_id
LEFT JOIN tariffs t ON o.tariff_id = t.tariff_id
LEFT JOIN cargos cg ON o.order_id = cg.order_id
WHERE o.order_id = 100
GROUP BY o.order_id, c.name, cc.phone, t.tariff_id;
```

### Результат
```sql
"GroupAggregate  (cost=6761.57..6761.60 rows=1 width=265) (actual time=54.148..64.620 rows=1 loops=1)"
"  Group Key: c.name, cc.phone, t.tariff_id"
"  Buffers: shared hit=1526 read=2921"
"  ->  Sort  (cost=6761.57..6761.58 rows=1 width=244) (actual time=53.934..64.406 rows=1 loops=1)"
"        Sort Key: c.name, cc.phone, t.tariff_id, cg.package_type"
"        Sort Method: quicksort  Memory: 25kB"
"        Buffers: shared hit=1526 read=2921"
"        ->  Nested Loop Left Join  (cost=1001.26..6761.56 rows=1 width=244) (actual time=2.404..64.344 rows=1 loops=1)"
"              Buffers: shared hit=1526 read=2921"
"              ->  Nested Loop Left Join  (cost=1.26..25.37 rows=1 width=225) (actual time=1.623..1.645 rows=1 loops=1)"
"                    Buffers: shared hit=8 read=5"
"                    ->  Nested Loop Left Join  (cost=1.11..17.17 rows=1 width=75) (actual time=0.743..0.761 rows=1 loops=1)"
"                          Buffers: shared hit=8 read=3"
"                          ->  Nested Loop  (cost=0.84..16.88 rows=1 width=67) (actual time=0.128..0.144 rows=1 loops=1)"
"                                Buffers: shared hit=7 read=1"
"                                ->  Index Scan using orders_pkey on orders o  (cost=0.42..8.44 rows=1 width=33) (actual time=0.114..0.126 rows=1 loops=1)"
"                                      Index Cond: (order_id = 100)"
"                                      Buffers: shared hit=3 read=1"
"                                ->  Index Scan using clients_pkey on clients c  (cost=0.42..8.44 rows=1 width=38) (actual time=0.010..0.010 rows=1 loops=1)"
"                                      Index Cond: (client_id = o.client_id)"
"                                      Buffers: shared hit=4"
"                          ->  Index Scan using client_contacts_pkey on client_contacts cc  (cost=0.28..0.29 rows=1 width=16) (actual time=0.606..0.606 rows=1 loops=1)"
"                                Index Cond: (client_id = c.client_id)"
"                                Buffers: shared hit=1 read=2"
"                    ->  Index Scan using tariffs_pkey on tariffs t  (cost=0.15..8.17 rows=1 width=154) (actual time=0.867..0.867 rows=1 loops=1)"
"                          Index Cond: (tariff_id = o.tariff_id)"
"                          Buffers: shared read=2"
"              ->  Gather  (cost=1000.00..6736.18 rows=1 width=23) (actual time=0.775..62.688 rows=1 loops=1)"
"                    Workers Planned: 2"
"                    Workers Launched: 2"
"                    Buffers: shared hit=1518 read=2916"
"                    ->  Parallel Seq Scan on cargos cg  (cost=0.00..5736.08 rows=1 width=23) (actual time=0.031..13.685 rows=0 loops=3)"
"                          Filter: (order_id = 100)"
"                          Rows Removed by Filter: 83333"
"                          Buffers: shared hit=1518 read=2916"
"Planning:"
"  Buffers: shared hit=78 read=7"
"Planning Time: 22.678 ms"
"Execution Time: 64.732 ms"
```
