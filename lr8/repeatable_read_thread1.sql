
select * from s; -- 0 строк


begin isolation level repeatable read;
select * from s where name = 'u'; -- 0


insert into s (name) values ('u');
-- ERROR: duplicate key

rollback;