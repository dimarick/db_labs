set max_parallel_workers_per_gather = 1;
set max_parallel_workers = 1;

-- 15. Простой выбор
explain analyse select * from citya;
-- QUERY PLAN
-- Seq Scan on citya  (cost=0.00..21563.03 rows=1104103 width=45) (actual time=0.006..42.230 rows=1104103 loops=1)
-- Planning Time: 0.031 ms
-- Execution Time: 62.477 ms

-- 16. Сортировка
explain analyse select * from citya order by name_city;
-- QUERY PLAN
-- Gather Merge  (cost=100701.21..175390.49 rows=649472 width=45) (actual time=902.739..1311.407 rows=1104103 loops=1)
--   Workers Planned: 1
--   Workers Launched: 1
--   ->  Sort  (cost=99701.20..101324.88 rows=649472 width=45) (actual time=889.523..1100.395 rows=552052 loops=2)
--         Sort Key: name_city
--         Sort Method: external merge  Disk: 29728kB
--         Worker 0:  Sort Method: external merge  Disk: 31520kB
--         ->  Parallel Seq Scan on citya  (cost=0.00..17016.72 rows=649472 width=45) (actual time=0.005..24.761 rows=552052 loops=2)
-- Planning Time: 0.043 ms
-- Execution Time: 1329.694 ms

-- 17. Сортировка с использованием индекса
create index citya_name on citya (name_city);
explain analyse select * from citya order by name_city;
-- QUERY PLAN
-- Index Scan using citya_name on citya  (cost=0.43..78511.92 rows=1104103 width=45) (actual time=0.022..346.183 rows=1104103 loops=1)
-- Planning Time: 0.212 ms
-- Execution Time: 361.899 ms

-- 18. Сортировка с использованием индекса, в отличном от индекса порядке
explain analyse select * from citya order by name_city desc;
-- QUERY PLAN
-- Index Scan Backward using citya_name on citya  (cost=0.43..78511.92 rows=1104103 width=45) (actual time=0.023..351.290 rows=1104103 loops=1)
-- Planning Time: 0.058 ms
-- Execution Time: 368.117 ms

-- 19. Группировка по полю по которому построен индекс
explain analyse select name_city, count(*) from citya group by name_city having count(*) > 2;
-- QUERY PLAN
-- GroupAggregate  (cost=0.43..48286.70 rows=169072 width=29) (actual time=236.296..313.321 rows=11011 loops=1)
--   Group Key: name_city
--   Filter: (count(*) > 2)
--   Rows Removed by Filter: 981981
--   ->  Index Only Scan using citya_name on citya  (cost=0.43..36425.97 rows=1104103 width=21) (actual time=0.107..88.987 rows=1104103 loops=1)
--         Heap Fetches: 0
-- Planning Time: 0.211 ms
-- Execution Time: 313.641 ms

-- 20. Выборка с использованием индекса
explain analyse select * from citya where name_city = 'Дно';
-- QUERY PLAN
-- Index Scan using citya_name on citya  (cost=0.43..12.46 rows=2 width=45) (actual time=0.117..0.121 rows=1 loops=1)
--   Index Cond: (name_city = 'Дно'::text)
-- Planning Time: 0.170 ms
-- Execution Time: 0.161 ms

-- 21. Выборка по началу строки с использованием индекса
create index citya_name_text on citya (name_city text_pattern_ops);
explain analyse select * from citya where name_city like 'Д%';
-- QUERY PLAN
-- Bitmap Heap Scan on citya  (cost=928.57..11860.29 rows=33440 width=45) (actual time=4.291..11.760 rows=34034 loops=1)
--   Filter: (name_city ~~ 'Д%'::text)
--   Heap Blocks: exact=8603
--   ->  Bitmap Index Scan on citya_name  (cost=0.00..920.21 rows=32778 width=0) (actual time=3.524..3.525 rows=34034 loops=1)
--         Index Cond: ((name_city ~>=~ 'Д'::text) AND (name_city ~<~ 'Е'::text))
-- Planning Time: 0.337 ms
-- Execution Time: 12.245 ms

