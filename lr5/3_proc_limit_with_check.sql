-- Дополнить предыдущую процедуру дополнительной проверкой:
-- при попытке вызова процедуры с неопределенным параметром
-- или отрицательным параметром должно вызываться исключение
-- с сообщением о недопустимости оставлять параметр неопределенным
-- или указывать отрицательное значение. Ситуация с нулевым
-- значением параметра должна обрабатываться корректно

set search_path = 'products';
drop function products_with_limit(l int);
create or replace function products_with_limit(l int) returns setof products as
$$
begin
    if (l is null) then
        raise exception 'Недопустимо оставлять параметр неопределенным';
    end if;
    if (l <= 0) then
        raise exception 'Недопустимо указывать отрицательное или нулевое значение';
    end if;
    return query select * from products limit l;
end;
$$ language plpgsql stable;

select * from products_with_limit(1);
