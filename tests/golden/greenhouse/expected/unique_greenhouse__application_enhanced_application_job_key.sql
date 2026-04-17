select
    application_job_key as unique_field,
    count(*) as n_records

from "greenhouse"."main_greenhouse"."greenhouse__application_enhanced"
where application_job_key is not null
group by application_job_key
having count(*) > 1
