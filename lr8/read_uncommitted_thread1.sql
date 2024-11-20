
select * from s; -- 0 строк


select * from s; -- q w
begin isolation level read uncommitted;
select * from s; -- q w


select * from s; -- q w


select * from s; -- e w
commit;
select * from s; -- e w
