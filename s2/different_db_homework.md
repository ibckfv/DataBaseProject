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

## InfluxDB

## Шаг 0 Docker

```yaml
version: '3.8'

services:
  influxdb:
    image: influxdb:2.7
    ports:
      - "8086:8086"
    volumes:
      - influx-data:/var/lib/influxdb2
    environment:
      DOCKER_INFLUXDB_INIT_MODE: setup
      DOCKER_INFLUXDB_INIT_USERNAME: admin
      DOCKER_INFLUXDB_INIT_PASSWORD: password123
      DOCKER_INFLUXDB_INIT_ORG: myorg
      DOCKER_INFLUXDB_INIT_BUCKET: mydb
      DOCKER_INFLUXDB_INIT_ADMIN_TOKEN: mytoken

volumes:
  influx-data:
```

## Шаг 1 Доступ к системе

Веб-интерфейс доступен по адресу:

```
http://localhost:8086
```

Bucket `mydb` был создан автоматически.

---

## Шаг 2 Вставка данных

```bash
curl -X POST "http://localhost:8086/api/v2/write?bucket=mydb&org=myorg&precision=s" \
  -H "Authorization: Token mytoken" \
  --data-raw "temperature,location=room1 value=23"

curl -X POST "http://localhost:8086/api/v2/write?bucket=mydb&org=myorg&precision=s" \
  -H "Authorization: Token mytoken" \
  --data-raw "temperature,location=room1 value=25"

curl -X POST "http://localhost:8086/api/v2/write?bucket=mydb&org=myorg&precision=s" \
  -H "Authorization: Token mytoken" \
  --data-raw "temperature,location=room2 value=20"

curl -X POST "http://localhost:8086/api/v2/write?bucket=mydb&org=myorg&precision=s" \
  -H "Authorization: Token mytoken" \
  --data-raw "temperature,location=room2 value=22"
```

---

## Шаг 3 Проверка данных

```sql
from(bucket: "mydb")
  |> range(start: -1h)
```

---

## Шаг 4 Выборка за последние 5 минут

```sql
from(bucket: "mydb")
  |> range(start: -5m)
```

---

## Шаг 5 Агрегация данных

```sql
from(bucket: "mydb")
  |> range(start: -1h)
  |> group(columns: ["location"])
  |> mean()
```

---

## Результат

| location | avg(value) |
| -------- | ---------- |
| room1    | ~24        |
| room2    | ~21        |

---

## MongoDB

```
docker run -d -p 27017:27017 mongo

docker exec -it boring_montalcini mongosh

use shopDB
```

### Задание 1.

```sql
db.products.insertMany([
    {
        name: "Складной смартфон X99",
        category: "Мобильные устройства",
        price: 74990,
        inStock: true,
        manufacturer: {
            name: "Samsung",
            country: "Южная Корея"
        }
    },
    {
        name: "Ноутбук MacBook Air на M3",
        category: "Компьютерная техника",
        price: 119990,
        inStock: true,
        manufacturer: {
            name: "Apple",
            country: "США"
        }
    },
    {
        name: "Наушники беспроводные WH-100XM2",
        category: "Аудио",
        price: 9990,
        inStock: false,
        manufacturer: {
            name: "Sony",
            country: "Япония"
        }
    },
    {
        name: "Смарт-колонка Яндекс Станция Макс",
        category: "Устройства для умного дома",
        price: 16990,
        inStock: true,
        manufacturer: {
            name: "Яндекс",
            country: "Россия"
        }
    },
    {
        name: "IPhone 20",
        category: "Мобильные устройства",
        price: 99000,
        inStock: false,
        manufacturer: {
            name: "Apple",
            country: "Iran"
        }
    }
])
```

```sql

acknowledged: true,
insertedIds: {
'0': ObjectId('69de61202b6449317944ba8d'),
'1': ObjectId('69de61202b6449317944ba8e'),
'2': ObjectId('69de61202b6449317944ba8f'),
'3': ObjectId('69de61202b6449317944ba90'),
'4': ObjectId('69de61202b6449317944ba91')
}
}
```


### Задание 2.

