with __dbt__cte__int_greenhouse__job_offices as (


with job_office as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__job_office"
),

office as (

    select *
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__office"
),

agg_offices as (

    select
        job_office.source_relation,
        job_id,
        
    string_agg(office.office_name, '; ')

 as offices,
        
    string_agg(office.location_name, '; ')

 as locations

    from job_office
    join office
        on job_office.office_id = office.office_id
        and job_office.source_relation = office.source_relation

    group by 1, 2
)

select * from 
agg_offices
) select job_id
from __dbt__cte__int_greenhouse__job_offices
where job_id is null
