-- Для таблицы «космические тела», написать триггеры
-- проверки на появление значений образующих циклы. (mod035)

create or replace function cycle_detect() returns trigger
as $$
declare
    path text[];
    path_str text;
    row heavenly_body%rowtype;
begin
    if new.num_heavenly_body = new.satellite then
        raise exception 'Небесное тело не может быть спутником самого себя';
    end if;

    row = new;
    path = path || row.name_heavenly_body;

    loop
        select * into row from heavenly_body body where body.num_heavenly_body = row.satellite;
        path = path || row.name_heavenly_body;
        exit when row.num_heavenly_body = new.num_heavenly_body or row.satellite is null;
    end loop;

    if row.num_heavenly_body = new.num_heavenly_body then
        path_str = array_to_string(path, ' -> ');

        raise exception 'Обнаружен цикл: %', path_str;
    end if;

    return new;
end;
$$ language plpgsql;

create or replace trigger cycle_detect_insert after insert on heavenly_body for each row execute function cycle_detect();
create or replace trigger cycle_detect_update after update on heavenly_body for each row execute function cycle_detect();

-- ошибка
insert into heavenly_body(num_heavenly_body, name_heavenly_body, satellite)
values
    (13, 'Pluto', 13);

-- успех
insert into heavenly_body(num_heavenly_body, name_heavenly_body, satellite)
values
    (13, 'Pluto', 1);

-- ошибка
update heavenly_body set satellite = 8 where num_heavenly_body = 1;

-- успех
insert into heavenly_body(num_heavenly_body, name_heavenly_body, satellite)
values
    (14, 'Стрелец-А', null);

-- успех
update heavenly_body set satellite = 14 where num_heavenly_body = 1;

-- ошибка
update heavenly_body set satellite = 8 where num_heavenly_body = 14;