```sql

db.products.find().pretty()

[
{
_id: ObjectId('69de61202b6449317944ba8d'),
name: 'Складной смартфон X99',
category: 'Мобильные устройства',
price: 74990,
inStock: true,
manufacturer: { name: 'Samsung', country: 'Южная Корея' }
},
{
_id: ObjectId('69de61202b6449317944ba8e'),
name: 'Ноутбук MacBook Air на M3',
category: 'Компьютерная техника',
price: 119990,
inStock: true,
manufacturer: { name: 'Apple', country: 'США' }
},
{
_id: ObjectId('69de61202b6449317944ba8f'),
name: 'Наушники беспроводные WH-100XM2',
category: 'Аудио',
price: 9990,
inStock: false,
manufacturer: { name: 'Sony', country: 'Япония' }
},
{
_id: ObjectId('69de61202b6449317944ba90'),
name: 'Смарт-колонка Яндекс Станция Макс',
category: 'Устройства для умного дома',
price: 16990,
inStock: true,
manufacturer: { name: 'Яндекс', country: 'Россия' }
},
{
_id: ObjectId('69de61202b6449317944ba91'),
name: 'IPhone 20',
category: 'Мобильные устройства',
price: 99000,
inStock: false,
manufacturer: { name: 'Apple', country: 'Iran' }
}
]
```

```sql

db.products.find({ category: "Мобильные устройства" }).pretty()

[
{
_id: ObjectId('69de61202b6449317944ba8d'),
name: 'Складной смартфон X99',
category: 'Мобильные устройства',
price: 74990,
inStock: true,
manufacturer: { name: 'Samsung', country: 'Южная Корея' }
},
{
_id: ObjectId('69de61202b6449317944ba91'),
name: 'IPhone 20',
category: 'Мобильные устройства',
price: 99000,
inStock: false,
manufacturer: { name: 'Apple', country: 'Iran' }
}
]
```

### Задание 3.

```sql

db.products.find(
{
category: "Мобильные устройства",
price: { $gt: 10000 }
},
{
_id: 0,
name: 1,
price: 1
}
).pretty()

[
{ name: 'Складной смартфон X99', price: 74990 },
{ name: 'IPhone 20', price: 99000 }
]
```

## Neo4J

docker-compose
```
version: "3.8"

services:
  neo4j:
    image: neo4j:5
    container_name: neo4j-demo
    restart: unless-stopped
    ports:
      - "7474:7474"   # HTTP (Browser)
      - "7687:7687"   # Bolt
    environment:
      - NEO4J_AUTH=neo4j/password
    volumes:
      - neo4j_data:/data
      - neo4j_logs:/logs

volumes:
  neo4j_data:
  neo4j_logs:
```

Датасет из README.md
```cypher
LOAD CSV WITH HEADERS FROM
'https://raw.githubusercontent.com/Mario-cartoon/ArticleBD/main/Category.csv'
AS line FIELDTERMINATOR ','
MERGE (category:Category {categoryID: line.title})
  ON CREATE SET category.title = line.title;

LOAD CSV WITH HEADERS FROM
'https://raw.githubusercontent.com/Mario-cartoon/ArticleBD/main/Articles.csv'
AS line FIELDTERMINATOR ','
MERGE (article:Article {articleID: line.title});

LOAD CSV WITH HEADERS FROM
'https://raw.githubusercontent.com/Mario-cartoon/ArticleBD/main/Reader.csv'
AS line FIELDTERMINATOR ','
MERGE (reader:Reader {readerID: line.name})
  ON CREATE SET reader.nickname = line.nickname,reader.email = line.email;

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Mario-cartoon/ArticleBD/main/Category_articles.csv' AS line
MATCH (category:Category {categoryID: line.title_category})
MATCH (article:Article {articleID: line.title_article})
CREATE (article)-[:IS_IN]->(category);

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/Mario-cartoon/ArticleBD/main/read_articles.csv' AS line
MATCH (reader:Reader {readerID: line.name})
MATCH (article:Article {articleID: line.title_article})
CREATE (reader)-[:READ]->(article);
```

---
## Вставка

### Добавить категорию 

```cypher
MERGE (category:Category {categoryID: 'tech-news'})
ON CREATE SET category.title = 'Технологии и новости';
```


### Добавить статью

```cypher
MERGE (article:Article {articleID: 'neo4j-best-practices'})
  ON CREATE SET article.title = 'Лучшие практики работы с Neo4j',
                article.publishedAt = datetime();

// Связать статью с категорией
MATCH (article:Article {articleID: 'neo4j-best-practices'})
MATCH (category:Category {categoryID: 'tech-news'})
MERGE (article)-[:IS_IN]->(category);
```


### Добавить читателя, добавить связь с 3 статьями

