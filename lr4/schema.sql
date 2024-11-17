create schema products;

create table products.contractors (
    id serial not null primary key,
    name text,
    inn varchar(20) not null,
    address text,
    city text not null
);

create unique index constraint_inn on products.contractors(inn);
comment on table products.contractors is 'Контрагенты';
comment on column products.contractors.name is 'Наименование';
comment on column products.contractors.inn is 'ИНН';
comment on column products.contractors.address is 'Адрес';
comment on column products.contractors.city is 'Город';

create table products.phones (
    id serial not null primary key,
    phone varchar(12)
);

comment on table products.phones is 'Телефоны';
comment on column products.phones.phone is 'Номер';

create table products.contractors_phones (
    phone_id int not null,
    contractor_id int not null,
    primary key (phone_id, contractor_id),
    foreign key (phone_id) references  products.phones(id) on delete cascade on update restrict,
    foreign key (contractor_id) references  products.contractors(id) on delete cascade on update restrict
);

create index contractors_phones_contractor_id on products.contractors_phones(contractor_id);

create table products.account (
    id serial not null primary key,
    bank text not null,
    current_account text not null,
    correspondent_account text not null,
    bik text not null,
    contractor_id int not null,
    foreign key (contractor_id) references products.contractors(id) on delete restrict on update restrict
);

comment on table products.account is 'Телефоны';
comment on column products.account.bank is 'Банк';
comment on column products.account.current_account is 'Расчетный счет';
comment on column products.account.correspondent_account is 'Кор. Счет';
comment on column products.account.bik is 'БИК';

create table products.product_groups (
    id serial not null primary key,
    name text
);

comment on table products.product_groups is 'Группа товара';
comment on column products.product_groups.name is 'Наименование группы';

create table products.products (
    id serial not null primary key,
    name text not null,
    article text not null,
    manufacturer text,
    group_id int not null,
    foreign key (group_id) references product_groups(id) on delete restrict on update restrict
);

create index products_group_id on products.products(group_id);

comment on table products.products is 'Товар';
comment on column products.products.name is 'Наименование товара';
comment on column products.products.article is 'Артикул';
comment on column products.products.manufacturer is 'Производство';

create table products.operations (
    id serial not null primary key,
    date timestamp not null,
    price numeric(10, 2),
    quantity int not null,
    flags int not null,
    contractor_id int not null,
    foreign key (contractor_id) references contractors(id) on delete restrict on update restrict,
    check ( price > 0 and quantity > 0 )
);

comment on table products.operations is 'Операции';
comment on column products.operations.date is 'Дата операции';
comment on column products.operations.price is 'Цена';
comment on column products.operations.quantity is 'Количество';
comment on column products.operations.flags is 'Признак';

create table products.payments (
    id serial not null primary key,
    sum numeric(10, 2),
    date timestamp not null,
    contractor_id int not null,
    foreign key (contractor_id) references contractors(id) on delete restrict on update restrict,
    check ( sum > 0 )
);

comment on table products.operations is 'Расчеты';
comment on column products.operations.price is 'Сумма расчета';
comment on column products.operations.date is 'Дата расчета';