-- 22. Выборка по подстроке
explain analyse select * from citya where name_city like '%ф%';
-- QUERY PLAN
-- Gather  (cost=1000.00..20755.10 rows=11147 width=45) (actual time=1.539..100.443 rows=9009 loops=1)
--   Workers Planned: 1
--   Workers Launched: 1
--   ->  Parallel Seq Scan on citya  (cost=0.00..18640.40 rows=6557 width=45) (actual time=0.177..77.623 rows=4504 loops=2)
--         Filter: (name_city ~~ '%ф%'::text)
--         Rows Removed by Filter: 547547
-- Planning Time: 0.208 ms
-- Execution Time: 100.734 ms

-- 23. Простое кросс соединение
explain select * from citya, cityb;
-- QUERY PLAN
-- Nested Loop  (cost=0.00..25978568204.83 rows=1220261260218 width=90)
--   ->  Seq Scan on citya  (cost=0.00..21563.03 rows=1104103 width=45)
--   ->  Materialize  (cost=0.00..36824.09 rows=1105206 width=45)
--         ->  Seq Scan on cityb  (cost=0.00..21584.06 rows=1105206 width=45)
-- JIT:
--   Functions: 3
-- "  Options: Inlining true, Optimization true, Expressions true, Deforming true"

-- 24. Соединение с использованием индекса для поиска
set enable_mergejoin = false;
set enable_hashjoin = false;
explain analyse select * from citya join cityb on citya.name_city = cityb.name_city;
-- Интересно что, без использования индексов получается самый быстрый джойн.
-- Но Nested Loop имеет константный расход памяти.
-- QUERY PLAN
-- Gather  (cost=1000.43..608738.64 rows=2405797 width=90) (actual time=109.930..1223.445 rows=2702394 loops=1)
--   Workers Planned: 1
--   Workers Launched: 1
--   ->  Nested Loop  (cost=0.43..367158.94 rows=1415175 width=90) (actual time=89.879..1052.562 rows=1351197 loops=2)
--         ->  Parallel Seq Scan on cityb  (cost=0.00..17033.21 rows=650121 width=45) (actual time=0.116..32.767 rows=552603 loops=2)
--         ->  Index Scan using citya_name_text on citya  (cost=0.43..0.52 rows=2 width=45) (actual time=0.001..0.001 rows=2 loops=1105206)
--               Index Cond: (name_city = cityb.name_city)
-- Planning Time: 0.211 ms
-- JIT:
--   Functions: 12
-- "  Options: Inlining true, Optimization true, Expressions true, Deforming true"
-- "  Timing: Generation 1.405 ms, Inlining 87.170 ms, Optimization 62.447 ms, Emission 29.800 ms, Total 180.822 ms"
-- Execution Time: 1293.883 ms

-- 25. Отсортированное соединение с использованием индекса для поиска
set enable_mergejoin = true;
set enable_hashjoin = true;
explain analyse select * from citya join cityb on citya.name_city = cityb.name_city order by citya.name_city;
-- QUERY PLAN
-- Merge Join  (cost=200523.31..320643.31 rows=2405797 width=90) (actual time=2137.850..3361.523 rows=2702394 loops=1)
--   Merge Cond: (citya.name_city = cityb.name_city)
--   ->  Index Scan using citya_name on citya  (cost=0.43..78511.92 rows=1104103 width=45) (actual time=0.033..339.622 rows=1104103 loops=1)
--   ->  Materialize  (cost=200522.00..206048.03 rows=1105206 width=45) (actual time=2120.923..2419.688 rows=2702394 loops=1)
--         ->  Sort  (cost=200522.00..203285.01 rows=1105206 width=45) (actual time=2120.915..2329.748 rows=1105206 loops=1)
--               Sort Key: cityb.name_city
--               Sort Method: external merge  Disk: 61216kB
--               ->  Seq Scan on cityb  (cost=0.00..21584.06 rows=1105206 width=45) (actual time=0.036..45.282 rows=1105206 loops=1)
-- Planning Time: 1.064 ms
-- JIT:
--   Functions: 7
-- "  Options: Inlining false, Optimization false, Expressions true, Deforming true"
-- "  Timing: Generation 1.305 ms, Inlining 0.000 ms, Optimization 0.873 ms, Emission 16.002 ms, Total 18.181 ms"
-- Execution Time: 3404.370 ms

