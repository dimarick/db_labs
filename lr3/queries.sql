-- 1. Найти КА, у которых вес больше 10, или меньше 100. (легкий)
select * from space_vehicle where weight_space_vehicle > 10 and weight_space_vehicle < 100;

-- 2. Вывести для каждого КА, последовательность событий происходивших с ним в порядке их наступления,
-- с указанием даты, времени и названия события. (сложный)
select name_space_vehicle, hsv.date_history_space_vehicle, hsv.time_history_space_vehicle, name_type_event
from space_vehicle
inner join public.history_space_vehicle hsv on space_vehicle.num_space_vehicle = hsv.num_space_vehicle
inner join public.type_event te on te.type_event = hsv.type_event
order by name_space_vehicle, hsv.date_history_space_vehicle, hsv.time_history_space_vehicle


-- 3. Для каждого космонавта человека указать имя КА, и должность, в которой он произвел полет. (стандартный)
select name, family, patronymic, name_space_vehicle, status.name_status
from people
inner join space_flight on people.num_astronaut = space_flight.num_astronaut
inner join space_vehicle on space_vehicle.num_space_vehicle = space_flight.num_space_vehicle
inner join status on status.num_status = space_flight.num_status

-- 4. Для всех КА, указать краткое название страны, название космодрома, ракету носитель,
-- название типа КА, порядковый номер, и указать название и дату события выведение на орбиту. (стандартный)

select short_name_country, cosmodrome.name_cosmodrom, name_carrier_rocket, type_space_flight.name_type_space_flight, sequence_number,
       type_event.name_type_event, history_space_vehicle.date_history_space_vehicle
from space_vehicle
inner join cosmodrome on space_vehicle.num_cosmodrome = cosmodrome.num_cosmodrome
inner join history_space_vehicle on space_vehicle.num_space_vehicle = history_space_vehicle.num_space_vehicle
inner join type_event on history_space_vehicle.type_event = type_event.type_event
inner join country on space_vehicle.num_country = country.num_country
inner join carrier_rocket on space_vehicle.num_carrier_rocket = carrier_rocket.num_carrier_rocket
inner join type_space_flight on space_vehicle.num_type_space_flight = type_space_flight.num_type_space_flight
where type_event.type_event = 4

-- 5. Для предыдущего запроса, в случае неуспешного выведения дату и
-- название оставить неопределенными. (стандартный)
select short_name_country, cosmodrome.name_cosmodrom, name_carrier_rocket, type_space_flight.name_type_space_flight, sequence_number,
       type_event.name_type_event, history_space_vehicle.date_history_space_vehicle
from space_vehicle
inner join cosmodrome on space_vehicle.num_cosmodrome = cosmodrome.num_cosmodrome
left join history_space_vehicle on space_vehicle.num_space_vehicle = history_space_vehicle.num_space_vehicle and history_space_vehicle.type_event = 4
left join type_event on history_space_vehicle.type_event = type_event.type_event
inner join country on space_vehicle.num_country = country.num_country
inner join carrier_rocket on space_vehicle.num_carrier_rocket = carrier_rocket.num_carrier_rocket
inner join type_space_flight on space_vehicle.num_type_space_flight = type_space_flight.num_type_space_flight


-- 6. Для предыдущего запроса, в случае неуспешного выведения, дату установить в нео
-- пределенное значение, а название события установить в "не вышел в космос". (сложный)
select short_name_country, cosmodrome.name_cosmodrom, name_carrier_rocket, type_space_flight.name_type_space_flight, sequence_number,
       coalesce(type_event.name_type_event, 'не вышел в космос'), history_space_vehicle.date_history_space_vehicle
from space_vehicle
inner join cosmodrome on space_vehicle.num_cosmodrome = cosmodrome.num_cosmodrome
left join history_space_vehicle on space_vehicle.num_space_vehicle = history_space_vehicle.num_space_vehicle and history_space_vehicle.type_event = 4
left join type_event on history_space_vehicle.type_event = type_event.type_event
inner join country on space_vehicle.num_country = country.num_country
inner join carrier_rocket on space_vehicle.num_carrier_rocket = carrier_rocket.num_carrier_rocket
inner join type_space_flight on space_vehicle.num_type_space_flight = type_space_flight.num_type_space_flight

