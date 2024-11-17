-- 1. Получить информацию обо всех типах космических аппаратов (КА).
select * from space_vehicle;

-- 2. Получить для каждого КА его интернациональное обозначение и вес.
select space_vehicle.international_designation, space_vehicle.weight_space_vehicle from space_vehicle;

-- 3. Найти целое значение веса КА в русских фунтах (вес в граммах на 403).
select
    space_vehicle.international_designation,
    space_vehicle.weight_space_vehicle / 0.403 as weight_space_vehicle_pounds
from space_vehicle;

-- 4. Найти номер дня недели, когда США меняло свое название.

-- 5. Найти КА порядковый номер которых меньше либо равен 114.
select * from space_vehicle where space_vehicle.num_space_vehicle <= 114;

-- 6. Найти космодромы расположенные между 5 градусами южной и северной широты,
-- открытых после 1960 года (значения широты в десятичных градусах,
-- положительные значения - северное полушарие, отрицательные - южное.).
select * from cosmodrome where latitude < 5 and latitude > -5 and cosmodrome.year_open > 1960;

-- 7. Выдать список уникальных номеров ракет-носителей использованных для запуска КА.
select carrier_rocket.num_carrier_rocket from carrier_rocket;

-- 8. Найти все возможные комбинации информации о РН и типах КА.
select * from carrier_rocket
join space_vehicle on true;

-- 9. Найти все пары возможных комбинаций названий типов КА.
select * from space_vehicle vh1
join space_vehicle vh2 on true;

-- 10. Внести информацию о типе КА «Восток-3А».
insert into space_vehicle
    (
     num_space_vehicle,
     num_carrier_rocket,
     num_country,
     num_cosmodrome,
     num_type_space_flight,
     name_space_vehicle,
     sequence_number,
     international_designation,
     weight_space_vehicle)
VALUES
    (53,
     1,
     1,
     1,
     2,
     'Восток-3А',
     42,
     'Восток-3А',
     542);

-- 11. Удалить информацию о РН номер 2.
delete from space_vehicle where num_space_vehicle = 2;

-- 12. Перевести все названия космических тел в верхний регистр.
update heavenly_body set name_heavenly_body = upper(name_heavenly_body);

-- 13. Найти космодромы, принадлежащие Франции, России и Китаю расположенные в северном полушарии.
select * from cosmodrome where num_country in (5, 1, 6) and latitude > 0;

-- 14. Найти названия КА и наименование страны,
-- которой они принадлежат, на борту
-- которых не было ни одной живой души.
select * from space_vehicle
left join space_flight on space_vehicle.num_space_vehicle = space_flight.num_space_vehicle
left join astronaut on space_flight.num_astronaut = astronaut.num_astronaut
left join animal on space_flight.num_astronaut = animal.num_astronaut
where animal.num_astronaut is null and astronaut is null;

-- 15. Найти названия КА и наименование типов КА масса,
-- которых находится в промежутке между 100 кг и одной тонной.
select * from space_vehicle where weight_space_vehicle >= 100 and weight_space_vehicle <= 1000;
select * from space_vehicle where weight_space_vehicle between 100 and 1000;

-- 16. Найти названия КА и наименование космодрома,
-- с которого они взлетели при условии,
-- что имя КА начинается с «explorer» учесть,
-- что регистр названия может быть разным.

