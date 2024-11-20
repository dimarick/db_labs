delete from s where true;

insert into s (name) values ('q');
insert into s (name) values ('w');



begin isolation level read uncommitted;
update s set name = 'e' where name = 'q';

select * from s; -- e w
commit;

