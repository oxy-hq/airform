select
    class_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite_source"."stg_netsuite__classes"
where class_id is not null
group by class_id
having count(*) > 1