-- 26. Соединение с использованием индекса для поиска и сортировки
create index cityb_name on cityb (name_city);
explain analyse select * from citya join cityb on citya.name_city = cityb.name_city order by citya.name_city;
-- QUERY PLAN
-- Merge Join  (cost=0.85..195936.69 rows=2405797 width=90) (actual time=10.227..2044.268 rows=2702394 loops=1)
--   Merge Cond: (citya.name_city = cityb.name_city)
--   ->  Index Scan using citya_name on citya  (cost=0.43..78511.92 rows=1104103 width=45) (actual time=0.026..657.973 rows=1104103 loops=1)
--   ->  Materialize  (cost=0.43..81340.58 rows=1105206 width=45) (actual time=0.043..750.606 rows=2702394 loops=1)
--         ->  Index Scan using cityb_name on cityb  (cost=0.43..78577.56 rows=1105206 width=45) (actual time=0.032..655.894 rows=1105206 loops=1)
-- Planning Time: 0.796 ms
-- JIT:
--   Functions: 7
-- "  Options: Inlining false, Optimization false, Expressions true, Deforming true"
-- "  Timing: Generation 0.622 ms, Inlining 0.000 ms, Optimization 0.646 ms, Emission 9.493 ms, Total 10.761 ms"
-- Execution Time: 2084.368 ms

-- 27. Левое внешнее соединение
explain analyse select * from citya left join cityb on citya.name_city = cityb.name_city;
-- QUERY PLAN
-- Merge Left Join  (cost=0.85..195936.69 rows=2405797 width=90) (actual time=5.766..2043.064 rows=2702394 loops=1)
--   Merge Cond: (citya.name_city = cityb.name_city)
--   ->  Index Scan using citya_name on citya  (cost=0.43..78511.92 rows=1104103 width=45) (actual time=0.021..669.114 rows=1104103 loops=1)
--   ->  Materialize  (cost=0.43..81340.58 rows=1105206 width=45) (actual time=0.029..748.620 rows=2702394 loops=1)
--         ->  Index Scan using cityb_name on cityb  (cost=0.43..78577.56 rows=1105206 width=45) (actual time=0.022..655.278 rows=1105206 loops=1)
-- Planning Time: 0.553 ms
-- JIT:
--   Functions: 7
-- "  Options: Inlining false, Optimization false, Expressions true, Deforming true"
-- "  Timing: Generation 0.473 ms, Inlining 0.000 ms, Optimization 0.345 ms, Emission 5.357 ms, Total 6.174 ms"
-- Execution Time: 2082.812 ms

-- 28. Правое внешнее соединение
explain analyse select * from citya right join cityb on citya.name_city = cityb.name_city;
-- QUERY PLAN
-- Merge Right Join  (cost=0.85..195936.69 rows=2405797 width=90) (actual time=12.271..1988.448 rows=2702394 loops=1)
--   Merge Cond: (citya.name_city = cityb.name_city)
--   ->  Index Scan using citya_name on citya  (cost=0.43..78511.92 rows=1104103 width=45) (actual time=0.015..639.470 rows=1104103 loops=1)
--   ->  Materialize  (cost=0.43..81340.58 rows=1105206 width=45) (actual time=0.024..724.644 rows=2702394 loops=1)
--         ->  Index Scan using cityb_name on cityb  (cost=0.43..78577.56 rows=1105206 width=45) (actual time=0.019..631.554 rows=1105206 loops=1)
-- Planning Time: 0.490 ms
-- JIT:
--   Functions: 7
-- "  Options: Inlining false, Optimization false, Expressions true, Deforming true"
-- "  Timing: Generation 0.501 ms, Inlining 0.000 ms, Optimization 0.702 ms, Emission 11.516 ms, Total 12.720 ms"
-- Execution Time: 2028.050 ms

