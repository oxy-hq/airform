select
    currency_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite_source"."stg_netsuite__currencies"
where currency_id is not null
group by currency_id
having count(*) > 1
