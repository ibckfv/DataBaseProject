# 1. SELECT

``` sql
SELECT 
    c.name,
    (SELECT COUNT(*) FROM orders o WHERE o.client_id = c.client_id) AS total_orders
FROM clients c;
```

<img width="368" height="172" alt="Снимок экрана 2025-11-04 212320" src="https://github.com/user-attachments/assets/957c8ee5-0985-484c-a8d3-2574048aa71d" />


``` sql
SELECT 
    v.plate_number,
    (SELECT type FROM vehicles v2 WHERE v2.vehicle_id = v.vehicle_id) AS vehicle_type
FROM vehicles v;
```

<img width="425" height="174" alt="Снимок экрана 2025-11-04 212337" src="https://github.com/user-attachments/assets/f3b01f3f-4829-4773-9d21-286a1725ad60" />


``` sql
SELECT 
    o.order_id,
    (SELECT SUM(weight) FROM cargos cg WHERE cg.order_id = o.order_id) AS total_weight
FROM orders o;
```

<img width="328" height="108" alt="Снимок экрана 2025-11-04 212356" src="https://github.com/user-attachments/assets/5b6b739f-9622-4e25-95fa-a7154508db35" />


# 2. FROM

``` sql
SELECT client_id, total_sum
FROM (
    SELECT client_id, SUM(total_cost) AS total_sum
    FROM orders
    GROUP BY client_id
) AS order_summary
WHERE total_sum > 10000;
```

<img width="255" height="111" alt="Снимок экрана 2025-11-04 212422" src="https://github.com/user-attachments/assets/64982c64-916f-4cca-bb0d-88579844f109" />


``` sql
SELECT route_id, avg_distance
FROM (
    SELECT route_id, AVG(distance_km) AS avg_distance
    FROM routes
    GROUP BY route_id
) r
WHERE avg_distance > 300;
```

<img width="371" height="234" alt="Снимок экрана 2025-11-04 212441" src="https://github.com/user-attachments/assets/9e0f1d49-f2a3-48b4-bf81-ce71d477bb4f" />


``` sql
SELECT * 
FROM (
    SELECT payment_id, amount FROM payments WHERE method = 'Карта'
) AS card_payments
WHERE amount > 1000;
```

<img width="309" height="79" alt="Снимок экрана 2025-11-04 212456" src="https://github.com/user-attachments/assets/ea541c77-c854-4c36-bf24-6e8aeecff462" />


# 3. WHERE

``` sql
SELECT * FROM orders
WHERE client_id IN (
    SELECT client_id FROM clients WHERE name LIKE 'О%'
);
```

<img width="955" height="77" alt="Снимок экрана 2025-11-04 212619" src="https://github.com/user-attachments/assets/e37fff73-1252-446d-82d2-6bfde66f3ddd" />


``` sql
SELECT * FROM cargos
WHERE order_id IN (
    SELECT order_id FROM orders WHERE total_cost > 10000
);
```

<img width="932" height="110" alt="Снимок экрана 2025-11-04 212639" src="https://github.com/user-attachments/assets/aee949d9-4da9-4be8-b133-b956fd3ec135" />


``` sql
SELECT * FROM vehicles
WHERE vehicle_id NOT IN (
    SELECT vehicle_id FROM trips WHERE arrival_datetime IS NULL
);
```

<img width="874" height="174" alt="Снимок экрана 2025-11-04 212655" src="https://github.com/user-attachments/assets/5a33708d-aa4e-4179-bf6e-6e905ce5ec55" />


# 4. HAVING

``` sql
SELECT client_id, SUM(total_cost) AS total_sum
FROM orders
GROUP BY client_id
HAVING SUM(total_cost) > (
    SELECT AVG(total_cost) FROM orders
);
```

<img width="253" height="77" alt="Снимок экрана 2025-11-04 212709" src="https://github.com/user-attachments/assets/0a370f90-6edc-4c77-a8e7-2aec348c004a" />


``` sql
SELECT package_type, AVG(weight) AS avg_weight
FROM cargos
GROUP BY package_type
HAVING AVG(weight) > (
    SELECT AVG(weight) FROM cargos WHERE package_type = 'Паллета'
);
```

<img width="395" height="81" alt="Снимок экрана 2025-11-04 212738" src="https://github.com/user-attachments/assets/de801c8d-4bbd-403a-8090-a52aa077c9c8" />


``` sql
SELECT status, COUNT(*) AS cnt
FROM orders
GROUP BY status
HAVING COUNT(*) > (
    SELECT COUNT(*) FROM orders WHERE status = 'Отменён'
);
```

<img width="320" height="111" alt="Снимок экрана 2025-11-04 212809" src="https://github.com/user-attachments/assets/d9e30840-1d4e-40ba-869c-d690d8cafa4e" />


# 5. ALL

``` sql
SELECT * FROM orders
WHERE total_cost > ALL (
    SELECT amount FROM payments WHERE status = 'Проведён'
);
```

<img width="954" height="76" alt="Снимок экрана 2025-11-04 212830" src="https://github.com/user-attachments/assets/3394706a-5bc8-4b72-b189-2b44a48e893f" />


``` sql
SELECT * FROM vehicles
WHERE capacity > ALL (
    SELECT capacity FROM vehicles WHERE status = 'Ремонт'
);
```

<img width="874" height="79" alt="Снимок экрана 2025-11-04 212845" src="https://github.com/user-attachments/assets/6dea842b-7ea3-4cbd-b3b5-fd85f2766441" />


``` sql
SELECT * FROM cargos
WHERE weight < ALL (
    SELECT weight FROM cargos WHERE package_type = 'Контейнер'
);
```
<img width="951" height="75" alt="Снимок экрана 2025-11-04 212904" src="https://github.com/user-attachments/assets/b21fcbb8-25ae-4191-9adf-88573ba1cbd0" />
