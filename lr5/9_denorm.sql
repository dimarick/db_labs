-- Создать таблицу, в которой для каждого номера страны указывается текущее
-- количество запусков КА данной страной, написать триггеры, заполняющие эту таблицу.

create table country_space_flight_stat (
    num_country int not null primary key,
    flights int,
    foreign key (num_country) references country(num_country) on delete cascade on update cascade
);

insert into country_space_flight_stat(num_country, flights)
select country.num_country, count(space_flight.num_space_flight) as flights
from country
left join space_vehicle on country.num_country = space_vehicle.num_country
left join space_flight on space_vehicle.num_space_vehicle = space_flight.num_space_vehicle
group by country.num_country;

create or replace function insert_country() returns trigger
as $$
begin
    insert into country_space_flight_stat(num_country, flights) values (new.num_country, 0) on conflict do nothing;
    return new;
end;
$$ language plpgsql;

create or replace function insert_flight() returns trigger
as $$
begin
    update country_space_flight_stat stat
    set flights = flights + 1
    where stat.num_country = (select space_vehicle.num_country from space_vehicle where space_vehicle.num_space_vehicle = new.num_space_vehicle);
    return new;
end;
$$ language plpgsql;

create or replace trigger insert_country_space_flight_stat after insert on country for each row execute function insert_country();
create or replace trigger insert_flight_space_flight_stat after insert on space_flight for each row execute function insert_flight();

insert into country (num_country, short_name_country)
values
    (20, 'КНР');


insert into space_vehicle (num_space_vehicle, num_carrier_rocket, num_country, num_cosmodrome, num_type_space_flight, name_space_vehicle, sequence_number, international_designation, weight_space_vehicle)
values
    (53, 1, 20, 1, 1, 'Чэнгоу', 2, 'CHG0114', 1540);


insert into space_flight (num_space_flight, num_space_vehicle, num_astronaut, num_status, flight_endurance)
values
    (24,53,21,5, null);

insert into space_flight (num_space_flight, num_space_vehicle, num_astronaut, num_status, flight_endurance)
values
    (25,53,21,5, null),
    (26,53,21,5, null);

select * from country_space_flight_stat where num_country = 20; -- должно быть 3
