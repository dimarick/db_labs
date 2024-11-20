delete from s where true;

insert into s (name) values ('q');
insert into s (name) values ('w');


begin isolation level serializable;
insert into s (name) values ('u');



select * from s; -- q w u
commit;

select * from s; -- q w u
