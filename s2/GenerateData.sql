-- Скрипт заполнения базы данных logistics_db тестовыми данными
-- ОСНОВНЫЕ ТАБЛИЦЫ (250k записей): clients, orders, cargos, payments, tracking
-- ОСТАЛЬНЫЕ ТАБЛИЦЫ (до 1000 записей): справочники и вспомогательные

DO $$
DECLARE
    v_start_time timestamp;
    v_total_records constant int := 250000;
    v_small_records constant int := 1000;
    v_batch_size constant int := 1000;
    
    -- Массивы для данных
    v_cities text[] := ARRAY['Москва', 'Санкт-Петербург', 'Новосибирск', 'Екатеринбург', 'Казань', 
                             'Нижний Новгород', 'Челябинск', 'Самара', 'Омск', 'Ростов-на-Дону'];
    v_streets text[] := ARRAY['Ленина', 'Советская', 'Мира', 'Гагарина', 'Пушкина', 
                              'Кирова', 'Молодежная', 'Садовая', 'Комсомольская', 'Калинина'];
    v_descriptions text[] := ARRAY['Срочная доставка', 'Стандартная перевозка', 'Международный груз', 
                                   'Сборный груз', 'Консолидация', 'Складское хранение'];
    v_package_types text[] := ARRAY['Коробка', 'Паллета', 'Контейнер'];
    v_payment_methods text[] := ARRAY['Карта', 'Счёт', 'Наличные'];
    v_payment_statuses text[] := ARRAY['Проведён', 'В обработке', 'Отклонён'];
    v_order_statuses text[] := ARRAY['Новый', 'В пути', 'Доставлен', 'Отменён'];
    v_tariff_types text[] := ARRAY['Эконом', 'Экспресс'];
    v_warehouse_types text[] := ARRAY['Хранение', 'Сортировка', 'Транзитный'];
    v_vehicle_types text[] := ARRAY['Грузовик', 'Самолет', 'Корабль', 'Поезд'];
    v_vehicle_statuses text[] := ARRAY['Доступен', 'В рейсе', 'Ремонт'];
    v_document_types text[] := ARRAY['Договор', 'ТТН', 'Счет-фактура', 'Акт', 'Сертификат'];
    v_tracking_statuses text[] := ARRAY['В пути', 'Задержан', 'Доставлен'];
    v_first_names text[] := ARRAY['Иван', 'Петр', 'Сергей', 'Андрей', 'Алексей'];
    v_last_names text[] := ARRAY['Иванов', 'Петров', 'Сидоров', 'Смирнов', 'Кузнецов'];
    
    -- Переменные для ID
    v_i int;
    v_random float;
    v_random2 float;
    v_random3 float;
    v_client_id int;
    v_tariff_id int;
    v_warehouse_id int;
    v_employee_id int;
    v_vehicle_id int;
    v_driver_id int;
    v_route_id int;
    v_trip_id int;
    v_order_id int;
    v_start_date date;
    v_end_date date;
    
    -- Массивы ID
    v_employee_ids int[];
    v_vehicle_ids int[];
    v_route_ids int[];
    v_warehouse_ids int[];
    v_tariff_ids int[];
