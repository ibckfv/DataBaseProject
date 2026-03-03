## 1. Поиск заказов с суммой > 5000
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, client_id, total_cost, status 
FROM orders 
WHERE total_cost > 5000;
```
### Без индексов
<img width="861" height="237" alt="image" src="https://github.com/user-attachments/assets/5e87a6e1-a552-4a4f-8fd2-a09d7d3c8cc3" />
### B-tree индекс

## 2. Поиск заказов с суммой > 5000
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, created_at, status 
FROM orders 
WHERE created_at < '2023-01-01';
```
### Без индексов
<img width="853" height="298" alt="image" src="https://github.com/user-attachments/assets/18b2635c-cf98-427b-848f-78029b3b8f97" />
