-- Написать процедуру, возвращающую первые N номеров Товаров и их названий,   где N передается в качестве аргумента процедуры.

set search_path = 'products';

drop function if exists products_with_limit(l int);
create or replace function products_with_limit(l int) returns setof products as
$$
begin
    return query select * from products limit l;
end;
$$ language plpgsql stable;

select * from products_with_limit(11);
