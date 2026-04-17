select
    subsidiary_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite_source"."stg_netsuite__subsidiaries"
where subsidiary_id is not null
group by subsidiary_id
having count(*) > 1
