-- НЕ УДАЛОСЬ ЗАГРУЗИТЬ МОДЕЛЬ
-- ~$ sudo isql-fb
-- [sudo] пароль для dima:
-- Use CONNECT or CREATE DATABASE to specify a database
-- SQL> connect '/home/dima/Учеба урфу/5 семестр/БД/Лабораторные работы/Модели/046/MOD046.GDB'
-- CON> ;
-- Statement failed, SQLSTATE = HY000
-- unsupported on-disk structure for file /home/dima/Учеба урфу/5 семестр/БД/Лабораторные работы/Модели/046/MOD046.GDB; found 10.0, support 12.2

-- 15. Простой выбор
select * from citya;
-- 16. Сортировка
select * from citya order by name_city;
-- 17. Сортировка с использованием индекса
create index citya on citya (name_city);
select * from citya order by name_city;
-- 18. Сортировка с использованием индекса, в отличном от индекса порядке
select * from citya order by name_city desc;
-- 19. Группировка по полю по которому построен индекс
select name_city, count() from citya group by name_city having count()>};
-- 20. Выборка с использованием индекса
select * from citya where name_city = 'Дно';
-- 21. Выборка по началу строки с использованием индекса
select * from citya where name_city starting with "Д";
-- 22. Выборка по подстроке
select * from citya where name_city like '%ф%';
-- 23. Простое кросс соединение
select * from citya, cityb;
-- 24. Соединение с использованием индекса для поиска
select * from citya join cityb on citya.name_city = cityb.name_city;
-- 25. Отсортированное соединение с использованием индекса для поиска
select * from citya join cityb on citya.name_city = cityb.name_city order by name_city;
-- 26. Соединение с использованием индекса для поиска и сортировки
create index cityb on cityb (name_city);
select * from citya join cityb on citya.name_city = cityb.name_city order by name_city;
-- 27. Левое внешнее соединение
select * from citya left join cityb on citya.name_city = cityb.name_city;
-- 28. Правое внешнее соединение
select * from citya right join cityb on citya.name_city = cityb.name_city;
-- 29. Полное внешнее соединение
select * from citya full join cityb on citya.name_city = cityb.name_city;
-- 30. Тройное эквисоединение с двумя индексами
select * from citya join cityb on citya.name_city = cityb.name_city join cityc on cityb.name_city = cityc.name_city;
-- 31. Статичный контекст
select * from citya where region in(select region from cityb where name_city = 'Абезь');
-- 32. Тоже но через соединение
select citya.* from citya join cityb on citya.region=cityb.region where cityb.name_city = 'Абезь'
-- 33. Соединение без использования индексов
drop index CITYA;
drop index CITYB;
select * from citya join cityb on citya.name_city = cityb.name_city;
-- 34. Группировка по полю без индекса
select region, count(*) from citya group by region;