-- 29. Полное внешнее соединение
explain analyse select * from citya full join cityb on citya.name_city = cityb.name_city;
-- QUERY PLAN
-- Merge Full Join  (cost=0.85..195936.69 rows=2405797 width=90) (actual time=7.957..1976.357 rows=2702394 loops=1)
--   Merge Cond: (citya.name_city = cityb.name_city)
--   ->  Index Scan using citya_name on citya  (cost=0.43..78511.92 rows=1104103 width=45) (actual time=0.071..632.560 rows=1104103 loops=1)
--   ->  Materialize  (cost=0.43..81340.58 rows=1105206 width=45) (actual time=0.053..714.325 rows=2702394 loops=1)
--         ->  Index Scan using cityb_name on cityb  (cost=0.43..78577.56 rows=1105206 width=45) (actual time=0.044..621.551 rows=1105206 loops=1)
-- Planning Time: 0.182 ms
-- JIT:
--   Functions: 7
-- "  Options: Inlining false, Optimization false, Expressions true, Deforming true"
-- "  Timing: Generation 0.575 ms, Inlining 0.000 ms, Optimization 0.420 ms, Emission 7.398 ms, Total 8.393 ms"
-- Execution Time: 2015.916 ms

-- 30. Тройное эквисоединение с двумя индексами
set enable_mergejoin = true;
set enable_hashjoin = true;
set work_mem = '1MB';
explain analyse select * from citya join cityb on citya.name_city = cityb.name_city join cityc on cityb.name_city = cityc.name_city;
-- QUERY PLAN
-- Hash Join  (cost=45113.99..385698.19 rows=5242138 width=135) (actual time=160.159..5129.737 rows=37438156 loops=1)
--   Hash Cond: (citya.name_city = cityc.name_city)
--   ->  Merge Join  (cost=0.85..195936.69 rows=2405797 width=90) (actual time=6.162..2051.607 rows=2702394 loops=1)
--         Merge Cond: (citya.name_city = cityb.name_city)
--         ->  Index Scan using citya_name on citya  (cost=0.43..78511.92 rows=1104103 width=45) (actual time=0.009..662.153 rows=1104103 loops=1)
--         ->  Materialize  (cost=0.43..81340.58 rows=1105206 width=45) (actual time=0.037..744.583 rows=2702394 loops=1)
--               ->  Index Scan using cityb_name on cityb  (cost=0.43..78577.56 rows=1105206 width=45) (actual time=0.030..650.180 rows=1105206 loops=1)
--   ->  Hash  (cost=21584.06..21584.06 rows=1105206 width=45) (actual time=153.413..153.413 rows=1105206 loops=1)
--         Buckets: 32768  Batches: 64  Memory Usage: 1596kB
--         ->  Seq Scan on cityc  (cost=0.00..21584.06 rows=1105206 width=45) (actual time=0.011..44.027 rows=1105206 loops=1)
-- Planning Time: 0.330 ms
-- JIT:
--   Functions: 14
-- "  Options: Inlining false, Optimization false, Expressions true, Deforming true"
-- "  Timing: Generation 0.326 ms, Inlining 0.000 ms, Optimization 0.176 ms, Emission 5.955 ms, Total 6.457 ms"
-- Execution Time: 5630.528 ms

-- 31. Статичный контекст
explain analyse select * from citya where region in (select region from cityb where name_city = 'Абезь');
-- Почти оптимально, но постгрес потратил лишнее время на уникальность во вложенном select
-- QUERY PLAN
-- Gather  (cost=1012.51..19737.62 rows=33 width=45) (actual time=14.550..16.465 rows=0 loops=1)
--   Workers Planned: 1
--   Workers Launched: 1
--   ->  Hash Join  (cost=12.51..18734.32 rows=19 width=45) (actual time=0.078..0.079 rows=0 loops=2)
--         Hash Cond: (citya.region = cityb.region)
--         ->  Parallel Seq Scan on citya  (cost=0.00..17016.72 rows=649472 width=45) (actual time=0.005..0.006 rows=1 loops=2)
--         ->  Hash  (cost=12.48..12.48 rows=2 width=24) (actual time=0.041..0.042 rows=0 loops=2)
--               Buckets: 1024  Batches: 1  Memory Usage: 8kB
--               ->  Unique  (cost=12.47..12.48 rows=2 width=24) (actual time=0.041..0.042 rows=0 loops=2)
--                     ->  Sort  (cost=12.47..12.48 rows=2 width=24) (actual time=0.041..0.041 rows=0 loops=2)
--                           Sort Key: cityb.region
--                           Sort Method: quicksort  Memory: 25kB
--                           Worker 0:  Sort Method: quicksort  Memory: 25kB
--                           ->  Index Scan using cityb_name on cityb  (cost=0.43..12.46 rows=2 width=24) (actual time=0.030..0.030 rows=0 loops=2)
--                                 Index Cond: (name_city = 'Абезь'::text)
-- Planning Time: 0.239 ms
-- Execution Time: 16.494 ms