BEGIN
    v_start_time := clock_timestamp();
    RAISE NOTICE 'Начало заполнения базы данных...';
    
    -- =====================================================
    -- 1. МАЛЫЕ ТАБЛИЦЫ (до 1000 записей)
    -- =====================================================
    RAISE NOTICE '1. Заполнение малых таблиц (справочники)...';
    
    -- Тарифы (2 записи)
    TRUNCATE tariffs RESTART IDENTITY CASCADE;
    INSERT INTO tariffs (type, price_per_km, price_per_kg) VALUES
        ('Эконом', 30.50, 15.20),
        ('Экспресс', 75.80, 35.90);
    v_tariff_ids := ARRAY[1,2];
    
    -- Склады (20 записей)
    TRUNCATE warehouses RESTART IDENTITY CASCADE;
    FOR v_i IN 1..20 LOOP
        INSERT INTO warehouses (name, address, capacity, type, manager_id) VALUES
            ('Склад ' || v_i, 
             v_cities[1 + ((v_i-1) % array_length(v_cities, 1))] || ', ул. ' || 
             v_streets[1 + ((v_i-1) % array_length(v_streets, 1))] || ', д. ' || v_i,
             round((random() * 9000 + 1000)::numeric, 2),
             v_warehouse_types[1 + ((v_i-1) % array_length(v_warehouse_types, 1))],
             NULL);
    END LOOP;
    v_warehouse_ids := ARRAY(SELECT warehouse_id FROM warehouses ORDER BY warehouse_id);
   	-- В начале кода, после заполнения warehouses:
	SELECT ARRAY_AGG(warehouse_id ORDER BY warehouse_id) INTO v_warehouse_ids FROM warehouses;
	RAISE NOTICE 'Склады: %', v_warehouse_ids;
    -- Маршруты (30 записей)
    TRUNCATE routes RESTART IDENTITY CASCADE;
    FOR v_i IN 1..30 LOOP
        INSERT INTO routes (departure_city, arrival_city, distance_km, estimated_time) VALUES
            (v_cities[1 + ((v_i-1) % array_length(v_cities, 1))],
             v_cities[1 + ((v_i + 3) % array_length(v_cities, 1))],
             round((random() * 1500 + 100)::numeric, 2),
             make_interval(hours => (random() * 48)::int));
    END LOOP;
    v_route_ids := ARRAY(SELECT route_id FROM routes ORDER BY route_id);
    
    -- Сотрудники (50 записей)
    TRUNCATE employees RESTART IDENTITY CASCADE;
    FOR v_i IN 1..50 LOOP
        INSERT INTO employees (full_name, phone, hire_date, notes) VALUES
            (v_last_names[1 + ((v_i-1) % array_length(v_last_names, 1))] || ' ' || 
             v_first_names[1 + ((v_i-1) % array_length(v_first_names, 1))] || ' ' ||
             v_first_names[1 + ((v_i + 2) % array_length(v_first_names, 1))] || 'ович',
             '+7' || (900000000 + v_i * 17)::text,
             date '2015-01-01' + (random() * 3000)::int,
             CASE WHEN random() < 0.2 THEN 'Заметка о сотруднике ' || v_i ELSE NULL END);
    END LOOP;
    v_employee_ids := ARRAY(SELECT employee_id FROM employees ORDER BY employee_id);
    
    -- Транспорт (30 записей)
    TRUNCATE vehicles RESTART IDENTITY CASCADE;
    FOR v_i IN 1..30 LOOP
        INSERT INTO vehicles (type, plate_number, capacity, status) VALUES
            (v_vehicle_types[1 + ((v_i-1) % array_length(v_vehicle_types, 1))],
             'А' || (v_i + 100) || 'ВВ' || (v_i + 50) || 'RUS',
             round((random() * 45 + 5)::numeric, 2),
             v_vehicle_statuses[1 + (random() * 2)::int]);
    END LOOP;
    v_vehicle_ids := ARRAY(SELECT vehicle_id FROM vehicles ORDER BY vehicle_id);
    
    -- Водители (30 записей)
    TRUNCATE drivers RESTART IDENTITY CASCADE;
    FOR v_i IN 1..30 LOOP
        v_employee_id := v_employee_ids[1 + ((v_i-1) % array_length(v_employee_ids, 1))];
        v_vehicle_id := CASE WHEN v_i <= 20 THEN v_vehicle_ids[v_i] ELSE 1 END;
        
        INSERT INTO drivers (driver_id, license_number, license_category, vehicle_id) VALUES
            (v_employee_id,
             '99AA' || (v_i + 100000)::text, 
             CASE WHEN random() < 0.7 THEN 'B' WHEN random() < 0.9 THEN 'C' ELSE 'E' END,
             v_vehicle_id);
    END LOOP;
    
    -- Поездки (500 записей)
    TRUNCATE trips RESTART IDENTITY CASCADE;
    FOR v_i IN 1..500 LOOP
        v_route_id := v_route_ids[1 + (random() * (array_length(v_route_ids, 1) - 1))::int];
        v_vehicle_id := v_vehicle_ids[1 + (random() * (array_length(v_vehicle_ids, 1) - 1))::int];
        v_driver_id := 1 + (random() * 29)::int; -- drivers 1-30
        
        INSERT INTO trips (route_id, vehicle_id, driver_id, departure_datetime, arrival_datetime, notes) VALUES
            (v_route_id,
             v_vehicle_id,
             v_driver_id,
             timestamp '2023-01-01 08:00:00' + (random() * 365) * interval '1 day',
             CASE WHEN random() < 0.8 THEN 
                 timestamp '2023-01-02 12:00:00' + (random() * 365) * interval '1 day'
             ELSE NULL END,
             CASE WHEN random() < 0.15 THEN 'Задержка из-за погодных условий' ELSE NULL END);
    END LOOP;
    
    -- Обновляем manager_id в warehouses
    FOR v_i IN 1..20 LOOP
        UPDATE warehouses SET manager_id = v_employee_ids[1 + (random() * (array_length(v_employee_ids, 1) - 1))::int]
        WHERE warehouse_id = v_i;
    END LOOP;
    
    -- =====================================================
    -- 2. КЛИЕНТЫ (250 000 записей)
    -- =====================================================
    RAISE NOTICE '2. Заполнение clients (250 000 записей)...';
    TRUNCATE clients RESTART IDENTITY CASCADE;
    
    FOR v_i IN 1..v_total_records LOOP
        IF v_i % v_batch_size = 0 THEN
            RAISE NOTICE '   clients: %/%', v_i, v_total_records;
        END IF;
        
        INSERT INTO clients (name) VALUES
            ('Клиент ' || v_i || ' ' || v_last_names[1 + ((v_i-1) % array_length(v_last_names, 1))]);
    END LOOP;
    
    -- =====================================================
    -- 3. КОНТАКТЫ КЛИЕНТОВ (только для первых 1000 клиентов)
    -- =====================================================
    RAISE NOTICE '3. Заполнение client_contacts (1 000 записей)...';
    TRUNCATE client_contacts RESTART IDENTITY CASCADE;
    
    FOR v_i IN 1..v_small_records LOOP
        INSERT INTO client_contacts (client_id, phone, email, address) VALUES
            (v_i,
             '+7' || (900000000 + v_i * 7)::text,
             'client' || v_i || '@example.com',
             v_cities[1 + ((v_i-1) % array_length(v_cities, 1))] || ', ул. ' || 
             v_streets[1 + ((v_i) % array_length(v_streets, 1))] || ', д. ' || (v_i % 100 + 1));
    END LOOP;
    
    -- =====================================================
    -- 4. ДОГОВОРЫ (1 000 записей)
    -- =====================================================
    RAISE NOTICE '4. Заполнение contracts (1 000 записей)...';
    TRUNCATE contracts RESTART IDENTITY CASCADE;
    
    FOR v_i IN 1..v_small_records LOOP
        -- 70% договоров для первых 100 клиентов (перекос)
        IF random() < 0.7 THEN
            v_client_id := 1 + (random() * 99)::int;
        ELSE
            v_client_id := 101 + (random() * 899)::int;
        END IF;
        
        INSERT INTO contracts (client_id, contract_date, valid_until, terms) VALUES
            (v_client_id,
             date '2018-01-01' + (random() * 2000)::int,
             CASE WHEN random() < 0.7 THEN date '2023-01-01' + (random() * 1000)::int ELSE NULL END,
             CASE WHEN random() < 0.3 THEN 'Особые условия: доставка в выходные' ELSE NULL END);
    END LOOP;
    
    -- =====================================================
    -- 5. ЗАКАЗЫ (250 000 записей) - ОСНОВНАЯ ТАБЛИЦА
    -- =====================================================
    RAISE NOTICE '5. Заполнение orders (250 000 записей)...';
    TRUNCATE orders RESTART IDENTITY CASCADE;
    
    FOR v_i IN 1..v_total_records LOOP
        IF v_i % v_batch_size = 0 THEN
            RAISE NOTICE '   orders: %/%', v_i, v_total_records;
        END IF;
        
        -- Client_id: сильно неравномерное (70% заказов от 10% клиентов)
        v_random := random();
        IF v_random < 0.7 THEN
            v_client_id := 1 + ((v_i-1) % 25000); -- топ 10% клиентов
        ELSE
            v_client_id := 25001 + ((v_i-1) % 225000);
        END IF;
        
        -- Tariff_id: 2 значения
        v_tariff_id := v_tariff_ids[1 + (random() * 1)::int];
        
        -- Trip_id: ссылка на trips (30% NULL)
        IF random() < 0.7 THEN
            v_trip_id := 1 + (random() * 499)::int;
        ELSE
            v_trip_id := NULL;
        END IF;
        
        -- Warehouse_id: ссылка на склады (20% NULL)
        IF random() < 0.8 THEN
    		SELECT warehouse_id INTO v_warehouse_id FROM warehouses ORDER BY random() LIMIT 1;
		ELSE
   			v_warehouse_id := NULL;
		END IF;
        
        -- Статус с неравномерным распределением
        v_random2 := random();
        IF v_random2 < 0.4 THEN
            v_random3 := 1; -- 'Новый' 40%
        ELSIF v_random2 < 0.7 THEN
            v_random3 := 2; -- 'В пути' 30%
        ELSIF v_random2 < 0.9 THEN
            v_random3 := 3; -- 'Доставлен' 20%
        ELSE
            v_random3 := 4; -- 'Отменён' 10%
        END IF;
        
        -- Диапазон доставки (с гарантией lower < upper)
        v_start_date := date '2022-01-01' + (random() * 300)::int;
        v_end_date := v_start_date + (random() * 30 + 1)::int;
        
        INSERT INTO orders (
            client_id, tariff_id, trip_id, warehouse_id,
            created_at, delivery_date, status, total_cost,
            notes, delivery_range, metadata, priority
        ) VALUES (
            v_client_id,
            v_tariff_id,
            v_trip_id,
            v_warehouse_id,
            timestamp '2022-01-01 00:00:00' + (random() * 700) * interval '1 day',
            CASE WHEN random() < 0.8 THEN 
                date '2022-01-10' + (random() * 700)::int
            ELSE NULL END,
            v_order_statuses[v_random3],
            CASE WHEN random() < 0.9 THEN round((random() * 100000 + 500)::numeric, 2) ELSE NULL END,
            CASE WHEN random() < 0.1 THEN 'Срочная доставка, звонить за час' ELSE NULL END,
            CASE WHEN random() < 0.3 THEN daterange(v_start_date, v_end_date) ELSE NULL END,
            CASE 
                WHEN random() < 0.33 THEN 
                    jsonb_build_object('source', 'web', 'priority', (random() * 5)::int)
                WHEN random() < 0.66 THEN
                    jsonb_build_object('source', 'mobile', 'app_version', '2.1.' || (random() * 10)::int)
                ELSE
                    jsonb_build_object('source', 'api', 'batch_id', v_i)
            END,
            (random() * 5)::int
        );
    END LOOP;
    
    -- =====================================================
    -- 6. ГРУЗЫ (250 000 записей) - ОСНОВНАЯ ТАБЛИЦА
    -- =====================================================
    RAISE NOTICE '6. Заполнение cargos (250 000 записей)...';
    TRUNCATE cargos RESTART IDENTITY CASCADE;
    
    FOR v_i IN 1..v_total_records LOOP
        IF v_i % v_batch_size = 0 THEN
            RAISE NOTICE '   cargos: %/%', v_i, v_total_records;
        END IF;
        
        v_order_id := 1 + ((v_i-1) % v_total_records);
        
        -- Package_type с перекосом
        v_random := random();
        IF v_random < 0.5 THEN
            v_random2 := 1; -- Коробка 50%
        ELSIF v_random < 0.8 THEN
            v_random2 := 2; -- Паллета 30%
        ELSE
            v_random2 := 3; -- Контейнер 20%
        END IF;
        
        INSERT INTO cargos (
            order_id, description, weight, package_type,
            price, volume, fragile, danger_class,
            dimensions, storage_conditions, coordinates
        ) VALUES (
            v_order_id,
            CASE WHEN random() < 0.2 THEN v_descriptions[1 + (random() * 5)::int] ELSE NULL END,
            round((random() * 950 + 50)::numeric, 2),
            v_package_types[v_random2],
            CASE WHEN random() < 0.7 THEN round((random() * 50000 + 1000)::numeric, 2) ELSE NULL END,
            CASE WHEN random() < 0.5 THEN round((random() * 10)::numeric, 2) ELSE NULL END,
            random() < 0.15,
            CASE WHEN random() < 0.1 THEN (random() * 4 + 1)::int ELSE NULL END,
            CASE WHEN random() < 0.3 THEN 
                jsonb_build_object('length', round((random() * 2)::numeric, 2), 
                                  'width', round((random() * 2)::numeric, 2))
            ELSE NULL END,
            CASE WHEN random() < 0.4 THEN 
                ARRAY['Температурный режим', 'Хрупкое']
            ELSE NULL END,
            CASE WHEN random() < 0.2 THEN 
                point((random() * 180 - 90)::int, (random() * 360 - 180)::int)
            ELSE NULL END
        );
    END LOOP;
    
    -- =====================================================
    -- 7. ОТСЛЕЖИВАНИЕ (250 000 записей) - ОСНОВНАЯ ТАБЛИЦА
    -- =====================================================
    RAISE NOTICE '7. Заполнение tracking (250 000 записей)...';
    TRUNCATE tracking RESTART IDENTITY CASCADE;
    
    FOR v_i IN 1..v_total_records LOOP
        IF v_i % v_batch_size = 0 THEN
            RAISE NOTICE '   tracking: %/%', v_i, v_total_records;
        END IF;
        
        v_order_id := 1 + ((v_i-1) % v_total_records);
        
        -- Статус с перекосом
        v_random := random();
        IF v_random < 0.5 THEN
            v_random2 := 1; -- 'В пути' 50%
        ELSIF v_random < 0.8 THEN
            v_random2 := 2; -- 'Задержан' 30%
        ELSE
            v_random2 := 3; -- 'Доставлен' 20%
        END IF;
        
        INSERT INTO tracking (
            order_id, status, updated_at,
            location, location_point, temperature,
            humidity, event_data, processed, delay_minutes
        ) VALUES (
            v_order_id,
            v_tracking_statuses[v_random2],
            timestamp '2023-01-01 00:00:00' + (random() * 365) * interval '1 day',
            CASE 
    			WHEN random() < 0.5 THEN (SELECT warehouse_id FROM warehouses ORDER BY random() LIMIT 1)
    			ELSE NULL 
			END,
            CASE WHEN random() < 0.3 THEN point((random() * 180 - 90)::int, (random() * 360 - 180)::int) ELSE NULL END,
            CASE WHEN random() < 0.4 THEN round((random() * 40 - 10)::numeric, 2) ELSE NULL END,
            CASE WHEN random() < 0.4 THEN (random() * 100)::int ELSE NULL END,
            CASE WHEN random() < 0.2 THEN 
                jsonb_build_object('event', 'scan', 'location', v_cities[1 + (random() * 9)::int])
            ELSE NULL END,
            random() < 0.9,
            CASE WHEN v_random2 = 2 THEN (random() * 1440)::int ELSE NULL END
        );
    END LOOP;
    
    -- =====================================================
    -- 8. ПЛАТЕЖИ (250 000 записей) - ОСНОВНАЯ ТАБЛИЦА
    -- =====================================================
    RAISE NOTICE '8. Заполнение payments (250 000 записей)...';
    TRUNCATE payments RESTART IDENTITY CASCADE;
    
    FOR v_i IN 1..v_total_records LOOP
        IF v_i % v_batch_size = 0 THEN
            RAISE NOTICE '   payments: %/%', v_i, v_total_records;
        END IF;
        
        v_order_id := 1 + ((v_i-1) % v_total_records);
        
        -- Method с перекосом
        v_random := random();
        IF v_random < 0.6 THEN
            v_random2 := 1; -- Карта 60%
        ELSIF v_random < 0.85 THEN
            v_random2 := 2; -- Счёт 25%
        ELSE
            v_random2 := 3; -- Наличные 15%
        END IF;
        
        -- Status с перекосом
        v_random3 := random();
        IF v_random3 < 0.7 THEN
            v_random := 1; -- Проведён 70%
        ELSIF v_random3 < 0.9 THEN
            v_random := 2; -- В обработке 20%
        ELSE
            v_random := 3; -- Отклонён 10%
        END IF;
        
        INSERT INTO payments (
            order_id, amount, payment_date,
            method, status, transaction_id,
            card_last4, bank_info, fraud_score
        ) VALUES (
            v_order_id,
            round((random() * 150000 + 1000)::numeric, 2),
            date '2023-01-01' + (random() * 365)::int,
            v_payment_methods[v_random2],
            v_payment_statuses[v_random],
            CASE WHEN random() < 0.8 THEN 'TXN' || (10000000 + v_i)::text ELSE NULL END,
            CASE WHEN v_random2 = 1 AND random() < 0.9 THEN (1000 + (random() * 8999)::int)::text ELSE NULL END,
            CASE WHEN v_random2 = 2 AND random() < 0.5 THEN 
                jsonb_build_object('bank', 'Сбербанк', 'account', '40702810' || (1000000 + v_i)::text)
            ELSE NULL END,
            CASE WHEN random() < 0.05 THEN random()::double precision ELSE NULL END
        );
    END LOOP;
    
    -- =====================================================
    -- 9. МАЛЫЕ ТАБЛИЦЫ (до 1000 записей)
    -- =====================================================
    RAISE NOTICE '9. Заполнение остальных малых таблиц...';
    
    -- Счета (1000 записей)
    TRUNCATE invoices RESTART IDENTITY CASCADE;
    FOR v_i IN 1..v_small_records LOOP
        v_order_id := 1 + (random() * (v_total_records - 1))::int;
        INSERT INTO invoices (order_id, invoice_date, amount) VALUES
            (v_order_id,
             date '2023-01-01' + (random() * 365)::int,
             round((random() * 150000 + 1000)::numeric, 2));
    END LOOP;
    
    -- Документы (1000 записей)
    TRUNCATE documents RESTART IDENTITY CASCADE;
    FOR v_i IN 1..v_small_records LOOP
        v_order_id := 1 + (random() * (v_total_records - 1))::int;
        INSERT INTO documents (order_id, file_link, issued_date, document_type) VALUES
            (v_order_id,
             '/docs/order_' || v_order_id || '/' || v_i || '.pdf',
             date '2023-01-01' + (random() * 365)::int,
             v_document_types[1 + (random() * 4)::int]);
    END LOOP;
    
    -- Логи заказов (1000 записей)
    TRUNCATE order_logs RESTART IDENTITY CASCADE;
    FOR v_i IN 1..v_small_records LOOP
        v_order_id := 1 + (random() * (v_total_records - 1))::int;
        INSERT INTO order_logs (order_id, action, user_name, changed_at) VALUES
            (v_order_id,
             CASE 
                 WHEN random() < 0.33 THEN 'Создан заказ'
                 WHEN random() < 0.66 THEN 'Изменён статус'
                 ELSE 'Удалён заказ'
             END,
             CASE 
                 WHEN random() < 0.5 THEN 'admin_user'
                 ELSE 'app'
             END,
             timestamp '2023-01-01 00:00:00' + (random() * 365) * interval '1 day');
    END LOOP;
    
    -- Архив заказов (1000 записей)
    TRUNCATE orders_archive RESTART IDENTITY CASCADE;
    FOR v_i IN 1..v_small_records LOOP
        v_order_id := 1 + (random() * (v_total_records - 1))::int;
        INSERT INTO orders_archive (order_id, old_status, old_cost, archived_at) VALUES
            (v_order_id,
             v_order_statuses[1 + (random() * 3)::int],
             CASE WHEN random() < 0.8 THEN round((random() * 100000)::numeric, 2) ELSE NULL END,
             timestamp '2023-01-01 00:00:00' + (random() * 365) * interval '1 day');
    END LOOP;
    
    -- =====================================================
    -- 10. ДОПОЛНИТЕЛЬНЫЕ ИНДЕКСЫ
    -- =====================================================
    RAISE NOTICE '10. Создание дополнительных индексов...';
    
    CREATE INDEX IF NOT EXISTS idx_orders_client_id_skew ON orders(client_id) WHERE client_id <= 25000;
    CREATE INDEX IF NOT EXISTS idx_orders_status_skew ON orders(status) WHERE status IN ('Новый', 'В пути');
    CREATE INDEX IF NOT EXISTS idx_cargos_weight_range ON cargos(weight) WHERE weight > 500;
    CREATE INDEX IF NOT EXISTS idx_payments_amount_range ON payments(amount) WHERE amount > 50000;
    CREATE INDEX IF NOT EXISTS idx_tracking_processed ON tracking(processed) WHERE processed = false;
    CREATE INDEX IF NOT EXISTS idx_orders_metadata_gin ON orders USING gin(metadata);
    
    -- =====================================================
    -- СТАТИСТИКА
    -- =====================================================
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Заполнение завершено за %', clock_timestamp() - v_start_time;
    RAISE NOTICE 'Статистика заполнения:';
    RAISE NOTICE 'clients: %', (SELECT COUNT(*) FROM clients);
    RAISE NOTICE 'orders: %', (SELECT COUNT(*) FROM orders);
    RAISE NOTICE 'cargos: %', (SELECT COUNT(*) FROM cargos);
    RAISE NOTICE 'tracking: %', (SELECT COUNT(*) FROM tracking);
    RAISE NOTICE 'payments: %', (SELECT COUNT(*) FROM payments);
    RAISE NOTICE 'Остальные таблицы (справочники): < 1000 записей';
    RAISE NOTICE '============================================';
END $$;

-- Анализ распределений
SELECT 'Перекос заказов: топ 10% клиентов имеют ' || 
       round(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) || '% заказов' as distribution
FROM orders WHERE client_id <= 25000;

SELECT 'Распределение статусов заказов:' as stats;
SELECT status, COUNT(*), round(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as percent
FROM orders GROUP BY status ORDER BY percent DESC;

SELECT 'Распределение типов грузов:' as stats;
SELECT package_type, COUNT(*), round(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) as percent
FROM cargos GROUP BY package_type ORDER BY percent DESC;

SELECT 'Процент NULL значений:' as null_stats
UNION ALL
SELECT 'orders.total_cost: ' || round(100.0 * COUNT(*) / (SELECT COUNT(*) FROM orders), 2) || '% NULL'
FROM orders WHERE total_cost IS NULL
UNION ALL
SELECT 'cargos.price: ' || round(100.0 * COUNT(*) / (SELECT COUNT(*) FROM cargos), 2) || '% NULL'
FROM cargos WHERE price IS NULL;