-- 4. Вычислить среднюю цену в таблице Операции. Для каждой записи в таблице сделать следующую проверку:
--     ◦ если существующая  цена  больше средней, то устанавливаем цену, равную средней + задаваемый фиксированный процент;
--     ◦ если существующая цена меньше средней, то устанавливаем цену, равную прежней + половина разницы между прежней и средней ценой:
--     ◦ если существующая цена равна средней, устанавливаем цену равной средней цене.

set search_path = 'products';

select
    -- На всякий случай с учетом количества, просто avg подозрительно просто
    sum(price * quantity) / sum(quantity) as avg_weighted,
    avg(price) as avg
from operations;

select *,
    case
        -- устанавливаем цену, равную средней + 18%
        when operations.price > average.avg_weighted then operations.price * 1.18
        -- если существующая цена меньше средней, то устанавливаем цену, равную прежней + половина разницы между прежней и средней ценой
        -- (среднее между этими ценами)
        when operations.price < average.avg_weighted then (operations.price + average.avg) / 2
        -- если существующая цена равна средней, устанавливаем цену равной средней цене
        else average.avg_weighted
    end as calculated_price
from operations
inner join (select
    sum(price * quantity) / sum(quantity) as avg_weighted,
    avg(price) as avg
from operations
) average on true;

