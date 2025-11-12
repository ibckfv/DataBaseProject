# 1. CTE

``` sql
WITH order_totals AS (
    SELECT client_id, SUM(total_cost) AS total_sum
    FROM orders
    GROUP BY client_id
)
SELECT c.client_id, c.name, ot.total_sum
FROM clients c
JOIN order_totals ot ON c.client_id = ot.client_id;
```

<img width="473" height="112" alt="Снимок экрана 2025-11-12 084423" src="https://github.com/user-attachments/assets/f55d9f10-51c2-4e76-b2ac-9eae9fb2f838" />


``` sql
WITH cargo_avg AS (
    SELECT order_id, AVG(weight) AS avg_weight
    FROM cargos
    GROUP BY order_id
)
SELECT o.order_id, o.total_cost, ca.avg_weight
FROM orders o
JOIN cargo_avg ca ON o.order_id = ca.order_id;
```

<img width="461" height="107" alt="Снимок экрана 2025-11-12 084442" src="https://github.com/user-attachments/assets/86cf3c50-9488-4edb-9f6a-62c8f759cc61" />


``` sql
WITH heavy_orders AS (
    SELECT order_id
    FROM cargos
    GROUP BY order_id
    HAVING SUM(weight) > 500
)
SELECT * FROM orders
WHERE order_id IN (SELECT order_id FROM heavy_orders);
```

<img width="954" height="113" alt="Снимок экрана 2025-11-12 084504" src="https://github.com/user-attachments/assets/5de4bc28-eff5-4fb8-ba3e-531eaa387a65" />


``` sql
WITH client_income AS (
    SELECT client_id, SUM(total_cost) AS total_income
    FROM orders
    GROUP BY client_id
)
SELECT * FROM clients
WHERE client_id IN (
    SELECT client_id
    FROM client_income
    WHERE total_income > 10000
);
```

<img width="367" height="110" alt="Снимок экрана 2025-11-12 084539" src="https://github.com/user-attachments/assets/c46a988a-8988-48e3-91c9-406c05559e97" />


``` sql
WITH last_orders AS (
    SELECT client_id, MAX(created_at) AS last_order_date
    FROM orders
    GROUP BY client_id
)
SELECT c.name, o.order_id, o.created_at
FROM orders o
JOIN last_orders lo ON o.client_id = lo.client_id AND o.created_at = lo.last_order_date
JOIN clients c ON c.client_id = o.client_id;
```

<img width="579" height="110" alt="Снимок экрана 2025-11-12 084609" src="https://github.com/user-attachments/assets/526cfa21-f615-429c-8640-82fccb020cd7" />


# 2. UNION

``` sql
SELECT name FROM clients WHERE client_id < 3
UNION
SELECT name FROM clients WHERE client_id > 2;
```

<img width="247" height="166" alt="Снимок экрана 2025-11-12 084706" src="https://github.com/user-attachments/assets/fb71cc6f-6434-4dca-a4a5-f18d094f4feb" />


``` sql
SELECT plate_number FROM vehicles WHERE status = 'В рейсе'
UNION
SELECT plate_number FROM vehicles WHERE status = 'Ремонт';
```

<img width="242" height="107" alt="Снимок экрана 2025-11-12 084720" src="https://github.com/user-attachments/assets/6b0dad65-3a99-47ae-bd4b-57681c8c4954" />


``` sql
SELECT status FROM orders WHERE total_cost > 10000
UNION
SELECT status FROM orders WHERE delivery_date IS NOT NULL;
```

<img width="238" height="108" alt="Снимок экрана 2025-11-12 084735" src="https://github.com/user-attachments/assets/580cd4c6-5bc8-485d-b89c-f150ae62d09f" />


# 3. INTERSECT

``` sql
SELECT client_id FROM orders WHERE total_cost > 5000
INTERSECT
SELECT client_id FROM orders WHERE status = 'Доставлен';
```

<img width="149" height="78" alt="Снимок экрана 2025-11-12 084821" src="https://github.com/user-attachments/assets/ceea34d8-239f-4ed2-9322-6c7cdd21d0be" />


``` sql
SELECT vehicle_id FROM vehicles WHERE type = 'Грузовик'
INTERSECT
SELECT vehicle_id FROM trips;
```

<img width="160" height="111" alt="Снимок экрана 2025-11-12 084838" src="https://github.com/user-attachments/assets/c41448a1-6bf8-4ad6-b87e-65708eb48b27" />


``` sql
SELECT order_id FROM cargos WHERE package_type = 'Контейнер'
INTERSECT
SELECT order_id FROM cargos WHERE weight > 500;
```

<img width="150" height="80" alt="Снимок экрана 2025-11-12 084857" src="https://github.com/user-attachments/assets/38a337aa-aa03-447b-a802-06c462c81f87" />


# 4. EXCEPT

``` sql
SELECT client_id FROM clients
EXCEPT
SELECT client_id FROM orders;
```

<img width="146" height="111" alt="Снимок экрана 2025-11-12 084914" src="https://github.com/user-attachments/assets/a03595e5-6e14-4638-909d-7b633ee9deb6" />


``` sql
SELECT vehicle_id FROM vehicles
EXCEPT
SELECT vehicle_id FROM trips;
```

<img width="157" height="113" alt="Снимок экрана 2025-11-12 084931" src="https://github.com/user-attachments/assets/ab8302ae-7eda-4699-ba91-b25ab73023bb" />


``` sql
SELECT vehicle_id FROM vehicles
EXCEPT
SELECT vehicle_id FROM drivers;
```

<img width="156" height="110" alt="Снимок экрана 2025-11-12 085150" src="https://github.com/user-attachments/assets/fa225c55-d8c2-414a-be69-36f3e7a129c8" />


# 5. PARTITION BY

``` sql
SELECT 
    client_id, 
    order_id, 
    SUM(total_cost) OVER (PARTITION BY client_id) AS client_total
FROM orders;
```

<img width="377" height="113" alt="Снимок экрана 2025-11-12 085244" src="https://github.com/user-attachments/assets/c69c9df1-fc05-48e3-b0d0-dfae2b2148f0" />


``` sql
SELECT 
    package_type, 
    weight, 
    AVG(weight) OVER (PARTITION BY package_type) AS avg_weight
FROM cargos;
```

<img width="543" height="109" alt="Снимок экрана 2025-11-12 085304" src="https://github.com/user-attachments/assets/2c83a494-fc6e-43bb-8ee6-f990eab149a0" />
