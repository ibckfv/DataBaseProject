## Cassandra

### docker-compose

```
version: '3.8'

services:
  cassandra-1:
    image: cassandra:latest
    container_name: cassandra-1
    ports:
      - "9042:9042"
    environment:
      - CASSANDRA_CLUSTER_NAME=TestCluster
      - CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch
      - CASSANDRA_SEEDS=cassandra-1,cassandra-2
    healthcheck:
      test: ["CMD", "cqlsh", "-u", "cassandra", "-p", "cassandra" ,"-e", "describe keyspaces"]
      interval: 15s
      timeout: 10s
      retries: 10

  cassandra-2:
    image: cassandra:latest
    container_name: cassandra-2
    environment:
      - CASSANDRA_CLUSTER_NAME=TestCluster
      - CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch
      - CASSANDRA_SEEDS=cassandra-1,cassandra-2
    depends_on:
      cassandra-1:
        condition: service_healthy

  cassandra-3:
    image: cassandra:latest
    container_name: cassandra-3
    environment:
      - CASSANDRA_CLUSTER_NAME=TestCluster
      - CASSANDRA_ENDPOINT_SNITCH=GossipingPropertyFileSnitch
      - CASSANDRA_SEEDS=cassandra-1,cassandra-2
    depends_on:
      cassandra-2:
        condition: service_started
```

## Keyspace

<img width="1190" height="176" alt="image" src="https://github.com/user-attachments/assets/7988049e-827b-4954-b33f-166ec642caa9" />

<img width="1439" height="137" alt="image" src="https://github.com/user-attachments/assets/57b72dba-b821-4207-ad66-779c51eb40aa" />

## Таблицы

```sql
-- Таблица 1: gолучить данные пользователя по его ID
CREATE TABLE users_by_id (
    user_id uuid PRIMARY KEY,
    name text,
    city text,
    age int
);

-- Таблица 2: получить всех пользователей в конкретном городе
CREATE TABLE users_by_city (
    city text,
    user_id uuid,
    name text,
    age int,
    PRIMARY KEY ((city), user_id)
);
```

## CRUD

```sql
-- INSERT
INSERT INTO users_by_id (user_id, name, city, age) 
VALUES (123e4567-e89b-12d3-a456-426614174000, 'Алексей', 'Москва', 28);

INSERT INTO users_by_city (city, user_id, name, age) 
VALUES ('Москва', 123e4567-e89b-12d3-a456-426614174000, 'Алексей', 28);

-- SELECT по правильным ключам
SELECT * FROM users_by_id WHERE user_id = 123e4567-e89b-12d3-a456-426614174000;
SELECT * FROM users_by_city WHERE city = 'Москва';

-- UPDATE
UPDATE users_by_id SET age = 29 WHERE user_id = 123e4567-e89b-12d3-a456-426614174000;
UPDATE users_by_city SET age = 29 WHERE city = 'Москва' AND user_id = 123e4567-e89b-12d3-a456-426614174000;
```

<img width="1204" height="120" alt="Снимок экрана 2026-05-03 201012" src="https://github.com/user-attachments/assets/476f8968-2620-4ee8-8dea-58191ed8ea6a" />

<img width="862" height="116" alt="Снимок экрана 2026-05-03 201029" src="https://github.com/user-attachments/assets/afbf7cbc-8cf7-470e-9e32-32a63e46b979" />

**error**

```sql
SELECT * FROM users_by_id WHERE age = 29;
```

<img width="1447" height="94" alt="Снимок экрана 2026-05-03 201156" src="https://github.com/user-attachments/assets/919772fc-0a45-47a1-84ae-e84cf80e3ac8" />

## ElasticSearch