-- 7. Вывести пары названий космических тел, связанных по условию первое тело является
-- спутником второго тела, для тел для которых неизвестно спутником кого они являются,
-- установить название в неопределенное значение. (простой)

select body.name_heavenly_body, satellite.name_heavenly_body from heavenly_body body
left join heavenly_body satellite on body.satellite = satellite.num_heavenly_body

-- 8. Выдать все пары номеров типов КА и РН, таких, что данный тип КА не выводился на
-- орбиту с использованием РН (номер РН установить в null), и наоборот (номер типа КА
-- установить в null). В результате обязательно должна присутствовать строка из пары null значений. (сложный)
select type_space_flight.num_type_space_flight, carrier_rocket.num_carrier_rocket from space_vehicle
left join carrier_rocket on carrier_rocket.num_carrier_rocket = space_vehicle.num_carrier_rocket
left join type_space_flight on space_vehicle.num_type_space_flight = type_space_flight.num_type_space_flight
where carrier_rocket is null and type_space_flight is null

-- 9. Найдите типы КА которые выводила только одна страна. (стандартный)
select count(distinct short_name_country), type_space_flight.name_type_space_flight
from space_vehicle
inner join country on space_vehicle.num_country = country.num_country
inner join type_space_flight on space_vehicle.num_type_space_flight = type_space_flight.num_type_space_flight
group by type_space_flight.name_type_space_flight
having count(distinct short_name_country) = 1

-- 10. Найти номера КА, которые побывали на орбите земли и солнца. (стандартный)
select space_vehicle.num_space_vehicle
from space_vehicle
inner join history_space_vehicle on space_vehicle.num_space_vehicle = history_space_vehicle.num_space_vehicle and history_space_vehicle.type_event = 4
where history_space_vehicle.num_heavenly_body in (1, 2)

-- 11. Напишите пару пользовательских функций, которые получают строку
-- (по умолчанию поставьте 8000 символов), и возвращает строку в верхнем и нижнем регистре. (стандартный)

create or replace function register_change(str text) returns table(lower text, upper text)
as $$
begin
    return query select lower(str), upper(str);
end;
$$ language plpgsql immutable;

select register_change('Test')

-- 12. Напишите пользовательскую функцию, которая получает три параметра типа float,
-- и возвращает второй параметр если первый строго больше нуля, а третий в остальных случаях. (стандартный)

create or replace function double_coalesce(param double precision, g0 double precision, els double precision) returns double precision
as $$
begin
    if param > 0 then
        return g0;
    else
        return els;
    end if;
end;
$$ language plpgsql immutable;

select double_coalesce(-1.2, 42.0, 43.0), double_coalesce(2.4, 42.0, 43.0);

-- 1. Создайте генератор для генерирования первичных ключей в таблице “космические тела”,
-- установите его значение таким образом, чтобы гарантировать уникальность первичных ключей.
-- Вставьте в таблицу “космические тела” информацию о спутниках Марса - "Фобосе" и "Деймосе" с использованием генератора. (простой)

create sequence heavenly_body_id_seq;
select setval('heavenly_body_id_seq', (select  max(heavenly_body.num_heavenly_body) from heavenly_body), true);
alter table heavenly_body alter column num_heavenly_body set default nextval('heavenly_body_id_seq');
insert into heavenly_body(name_heavenly_body, satellite)
values
    ('Марс', 1);

insert into heavenly_body(name_heavenly_body, satellite)
values
    ('Фобос', (select num_heavenly_body from heavenly_body where name_heavenly_body = 'Марс')),
    ('Деймос', (select num_heavenly_body from heavenly_body where name_heavenly_body = 'Марс'));

-- 2. Создайте генератор, и с его помощью перенумеруйте строки результата выполнения первого запроса. (стандартный)
select *, row_number() over () from heavenly_body