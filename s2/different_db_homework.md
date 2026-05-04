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

<img width="1445" height="327" alt="image" src="https://github.com/user-attachments/assets/7f30388b-87af-40cd-869a-fe3a5a61e64d" />

<img width="1065" height="714" alt="image" src="https://github.com/user-attachments/assets/57205575-9f3d-4c62-a328-ed65e320fc0c" />

<img width="1583" height="984" alt="image" src="https://github.com/user-attachments/assets/8658132e-717d-4991-8f99-9c44ca22a0cd" />

<img width="1570" height="988" alt="Снимок экрана 2026-05-04 183941" src="https://github.com/user-attachments/assets/bd65d21e-f65d-46cb-8b33-62d60a08b46e" />

<img width="1085" height="790" alt="image" src="https://github.com/user-attachments/assets/3fc528ea-b594-4bd5-9731-18e32f9d5bf1" />

<img width="1062" height="797" alt="image" src="https://github.com/user-attachments/assets/9ae101d6-0b93-4ee7-9a21-c2f58b68c3ef" />

<img width="1072" height="791" alt="image" src="https://github.com/user-attachments/assets/ba26b0ce-08b4-4b82-afd9-509599a6b102" />

<img width="1087" height="808" alt="image" src="https://github.com/user-attachments/assets/e2203413-caf6-4290-8f8a-e52dd1612df3" />

<img width="1072" height="790" alt="image" src="https://github.com/user-attachments/assets/68468726-5d1a-42b1-9c82-822fcc05bc10" />

<img width="1070" height="782" alt="image" src="https://github.com/user-attachments/assets/a14fa970-c5f4-4a59-b6f8-1b46d6763d2d" />

<img width="1035" height="787" alt="image" src="https://github.com/user-attachments/assets/ba60e181-4a9e-42bc-8a14-25057c96fbca" />
