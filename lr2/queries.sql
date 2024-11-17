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
select extract(dow from date_change_name) from assignee where num_country = 3

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
select space_vehicle.name_space_vehicle, cosmodrome.name_cosmodrom from space_vehicle
left join cosmodrome on space_vehicle.num_cosmodrome = cosmodrome.num_cosmodrome
where space_vehicle.name_space_vehicle ilike 'explorer%';

-- 17. Найти названия КА при условии, что имя КА содержит подстроку «спутник».
select space_vehicle.name_space_vehicle from space_vehicle
where space_vehicle.name_space_vehicle ilike '%спутник%';

-- 18. Найти названия биологических видов, которые оканчиваются на слог «ка».
select * from species where name_species like '%ка'

-- 19. Найти информацию обо всех КА, для которых неизвестен вес.
select * from space_vehicle
where space_vehicle.weight_space_vehicle is null;


-- 20. Найти название страны, которая запускала в космос космонавтов всех биологических видов.
select short_name_country, count(distinct a.num_species) count_species from country
inner join space_vehicle sv on country.num_country = sv.num_country
inner join space_flight sf on sv.num_space_vehicle = sf.num_space_vehicle
inner join astronaut a on sf.num_astronaut = a.num_astronaut
group by short_name_country
having count(distinct a.num_species) = (select count(num_species) from species)
;

-- 21. Найти информацию обо всех РН, которые использовались для единственного запуска КА.
select carrier_rocket.*
from carrier_rocket
inner join space_vehicle on carrier_rocket.num_carrier_rocket = space_vehicle.num_carrier_rocket
group by carrier_rocket.num_carrier_rocket
having count(*) = 1
;

-- 22. Найти пары номер КА и номер космодрома, такие что, данный КА был выведен с данного космодрома,
-- при условии что, в результате будут представлены все космодромы, для космодрома, с которого не стартовал КА вместо номера КА установить null.
select * from cosmodrome
left join space_vehicle on cosmodrome.num_cosmodrome = space_vehicle.num_cosmodrome

-- 23. Сколько всего было космонавтов?
select count(*) from astronaut;

-- 24. Сколько было космонавтов животных?
select count(*) from animal;

-- 25. Найти последнее название Франции.
select name_country
from assignee
where num_country = 5
order by date_change_name desc limit 1;

-- 26. Получить список космодромов с указанием общего числа запусков КА.
select name_cosmodrom, count(*) from cosmodrome
left join space_vehicle on cosmodrome.num_cosmodrome = space_vehicle.num_cosmodrome
left join space_flight on space_vehicle.num_space_vehicle = space_flight.num_space_vehicle
group by name_cosmodrom;

-- 27. Получение статистических данных о количество запусков в 1978 с
-- указанием количества запусков за каждый месяц. (нетривиальный)
select date_trunc('quarter', date_history_space_vehicle), count(distinct num_space_vehicle)
from history_space_vehicle
where date_history_space_vehicle > '1978-01-01'
group by date_trunc('quarter', date_history_space_vehicle)

-- 28. Составить запрос возвращающий: список стран в порядке вывода ими КА в космос со своих космодромов.
select country.short_name_country
from space_vehicle
inner join cosmodrome on space_vehicle.num_cosmodrome = cosmodrome.num_cosmodrome
inner join country on cosmodrome.num_country = country.num_country
group by country.short_name_country
order by min(sequence_number);

-- 29. Составить запрос возвращающий: список стран в порядке вывода ими КА в космос со своих космодромов
-- и своими ракетами-носителями.
select country.short_name_country
from space_vehicle
inner join cosmodrome on space_vehicle.num_cosmodrome = cosmodrome.num_cosmodrome
inner join carrier_rocket on space_vehicle.num_carrier_rocket = carrier_rocket.num_carrier_rocket
inner join country on cosmodrome.num_country = country.num_country and carrier_rocket.num_country = country.num_country
group by country.short_name_country
order by min(sequence_number);

-- 30. Список стран с указанием общего количества представителей страны слетавших в космос,
-- отсортированный в порядке возрастания числа полетов.
select short_name_country, count(distinct num_astronaut), count(num_astronaut) from country
inner join space_vehicle on country.num_country = space_vehicle.num_country
inner join space_flight on space_vehicle.num_space_vehicle = space_flight.num_space_vehicle
group by short_name_country
order by count(num_astronaut);

-- 31. Внести в БД следующую информацию: 12.04.1961 В 6:07 UTC с космодрома Байконур,
-- стартовый комплекс № 1, осуществлен пуск ракеты-носителя «Восток 8К72К», которая
-- вывела на околоземную орбиту советский космический корабль «Восток» (00103 / 1961 Мю 1),
-- КА типа «Восток-3А». Космический корабль пилотировал советский космонавт Юрий ГАГАРИН. Полет продолжался 1 час 48 минут.
insert into carrier_rocket(num_carrier_rocket, num_country, name_carrier_rocket, stages)
values
    (54, 1, 'Восток 8К72К', 3);

insert into astronaut(num_astronaut, num_species, sex)
values
    (22, 1, 'М');

insert into people(num_astronaut, num_country, name, family, patronymic)
values
    (22, 1, 'Юрий', 'ГАГАРИН', 'Алекссевич');

insert into type_space_flight(num_type_space_flight, name_type_space_flight)
values
    (21, 'Восток-3А');

insert into space_vehicle(num_space_vehicle, num_carrier_rocket, num_country, num_cosmodrome, num_type_space_flight, name_space_vehicle, sequence_number, international_designation)
values
    (54, 54, 1, 1, 21, 'Восток', 1, '00103 / 1961 Мю 1');

insert into space_flight(num_space_flight, num_space_vehicle, num_astronaut, num_status, flight_endurance)
values
    (27, 54, 22, 4, 108)

insert into history_space_vehicle (num_history_space_vehicle, num_heavenly_body, num_space_vehicle, type_event, date_history_space_vehicle, time_history_space_vehicle)
values
    (49, 2, 54, 0, '1961-04-12', '06:07 UTC')