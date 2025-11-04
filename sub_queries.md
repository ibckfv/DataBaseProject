# 1. SELECT

``` sql
SELECT 
    c.name,
    (SELECT COUNT(*) FROM orders o WHERE o.client_id = c.client_id) AS total_orders
FROM clients c;
```

``` sql
SELECT 
    v.plate_number,
    (SELECT type FROM vehicles v2 WHERE v2.vehicle_id = v.vehicle_id) AS vehicle_type
FROM vehicles v;
```

``` sql
SELECT 
    o.order_id,
    (SELECT SUM(weight) FROM cargos cg WHERE cg.order_id = o.order_id) AS total_weight
FROM orders o;
```

# 2. FROM

``` sql
SELECT client_id, total_sum
FROM (
    SELECT client_id, SUM(total_cost) AS total_sum
    FROM orders
    GROUP BY client_id
) AS order_summary
WHERE total_sum > 20000;
```

``` sql
SELECT route_id, avg_distance
FROM (
    SELECT route_id, AVG(distance_km) AS avg_distance
    FROM routes
    GROUP BY route_id
) r
WHERE avg_distance > 300;
```

``` sql
SELECT * 
FROM (
    SELECT payment_id, amount FROM payments WHERE method = 'Карта'
) AS card_payments
WHERE amount > 1000;
```

# 3. WHERE

``` sql
SELECT * FROM orders
WHERE client_id IN (
    SELECT client_id FROM clients WHERE name LIKE 'A%'
);
```

``` sql
SELECT * FROM cargos
WHERE order_id IN (
    SELECT order_id FROM orders WHERE total_cost > 10000
);
```

``` sql
SELECT * FROM vehicles
WHERE vehicle_id NOT IN (
    SELECT vehicle_id FROM trips WHERE arrival_datetime IS NULL
);
```

# 4. HAVING

``` sql
SELECT client_id, SUM(total_cost) AS total_sum
FROM orders
GROUP BY client_id
HAVING SUM(total_cost) > (
    SELECT AVG(total_cost) FROM orders
);
```

``` sql
SELECT package_type, AVG(weight) AS avg_weight
FROM cargos
GROUP BY package_type
HAVING AVG(weight) > (
    SELECT AVG(weight) FROM cargos WHERE package_type = 'Коробка'
);
```

``` sql
SELECT status, COUNT(*) AS cnt
FROM orders
GROUP BY status
HAVING COUNT(*) > (
    SELECT COUNT(*) FROM orders WHERE status = 'Отменён'
);
```

# 5. ALL

``` sql
SELECT * FROM orders
WHERE total_cost > ALL (
    SELECT amount FROM payments WHERE status = 'Проведён'
);
```

``` sql
SELECT * FROM vehicles
WHERE capacity > ALL (
    SELECT capacity FROM vehicles WHERE status = 'Ремонт'
);
```

``` sql
SELECT * FROM cargos
WHERE weight < ALL (
    SELECT weight FROM cargos WHERE package_type = 'Контейнер'
);
```
