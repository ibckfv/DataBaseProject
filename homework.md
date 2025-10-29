**1. COUNT()**
```
SELECT c.client_id, c.name, COUNT(o.order_id) AS orders_count
FROM clients c
LEFT JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```

```
SELECT o.order_id, COUNT(DISTINCT cgs.package_type) AS distinct_package_types
FROM orders o
JOIN cargos cgs ON cgs.order_id = o.order_id
GROUP BY o.order_id;
```

**2. SUM()**

```
SELECT c.client_id, c.name, SUM(o.total_cost) AS sum_total_cost
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```

```
SELECT order_id, SUM(weight) AS total_weight_kg
FROM cargos
GROUP BY order_id;
```

**3. AVG()**

```
SELECT method, AVG(amount) AS avg_amount
FROM payments
GROUP BY method;
```

```
SELECT 'all_routes' AS scope, AVG(distance_km) AS avg_distance_km
FROM routes;
```

**4. MIN()**

```
SELECT c.client_id, c.name, MIN(o.delivery_date) AS first_delivery_date
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```

```
SELECT package_type, MIN(weight) AS min_weight
FROM cargos
GROUP BY package_type;
```

**5. MAX()**

```
SELECT c.client_id, c.name, MAX(o.total_cost) AS max_order_cost
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```

```
SELECT type, MAX(capacity) AS max_capacity
FROM vehicles
GROUP BY type;
```

**6. STRING_AGG()**

```
SELECT d.order_id,
      STRING_AGG(DISTINCT d.document_type, ', ' ORDER BY d.document_type) AS doc_types
FROM documents d
GROUP BY d.order_id;
```

```
SELECT c.client_id,
       c.name,
       STRING_AGG(DISTINCT cg.package_type, ', ' ORDER BY cg.package_type) AS package_types_used
FROM clients c
JOIN orders o ON o.client_id = c.client_id
JOIN cargos cg ON cg.order_id = o.order_id
GROUP BY c.client_id, c.name;
```

**7. GROUP BY**

```
SELECT 
    c.client_id,
    c.name AS client_name,
    SUM(o.total_cost) AS total_sum
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```

```
SELECT 
    package_type,
    AVG(weight) AS avg_weight
FROM cargos
GROUP BY package_type;
```

**8. HAVING**

```
SELECT 
    c.name AS client_name,
    SUM(o.total_cost) AS total_sum
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.name
HAVING SUM(o.total_cost) > 20000;
```

```
SELECT 
    package_type,
    AVG(weight) AS avg_weight
FROM cargos
GROUP BY package_type
HAVING AVG(weight) > 100;
```

**9. GROUPING SETS**

```
SELECT 
    c.name AS client_name,
    cg.package_type,
    SUM(cg.price) AS total_price
FROM clients c
JOIN orders o ON o.client_id = c.client_id
JOIN cargos cg ON cg.order_id = o.order_id
GROUP BY GROUPING SETS ((c.name), (cg.package_type));
```

```
SELECT 
    c.name AS client_name,
    o.status,
    SUM(o.total_cost) AS total_sum
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY GROUPING SETS ((c.name), (o.status));
```
