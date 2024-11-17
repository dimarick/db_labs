-- Заполнить таблицы базы данных, созданные на предыдущей лабораторной работе.

set search_path = 'products';

select setseed(0.5);

insert into contractors(name, inn, address, city)
with cities as (select *, row_number() over () as n from (
values
    ('Екатеринбург'),
    ('Москва'),
    ('Санкт-Петербург'),
    ('Калининград'),
    ('Сочи'),
    ('Пермь'),
    ('Омск'),
    ('Новосибирск'),
    ('Брянск')
) a(city)),
streets as (select *, row_number() over () as n from (
values
    ('Улица Солнечная'),
    ('Проезд Лесной'),
    ('Переулок Цветочный'),
    ('Проспект Мирный'),
    ('Набережная Речная'),
    ('Шоссе Садовое'),
    ('Площадь Победы'),
    ('Бульвар Центральный'),
    ('Первомайская Улица')
) a(street))
select
    'org' || rand.i as name,
    round(7766000000 + random() * 1e6)::text as inn,
    city || ', ' || street  || ', д. ' || (random() * 200)::int || ', ' || (random() * 1e6)::int as address,
    city
from (select i, random() as r1 from generate_series(1, 100) n(i)) rand
left join cities on cities.n = (r1 * (select count(*) - 1 from cities))::int + 1
left join streets on streets.n = (r1 * (select count(*) - 1 from streets))::int + 1;

insert into phones(phone)
select '+790' || (r1 * 9e7 + 1e7)::int from (select i, random() as r1 from generate_series(1, 200) n(i)) rand;

insert into contractors_phones(phone_id, contractor_id)
with free_phones as (
    select *, row_number() over () as n
    from phones
    left join public.contractors_phones cp on phones.id = cp.phone_id
    where contractor_id is null order by random()
),
random_contractors as (
    select *, row_number() over () as n
    from contractors order by random()
),
count_phones as (select count(*) - 1 as c from free_phones),
count_contractors as (select count(*) - 1 as c from random_contractors)
select
    distinct
    free_phones.id as phone_id,
    random_contractors.id as contractor_id
from (select i, random() as r1 from generate_series(1, 100) n(i)) rand
inner join count_phones on true
inner join count_contractors on true
left join random_contractors on random_contractors.n = (rand.r1 * count_contractors.c)::int + 1
left join free_phones on free_phones.n = (rand.r1 * count_phones.c)::int + 1;

insert into contractors_phones(phone_id, contractor_id)
with free_phones as (
    select *, row_number() over () as n
    from phones
    left join public.contractors_phones cp on phones.id = cp.phone_id
    where contractor_id is null order by random()
),
random_contractors as (
    select *, row_number() over () as n
    from contractors order by random()
),
count_phones as (select count(*) - 1 as c from free_phones),
count_contractors as (select count(*) - 1 as c from random_contractors)
select
    distinct
    free_phones.id as phone_id,
    random_contractors.id as contractor_id
from (select i, random() as r1 from generate_series(1, 50) n(i)) rand
inner join count_phones on true
inner join count_contractors on true
left join random_contractors on random_contractors.n = (rand.r1 * count_contractors.c)::int + 1
left join free_phones on free_phones.n = (rand.r1 * count_phones.c)::int + 1;

delete from phones p where not exists(select 1 from contractors_phones cp where cp.phone_id = p.id);

insert into account(bank, current_account, correspondent_account, bik, contractor_id)
with banks as (select *, row_number() over () as n from (
values
    ('ЮниКредит Банк', '044525201', '33000000100000000101'),
    ('Альфа-Банк', '044525275', '33000000100000000102'),
    ('ПСБ', '044525237', '33000000100000000102'),
    ('ВТБ', '044525242', '33000000100000000103'),
    ('Сбербанк', '044525225', '33000000100000000104')
) a(name, bik, correspondent_account)),
count_banks as (select count(*) - 1 as c from banks),
random_contractors as (
    select *, row_number() over () as n
    from contractors order by random()
),
count_contractors as (select count(*) - 1 as c from random_contractors)
select
    banks.name,
    '4070000' || (random() * 1e13)::bigint,
    correspondent_account,
    bik,
    random_contractors.id as contractor_id
from (select i, random() as r1, random() as r2 from generate_series(1, 100) n(i)) rand
inner join count_banks on true
inner join count_contractors on true
left join banks on banks.n = (rand.r1 * count_banks.c)::int + 1
left join random_contractors on random_contractors.n = (rand.r2 * count_contractors.c)::int + 1;


insert into product_groups(name)
select 'g' || (random() * 1000)::int from generate_series(1, 10);

insert into products(name, article, group_id)
with
    groups as (select *, row_number() over () as n from product_groups),
    count_groups as (select count(*) - 1 as c from groups)
select 'product' || (random() * 1000)::int as name, (random() * 1e6)::int, groups.id as group_id
from (select i, random() as r1, random() as r2 from generate_series(1, 100) n(i)) rand
inner join count_groups on true
left join groups on groups.n = (rand.r1 * count_groups.c)::int + 1

insert into operations(date, price, quantity, flags, contractor_id)
with
    random_contractors as (
        select *, row_number() over () as n
        from contractors order by random()
    ),
    count_contractors as (select count(*) - 1 as c from random_contractors)
select
    '2024-01-01 00:00'::timestamp + interval '1 second' * (r1 * 366 * 24 * 3600) as date,
    1 + (r2 * 10000)::numeric(10, 2) as price,
    1 + (r2 * 10)::int as quantity,
    (random() * 3)::int as flags,
    random_contractors.id as contractor_id
from (select i, random() as r1, random() as r2 from generate_series(1, 100) n(i)) rand
inner join count_contractors on true
left join random_contractors on random_contractors.n = (rand.r1 * count_contractors.c)::int + 1

insert into payments(sum, date, contractor_id)
with
    random_contractors as (
        select *, row_number() over () as n
        from contractors order by random()
    ),
    count_contractors as (select count(*) - 1 as c from random_contractors)
select
    1 + (r2 * 10000)::numeric(10, 2) as sum,
    '2024-01-01 00:00'::timestamp + interval '1 second' * (r1 * 366 * 24 * 3600) as date,
    random_contractors.id as contractor_id
from (select i, random() as r1, random() as r2 from generate_series(1, 50) n(i)) rand
inner join count_contractors on true
left join random_contractors on random_contractors.n = (rand.r1 * count_contractors.c)::int + 1
;
