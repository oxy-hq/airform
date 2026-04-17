select
    consolidated_exchange_rate_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite_source"."stg_netsuite__consolidated_exchange_rates"
where consolidated_exchange_rate_id is not null
group by consolidated_exchange_rate_id
having count(*) > 1
