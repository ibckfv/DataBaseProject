**1. COUNT()**
```SELECT c.client_id, c.name, COUNT(o.order_id) AS orders_count
FROM clients c
LEFT JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```

```SELECT o.order_id, COUNT(DISTINCT cgs.package_type) AS distinct_package_types
FROM orders o
JOIN cargos cgs ON cgs.order_id = o.order_id
GROUP BY o.order_id;
```

**2. SUM()**

```SELECT c.client_id, c.name, SUM(o.total_cost) AS sum_total_cost
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```

```SELECT order_id, SUM(weight) AS total_weight_kg
FROM cargos
GROUP BY order_id;
```

**3. AVG()**

```SELECT method, AVG(amount) AS avg_amount
FROM payments
GROUP BY method;
```

```SELECT 'all_routes' AS scope, AVG(distance_km) AS avg_distance_km
FROM routes;
```

**4. MIN()**

```SELECT c.client_id, c.name, MIN(o.delivery_date) AS first_delivery_date
FROM clients c
JOIN orders o ON o.client_id = c.client_id
GROUP BY c.client_id, c.name;
```

```SELECT package_type, MIN(weight) AS min_weight
FROM cargos
GROUP BY package_type;
```