-- 32. Тоже но через соединение
explain analyse select citya.* from citya join cityb on citya.region=cityb.region where cityb.name_city = 'Абезь';
-- Явный джойн сработал чище
-- QUERY PLAN
-- Gather  (cost=1012.49..21280.07 rows=33 width=45) (actual time=16.460..16.516 rows=0 loops=1)
--   Workers Planned: 1
--   Workers Launched: 1
--   ->  Hash Join  (cost=12.49..20276.77 rows=19 width=45) (actual time=0.078..0.080 rows=0 loops=2)
--         Hash Cond: (citya.region = cityb.region)
--         ->  Parallel Seq Scan on citya  (cost=0.00..17016.72 rows=649472 width=45) (actual time=0.005..0.005 rows=1 loops=2)
--         ->  Hash  (cost=12.46..12.46 rows=2 width=24) (actual time=0.020..0.021 rows=0 loops=2)
--               Buckets: 1024  Batches: 1  Memory Usage: 8kB
--               ->  Index Scan using cityb_name on cityb  (cost=0.43..12.46 rows=2 width=24) (actual time=0.020..0.020 rows=0 loops=2)
--                     Index Cond: (name_city = 'Абезь'::text)
-- Planning Time: 0.101 ms
-- Execution Time: 16.538 ms

-- 33. Соединение без использования индексов
drop index citya_name;
drop index citya_name_text;
drop index cityb_name;
explain analyse select * from citya join cityb on citya.name_city = cityb.name_city;
-- QUERY PLAN
-- Hash Join  (cost=45113.13..376562.08 rows=2405797 width=90) (actual time=297.547..1041.803 rows=2702394 loops=1)
--   Hash Cond: (citya.name_city = cityb.name_city)
--   ->  Seq Scan on citya  (cost=0.00..21563.03 rows=1104103 width=45) (actual time=0.024..50.865 rows=1104103 loops=1)
--   ->  Hash  (cost=21584.06..21584.06 rows=1105206 width=45) (actual time=297.165..297.165 rows=1105206 loops=1)
--         Buckets: 32768  Batches: 64  Memory Usage: 1596kB
--         ->  Seq Scan on cityb  (cost=0.00..21584.06 rows=1105206 width=45) (actual time=0.070..85.438 rows=1105206 loops=1)
-- Planning Time: 0.662 ms
-- JIT:
--   Functions: 10
-- "  Options: Inlining false, Optimization false, Expressions true, Deforming true"
-- "  Timing: Generation 1.383 ms, Inlining 0.000 ms, Optimization 0.912 ms, Emission 18.233 ms, Total 20.527 ms"
-- Execution Time: 1104.651 ms

-- 34. Группировка по полю без индекса
explain analyse select region, count(*) from citya group by region;
-- QUERY PLAN
-- Finalize HashAggregate  (cost=84862.80..86429.50 rows=66184 width=32) (actual time=265.412..307.589 rows=176176 loops=1)
--   Group Key: region
--   Planned Partitions: 8  Batches: 41  Memory Usage: 2105kB  Disk Usage: 14944kB
--   ->  Gather  (cost=64697.52..79588.76 rows=66184 width=32) (actual time=145.703..233.633 rows=177979 loops=1)
--         Workers Planned: 1
--         Workers Launched: 1
--         ->  Partial HashAggregate  (cost=63697.52..71970.36 rows=66184 width=32) (actual time=124.922..199.858 rows=88990 loops=2)
--               Group Key: region
--               Planned Partitions: 4  Batches: 21  Memory Usage: 2105kB  Disk Usage: 23632kB
--               Worker 0:  Batches: 21  Memory Usage: 2105kB  Disk Usage: 19904kB
--               ->  Parallel Seq Scan on citya  (cost=0.00..17016.72 rows=649472 width=24) (actual time=0.014..22.822 rows=552052 loops=2)
-- Planning Time: 0.179 ms
-- Execution Time: 313.772 ms
