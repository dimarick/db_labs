
select * from s; -- 0 строк


begin isolation level serializable;
select * from s where name = 'u'; -- 0


insert into s (name) values ('u');
-- ERROR: could not serialize access

rollback;