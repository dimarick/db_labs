-- Адаптировать примеры из файла Хранимые процедуры.doc для своей БД.

set search_path = 'public';

-- Процедура проверки положительности числа:
create or replace function positive (i int) returns integer
as $$
declare
    rez int;
begin
    if (i > 0)
        then rez = i;
    else
        raise exception 'non_positive_number';
    end if;

    return rez;
end;
$$ language plpgsql immutable;

select positive(1);
select positive(0);
select positive(-1);

-- Интервал дат:
create function date_interval (d_start date, d_end date) returns setof date
as $$
declare
    d date;
begin
    d = d_start;

    while d <= d_end loop
        d = d + interval '1 day';
        return next d;
    end loop;
end;
$$ language plpgsql immutable;

select * from date_interval ('2000-01-01','2000-02-04');


create or replace function percent_start() returns table(num_carrier_rocket integer, percent float)
as $$
declare
    total int;
begin
    select count(*) from space_vehicle into total;

    for num_carrier_rocket, percent in
        select space_vehicle.num_carrier_rocket, count(*)::float / total
        from space_vehicle
        group by space_vehicle.num_carrier_rocket
    loop
        return next;
    end loop;
end
$$ language plpgsql stable;

select * from percent_start();