```cypher
// Создаём читателя
MERGE (reader:Reader {readerID: 'alice-wonder'})
  ON CREATE SET reader.nickname = 'AliceW',
                reader.email = 'alice@example.com';

// Связываем с существующими статьями (3-5 штук)
MATCH (reader:Reader {readerID: 'alice-wonder'})
MATCH (article:Article) 
WHERE article.articleID IN [
  'neo4j-best-practices', 
  'Gradient boosting with CatBoost (part 2/3)', 
  'Clustering of clients. Analysis of the client\'s personality'
]
FOREACH (a IN [article] | 
  MERGE (reader)-[:READ {readAt: datetime()}]->(a)
);
```


---
## Запросы

### Отобразить всех пользователей, статьи и связи между ними

```cypher
MATCH (reader:Reader)-[r:READ]->(article:Article)
RETURN reader.readerID AS reader, 
       article.articleID AS article,
       r.readAt AS readAt
ORDER BY reader.readerID;
```

### Выбрать пользователя и найти категории, которые он читает

```cypher
MATCH (reader:Reader {readerID: 'alice-wonder'})-[:READ]->(article:Article)-[:IS_IN]->(category:Category)
RETURN DISTINCT category.categoryID AS categoryID,
                category.title AS categoryTitle,
                count(article) AS articlesRead
ORDER BY articlesRead DESC;
```


### Найти самых активных читателей (посчитать, кто читает больше всего статей)

```cypher
MATCH (reader:Reader)-[:READ]->(article:Article)
RETURN reader.readerID AS reader,
       reader.nickname AS nickname,
       count(article) AS articlesCount
ORDER BY articlesCount DESC
LIMIT 10;
```


### Выбрать статью и найти похожие статьи (статьи, которые читают те же пользователи)

```cypher
// Подставьте articleID целевой статьи
MATCH (target:Article {articleID: 'neo4j-best-practices'})<-[:READ]-(reader:Reader)-[:READ]->(similar:Article)
WHERE target <> similar
WITH similar, count(DISTINCT reader) AS commonReaders
ORDER BY commonReaders DESC
LIMIT 10
RETURN similar.articleID AS articleID,
       similar.title AS title,
       commonReaders AS similarityScore;
```


### Рекомендации по категориям


#### Найти категории, которые читает пользователь

```cypher
MATCH (reader:Reader {readerID: 'alice-wonder'})-[:READ]->(article:Article)-[:IS_IN]->(category:Category)
RETURN DISTINCT category.categoryID AS categoryID,
                category.title AS categoryTitle;
```


#### Предложить статьи из этих категорий, которые он ещё не читал 


```cypher
MATCH (reader:Reader {readerID: 'alice-wonder'})-[:READ]->(readArticle:Article)-[:IS_IN]->(category:Category)
WITH reader, collect(DISTINCT readArticle) AS readArticles, collect(DISTINCT category) AS readCategories

UNWIND readCategories AS category
MATCH (category)<-[:IS_IN]-(recommended:Article)
WHERE NOT recommended IN readArticles
AND NOT (reader)-[:READ]->(recommended)
RETURN recommended.articleID AS articleID,
recommended.title AS title,
category.title AS categoryTitle
ORDER BY categoryTitle
LIMIT 10;
```


## Qdrant

```
services:
  qdrant:
    image: qdrant/qdrant:latest
    container_name: qdrant
    ports:
      - "6333:6333"  # HTTP REST API + Dashboard
      - "6334:6334"  # gRPC API
    volumes:
      - qdrant_data:/qdrant/storage
      - qdrant_snapshots:/qdrant/snapshots
    environment:
      - QDRANT__SERVICE__HTTP_PORT=6333
      - QDRANT__SERVICE__GRPC_PORT=6334
      - QDRANT__LOG_LEVEL=INFO
      - QDRANT__CLUSTER__ENABLED=false
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:6333/healthz"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s

volumes:
  qdrant_data:
    driver: local
  qdrant_snapshots:
    driver: local
```

## Redis

### Часть 1
docker run -d --name redis -p 6379:6379 redis

docker ps

docker exec -it redis redis-cli ping


### Часть 2 
```
redis-cli 
INCR article:10:views
INCR article:10:views
INCR article:10:views
```

### Часть 3 
```
ZADD articles:leaderboard 300 article:1 200 article:2 150 article:3 1000 article:4

ZREVRANGE articles:leaderboard 0 2

ZREVRANGE articles:leaderboard 0 2 WITHSCORES
```
```
ZINCRBY articles:leaderboard 5000 article:3

ZREVRANGE articles:leaderboard 0 2 WITHSCORES
```

### Часть 4 

```
INCR user:123:likes
INCR user:123:likes
INCR user:123:likes

EXPIRE user:123:likes 60

GET user:123:likes
TTL user:123:likes
```
