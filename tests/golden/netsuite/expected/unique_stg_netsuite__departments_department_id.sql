select
    department_id as unique_field,
    count(*) as n_records

from "netsuite"."main_netsuite_source"."stg_netsuite__departments"
where department_id is not null
group by department_id
having count(*) > 1
