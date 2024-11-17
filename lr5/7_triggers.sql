-- Адаптировать примеры триггеров для своей БД.

-- Генерация уникальных значений:
-- (Сначала надо создать генератор GEN_TOVAR.)

set search_path = 'tovar';

create sequence tovar_id_seq;
select setval('tovar_id_seq', (select max(tovar.id_tovar) from tovar), true);

create or replace function on_tovar_insert() returns trigger
as $$
declare
    next_id int;
begin
    select nextval('tovar_id_seq') into next_id;
    new.id_tovar = next_id;
    return new;
end;
$$ language plpgsql;

create or replace trigger tovar_bi before insert on tovar for each row when (new.id_tovar is null) execute function on_tovar_insert();

insert into tovar(id_tovar, name_tovar) values (null, 'test1'), (42, 'test2');
insert into tovar(name_tovar) values ('test3'), ('test4');

select * from tovar;


--Реализация каскадных воздействий:
create or replace function on_tovar_delete() returns trigger
as $$
begin
    delete from history_tovar h where h.id_tovar = old.id_tovar;

    return old;
end;
$$ language plpgsql;

create or replace trigger tovar_bd0 before delete on tovar for each row execute function on_tovar_delete();

delete from tovar where id_tovar = 2;
select * from history_tovar;


-- Создание отчетных таблиц (внесение изменений в семантически связанные таблицы):

create or replace function update_tovar_col() returns trigger
as $$
begin
    update tovar set col_sclad = tovar.col_sclad + new.val where tovar.id_tovar = new.id_tovar;
    return new;
end;
$$ language plpgsql;

create or replace trigger sclad_ai2  after insert on sclad for each row execute function update_tovar_col();

insert into sclad(id_sclad, id_tovar, val, dat) values (6, 3, 11, now());
insert into sclad(id_sclad, id_tovar, val, dat) values (7, 3, 7, now());

select * from tovar;

create table report_tovar(
    year_report integer not null,
    kvartal_report integer not null,
    id_tovar integer not null,
    val integer,
    primary key (year_report, kvartal_report, id_tovar)
);

create or replace function update_report() returns trigger
as $$
declare
    quarter int;
    year int;
begin
    quarter = extract(quarter from new.dat);
    year = extract(year from new.dat);

    insert into report_tovar(year_report, kvartal_report, id_tovar, val)
    values (year, quarter, new.id_tovar, new.val)
    on conflict (year_report, kvartal_report, id_tovar) do update set val = report_tovar.val + excluded.val;

    return new;
end;
$$ language plpgsql;

create or replace trigger sclad_ai4 after insert on sclad for each row execute function update_report();

insert into sclad(id_sclad, id_tovar, val, dat)
values
    (8, 3, 11, '2024-01-01'),
    (9, 3, 7, '2024-02-01'),
    (10, 1, 7, '2024-02-01'),
    (11, 1, 7, '2024-08-01');

select * from report_tovar;


-- Ведение журнала изменений

create sequence history_tovar_id_seq;
select setval('history_tovar_id_seq', (select max(id_history) from history_tovar), true);

alter table history_tovar alter column id_history set default nextval('history_tovar_id_seq');

create or replace function insert_history() returns trigger
as $$
begin
    insert into history_tovar (id_tovar, date_change, operation,
    new_cost, operator)
    values (new.id_tovar, now(), 'i' ,new.cost, user);

    return new;
end;
$$ language plpgsql;

create or replace function update_history() returns trigger
as $$
begin
    insert into history_tovar (id_tovar, date_change, operation,
    new_cost, operator)
    values (new.id_tovar, now(), 'u' ,new.cost, user);

    return new;
end;
$$ language plpgsql;

create or replace trigger tovar_ai0 after insert on tovar for each row execute function insert_history();
create or replace trigger tovar_au0 after update on tovar for each row execute function update_history();

update tovar set cost = cost + 1 where id_tovar = 1;
insert into tovar (name_tovar, col_sclad, cost) values ('test5', 5, 7);

select * from history_tovar;
