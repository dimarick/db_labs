
select * from s; -- 0 строк


begin isolation level read committed;
select * from s; -- q w


select * from s; -- q w


select * from s; -- e w
commit;
