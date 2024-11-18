

1
nowait
read_committed
rec_version

select * from s;

insert into s (s_id) values ('q');

insert into s (s_id) values ('w');

insert into s (s_id) values ('u');

insert into s (s_id) values ('e');

2
nowait
concurrency


update s set sname='e1' where s_id='e';

insert into s (s_id) values ('r');

3
nowait
consistency

insert into s (s_id) values ('t');


4
nowait
consistency
lock_write=S
exclusive


insert into s (s_id) values ('y');


insert into s (s_id) values ('i');
insert into s (s_id) values ('o');

5
nowait
consistency
lock_read=S
exclusive
