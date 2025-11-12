# 1. CTE


WITH order_totals AS (
    SELECT client_id, SUM(total_cost) AS total_sum
    FROM orders
    GROUP BY client_id
)
SELECT c.client_id, c.name, ot.total_sum
FROM clients c
JOIN order_totals ot ON c.client_id = ot.client_id;
