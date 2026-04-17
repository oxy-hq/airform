select
    item_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite_source"."stg_netsuite__items"
where item_id is not null
group by item_id
having count(*) > 1
