-- 1. Создайте пользователей: USER1, USER2, USER3, USER4, утилитой gsec, пароли установите произвольные.
create role user1 login encrypted password '123321';
create role user2 login encrypted password 'qwerty';
create role user3 login encrypted password 'asdf';
create role user4 login encrypted password 'jkl';

-- 2. Создайте роли: ROLE1, ROLE2, ROLE3. В роль ROLE1 входят: USER1, USER2, USER3; в роль ROLE2 входят: USER3, USER4.
create role role1 nologin;
create role role2 nologin;
create role role3 nologin;

grant role1 to user1;
grant role1 to user2;

grant role2 to user3;
grant role2 to user4;

-- 3. Реализуйте матрицу прав, подумайте, какие еще проблемы с безопасностью в ней могут возникнуть?

grant select,update,delete,insert,references on status to user1;
grant select,update,delete,insert,references on astronaut to user1;
grant select,update,delete,insert,references on animal to user1;
grant select,update,delete,insert,references on space_flight to user1;
grant select,update,delete,insert,references on people to user1;

grant select,references on status to user2;
grant select,references on astronaut to user2;
grant select on animal to user2;

grant select,update,insert,references on space_flight to user2;

grant select,references on people to user2;

grant references on status to user3;

grant select,update,insert on astronaut to user3;
grant select,update,insert on animal to user3;
grant select,update,insert on space_flight to user3;

select grantee, table_schema, table_name, array_agg(substring(privilege_type, 1, 1))
from information_schema.role_table_grants
where grantee not in ('postgres', 'PUBLIC', 'pg_read_all_stats')
group by grantee, table_schema, table_name
order by grantee, table_schema, table_name;

-- Дайте пользователям, принадлежащим роли ROLE2 право вставки, удаления и обновления таблицы "образование", какие дополнительные права необходимо предоставить этим пользователям?

grant insert on education to role2;
grant delete on education to role2;
grant update on education to role2;

-- Доп права:
grant select on education to role2;
grant select on educational_institution to role2;

grant insert on educational_institution to role2;
grant delete on educational_institution to role2;
grant update on educational_institution to role2;

grant references on astronaut to role2;

-- 5. Разрешите пользователям, входящим в роль ROLE2 и пользователю USER4 просматривать информацию о правопреемниках только для России и Франции.

alter table assignee enable row level security;
revoke all privileges on assignee from user4,role2;
grant select on assignee to user4,role2;
create policy assignee_access_role2 on assignee for select to role2, user4 using (num_country in (1, 5));

-- 6. Создать ограничение безопасности для пользователя USER1: разрешив просмотр только следующей информации по космодрому:
-- номер страны, название страны, год открытия; информация из других таблиц остается доступной.

grant all privileges (num_country, year_open) on cosmodrome to user1;
grant all privileges on country to user1;

-- 7. Разрешите пользователям, входящим в роль ROLE2 и пользователю USER4 просматривать
-- всю информацию и обновлять только содержимое поля дата рождения, в таблице "человек" только для космонавтов из России и США.
-- Реализовать с использованием видов и триггеров.

revoke all privileges on people from user4,role2;
create view people_restricted as select * from people where num_country in (1, 3);
grant select on people_restricted to user4,role2;

create or replace function restrict_update() returns trigger
as $$
begin
    if current_user != 'user4' and not pg_has_role(current_user, 'role2') then
        return new;
    end if;

    if
        old.num_astronaut != new.num_astronaut or
        old.num_country != new.num_country or
        old.name != new.name or
        old.family != new.family or
        old.patronymic != new.patronymic
    then
        raise exception 'Доступ запрещен';
    end if;

    return new;
end;
$$ language plpgsql;

create trigger restrict_update_people before update on people for each row execute function restrict_update();

grant update on people to user4, role2;
grant select on people to user4, role2; -- без этого гранта не работает where в update

-- поэтому чтобы снова ограничить странами вводим row level security. Правда при этом пропадает смысл триггера и вью.
alter table people enable row level security;
create policy people_access_role2 on people for select to role2, user4 using (num_country in (1, 3));

-- 8. Реализовать вариант многоуровневой зашиты для примера 035 модели.

create role data_read nologin;
create role data_add nologin;
create role data_write nologin;
create role manager_flight nologin;

create role vpupkin login password '';
create role aivanov login password '';
create role dkuleshov login password '';
create role spetrov login password '';
create role gsidorov login password '';

grant select on space_flight, space_vehicle, history_space_vehicle, type_event, heavenly_body, astronaut, species, status, country, carrier_rocket, type_space_flight, cosmodrome to data_read;
grant insert on space_flight, space_vehicle, history_space_vehicle, type_event, heavenly_body, astronaut, species, status, country, carrier_rocket, type_space_flight, cosmodrome to data_add;
grant select, update, delete, insert on space_flight, space_vehicle, history_space_vehicle, type_event, carrier_rocket, type_space_flight to manager_flight;

-- Доступ на чтение всем зарегистрированным
grant data_read to vpupkin,aivanov,dkuleshov,spetrov,gsidorov;
-- Добавление любых данных
grant data_add to vpupkin;
-- Заполнение и уточнение данных полетов
grant manager_flight to vpupkin,aivanov;
-- Полный доступ к данным
grant data_write to gsidorov;

