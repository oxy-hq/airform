select
    account_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite_source"."stg_netsuite__accounts"
where account_id is not null
group by account_id
having count(*) > 1
