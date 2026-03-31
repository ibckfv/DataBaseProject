## RANGE

```sql
CREATE TABLE orders_partitioned (
    order_id integer NOT NULL,
    tariff_id integer,
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    delivery_date date,
    status character varying(20) NOT NULL,
    total_cost numeric(12,2),
    notes text,
    client_id integer NOT NULL,
    trip_id integer,
    delivery_range daterange,
    metadata jsonb,
    priority integer,
    warehouse_id integer
) PARTITION BY RANGE (created_at);
```

### Секции по кварталам

```sql
CREATE TABLE orders_2024_q1 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

CREATE TABLE orders_2024_q2 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

CREATE TABLE orders_2024_q3 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');

CREATE TABLE orders_2024_q4 PARTITION OF orders_partitioned
    FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');

CREATE TABLE orders_default PARTITION OF orders_partitioned DEFAULT;
```

<img width="226" height="386" alt="image" src="https://github.com/user-attachments/assets/9e7e56a5-f125-422b-a750-90d345d0370a" />

```sql
SELECT order_id, client_id, total_cost, created_at
FROM orders_partitioned
WHERE created_at BETWEEN '2024-03-01' AND '2024-05-01';
```

## LIST

```sql
CREATE TABLE tracking_partitioned (
    tracking_id integer NOT NULL,
    order_id integer NOT NULL,
    status character varying(50) NOT NULL,
    updated_at timestamp without time zone NOT NULL DEFAULT now(),
    location integer,
    location_point point,
    temperature numeric(5,2),
    humidity integer,
    event_data jsonb,
    route_path path,
    processed boolean DEFAULT false,
    delay_minutes integer
) PARTITION BY LIST (status);
```

### Секции по статусам доставок

```sql
CREATE TABLE tracking_in_transit PARTITION OF tracking_partitioned
    FOR VALUES IN ('В пути');

CREATE TABLE tracking_delayed PARTITION OF tracking_partitioned
    FOR VALUES IN ('Задержан');

CREATE TABLE tracking_delivered PARTITION OF tracking_partitioned
    FOR VALUES IN ('Доставлен');

CREATE TABLE tracking_default PARTITION OF tracking_partitioned DEFAULT;
```

<img width="226" height="360" alt="image" src="https://github.com/user-attachments/assets/1d9ed428-de40-41c8-bfb2-e80fe2ce37ec" />

```sql
SELECT tracking_id, order_id, status, updated_at
FROM tracking_partitioned
WHERE status = 'Задержан';
```

## HASH

```sql
CREATE TABLE payments_partitioned (
    payment_id integer NOT NULL,
    order_id integer NOT NULL,
    amount numeric(12,2) NOT NULL,
    payment_date date NOT NULL,
    method character varying(50) NOT NULL,
    status character varying(20) NOT NULL,
    transaction_id character varying(50),
    card_last4 character varying(4),
    bank_info jsonb,
    installments integer,
    receipt_data text,
    payment_window tstzrange,
    fraud_score double precision
) PARTITION BY HASH (order_id);
```

### Секции по order_id

```sql
CREATE TABLE payments_p0 PARTITION OF payments_partitioned
    FOR VALUES WITH (MODULUS 4, REMAINDER 0);

CREATE TABLE payments_p1 PARTITION OF payments_partitioned
    FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE payments_p2 PARTITION OF payments_partitioned
    FOR VALUES WITH (MODULUS 4, REMAINDER 2);

CREATE TABLE payments_p3 PARTITION OF payments_partitioned
    FOR VALUES WITH (MODULUS 4, REMAINDER 3);
```

<img width="218" height="358" alt="image" src="https://github.com/user-attachments/assets/894cf4ee-3698-48e9-9c8f-a9e1e5bfe5ad" />

```sql
SELECT payment_id, order_id, amount, status
FROM payments_partitioned
WHERE order_id = 1234;
```

## Секционирование и физическая репликация

<img width="715" height="248" alt="image" src="https://github.com/user-attachments/assets/b932fdd5-fc48-4069-ac0f-1ad59cd56e98" />

<img width="471" height="604" alt="Снимок экрана 2026-03-31 161749" src="https://github.com/user-attachments/assets/25d1ee77-3892-4e14-924f-44e6ffa62b36" />

<img width="470" height="61" alt="Снимок экрана 2026-03-31 161759" src="https://github.com/user-attachments/assets/f9f069a7-7ae4-4900-af79-897859d6300c" />

Физическая репликация работает на уровне WAL. Реплика просто воспроизводит эти изменения, не интерпретируя их как SQL-команды. Поэтому:
Реплика "не знает" о логической структуре секций
Но секции существуют на реплике, потому что структура базы данных полностью копируется
Восстановление секций происходит автоматически через WAL

## Секционирование и логическая репликация

<img width="697" height="237" alt="image" src="https://github.com/user-attachments/assets/66857fde-1786-441e-a175-2a7365ff7ebb" />

### Логическая реплика не знает о секциях

<img width="416" height="79" alt="image" src="https://github.com/user-attachments/assets/21dac865-d439-4acf-ae6b-9a54c5cd8fb8" />

### publish_via_partition_root = off (по умолчанию)

```sql
CREATE PUBLICATION orders_pub FOR TABLE orders_partitioned
    WITH (publish_via_partition_root = off);
```

` Поведение:` 

Изменения реплицируются с именами конкретных секций

На подписчике должны существовать таблицы с такими же именами (могут быть обычными таблицами)

Если структура секций отличается, репликация сломается

### publish_via_partition_root = on

```sql
CREATE PUBLICATION orders_pub FOR TABLE orders_partitioned
    WITH (publish_via_partition_root = on);
```

` Поведение:` 

Изменения реплицируются как операции над родительской таблицей

На подписчике может быть:

  Своя схема секционирования (другая)

  Обычная несекционированная таблица

  Таблица с другим ключом секционирования

## Шардирование 

### Шарды

```sql
CREATE TABLE orders_shard (
    order_id SERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL,
    total_cost NUMERIC(12,2),
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT now()
);
```

### Роутер

```sql
CREATE EXTENSION postgres_fdw;

CREATE SERVER shard1_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host '172.18.0.1', dbname 'postgres', port '5437');

CREATE SERVER shard2_server
    FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host '172.18.0.1', dbname 'postgres', port '5438');

CREATE USER MAPPING FOR current_user
    SERVER shard1_server
    OPTIONS (user 'postgres', password '');

CREATE USER MAPPING FOR current_user
    SERVER shard2_server
    OPTIONS (user 'postgres', password '');

IMPORT FOREIGN SCHEMA public
    FROM SERVER shard1_server
    INTO public;
```

```sql
CREATE TABLE orders_global (
    order_id INTEGER,
    client_id INTEGER,
    total_cost NUMERIC(12,2),
    status VARCHAR(20),
    created_at TIMESTAMP
) PARTITION BY RANGE (client_id);
```

```sql
CREATE FOREIGN TABLE orders_shard1
    PARTITION OF orders_global
    FOR VALUES FROM (1) TO (10001)
    SERVER shard1_server
    OPTIONS (schema_name 'public', table_name 'orders_shard');

CREATE FOREIGN TABLE orders_shard2
    PARTITION OF orders_global
    FOR VALUES FROM (10001) TO (20001)
    SERVER shard2_server
    OPTIONS (schema_name 'public', table_name 'orders_shard');
```

```sql
EXPLAIN SELECT * FROM orders_global WHERE client_id = 5000;
```

<img width="685" height="79" alt="image" src="https://github.com/user-attachments/assets/8aee99a1-4132-469a-9438-78956cd78cd5" />
