## Docker Compose 
```
services:
  postgres:
    image: postgres:17
    container_name: logistics_db
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: 1469
      POSTGRES_DB: logistics_db
    ports:
      - "5435:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    command: >
      postgres 
      -c wal_level=replica
      -c max_wal_senders=10
      -c max_replication_slots=10
      -c wal_keep_size=1GB
      -c hot_standby=on
      -c listen_addresses=*
    networks:
      - logistics_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d logistics_db"]
      interval: 5s
      timeout: 5s
      retries: 5

  replica1:
    image: postgres:17
    container_name: logistics_db_replica_1
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: 1469
    ports:
      - "5433:5432"
    volumes:
      - pg_replica1_data:/var/lib/postgresql/data
    command: >
      postgres 
      -c hot_standby=on
      -c listen_addresses=*
    networks:
      - logistics_network
    depends_on:
      postgres:
        condition: service_healthy

  replica2:
    image: postgres:17
    container_name: logistics_db_replica_2
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: 1469
    ports:
      - "5434:5432"
    volumes:
      - pg_replica2_data:/var/lib/postgresql/data
    command: >
      postgres 
      -c hot_standby=on
      -c listen_addresses=*
    networks:
      - logistics_network
    depends_on:
      postgres:
        condition: service_healthy

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: my_pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com  
      PGADMIN_DEFAULT_PASSWORD: admin         
    ports:
      - "5050:80" 
    networks:
      - logistics_network
    restart: unless-stopped
    depends_on:
      - postgres   

  flyway:
    image: flyway/flyway:latest
    container_name: flyway
    command: migrate
    volumes:
      - ./migrations:/flyway/sql
    environment:
      FLYWAY_URL: jdbc:postgresql://postgres:5432/logistics_db
      FLYWAY_USER: postgres
      FLYWAY_PASSWORD: 1469
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - logistics_network

  postgres-exporter:
    image: prometheuscommunity/postgres-exporter:latest
    ports:
      - "9187:9187"
    environment:
      DATA_SOURCE_NAME: "postgresql://postgres:1469@postgres:5432/logistics_db?sslmode=disable"
    restart: unless-stopped
    networks:
      - logistics_network
    depends_on:
      - postgres

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml:ro
    restart: unless-stopped
    networks:
      - logistics_network
    depends_on:
      - postgres-exporter

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    restart: unless-stopped
    networks:
      - logistics_network
    depends_on:
      - prometheus

volumes:
  postgres_data:
    driver: local
  pgadmin_data:
  pg_replica1_data:
    driver: local
  pg_replica2_data:
    driver: local

networks:
  logistics_network:
    driver: bridge
```

## Replication

<img width="1450" height="92" alt="image" src="https://github.com/user-attachments/assets/9f780902-d94b-416b-998a-e37f1ece13f5" />

<img width="1448" height="97" alt="image" src="https://github.com/user-attachments/assets/a149a0a3-b12a-4b44-9f90-c385b7b6305c" />

<img width="1453" height="535" alt="image" src="https://github.com/user-attachments/assets/76f983de-df0e-4e27-afba-072a0fc87750" />

<img width="1450" height="76" alt="image" src="https://github.com/user-attachments/assets/c08cfb96-5407-4a49-bda6-39eb210a6667" />

## Logical Replication

### Master

```sql
CREATE PUBLICATION logistics_publication FOR TABLE 
    customers_logical,
    orders_logical;
```

<img width="1434" height="51" alt="Снимок экрана 2026-03-30 230628" src="https://github.com/user-attachments/assets/e73cd1e4-18d4-42f7-aa14-88810fcf88b2" />

### Replica

```sql
CREATE SUBSCRIPTION logistics_subscription 
CONNECTION 'host=172.18.0.1 port=5435 dbname=logistics_db user=postgres password=admin123' 
PUBLICATION logistics_publication;
```

<img width="1446" height="106" alt="Снимок экрана 2026-03-30 230638" src="https://github.com/user-attachments/assets/cf45d28e-113a-46c6-894e-6d7b99235ed0" />

### DDL

<img width="1443" height="69" alt="image" src="https://github.com/user-attachments/assets/4e43904c-9e54-489f-9fac-4426706b4a10" />

<img width="1329" height="178" alt="image" src="https://github.com/user-attachments/assets/841844c9-fd1f-4c70-bd1b-0e7a9ea31a02" />
 ### Replica Identity
 
<img width="1434" height="51" alt="Снимок экрана 2026-03-30 230628" src="https://github.com/user-attachments/assets/e38ab77d-f21f-4aa3-92ae-872ca68ed578" />

<img width="1448" height="105" alt="image" src="https://github.com/user-attachments/assets/336335b7-4278-4f40-b4a7-0680f108197e" />

### Replication Status

<img width="1452" height="143" alt="image" src="https://github.com/user-attachments/assets/d314c127-9259-45ec-ab54-a9384c13b6fd" />

<img width="1450" height="138" alt="image" src="https://github.com/user-attachments/assets/800264e9-4fe3-4816-a998-09888d14a2d9" />

### Почему нужен pg_dump/pg_restore

Logical replication НЕ реплицирует:
Структуру таблиц (DDL)
Последовательности (SEQUENCES)
Индексы
Ограничения
Триггеры
