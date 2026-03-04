## 1. 
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT client_id, name 
FROM clients 
WHERE name = 'Клиент 1000 Кузнецов';
```
### Без индексов
<img width="970" height="296" alt="Снимок экрана 2026-02-25 112523" src="https://github.com/user-attachments/assets/7f79fc67-27fb-42d1-a063-e8a6ac9a628a" />
### Hash индекс
<img width="991" height="238" alt="Снимок экрана 2026-02-25 112335" src="https://github.com/user-attachments/assets/a0b11d4e-763a-4e80-bcb6-995daa88709f" />
### B-tree индекс
<img width="992" height="298" alt="Снимок экрана 2026-02-25 112451" src="https://github.com/user-attachments/assets/63fcdc99-d8ee-4a7c-aaaa-c96bce1ee9d9" />
## 2.
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM tracking WHERE temperature < 5;
```
### Без индексов
<img width="864" height="299" alt="image" src="https://github.com/user-attachments/assets/c44ba40d-7c68-44de-8c41-9d66ab3a9260" />
### B-tree индекс
<img width="1020" height="379" alt="image" src="https://github.com/user-attachments/assets/f184e5f0-0228-4b9a-a0d5-3a4fd8d6f3a9" />
## 3. 
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, client_id, status 
FROM orders 
WHERE status = 'Доставлен';
```
### Без индексов
<img width="834" height="236" alt="image" src="https://github.com/user-attachments/assets/3f82e493-99a2-400e-80bd-ebed22abafa7" />
### Hash индекс
<img width="1020" height="377" alt="image" src="https://github.com/user-attachments/assets/7e81a2e5-f14d-4087-8d34-74f8cdd32452" />
### B-tree индекс
<img width="1014" height="377" alt="image" src="https://github.com/user-attachments/assets/7d0a5329-7035-43da-8ca7-2a03cd9ad10b" />
## 4.
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT payment_id, order_id, amount, method
FROM payments
WHERE method IN ('Карта', 'Наличные');
```
### Без индексов
<img width="862" height="296" alt="image" src="https://github.com/user-attachments/assets/67fe11a3-b0f8-4a3e-b446-7a7b461bc264" />
### B-tree индекс
<img width="875" height="298" alt="image" src="https://github.com/user-attachments/assets/c3448dc9-e97a-4608-a6b4-1edde6a7b4d3" />
## 5.
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT client_id, name
FROM clients
WHERE name LIKE '%Петров';
```
### Без индексов
<img width="835" height="297" alt="image" src="https://github.com/user-attachments/assets/8eea5c69-080a-4794-b291-a6b0cfeee82f" />
### B-tree индекс
<img width="835" height="232" alt="image" src="https://github.com/user-attachments/assets/87b1054d-a66a-4ebd-a6ed-7f7b772a9736" />
